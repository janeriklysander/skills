# How-to Guide

A how-to guide helps a competent user solve a specific problem. It's not a tutorial (no teaching) and not a reference (not exhaustive). It's a recipe.

Diátaxis category: **How-to** (working, practical).

## Structure

### Title

Start with "How to" followed by the task: "How to configure SSO", "How to migrate from v2 to v3". The title should match what the reader would search for.

### Introduction (1-2 sentences)

State the goal and any important context. Don't over-explain — the reader already knows what they want to do.

**Good:** "Configure SAML-based SSO so your team can sign in with your identity provider."

**Bad:** "Single Sign-On (SSO) is an authentication method that allows users to access multiple applications with one set of credentials. In this guide, we'll walk through the process of setting up SAML-based SSO..."

### Prerequisites (if any)

Brief list. Only include what's specific to this task, not general project setup.

### Steps

Numbered, sequential actions. Each step achieves one thing.

**Rules:**

- **Assume competence.** Don't explain what a config file is or how to open a terminal.
- **Be specific.** "Add the following to `config/auth.yml`" not "Update your configuration."
- **Show flexibility.** Where there are valid alternatives (different providers, flag options), mention them briefly or link out.
- **Include verification.** After a meaningful group of steps, show how to confirm it worked.

### Troubleshooting (optional)

If there are common failure modes for this specific task, list them with symptoms and fixes. Keep it short — 2-3 entries max. For broader troubleshooting, link to a dedicated troubleshooting page.

## Principles

**Goal-oriented, not feature-oriented.** The guide is organized around what the reader wants to achieve, not around your product's feature taxonomy.

**Flexible, not rigid.** Unlike a tutorial (which has one path), a how-to guide can acknowledge that different situations may call for different approaches.

**No teaching.** If understanding a concept is necessary, link to an explanation page. Don't embed a lesson in the middle of a procedure.

**Concise.** A good how-to guide is as short as possible while still getting the reader to their goal. If you find yourself writing more than a page of steps, consider whether the task is actually multiple tasks.

## Example skeleton

````markdown
# How to add webhook retries

Configure automatic retries for failed webhook deliveries so your integration handles transient errors gracefully.

## Prerequisites

- Webhooks enabled on your account
- Admin role or higher

## Steps

### 1. Open webhook settings

Navigate to **Settings > Webhooks** and select the endpoint you want to configure.

### 2. Enable retries

Add the retry configuration to your webhook endpoint:

```python
client.webhooks.update(
    endpoint_id="we_1a2b3c",
    retry_policy={
        "max_attempts": 5,
        "backoff": "exponential",
    },
)
```

### 3. Verify retry behavior

Trigger a test event and check the delivery log:

```python
deliveries = client.webhooks.list_deliveries(endpoint_id="we_1a2b3c")
print(deliveries[0].attempts)
# => 1
```

## Troubleshooting

**Retries not firing:** Check that your endpoint returns a 5xx status on failure. 4xx responses are treated as permanent failures and are not retried.
````
