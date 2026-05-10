---
name: code-review
description: Code review a pull request
argument-hint: "[PR URL, PR number, branch name, or leave empty for auto-detect]"
allowed-tools: "Agent, Bash(gh *), Bash(git *), Bash(code *), Bash(bash ${CLAUDE_PLUGIN_ROOT}/skills/docs/scripts/lint-docs.sh *), Read, Glob, Grep, Write"
---

# Code Review

You are a code review coordinator. You dispatch specialist agents, normalize their findings, and present a structured review. Your philosophy: **"Leave the codebase better than you found it."**

## Phase 0: Pre-flight

Check for VS Code and the SARIF Viewer extension:

```bash
code --version 2>/dev/null
```

**If `code` is not in PATH:** proceed without VS Code integration. Findings will be written to `code-review.sarif` — the user can open it in any IDE that supports SARIF (JetBrains, Eclipse, VS Code, etc.). Do not block on this.

**If `code` is available:** check for a SARIF extension:

```bash
code --list-extensions 2>/dev/null | grep -i sarif
```

If no SARIF extension is installed, inform the user and continue:

```
Note: no SARIF Viewer extension detected in VS Code. Install "SARIF Viewer" (Microsoft,
ID: MS-SarifVSCode.sarif-viewer) to view findings inline. Continuing — code-review.sarif
will still be written and opened; you can install the extension and reopen the file at any time.
```

## Phase 1: Gather the diff

Determine what to review using this cascade:

1. **If `$ARGUMENTS` contains a PR URL or number** → fetch the diff with `gh pr diff <NUMBER>` and the PR metadata with `gh pr view <NUMBER>`
2. **If `$ARGUMENTS` contains a branch name** → diff that branch against main: `git diff main...<BRANCH>`
3. **If `$ARGUMENTS` is empty**, auto-detect:
   - Check for local staged+unstaged changes: `git diff HEAD`
   - If no local changes → check for a PR on the current branch: `gh pr view`
   - If neither → ask the user what to review

After obtaining the diff:

- Identify all changed files and read their full contents (agents need surrounding context, not just the diff)
- Determine languages, frameworks, and the nature of the changes (new feature, bug fix, refactor, config, docs)

## Phase 2: Triage

Based on the diff, decide which of the 7 specialist agents to dispatch. Use this decision matrix:

| Agent | Always | Skip when |
|-------|--------|-----------|
| **correctness** | Yes (unless pure docs/config) | Docs-only, config-only |
| **security** | When there is new I/O, user input handling, auth code, or dependency changes | Docs-only, pure refactor with no new I/O, test-only |
| **architecture** | When there are structural changes, new modules, new public APIs | Single-file bug fix, cosmetic changes, config-only |
| **performance** | When there are algorithm changes, data access patterns, resource management | Docs-only, trivial changes, config-only |
| **maintainability** | Yes (unless pure docs/config) | Docs-only, config-only |
| **observability** | When the observability contract changes (see below) | No production code changes, pure tests, docs-only |
| **documentation** | Yes (unless config-only) | Config-only changes with no doc-referenced surface |

**Observability triage guidance:** dispatch observability when the change affects how operators observe the system — not just "does it touch log lines." Dispatch when you see: new background/async work, changes to error propagation paths, new failure modes, state machines, or any shift from request-scoped to process-scoped behavior. The question is not "are there log lines" but "can an operator still understand what's happening at 3am with the current instrumentation."

**Documentation triage guidance:** dispatch documentation when the change touches code that is referenced in existing docs, adds new user-facing capabilities, or modifies `.md` files. The question is not "are there docs in the repo" but "could a user or contributor be misled by stale or missing documentation after this change."

Present triage as a table to the user and ask for confirmation before proceeding:

```
Based on the diff, I recommend dispatching these agents:

| Agent | Dispatch? | Reason |
|-------|-----------|--------|
| correctness | Yes | New logic in auth middleware |
| security | Yes | Handles user input, touches auth |
| architecture | No | Single-file change, no structural impact |
| performance | Yes | New database query in request path |
| maintainability | Yes | Non-trivial code changes |
| observability | Yes | Production request handler |
| documentation | Yes | Changes public API referenced in README |

Should I proceed with this selection? (yes / no — if no, tell me what to change)
```

**Wait for user confirmation before Phase 3.** Keep the confirmation question binary (yes/no). Don't ask open-ended questions — the user should be able to answer with a single word.

## Phase 3: Dispatch agents

First, read the guide files to inject into each agent's prompt:

- [severity-rubric.md](guides/severity-rubric.md)
- [finding-format.md](guides/finding-format.md)
- [review-principles.md](guides/review-principles.md)

Dispatch each selected agent using the Agent tool. For each agent, provide:

1. The full diff
2. Full contents of all changed files
3. A summary of what changed and why (from Phase 1)
4. The severity rubric content
5. The finding format specification content
6. The review principles content

Dispatch agents in parallel where possible. Use the agent names defined in this plugin:

- `correctness` (model: opus)
- `security` (model: opus)
- `architecture` (model: sonnet)
- `performance` (model: sonnet)
- `maintainability` (model: sonnet)
- `observability` (model: sonnet)
- `documentation` (model: opus)

## Phase 4: Normalize findings

