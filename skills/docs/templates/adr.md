# Architecture Decision Record (ADR)

An ADR captures a significant architectural decision — the context, the choice made, and the consequences. Its purpose is to help future readers (including future you) understand *why* the system looks the way it does.

## When to write an ADR

Write one when a decision:

- Is hard to reverse (technology choice, data model, protocol)
- Affects multiple teams or components
- Was debated and had viable alternatives
- Would surprise someone reading the code in six months

Don't write one for routine choices that follow established patterns.

## Sections

### Title (essential)

Short, descriptive, numbered. Use the format `ADR-NNNN: Decision subject`.

**Good:** `ADR-0012: Use PostgreSQL for event storage`
**Bad:** `ADR-0012: Database decision`

### Status (essential)

One of: **Proposed**, **Accepted**, **Deprecated**, **Superseded by ADR-NNNN**.

Include the date the status last changed.

### Context (essential)

Describe the situation that led to this decision. What problem are you facing? What constraints exist? What forces are in tension?

Be specific. Name the systems, teams, and requirements involved. A reader should understand the problem fully before reaching the decision.

### Decision (essential)

State the decision clearly in one or two sentences, then elaborate if needed.

**Good:** "We use PostgreSQL as the primary store for domain events, with a JSONB column for event payloads."

**Bad:** "After careful consideration of various options, we decided to go with a relational database approach."

### Consequences (essential)

What changes as a result of this decision? Include both positive and negative consequences. Be honest about trade-offs.

Structure as:

- **Benefits** — what this decision enables or improves
- **Costs** — what becomes harder, more complex, or constrained
- **Risks** — what could go wrong and how you'd detect it

### Alternatives considered (recommended)

List the options you evaluated and why you rejected them. This is one of the most valuable sections — it prevents future teams from re-evaluating the same options.

For each alternative, briefly state:

- What the option was
- Its main advantage
- Why it was rejected

### References (if applicable)

Link to relevant RFCs, design docs, benchmarks, or external resources that informed the decision.

## Example skeleton

```markdown
# ADR-0012: Use PostgreSQL for event storage

**Status:** Accepted (2026-03-15)

## Context

The order service emits ~50 domain events per second that downstream services
consume for projections and notifications. We need a durable event store that
supports ordered retrieval by aggregate ID and global sequence number.

Current volume is manageable, but projected growth reaches 500 events/sec
within 12 months. The team has deep PostgreSQL expertise but limited
experience with dedicated event stores.

## Decision

Use PostgreSQL as the primary event store with a JSONB payload column and a
bigserial global sequence number.

## Consequences

**Benefits:**
- Leverages existing PostgreSQL infrastructure and team expertise
- JSONB provides schema flexibility for evolving event payloads
- Transactional guarantees simplify command-side consistency

**Costs:**
- Requires manual partitioning strategy as volume grows
- No built-in subscription mechanism — polling or LISTEN/NOTIFY needed

**Risks:**
- Write throughput may bottleneck at projected 500 evt/sec on a single node.
  Mitigation: benchmark at 2x projected load before committing.

## Alternatives considered

**EventStoreDB:** Purpose-built for event sourcing with built-in projections
and subscriptions. Rejected because the team lacks operational experience and
the current scale doesn't justify the infrastructure overhead.

**Apache Kafka:** Strong at high-throughput streaming but adds operational
complexity. Ordered retrieval by aggregate ID requires careful partitioning.
Rejected as premature for current scale.
```

## File naming and location

Default location: `docs/adr/` in the repo root. Name files as `NNNN-short-description.md` (for example, `0012-postgresql-event-storage.md`).

Keep an index file (`docs/adr/README.md`) that lists all ADRs with their status and a one-line summary.
