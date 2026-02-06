# Plan: Optimize All Docs for LLM Context

## Context

The `docs/` files were bulk-fetched from upstream wikis/READMEs. They contain narrative prose, inconsistent formatting, redundant explanations, and no cross-references. This optimization converts them into structured, LLM-optimized reference documents so an AI can efficiently look up any API function, conditional, event, or mechanic.

## Standard Format

Every doc will follow this template:

```markdown
# Title

> Source: [URL] | Version: X | Updated: YYYY-MM-DD

[1-2 sentence purpose]

---

## Category

### FunctionName(param1 [, param2]) -> returnType

1-line description.

| Param | Type | Description |
|-------|------|-------------|
| param1 | type | desc |

**Returns:** description
**See also:** `other-doc.md#section`
```

Rules: facts over prose, no opinions/flavor, cross-refs bidirectional, no duplication.

---

## Execution Steps

### Step 1: Create `docs/warrior-rotations.md` (NEW)

**Source:** Extract mechanical data from `docs/warrior-guide.md` (untouched)
**Target:** ~150-200 lines

**Extract:**
- Fury DW: single-target & multi-target priority lists, BT vs Execute formula (AP>2000 breakpoint)
- Fury 2H: slam timing, weapon speed thresholds (3.7-3.8)
- Arms: rotation sequences (Sunder->Slam->MS->Slam->WW->Slam), execute pooling (120 rage)
- Furyprot: priority system (Sunder->BT->HS->Revenge), threat modifiers
- Defensive Tactics Prot: 3 stance rotations
- Cooldown guidelines: Death Wish timing, Bloodrage-Enrage interaction, Berserker Rage for rage gen
- Mechanical rules: never clip BT with WW, HS prevents miss/glance, Sweeping Strikes pre-pull timing
- Demo Shout bug: never apply before Curse of Recklessness

**Strip:** All opinions, gear discussion, consume recommendations, author attributions, ALL CAPS rants, humor, guild context, patch history.

**Format:** Numbered priority tables per spec/scenario with conditions. Cross-ref to `patterns.md#1` and `cleveroid-conditionals.md`.

---

### Step 2: Optimize `docs/unitxp-api.md` (753 -> ~300 lines)

**Biggest trim.** Remove 9 non-macro sections entirely:

| Remove | Why |
|--------|-----|
| Camera Control | Addon config, not macro API |
| Nameplate Control | Visual config |
| FPS Cap | Performance setting |
| Floating Combat Text | Visual config |
| Weather | Cosmetic |
| Screenshot | Utility |
| Hide EXP Text | Cosmetic |
| Performance Profile | Debug tool |
| Lua Debugger | Dev tool |

**Keep & enhance:**
- Version Detection (condense to ~15 lines)
- Line of Sight -- add cross-ref to `[insight]` conditional
- Distance (all 5 meter types) -- add cross-ref to `[distance]` conditional
- Behind -- add cross-ref to `[behind]` conditional
- Targeting (all 8 functions) -- add cross-ref to `/target` commands
- Timer -- keep for advanced macros
- OS Notifications -- brief mention

**Add:** Brief appendix listing removed functions with link to full upstream wiki.

---

### Step 3: Optimize `docs/superwow-api.md` (353 -> ~360 lines)

- Add TOC after header
- Convert "Behavior Changes" narrative into table format
- Add cross-refs: `CastSpellByName` -> `nampower-api.md#QueueSpellByName`, `UnitExists` -> `vanilla-api-essentials.md`, `UNIT_CASTEVENT` -> `nampower-events.md#SPELL_START_SELF`
- Mark every modified function with `(vanilla: [original behavior])`

---

### Step 4: Optimize Nampower trilogy

**`nampower-api.md` (433 -> ~440 lines):**
- Strengthen reusable-table warning (move to top, add `(reusable table)` tag to affected functions)
- Add cross-refs: `QueueSpellByName` -> `nampower-cvars.md#spell-queuing`, `GetCastInfo` -> `nampower-events.md#SPELL_CAST_EVENT`, `GetSpellIdCooldown` -> `cleveroid-conditionals.md#cooldown`

**`nampower-events.md` (344 -> ~360 lines):**
- Add CVar gate annotation to every gated event: `**Requires:** NP_EnableX=1` with link to `nampower-cvars.md`
- Add "how to enable" code snippet (SetCVar + config.wtf)
- Cross-ref: `SPELL_START_SELF` -> `superwow-api.md#UNIT_CASTEVENT`

