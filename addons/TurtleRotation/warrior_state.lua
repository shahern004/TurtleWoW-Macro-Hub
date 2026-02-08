-- TurtleRotation Warrior State
-- Per-keypress and persistent combat state for warrior rotations.

TR.state = {
    -- Per-keypress state (reset by InitializeRotation)
    queueGCD = true,           -- mutex: prevents multiple GCD casts per keypress
    reservedRage = 0,          -- running sum of rage reserved for upcoming abilities

    -- Persistent state (set by events, NOT reset per keypress)
    overpowerUntil = 0,        -- GetTime() when overpower window expires
    revengeUntil = 0,          -- GetTime() when revenge window expires
    slamCasting = false,       -- true while Slam cast bar is active
    slamCastEnd = 0,           -- GetTime() when current slam cast finishes
    swingAttackQueued = false,  -- true when HS/Cleave is queued (on-next-swing)
    autoAttacking = false,      -- true after AttackTarget() called, reset on combat drop/target change
    lastStanceSwap = 0,        -- GetTime() of last stance swap (prevent double-swap)
}

--- Reset per-keypress state. Called at the start of every rotation execution.
function TR:InitializeRotation()
    TR.state.queueGCD = true
    TR.state.reservedRage = 0
end

--- Add rage reservation for a lower-priority ability.
-- Called after each ability in the rotation chain.
function TR:ReserveRage(name)
    local cost = TR.config.rageCost[name] or 0
    TR.state.reservedRage = TR.state.reservedRage + cost
end

--- Check if Overpower is available (within react window from a dodge).
function TR:IsOverpowerAvailable()
    return GetTime() < TR.state.overpowerUntil
end

--- Check if Revenge is available (within react window from block/parry/dodge).
function TR:IsRevengeAvailable()
    return GetTime() < TR.state.revengeUntil
end

--- Check if slam timing allows a GCD ability.
-- Returns true if we are NOT in a slam cast right now.
function TR:IsSlamSafe()
    if not TR.state.slamCasting then return true end
    return GetTime() > TR.state.slamCastEnd
end

--- Check if swing timer allows a Slam cast (first half of swing).
-- Reads st_timer from SP_SwingTimer addon (global variable).
-- If SP_SwingTimer is not installed, always allows Slam.
function TR:IsSlamWindowOpen()
    if not st_timer then return true end  -- no swing timer addon = always allow
    local attackSpeed = UnitAttackSpeed("player")
    return st_timer > (attackSpeed * TR.config.slamSwingRatio)
end
