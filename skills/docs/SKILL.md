---
name: docs
description: Create and improve technical documentation. Use when the user wants to write docs, create a README, write an ADR, document an API, create a quickstart guide, write a runbook, create a migration guide, write an RFC or design doc, improve existing documentation, or mentions "docs" or "documentation".
---

# Documentation

Write clear, warm, well-structured documentation that helps readers accomplish their goals.

## Workflow

### 1. Clarify what needs documenting

Before writing anything, work through this checklist. For each item that isn't answered by the user's request or the codebase, ask before proceeding.

| Question  | What to establish                                                                                                                      |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **What**  | Scope — new feature, entire system, specific workflow, or update to existing doc?                                                      |
| **Who**   | Audience — determines terminology, detail level, and which examples resonate                                                           |
| **Why**   | Reader's need — do they want an overview, a task walk-through, step-by-step instructions, or a lookup? Maps directly to Diátaxis type. |
| **Where** | Doc location — default `docs/` in repo root; discuss if that doesn't fit the audience or delivery channel                              |
| **How**   | How does this thing work *in this codebase specifically*? Document the implementation, not the general concept.                        |
| **When**  | Usage context — development, onboarding, incident response, or maintenance?                                                            |

You don't need all six answers for every doc. A trivial README update needs almost none of them. A new runbook needs all of them. Use judgment about which gaps matter.

### 2. Determine the audience

If the audience is obvious from context (for example, a README in an open source library targets developers), proceed.

**If not obvious, ask the user explicitly.** Never assume the audience. The tone, depth, and structure all depend on who is reading.

### 3. Route to the appropriate guidance

Consult the relevant guide based on doc type. Every document falls into one of two categories.

**User-facing documentation** — apply the [Diátaxis framework](guides/diataxis.md):

| Doc type                     | Guide                                          | Diátaxis category                 |
| ---------------------------- | ---------------------------------------------- | --------------------------------- |
| README                       | [readme.md](templates/readme.md)               | Hybrid (orientation + quickstart) |
| Quickstart / Getting started | [quickstart.md](templates/quickstart.md)       | Tutorial                          |
| How-to guide                 | [how-to-guide.md](templates/how-to-guide.md)   | How-to                            |
| API reference                | [api-reference.md](templates/api-reference.md) | Reference                         |

**Decision and design documents** — purpose-specific templates:

| Doc type                           | Guide                                              |
| ---------------------------------- | -------------------------------------------------- |
| ADR (Architecture Decision Record) | [adr.md](templates/adr.md)                         |
| RFC / Design doc                   | [rfc-design-doc.md](templates/rfc-design-doc.md)   |
| Migration guide                    | [migration-guide.md](templates/migration-guide.md) |
| Runbook                            | [runbook.md](templates/runbook.md)                 |

For **all** doc types, also consult:

- [tone-and-voice.md](guides/tone-and-voice.md) — writing style and tone
- [code-examples.md](guides/code-examples.md) — standards for code in documentation

### 4. Explore the codebase

**If it's clear what's being documented:** explore the codebase first. Read relevant source files, tests, and existing docs. Then propose a document structure to the user for approval before writing.

**If it's not clear:** ask the user first (step 1), then explore.

### 5. Determine document location

**Default:** `docs/` directory in the repo root.

Negotiate with the user if the default doesn't fit. Ask where they want the document placed.

**Flag delivery gaps:** if the document is clearly meant for end users (help articles, product guides, onboarding docs) and lives only in a git repo, raise this with the user: the target audience probably won't find it there. Don't scope creep into building a docs site or CI pipeline — just inform so the user can make a conscious choice.

### 6. Write the document

Apply guidance from the relevant doc type guide and cross-cutting concerns:

- Follow [tone-and-voice.md](guides/tone-and-voice.md) for style
- Follow [code-examples.md](guides/code-examples.md) for any code snippets
- Follow the Diátaxis category rules for user-facing docs (don't mix types)
- Follow the purpose-specific template for decision/design docs
- Use **mermaid diagrams** for visual explanations — never ASCII art
- Use **progressive disclosure** — show the simple path first, reveal complexity on demand
- **Front-load value** — readers should get useful information in the first paragraph
- **Substantiate claims** — link to sources, reference specific files/functions

### 7. Lint and verify

Before presenting the document to the user, run the bundled lint script:

```bash
bash skills/docs/scripts/lint-docs.sh <file-or-directory>
```

This runs **markdownlint** and **Vale** (if installed). See [linting.md](guides/linting.md) for configuration details.

Additionally:

1. **Verify all code examples** — execute them to confirm they work in the repo's language
2. Check that all internal links resolve

## Rules

- **Ask, don't assume** the audience when it's ambiguous
- **Never mix Diátaxis types** in user-facing docs — know which of the four you're writing
- **Use mermaid diagrams** over ASCII art for all visual explanations
- **Code examples must be verified** — run them to confirm they work
- **Stay in the repo's language** for code examples — no multi-language tabs
- **Progressive disclosure** — simple path first, advanced details on demand
- **Substantiate claims** — link to sources, don't hand-wave
- **Don't scope creep** into building doc delivery infrastructure — but flag when it's needed
- **Lint before delivering** — every document passes markdownlint and Vale
