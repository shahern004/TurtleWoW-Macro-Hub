# TurtleWoW Macros Project

## Golden Directive
**ALWAYS ask the user to provide missing information before filling knowledge gaps with assumptions or searching the internet.**
- Do not guess API signatures, function behaviors, addon capabilities, or server-specific features
- If documentation is unclear or missing, ask the user first
- Verify against Turtle WoW docs — vanilla 1.12 API behavior often differs here

## Development Workflow

1. **Clarify** — understand the spec, desired behavior, and which rotation (`/idps`, `/icleave`, `/itank`, `/ihodor`). Ask if anything is ambiguous
2. **Read docs** — use the **Task Routing** table to pick which `docs/` files to read. Always read before using any custom API function
3. **Read code** — read the relevant IWinEnhanced files (`rotation.lua`, `action.lua`, etc.) before editing. Understand existing patterns
4. **Write** — edit `warrior/action.lua` (new/modified ability functions) and `warrior/rotation.lua` (priority chain ordering). Respect the patterns in **IWinEnhanced Editing Patterns**
5. **Deploy & test** — deploy to live folder, user does `/reload` and tests in-game. Do NOT commit or push until the user explicitly confirms it passed
6. **Iterate or commit** — if the test fails, fix and re-deploy. If it passes, commit only when the user asks

## Deploy & Test

```bash
# Deploy dev copy to live addon folder
cp -r addons/IWinEnhanced/* C:/Games/TurtleWoW/Interface/AddOns/IWinEnhanced/
# Then /reload in-game to pick up changes
```

**Slash commands:** `/idps` (single-target DPS), `/icleave` (AoE DPS), `/itank` (tanking), `/ihodor` (offtank/DT prot). Config via `/iwin`.

## Project Structure
```
addons/IWinEnhanced/      # IWinEnhanced dev copy (edit here, deploy to live)
  warrior/rotation.lua    # Rotation priority chains (/idps, /icleave, /itank, /ihodor)
  warrior/action.lua      # Ability function implementations (self-gating, rage checks)
  warrior/setup.lua       # Config system (/iwin slash command)
  warrior/data.lua        # Rage cost table
  warrior/condition.lua   # Condition checks (stance, buff, debuff, range)
  warrior/event.lua       # Event handlers (combat log, swing timer)
  warrior/init.lua        # Warrior module initialization
docs/                     # API reference (read on-demand per task routing table)
  plans/                  # Design docs for implemented features
  superwow-api.md         # SuperWoW DLL functions, events, CVars
  nampower-api.md         # Nampower Lua functions (30+)
  nampower-events.md      # Nampower custom events (30+)
  nampower-cvars.md       # Nampower CVar configuration
  unitxp-api.md           # UnitXP_SP3 functions (distance, LoS, targeting)
  doiteauras-api.md       # DoiteAuras addon API (buff cap tracking, aura durations)
  vanilla-api-essentials.md  # Curated vanilla 1.12 Lua API
  warrior-rotations.md    # Warrior rotation priorities & mechanics
  warrior-guide.md        # Full warrior guide (opinions, gear, consumes)
  iwin-code-review-rules.md  # 17 rule categories for IWinEnhanced code review
  _VERSIONS.md            # Dependency version tracking
.claude/skills/           # Claude Code skills (iwin-analyzer, etc.)
plans/                    # Implementation plans and research notes
```

## Which Docs to Read (Task Routing)

| Task | Read These Docs |
|------|----------------|
| **Editing rotation priorities** | `warrior-rotations.md` (expected priorities & mechanics) + read `warrior/rotation.lua` |
| **Adding/modifying ability functions** | `warrior-rotations.md` + read `warrior/action.lua` (existing patterns) |
| **Using distance, LoS, or behind checks** | `unitxp-api.md` (5 meter types, LoS caching, targeting) |
| **Querying DBC data (spell/item/unit info)** | `nampower-api.md` (GetSpellRec, GetItemStats, GetUnitData -- mind reusable tables!) |
| **Listening for combat events** | `nampower-events.md` (30+ events) + `nampower-cvars.md` (CVar gates) |
| **Using vanilla or SuperWoW Lua API** | `vanilla-api-essentials.md` (base API) + `superwow-api.md` (enhanced functions) |
| **Spell queuing behavior** | `nampower-api.md#spell-casting-and-queuing` + `nampower-cvars.md#spell-queuing-controls` |
| **Checking buffs beyond buff cap** | `doiteauras-api.md` (DoitePlayerAuras: HasBuff, GetBuffStacks, IsHiddenByBuffCap) |
| **Querying aura duration/ownership** | `doiteauras-api.md` (DoiteTrack: GetAuraRemainingSecondsByName, GetAuraOwnershipByName) |
| **IWinEnhanced code review** | `iwin-code-review-rules.md` (17 rule categories) + `warrior-rotations.md` (expected priorities) |

