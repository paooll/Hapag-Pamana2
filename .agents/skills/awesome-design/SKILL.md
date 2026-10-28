---
name: awesome-design
description: Curated collection of DESIGN.md design-system documents extracted from real developer-focused websites. Use when you want to copy a real site's design language into your project so an AI agent can generate UI that stays visually consistent with that look and feel. Each DESIGN.md is a plain-text design system (palette, type, components, layout, guardrails) that agents and Google Stitch read directly.
source: https://github.com/VoltAgent/awesome-design-md.git
upstream_name: awesome-design-md
note: This repo is a curated collection of DESIGN.md files (no single SKILL.md). Installed skill is built from the repo README; the real artifacts are the individual DESIGN.md files in the upstream design-md/ folder.
---

# Awesome DESIGN.md

Curated collection of DESIGN.md analysis by developer-focused websites.

Copy a DESIGN.md into your project, tell your AI agent "build me a page that looks like this," and generate high-quality UI that stays visually consistent with the design language.

Built with real design depth — including analyzed patterns, tokens, and rules — for high-quality UI generation, not surface-level outputs.

## What is DESIGN.md?

[DESIGN.md](https://stitch.withgoogle.com/docs/design-md/overview/) is a new concept introduced by Google Stitch. A plain-text design system document that AI agents read to generate consistent UI.

It's just a markdown file. No Figma exports, no JSON schemas, no special tooling. Drop it into your project root and any AI coding agent or Google Stitch instantly understands how your UI should look. Markdown is the format LLMs read best, so there's nothing to parse or configure.

| File | Who reads it | What it defines |
|------|-------------|-----------------|
| `AGENTS.md` | Coding agents | How to build the project |
| `DESIGN.md` | Design agents | How the project should look and feel |

**This repo provides ready-to-use DESIGN.md files** extracted from real websites.

## How to Use

1. Copy a site's `DESIGN.md` into your project root.
2. Tell your AI agent to use it.

Each DESIGN.md follows the [Stitch DESIGN.md format](https://stitch.withgoogle.com/docs/design-md/specification/) with extended sections:

| # | Section | What it captures |
|---|---------|-----------------|
| 1 | Visual Theme & Atmosphere | Mood, density, design philosophy |
| 2 | Color Palette & Roles | Semantic name + hex + functional role |
| 3 | Typography Rules | Font families, full hierarchy table |
| 4 | Component Stylings | Buttons, cards, inputs, navigation with states |
| 5 | Layout Principles | Spacing scale, grid, whitespace philosophy |
| 6 | Depth & Elevation | Shadow system, surface hierarchy |
| 7 | Do's and Don'ts | Design guardrails and anti-patterns |
| 8 | Responsive Behavior | Breakpoints, touch targets, collapsing strategy |
| 9 | Agent Prompt Guide | Quick color reference, ready-to-use prompts |

Each site entry includes:
- `DESIGN.md` — the design system (what agents read)
- `preview.html` — visual catalog showing color swatches, type scale, buttons, cards
- `preview-dark.html` — same catalog with dark surfaces

## Collection highlights (by category)

### AI & LLM Platforms
Claude, Cohere, ElevenLabs, Jobright, Minimax, Mistral AI, Ollama, OpenCode AI, Replicate, Runway, Together AI, VoltAgent, xAI

### Developer Tools & IDEs
Cursor, Expo, Lovable, Raycast, Superhuman, Vercel, Warp

### Backend, Database & DevOps
ClickHouse, Composio, HashiCorp, MongoDB, Oracle, PostHog, Sanity, Sentry, Supabase

### Productivity & SaaS
Cal.com, Intercom, Linear, Mintlify, Notion, Resend, SAP, Zapier

### Design & Creative Tools
Airtable, Clay, Figma, Framer, Miro, Webflow

### Fintech & Crypto
Binance, Coinbase, Kraken, Mastercard, Mercury, NerdWallet, Revolut, Stripe, Wise

### E-commerce & Retail
Airbnb, Meta, mydealz, Nike, Shopify, Starbucks

### Media & Consumer Tech
1win, Al Jazeera, Apple, DJI, HP, IBM, NVIDIA, Oura, Pinterest, PlayStation, SpaceX, Spotify, The Verge, Uber, Vodafone, WIRED

### Automotive
BMW, BMW M, Bugatti, Ferrari, Lamborghini, Renault, Tesla

### Retro Web · DESIGN.md Nostalgia
Dell (1996), Nintendo.com (2001)

## When to use this skill

- You want a new page/UI to look like a specific real site whose DESIGN.md is in this collection.
- You are starting a design system and want a concrete, real-world reference rather than inventing tokens from scratch.
- You want to give an AI agent a clear, written design brief (palette, type, components, guardrails) instead of vague adjectives.

## Source

See the upstream repo for the full list of DESIGN.md files and the latest additions: https://github.com/VoltAgent/awesome-design-md
