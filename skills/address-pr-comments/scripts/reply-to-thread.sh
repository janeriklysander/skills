#!/usr/bin/env bash
set -euo pipefail

fail() { printf '%s\n' "$1" >&2; exit 1; }

usage() {
  printf '%s\n' 'Usage: reply-to-thread.sh <review-thread-id> [--sha <commit-sha>] [--description <text>]'
}

[ "$#" -ge 1 ] || { usage >&2; exit 1; }

thread_id=$1
shift
[ -n "$thread_id" ] || fail 'Review Thread ID is required.'

sha=''
description=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sha)
      [ "$#" -ge 2 ] || fail '--sha requires a value.'
      sha=$2
      shift 2
      ;;
    --description)
      [ "$#" -ge 2 ] || fail '--description requires a value.'
      description=$2
      shift 2
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

[ -n "$sha" ] || [ -n "$description" ] || fail 'A description is required when no commit SHA is given.'
[ -z "$sha" ] || [[ $sha =~ ^[[:xdigit:]]{7,40}$ ]] || fail 'Commit SHA must contain 7 to 40 hexadecimal characters.'
[ -z "$description" ] || [[ $description =~ [^[:space:]] ]] || fail 'Description cannot be blank.'
[ "${#description}" -le 140 ] || fail 'Description must not exceed 140 characters.'

command -v gh >/dev/null || fail 'GitHub CLI (gh) is required.'
command -v jq >/dev/null || fail 'jq is required.'

if [ -n "$sha" ]; then
  repository=$(gh repo view --json nameWithOwner --jq '.nameWithOwner') ||
    fail 'Could not identify the GitHub repository for the current checkout.'
  [ -n "$repository" ] || fail 'Could not identify the GitHub repository for the current checkout.'

  gh api "repos/$repository/commits/$sha" --silent >/dev/null ||
    fail "Commit $sha was not found in the remote repository."

  body="Addressed in $sha."
  if [ -n "$description" ]; then
    body+=" $description"
  fi
else
  body=$description
fi

response=$(gh api graphql \
  -f query='mutation($threadId: ID!, $body: String!) { addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) { comment { id } } }' \
  -f threadId="$thread_id" \
  -f body="$body") || fail 'Could not reply to Review Thread.'

jq -e '.data.addPullRequestReviewThreadReply.comment.id' >/dev/null <<<"$response" ||
  fail 'GitHub did not confirm the Review Thread reply.'
