function Lifebloomer_OnLoad_Colors()
	if not LBSaved.RaidIconAlpha then
		LBSaved.RaidIconAlpha = 0.75
	end

	if LBColors then
		Lifebloomer_SetColor(1);
	else
		LBColors = Lifebloomer_deepcopy(LBColorsDefault);
	end
	
	LB_Buffer.LBColors = {};
	LB_Buffer.LBColors = Lifebloomer_deepcopy(LBColors);
	LB_Buffer.Debuff = 0;		-- 0: none, 1: curse, 2: poison, 3: both
	LB_Buffer.Range = 1;		-- 0: out, 1: in
	LB_Buffer.Agro = 0;			-- 0: no, 1: yes
	Lifebloomer_SetColors_Sample();
end

function Lifebloomer_SetColors_Sample()
	local i = 1;
	LifebloomerOptionsAppearanceSample:SetBackdropColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSample:SetBackdropColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 2;
	LifebloomerOptionsAppearanceSampleHPBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleHPBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 3;
	LifebloomerOptionsAppearanceSampleLBBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleLBBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 4;
	LifebloomerOptionsAppearanceSampleRejuvBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleRejuvBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 5;
	LifebloomerOptionsAppearanceSampleRegroBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleRegroBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 6 + LB_Buffer.Debuff;
	LifebloomerOptionsAppearanceSample:SetBackdropBorderColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSample:SetBackdropBorderColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 11 - LB_Buffer.Range;
	LifebloomerOptionsAppearanceSampleHPBarName:SetTextColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleHPBarName:SetTextColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 13 - LB_Buffer.Agro;
	LifebloomerOptionsAppearanceSampleHPBarDTPS:SetTextColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleHPBarDTPS:SetTextColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	-- local i = 14;
	-- LifebloomerOptionsAppearanceSampleLBBarNumber:SetTextColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	-- LifebloomerOptionsDimensionsSampleLBBarNumber:SetTextColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 15;
	LifebloomerOptionsAppearanceSampleLBBarTimer:SetTextColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleLBBarTimer:SetTextColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 16;
	LifebloomerOptionsAppearanceSampleWildBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleWildBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	local i = 17;
	LifebloomerOptionsAppearanceSampleGerBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	LifebloomerOptionsDimensionsSampleGerBar:SetStatusBarColor(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
	for i=1, 17, 1 do
		if i ~= 14 then
			_G["LifebloomerOptionsAppearanceTexture"..i.."Texture"]:SetTexture(LB_Buffer.LBColors[i].R, LB_Buffer.LBColors[i].G, LB_Buffer.LBColors[i].B, LB_Buffer.LBColors[i].A);
		end
	end
end

function Lifebloomer_Color(preval)
	if not preval then
		LB_Buffer.LBColors[LBColorID].R, LB_Buffer.LBColors[LBColorID].G, LB_Buffer.LBColors[LBColorID].B = ColorPickerFrame:GetColorRGB();
	else
		LB_Buffer.LBColors[LBColorID].R, LB_Buffer.LBColors[LBColorID].G, LB_Buffer.LBColors[LBColorID].B, LB_Buffer.LBColors[LBColorID].A = unpack(preval);
	end
	Lifebloomer_SetColors_Sample();
end

function Lifebloomer_Opacity()
	LB_Buffer.LBColors[LBColorID].A = OpacitySliderFrame:GetValue();
	Lifebloomer_SetColors_Sample();
end

function Lifebloomer_SetColors()
	local n = getn(LBV) + LBVFF;
	while n > 0 do
		Lifebloomer_SetColor(n);
		n = n - 1;
	end
	Lifebloomer_RefreshAllRaidIcons();
end

function Lifebloomer_SetColor(n)
	-- Apply the backdrop that corresponds to the frame, defined by key values in the XML file (Lifebloomer.xml, for example.)
	-- Reference: https://github.com/Stanzilla/WoWUIBugs/wiki/9.0.1-Consolidated-UI-Changes#xml-changes
	_G["LifebloomerMainFrameUnitFrame"..n]:ApplyBackdrop();

	local i = 1;
	_G["LifebloomerMainFrameUnitFrame"..n]:SetBackdropColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
	i = 2;
	_G["LifebloomerMainFrameUnitFrame"..n.."HPBar"]:SetStatusBarColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
	i = 3;
	_G["LifebloomerMainFrameUnitFrame"..n.."LBBar"]:SetStatusBarColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
	i = 4;
	_G["LifebloomerMainFrameUnitFrame"..n.."RejuvBar"]:SetStatusBarColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
	i = 5;
	_G["LifebloomerMainFrameUnitFrame"..n.."RegroBar"]:SetStatusBarColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
	i = 6;
	_G["LifebloomerMainFrameUnitFrame"..n]:SetBackdropBorderColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
	i = 15;
	_G["LifebloomerMainFrameUnitFrame"..n.."LBBarTimer"]:SetTextColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
	i = 16;
	_G["LifebloomerMainFrameUnitFrame"..n.."WildBar"]:SetStatusBarColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
	i = 17;
	_G["LifebloomerMainFrameUnitFrame"..n.."GerBar"]:SetStatusBarColor(LBColors[i].R, LBColors[i].G, LBColors[i].B, LBColors[i].A);
end

function Lifebloomer_OptionsAppearance_Accept()
	LBColors = Lifebloomer_deepcopy(LB_Buffer.LBColors);
	Lifebloomer_SetColors();
end

function Lifebloomer_OptionsAppearance_Cancel()
	LB_Buffer.LBColors = Lifebloomer_deepcopy(LBColors);
	Lifebloomer_SetColors_Sample();
end

function Lifebloomer_OptionsAppearance_Default()
--Colors
	LB_Buffer.LBColors = Lifebloomer_deepcopy(LBColorsDefault);
--Condition Settings
	LB_Buffer.Debuff = 0;		-- 0: none, 1: curse, 2: poison, 3: both
	LB_Buffer.Range = 1;		-- 0: out, 1: in
	LB_Buffer.Agro = 0;			-- 0: no, 1: yes
	
	Lifebloomer_SetColors_Sample();
end

function Lifebloomer_OptionsAppearance_Preset(PresetArray)
	LB_Buffer.LBColors = Lifebloomer_deepcopy(PresetArray);
end

LBColorsDefault = {};
--Background
	LBColorsDefault[1] = {};
	LBColorsDefault[1].R = 0;
	LBColorsDefault[1].G = 0;
	LBColorsDefault[1].B = 0;
	LBColorsDefault[1].A = .25;
--Health
	LBColorsDefault[2] = {};
	LBColorsDefault[2].R = 0;
	LBColorsDefault[2].G = 1;
	LBColorsDefault[2].B = 0;
	LBColorsDefault[2].A = 1;
--Lifebloom
	LBColorsDefault[3] = {};
	LBColorsDefault[3].R = 0;
	LBColorsDefault[3].G = .4;
	LBColorsDefault[3].B = 1;
	LBColorsDefault[3].A = 0.88;
--Rejuv
	LBColorsDefault[4] = {};
	LBColorsDefault[4].R = .78;
	LBColorsDefault[4].G = 0;
	LBColorsDefault[4].B = .78;
	LBColorsDefault[4].A = 1;
--Regrowth
	LBColorsDefault[5] = {};
	LBColorsDefault[5].R = 0;
	LBColorsDefault[5].G = 1;
	LBColorsDefault[5].B = 0;
	LBColorsDefault[5].A = 1;
--Border
	LBColorsDefault[6] = {};
	LBColorsDefault[6].R = 1;
	LBColorsDefault[6].G = 1;
	LBColorsDefault[6].B = 1;
	LBColorsDefault[6].A = 0.75;
--Cursed
	LBColorsDefault[7] = {};
	LBColorsDefault[7].R = 1;
	LBColorsDefault[7].G = 0;
	LBColorsDefault[7].B = 1;
	LBColorsDefault[7].A = 0.75;
--Poisoned
	LBColorsDefault[8] = {};
	LBColorsDefault[8].R = 0;
	LBColorsDefault[8].G = 1;
	LBColorsDefault[8].B = 0;
	LBColorsDefault[8].A = 0.75;
--Curse + Poison
	LBColorsDefault[9] = {};
	LBColorsDefault[9].R = 1;
	LBColorsDefault[9].G = 0;
	LBColorsDefault[9].B = 0;
	LBColorsDefault[9].A = 0.75;
--In Range
	LBColorsDefault[10] = {};
	LBColorsDefault[10].R = 1;
	LBColorsDefault[10].G = 1;
	LBColorsDefault[10].B = 1;
	LBColorsDefault[10].A = 1;
--Out of Range
	LBColorsDefault[11] = {};
	LBColorsDefault[11].R = 0.5;
	LBColorsDefault[11].G = 0;
	LBColorsDefault[11].B = 0;
	LBColorsDefault[11].A = 1;
--Has Agro
	LBColorsDefault[12] = {};
	LBColorsDefault[12].R = 1;
	LBColorsDefault[12].G = 1;
	LBColorsDefault[12].B = 0;
	LBColorsDefault[12].A = 1;
--No Agro
	LBColorsDefault[13] = {};
	LBColorsDefault[13].R = 0;
	LBColorsDefault[13].G = 1;
	LBColorsDefault[13].B = 1;
	LBColorsDefault[13].A = 1;
--LB Count
	LBColorsDefault[14] = {};
	LBColorsDefault[14].R = 1;
	LBColorsDefault[14].G = 1;
	LBColorsDefault[14].B = 1;
	LBColorsDefault[14].A = 1;
--LB Timer
	LBColorsDefault[15] = {};
	LBColorsDefault[15].R = 1;
	LBColorsDefault[15].G = 1;
	LBColorsDefault[15].B = 1;
	LBColorsDefault[15].A = 1;
--Wild Growth
	LBColorsDefault[16] = {};
	LBColorsDefault[16].R = 1;
	LBColorsDefault[16].G = 1;
	LBColorsDefault[16].B = 0;
	LBColorsDefault[16].A = 1;
--Germination
	LBColorsDefault[17] = {};
	LBColorsDefault[17].R = 0;
	LBColorsDefault[17].G = 1;
	LBColorsDefault[17].B = 1;
	LBColorsDefault[17].A = 1;
	
LBColorsDefaultClassic = {};
--Background
	LBColorsDefaultClassic[1] = {};
	LBColorsDefaultClassic[1].R = 0;
	LBColorsDefaultClassic[1].G = 0;
	LBColorsDefaultClassic[1].B = 0;
	LBColorsDefaultClassic[1].A = .25;
--Health
	LBColorsDefaultClassic[2] = {};
	LBColorsDefaultClassic[2].R = 0;
	LBColorsDefaultClassic[2].G = 1;
	LBColorsDefaultClassic[2].B = 0;
	LBColorsDefaultClassic[2].A = 1;
--Lifebloom
	LBColorsDefaultClassic[3] = {};
	LBColorsDefaultClassic[3].R = 0;
	LBColorsDefaultClassic[3].G = .4;
	LBColorsDefaultClassic[3].B = 1;
	LBColorsDefaultClassic[3].A = 0.88;
--Rejuv
	LBColorsDefaultClassic[4] = {};
	LBColorsDefaultClassic[4].R = .78;
	LBColorsDefaultClassic[4].G = 0;
	LBColorsDefaultClassic[4].B = .78;
	LBColorsDefaultClassic[4].A = 1;
--Regrowth
	LBColorsDefaultClassic[5] = {};
	LBColorsDefaultClassic[5].R = 0;
	LBColorsDefaultClassic[5].G = 1;
	LBColorsDefaultClassic[5].B = 0;
	LBColorsDefaultClassic[5].A = 1;
--Border
	LBColorsDefaultClassic[6] = {};
	LBColorsDefaultClassic[6].R = 1;
	LBColorsDefaultClassic[6].G = 1;
	LBColorsDefaultClassic[6].B = 1;
	LBColorsDefaultClassic[6].A = 0.75;
--Cursed
	LBColorsDefaultClassic[7] = {};
	LBColorsDefaultClassic[7].R = 1;
	LBColorsDefaultClassic[7].G = 0;
	LBColorsDefaultClassic[7].B = 1;
	LBColorsDefaultClassic[7].A = 0.75;
--Poisoned
	LBColorsDefaultClassic[8] = {};
	LBColorsDefaultClassic[8].R = 0;
	LBColorsDefaultClassic[8].G = 1;
	LBColorsDefaultClassic[8].B = 0;
	LBColorsDefaultClassic[8].A = 0.75;
--Curse + Poison
	LBColorsDefaultClassic[9] = {};
	LBColorsDefaultClassic[9].R = 1;
	LBColorsDefaultClassic[9].G = 0;
	LBColorsDefaultClassic[9].B = 0;
	LBColorsDefaultClassic[9].A = 0.75;
--In Range
	LBColorsDefaultClassic[10] = {};
	LBColorsDefaultClassic[10].R = 0;
	LBColorsDefaultClassic[10].G = 0.1;
	LBColorsDefaultClassic[10].B = 0;
	LBColorsDefaultClassic[10].A = 0.5;
--Out of Range
	LBColorsDefaultClassic[11] = {};
	LBColorsDefaultClassic[11].R = 0.5;
	LBColorsDefaultClassic[11].G = 0;
	LBColorsDefaultClassic[11].B = 0;
	LBColorsDefaultClassic[11].A = 1;
--Has Agro
	LBColorsDefaultClassic[12] = {};
	LBColorsDefaultClassic[12].R = 1;
	LBColorsDefaultClassic[12].G = 1;
	LBColorsDefaultClassic[12].B = 0;
	LBColorsDefaultClassic[12].A = 1;
--No Agro
	LBColorsDefaultClassic[13] = {};
	LBColorsDefaultClassic[13].R = 0;
	LBColorsDefaultClassic[13].G = 1;
	LBColorsDefaultClassic[13].B = 1;
	LBColorsDefaultClassic[13].A = 1;
--LB Count
	LBColorsDefaultClassic[14] = {};
	LBColorsDefaultClassic[14].R = 1;
	LBColorsDefaultClassic[14].G = 1;
	LBColorsDefaultClassic[14].B = 1;
	LBColorsDefaultClassic[14].A = 1;
--LB Timer
	LBColorsDefaultClassic[15] = {};
	LBColorsDefaultClassic[15].R = 1;
	LBColorsDefaultClassic[15].G = 1;
	LBColorsDefaultClassic[15].B = 1;
	LBColorsDefaultClassic[15].A = 1;
--Wild Growth
	LBColorsDefaultClassic[16] = {};
	LBColorsDefaultClassic[16].R = 1;
	LBColorsDefaultClassic[16].G = 1;
	LBColorsDefaultClassic[16].B = 0;
	LBColorsDefaultClassic[16].A = 1;
--Germination
	LBColorsDefaultClassic[17] = {};
	LBColorsDefaultClassic[17].R = 0;
	LBColorsDefaultClassic[17].G = 1;
	LBColorsDefaultClassic[17].B = 1;
	LBColorsDefaultClassic[17].A = 1;

-- vim: sw=8 sts=8 noexpandtab 
