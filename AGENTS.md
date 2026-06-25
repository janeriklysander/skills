# AGENTS.md

Guidance for coding agents working in this repository.

## What this repo is

This is an agent-agnostic skills repository. It contains reusable Markdown skills under `skills/<name>/`.

This repo has no build system, package manager, or test suite. The only executable is the docs lint script.

## Repository layout

```text
skills/
  docs/
    SKILL.md
    guides/
    templates/
    scripts/
      lint-docs.sh
```

## Skill format

Skills use minimal YAML frontmatter:

```yaml
---
name: docs
description: Create and improve technical documentation...
---
```

Keep skill source harness-agnostic:

- Do not add marketplace manifests.
- Do not add tool permission fields.
- Do not add agent-specific environment variables.
- Do not add agent-specific install commands.
- Keep bundled resources beside the skill that uses them.

## Linting

Run the docs linter after changing Markdown:

```bash
bash skills/docs/scripts/lint-docs.sh <file-or-directory>
```

The script requires Node.js for markdownlint through `npx`. Vale runs when installed.

## Working rules

- Make small, focused changes.
- Preserve relative links when moving skill resources.
- Prefer repo-relative paths in examples.
- Check for harness-specific leftovers before finishing.
- Run relevant lint checks before reporting done.
