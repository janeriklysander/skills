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

Present one compact proposal grouped by **logical change**, rather than by feedback item. Associate every affected item with its change group. For every group include its items’ URLs, classifications, rationale, intended change or response, and narrowest meaningful verification. Keep unrelated changes separate and state the focused commit message each group is ready to use. Ask the user to approve all or selected groups.

Do not modify files until approval. A discovered current-branch PR needs no confirmation. Treat a PR number or URL as the selected PR.

## 4. Implement approved changes

Change only approved groups. Keep each group independently committable; make a separate focused commit when the user asks to commit. Verify each with the proposed check: behavioral checks for code; the relevant lint/check for documentation or formatting. Draft a concise response for every addressed item:

- change: change and verification;
- reply: direct answer and evidence;
- clarify: exact missing fact;
- declined change: conflict and alternative.

Do not post replies or resolve Review Threads unless the user explicitly asks. Never claim a PR-Level Comment was resolved; it has no resolution lifecycle.

## Completion

Every fetched item is classified; approved changes are implemented and verified; and each addressed item has a response draft. State which items were intentionally unchanged.
