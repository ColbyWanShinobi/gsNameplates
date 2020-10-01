--[[
gsNameplates
Created by ColbyWanShinobi
email: colbywanshinobi@gameshaman.com
web: gameshaman.com
repo: https://github.com/ColbyWanShinobi/gsNameplates.git
--]]

-- Makes Personal Resource Display click-through.
-- C_NamePlate.SetNamePlateSelfClickThrough(true)

local gsNameplates = CreateFrame("Frame");
local events = {};

function loadOptionPanel()
	local gsNP_Options = CreateFrame("frame", "gsNameplates_Options");
	gsNP_Options.name = "gsNameplates";
	InterfaceOptions_AddCategory(gsNP_Options);

	StaticPopupDialogs["GSNAMEPLATESCONFIRMRELOAD"] = {
		text = "Changing this option requires a UI reload. Reload now?",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			ReloadUI();
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	}

	local gsNP_Title = gsNP_Options:CreateFontString("Title", "ARTWORK", "GameFontNormalLarge");
	gsNP_Title:SetPoint("TOPLEFT", 16, -16);
	gsNP_Title:SetText("gsNameplates");

	local prdClickThroughCheckbox = CreateFrame("CheckButton", "prdClickThroughCheckbox", gsNP_Options, "ChatConfigCheckButtonTemplate");
	prdClickThroughCheckbox:SetPoint("TOPLEFT", 15, -40);
	prdClickThroughCheckbox:SetWidth(30);
	prdClickThroughCheckbox:SetHeight(30);
	_G[prdClickThroughCheckbox:GetName().."Text"]:SetText("Enable PRD Click Through");
	prdClickThroughCheckbox.tooltip = "Allows mouse clicks to pass through the PRD (health/mana bars near the center of your screen)";
	prdClickThroughCheckbox:SetChecked(gsNameplatesConfig.prdClickThrough);
	prdClickThroughCheckbox:SetScript("OnClick", function()
		gsNameplatesConfig.prdClickThrough = prdClickThroughCheckbox:GetChecked();
		C_NamePlate.SetNamePlateSelfClickThrough(gsNameplatesConfig.prdClickThrough);
		print("[gsNP] PRD Clickthtough set to ", C_NamePlate.GetNamePlateSelfClickThrough());
  end)
  

  ---------------------------------------
  
  --[[local numericDisplaySelfLabel = INP_Options:CreateFontString("numericDisplaySelfLabel", "ARTWORK", "GameFontHighlightSmall")
	numericDisplaySelfLabel:SetPoint("TOPLEFT", 15, -150)
	numericDisplaySelfLabel:SetText("Numeric Display (Self)")

	local numericDisplaySelfDropdown = CreateFrame("Frame", "numericDisplaySelfDropdown", INP_Options, "UIDropDownMenuTemplate")
	numericDisplaySelfDropdown:SetPoint("TOPLEFT", 0, -163)
	numericDisplaySelfDropdown.initialize = function(dropdown)
		local sortMode = { "Numeric Value", "Current", "Percentage", "Both", "Hide" }
		for i, mode in next, sortMode do
			local info = UIDropDownMenu_CreateInfo()
			info.text = sortMode[i]
			info.value = sortMode[i]
			info.func = function(self)
				ImprovedNameplatesDB.numbersDisplaySelf = self.value
				UIDropDownMenu_SetSelectedValue(dropdown, self.value)
			end
			UIDropDownMenu_AddButton(info)
		end
		UIDropDownMenu_SetSelectedValue(dropdown, ImprovedNameplatesDB.numbersDisplaySelf)
	end
	numericDisplaySelfDropdown:HookScript("OnShow", numericDisplaySelfDropdown.initialize)
	UIDropDownMenu_SetText(numericDisplaySelfDropdown, ImprovedNameplatesDB.numbersDisplaySelf)
  ]]

	--[[local nameFontSmallSlider = CreateFrame("Slider", "nameFontSmallSlider", INP_Options, "OptionsSliderTemplate")
	nameFontSmallSlider:ClearAllPoints()
	nameFontSmallSlider:SetPoint("TOPLEFT", 15, -275)
	nameFontSmallSlider:SetMinMaxValues(5, 20)
	nameFontSmallSlider:SetValue(ImprovedNameplatesDB.nameFontSmall)
	nameFontSmallSlider:SetValueStep(1)
	nameFontSmallSlider:SetObeyStepOnDrag(true)
	nameFontSmallSlider:SetOrientation("HORIZONTAL")
	_G[nameFontSmallSlider:GetName() .. "Low"]:SetText("5")
	_G[nameFontSmallSlider:GetName() .. "High"]:SetText("20")
	_G[nameFontSmallSlider:GetName() .. "Text"]:SetText("Name Font Size (Small)")
	nameFontSmallSlider:SetScript("OnValueChanged", function() ImprovedNameplatesDB.nameFontSmall = nameFontSmallSlider:GetValue() nameFontSmallLabel:SetText("Selected: " .. nameFontSmallSlider:GetValue()) end)

	local nameFontSmallLabel = INP_Options:CreateFontString("nameFontSmallLabel", "ARTWORK", "GameFontHighlightSmall")
	nameFontSmallLabel:SetPoint("LEFT", nameFontSmallSlider, "RIGHT", 20, 0)
	nameFontSmallLabel:SetText("Selected: " .. ImprovedNameplatesDB.nameFontSmall)]]
