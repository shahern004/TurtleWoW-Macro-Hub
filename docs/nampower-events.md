# Nampower Custom Events Reference

> Source: https://gitea.com/avitasia/nampower (EVENTS.md)
> Version: master HEAD
> Last fetched: 2026-02-06

All custom events fired by Nampower. Events marked **Requires** are disabled by
default and must be enabled via CVar. Event arguments are accessed via `arg1`,
`arg2`, etc. in the event handler (standard 1.12 pattern).

### How to Enable CVar-Gated Events

```lua
-- Session-only (resets on restart):
/run SetCVar("NP_EnableAutoAttackEvents", "1")

-- Persistent (add to Config/config.wtf):
SET NP_EnableAutoAttackEvents "1"

-- Verify current value:
/run DEFAULT_CHAT_FRAME:AddMessage(GetCVar("NP_EnableAutoAttackEvents"))
```

**See also:** `nampower-cvars.md#custom-event-toggles` for all 6 toggle CVars

---

## SPELL_QUEUE_EVENT

Fires when a spell enters or leaves the queue.

**CVar gate:** None (always active)

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | number | Event code (see below) |
| arg2 | number | Spell ID |

**Event codes:**
| Code | Constant | Meaning |
|------|----------|---------|
| 0 | ON_SWING_QUEUED | On-swing spell added to queue |
| 1 | ON_SWING_QUEUE_POPPED | On-swing spell left queue (cast) |
| 2 | NORMAL_QUEUED | Normal (GCD) spell added to queue |
| 3 | NORMAL_QUEUE_POPPED | Normal spell left queue (cast) |
| 4 | NON_GCD_QUEUED | Non-GCD spell added to queue |
| 5 | NON_GCD_QUEUE_POPPED | Non-GCD spell left queue (cast) |

---

## SPELL_CAST_EVENT

Fires when the player attempts to cast a spell (success or failure).

**CVar gate:** None (always active)

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | number | `1` = succeeded, `0` = failed |
| arg2 | number | Spell ID |
| arg3 | number | Cast type (see below) |
| arg4 | string | Target GUID or `"0x000000000"` |
| arg5 | number | Item ID that triggered the cast (`0` if spell-initiated) |

**Cast types:**
| Value | Constant | Meaning |
|-------|----------|---------|
| 1 | NORMAL | Standard cast-time spell |
| 2 | NON_GCD | Spell not on GCD |
| 3 | ON_SWING | Next-melee-swing spell |
| 4 | CHANNEL | Channeled spell |
| 5 | TARGETING | Terrain targeting spell |
| 6 | TARGETING_NON_GCD | Terrain targeting, non-GCD |

---

## SPELL_START_SELF / SPELL_START_OTHER

Fires when a spell cast begins (SELF = player, OTHER = any other unit).

**Requires:** `NP_EnableSpellStartEvents=1` -> See `nampower-cvars.md#custom-event-toggles`

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | number | Item ID (`0` if spell-initiated) |
| arg2 | number | Spell ID |
| arg3 | string | Caster GUID |
| arg4 | string | Target GUID or `"0x0000000000000000"` |
| arg5 | number | Cast flags (bitmask, see below) |
| arg6 | number | Cast time in milliseconds |

**See also:** `superwow-api.md#UNIT_CASTEVENT` (SuperWoW equivalent, always active, fires for all visible units)

---

## SPELL_GO_SELF / SPELL_GO_OTHER

Fires when a spell completes and takes effect.

**Requires:** `NP_EnableSpellGoEvents=1` -> See `nampower-cvars.md#custom-event-toggles`

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | number | Item ID (`0` if spell-initiated) |
| arg2 | number | Spell ID |
| arg3 | string | Caster GUID |
| arg4 | string | Target GUID or `"0x0000000000000000"` |
| arg5 | number | Cast flags (bitmask) |
| arg6 | number | Number of targets hit |
| arg7 | number | Number of targets missed |

