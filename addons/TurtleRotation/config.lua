-- TurtleRotation Config
-- All tuning constants in one place. Edit here to adjust rotation behavior.
-- Future: SavedVariablesPerCharacter will override these defaults.

TR.config = {
    -- GCD queue window (ms). Abilities cast if their CD remaining < this value.
    -- Matches IWinEnhanced: cast slightly early, let engine handle queue timing.
    queueWindow = 1500,

    -- Slam: only cast when swing timer is in first half (prevents auto-attack clip).
    -- Ratio of swing timer elapsed before slam is blocked. 0.5 = IWinEnhanced default.
    slamSwingRatio = 0.5,

    -- Overpower window duration (seconds). Dodge gives a 5-second react window.
    overpowerWindow = 5.0,

    -- Revenge window duration (seconds). Block/parry/dodge gives 5-second window.
    revengeWindow = 5.0,

    -- Rage costs per ability (base, before talent reductions).
    -- Update these if talents reduce costs (e.g., Improved Heroic Strike).
    rageCost = {
        ["Execute"]         = 15,
        ["Mortal Strike"]   = 30,
        ["Bloodthirst"]     = 30,
        ["Whirlwind"]       = 25,
        ["Slam"]            = 15,
        ["Heroic Strike"]   = 15,
        ["Cleave"]          = 20,
        ["Sunder Armor"]    = 15,
        ["Overpower"]       = 5,
        ["Revenge"]         = 5,
        ["Battle Shout"]    = 10,
        ["Hamstring"]       = 10,
        ["Thunder Clap"]    = 20,
        ["Shield Slam"]     = 20,
        ["Concussion Blow"] = 25,
    },

    -- Spell IDs for Nampower API calls (GetSpellIdCooldown, etc.).
    -- TurtleWoW spell IDs — verify in-game with /run print(GetSpellRec(ID).name)
    -- NOTE: These are max-rank IDs. Populate during Task 8 in-game verification.
    spellId = {
        ["Execute"]         = 0,  -- FILL IN-GAME
        ["Mortal Strike"]   = 0,  -- FILL IN-GAME
        ["Bloodthirst"]     = 0,  -- FILL IN-GAME
        ["Whirlwind"]       = 0,  -- FILL IN-GAME
        ["Slam"]            = 0,  -- FILL IN-GAME
        ["Heroic Strike"]   = 0,  -- FILL IN-GAME
        ["Cleave"]          = 0,  -- FILL IN-GAME
        ["Sunder Armor"]    = 0,  -- FILL IN-GAME
        ["Overpower"]       = 0,  -- FILL IN-GAME
        ["Revenge"]         = 0,  -- FILL IN-GAME
        ["Battle Shout"]    = 0,  -- FILL IN-GAME
        ["Battle Stance"]   = 0,  -- FILL IN-GAME
        ["Defensive Stance"]= 0,  -- FILL IN-GAME
        ["Berserker Stance"]= 0,  -- FILL IN-GAME
    },

    -- Stance IDs for GetShapeshiftFormInfo index
    stance = {
        battle    = 1,
        defensive = 2,
        berserker = 3,
    },

    -- Rage thresholds for Heroic Strike (on-next-swing dump).
    hsRageThreshold = 60,

    -- Execute rage threshold. Higher = bigger execute damage.
    executeRageThreshold = 30,

    -- Sunder target stacks. Stop sundering at this count.
    sunderMaxStacks = 5,

    -- Tactical Mastery: max rage retained on stance swap.
    tacticalMasteryRage = 25,
}
