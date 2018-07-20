function Lifebloomer_OnLoad_Dimensions()
	if LBDim then
		if not LBDim.rej then
			LBDim.rej = LBDimDefault.rej;
		end
		if not LBDim.reg then
			LBDim.reg = LBDimDefault.reg;
		end
		if not LBDim.wild then
			LBDim.wild = LBDimDefault.wild;
		end
		if not LBDim.ger then
			LBDim.ger = LBDimDefault.ger;
		end
		
		if not LBDim.fpc then
		  LBDim.fpc = LBDimDefault.fpc; --frames per column
		end
		if not LBDim.hs then
		  LBDim.hs = LBDimDefault.hs; --horizontal spacing
		end
	else
		LBDim = Lifebloomer_deepcopy(LBDimDefault);
	end
	
	-- Lifebloomer_AdjustH();
	-- Lifebloomer_AdjustW();
	-- Lifebloomer_AdjustS();
	-- Lifebloomer_AdjustRejuv();
	-- Lifebloomer_AdjustGer();
	-- Lifebloomer_AdjustRegro();
	-- Lifebloomer_AdjustWild();
	

	Lifebloomer_Adjust_AllDimensions_AllFrames();
	
	-- LBDim.w = LBDim.wRaid or LBDim.w;
	-- Lifebloomer_Adjust_FrameW(1);
	-- Lifebloomer_Set_MainFrameW();
	-- LifebloomerMainFrame:ClearAllPoints();
	-- LifebloomerMainFrame:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", LifebloomerMainFrame:GetLeft(), LifebloomerMainFrame:GetTop());
	-- LBDim.w = LBDim.wParty or LBDim.w;
	
	LB_Buffer.LBDim = {};
	LB_Buffer.LBDim = Lifebloomer_deepcopy(LBDim);
	
	Lifebloomer_AdjustH_Sample();
	Lifebloomer_AdjustW_Sample();
	--Lifebloomer_AdjustS_Sample();
	Lifebloomer_AdjustRejuv_Sample();
	Lifebloomer_AdjustGer_Sample();
	Lifebloomer_AdjustRegro_Sample();
	Lifebloomer_AdjustWild_Sample();
end

function Lifebloomer_Adjust_BuffBar(n, barName, dim)
	if dim == 0 then
		_G["LifebloomerMainFrameUnitFrame"..n..barName.."Bar"]:Hide();
	else
		_G["LifebloomerMainFrameUnitFrame"..n..barName.."Bar"]:Show();
		_G["LifebloomerMainFrameUnitFrame"..n..barName.."Bar"]:SetHeight(dim);
		if barName == "Ger" then
			_G["LifebloomerMainFrameUnitFrame"..n..barName.."Bar"]:SetPoint("TOPLEFT", "LifebloomerMainFrameUnitFrame"..n.."Rejuv".."Bar", "BOTTOMLEFT", 0, 0);
		end
	end
end

function Lifebloomer_Adjust_AllBuffBars(n)
	Lifebloomer_Adjust_BuffBar(n, "Rejuv", LBDim.rej)
	Lifebloomer_Adjust_BuffBar(n, "Ger", LBDim.ger)
	Lifebloomer_Adjust_BuffBar(n, "Regro", LBDim.reg)
	Lifebloomer_Adjust_BuffBar(n, "Wild", LBDim.wild)
end

function Lifebloomer_Adjust_FrameH(n)
	local buttonSize = (LBDim.h-10)/3;
	_G["LifebloomerMainFrameUnitFrame"..n]:SetHeight(LBDim.h)
	_G["LifebloomerMainFrameUnitFrame"..n.."TargetButton"]:SetHeight(buttonSize)
	_G["LifebloomerMainFrameUnitFrame"..n.."TargetButton"]:SetWidth(buttonSize)
	_G["LifebloomerMainFrameUnitFrame"..n.."ReduceButton"]:SetHeight(buttonSize)
	_G["LifebloomerMainFrameUnitFrame"..n.."ReduceButton"]:SetWidth(buttonSize)
	_G["LifebloomerMainFrameUnitFrame"..n.."IncreaseButton"]:SetHeight(buttonSize)
	_G["LifebloomerMainFrameUnitFrame"..n.."IncreaseButton"]:SetWidth(buttonSize)
end