end

local function round(number, decimals)
	local power = 10^decimals
	return math.floor(number * power) / power
end

local function formatNumbers(amount)
	local formatted = amount;
	if amount >= 100000 and amount <= 1000000 then
		local k = round(amount / 1000, 2).."K";
		formatted = k;
	elseif amount > 1000000 then
		local m = round(amount / 1000000, 2).."M";
		formatted = m;
	end
	return formatted;
end

--Health Text
hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
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
		frame.health.text:SetFont("FONTS\\ARIALN.TTF", 10, "OUTLINE")
		frame.health.text:SetText(formatNumbers(UnitHealth(frame.unit)) .. " (" .. healthPercentage .. "%)")
		frame.health.text:Show()
	end
end)

--[[hooksecurefunc("CompactUnitFrame_UpdatePower", function(frame)
	--if frame.optionTable.colorNameBySelection and not frame:IsForbidden() then
	if C_NamePlate.GetNamePlateForUnit(frame.unit) == C_NamePlate.GetNamePlateForUnit("player") then	
	local powerPercentage = ceil((UnitPower(frame.displayedUnit) / UnitPowerMax(frame.displayedUnit) * 100));

		if not frame.power then
			frame.power = CreateFrame("Frame", nil, frame) -- Setting up custom power display frames.
			frame.power:SetSize(170,16)
			frame.power.text = frame.power.text or frame.power:CreateFontString(nil, "OVERLAY")
			frame.power.text:SetAllPoints(true)
			frame.power:SetFrameStrata("HIGH")
			frame.power:SetPoint("CENTER", frame.powerBar)
			frame.power.text:SetVertexColor(1, 1, 1)
		end
		frame.power.text:SetFont("FONTS\\ARIALN.TTF", 10, "OUTLINE")
		frame.power.text:SetText(powerPercentage .. "%")
		frame.power.text:Show()
	end
end)]]

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
	if frame.name then
		frame.name:SetFont("FONTS\\ARIALN.TTF", 12, "OUTLINE")
	end
end)

