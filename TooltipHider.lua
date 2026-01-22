local ADDON_NAME = ...
local DEFAULTS = {
  enabled = true,
}

local function InitializeDB()
  if type(TooltipHiderDB) ~= "table" then
    TooltipHiderDB = {}
  end
  if TooltipHiderDB.enabled == nil then
    TooltipHiderDB.enabled = DEFAULTS.enabled
  end
end

local function IsEnabled()
  return TooltipHiderDB and TooltipHiderDB.enabled
end

local function SetEnabled(enabled)
  TooltipHiderDB.enabled = enabled and true or false
end

local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00TooltipHider:|r " .. msg)
end

local function ShouldHide()
  return IsEnabled() and InCombatLockdown()
end

local function HideTooltip(tooltip)
  if tooltip and tooltip:IsShown() then
    tooltip:Hide()
  end
end

local function OnTooltipShow(tooltip)
  if ShouldHide() then
    HideTooltip(tooltip)
  end
end

local tooltips = {
  GameTooltip,
  ItemRefTooltip,
  ShoppingTooltip1,
  ShoppingTooltip2,
  ShoppingTooltip3,
  WorldMapTooltip,
}

for _, tooltip in ipairs(tooltips) do
  if tooltip and tooltip.HookScript then
    tooltip:HookScript("OnShow", OnTooltipShow)
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

frame:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
    InitializeDB()
    Print("Loaded. Type /tooltiphider to toggle.")
  elseif event == "PLAYER_REGEN_DISABLED" then
    if ShouldHide() then
      HideTooltip(GameTooltip)
      HideTooltip(ItemRefTooltip)
      HideTooltip(ShoppingTooltip1)
      HideTooltip(ShoppingTooltip2)
      HideTooltip(ShoppingTooltip3)
      HideTooltip(WorldMapTooltip)
    end
  elseif event == "PLAYER_REGEN_ENABLED" then
    -- Tooltips will show normally out of combat
  end
end)

SLASH_TOOLTIPHIDER1 = "/tooltiphider"
SLASH_TOOLTIPHIDER2 = "/th"
SlashCmdList.TOOLTIPHIDER = function()
  SetEnabled(not IsEnabled())
  if IsEnabled() then
    Print("Enabled (tooltips hidden in combat).")
  else
    Print("Disabled (tooltips will show in combat).")
  end
end
