# Jan-Erik Lysander's Agent Skills

Reusable, agent-agnostic skills for software engineering work.

This repository is intentionally not tied to a specific coding-agent harness. Skill source lives in plain Markdown under `skills/<name>/`, with minimal frontmatter and bundled resources next to the skill that uses them.

## Skills

### docs

[`skills/docs`](skills/docs/SKILL.md) helps agents create and improve technical documentation.

It includes:

- A documentation workflow for clarifying audience, scope, purpose, location, implementation details, and usage context
- Diátaxis guidance for tutorials, how-to guides, reference docs, and explanations
- Templates for READMEs, quickstarts, how-to guides, API reference, ADRs, RFCs, migration guides, and runbooks
- Tone, voice, and code example guidance
- A bundled Markdown lint script using markdownlint and Vale

## Quickstart

Run the open agent skills installer:

```bash
npx skills@latest add janeriklysander/skills
```

The installer opens an interactive wizard where you can choose:

- which skills to install
- which agent or agents to install them for
- whether to install into the current project or globally
- whether to symlink or copy the skill files

For scripted installs, pass the choices as flags:

```bash
npx skills@latest add janeriklysander/skills --skill docs --agent pi --yes
```

To install globally instead of into the current project:

```bash
npx skills@latest add janeriklysander/skills --skill docs --global --yes
```

## Updating

Update installed skills with:

```bash
npx skills@latest update
```

The update command checks installed skills and pulls newer versions from their source repositories.

For unattended updates, run the same command from your scheduler of choice, such as cron, launchd, or a scheduled CI job:

```bash
npx skills@latest update --yes
```

Use unattended updates only if you are comfortable accepting skill prompt changes automatically. For project-local skills shared with a team, prefer a scheduled pull request that runs `npx skills@latest update --yes` and lets the team review the diff.

## Manual usage

Point your agent at [`skills/docs/SKILL.md`](skills/docs/SKILL.md), or copy the full `skills/docs` directory into your agent's skill directory.

The full directory matters because the skill references its bundled guides, templates, and linting script:

```text
skills/docs/
  SKILL.md
  guides/
  templates/
  scripts/
```

## Linting

The docs skill requires documentation to be linted before delivery:

```bash
bash skills/docs/scripts/lint-docs.sh <file-or-directory>
```

The script runs markdownlint through `npx` and runs Vale when it is installed. Node.js is required for markdownlint. Vale is optional but recommended for prose checks.

## Skill format

Skills use minimal YAML frontmatter:

```yaml
---
name: docs
description: Create and improve technical documentation...
---
```

Do not add harness-specific fields, environment variables, manifests, tool permissions, or install instructions to skill source files.

## License

[MIT](LICENSE)
