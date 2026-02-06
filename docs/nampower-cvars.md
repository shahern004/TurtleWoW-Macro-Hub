# Nampower CVar Reference

> Source: https://gitea.com/avitasia/nampower (README.md)
> Version: v2.0.0+
> Last fetched: 2026-02-06

All CVars control Nampower behavior. For event toggle CVars, see `nampower-events.md` for full event documentation.

### How to Set CVars

```lua
-- Session-only (resets on game restart):
/run SetCVar("NP_SpellQueueWindowMs", "400")

-- Read current value:
/run DEFAULT_CHAT_FRAME:AddMessage(GetCVar("NP_SpellQueueWindowMs"))
```

```ini
-- Persistent (add to Config/config.wtf, applied on startup):
SET NP_SpellQueueWindowMs "400"
SET NP_EnableAutoAttackEvents "1"
```

---

## Spell Queuing Controls

| CVar | Default | Description |
|------|---------|-------------|
| `NP_QueueCastTimeSpells` | `1` | Queue spells with a cast time. `0` to disable. |
| `NP_QueueInstantSpells` | `1` | Queue instant-cast spells tied to GCD. `0` to disable. |
| `NP_QueueChannelingSpells` | `1` | Queue channeling spells and allow any queuing during channels. `0` to disable. |
| `NP_QueueTargetingSpells` | `1` | Queue terrain-targeting (reticle) spells. `0` to disable. |
| `NP_QueueOnSwingSpells` | `0` | Queue on-next-swing spells (Heroic Strike, etc.). `0` to disable. |
| `NP_QueueSpellsOnCooldown` | `1` | Queue spells that are about to come off cooldown. `0` to disable. |

---

## Timing and Buffer Configuration

| CVar | Default | Description |
|------|---------|-------------|
| `NP_SpellQueueWindowMs` | `500` | Window in ms before a cast finishes where the next spell will be queued. |
| `NP_OnSwingBufferCooldownMs` | `500` | Cooldown in ms after an on-swing spell before another on-swing can queue. |
| `NP_ChannelQueueWindowMs` | `1500` | Window in ms before a channel finishes where the next spell will be queued. |
| `NP_TargetingQueueWindowMs` | `500` | Window in ms before a targeting spell finishes where the next will be queued. |
| `NP_CooldownQueueWindowMs` | `250` | Window in ms of remaining cooldown where a spell queues instead of failing. |
| `NP_MinBufferTimeMs` | `55` | Minimum buffer delay in ms added to each cast. Dynamic buffer will not go below this. |
| `NP_NonGcdBufferTimeMs` | `100` | Buffer delay in ms added after each non-GCD cast. |
| `NP_MaxBufferIncreaseMs` | `30` | Maximum amount in ms to increase the buffer when the server rejects a cast. |

---

## Channel and Latency

| CVar | Default | Description |
|------|---------|-------------|
| `NP_ChannelLatencyReductionPercentage` | `75` | Percentage of latency to subtract from channel end for optimization. |
| `NP_InterruptChannelsOutsideQueueWindow` | `0` | Allow interrupting channels when casting outside the channel queue window. |
| `NP_DoubleCastToEndChannelEarly` | `0` | Double-cast a spell within 350ms to end channeling on next tick. |

---

## Advanced Features

| CVar | Default | Description |
|------|---------|-------------|
| `NP_QuickcastTargetingSpells` | `0` | Instant-cast ALL terrain targeting spells at cursor position (no reticle). |
| `NP_QuickcastOnDoubleCast` | `0` | Cast targeting spells by attempting to cast them twice (alternative quickcast). |
| `NP_ReplaceMatchingNonGcdCategory` | `0` | Replace a queued non-GCD spell when a new one with the same StartRecoveryCategory is cast. |

---

## Safety and Protection

| CVar | Default | Description |
|------|---------|-------------|
| `NP_RetryServerRejectedSpells` | `1` | Retry spells rejected by server for ITEM_NOT_READY, NOT_READY, or SPELL_IN_PROGRESS. |
| `NP_OptimizeBufferUsingPacketTimings` | `0` | Optimize buffer using latency and server packet timings. |
| `NP_SpamProtectionEnabled` | `1` | Block spell spam while waiting for server response. |
| `NP_PreventRightClickTargetChange` | `0` | Prevent right-click from changing target while in combat. |
| `NP_PreventRightClickPvPAttack` | `0` | Prevent right-click on PvP-flagged players to avoid accidental PvP. |
| `NP_PreventMountingWhenBuffCapped` | `1` | Prevent mounting at 32 buffs (would push one off); shows error instead. |

---

## Custom Event Toggles

All event CVars default to `0` (disabled). Set to `1` to enable. See `nampower-events.md` for full event args and documentation.

| CVar | Default | Events Enabled | See |
|------|---------|----------------|-----|
| `NP_EnableAuraCastEvents` | `0` | `AURA_CAST_ON_SELF/OTHER` | `nampower-events.md#AURA_CAST_ON_SELF` |
| `NP_EnableAutoAttackEvents` | `0` | `AUTO_ATTACK_SELF/OTHER` | `nampower-events.md#AUTO_ATTACK_SELF` |
| `NP_EnableSpellStartEvents` | `0` | `SPELL_START_SELF/OTHER` | `nampower-events.md#SPELL_START_SELF` |
| `NP_EnableSpellGoEvents` | `0` | `SPELL_GO_SELF/OTHER` | `nampower-events.md#SPELL_GO_SELF` |
| `NP_EnableSpellHealEvents` | `0` | `SPELL_HEAL_BY/ON_SELF/OTHER` | `nampower-events.md#SPELL_HEAL_BY_SELF` |
| `NP_EnableSpellEnergizeEvents` | `0` | `SPELL_ENERGIZE_BY/ON_SELF/OTHER` | `nampower-events.md#SPELL_ENERGIZE_BY_SELF` |

**Always-active events (no CVar required):** `SPELL_QUEUE_EVENT`,
`SPELL_CAST_EVENT`, `SPELL_FAILED_SELF/OTHER`, `SPELL_DELAYED_SELF/OTHER`,
`SPELL_CHANNEL_START/UPDATE`, `SPELL_DAMAGE_EVENT_SELF/OTHER`,
`BUFF/DEBUFF_ADDED/REMOVED_SELF/OTHER`, `UNIT_DIED`.

---

## World Interface

| CVar | Default | Description |
|------|---------|-------------|
| `NP_NameplateDistance` | (game default) | Distance in yards to display nameplates. Overrides game default or VanillaTweaks setting. |
