#!/usr/bin/env bash
set -euo pipefail

fail() { printf '%s\n' "$1" >&2; exit 1; }
verbose=false
log() { "$verbose" && printf '%s\n' "$*" >&2 || true; }

command -v gh >/dev/null || fail 'GitHub CLI (gh) is required.'
command -v jq >/dev/null || fail 'jq is required.'
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
touch "$tmpdir/threads.jsonl" "$tmpdir/items.jsonl"

selector=
while [ "$#" -gt 0 ]; do
  case "$1" in
    -v|--verbose) verbose=true ;;
    -h|--help) printf '%s\n' 'Usage: fetch-comments.sh [-v|--verbose] [PR-number-or-URL]'; exit 0 ;;
    -*) fail "Unknown option: $1" ;;
    *) [ -z "$selector" ] || fail 'Usage: fetch-comments.sh [-v|--verbose] [PR-number-or-URL]'; selector=$1 ;;
  esac
  shift
done

if [ -n "$selector" ]; then
  pr=$(gh pr view "$selector" --json number,url) || fail 'Could not identify pull request.'
else
  pr=$(gh pr view --json number,url) || fail 'Could not find a pull request for the current branch.'
fi
number=$(jq -er '.number' <<<"$pr")
url=$(jq -er '.url' <<<"$pr")
if [[ $url =~ ^https://github\.com/([^/]+)/([^/]+)/pull/[0-9]+$ ]]; then
  owner=${BASH_REMATCH[1]}
  name=${BASH_REMATCH[2]}
else
  fail "Could not determine the repository from PR URL: $url"
fi
log "Fetching feedback for $url"
api() { gh api graphql "$@"; }
is_bot_report='(.body | test("<!-- sarif-pr-comment|<!-- linear-linkback -->"))'

cursor=null
thread_pages=0
while :; do
  page=$(api -f query='query($owner:String!, $name:String!, $number:Int!, $cursor:String) { repository(owner:$owner, name:$name) { pullRequest(number:$number) { reviewThreads(first:100, after:$cursor) { nodes { id isResolved isOutdated path line originalLine } pageInfo { hasNextPage endCursor } } } } }' -F owner="$owner" -F name="$name" -F number="$number" -F cursor="$cursor") || fail 'Could not fetch review threads.'
  jq -e '.data.repository.pullRequest.reviewThreads' >/dev/null <<<"$page" || fail 'GitHub returned no review-thread data.'
  thread_pages=$((thread_pages + 1))
  log "Fetched review-thread page $thread_pages"
  jq -c '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved | not)' <<<"$page" >>"$tmpdir/threads.jsonl"
  has_next=$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage' <<<"$page")
  [ "$has_next" = true ] || break
  cursor=$(jq -er '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor' <<<"$page")
done

log "Fetching comments for $(wc -l <"$tmpdir/threads.jsonl" | tr -d ' ') unresolved review thread(s)"
while IFS= read -r thread; do
  id=$(jq -er '.id' <<<"$thread")
  comments='[]'
  cursor=null
  while :; do
    page=$(api -f query='query($id:ID!, $cursor:String) { node(id:$id) { ... on PullRequestReviewThread { comments(first:100, after:$cursor) { nodes { id author { login } body url } pageInfo { hasNextPage endCursor } } } } }' -F id="$id" -F cursor="$cursor") || fail 'Could not fetch review-thread comments.'
    jq -e '.data.node.comments' >/dev/null <<<"$page" || fail 'GitHub returned no review-thread comment data.'
    comments=$(jq -c --argjson prior "$comments" '$prior + .data.node.comments.nodes' <<<"$page")
    has_next=$(jq -r '.data.node.comments.pageInfo.hasNextPage' <<<"$page")
    [ "$has_next" = true ] || break
    cursor=$(jq -er '.data.node.comments.pageInfo.endCursor' <<<"$page")
  done
  log "Fetched $id with $(jq 'length' <<<"$comments") comment(s)"
  jq -cn --argjson thread "$thread" --argjson comments "$comments" --arg pr_url "$url" '($comments | map(select('"$is_bot_report"' | not))) as $kept | select($kept | length > 0) | {kind:"review_thread", id:$thread.id, url:($kept[0].url // $pr_url), outdated:$thread.isOutdated, path:$thread.path, line:$thread.line, original_line:$thread.originalLine, comments:[$kept[] | {id, author:(.author.login // null), body}]}' >>"$tmpdir/items.jsonl"
done <"$tmpdir/threads.jsonl"

cursor=null
pr_comment_pages=0
while :; do
  page=$(api -f query='query($owner:String!, $name:String!, $number:Int!, $cursor:String) { repository(owner:$owner, name:$name) { pullRequest(number:$number) { comments(first:100, after:$cursor) { nodes { id author { login } body url } pageInfo { hasNextPage endCursor } } } } }' -F owner="$owner" -F name="$name" -F number="$number" -F cursor="$cursor") || fail 'Could not fetch pull-request comments.'
  jq -e '.data.repository.pullRequest.comments' >/dev/null <<<"$page" || fail 'GitHub returned no pull-request comment data.'
  pr_comment_pages=$((pr_comment_pages + 1))
  log "Fetched PR-level-comment page $pr_comment_pages"
  jq -c '.data.repository.pullRequest.comments.nodes[] | select('"$is_bot_report"' | not) | {kind:"pr_level_comment", id, url, author:(.author.login // null), body}' <<<"$page" >>"$tmpdir/items.jsonl"
  has_next=$(jq -r '.data.repository.pullRequest.comments.pageInfo.hasNextPage' <<<"$page")
  [ "$has_next" = true ] || break
  cursor=$(jq -er '.data.repository.pullRequest.comments.pageInfo.endCursor' <<<"$page")
done

log "Emitting $(wc -l <"$tmpdir/items.jsonl" | tr -d ' ') item(s)"
cat "$tmpdir/items.jsonl"