function Lifebloomer_Adjust_FrameW(n)
	local self = _G["LifebloomerMainFrameUnitFrame"..n]
	local xOffset = (LBDim.w-10)/self.LBMax*LB_GCD_Time
	self:SetWidth(LBDim.w);
	_G["LifebloomerMainFrameUnitFrame"..n.."LBBarGCD"]:ClearAllPoints();
	_G["LifebloomerMainFrameUnitFrame"..n.."LBBarGCD"]:SetPoint("TOP", "LifebloomerMainFrameUnitFrame"..n.."LBBar", "TOPLEFT", xOffset, -1);
	_G["LifebloomerMainFrameUnitFrame"..n.."LBBarGCD"]:SetPoint("BOTTOM", "LifebloomerMainFrameUnitFrame"..n.."LBBar", "BOTTOMLEFT", xOffset, 1);
end

function Lifebloomer_Adjust_FrameS(n)
	if n > 1 then
		_G["LifebloomerMainFrameUnitFrame"..n]:ClearAllPoints();
		-- If frames-per-column is non-zero then use modular arithmetic to wrap frames into columns.
		if LBDim.fpc > 0 and (n % LBDim.fpc == 1 or LBDim.fpc == 1) then
			_G["LifebloomerMainFrameUnitFrame"..n]:SetPoint("LEFT", "LifebloomerMainFrameUnitFrame"..(n-LBDim.fpc), "RIGHT", LBDim.hs, 0);
		else
			_G["LifebloomerMainFrameUnitFrame"..n]:SetPoint("TOP", "LifebloomerMainFrameUnitFrame"..(n-1), "BOTTOM", 0, -LBDim.s);
		end
	end
end

function Lifebloomer_Set_MainFrameH()
	local nv = getn(LBV)
	if LBDim.fpc > 0 then
		LifebloomerMainFrame:SetHeight(16 + (LBDim.h * min(nv, LBDim.fpc)) + (LBDim.s * (min(nv, LBDim.fpc) - 1)));
	else
		-- If fpc == 0 then revert to old method of setting height
		LifebloomerMainFrame:SetHeight(16 + (LBDim.h * nv) + (LBDim.s * (nv - 1)));
	end
end

function Lifebloomer_Set_MainFrameW()
	LifebloomerMainFrame:SetWidth(LBDim.w)
end

function Lifebloomer_Adjust_AllDimensions_SingleFrame(n)
	Lifebloomer_Adjust_FrameH(n)
	Lifebloomer_Adjust_FrameW(n)
	Lifebloomer_Adjust_FrameS(n)
	Lifebloomer_Adjust_AllBuffBars(n)
end

function Lifebloomer_Adjust_AllDimensions_AllFrames()
	local nv = getn(LBV);
	local n = nv + LBVFF;
	
	--AdjustW stuff
	if nv > LBDim.fpc then
		LBDim.w = LBDim.wRaid or LBDim.w;
	else
		LBDim.w = LBDim.wParty or LBDim.w;
	end
	
	while n > 0 do
		Lifebloomer_Adjust_AllDimensions_SingleFrame(n)
		n = n - 1;
	end
	
	Lifebloomer_Set_MainFrameW()
	Lifebloomer_Set_MainFrameH()
end

function Lifebloomer_AdjustH_Sample()
	LifebloomerOptionsDimensionsSample:SetHeight(LB_Buffer.LBDim.h);
end

function Lifebloomer_AdjustH()
	local nv = getn(LBV);
	local n = nv + LBVFF;
	while n > 0 do
		Lifebloomer_Adjust_FrameH(n)
		n = n - 1;
	end
	
	Lifebloomer_Set_MainFrameH()
end

function Lifebloomer_AdjustW_Sample()
	LifebloomerOptionsDimensionsSample:SetWidth(LB_Buffer.LBDim.w);
	LifebloomerOptionsDimensionsSampleLBBarGCD:ClearAllPoints();
	LifebloomerOptionsDimensionsSampleLBBarGCD:SetPoint("TOP", "LifebloomerOptionsDimensionsSampleLBBar", "TOPLEFT", LB_Buffer.LBDim.w*(1.5*(100-GetCombatRatingBonus(20))/100)/7, -1);
	LifebloomerOptionsDimensionsSampleLBBarGCD:SetPoint("BOTTOM", "LifebloomerOptionsDimensionsSampleLBBar", "BOTTOMLEFT", LB_Buffer.LBDim.w*(1.5*(100-GetCombatRatingBonus(20))/100)/7, 1);
