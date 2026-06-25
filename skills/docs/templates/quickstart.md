# Quickstart Guide

A quickstart is a tutorial that gets the reader to first success in under five minutes. It's the single most important document for adoption — if someone can't get your tool working quickly, they leave.

Diátaxis category: **Tutorial** (learning-oriented, practical).

## Structure

### Title

Use "Quickstart" or "Get started with [product name]". Don't be clever with the title.

### Prerequisites

List everything the reader needs before they begin. Be specific about versions.

**Good:**

- Node.js 18 or later
- A Stripe account with API keys ([sign up](https://...))

**Bad:**

- "Make sure you have the usual dev tools installed"

### Steps

Number every step. Each step should be one action with one observable result.

**Rules for steps:**

- **One action per step.** "Install the package and configure your API key" is two steps.
- **Show the expected result.** After a command, show what success looks like (output, status message, file created).
- **Use the imperative mood.** "Run the migration" not "You should run the migration."
- **Don't explain why** in the steps. If context is needed, add a brief note after the step or link to an explanation page.
- **Keep the happy path.** Don't branch into error handling or alternative approaches. Those belong in how-to guides or troubleshooting docs.

### Verify it works

The final step should produce a visible, satisfying result. "You should see your dashboard at `http://localhost:3000`" or "The API returns a charge object with `status: succeeded`."

### Next steps

Link to 2-3 logical follow-ups: a deeper tutorial, common how-to guides, or the configuration reference.

## Example skeleton

````markdown
# Get started with Acme SDK

Set up the Acme SDK and create your first widget in under five minutes.

## Prerequisites

- Python 3.10 or later
- An Acme API key ([get one here](https://...))

## Steps

### 1. Install the SDK

```bash
pip install acme-sdk
```

### 2. Configure your API key

```bash
export ACME_API_KEY="ak_test_..."
```

### 3. Create your first widget

```python
from acme import Client

client = Client()
widget = client.widgets.create(name="My Widget")
print(widget.id)
# => wgt_1a2b3c4d
```

### 4. Verify

Open https://dashboard.acme.com/widgets — your new widget appears in the list.

## Next steps

- [Configure widget properties](how-to/configure-widgets.md)
- [API reference: Widgets](reference/widgets.md)
````

## Common mistakes

- **Too many prerequisites** — if setup takes 10 minutes, the quickstart has failed. Consider providing a sandbox, Docker image, or hosted environment.
- **Branching paths** — "If you're on Linux, do X; if macOS, do Y; if Windows, do Z." Pick one primary path. Link to alternatives.
- **Explaining concepts mid-flow** — the reader wants to succeed, not learn. Teach later.
- **Outdated commands** — quickstarts break the fastest because they depend on exact versions and APIs. Test them regularly.