**Cast flags bitmask:**
| Value | Constant | Description |
|-------|----------|-------------|
| 0x00 | CAST_FLAG_NONE | No flags |
| 0x01 | CAST_FLAG_HIDDEN_COMBATLOG | Hidden from combat log |
| 0x02 | CAST_FLAG_UNKNOWN2 | Unknown |
| 0x04 | CAST_FLAG_UNKNOWN3 | Unknown |
| 0x08 | CAST_FLAG_UNKNOWN4 | Unknown |
| 0x10 | CAST_FLAG_UNKNOWN5 | Unknown |
| 0x20 | CAST_FLAG_AMMO | Uses ammo |
| 0x40 | CAST_FLAG_UNKNOWN7 | Unknown |
| 0x80 | CAST_FLAG_UNKNOWN8 | Unknown |
| 0x100 | CAST_FLAG_UNKNOWN9 | Unknown |

---

## SPELL_FAILED_SELF / SPELL_FAILED_OTHER

Fires when a spell cast fails.

**CVar gate:** None (always active)

**SPELL_FAILED_SELF:**

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | number | Spell ID |
| arg2 | number | SpellCastResult enum value |
| arg3 | number | `1` if server-initiated failure, `0` if client-side |

**SPELL_FAILED_OTHER:**

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | string | Caster GUID |
| arg2 | number | Spell ID |

---

## SPELL_DELAYED_SELF / SPELL_DELAYED_OTHER

Fires when a spell cast is delayed (pushback).

**CVar gate:** None (always active)

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | string | Caster GUID |
| arg2 | number | Delay amount in milliseconds |

Note: `SPELL_DELAYED_OTHER` is non-functional; the server only sends delay
information to the affected player.

---

## SPELL_CHANNEL_START

Fires when a channeled spell begins.

**CVar gate:** None (always active)

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | number | Spell ID |
| arg2 | string | Target GUID or `"0x0000000000000000"` |
| arg3 | number | Channel duration in milliseconds |

---

## SPELL_CHANNEL_UPDATE

Fires when a channel tick occurs or channel is partially interrupted.

**CVar gate:** None (always active)

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | number | Spell ID |
| arg2 | string | Target GUID or `"0x0000000000000000"` |
| arg3 | number | Remaining channel time in milliseconds |

---

## SPELL_DAMAGE_EVENT_SELF / SPELL_DAMAGE_EVENT_OTHER

Fires when spell damage is dealt (SELF = player is caster or target,
OTHER = neither).

**CVar gate:** None (always active)

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | string | Target GUID (damage recipient) |
| arg2 | string | Caster GUID (damage source) |
| arg3 | number | Spell ID |
| arg4 | number | Damage amount (or percentage for certain aura effects) |
| arg5 | string | Mitigation string: `"absorb,block,resist"` (comma-separated) |
| arg6 | number | Hit info bitfield (`0` = normal, `2` = critical) |
| arg7 | number | Spell school |
| arg8 | string | Effect/aura string: `"effect1,effect2,effect3,auraType"` |

---

## BUFF_ADDED_SELF / BUFF_REMOVED_SELF

## BUFF_ADDED_OTHER / BUFF_REMOVED_OTHER

## DEBUFF_ADDED_SELF / DEBUFF_REMOVED_SELF

## DEBUFF_ADDED_OTHER / DEBUFF_REMOVED_OTHER

Eight events for aura changes. SELF = player, OTHER = any other unit.

