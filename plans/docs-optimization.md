# Plan: Optimize All Docs for LLM Context

## Goal
Convert all `docs/` files from raw fetched content into structured, LLM-optimized reference documents. Apply prompt engineering best practices so an AI can efficiently look up any API function, conditional, event, or mechanic without parsing prose.

## Why
The current docs were bulk-fetched from upstream wikis/READMEs. They contain:
- Narrative prose mixed with technical specs
- Inconsistent formatting across files
- Redundant explanations
- Missing cross-references between related APIs
- No consistent lookup structure

## Design Principles
- **Consistent structure** — every doc uses the same section/table format
- **Facts over prose** — strip opinions, rationale, flavor text; keep only what an LLM needs to generate correct code
- **Lookup-friendly** — functions grouped by category, each with signature, params, returns, notes
- **Conditional annotations** — where applicable, show how API maps to CleveroidMacros syntax
- **Cross-references** — note when SuperWoW modifies a vanilla function, or when a CVar gates an event
- **No duplication** — if info exists in one doc, others reference it instead of repeating

## Files to Optimize

| File | Lines | Content | Optimization Notes |
|------|-------|---------|-------------------|
| `superwow-api.md` | ~353 | SuperWoW functions, events, CVars | Standardize function signatures, deduplicate with vanilla-api |
| `nampower-api.md` | ~433 | Nampower Lua functions | Largest API doc; ensure consistent param/return tables, add reusable-table warnings |
| `nampower-events.md` | ~344 | Nampower events | Standardize arg tables, group by CVar gate |
| `nampower-cvars.md` | ~97 | Nampower CVars | Already compact; verify defaults are listed |
| `unitxp-api.md` | ~500+ | UnitXP_SP3 functions | Very large; may need trimming of source-code-level detail |
| `cleveroid-syntax.md` | ~154 | CleveroidMacros syntax | Good structure; verify completeness |
| `cleveroid-conditionals.md` | ~472 | 100+ conditionals | Large but essential; ensure table consistency |
| `vanilla-api-essentials.md` | ~265 | Base 1.12 API | Mark which functions SuperWoW enhances |
| `patterns.md` | ~247 | Macro pattern templates | Replace guessed patterns with guide-sourced ones |
| `warrior-guide.md` | ~436 | Raw warrior guide | Keep as-is; create `warrior-rotations.md` as optimized derivative |

## New File
- `warrior-rotations.md` — LLM-optimized rotation/mechanics reference derived from `warrior-guide.md`

## Optimization Checklist Per File
- [ ] Consistent header hierarchy (# Title, ## Category, ### Function/Item)
- [ ] Function entries use: `name(params) -> returns` format
- [ ] Tables for multi-item lists (params, events, conditionals)
- [ ] No narrative prose — only technical facts
- [ ] Cross-references to related docs where applicable
- [ ] CVar/dependency gates clearly marked
- [ ] Macro-relevant usage examples where helpful (1-line, not essays)
- [ ] File stays under reasonable size (target: under 300 lines each where possible)

## Execution Order
1. Start with `warrior-rotations.md` (new file from warrior-guide.md) — establishes the optimization pattern
2. Optimize remaining docs in dependency order: superwow -> nampower (api, events, cvars) -> unitxp -> cleveroid (syntax, conditionals) -> vanilla-api -> patterns
3. Update CLAUDE.md if any quick-ref entries change due to optimization
4. Review all cross-references for consistency

## After Optimization
Proceed to `plans/test-macros.md` — create and test the 4 capability test macros.
