function Lifebloomer_OnLoad()
	SlashCmdList["LIFEBLOOMER"] = Lifebloomer_SlashCommand;
	SLASH_LIFEBLOOMER1 = "/Lifebloomer";
	SLASH_LIFEBLOOMER2 = "/lifebloomer";
	SLASH_LIFEBLOOMER3 = "/LB";
	SLASH_LIFEBLOOMER4 = "/Lb";
	SLASH_LIFEBLOOMER5 = "/lb";
	LBVplayername = LB_GetUnitName("player");
	loc, LBVClass = UnitClass("player");
	LBVLevel = UnitLevel("player");
	LBVersion = "3.5.3";
	LB_GCD_Time = 1.5;
	LBVFF = 0;
	LB_NameMap = {};
	LB_RefreshNameMapInterval = 5;
	
	--LB_Debugging = true;
	
	if LBVClass == "DRUID" then
		LB_GCD = true;
	else
		LB_GCD = false;
	end
	
	Lifebloomer_SetFrameDefaultProperties(LifebloomerMainFrameUnitFrame1, 1)
	
	ClickCastFrames = ClickCastFrames or {};
	ClickCastFrames[LifebloomerMainFrameUnitFrame1] = true;
	
	LB_Buffer = {};
	--TODO: check how to safely remove both of these
	Lifebloomer_OnLoad_Bindings(); --LBSaved is initialized here for some reason
	Lifebloomer_OnLoad_Handlers();
	
	if LBSaved.AutoGenerateFrames == nil then LBSaved.AutoGenerateFrames = true end
	if LBSaved.SortByRoles == nil then LBSaved.SortByRoles = true end
	if LBSaved.ShowRoleIcons == nil then LBSaved.ShowRoleIcons = true end
	if not LBSaved.RolePriority or not LBSaved.RolePriority[1] then
		LBSaved.RolePriority = {}
		LBSaved.RolePriority[1] = "TANK"
		LBSaved.RolePriority[2] = "HEALER"
		LBSaved.RolePriority[3] = "DAMAGER"
		LBSaved.RolePriority[4] = "NONE"
	end
	
	--We must copy to a temp table because all functions that add, remove and resize use LBV to find out the number of frames.
	--Since at the start there's always only one frame, we must make LBV match that. We can then copy back the actual values.
	if LBV then LBV_t = Lifebloomer_deepcopy(LBV) end
	LBV = {}
	Set_LBV(1,"target","targettargettarget",nil)
	
	Lifebloomer_OnLoad_Dimensions()
	Lifebloomer_OnLoad_Colors()
	
	if LBV_t then
		local n = getn(LBV_t);
		if n>1 then
			for i = 2, n, 1 do
				Lifebloomer_AddFrame(_G["LifebloomerMainFrameUnitFrame"..(i-1)]);
			end
		elseif n==0 then
			Lifebloomer_RemoveFrame(LifebloomerMainFrameUnitFrame1);
		end
		
		LBV = Lifebloomer_deepcopy(LBV_t);
		for i=1, n, 1 do
			Set_LBTarget(nil, LBV[i].Unitid, _G["LifebloomerMainFrameUnitFrame"..i]);
		end
	end
	
	if LBSaved.Vis then
		LifebloomerMainFrame:Show();
	end
	
	if LBSaved.LStat == 1 and LBSaved.Lock then
		LBSaved.Lock = nil;
		Lifebloomer_SlashCommand("lock");
	end
	
	Lifebloomer_SetAttributes(LifebloomerMainFrameUnitFrame1);
	Lifebloomer_SetHandlerAttributes(LifebloomerMainFrameUnitFrame1);
	
	InterfaceOptionsFrame:SetMovable(true);
	InterfaceOptionsFrame:RegisterForDrag("LeftButton");
	InterfaceOptionsFrame:SetScript("OnDragStart", function() InterfaceOptionsFrame:StartMoving(); end);
	InterfaceOptionsFrame:SetScript("OnMouseUp", function() InterfaceOptionsFrame:StopMovingOrSizing(); InterfaceOptionsFrame:SetUserPlaced(false); end);
	InterfaceOptionsFrame:SetScript("OnDragStop", function() InterfaceOptionsFrame:StopMovingOrSizing(); InterfaceOptionsFrame:SetUserPlaced(false); end);
	
	DEFAULT_CHAT_FRAME:AddMessage("Lifebloomer Loaded.  Type |cFFFFFFFF/lifebloomer|r for help.", 0, 1, 0)
end

function Lifebloomer_OnTalentInfoAvailable()
	if LBSaved.AutoGenerateFrames then
		Lifebloomer_AutoGenerateGroupFrames()
	elseif not LBV_t or LBSaved.FTar ~= 1 then
		LB_Add_Remove_Frames(1)
		LBV = {}
		LBV[1] = {}
		Lifebloomer_SetLBVName(_G["LifebloomerMainFrameUnitFrame1"], LBVplayername)
		Set_LBTarget(nil, "player", _G["LifebloomerMainFrameUnitFrame1"])
	end
end

function Lifebloomer_UnitFrame_OnEnter(self)
	if ( SpellIsTargeting() ) then
		SetCursor("CAST_CURSOR");
	end
	local unitid = self:GetAttribute("unit");
	if ( SpellIsTargeting() and not SpellCanTargetUnit(unitid) ) then
		SetCursor("CAST_ERROR_CURSOR");
	end
end

function Set_LBV(i, unitid, target2, realm)
	LBV[i] = {};
	LBV[i].Unitid = unitid;
	LBV[i].Name = LB_GetUnitName(unitid) or unitid;
	LBV[i].Target2 = target2;
	LBV[i].Realm = realm;
end

function Set_LBTarget(tar, unit, parent)
	if unit == 0 then
		unit = Lifebloomer_ID_Unit(tar);
	end
	if unit ~= nil then
		local id = (parent):GetID();
		LBV[id].Unitid = unit;
		if not InCombatLockdown() then
			(parent):SetAttribute("unit", unit);
		end
		if strsub(unit, 1, 6) == "player" or strsub(unit, 1, 6) == "target" or strsub(unit, 1, 5) == "focus" or strsub(unit, 1, 9) == "mouseover" or strsub(unit, 1, 3) == "pet" or strsub(unit, 1, 5) == "party" then
			LBV[id].Target2 = unit.."targettarget";
		else
			LBV[id].Target2 = Lifebloomer_UnitRaidIndex(unit).."targettarget";
		end
	end
end

function Lifebloomer_UnitRaidIndex(unit)
	if UnitInRaid(unit) then
		for i = 1, 40, 1 do
			if UnitIsUnit(unit, "raid"..i) then
				return "raid"..i;
			end
		end
	elseif UnitInParty(unit) then
		for i = 1, 4, 1 do
			if UnitIsUnit(unit, "party"..i) then
				return "party"..i;
			end
		end
	else
		return unit;
	end
end

--Deprecated Function every Resto Druid has Natures cure now 5.0.4
--function Lifebloomer_HasNaturesCure()
	-- "Nature's Cure" is currently the 17th talent listed in tab 3 (Restoration)