## Dependency Stack
| Source | Doc File(s) | Purpose |
|--------|------------|---------|
| **IWinEnhanced** (addon) | `addons/IWinEnhanced/warrior/` | Rotation automation: `/idps`, `/icleave`, `/itank`, `/ihodor` with queueGCD mutex, rage reservation, slam timing. Dev copy in repo, deploy to live with `cp -r` |
| **SuperWoW** (DLL) | `superwow-api.md` | Enhanced Lua API: GUID via UnitExists, aura IDs via UnitBuff/UnitDebuff, file I/O, UNIT_CASTEVENT, mark1-8 units, CastSpellByName with unit arg |
| **Nampower** (DLL) | `nampower-api.md`, `nampower-events.md`, `nampower-cvars.md` | Spell queuing, DBC data (GetSpellRec, GetItemStats, GetUnitData), cast/cooldown info, 30+ custom events |
| **UnitXP_SP3** (DLL) | `unitxp-api.md` | Distance (5 meter types), line-of-sight, behind check, advanced targeting, timers |
| **DoiteAuras** (addon) | `doiteauras-api.md` | Buff cap tracking (DoitePlayerAuras), aura duration/ownership queries (DoiteTrack). Optional dependency — nil-check globals |
| **Vanilla 1.12 API** | `vanilla-api-essentials.md` | Base WoW API (many functions enhanced by SuperWoW) |

**For API functions, events, and signatures** — read the relevant doc file per the Task Routing table above. Do not rely on memorized signatures.

## IWinEnhanced Editing Patterns
When editing `warrior/action.lua` or `warrior/rotation.lua`, respect these patterns:
- **queueGCD mutex** — Every ability function must early-return if `queueGCD` is set. Only one cast per keypress cycle
- **Self-gating** — Each function checks its own conditions (stance, rage, cooldown, debuff stacks) and returns silently if not met. Callers never pre-check
- **CastSpellByName (not Queue)** — IWinEnhanced uses `CastSpellByName()`, not `QueueSpellByName()`. Queuing is handled by the framework
- **CD pre-queue** — Check `cooldownRemaining < 1500` (ms) to cast abilities coming off CD within the next GCD
- **Rage reservation** — Call `SetReservedRage(cost, timeUntilNeeded)` for high-priority abilities. Time-aware: `rageCost - ragePerSec * time`
- **Debuff stacks** — Use `IWin.libdebuff:UnitDebuff()` (returns stacks at position 4), NOT raw `UnitDebuff()` (returns auraId at position 4)
- **Auto-attack** — Scans 172 action bar slots with `IsCurrentAction()`. Never call `AttackTarget()` in combat (it toggles!)

## Gotchas
- **Spell name case**: Case-sensitive in `CastSpellByName`. Use exact names from spellbook
- **copy parameter**: Nampower table-returning functions reuse the same table. Store values immediately or pass `copy=1`
- **CVar requirements**: Auto-attack events need `NP_EnableAutoAttackEvents=1`. Aura cap tracking needs `NP_EnableAuraCastEvents=1`. Set in `Config\config.wtf` or via `/run SetCVar(...)`
- **UnitXP distance cache**: `inSight` results cached 100ms. `distanceBetween` has 5 meter types — default is ranged, use "meleeAutoAttack" for melee
- **HS dequeue trap**: `CastSpellByName("Heroic Strike")` when HS is already queued DEQUEUES it — use per-cycle `swingAttackQueued` reset to prevent
- **SuperWoW GUID return**: `UnitExists("target")` returns `(1, guid)` — GUID is the 2nd value. Use `local _, guid = UnitExists("target")`
- **TargetUnit with GUIDs**: `TargetUnit(guid)` accepts GUID strings but passing `1` (vanilla return) errors with "Unknown unit name: 1"
- **Phantom reservations**: `SetReservedRage()` for abilities that never fire inflates `reservedRage` — remove unused reservations
- **UnitXP cycling pitfall**: With 1 alive enemy + dead mobs, cycling can break targeting — guard with early return if current target needs work
