---
name: address-pr-comments
description: Address GitHub pull-request feedback with an approval gate.
disable-model-invocation: true
argument-hint: PR number | PR URL
---

# Address PR Comments

Address feedback without changing files until the user approves a concrete proposal.

## 1. Fetch feedback

Run [`scripts/fetch-comments.sh`](scripts/fetch-comments.sh) with a PR number or URL. With no argument, it discovers the PR for the current branch. The script emits complete NDJSON or fails without output; don't replace it with direct GitHub queries.

Treat each record by `kind`:

- `review_thread`: an unresolved inline **Review Thread**. Its `outdated` location may still describe a valid request.
- `pr_level_comment`: a **PR-Level Comment**, which has no resolution state.

## 2. Assess

Classify every returned item as one of:

- `change` — a justified modification is requested.
- `reply` — an answer is needed but no modification.
- `clarify` — a decision cannot be made from the available evidence.
- `no action` — no response or modification is warranted.
- `previously addressed` — the current branch already satisfies it.

For `change` candidates, read only the necessary current local code or document context. Use the issue/spec and existing architecture as evidence. Follow justified feedback; when it is harmful or out of scope, propose a concise evidence-backed alternative. Escalate only product or architectural decisions.

## 3. Propose and wait

Present one compact proposal grouped into **Comment Groups**. Associate every affected item with its group. For every group include its items’ URLs, classifications, rationale, intended change or response, and narrowest meaningful verification. Keep unrelated changes separate and state the focused commit message each group is ready to use.

Ask the user to approve all or selected groups. This is the **scope gate**: it picks which groups get worked, nothing more. It does not approve any commit — every group still needs its own **commit gate** in step 4.3, no matter how many groups were approved together here.

Do not modify files until approval. A discovered current-branch PR needs no confirmation. Treat a PR number or URL as the selected PR.

## 4. Work approved groups one by one

Take approved groups in the order proposed. For each group, work through 4.1-4.4 in order; do not batch multiple groups' drafting before a group's commit gate is cleared.

1. Draft the change, if any, as real file edits, with its commit message. Verify it with the proposed check: behavioral checks for code, the relevant lint/check for documentation or formatting.
2. Draft the reply for each of the group's items, using `user-tone-of-voice`:
   - `change` / `previously addressed`: `Addressed in <commit-sha>.`, plus an optional description when the change is non-obvious or deviates from the feedback.
   - `reply`: a direct answer with evidence, no commit SHA.
   - `clarify`: the exact missing fact, no commit SHA.
   - `declined change`: the conflict and the alternative, no commit SHA.
   - Descriptions and SHA-less replies should aim for 20 words or fewer. Go over only when a shorter reply would lose meaning, and stay as concise as the point allows even then.
3. Run `plannotator-review` for the code review. Then clear this group's **commit gate**: pause and show the drafted commit message and every drafted reply for this group, and wait for explicit approval. The scope gate in step 3 never substitutes for this — approving the group selection is not approving the commit or the replies.
4. On approval: commit, and push it — pushing before replying matters, since `reply-to-thread.sh` verifies the SHA against the remote. Then reply to each approved Review Thread with the thread `id` emitted by `fetch-comments.sh`; never make direct GitHub mutations:

   ```bash
   scripts/reply-to-thread.sh <review-thread-id> [--sha <commit-sha>] [--description <text>]
   ```

   `--sha` accepts only a 7- to 40-character hexadecimal SHA and is verified against the current checkout's remote GitHub repository before posting; when given, the reply is `Addressed in <sha>.` plus the description. Omit `--sha` for `reply`/`clarify`/`declined change` items — the reply becomes the description text, and a description is required when no SHA is given. Either way, the description tops out at 140 characters.

5. Once the reply for the group posts successfully, continue with the next approved group automatically — no separate confirmation is needed to start it.

Resolving a Review Thread afterward is a human-only action; nothing in this skill resolves threads. Never reply to or claim a PR-Level Comment was resolved either; it has no resolution lifecycle.

## Completion

Every fetched item is classified; approved changes are implemented and verified; and each addressed item has a response draft. State which items were intentionally unchanged.
