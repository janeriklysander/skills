# Linting Documentation

Every document produced by this skill must be linted before delivery. The linting script at [lint-docs.sh](../scripts/lint-docs.sh) handles this automatically.

## Running the linter

```bash
bash skills/docs/scripts/lint-docs.sh <file-or-directory>
```

The script runs two linters in sequence and reports results for each.

## markdownlint (always runs)

**Requirement:** Node.js and npm available in the environment.

markdownlint enforces structural Markdown quality — heading hierarchy, list formatting, code block syntax, whitespace. The config is bundled at [.markdownlint-cli2.yaml](../scripts/.markdownlint-cli2.yaml).

The script runs markdownlint via `npx` so no global installation is needed. On first run it downloads `markdownlint-cli2` automatically.

### Key rules enforced

- ATX-style headings (`#`) that increment by one level
- Dash-style unordered lists (`-`) with 2-space indentation
- Fenced code blocks with a language specified
- No trailing whitespace, no hard tabs
- No bare URLs — always use `[text](url)` format
- Files end with a single newline

## Vale (optional, recommended)

Vale checks prose quality — passive voice, weasel words, jargon, inclusive language. It uses the Google developer docs style and write-good as baselines, tuned via [.vale.ini](../scripts/.vale.ini).

### Setup instructions

If Vale is not installed, the lint script skips it and prints a notice. To enable Vale:

1. **Install Vale:**

   ```bash
   # macOS
   brew install vale

   # Linux (snap)
   sudo snap install vale

   # Linux (binary)
   # Download from https://github.com/errata-ai/vale/releases
   ```

2. **Download style packages:**

   ```bash
   cd skills/docs/scripts
   vale sync
   ```

   This reads `.vale.ini` and downloads the Google and write-good style packages into `.vale/styles/`.

3. **Verify:**

   ```bash
   bash skills/docs/scripts/lint-docs.sh docs/some-file.md
   ```

   You should see output from both markdownlint and Vale.

### What Vale catches

- Passive voice ("was created" → "created")
- Weasel words ("very", "extremely", "quite")
- Jargon and readability issues
- Google style guide violations (capitalization, word choice, formatting)
- Inclusive language suggestions

## Agent Workflow

When running the linting step:

1. Run `lint-docs.sh` on the written document
2. If markdownlint reports issues → fix them automatically
3. If Vale reports issues → fix them automatically
4. If Vale is not installed → inform the user and offer to walk them through setup
5. Re-run after fixes to confirm a clean pass
6. Only present the document to the user after all available linters pass