--	local name, icon, tier, column, rank = GetTalentInfo (3, 17);
--	return rank == 1;
--end

-- Invoked by the Main Frame whenever a combat log event is received.
function Lifebloomer_CombatLogEvent(self, event, ...)
	local arg1, arg2, hideCaster, arg3, arg4, arg5, arg6, arg7 = ...;
	if not arg7 then
		return
	end
	
	local name = arg7
	local self

	if LBSaved.UseReverseLookup then
		-- Use the LB_NameMap to quickly find the frames associated with the player.
		for id, self in pairs(LB_NameMap[name] or {}) do
			if self and LBV[id].Unitid ~= -1 and LBV[id] and LBV[id].Name == name and self:IsVisible() then
				if arg2 == "SWING_DAMAGE" or arg2 == "RANGE_DAMAGE" or arg2 == "SPELL_DAMAGE" or arg2 == "SPELL_PERIODIC_DAMAGE" or arg2 == "ENVIRONMENTAL" then
					local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19 = ...;
					Lifebloomer_DamageTaken(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19);
				elseif arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_REMOVED" or arg2 == "SPELL_AURA_APPLIED_DOSE" or arg2 == "SPELL_AURA_REMOVED_DOSE" or arg2 == "SPELL_AURA_REFRESH" or arg2 == "SPELL_AURA_STOLEN" or arg2 == "UNIT_DIED" then
					local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 = ...;
					Lifebloomer_Buff_Update(self, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
				end
			end
		end
	else
		-- Search all frames for the ones which are associated with the player.
		for i = 1,getn(LBV) do
			if LBV[i].Name == name then
				self = _G["LifebloomerMainFrameUnitFrame"..i];
				if arg2 == "SWING_DAMAGE" or arg2 == "RANGE_DAMAGE" or arg2 == "SPELL_DAMAGE" or arg2 == "SPELL_PERIODIC_DAMAGE" or arg2 == "ENVIRONMENTAL" then
					local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19 = ...;
					Lifebloomer_DamageTaken(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19);
				elseif arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_REMOVED" or arg2 == "SPELL_AURA_APPLIED_DOSE" or arg2 == "SPELL_AURA_REMOVED_DOSE" or arg2 == "SPELL_AURA_REFRESH" or arg2 == "SPELL_AURA_STOLEN" then
					local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 = ...;
					Lifebloomer_Buff_Update(self, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
				end
			end
		end
	end
end

function Lifebloomer_Buff_Update(self, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, auraType, amount)
	--DEFAULT_CHAT_FRAME:AddMessage(tostring(event)..tostring(sourceName)..tostring(destName)..tostring(spellName)..tostring(amount));
	local unit = LBV[self:GetID()].Unitid;
	if event == "UNIT_DIED" then
		if self.frostBlast or self.slagPot then
			self.frostBlast = false;
			self.slagPot = false;
			self.lockBorderColor = false;
			self:SetBackdropBorderColor(LBColors[6].R, LBColors[6].G, LBColors[6].B, LBColors[6].A);
		end
	elseif event == "LifebloomerTrigger" then
		local now = GetTime();
		local down, up, lag = GetNetStats();
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Lifebloom, "PLAYER");
		if isMine then
			self.LBTimer = expirationTime - now - lag/1000;
			self.LBMax = duration;
			--self.Number:SetText(count);
			self.LBBarGCD:SetPoint("TOP", self.LBBar, "TOPLEFT", (LBDim.w-10)/self.LBMax*LB_GCD_Time, -1);
			self.LBBarGCD:SetPoint("BOTTOM", self.LBBar, "BOTTOMLEFT", (LBDim.w-10)/self.LBMax*LB_GCD_Time, 1);
			self.LBBarGCD:Show();
		else
			self.LBTimer = 0;
			self.Number:SetText("");
			self.LBBarGCD:Hide();
		end
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Rejuvenation, "PLAYER");
		if isMine then
			if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
				-- WoW Classic does not allow tracking others buffs out of the box. So, we need to use a library to do so.
				LibClassicDurations = LibStub("LibClassicDurations")
				durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(unit, 774, "player")
				if expirationTimeNew and durationNew then
					self.RejuvTimer = expirationTimeNew - now - lag/1000;
					self.RejuvMax = durationNew;
				else
					self.RejuvTimer = 0;
				end
			else
				-- Setting variables for Retail.
				self.RejuvTimer = expirationTime - now - lag/1000;
				self.RejuvMax = duration;
			end
		else
			self.RejuvTimer = 0;
		end
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Germination, "PLAYER");
		if isMine then
			self.GerTimer = expirationTime - now - lag/1000;
			self.GerMax = duration;
		else
			self.GerTimer = 0;
		end
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Regrowth, "PLAYER");
		if isMine then
			if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
				-- WoW Classic does not allow tracking others buffs out of the box. So, we need to use a library to do so.
				LibClassicDurations = LibStub("LibClassicDurations")
				durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(unit, 8936, "player")
				if expirationTimeNew and durationNew then
					self.RegroTimer = expirationTimeNew - now - lag/1000;
					self.RegroMax = durationNew;
				else
					self.RegroTimer = 0;
				end
			else
				-- Setting variables for Retail.
				self.RegroTimer = expirationTime - now - lag/1000;
				self.RegroMax = duration;
			end
		else
			self.RegroTimer = 0;
		end
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Wild_Growth, "PLAYER");
		if isMine then
			self.WildTimer = expirationTime - now - lag/1000;
			self.WildMax = duration;
		else
			self.WildTimer = 0;
		end
		--debuff
		if not self.lockBorderColor then
			local corruption = false;
			for i = 1, 40, 1 do
				if UnitExists(unit) then
					local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff(unit, i);
					if name == nil then
						break;
					elseif debuffType == "Poison" then
						corruption = true;
						break;
					elseif debuffType == "Curse" then
						corruption = true;
						break;
					elseif debuffType == "Magic" then
						corruption = true;
						break;
					end
				end
			end
			if corruption then
				-- "curse" color covers poisons, curses, and magic if talented
				self:SetBackdropBorderColor(LBColors[7].R, LBColors[7].G, LBColors[7].B, LBColors[7].A);
			else
				self:SetBackdropBorderColor(LBColors[6].R, LBColors[6].G, LBColors[6].B, LBColors[6].A);
			end
		end
	elseif spellName == LIFEBLOOMER_Lifebloom then
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Lifebloom, "PLAYER");
		if isMine then
			local now = GetTime();
			local down, up, lag = GetNetStats();
			self.LBTimer = expirationTime - now - lag/1000;
			self.LBMax = duration;
			self.Number:SetText(count);
			if event == "SPELL_AURA_APPLIED" then
				_, LB_GCD_Time, _ = GetSpellCooldown(spellName);
			end
			self.LBBarGCD:SetPoint("TOP", self.LBBar, "TOPLEFT", (LBDim.w-10)/self.LBMax*LB_GCD_Time, -1);
			self.LBBarGCD:SetPoint("BOTTOM", self.LBBar, "BOTTOMLEFT", (LBDim.w-10)/self.LBMax*LB_GCD_Time, 1);
			self.LBBarGCD:Show();
		else
			self.LBTimer = 0;
			self.Number:SetText("");
			self.LBBarGCD:Hide();
		end
	elseif spellName == LIFEBLOOMER_Rejuvenation then
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Rejuvenation, "PLAYER");
		if isMine then
			local now = GetTime();
			local down, up, lag = GetNetStats();
			self.RejuvTimer = expirationTime - now - lag/1000;
			self.RejuvMax = duration;
		else
			self.RejuvTimer = 0;
		end
	elseif spellName == LIFEBLOOMER_Germination then
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Germination, "PLAYER");
		if isMine then
			local now = GetTime();
			local down, up, lag = GetNetStats();
			self.GerTimer = expirationTime - now - lag/1000;
			self.GerMax = duration;
		else
			self.GerTimer = 0;
		end
	elseif spellName == LIFEBLOOMER_Regrowth then
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Regrowth, "PLAYER");
		if isMine then
			local now = GetTime();
			local down, up, lag = GetNetStats();
			self.RegroTimer = expirationTime - now - lag/1000;
			self.RegroMax = duration;
		else
			self.RegroTimer = 0;
		end
	elseif spellName == LIFEBLOOMER_Wild_Growth then
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = FindUnitBuffBySpellName(unit, LIFEBLOOMER_Wild_Growth, "PLAYER");
		if isMine then
			local now = GetTime();
			local down, up, lag = GetNetStats();
			self.WildTimer = expirationTime - now - lag/1000;
			self.WildMax = duration;
		else
			self.WildTimer = 0;
		end
	elseif event == "SPELL_AURA_APPLIED" and sourceName == "Kel'Thuzad" and spellName == LIFEBLOOMER_Frost_Blast then
			self.frostBlast = true;
			self.lockBorderColor = true;
			self:SetBackdropBorderColor(LBColors[9].R, LBColors[9].G, LBColors[9].B, LBColors[9].A);
	elseif event == "SPELL_AURA_REMOVED" and sourceName == "Kel'Thuzad" and spellName == LIFEBLOOMER_Frost_Blast then
			self.frostBlast = false;
			self.lockBorderColor = false;
			self:SetBackdropBorderColor(LBColors[6].R, LBColors[6].G, LBColors[6].B, LBColors[6].A);
	elseif event == "SPELL_AURA_APPLIED" and spellName == LIFEBLOOMER_Slag_Pot then
			self.slagPot = true;
			self.lockBorderColor = true;
			self:SetBackdropBorderColor(LBColors[9].R, LBColors[9].G, LBColors[9].B, LBColors[9].A);
	elseif event == "SPELL_AURA_REMOVED" and spellName == LIFEBLOOMER_Slag_Pot then
			self.slagPot = false;
			self.lockBorderColor = false;
			self:SetBackdropBorderColor(LBColors[6].R, LBColors[6].G, LBColors[6].B, LBColors[6].A);
	elseif event == "SPELL_AURA_APPLIED" and spellName == LIFEBLOOMER_Incinerate_Flesh then
			self.incinerateFlesh = true;
			self.lockBorderColor = true;
			self:SetBackdropBorderColor(LBColors[9].R, LBColors[9].G, LBColors[9].B, LBColors[9].A);
	elseif event == "SPELL_AURA_REMOVED" and spellName == LIFEBLOOMER_Incinerate_Flesh then
			self.incinerateFlesh = false;
			self.lockBorderColor = false;
			self:SetBackdropBorderColor(LBColors[6].R, LBColors[6].G, LBColors[6].B, LBColors[6].A);
	elseif event == "SPELL_AURA_APPLIED" and spellName == LIFEBLOOMER_Penetrating_Cold then
			self.penetratingCold = true;
			self.lockBorderColor = true;
			self:SetBackdropBorderColor(LBColors[9].R, LBColors[9].G, LBColors[9].B, LBColors[9].A);
	elseif event == "SPELL_AURA_REMOVED" and spellName == LIFEBLOOMER_Penetrating_Cold then
			self.penetratingCold = false;
			self.lockBorderColor = false;
			self:SetBackdropBorderColor(LBColors[6].R, LBColors[6].G, LBColors[6].B, LBColors[6].A);
	elseif not self.lockBorderColor	then --debuff
		local corruption = false;
		for i = 1, 40, 1 do
			if UnitExists(unit) then
				local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff(unit, i);
				if name == nil then
					break;
				elseif debuffType == "Poison" then
					corruption = true;
					break;
				elseif debuffType == "Curse" then
					corruption = true;
					break;
				elseif debuffType == "Magic" then
					corruption = true;
					break;
				end
			end
		end
		if corruption then
			-- "curse" color covers poisons, curses, and magic if talented
			self:SetBackdropBorderColor(LBColors[7].R, LBColors[7].G, LBColors[7].B, LBColors[7].A);
		else 
			self:SetBackdropBorderColor(LBColors[6].R, LBColors[6].G, LBColors[6].B, LBColors[6].A);
		end
	end