end

function Lifebloomer_AdjustW()
	local nv = getn(LBV);
	
	if nv > LBDim.fpc then
		LBDim.w = LBDim.wRaid or LBDim.w;
	else
		LBDim.w = LBDim.wParty or LBDim.w;
	end
	
	local n = nv + LBVFF;
	while n > 0 do
		Lifebloomer_Adjust_FrameW(n)
		n = n - 1;
	end
	-- Leaving this for now -- let the GCD frame sweep across only the first column.
	Lifebloomer_Set_MainFrameW()
	-- LifebloomerMainFrame:SetWidth(ceil(nv / LBDim.fpc) * LBDim.w + ((ceil(nv / LBDim.fpc) - 1) * LBDim.hs)); -- Width of all columns (num columns + horizontal spacing)
end

function Lifebloomer_AdjustS_Sample()
--wtf??
end

function Lifebloomer_AdjustS()
	local nv = getn(LBV);
	local n = nv + LBVFF;
	
	while n > 1 do
		Lifebloomer_Adjust_FrameS(n)
		n = n - 1;
	end
	
	Lifebloomer_Set_MainFrameH()
end

function Lifebloomer_AdjustRejuv_Sample()
	if LB_Buffer.LBDim.rej == 0 then
		LifebloomerOptionsDimensionsSampleRejuvBar:Hide();
		LifebloomerOptionsAppearanceSampleRejuvBar:Hide();
	else
		LifebloomerOptionsDimensionsSampleRejuvBar:Show();
		LifebloomerOptionsAppearanceSampleRejuvBar:Show();
		LifebloomerOptionsDimensionsSampleRejuvBar:SetHeight(LB_Buffer.LBDim.rej);
		LifebloomerOptionsAppearanceSampleRejuvBar:SetHeight(LB_Buffer.LBDim.rej);
	end
end

function Lifebloomer_AdjustRejuv()
	local nv = getn(LBV);
	local n = nv + LBVFF;
	while n > 0 do
		Lifebloomer_Adjust_BuffBar(n, "Rejuv", LBDim.rej)
		n = n - 1
	end
end

function Lifebloomer_AdjustGer_Sample()
	if LB_Buffer.LBDim.ger == 0 then
		LifebloomerOptionsDimensionsSampleGerBar:Hide();
		LifebloomerOptionsAppearanceSampleGerBar:Hide();
	else
		LifebloomerOptionsDimensionsSampleGerBar:Show();
		LifebloomerOptionsAppearanceSampleGerBar:Show();
		LifebloomerOptionsDimensionsSampleGerBar:SetHeight(LB_Buffer.LBDim.ger);
		LifebloomerOptionsAppearanceSampleGerBar:SetHeight(LB_Buffer.LBDim.ger);
	end
end

function Lifebloomer_AdjustGer()
	local nv = getn(LBV);
	local n = nv + LBVFF;
	while n > 0 do
		Lifebloomer_Adjust_BuffBar(n, "Ger", LBDim.ger)
		n = n - 1;
	end
end

function Lifebloomer_AdjustRegro_Sample()
	if LB_Buffer.LBDim.reg == 0 then
		LifebloomerOptionsDimensionsSampleRegroBar:Hide();
		LifebloomerOptionsAppearanceSampleRegroBar:Hide();
	else
		LifebloomerOptionsDimensionsSampleRegroBar:Show();
		LifebloomerOptionsAppearanceSampleRegroBar:Show();
		LifebloomerOptionsDimensionsSampleRegroBar:SetHeight(LB_Buffer.LBDim.reg);
		LifebloomerOptionsAppearanceSampleRegroBar:SetHeight(LB_Buffer.LBDim.reg);
	end
end

function Lifebloomer_AdjustRegro()
	local nv = getn(LBV);
	local n = nv + LBVFF;
	while n > 0 do
		Lifebloomer_Adjust_BuffBar(n, "Regro", LBDim.reg)
		n = n - 1;
	end
end

