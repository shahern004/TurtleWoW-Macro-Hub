local DoiteBuffData = {
  -- this uses spellId as key to avoid having to look up UNIT_CASTEVENT spell names
  stackConsumers = {
    -- Mage --
    [11366] = { -- Pyroblast rk 1
      modifiedBuffName = "Hot Streak",
      stackChange = -5
    },
    [12505] = {  -- Pyroblast rk 2
      modifiedBuffName = "Hot Streak",
      stackChange = -5
    },
    [12522] = {  -- Pyroblast rk 3
      modifiedBuffName = "Hot Streak",
      stackChange = -5
    },
    [12523] = {  -- Pyroblast rk 4
      modifiedBuffName = "Hot Streak",
      stackChange = -5
    },
    [12524] = {  -- Pyroblast rk 5
      modifiedBuffName = "Hot Streak",
      stackChange = -5
    },
    [12525] = {  -- Pyroblast rk 6
      modifiedBuffName = "Hot Streak",
      stackChange = -5
    },

    -- Shaman --
    [51387] = {  -- Lightning Strike rk 1
      modifiedBuffName = "Lightning Shield",
      stackChange = -1
    },
    [52420] = {  -- Lightning Strike rk 2
      modifiedBuffName = "Lightning Shield",
      stackChange = -1
    },
    [52422] = {  -- Lightning Strike rk 3
      modifiedBuffName = "Lightning Shield",
      stackChange = -1
    },
  }
}
_G["DoiteBuffData"] = DoiteBuffData