end

function Lifebloomer_UnitHealth_Update(self, elapsed)
	local unit = LBV[self:GetID()].Unitid;
	self.HPBar:SetValue(UnitHealth(unit)/(UnitHealthMax(unit)+0.01));
end

-- Refreshes the LB_NameMap from the LBV table
function Lifebloomer_RefreshNameMap()
	wipe(LB_NameMap);
	for i = 1,getn(LBV) do
		if not LB_NameMap[LBV[i].Name] then
				LB_NameMap[LBV[i].Name] = {};
		end
		LB_NameMap[LBV[i].Name][i] = _G["LifebloomerMainFrameUnitFrame"..i];
	end
end

-- Updates the Name slot in an LBV entry, and also updates the reverse Name
-- lookup table.
function Lifebloomer_SetLBVName(self, name)
	local id = self:GetID();
	--local oldName = LBV[id].Name;

	--[[
	if LB_NameMap[oldName] then
			DEFAULT_CHAT_FRAME:AddMessage("Removing LB_NameMap["..oldName.."]["..id.."]");
			tremove(LB_NameMap[oldName], id);
	end
	]]--

	-- DEFAULT_CHAT_FRAME:AddMessage("Setting LBV["..id.."] = "..name);
	LBV[id].Name = name;

	if not LB_NameMap[name] then
		LB_NameMap[name] = {};
	end

	-- DEFAULT_CHAT_FRAME:AddMessage("Setting LB_NameMap["..name.."]["..id.."] = "..self:GetName());
	LB_NameMap[name][id] = self;
end

function Lifebloomer_ClearLBVName(self, name)
	local id = self:GetID();
	if LB_NameMap[name] then
		tremove(LB_NameMap[name], id);
	end
end