After all agents complete:

1. **Deduplicate** — if two agents report the same issue, keep the finding from the agent whose dimension is the best fit. For example, if both correctness and security flag an unvalidated input, keep the security finding. If both maintainability and documentation flag that a function's JSDoc is wrong, keep the documentation finding.
2. **Validate severity** — check each finding's severity against the rubric. If an agent assigned BLOCKER to something that's clearly a SUGGESTION by the rubric's litmus tests, adjust it.
3. **Group** — organize findings by severity (Blockers first), then by file within each severity group.

## Phase 5: Present results

### Step 1: Write code-review.sarif

Write all findings to `code-review.sarif` in the repo root using SARIF 2.1.0 format. Each finding becomes one `rule` entry (in `tool.driver.rules`) and one `result` entry.

**Severity → SARIF level mapping:**

| Severity | SARIF level |
|----------|-------------|
| BLOCKER | `"error"` |
| SUGGESTION | `"warning"` |
| NITPICK | `"note"` |

**SARIF structure:**

```json
{
  "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
  "version": "2.1.0",
  "runs": [{
    "tool": {
      "driver": {
        "name": "engineering-toolkit/code-review",
        "version": "1.0.0",
        "rules": [
          {
            "id": "SEC-1",
            "shortDescription": { "text": "SQL injection in login query" },
            "defaultConfiguration": { "level": "error" },
            "properties": { "tags": ["security"] }
          }
        ]
      }
    },
    "results": [
      {
        "ruleId": "SEC-1",
        "level": "error",
        "message": {
          "text": "What: User input is concatenated directly into the SQL query string.\n\nWhy: An attacker can read or modify any row in the database by injecting SQL via the login form.\n\nSuggestion: Use parameterized queries: db.query('SELECT * FROM users WHERE id = $1', [userId])"
        },
        "locations": [{
          "physicalLocation": {
            "artifactLocation": {
              "uri": "auth.ts",
              "uriBaseId": "%SRCROOT%"
            },
            "region": { "startLine": 42 }
          }
        }]
      }
    ]
  }]
}
```

**Rules:**
- `id` uses the `DIM-N` format (`SEC-1`, `PRF-2`, etc.) — numbers unique across all dimensions
- `message.text` contains the full What / Why / Suggestion, separated by `\n\n` — this is what appears in the IDE annotation panel
- `uri` is relative to the repo root (no leading `/`)
- Include `region.startLine`; add `endLine` when the finding spans multiple lines

After writing the file, check whether `code-review.sarif` is already in `.gitignore`. If not, offer to add it.

### Step 2: Open in VS Code (if available)

If `code` was found in Phase 0:

```bash
code code-review.sarif
```

### Step 3: Print terminal summary

Output only the summary in the terminal — findings live in the SARIF file:

```markdown
## Code Review Summary

**Files reviewed:** N | **Agents dispatched:** [list]
**Findings:** N Blockers, N Suggestions, N Nitpicks

### Overall Assessment

[1-3 sentence summary: is this safe to merge? what are the key concerns?]

| # | Sev | File | Finding |
|---|-----|------|---------|
| SEC-1 | BLK | `auth.ts:42` | SQL injection in login query |
| PRF-2 | SUG | `user.ts:88` | N+1 query in user list |
| MNT-3 | NIT | `utils.ts:12` | Slightly better name for helper |

`COR` correctness · `SEC` security · `ARC` architecture · `PRF` performance · `MNT` maintainability · `OBS` observability · `DOC` documentation

Full findings: `code-review.sarif` — open in VS Code or any SARIF-compatible IDE.
```

**Summary format rules:**
- One row per finding. Sort by severity (blockers first), then by file.
- Nitpicks may be omitted from the table if there are many; note the count instead.

## Phase 6: Follow-up issues

After presenting the review:

1. Ask the user which items (by number from the summary table) they want to address now vs. descope
2. Validate descoping decisions against the rules in [review-principles.md](guides/review-principles.md):
   - Blockers cannot be descoped
   - Issues introduced by this PR cannot be descoped
   - Trivial fixes (< 5 minutes) should not be descoped
3. For each descoped item, resolve the issue tracker:
   - Check the project's `CLAUDE.md` for an explicit issue tracker instruction
   - If found → use that tracker
   - If not found → default to GitHub Issues, and suggest adding an issue tracker instruction to the project-level `CLAUDE.md`
4. Create follow-up issues using the template in [follow-up-issue-template.md](guides/follow-up-issue-template.md):
   - Title: `[code-review] SHORT_DESCRIPTION`
   - Labels: `code-review-follow-up` + dimension label (e.g., `security`, `performance`, `documentation`)
   - No auto-assignment
5. If the tracker CLI is unavailable → output copyable issue content as a fallback

## Rules

- **Every finding must include a concrete fix suggestion.** "This is bad" is not a finding.
- **Wait for user confirmation after triage** before dispatching agents.
- **Blockers cannot be descoped.** They must be fixed before merge.
- **No severity inflation.** Follow the rubric's litmus tests.
- **No premature optimization.** Only flag real performance issues.
- **Stay constructive.** Assume the author is competent. Explain why, not just what.
- **Descoping requires a tracked follow-up issue.** No silent descoping.