function Lifebloomer_AdjustWild_Sample()
	if LB_Buffer.LBDim.wild == 0 then
		LifebloomerOptionsDimensionsSampleWildBar:Hide();
		LifebloomerOptionsAppearanceSampleWildBar:Hide();
	else
		LifebloomerOptionsDimensionsSampleWildBar:Show();
		LifebloomerOptionsAppearanceSampleWildBar:Show();
		LifebloomerOptionsDimensionsSampleWildBar:SetHeight(LB_Buffer.LBDim.wild);
		LifebloomerOptionsAppearanceSampleWildBar:SetHeight(LB_Buffer.LBDim.wild);
	end
end

function Lifebloomer_AdjustWild()
	local nv = getn(LBV);
	local n = nv + LBVFF;
	while n > 0 do
		Lifebloomer_Adjust_BuffBar(n, "Wild", LBDim.wild)
		n = n - 1;
	end
end

function Lifebloomer_OptionsDimensions_Accept()
	LBDim = Lifebloomer_deepcopy(LB_Buffer.LBDim);
	-- Lifebloomer_AdjustH();
	-- Lifebloomer_AdjustW();
	-- Lifebloomer_AdjustS();
	-- Lifebloomer_AdjustRejuv();
	-- Lifebloomer_AdjustGer();
	-- Lifebloomer_AdjustRegro();
	-- Lifebloomer_AdjustWild();
	Lifebloomer_Adjust_AllDimensions_AllFrames();
end

function Lifebloomer_OptionsDimensions_Cancel()
	LB_Buffer.LBDim = Lifebloomer_deepcopy(LBDim);
	-- Lifebloomer_AdjustH();
	-- Lifebloomer_AdjustW();
	-- Lifebloomer_AdjustS();
	-- Lifebloomer_AdjustRejuv();
	-- Lifebloomer_AdjustGer();
	-- Lifebloomer_AdjustRegro();
	-- Lifebloomer_AdjustWild();
	Lifebloomer_Adjust_AllDimensions_AllFrames();
end

function Lifebloomer_OptionsDimensions_Default()
	LB_Buffer.LBDim = Lifebloomer_deepcopy(LBDimDefault);
	LifebloomerOptionsDimensionsVerticalSlider:SetValue(LB_Buffer.LBDim.h);
	LifebloomerOptionsDimensionsHorizontalSlider:SetValue(LB_Buffer.LBDim.w);
	LifebloomerOptionsDimensionsSpacingSlider:SetValue(LB_Buffer.LBDim.s);
	LifebloomerOptionsDimensionsRejuvSlider:SetValue(LB_Buffer.LBDim.rej);
	LifebloomerOptionsDimensionsRegrowthSlider:SetValue(LB_Buffer.LBDim.reg);
	LifebloomerOptionsDimensionsWildSlider:SetValue(LB_Buffer.LBDim.wild);
	Lifebloomer_AdjustH_Sample();
	Lifebloomer_AdjustW_Sample();
	Lifebloomer_AdjustS_Sample();
	Lifebloomer_AdjustRejuv_Sample();
	Lifebloomer_AdjustGer_Sample();
	Lifebloomer_AdjustRegro_Sample();
	Lifebloomer_AdjustWild_Sample();
end

function Lifebloomer_OptionsDimensions_Preset(PresetArray)
	LB_Buffer.LBDim = Lifebloomer_deepcopy(PresetArray);
end

LBDimDefault = {};
LBDimDefault.h = 40;
LBDimDefault.w = 160;
LBDimDefault.wParty = 160;
LBDimDefault.wRaid = 100;
LBDimDefault.s = -2;
LBDimDefault.hs = 0; -- Horizontal separation
LBDimDefault.fpc = 6; -- Frames per Column
LBDimDefault.rej = 3;
LBDimDefault.ger = 3;
LBDimDefault.reg = 3;
LBDimDefault.wild = 3;

LBDimDefaultClassic = {};
LBDimDefaultClassic.h = 40;
LBDimDefaultClassic.w = 180;
LBDimDefaultClassic.s = 0;
LBDimDefaultClassic.hs = 8; -- Horizontal separation
LBDimDefaultClassic.fpc = 5; -- Frames per Column
LBDimDefaultClassic.rej = 2;
LBDimDefaultClassic.ger = 2;
LBDimDefaultClassic.reg = 2;
LBDimDefaultClassic.wild = 2;
--LBDimDefaultClassic.abolish = 2;
-- vim: sw=8 sts=8 noexpandtab 