function Lifebloomer_MainFrameOnUpdate(self, elapsed)	
	-- Refresh NameMap every so often
	if not self.TimeSinceLastRefresh then
		self.TimeSinceLastRefresh = 0;
	else
		self.TimeSinceLastRefresh = self.TimeSinceLastRefresh + elapsed;
	end
	if self.TimeSinceLastRefresh > LB_RefreshNameMapInterval then
		if not InCombatLockdown() then
			Lifebloomer_RefreshNameMap();
		end
		self.TimeSinceLastRefresh = 0;
	end
end

-- Ordered by return index of GetRaidTargetIndex
Lifebloomer_RaidIcons = { [1] = "Star"
			, [2] = "Circle"
			, [3] = "Diamond"
			, [4] = "Triangle"
			, [5] = "Moon"
			, [6] = "Square"
			, [7] = "X"
			, [8] = "Skull" }

function Lifebloomer_HideRaidIcons(self)
	-- Hide all raid icon indicators
	for _, icon in pairs(Lifebloomer_RaidIcons) do
		_G[self:GetName().."HPBarIcon"..icon]:Hide();
	end
end

function Lifebloomer_ShowRaidIcon(self)
	if self.raidIcon and not LBSaved.HideRaidIcons then
		-- Show the raid icon indicator for index: ri
		_G[self:GetName().."HPBarIcon"..Lifebloomer_RaidIcons[self.raidIcon]]:Show();
		_G[self:GetName().."HPBarIcon"..Lifebloomer_RaidIcons[self.raidIcon]]:SetAlpha(LBSaved.RaidIconAlpha);
	end
end

function Lifebloomer_RefreshAllRaidIcons()
	for i=1, getn(LBV), 1 do
		Lifebloomer_HideRaidIcons(_G["LifebloomerMainFrameUnitFrame"..i]);
		Lifebloomer_ShowRaidIcon(_G["LifebloomerMainFrameUnitFrame"..i]);
	end
end

function Lifebloomer_UnitFrame_Update_RaidIcons(self)
	local ri = nil;
	if UnitExists(LBV[self:GetID()].Unitid) then
		ri = GetRaidTargetIndex(LBV[self:GetID()].Unitid);
	end
	if not ri then
		if self.raidIcon then 
			-- No raid icon present
			Lifebloomer_HideRaidIcons(self);
			self.raidIcon = nil;
		end
	else
		if self.raidIcon and self.raidIcon ~= ri then
			-- Currently recorded as a different icon
			Lifebloomer_HideRaidIcons(self);
			self.raidIcon = nil;
		end
		if not self.raidIcon then
			-- This raid icon was not recorded yet
			self.raidIcon = ri;
			-- Flash the HP bar to indicate raid icon set
			self.HPBarColor = 12;
			self.flashingHPBar = true;
			Lifebloomer_ShowRaidIcon(self);
		end
	end
end

function Lifebloomer_UnitFrame_Update(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if self.LBTimer > 0 then
		self.LBTimer = self.LBTimer - elapsed;
	end
	if self.RejuvTimer > 0 then
		self.RejuvTimer = self.RejuvTimer - elapsed;
	end
	if self.GerTimer > 0 then
		self.GerTimer = self.GerTimer - elapsed;
	end
	if self.RegroTimer > 0 then
		self.RegroTimer = self.RegroTimer - elapsed;
	end
	if self.WildTimer > 0 then
		self.WildTimer = self.WildTimer - elapsed;
	end
	if self.TimeSinceLastUpdate > 0.05 then
		while self.TimeSinceLastUpdate > 0.05 do
			self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - 0.05;
			self.TimeCount = self.TimeCount + 1;
			if self.TimeCount >= 10 then
				self.prevDTPS = self.DTPS
				if LBSaved.DTPS == 1 then
					Lifebloomer_DamageTakenUpdate1(self);
				elseif LBSaved.DTPS == 2 then
					Lifebloomer_DamageTakenUpdate2(self);
				end
				if LBSaved.FlashDmg and 
					self.DTPS > 0 and self.prevDTPS == 0 then
					self.HPBarColor = 12
					self.flashingHPBar = true
				elseif self.flashingHPBar then
					self.HPBarColor = 2
					self.flashingHPBar = false
				end
				self.TimeCount = self.TimeCount - 10;
			end
		end
		local id = self:GetID();
		local down, up, lag = GetNetStats();
		local unit = LBV[id].Unitid;
		local name= LB_GetUnitName(unit);
		if unit == name then
			LBV[id].Target2 = Lifebloomer_UnitRaidIndex(unit).."targettarget";
		end
		
		if name == self.Name:GetText() then
			Lifebloomer_Buff_Update(self, "LifebloomerTrigger");
		elseif name then
			self.Name:SetText(name);
			-- Now handled by SetLBVName:
			-- LBV[self:GetID()].Name = name;
			-- Update reverse lookup name-map if unit has changed name
			Lifebloomer_SetLBVName(self, name);
			Lifebloomer_Buff_Update(self, "LifebloomerTrigger");
		else
			self.Name:SetText(unit);
		end
		
		-- Using Regrowth to perform the range check as it's currently a spell available to all specs.
		if IsSpellInRange(LIFEBLOOMER_Regrowth, unit) == 1 then
			local i = self.HPBarColor or 2
			if LBSaved.ClassColorsEnabled and GetUnitClassColor(unit) then
				local unitClassColor = GetUnitClassColor(unit)
				self.HPBar:SetStatusBarColor(unitClassColor.r, unitClassColor.g, unitClassColor.b, LBColors[i].A)
			else
				self.HPBar:SetStatusBarColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A)
			end
			self.Name:SetTextColor(LBColors[10].R, LBColors[10].G, LBColors[10].B, LBColors[10].A);
		else
			local i = self.HPBarColor or 2
			if LBSaved.DimOOR then
				if LBSaved.ClassColorsEnabled and GetUnitClassColor(unit) then
					local unitClassColor = GetUnitClassColor(unit)
					self.HPBar:SetStatusBarColor(unitClassColor.r, unitClassColor.g, unitClassColor.b, LBColors[i].A / 2)
				else
					self.HPBar:SetStatusBarColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A / 2)
				end
			end
			self.Name:SetTextColor(LBColors[11].R, LBColors[11].G, LBColors[11].B, LBColors[11].A);
		end
		
		self.LBBar:SetValue(self.LBTimer/self.LBMax);
		self.RejuvBar:SetValue(self.RejuvTimer/self.RejuvMax);
		self.GerBar:SetValue(self.GerTimer/self.GerMax);
		self.RegroBar:SetValue(self.RegroTimer/self.RegroMax);
		self.WildBar:SetValue(self.WildTimer/self.WildMax);
		if self.LBTimer <=0 then
			self.Timer:SetText("");
			self.Number:SetText("");
			self.LBBarGCD:Hide();
		else
			self.Timer:SetText(floor(self.LBTimer*10)/10);
			if self.LBTimer + lag/1000 < 1 then
				self.LBBar:SetStatusBarColor(.75, 0, 0, LBColors[3].A);
			elseif self.LBTimer < 1 then
				self.LBBar:SetStatusBarColor(.5, 0, .5, LBColors[3].A);
			else self.LBBar:SetStatusBarColor(LBColors[3].R, LBColors[3].G, LBColors[3].B, LBColors[3].A);
			end
		end
		
		-- local i = 14;
		-- self.Number:SetTextColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
		local i = 15;
		self.Timer:SetTextColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);

		Lifebloomer_UnitFrame_Update_RaidIcons(self);
	end