--[[hooksecurefunc("ClassNameplateManaBar_OnUpdate", function(frame)
	local powerPercentage = ceil((UnitPower("player") / UnitPowerMax("player") * 100));
	if not frame.powerNumbers then
		frame.powerNumbers = CreateFrame("Frame", nil, frame) -- Setting up resource display frame.
		frame.powerNumbers:SetSize(170,16)
		frame.powerNumbers.text = frame.powerNumbers.text or frame.powerNumbers:CreateFontString(nil, "OVERLAY")
		frame.powerNumbers.text:SetAllPoints(true)
		frame.powerNumbers:SetFrameStrata("HIGH")
		frame.powerNumbers:SetPoint("CENTER", frame.powerbar)
		frame.powerNumbers.text:SetVertexColor(1, 1, 1)
	end
	frame.powerNumbers.text:SetFont("ARIALN.TTF", 10, "OUTLINE")
	frame.powerNumbers.text:SetText(powerPercentage .. "%")
	frame.powerNumbers.text:Show()
end)]]

hooksecurefunc("ClassNameplateManaBar_OnUpdate", function(frame)
	local powerPercentage = ceil((UnitPower("player") / UnitPowerMax("player") * 100)) -- Calculating a percentage value for primary resource (Rage/Mana/Focus/etc.)

	if not frame.powerNumbers then
		frame.powerNumbers = CreateFrame("Frame", nil, frame) -- Setting up resource display frame.
		frame.powerNumbers:SetSize(170,16)
		frame.powerNumbers.text = frame.powerNumbers.text or frame.powerNumbers:CreateFontString(nil, "OVERLAY")
		frame.powerNumbers.text:SetAllPoints(true)
		frame.powerNumbers:SetFrameStrata("HIGH")
		frame.powerNumbers:SetPoint("CENTER", frame)
		frame.powerNumbers.text:SetFont("FONTS\\ARIALN.TTF", 10, "OUTLINE")
		frame.powerNumbers.text:SetVertexColor(1, 1, 1)
	else
		if InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:GetValue() == "1" then -- If 'Larger Nameplates' option is enabled.
			frame.powerNumbers.text:SetText(powerPercentage .. "%") -- Update resource percentages.
			frame.powerNumbers.text:Show()
		else
			frame.powerNumbers.text:Hide() -- Not enough space on regular-sized nameplates to have text on resource bar alongside health bar text, so we disable that.
		end
	end
end)

local updateCastbar = CreateFrame("Frame")
updateCastbar:RegisterEvent("NAME_PLATE_UNIT_ADDED")
updateCastbar:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
updateCastbar:SetScript("OnEvent", function(self, event, unit)
	local p = C_NamePlate.GetNamePlateForUnit(unit).UnitFrame
	if event == "NAME_PLATE_UNIT_ADDED" then
		--if UnitGUID(unit) ~= UnitGUID("player") then
			--if ImprovedNameplatesDB.showLevels then
				--if InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:GetValue() == "1" then
					--offset(p.name, 15, 6)
					--offset(p.healthBar, -15, 3)
				--elseif InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:GetValue() == "0" then
					--offset(p.name, 9, 6)
					--offset(p.healthBar, -9, 3)
				--end
			--end
		--else -- Thanks Blizzard...
			--local fontName, fontHeight, fontFlags = p.castBar.Text:GetFont()
			p.castBar.Text:SetFont("FONTS\\ARIALN.TTF", 10, "OUTLINE")
		--end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		p.healthBar:ClearAllPoints()
	end
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
    if gsNameplatesConfig == nil then
			print("Initializing gsNameplates...");
			--gsNameplates:initializeSaveFile()
			local prdCT = C_NamePlate.GetNamePlateSelfClickThrough();
			gsNameplatesConfig = {
				prdClickThrough = prdCT,
			}
		end

		--Set CVAR values on load from saved preferences
		C_NamePlate.SetNamePlateSelfClickThrough(gsNameplatesConfig.prdClickThrough);

    loadOptionPanel();
    print("C_NamePlate.GetNamePlateSelfClickThrough: ", C_NamePlate.GetNamePlateSelfClickThrough());
  end
end

-- ................................................................
  -- must be last line:
	gsNameplates:init();
