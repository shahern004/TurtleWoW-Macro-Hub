---------------------------------------------------------------
-- DoiteGlow.lua
-- Simple compatible glow effect inspired by ActionButtonUtils
-- Please respect license note: Ask permission
-- WoW 1.12 | Lua 5.0
---------------------------------------------------------------

local DG = {}
_G["DoiteGlow"] = DG

-- Local animation data (texture coords for the ants)
local texCoords = {
  { 0.0078, 0.1796, 0.0039, 0.1757 }, { 0.1953, 0.3671, 0.0039, 0.1757 }, { 0.3828, 0.5546, 0.0039, 0.1757 }, { 0.5703, 0.7421, 0.0039, 0.1757 }, { 0.7578, 0.9296, 0.0039, 0.1757 },
  { 0.0078, 0.1796, 0.1914, 0.3632 }, { 0.1953, 0.3671, 0.1914, 0.3632 }, { 0.3828, 0.5546, 0.1914, 0.3632 }, { 0.5703, 0.7421, 0.1914, 0.3632 }, { 0.7578, 0.9296, 0.1914, 0.3632 },
  { 0.0078, 0.1796, 0.3789, 0.5507 }, { 0.1953, 0.3671, 0.3789, 0.5507 }, { 0.3828, 0.5546, 0.3789, 0.5507 }, { 0.5703, 0.7421, 0.3789, 0.5507 }, { 0.7578, 0.9296, 0.3789, 0.5507 },
  { 0.0078, 0.1796, 0.5664, 0.7382 }, { 0.1953, 0.3671, 0.5664, 0.7382 }, { 0.3828, 0.5546, 0.5664, 0.7382 }, { 0.5703, 0.7421, 0.5664, 0.7382 }, { 0.7578, 0.9296, 0.5664, 0.7382 },
  { 0.0078, 0.1796, 0.7539, 0.9257 }, { 0.1953, 0.3671, 0.7539, 0.9257 }, { 0.3828, 0.5546, 0.7539, 0.9257 }, { 0.5703, 0.7421, 0.7539, 0.9257 }, { 0.7578, 0.9296, 0.7539, 0.9257 }
}

local pool = {}
local numOverlays = 0
local updateInterval = 0.04

local function NextIndex(i)
  if i >= 22 then
    return 1
  else
    return i + 1
  end
end

local function GetOverlay()
  local overlay = tremove(pool)
  if not overlay then
    numOverlays = numOverlays + 1
    overlay = CreateFrame("Frame", "DoiteGlowOverlay" .. numOverlays)
    overlay:SetFrameStrata("TOOLTIP")

    overlay.bg = overlay:CreateTexture(nil, "ARTWORK")
    overlay.bg:SetTexture("Interface\\AddOns\\DoiteAuras\\Textures\\IconAlert")
    overlay.bg:SetTexCoord(0.0546, 0.4609, 0.3007, 0.5039)
    overlay.bg:SetAllPoints(overlay)

    overlay.glow = overlay:CreateTexture(nil, "OVERLAY")
    overlay.glow:SetTexture("Interface\\AddOns\\DoiteAuras\\Textures\\IconAlertAnts")
    overlay.glow:SetTexCoord(texCoords[1][1], texCoords[1][2], texCoords[1][3], texCoords[1][4])
    overlay.glow:SetAllPoints(overlay)
    overlay.glow:SetBlendMode("ADD")
  end
  return overlay
end

function DG.Start(frame)
  if not frame then
    return
  end
  if frame.glow then
    return
  end

  local overlay = GetOverlay()
  overlay:SetParent(frame)
  overlay:SetAllPoints(frame)
  overlay:SetWidth(frame:GetWidth())
  overlay:SetHeight(frame:GetHeight())
  overlay.index = 1
  overlay.lastUpdated = 0
  frame.glow = overlay
  overlay:Show()

  overlay:SetScript("OnUpdate", function()
    overlay.lastUpdated = overlay.lastUpdated + arg1
    if overlay.lastUpdated > updateInterval then
      overlay.index = NextIndex(overlay.index)
      overlay.glow:SetTexCoord(texCoords[overlay.index][1], texCoords[overlay.index][2],
          texCoords[overlay.index][3], texCoords[overlay.index][4])
      overlay.lastUpdated = 0
    end
  end)
end

function DG.Stop(frame)
  if not frame or not frame.glow then
    return
  end
  local overlay = frame.glow
  frame.glow:SetScript("OnUpdate", nil)
  frame.glow:Hide()
  frame.glow:SetParent(UIParent)
  frame.glow = nil
  tinsert(pool, overlay)
end