end

-- Retrieves the appropriate color for a given class as defined by the default UI
function GetUnitClassColor(unit)
	local unitClass, unitClassFileName = UnitClass(unit)
	return RAID_CLASS_COLORS[unitClassFileName]
end

function Lifebloomer_GCDUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	while self.TimeSinceLastUpdate > 0.05 do
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - 0.05;
		if LB_GCD then
			-- Using Regrowth to perform the GCD check as it's currently a spell with no cooldown available to all specs.
			local start, duration, e = GetSpellCooldown(LIFEBLOOMER_Regrowth);
			local seconds = GetTime();
			self:SetValue((duration-(seconds-start))/duration);
		end
	end
end

function Lifebloomer_OnEvent(self, event, arg1)
	if event == "PLAYER_TARGET_CHANGED" then
		if self:GetAttribute("unit") == "target" then
			self.Dmg = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			self.DTPS = 0;
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if self:GetAttribute("unit") == "focus" then
			self.Dmg = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			self.DTPS = 0;
		end
	end
end

function Lifebloomer_ID_Unit(unit)
	if not UnitExists(unit) then
		return "target";
	elseif UnitIsUnit(unit, "focus") then
		return "focus";
	elseif UnitIsUnit(unit, "player") then
		return "player";
	elseif UnitIsUnit(unit, "pet") then
		return "pet";
	elseif UnitInRaid(unit) or UnitInParty(unit)then
		local name = LB_GetUnitName(unit);
		return name;
	elseif UnitPlayerOrPetInRaid(unit) then
		for i=1, 40, 1 do
			if UnitIsUnit(unit, "raidpet"..i) then
				return "raidpet"..i;
			end
		end
	elseif UnitPlayerOrPetInParty(unit) then
		for i=1, 4, 1 do
			if UnitIsUnit(unit, "partypet"..i) then
				return "partypet"..i;
			end
		end
	else return "target" end
end

function Lifebloomer_AddFrame(self)
	local top = LifebloomerMainFrame:GetTop();
	local left = LifebloomerMainFrame:GetLeft();
	
	local n = self:GetParent():GetID() + 1;
	local nt = getn(LBV) + 1;
	if LBVFF == 0 then
		local NewFrame = CreateFrame("Button", "LifebloomerMainFrameUnitFrame"..nt, LifebloomerMainFrame, "LifebloomerUnitTemplate");
		NewFrame:SetID(nt);
		
		Lifebloomer_Adjust_FrameS(nt)
		
		-- -- If frames-per-column is non-zero then use modular arithmetic to wrap frames into columns.
		-- if LBDim.fpc > 0 and nt > 1 and (nt % LBDim.fpc == 1 or LBDim.fpc == 1) then
			-- NewFrame:SetPoint("LEFT", "LifebloomerMainFrameUnitFrame"..(nt-LBDim.fpc), "RIGHT", LBDim.hs, 0);
		-- else
			-- NewFrame:SetPoint("TOP", "LifebloomerMainFrameUnitFrame"..(nt-1), "BOTTOM", 0, -LBDim.s);
		-- end
		
		Lifebloomer_SetFrameDefaultProperties(NewFrame, nt)
		
		Lifebloomer_SetColor(nt)
		Lifebloomer_Adjust_AllDimensions_SingleFrame(nt)
		
		ClickCastFrames[NewFrame] = true;
		Lifebloomer_SetAttributes(NewFrame);
		Lifebloomer_SetHandlerAttributes(NewFrame);
		if Click2Cast then
			Click2Cast:RegisterFrame(NewFrame);
		end
	else
		local frame = _G["LifebloomerMainFrameUnitFrame"..nt];
		frame:Show();
		frame:SetAttribute("unit", "target");
		if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
			-- The concept of a "focus" target is not present in Classic WoW. We will only register for retail.
			frame:RegisterEvent("PLAYER_FOCUS_CHANGED");
		end
		frame:RegisterEvent("PLAYER_TARGET_CHANGED");
		-- Now delegated by MainFrame:
		-- frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		LBVFF = LBVFF - 1;
	end
	
	tinsert(LBV, n, {});
	Set_LBV(n,"target",nil,nil)
	
	for i=n, nt, 1 do
		-- Lifebloomer_SetLBVName(_G["LifebloomerMainFrameUnitFrame"..i], LBV[i].Name);
		Set_LBTarget(nil, LBV[i].Unitid, _G["LifebloomerMainFrameUnitFrame"..i]);
	end
	
	if nt > LBDim.fpc then
		Lifebloomer_AdjustW()
	end
	Lifebloomer_Set_MainFrameW()
	Lifebloomer_Set_MainFrameH()
	
	if LBSaved.Lock then
		_G["LifebloomerMainFrameUnitFrame"..nt.."TargetButton"]:Hide();
		_G["LifebloomerMainFrameUnitFrame"..nt.."ReduceButton"]:Hide();
		_G["LifebloomerMainFrameUnitFrame"..nt.."IncreaseButton"]:Hide();
	else
		_G["LifebloomerMainFrameUnitFrame"..nt.."TargetButton"]:Show();
		_G["LifebloomerMainFrameUnitFrame"..nt.."ReduceButton"]:Show();
		_G["LifebloomerMainFrameUnitFrame"..nt.."IncreaseButton"]:Show();
	end
	
	LifebloomerMainFrame:ClearAllPoints();
	LifebloomerMainFrame:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", left, top);
	
	Lifebloomer_RefreshNameMap();
end

function Lifebloomer_RemoveFrame(parent)
	local top = LifebloomerMainFrame:GetTop();
	local left = LifebloomerMainFrame:GetLeft();
	
	local nt = getn(LBV);
	
	if nt == 0 then
		LifebloomerMainFrame:Hide();
		DEFAULT_CHAT_FRAME:AddMessage(">> |cFFFFFFFFl|rife|cFFFFFFFFb|rloomer Hidden.", 0, 1, 0);
		return
	end
	local n1 = (parent):GetID();
	Lifebloomer_ClearLBVName(_G["LifebloomerMainFrameUnitFrame"..n1], LBV[n1].Name);
	tremove(LBV, n1);
	for i=n1, nt-1, 1 do
		-- Lifebloomer_SetLBVName(_G["LifebloomerMainFrameUnitFrame"..i], LBV[i].Name);
		Set_LBTarget(nil, LBV[i].Unitid, _G["LifebloomerMainFrameUnitFrame"..i]);
	end
	
	_G["LifebloomerMainFrameUnitFrame"..nt]:Hide();
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		-- The concept of a "focus" target is not present in Classic WoW. We will only unregister for retail.
		_G["LifebloomerMainFrameUnitFrame"..nt]:UnregisterEvent("PLAYER_FOCUS_CHANGED");
	end
	_G["LifebloomerMainFrameUnitFrame"..nt]:UnregisterEvent("PLAYER_TARGET_CHANGED");
	_G["LifebloomerMainFrameUnitFrame"..nt]:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	LBVFF = LBVFF + 1;
	
	if nt-1 == LBDim.fpc then
		Lifebloomer_AdjustW();
	end
	Lifebloomer_Set_MainFrameW()
	Lifebloomer_Set_MainFrameH()
	
	LifebloomerMainFrame:ClearAllPoints();
	LifebloomerMainFrame:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", left, top);
	-- LifebloomerMainFrame:SetHeight(LifebloomerMainFrame:GetHeight() - (LBDim.h + LBDim.s));
	
	Lifebloomer_RefreshNameMap();
