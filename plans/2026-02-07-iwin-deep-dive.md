# IWinEnhanced Deep Dive: Adopt Proven Solutions

> **STATUS: COMPLETED (2026-02-07)**
> Research complete. Output: `plans/iwin-solutions-to-port.md`. This research also led to a strategic pivot — instead of porting solutions into TurtleRotation, we decided to **use IWinEnhanced directly** and optimize its warrior rotations for maximum DPS.

> **For Claude:** Start with fresh context. Read this plan, then read `plans/iwin-enhanced-study.md` for prior analysis. The goal was to study IWinEnhanced's **actual code** (not just architecture) for specific problems TurtleRotation was hitting.

**Goal:** Investigate how IWinEnhanced solves specific runtime problems — originally to port into TurtleRotation, but the findings showed TurtleRotation was redundant. We now work within IWinEnhanced directly.

**Why:** The deep dive revealed that all 6 TurtleRotation bugs were already solved in IWinEnhanced. Rather than rebuilding their solutions in our own addon, we adopt IWinEnhanced and focus on rotation optimization and DPS tuning.

**IWinEnhanced source location:** `C:\Games\TurtleWoW\Interface\AddOns\IWinEnhanced\`

---

## Problems to Investigate

### Problem 1: Debuff/Buff Stack Detection
**Our bug:** `UnitDebuff()` returns `auraId` (SuperWoW) not stacks. We can't read Sunder Armor stack count from the API. Currently using a manual counter that doesn't handle misses, other warriors sundering, or debuff expiration.

**Investigate in IWinEnhanced:**
- How does `warrior/condition.lua` check Sunder stacks?
- Do they use `UnitDebuff`, combat log parsing, Nampower events, or something else?
- How do they handle buff duration checks (Battle Shout active)?
- Read `core/condition.lua` for generic buff/debuff helpers

**Files to read:**
- `warrior/condition.lua` — look for Sunder, debuff stack functions
- `core/condition.lua` — look for generic buff/debuff helpers (HasBuff, HasDebuff patterns)
- `warrior/action.lua` — look for SunderArmor function, what conditions it checks

### Problem 2: Auto-Attack Toggle Prevention
**Our bug:** `AttackTarget()` toggles auto-attack off if already active. We added an `autoAttacking` flag but it's fragile (resets on target change/combat drop).

**Investigate in IWinEnhanced:**
- How does `core/action.lua` implement StartAttack?
- Do they use `AttackTarget()`, `IsCurrentAction()`, or something else?
- How do they prevent the toggle-off problem?

**Files to read:**
- `core/action.lua` — StartAttack implementation
- `warrior/rotation.lua` — how/where StartAttack is called in the rotation

### Problem 3: Heroic Strike / On-Next-Swing Management
**Our bug:** HS can be toggled off by rapid keypresses (CastSpellByName("Heroic Strike") dequeues if already queued). We track `swingAttackQueued` but resetting it reliably is hard.

**Investigate in IWinEnhanced:**
- How does `warrior/action.lua` implement HeroicStrike?
- How do they know if HS is already queued?
- How do they prevent the toggle-off problem?
- Do they use Nampower events for swing detection?

**Files to read:**
- `warrior/action.lua` — HeroicStrike / Cleave implementation
- `warrior/event.lua` — swing-related event handlers
- `warrior/condition.lua` — any IsHSQueued or similar checks

### Problem 4: Spell ID Resolution
**Our bug:** We hardcoded vanilla spell IDs in config.lua. IWinEnhanced must also need spell IDs for Nampower calls. How do they resolve them?

**Investigate in IWinEnhanced:**
- Do they hardcode spell IDs or discover them at runtime?
- If runtime: what's the spellbook → spell ID conversion method?
- Check `warrior/data.lua` and `warrior/init.lua` for spell ID tables

**Files to read:**
- `warrior/data.lua` — spell ID tables or discovery logic
- `warrior/init.lua` — initialization that might scan spellbook
- `core/condition.lua` — cooldown check implementation (what ID format does it use?)

### Problem 5: Slam Swing Timer Integration
**Our approach:** Read `st_timer` global from SP_SwingTimer addon. If missing, allow all Slams.

**Investigate in IWinEnhanced:**
- How do they gate Slam on swing timing?
- Do they use SP_SwingTimer's globals directly or have their own timer?
- What's the exact slam window calculation?
- How do they handle Slam resetting the swing timer?

**Files to read:**
- `warrior/action.lua` — Slam function
- `warrior/event.lua` — swing timer event handling
- `warrior/condition.lua` — IsSlamWindowOpen or equivalent

### Problem 6: Rage Reservation Strategy
**Our approach:** Static `ReserveRage()` calls after each ability in the rotation chain. Simple but imprecise.

**Investigate in IWinEnhanced:**
- How does their rage reservation work? (Prior study mentions `GetRageToReserve`)
- Is it time-aware (predict future rage income)?
- How do they balance rage between GCD abilities and HS dump?

**Files to read:**
- `warrior/condition.lua` — GetRageToReserve or HasEnoughRage implementation
- `warrior/rotation.lua` — how reservation integrates with the rotation chain

---

## Deliverable

After investigation, produce a single document: `plans/iwin-solutions-to-port.md` containing:

For each problem above:
1. **How IWinEnhanced solves it** — exact code patterns with file:line references
2. **Adaptation plan** — specific changes to TurtleRotation files
3. **Complexity assessment** — simple port vs needs rework

Then we'll use that document to implement fixes in TurtleRotation.

---

## Execution Notes

- This is a **research task**, not an implementation task
- Read IWinEnhanced source code directly — it's installed locally
- Cross-reference with `plans/iwin-enhanced-study.md` for architecture context
- Focus on the 6 specific problems above — don't analyze the entire codebase
- For each problem, find the SPECIFIC function that solves it and quote the relevant code