**`nampower-cvars.md` (97 -> ~120 lines):**
- Add "how to set" example block (config.wtf persistent, /run session-only, read value)
- Add event cross-refs for all 6 toggle CVars -> `nampower-events.md`
- Note which events are always-active (no CVar required)

---

### Step 5: Optimize `docs/cleveroid-syntax.md` (154 -> ~160 lines)

- Add link to `cleveroid-conditionals.md` for full conditional reference
- Convert "Known Issues" to table format
- Cross-refs: `/cast` -> conditionals doc, `[multiscan]` -> `unitxp-api.md#targeting`, `{MacroName}` -> `patterns.md`

---

### Step 6: Optimize `docs/cleveroid-conditionals.md` (472 -> ~450 lines)

- Strip narrative prose from addon integration sections (Cursive, pfUI Tank, MonkeySpeed) -- keep tables, remove intro paragraphs
- Add "Powered by" cross-refs: `[cooldown]` -> `nampower-api.md#GetSpellIdCooldown`, `[distance]` -> `unitxp-api.md#distance`, `[behind]` -> `unitxp-api.md#behind`, `[insight]` -> `unitxp-api.md#line-of-sight`
- Add addon requirement notes: `[swingtimer]` needs SP_SwingTimer, `[threat]` needs TWThreat, `[cursive]` needs Cursive, `[moving]` (speed) needs MonkeySpeed
- Eliminate any duplicated content between sections

---

### Step 7: Optimize `docs/vanilla-api-essentials.md` (265 -> ~270 lines)

- Systematize SuperWoW enhancement markers: every enhanced function gets `**SuperWoW:** [change] -> See superwow-api.md#section`
- Functions to mark: UnitMana, UnitExists, UnitBuff, UnitDebuff, CastSpellByName, SetRaidTarget, GetContainerItemInfo, GetWeaponEnchantInfo
- Convert events list (bottom of file) to table with args column
- Add note: "Nampower adds 30+ custom events. See `nampower-events.md`."

---

### Step 8: Optimize `docs/patterns.md` (247 -> ~270 lines)

- Add "Requirements" block to each pattern listing required addons/DLLs
- All conditionals verified correct against `cleveroid-conditionals.md` (hplost, myrawpower, nocursive, inrange all valid)
- Add cross-refs per pattern to relevant API docs
- Add "Common Mistakes" appendix (reactive needs action bar, behind needs UnitXP, cursive needs addon, /nofirstaction to close block)

---

### Step 9: Cross-reference review & CLAUDE.md update

- Verify all cross-refs are bidirectional (if A links to B, B links back to A)
- Update CLAUDE.md Project Structure section if warrior-rotations.md is added
- Verify CLAUDE.md quick-reference tables still match optimized docs

---

## Files Modified

| # | File | Action | Before | After |
|---|------|--------|--------|-------|
| 1 | `docs/warrior-rotations.md` | CREATE | 0 | ~180 |
| 2 | `docs/unitxp-api.md` | TRIM | 753 | ~300 |
| 3 | `docs/superwow-api.md` | ENHANCE | 353 | ~360 |
| 4 | `docs/nampower-api.md` | ENHANCE | 433 | ~440 |
| 5 | `docs/nampower-events.md` | ENHANCE | 344 | ~360 |
| 6 | `docs/nampower-cvars.md` | ENHANCE | 97 | ~120 |
| 7 | `docs/cleveroid-syntax.md` | POLISH | 154 | ~160 |
| 8 | `docs/cleveroid-conditionals.md` | TRIM+ENHANCE | 472 | ~450 |
| 9 | `docs/vanilla-api-essentials.md` | ENHANCE | 265 | ~270 |
| 10 | `docs/patterns.md` | ENHANCE | 247 | ~270 |
| 11 | `CLAUDE.md` | UPDATE | - | - |
| | **Total** | | **3118** | **~2910** |

## Verification

After each file:
- Confirm no prose/opinions remain (facts only)
- Confirm cross-refs point to valid sections
- Confirm function signatures match `name(params) -> returns` format

After all files:
- Grep for orphaned cross-refs (links to sections that don't exist)
- Verify CLAUDE.md quick-reference still matches optimized content
- No in-game testing needed (docs only, no macro code changes)