end

function Lifebloomer_SetFrameDefaultProperties(Frame, nt)
	Frame.Number = _G["LifebloomerMainFrameUnitFrame"..nt.."LBBarNumber"];
	Frame.Timer = _G["LifebloomerMainFrameUnitFrame"..nt.."LBBarTimer"];
	Frame.LBBar = _G["LifebloomerMainFrameUnitFrame"..nt.."LBBar"];
	Frame.LBBarGCD = _G["LifebloomerMainFrameUnitFrame"..nt.."LBBarGCD"];
	Frame.RejuvBar = _G["LifebloomerMainFrameUnitFrame"..nt.."RejuvBar"];
	Frame.GerBar = _G["LifebloomerMainFrameUnitFrame"..nt.."GerBar"];
	Frame.RegroBar = _G["LifebloomerMainFrameUnitFrame"..nt.."RegroBar"];
	Frame.WildBar = _G["LifebloomerMainFrameUnitFrame"..nt.."WildBar"];
	Frame.HPBar = _G["LifebloomerMainFrameUnitFrame"..nt.."HPBar"];
	Frame.Name = _G["LifebloomerMainFrameUnitFrame"..nt.."HPBarName"];
	Frame.DTPSlabel = _G["LifebloomerMainFrameUnitFrame"..nt.."HPBarDTPS"];
	Frame.DTPS = 0;
	Frame.Damage = 0;
	Frame.TimeCount = 0;
	Frame.Dmg = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	Frame.LBTimer = 0;
	Frame.RejuvTimer = 0;
	Frame.GerTimer = 0;
	Frame.RegroTimer = 0;
	Frame.WildTimer = 0;
	Frame.LBMax = 15;
	Frame.RejuvMax = 18;
	Frame.GerMax = 21;
	Frame.RegroMax = 12;
	Frame.WildMax = 7;
end

function Lifebloomer_DefaultNew()
	Lifebloomer_OptionsAppearance_Preset(LBColorsDefault);
	Lifebloomer_OptionsAppearance_Accept();
	
	Lifebloomer_OptionsDimensions_Preset(LBDimDefault);
	Lifebloomer_OptionsDimensions_Accept();
end

function Lifebloomer_DefaultClassic()
	Lifebloomer_OptionsAppearance_Preset(LBColorsDefaultClassic);
	Lifebloomer_OptionsAppearance_Accept();
	
	Lifebloomer_OptionsDimensions_Preset(LBDimDefaultClassic);
	Lifebloomer_OptionsDimensions_Accept();
end

function Lifebloomer_GenerateRaidFrames()
	Lifebloomer_GenerateGroupFrames("raid")
end

function Lifebloomer_GeneratePartyFrames()
	Lifebloomer_GenerateGroupFrames("party")
end

function Lifebloomer_AutoGenerateGroupFrames()
	if IsInRaid() then
		Lifebloomer_GenerateRaidFrames()
	else
		Lifebloomer_GeneratePartyFrames()
	end
end

function Lifebloomer_GenerateGroupFrames(groupType)
	local numFrames, lastIndex, unitId, name, role;
	local groupByRoles = {}
	
	if groupType == "party" then
		lastIndex = GetNumSubgroupMembers();
		numFrames = lastIndex + 1; --add 1 because GetNumSubgroupMembers does not include the player
	else
		lastIndex = GetNumGroupMembers();
		numFrames = lastIndex;
		if numFrames == 0 then numFrames = 1 end
	end
	
	LB_Add_Remove_Frames(numFrames)
	
	--Set Player frame
	unitId = "player"; frameIndex = 1; name = LBVplayername;
	LBV[frameIndex] = {}
	Lifebloomer_SetLBVName(_G["LifebloomerMainFrameUnitFrame"..frameIndex], name)
	Set_LBTarget(nil, unitId, _G["LifebloomerMainFrameUnitFrame"..frameIndex])
	role = LB_GetUnitRole(unitId)
	Lifebloomer_SetLBRole(role, _G["LifebloomerMainFrameUnitFrame"..frameIndex.."HPBarIconRole"])
	
	--Group Party/Raid members by Role
	for i = 1, lastIndex do
		unitId = groupType..i
		name = GetUnitName(unitId)
		
		if name ~= LBVplayername then
		
			if LBSaved.SortByRoles then
				role = LB_GetUnitRole(unitId)
			else
				role = "NONE"
			end
			
			if LB_Debugging then DEFAULT_CHAT_FRAME:AddMessage("groupByRoles["..role.."]["..unitId.."] = "..name) end
			
			if not groupByRoles[role] then groupByRoles[role] = {} end
			groupByRoles[role][unitId] = name
			--name,_,_,_,_,_,_,_,_,raidRole = GetRaidRosterInfo(i)
			--raidRole == "MAINTANK" or raidRole == "MAINASSIST"
		end
	end
	
	--Distribute Role groups by Frames
	local frameIndex = 2; --starts at 2 because frame 1 is reserved for the player
	for i = 1, getn(LBSaved.RolePriority) do
		role = LBSaved.RolePriority[i]
		
		if groupByRoles[role] then
			for unitId,name in pairs(groupByRoles[role]) do
				if LB_Debugging then DEFAULT_CHAT_FRAME:AddMessage("unitId"..unitId.." name"..name.." frameIndex"..frameIndex) end
				
				Lifebloomer_SetLBVName(_G["LifebloomerMainFrameUnitFrame"..frameIndex], name)
				Set_LBTarget(nil, unitId, _G["LifebloomerMainFrameUnitFrame"..frameIndex])
				Lifebloomer_SetLBRole(role, _G["LifebloomerMainFrameUnitFrame"..frameIndex.."HPBarIconRole"])
				
				frameIndex = frameIndex + 1;
			end
		end
		
	end
	Lifebloomer_RefreshNameMap();
end

function Lifebloomer_SetLBRole(role, roleIcon)
	if LBSaved.ShowRoleIcons and role ~= "NONE" then
		roleIcon:SetTexCoord(GetTexCoordsForRole(role)) -- GetTexCoordsForRole(role) cray blizz function that returns tex coords and shit
		roleIcon:Show()
	else
		roleIcon:Hide()
	end
end

