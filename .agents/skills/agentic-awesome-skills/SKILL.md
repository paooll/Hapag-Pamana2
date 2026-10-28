---
name: agentic-awesome-skills
description: Agentic Awesome Skills — a curated registry/index of many installable agent skills (security, design, testing, agent-tooling, marketing, workflow, and more) with per-skill metadata (name, description, category, risk, source, plugin setup). Use when you want to discover or compare skills for a task before installing one, or when you want a broad map of what skills exist across the ecosystem.
source: https://github.com/sickn33/agentic-awesome-skills.git
upstream_name: agentic-awesome-skills
note: Installed as "agentic-awesome-skills" (your .md filename); upstream is a skills REGISTRY/INDEX (data/skills_index.json), not a single SKILL.md. This installed skill is a focused description of the registry. Do NOT inline the entire registry here.
---

# Agentic Awesome Skills

Agentic Awesome Skills is a curated registry of agent skills — a searchable index of many skills with metadata, descriptions, categories, risk levels, sources, and plugin setup info. It is a discovery/reference layer, not a single workflow skill.

## What it is

- A registry/index of skills across many categories: security, design, testing, agent-tooling, marketing, workflow, ai-ml, business, legal, and more.
- Each entry carries: id, name, description, category, risk, source, plugin targets (e.g. claude/codex supported or blocked), setup type, and tags.
- It is the kind of thing you query when you want to answer "is there a skill for X?" or "compare the available skills for this task" before picking one to install.

## How to use it

- When the user asks whether a skill exists for a task, or asks you to find/compare skills for a task, treat this as a discovery request: scan the registry for matching entries by name/description/tags/category, present the closest matches with their risk and source, and let the user choose.
- Do not auto-install a skill from the registry without the user's go-ahead.
- Respect risk levels: "critical" and "offensive" entries need explicit user awareness before use; "safe" and "none" are lower-friction.
- This registry is a pointer to skills; the actual skill instructions live in each skill's own SKILL.md once installed.

## Scope note

This installed skill is a description of the registry itself. It is NOT the full registry contents — the upstream repo ships the index as structured data (e.g. `data/skills_index.json` / `data/aas-v1/skill-content.v1.ndjson`) that is too large to inline. When you need the actual entry list, read the upstream index file rather than this summary.

## Source

Repository: https://github.com/sickn33/agentic-awesome-skills
