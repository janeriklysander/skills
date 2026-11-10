#!/usr/bin/env bats

setup() {
  root="$BATS_TEST_DIRNAME/.."
  fake_bin="$BATS_TEST_TMPDIR/bin"
  log="$BATS_TEST_TMPDIR/gh.log"
  mkdir "$fake_bin"
  export PATH="$fake_bin:$PATH"
  export FAKE_GH_LOG="$log"

  cat >"$fake_bin/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$FAKE_GH_LOG"

case "$1 $2" in
  "repo view")
    printf '%s\n' 'octo/example'
    ;;
  "api graphql")
    case "$*" in
      *addPullRequestReviewThreadReply*)
        [ "${FAKE_REPLY_SUCCEEDS:-true}" = true ] || exit 1
        response='{"data":{"addPullRequestReviewThreadReply":{"comment":{"id":"comment-1","url":"https://github.com/octo/example/pull/1#discussion_r1"}}}}'
        printf '%s\n' "${FAKE_REPLY_RESPONSE:-$response}"
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  "api repos/"*)
    [ "${FAKE_COMMIT_EXISTS:-true}" = true ] || exit 1
    printf '%s\n' '{}'
    ;;
  *)
    exit 1
    ;;
esac
EOF
  chmod +x "$fake_bin/gh"
}

@test "reply posts the standard addressed message for a pushed commit" {
  run bash "$root/scripts/reply-to-thread.sh" thread-1 --sha abcdef1

  [ "$status" -eq 0 ]
  [ "$output" = 'thread-1 https://github.com/octo/example/pull/1#discussion_r1' ]
  grep -Fq 'comment { id url }' "$log"
  grep -Fq 'api repos/octo/example/commits/abcdef1' "$log"
  grep -Fq 'addPullRequestReviewThreadReply' "$log"
  grep -Fq 'threadId=thread-1' "$log"
  grep -Fq 'body=Addressed in abcdef1.' "$log"
}

@test "reply appends an approved short description" {
  run bash "$root/scripts/reply-to-thread.sh" thread-1 --sha abcdef1 --description 'Clarified the fallback behavior.'

  [ "$status" -eq 0 ]
  grep -Fq 'body=Addressed in abcdef1. Clarified the fallback behavior.' "$log"
}

@test "reply accepts a description of exactly 140 characters" {
  printf -v description '%*s' 140 ''
  description=${description// /x}

  run bash "$root/scripts/reply-to-thread.sh" thread-1 --sha abcdef1 --description "$description"

  [ "$status" -eq 0 ]
  grep -Fq "body=Addressed in abcdef1. $description" "$log"
}

@test "reply rejects an invalid SHA before contacting GitHub" {
  run bash "$root/scripts/reply-to-thread.sh" thread-1 --sha not-a-sha

  [ "$status" -ne 0 ]
  [ ! -s "$log" ]
}

@test "reply refuses to post when the commit is absent from the remote repository" {
  run env FAKE_COMMIT_EXISTS=false bash "$root/scripts/reply-to-thread.sh" thread-1 --sha abcdef1

  [ "$status" -ne 0 ]
  grep -Fq 'api repos/octo/example/commits/abcdef1' "$log"
  ! grep -Fq 'addPullRequestReviewThreadReply' "$log"
}

@test "reply rejects descriptions longer than 140 characters before contacting GitHub" {
  printf -v description '%*s' 141 ''
  description=${description// /x}

  run bash "$root/scripts/reply-to-thread.sh" thread-1 --sha abcdef1 --description "$description"

  [ "$status" -ne 0 ]
  [ ! -s "$log" ]
}

@test "reply posts a plain description when there is no commit SHA" {
  run bash "$root/scripts/reply-to-thread.sh" thread-1 --description 'Clarification: the retry limit is intentional.'

  [ "$status" -eq 0 ]
  ! grep -Fq 'commits/' "$log"
  grep -Fq 'body=Clarification: the retry limit is intentional.' "$log"
}

@test "reply requires a description when no SHA is given" {
  run bash "$root/scripts/reply-to-thread.sh" thread-1

  [ "$status" -ne 0 ]
  [ ! -s "$log" ]
}

@test "reply fails without a success line when the GitHub request fails" {
  run bash -c 'FAKE_REPLY_SUCCEEDS=false bash "$1" thread-1 --description Answer >"$2"' \
    _ "$root/scripts/reply-to-thread.sh" "$BATS_TEST_TMPDIR/stdout"

  [ "$status" -eq 1 ]
  [ "$output" = 'Could not reply to Review Thread.' ]
  [ ! -s "$BATS_TEST_TMPDIR/stdout" ]
}

@test "reply fails without a success line when GitHub does not confirm the comment" {
  for response in \
    '{"data":{"addPullRequestReviewThreadReply":{"comment":null}}}' \
    '{"data":{"addPullRequestReviewThreadReply":{"comment":{"url":"https://github.com/octo/example/pull/1#discussion_r1"}}}}' \
    '{"data":{"addPullRequestReviewThreadReply":{"comment":{"id":"comment-1"}}}}'; do
    export FAKE_REPLY_RESPONSE="$response"
    run bash -c 'bash "$1" thread-1 --description Answer >"$2"' \
      _ "$root/scripts/reply-to-thread.sh" "$BATS_TEST_TMPDIR/stdout"

    [ "$status" -eq 1 ]
    [ "$output" = 'GitHub did not confirm the Review Thread reply.' ]
    [ ! -s "$BATS_TEST_TMPDIR/stdout" ]
  done
}