**CVar gate:** None (always active)

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | string | Unit GUID |
| arg2 | number | Aura slot (1-based Lua index, skips empty slots) |
| arg3 | number | Spell ID |
| arg4 | number | Stack count (`1` for new, `0` when removed) |
| arg5 | number | Aura level (caster's level when aura was applied) |

---

## AURA_CAST_ON_SELF / AURA_CAST_ON_OTHER

Fires when an aura is applied to a unit. Fires separately for each target
affected by a spell.

**Requires:** `NP_EnableAuraCastEvents=1` -> See `nampower-cvars.md#custom-event-toggles`

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | number | Spell ID |
| arg2 | string | Caster GUID |
| arg3 | string | Target GUID |
| arg4 | number | Effect index (which spell effect applied the aura) |
| arg5 | number | EffectApplyAuraName enum value |
| arg6 | number | EffectAmplitude value |
| arg7 | number | EffectMiscValue entry |
| arg8 | number | Aura duration in milliseconds |
| arg9 | number | Aura cap status bitfield: `1`=buff bar full, `2`=debuff bar full, `3`=both full |

---

## AUTO_ATTACK_SELF / AUTO_ATTACK_OTHER

Fires on melee auto-attacks. SELF = player is attacker or victim,
OTHER = neither.

**Requires:** `NP_EnableAutoAttackEvents=1` -> See `nampower-cvars.md#custom-event-toggles`

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | string | Attacker GUID |
| arg2 | string | Target GUID (victim) |
| arg3 | number | Total damage dealt |
| arg4 | number | HitInfo bitfield (see below) |
| arg5 | number | VictimState (see below) |
| arg6 | number | Sub-damage count (typically `1`) |
| arg7 | number | Blocked amount |
| arg8 | number | Total absorbed |
| arg9 | number | Total resisted |

**HitInfo flags (bitmask):**
| Value | Constant | Description |
|-------|----------|-------------|
| 0x0 | HITINFO_NORMALSWING | Normal swing |
| 0x1 | HITINFO_UNK0 | Unknown |
| 0x2 | HITINFO_AFFECTS_VICTIM | Affects victim |
| 0x4 | HITINFO_LEFTSWING | Off-hand swing |
| 0x10 | HITINFO_MISS | Attack missed |
| 0x20 | HITINFO_ABSORB | Damage absorbed |
| 0x40 | HITINFO_RESIST | Damage resisted |
| 0x80 | HITINFO_CRITICALHIT | Critical hit |
| 0x4000 | HITINFO_GLANCING | Glancing blow |
| 0x8000 | HITINFO_CRUSHING | Crushing blow |
| 0x10000 | HITINFO_NOACTION | No action |
| 0x80000 | HITINFO_SWINGNOHITSOUND | Swing with no hit sound |

**VictimState values:**
| Value | Constant | Description |
|-------|----------|-------------|
| 0 | VICTIMSTATE_UNAFFECTED | Miss (with HITINFO_MISS) |
| 1 | VICTIMSTATE_NORMAL | Normal hit |
| 2 | VICTIMSTATE_DODGE | Dodged |
| 3 | VICTIMSTATE_PARRY | Parried |
| 4 | VICTIMSTATE_INTERRUPT | Interrupted |
| 5 | VICTIMSTATE_BLOCKS | Blocked |
| 6 | VICTIMSTATE_EVADES | Evaded |
| 7 | VICTIMSTATE_IS_IMMUNE | Immune |
| 8 | VICTIMSTATE_DEFLECTS | Deflected |

---

## SPELL_HEAL_BY_SELF / SPELL_HEAL_BY_OTHER / SPELL_HEAL_ON_SELF

Fires on healing events. BY_SELF = player is healer, BY_OTHER = someone else
heals someone else, ON_SELF = player is healed.

**Requires:** `NP_EnableSpellHealEvents=1` -> See `nampower-cvars.md#custom-event-toggles`

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | string | Target GUID (heal recipient) |
| arg2 | string | Caster GUID (healer) |
| arg3 | number | Spell ID |
| arg4 | number | Heal amount |
| arg5 | number | `1` if critical, `0` otherwise |
| arg6 | number | `1` if periodic (HoT tick), `0` otherwise |

---

## SPELL_ENERGIZE_BY_SELF / SPELL_ENERGIZE_BY_OTHER / SPELL_ENERGIZE_ON_SELF

Fires on power restoration events (mana, rage, energy, etc.).

**Requires:** `NP_EnableSpellEnergizeEvents=1` -> See `nampower-cvars.md#custom-event-toggles`

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | string | Target GUID (power recipient) |
| arg2 | string | Caster GUID (power source) |
| arg3 | number | Spell ID |
| arg4 | number | Power type (see below) |
| arg5 | number | Power amount restored |
| arg6 | number | `1` if periodic, `0` otherwise |

**Power types:**
| Value | Constant | Description |
|-------|----------|-------------|
| 0 | POWER_MANA | Mana |
| 1 | POWER_RAGE | Rage |
| 2 | POWER_FOCUS | Focus (hunter pets) |
| 3 | POWER_ENERGY | Energy |
| 4 | POWER_HAPPINESS | Happiness (hunter pets) |
| -2 | POWER_HEALTH | Health (as power) |

---

## UNIT_DIED

Fires when any unit dies.

**CVar gate:** None (always active)

| Arg | Type | Description |
|-----|------|-------------|
| arg1 | string | GUID of the deceased unit |
