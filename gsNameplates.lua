--[[
gsNameplates
Created by ColbyWanShinobi
email: colbywanshinobi@gameshaman.com
web: gameshaman.com
repo: https://github.com/ColbyWanShinobi/gsNameplates.git
--]]

local gsNameplates = CreateFrame("Frame");
local events = {};

local barTexturePath = "Interface\\Addons\\gsNameplates\\media\\gsBarTexture";
local fontPath = "Interface\\Addons\\gsNameplates\\media\\LiberationSans-Regular.ttf";
local fontSize = 10;

function printTable(table)
	if type(table) == "table" then
		for k, v in pairs(table) do
			local value = v;
			if type(v) ~= "string" then
				value = type(v);
			end
			print("["..k.."]".."["..value.."]");
		end
	else
		print("NOT A TABLE");
	end
end

local function round(number, decimals)
	local power = 10^decimals
	return math.floor(number * power) / power
end

local function add_commas(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

local function formatNumbers(amount)
	local formatted = amount;
	if amount >= 10000 and amount <= 1000000 then
		local k = round(amount / 1000, 2).."K";
		formatted = k;
	elseif amount > 1000000 then
		local m = round(amount / 1000000, 2).."M";
		formatted = m;
	else
		formatted = add_commas(amount) 
	end
	return formatted;
end

function gsNameplates:applyHealthbarClassColor(frame)
	local r, g, b;
	local localizedClass, englishClass = UnitClass(frame.unit);
	local classColor = RAID_CLASS_COLORS[englishClass];
	r, g, b = classColor.r, classColor.g, classColor.b;
	frame.healthBar:SetStatusBarColor(r, g, b);
end

function gsNameplates:applyHealthbarTexture(frame)
	frame.healthBar:SetStatusBarTexture(barTexturePath);
end

function gsNameplates:updateHealthText(frame)
	if frame.optionTable.colorNameBySelection and not frame:IsForbidden() then
		local healthPercentage = ceil((UnitHealth(frame.displayedUnit) / UnitHealthMax(frame.displayedUnit) * 100));

		if not frame.health then
			frame.health = CreateFrame("Frame", nil, frame) -- Setting up custom health display frames.
			frame.health:SetSize(170,16)
			frame.health.text = frame.health.text or frame.health:CreateFontString(nil, "OVERLAY")
			frame.health.text:SetAllPoints(true)
			frame.health:SetFrameStrata("HIGH")
			frame.health:SetPoint("CENTER", frame.healthBar)
			frame.health.text:SetVertexColor(1, 1, 1)
		end
		frame.health.text:SetFont(fontPath, fontSize, "OUTLINE")
		frame.health.text:SetText(formatNumbers(UnitHealth(frame.unit)) .. " (" .. healthPercentage .. "%)")
		frame.health.text:Show()
	end
end

function gsNameplates:updatePowerbarText(frame)
	local powerPercentage = ceil((UnitPower("player") / UnitPowerMax("player") * 100)) -- Calculating a percentage value for primary resource (Rage/Mana/Focus/etc.)

	frame:SetStatusBarTexture(barTexturePath)
	if not frame.powerNumbers then
		frame.powerNumbers = CreateFrame("Frame", nil, frame) -- Setting up resource display frame.
		frame.powerNumbers:SetSize(170,16)
		frame.powerNumbers.text = frame.powerNumbers.text or frame.powerNumbers:CreateFontString(nil, "OVERLAY")
		frame.powerNumbers.text:SetAllPoints(true)
		frame.powerNumbers:SetFrameStrata("HIGH")
		frame.powerNumbers:SetPoint("CENTER", frame)
		frame.powerNumbers.text:SetFont(fontPath, fontSize, "OUTLINE")
		frame.powerNumbers.text:SetVertexColor(1, 1, 1)
	else
		if InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:GetValue() == "1" then -- If 'Larger Nameplates' option is enabled.
			frame.powerNumbers.text:SetText(powerPercentage .. "%") -- Update resource percentages.
			frame.powerNumbers.text:Show()
		else
			frame.powerNumbers.text:Hide() -- Not enough space on regular-sized nameplates to have text on resource bar alongside health bar text, so we disable that.
		end
	end
end

function gsNameplates:applyCastbarStyle(frame)
	frame.castBar.Text:SetFont(fontPath, fontSize, "OUTLINE");
	frame.castBar:SetStatusBarTexture(barTexturePath);
end

hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
	gsNameplates:updateHealthText(frame);
end)

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)

end)

hooksecurefunc("ClassNameplateManaBar_OnUpdate", function(frame)
	gsNameplates:updatePowerbarText(frame);

end)

--Set bar texture for primary player unitframe
hooksecurefunc("PlayerFrame_ToPlayerArt", function(frame)
end)

hooksecurefunc("TargetFrame_OnUpdate", function(frame)
end)




-- *****************************************************************
-- *****************************************************************
function gsNameplates:init()
  self:SetScript("OnEvent", function(frame, event, ...)
    local handler = events[event];
    if handler then
      -- dispatch events that were auto-registered by naming convention
      handler(frame, ...);
    end
  end)
  for k,v in pairs(events) do
    self:RegisterEvent(k);
  end
    
end

function events:ADDON_LOADED(addonName)
  if (addonName == "gsNameplates") then
		print("gsNameplates [gsNP] by gameshaman.com - Addon Loaded");
		C_NamePlate.SetNamePlateSelfClickThrough(true);
		SetCVar('nameplatePersonalShowAlways', true)
		SetCVar('nameplateMaxDistance', 40)
		SetCVar('nameplateTargetBehindMaxDistance', 20)
  end
end

function events:PLAYER_TARGET_CHANGED()

end

function events:NAME_PLATE_UNIT_ADDED(unitId)
		local nameplate = C_NamePlate.GetNamePlateForUnit(unitId);
		gsNameplates:applyHealthbarTexture(nameplate.UnitFrame);
		gsNameplates:updateHealthText(nameplate.UnitFrame);
		gsNameplates:applyCastbarStyle(nameplate.UnitFrame);
		if nameplate == C_NamePlate.GetNamePlateForUnit("player") then
			printTable(nameplate)
			gsNameplates:applyHealthbarClassColor(nameplate.UnitFrame);
		end
end
-- ................................................................
  -- must be last line:
	gsNameplates:init();
