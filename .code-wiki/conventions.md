---
title: wiki conventions
last-updated: 2026-07-08
---

# wiki conventions

## file format

Every topic file starts with YAML frontmatter:

- `topic` - kebab-case name, matches filename without extension
- `status` - `draft` or `verified`
- `last-verified` - date (`yyyy-mm-dd`) when last checked against code
- `confidence_score` - float `0.0-1.0` indicating confidence in the topic's accuracy
- `priority` - `core` or `extended`
- `rank` - integer `1-10` within the priority tier
- `tokens` - approximate token count of file body
- `code-paths` - list of repo-relative paths the topic covers
- `related-topics` - list of other topic names

Body sections, in order:

- `overview`
- `current behavior`
- `decisions`
- `gotchas`
- `references`

No flowing paragraphs that repeat what structured data already shows.

## size rules

- Hard cap: ~500 lines per topic file.
- Over cap: split into two topics.
- Under ~30 lines: belongs as a section in an existing topic.

## re-verify trigger

A topic is stale when any of these are true:

1. A task modifies `addons/main/functions/**` overlapping the topic's code-paths.
2. A task modifies `addons/main/config.cpp`, `addons/main/CfgFunctions.hpp`, or `addons/main/CfgVehicles.hpp` overlapping the topic's code-paths.
3. A task marked `[REFACTOR]` touches the topic's code-paths.
4. A manual audit or `wiki-lint --fix` asks for re-verification.

## new topic creation

Default: update an existing topic.

New topic is justified when:

- The code introduces a genuinely new subsystem.
- A cross-cutting concern emerges repeatedly.
- Consolidation reveals one topic was really two.

New topics require human approval.

## backlink audit

When a new topic is created or renamed:

1. Scan existing topics for mentions of the new or changed topic name.
2. Add `related-topics` entries in both directions.
3. Keep cross-references bidirectional and discoverable.

## not in scope

- Session notes -> change-logs/
- Unimplemented plans -> change-logs/
- Things code already makes obvious -> nothing
- Dated files (`yyyymmdd-*.md`) -> never in wiki

## wiki updates

When an agent updates a topic file:

1. Show the diff before writing.
2. Append the diff or summary to `log.md`.
3. Bump `last-verified` and update `tokens`.

## source of truth

When the wiki and the code disagree, code wins. Wiki gets updated to match, never the other way around.
