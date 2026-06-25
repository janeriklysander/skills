# Tone and Voice

This guide defines the writing style for all documentation produced by this skill. The style is inspired by [Stripe's documentation](https://docs.stripe.com/) — warm, precise, task-oriented, and substantiated.

## Core Principles

**Sound like a knowledgeable colleague.** Not a textbook, not a chatbot. You're a senior engineer explaining something to a peer — friendly but substantive.

**Get to the point.** Lead with the answer or action. Front-load the most important information in every heading, paragraph, and sentence. Readers scan before they read.

**Substantiate everything.** Link to sources, reference specific files or functions, cite specifications. Don't hand-wave. If you can't substantiate a claim, reconsider whether it belongs.

**Show, don't just tell.** A code example or diagram is worth more than a paragraph of explanation. Use mermaid diagrams for visual concepts, runnable code for technical ones.

## Voice Rules

<!-- vale Google.Will = NO -->

| Do                                                                | Don't                                               |
| ----------------------------------------------------------------- | --------------------------------------------------- |
| Use **second person** ("you")                                     | Use "we" to mean the reader                         |
| Use **active voice** ("Run the script")                           | Use passive ("The script should be run")            |
| Use **present tense** ("Returns a list")                          | Use future ("Will return a list")                   |
| Use **imperative mood** for instructions ("Configure the server") | Use hedged phrasing ("You might want to configure") |
| Use **contractions** ("it's", "you'll", "don't")                  | Write overly formal prose ("it is", "you will")     |
| State things **positively** ("Save the file")                     | Use double negatives ("Don't forget to save")       |

<!-- vale Google.Will = YES -->

## Words and Phrases to Avoid

- **"Simple", "easy", "just", "straightforward"** — what feels easy to the author may not be easy to the reader. These words alienate anyone who is struggling.
- **"Obviously", "of course", "clearly"** — if it were obvious, you wouldn't need to document it.
- **"Please"** in instructions — unnecessary in technical docs. Just state the action.
- **"We"** to mean the reader — use "you". Reserve "we" for the authoring organization when strictly necessary.
- **Jargon without definition** — if a term isn't universally known by the target audience, define it on first use or link to a glossary.
- **"Click here"** — use descriptive link text ("See the [configuration reference](...)").
- **"Above" / "below"** — use "preceding" or "following". Spatial terms break across layouts and screen readers.

## Inclusive Language

- Use gender-neutral pronouns ("they/them") or role-based terms ("the developer", "the user")
- Avoid ableist language and disability metaphors
- Don't assume cultural context (holidays, sports, idioms)
- Use diverse names in examples

## Structure for Scannability

- **Headings summarize content** — "Configure authentication" not "About configuration"
- **One idea per paragraph** — if a paragraph covers two topics, split it
- **Lists for 3+ items** — don't bury a list in a paragraph
- **Tables for comparisons** — tables beat prose for structured data
- **Bold for key terms** — use sparingly for scannable emphasis
- **Short paragraphs** — aim for 1-4 sentences per paragraph
- **Front-load keywords** in headings and topic sentences

## Formatting Conventions

- Use **sentence case** for headings ("Configure the database" not "Configure the Database")
- Use the **Oxford comma** (a, b, and c)
- One space after periods
- Use `code formatting` for file paths, function names, command-line commands, and variable names
- Use **bold** for UI elements and key terms on first mention
- Use > blockquotes for callouts and important notes

## Progressive Disclosure

Present information in layers:

1. **Lead with the essential path** — the simplest way to accomplish the goal
2. **Reveal complexity on demand** — use collapsible sections, linked pages, or "for advanced usage" subsections
3. **Don't front-load caveats** — state the action first, then mention edge cases

This mirrors Stripe's approach: show a three-line cURL example first, then reveal SDKs, error handling, and advanced options.