function LB_Add_Remove_Frames(np)
	local n = getn(LBV);
	if n > np then
		for i = 1, n - np, 1 do
			Lifebloomer_RemoveFrame(LifebloomerMainFrameUnitFrame1);
		end
	elseif n < np then
		for i = 1, np - n, 1 do
			Lifebloomer_AddFrame(LifebloomerMainFrameUnitFrame1);
		end
	end
end

function LB_GetUnitRole(unitID)
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		-- Wow Classic does not support Roles, resulting in UnitGroupRolesAssigned() throwing an error when called.
		return "NONE"
	end

	local role = UnitGroupRolesAssigned(unitID)
	if not role or role == "NONE" then
		local specId;
		if unitID == "player" then
			specId = GetSpecializationInfo(GetSpecialization())
		else
			specId = GetInspectSpecialization(unitID)
		end
		role = GetSpecializationRoleByID(specId)
	end
	return role or "NONE"
end

function Lifebloomer_SlashCommand(cmd)
	if (cmd == "default new" or cmd == "dn") then	--Blizzard prevents addon changes while in combat
		if InCombatLockdown() then					--InCombatLockdown() - blizzard function to check if you are in combat
			DEFAULT_CHAT_FRAME:AddMessage("Cannot make changes while in combat", 0, 1, 0);
		else
			DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFd|refault |cFFFFFFFFn|rew |cFFFFFFFF - Reset All Settings to the New Default Values|r", 0, 1, 0);
			Lifebloomer_DefaultNew();
		end
	elseif (cmd == "default classic" or cmd == "dc") then
		if InCombatLockdown() then
			DEFAULT_CHAT_FRAME:AddMessage("Cannot make changes while in combat", 0, 1, 0);
		else
			DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFd|refault |cFFFFFFFFc|rlassic |cFFFFFFFF - Reset All Settings to the Classic Default Values|r", 0, 1, 0);
			Lifebloomer_DefaultClassic();
		end
	elseif (cmd == "reset" or cmd == "r") then
		if InCombatLockdown() then
			DEFAULT_CHAT_FRAME:AddMessage("Cannot make changes while in combat", 0, 1, 0);
		else
			DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFr|reset |cFFFFFFFF - Reset|r", 0, 1, 0);
			LifebloomerMainFrame:ClearAllPoints();
			LifebloomerMainFrame:SetPoint("TOP", "UIParent", "CENTER");
		end
	elseif (cmd == "show" or cmd == "s") then
		if InCombatLockdown() then
			DEFAULT_CHAT_FRAME:AddMessage("Cannot make changes while in combat", 0, 1, 0);
		else
			DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFs|rhow |cFFFFFFFF - Show|r", 0, 1, 0);
			LifebloomerMainFrame:Show();
		end
	elseif (cmd == "hide" or cmd == "h") then
		if InCombatLockdown() then
			DEFAULT_CHAT_FRAME:AddMessage("Cannot make changes while in combat", 0, 1, 0);
		else
			DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFh|ride |cFFFFFFFF - Hide|r", 0, 1, 0);
			LifebloomerMainFrame:Hide();
		end
	elseif cmd == "lock" or cmd == "l" then
		DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFl|rock |cFFFFFFFF - Lock|r", 0, 1, 0);
		if LBSaved.Lock then
			LBSaved.Lock = nil;
			if not InCombatLockdown() then
				LifebloomerMainFrameText:Show();
				LifebloomerMainFrame:EnableMouse(true);
				LifebloomerMainFrameReduceButton:Show();
				LifebloomerMainFrameIncreaseButton:Show();
				for i=1, #(LBV), 1 do
					_G["LifebloomerMainFrameUnitFrame"..i.."TargetButton"]:Show();
					_G["LifebloomerMainFrameUnitFrame"..i.."ReduceButton"]:Show();
					_G["LifebloomerMainFrameUnitFrame"..i.."IncreaseButton"]:Show();
				end
			end
		else
			LBSaved.Lock = 1;
			if not InCombatLockdown() then
				LifebloomerMainFrameText:Hide();
				LifebloomerMainFrame:EnableMouse(false);
				LifebloomerMainFrameReduceButton:Hide();
				LifebloomerMainFrameIncreaseButton:Hide();
				for i=1, getn(LBV), 1 do
					_G["LifebloomerMainFrameUnitFrame"..i.."TargetButton"]:Hide();
					_G["LifebloomerMainFrameUnitFrame"..i.."ReduceButton"]:Hide();
					_G["LifebloomerMainFrameUnitFrame"..i.."IncreaseButton"]:Hide();
				end
			end
		end
	elseif (cmd == "party" or cmd == "p") then
		if InCombatLockdown() then
			DEFAULT_CHAT_FRAME:AddMessage("Cannot make changes while in combat", 0, 1, 0);
		else
			DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFp|rarty |cFFFFFFFF - Generate Party Frames|r", 0, 1, 0);
			Lifebloomer_GeneratePartyFrames();
		end
	elseif (cmd == "raid" or cmd == "ra") then
		if InCombatLockdown() then
			DEFAULT_CHAT_FRAME:AddMessage("Cannot make changes while in combat", 0, 1, 0);
		else
			DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFra|rid |cFFFFFFFF - Generate Raid Frames|r", 0, 1, 0);
			Lifebloomer_GenerateRaidFrames();
		end
	elseif (cmd == "smartraid" or cmd == "sr") then
		if InCombatLockdown() then
			DEFAULT_CHAT_FRAME:AddMessage("Cannot make changes while in combat", 0, 1, 0);
		else
			DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFs|rmart|cFFFFFFFFr|raid|cFFFFFFFF - Generate Raid Frames Without Disturbing Player-Set Frames|r", 0, 1, 0);
			local np = GetNumGroupMembers();
			if np > 0 then
				local n = getn(LBV);
				local manualSet = {};
				local jSet = {};
				local dups = 0;

				-- find those names which were setup manually by the player
				for j = 1, n, 1 do
					if LBV[j].Unitid:sub(1,4) ~= "raid" and LBV[j].Unitid ~= "target" then
						if manualSet[LBV[j].Name] then
							-- Already seen once, must be a duplicate
							dups = dups + 1;
						end
						-- assume it was set by the player
						manualSet[LBV[j].Name] = {
								["j"] = j,
								["Unitid"] = LBV[j].Unitid,
						};
						jSet[j] = { 
								["Unitid"] = LBV[j].Unitid,
								["Name"] = LBV[j].Name,
						};
					end
				end

				if LB_Debugging then
						DEFAULT_CHAT_FRAME:AddMessage("dups = "..tostring(dups))
				end

				local nframes = np + dups
				LB_Add_Remove_Frames(nframes)
				
				if LB_Debugging then
					for j, info in pairs(jSet) do
						DEFAULT_CHAT_FRAME:AddMessage("j = "..tostring(j).." "..info["Unitid"].." "..info["Name"])
					end
				end
					
				local j = 1;
				n = getn(LBV);
				for i = 1, np, 1 do
					local name = LB_CanonName(GetRaidRosterInfo(i));
					if name and not manualSet[name] then
						-- Only set frames for those not manually set
						local id = "raid"..i;
						-- Find a j which is either a "raid<n>" or "target" Unitid
						--while LBV[j].Unitid:sub(1,4) ~= "raid" and LBV[j].Unitid ~= "target" do
						while jSet[j] do
							-- DEFAULT_CHAT_FRAME:AddMessage("Using jSet["..tostring(j).."]");
							LBV[j].Unitid = jSet[j].Unitid;
							-- LBV[j].Name = jSet[j].Name;
							Lifebloomer_SetLBVName(_G["LifebloomerMainFrameUnitFrame"..j], jSet[j].Name);
							Set_LBTarget(nil, jSet[j].Unitid, _G["LifebloomerMainFrameUnitFrame"..j]);
							j = j + 1;
						end
						if j > n then
							if LB_Debugging then
								DEFAULT_CHAT_FRAME:AddMessage("Not enough frames", 0, 1, 0);
							end
							break;
						end
						LBV[j].Unitid = id;
						-- LBV[j].Name = LB_GetUnitName(id);
						Lifebloomer_SetLBVName(_G["LifebloomerMainFrameUnitFrame"..j], LB_GetUnitName(id));
						Set_LBTarget(nil, id, _G["LifebloomerMainFrameUnitFrame"..j]);
						j = j + 1;
					end
				end
				-- Seems to work, but, may have to check jSet some more, now ...
				Lifebloomer_RefreshNameMap();
			end
		end
	elseif (cmd == "autogeneration" or cmd == "ag") then		
		LBSaved.AutoGenerateFrames = not LBSaved.AutoGenerateFrames;		
		DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFa|ruto|cFFFFFFFFg|reneration |cFFFFFFFF - Toggle Autogeration of Frames|r", 0, 1, 0);
		DEFAULT_CHAT_FRAME:AddMessage("AutoGeneration of frames " .. (LBSaved.AutoGenerateFrames and "|cFFFFFFFFenabled|r" or "|cFFFF0000disabled|r"), 0, 1, 0);
	else
		Lifebloomer_CommandList();
	end
