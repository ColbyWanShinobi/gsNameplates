--[[
gsNameplates
Created by ColbyWanShinobi
email: colbywanshinobi@gameshaman.com
web: gameshaman.com
repo: https://github.com/ColbyWanShinobi/gsNameplates.git
--]]

local gsNameplates = CreateFrame("Frame");
local events = {};

gsNameplates.barTexturePath = "Interface\\Addons\\gsNameplates\\media\\gsBarTexture";
gsNameplates.fontPath = "Interface\\Addons\\gsNameplates\\media\\LiberationSans-Regular.ttf";
gsNameplates.fontSize = 10;
gsNameplates.nameFontSize = 12;
gsNameplates.defaultNameplateScale = 1;
gsNameplates.defaultNameplateAlpha = 1;
gsNameplates.pvpNameplateScale = 1;
gsNameplates.pvpNameplateAlpha = 0.5;
gsNameplates.worldNameplateScale = 0.75;
gsNameplates.worldNameplateAlpha = 0.40;

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
	frame.healthBar:SetStatusBarTexture(gsNameplates.barTexturePath);
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
		frame.health.text:SetFont(gsNameplates.fontPath, gsNameplates.fontSize, "OUTLINE")
		frame.health.text:SetText(formatNumbers(UnitHealth(frame.unit)) .. " (" .. healthPercentage .. "%)")
		frame.health.text:Show()
	end
end

function gsNameplates:updatePowerbarText(frame)
	local powerPercentage = ceil((UnitPower("player") / UnitPowerMax("player") * 100)) -- Calculating a percentage value for primary resource (Rage/Mana/Focus/etc.)

	frame:SetStatusBarTexture(gsNameplates.barTexturePath)
	if not frame.powerNumbers then
		frame.powerNumbers = CreateFrame("Frame", nil, frame) -- Setting up resource display frame.
		frame.powerNumbers:SetSize(170,16)
		frame.powerNumbers.text = frame.powerNumbers.text or frame.powerNumbers:CreateFontString(nil, "OVERLAY")
		frame.powerNumbers.text:SetAllPoints(true)
		frame.powerNumbers:SetFrameStrata("HIGH")
		frame.powerNumbers:SetPoint("CENTER", frame)
		frame.powerNumbers.text:SetFont(gsNameplates.fontPath, gsNameplates.fontSize, "OUTLINE")
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
	frame.castBar.Text:SetFont(gsNameplates.fontPath, gsNameplates.fontSize, "OUTLINE");
	frame.castBar:SetStatusBarTexture(gsNameplates.barTexturePath);
end

function gsNameplates:updateNameText(frame)
	if not UnitIsPlayer(frame.unit) and not string.match(frame.unit, "raid*%a%d+") and not string.match(frame.unit, "party*%a%d+") then
		local level = UnitLevel(frame.unit) or "";
		if level == -1 then
			level = "??";
		end
		local name = GetUnitName(frame.unit) or "";
		frame.name:SetText("["..level.."] "..name);
	end
	frame.name:SetFont(gsNameplates.fontPath, gsNameplates.nameFontSize, "OUTLINE");
end

function gsNameplates:setVisibility(frame, frameAlpha, frameScale)
	frame:SetAlpha(frameAlpha);
	frame:SetScale(frameScale);
end

function gsNameplates:setNameplateFrameVisibility(frame)
	local threatStatus = UnitThreatSituation("player", frame.unit);
	local nameplate = C_NamePlate.GetNamePlateForUnit(frame.unit);
	--local inRange = CheckInteractDistance(frame.unit, 4); --this is a hack because Blizz fubared range detection on nomeplates - https://wow.gamepedia.com/API_CheckInteractDistance
	local playerNameplate = C_NamePlate.GetNamePlateForUnit("player");
	local targetNameplate = C_NamePlate.GetNamePlateForUnit("target");
	local mobName = GetUnitName(frame.unit) or "";

	if nameplate == playerNameplate then --never modify the player nameplate/PRD
		gsNameplates:setVisibility(frame, gsNameplates.defaultNameplateAlpha, gsNameplates.defaultNameplateScale);
	else
		if UnitIsPlayer(frame.unit) then --is it another player?
			gsNameplates:setVisibility(frame, gsNameplates.pvpNameplateAlpha, gsNameplates.pvpNameplateScale);
		elseif nameplate == targetNameplate or threatStatus ~= nil then
			--if target or any mob we have threat status with, then full size frame
			gsNameplates:setVisibility(frame, gsNameplates.defaultNameplateAlpha, gsNameplates.defaultNameplateScale);
			--if we have any non nil threat status, then set the color accordingly, otherwise ignore color
			if threatStatus ~= nil then
				local r, g, b = GetThreatStatusColor(threatStatus);
				frame.healthBar:SetStatusBarColor(r, g, b);
			end
		--elseif not inRange then
			--gsNameplates:setVisibility(frame, gsNameplates.hiddenNameplateAlpha, gsNameplates.hiddenNameplateScale);
		else
			gsNameplates:setVisibility(frame, gsNameplates.worldNameplateAlpha, gsNameplates.worldNameplateScale);
		end
	end
end

hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
	gsNameplates:updateHealthText(frame);
end)

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
	gsNameplates:updateNameText(frame);
end)

hooksecurefunc("ClassNameplateManaBar_OnUpdate", function(frame)
	gsNameplates:updatePowerbarText(frame);

end)

--Set bar texture for primary player unitframe
hooksecurefunc("PlayerFrame_ToPlayerArt", function(frame)
	frame.healthbar:SetStatusBarTexture(gsNameplates.barTexturePath);
end)

hooksecurefunc("TargetFrame_OnUpdate", function(frame)
	frame.healthbar:SetStatusBarTexture(gsNameplates.barTexturePath);
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
	for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
		gsNameplates:setNameplateFrameVisibility(nameplate.UnitFrame);
	end
end

function events:NAME_PLATE_UNIT_ADDED(unitId)
		local nameplate = C_NamePlate.GetNamePlateForUnit(unitId);
		gsNameplates:applyHealthbarTexture(nameplate.UnitFrame);
		gsNameplates:updateHealthText(nameplate.UnitFrame);
		gsNameplates:applyCastbarStyle(nameplate.UnitFrame);
		if nameplate == C_NamePlate.GetNamePlateForUnit("player") then
			gsNameplates:updateHealthText(nameplate.UnitFrame); -- apply the health text again to the PRD because sometimes it doesn't work the first time
			gsNameplates:applyHealthbarClassColor(nameplate.UnitFrame);
		end
		gsNameplates:setNameplateFrameVisibility(nameplate.UnitFrame);
end

function events:PLAYER_REGEN_DISABLED()
	for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
		gsNameplates:setNameplateFrameVisibility(nameplate.UnitFrame);
	end
end

function events:PLAYER_REGEN_ENABLED()
	for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
		gsNameplates:setNameplateFrameVisibility(nameplate.UnitFrame);
	end
end

function events:UNIT_THREAT_LIST_UPDATE(unitId)
	if unitId ~= "player" then
		local nameplate = C_NamePlate.GetNamePlateForUnit(unitId);
		if nameplate then
			gsNameplates:setNameplateFrameVisibility(nameplate.UnitFrame);
		end
	end
end
-- ................................................................
  -- must be last line:
	gsNameplates:init();
