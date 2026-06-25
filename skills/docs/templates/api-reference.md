# API Reference Guide

API reference documentation describes every endpoint, method, parameter, and return value. It must be complete, accurate, and consistently formatted. The reader comes here to look up a specific fact, not to learn.

Diátaxis category: **Reference** (working, theoretical).

## Principles

**Accuracy over everything.** A wrong reference doc is worse than no reference doc. Verify every parameter name, type, default value, and constraint against the actual implementation.

**Consistency is structure.** Every entry should follow the same format. The reader should know exactly where to look for the information they need without reading prose.

**Austere.** No tutorials, no opinions, no "why you might want to use this." Describe what exists. Link to how-to guides and explanations for context.

**Auto-generate where possible.** If you can generate reference docs from source (OpenAPI specs, docstrings, type definitions), do it. Hand-written reference docs drift from reality.

## Structure for REST APIs

### Endpoint entry

Each endpoint gets its own section or page with these subsections:

#### Title and method

```markdown
## Create a charge

`POST /v1/charges`
```

#### Description

One to two sentences explaining what this endpoint does. No tutorials.

#### Parameters

Use a table. Include every parameter — required and optional.

| Parameter     | Type    | Required | Description                                           |
| ------------- | ------- | -------- | ----------------------------------------------------- |
| `amount`      | integer | yes      | Amount in smallest currency unit (for example, cents) |
| `currency`    | string  | yes      | Three-letter ISO currency code                        |
| `description` | string  | no       | Arbitrary text attached to the charge                 |
| `metadata`    | object  | no       | Key-value pairs for your use                          |

#### Request example

Use cURL for request examples in templates. When writing real documentation, use the repo's language instead.

```bash
curl https://api.example.com/v1/charges \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000, "currency": "usd", "description": "Test charge"}'
```

#### Response example

Show the full response object with realistic data.

```json
{
  "id": "ch_1a2b3c4d",
  "amount": 1000,
  "currency": "usd",
  "status": "succeeded",
  "created": 1679012345
}
```

#### Error responses

List the errors specific to this endpoint.

| Status | Code                   | Description                                                |
| ------ | ---------------------- | ---------------------------------------------------------- |
| 400    | `invalid_amount`       | Amount must be a positive integer                          |
| 402    | `card_declined`        | The card was declined                                      |
| 409    | `idempotency_conflict` | A request with this idempotency key is already in progress |

## Structure for libraries/SDKs

### Class or module entry

#### Signature

Show the full constructor or function signature with types.

#### Parameters

Same table format as REST APIs.

#### Methods

Each method follows the same pattern: signature, description, parameters, return type, example.

#### Return types

Document the shape of returned objects. Use the response example format from REST APIs.

## Cross-cutting concerns

### Authentication

Document auth once in a dedicated section. Don't repeat it in every endpoint.

### Pagination

If the API uses pagination, document the pattern once and link to it from list endpoints.

### Rate limiting

Document rate limits, headers, and retry guidance in a dedicated section.

### Errors

Document the global error format once. Only document endpoint-specific errors on the endpoint page.

## Keeping reference docs current

- **Generate from source** when your tooling supports it (OpenAPI, TypeDoc, Sphinx autodoc)
- **Test examples in CI** — treat code snippets as production code
- **Version your docs** — readers on v2 shouldn't see v3 parameters
- **Flag deprecated fields** — mark them clearly, state what replaces them, include a removal timeline