end

function Lifebloomer_CommandList()
	DEFAULT_CHAT_FRAME:AddMessage("Commands:", 1, 1, 1);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFF - Command List|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFs|rhow |cFFFFFFFF - Show|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFh|ride |cFFFFFFFF - Hide|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFr|reset |cFFFFFFFF - Reset|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFl|rock |cFFFFFFFF - Lock|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFp|rarty |cFFFFFFFF - Generate Party Frames|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFra|rid |cFFFFFFFF - Generate Raid Frames|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFs|rmart|cFFFFFFFFr|raid|cFFFFFFFF - Generate Raid Frames Without Disturbing Player-Set Frames|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFd|refault |cFFFFFFFFn|rew |cFFFFFFFF - Reset All Settings to the New Default Values|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFd|refault |cFFFFFFFFc|rlassic |cFFFFFFFF - Reset All Settings to the Classic Default Values|r", 0, 1, 0);
	DEFAULT_CHAT_FRAME:AddMessage("/|cFFFFFFFFl|rife|cFFFFFFFFb|rloomer |cFFFFFFFFa|ruto|cFFFFFFFFg|reneration |cFFFFFFFF - Toggle Autogeration of Frames|r", 0, 1, 0);
end

function Lifebloomer_DamageTaken(self, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, amount, school, resisted, blocked, absorbed, critical, glancing, crushing)
	if event == "SWING_DAMAGE" then
		self.Damage = self.Damage + spellId;
	elseif event == "ENVIRONMENTAL_DAMAGE" then
		self.Damage = self.Damage + spellName;
	else
		self.Damage = self.Damage + amount;
	end
end

function Lifebloomer_DamageTakenUpdate1(self)
	self.DTPS = self.DTPS * 0.8 + self.Damage * 0.4;
	self.Damage = 0;
	self.DTPSlabel:SetText(tostring(floor(self.DTPS)));
	if UnitIsUnit(LBV[self:GetID()].Unitid, LBV[self:GetID()].Target2) then
		self.DTPSlabel:SetTextColor(LBColors[12].R, LBColors[12].G, LBColors[12].B, LBColors[12].A);
	else self.DTPSlabel:SetTextColor(LBColors[13].R, LBColors[13].G, LBColors[13].B, LBColors[13].A); end
end

function Lifebloomer_DamageTakenUpdate2(self)
	tinsert(self.Dmg, 1, self.Damage);
	tremove(self.Dmg, 13);
	self.Damage = 0;
	self.DTPS = ( self.Dmg[1] + self.Dmg[2] + self.Dmg[3] + self.Dmg[4] + self.Dmg[5] + self.Dmg[6] + self.Dmg[7] + self.Dmg[8] + self.Dmg[9] + self.Dmg[10] + self.Dmg[11] + self.Dmg[12] ) / 6;
	self.DTPSlabel:SetText(tostring(floor(self.DTPS)));
	if UnitIsUnit(LBV[self:GetID()].Unitid, LBV[self:GetID()].Target2) then
		self.DTPSlabel:SetTextColor(LBColors[12].R, LBColors[12].G, LBColors[12].B, LBColors[12].A);
	else self.DTPSlabel:SetTextColor(LBColors[13].R, LBColors[13].G, LBColors[13].B, LBColors[13].A); end
end

function Lifebloomer_deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function Lifebloomer_UIDropdownMenu_OnLoad(self)
	local cb_init_fn = function()
		local info;
		info = {};
		info.text = LIFEBLOOMER_None;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 1, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Target;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 2, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Lifebloom;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 3, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Rejuvenation;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 4, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Regrowth;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 5, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Healing_Touch;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 6, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Nourish;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 7, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Swiftmend;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 8, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Wild_Growth;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 9, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Remove_Curse;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 10, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Rebirth;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 11, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Mark_of_the_Wild;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 12, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Thorns;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 13, 0); end
		UIDropDownMenu_AddButton(info);
		info = {};
		info.text = LIFEBLOOMER_Natures_Swiftness;
		info.func = function() UIDropDownMenu_SetSelectedID(self, 14, 0); end
		UIDropDownMenu_AddButton(info);
	end
	UIDropDownMenu_Initialize(self, cb_init_fn);
end

function LB_GetUnitName(unit)
	local n = GetUnitName(unit, true)
	if type(n)=="string" then
		return LB_CanonName(n)
	else
		return n
	end
	return n
end

function LB_CanonName(n)
	return string.gsub(n, "%s?-%s?", "-");
end

-- Used to check if a given buff is currently applied to a unit. The UnitBuff API used to support lookup by spell name,
-- but that functionality was removed as of patch 8.0.1. This function mimics that original functionality.
function FindUnitBuffBySpellName(unitId, spellName, filter)
	for i=1,40 do
		local name, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(unitId, i, filter);
		if name == spellName then
			return name, icon, count, debuffType, duration, expirationTime, isMine, isStealable;
		end
	end
end

-- vim: sw=8 sts=8 noexpandtab 
