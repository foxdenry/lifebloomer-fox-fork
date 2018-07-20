
function Lifebloomer_OnLoad_Bindings()
	if LBSaved then
		if not LBSaved[3] or not LBSaved[1][5] then
			Lifebloomer_Bindings_Default(3,1);
			Lifebloomer_Bindings_Default(1,5);
		end
		if not LBSaved.Bind then
			LBSaved.Bind = nil;
		end
		if not LBSaved.DTPS then
			LBSaved.DTPS = 1;
			LBSaved.Bind = nil;
		end
		if LBSaved.FTar == nil then
			LBSaved.FTar = 1;
			LBSaved.LStat = 1;
		end
		if LBSaved.DimOOR == nil then
			LBSaved.DimOOR = true;
		end
		if LBSaved.FlashDmg == nil then
			LBSaved.FlashDmg = true;
		end
		if LBSaved.UseReverseLookup == nil then
			LBSaved.UseReverseLookup = true;
		end
		Lifebloomer_Check_Deprecated_Spells ();
	else
		LBSaved = {};
		LBSaved.DTPS = 2;
		LBSaved.Bind = nil;
		if LBVClass == "DRUID" and LBVLevel > 64 then
			LBSaved.Vis = 1;
		else LBSaved.Vis = nil;
		end
		LBSaved.FTar = 1;
		LBSaved.LStat = 1;
		LBSaved.DimOOR = true;
		LBSaved.FlashDmg = true;
		LBSaved.UseReverseLookup = true;
		Lifebloomer_Bindings_Default(1,1);
	end
	
	LB_Buffer.LBBind = {};
	LB_Buffer.Button = 0;
end

function Lifebloomer_Bindings_Default(m, n)
	for i = m, 5, 1 do
		if not LBSaved[i] then
			LBSaved[i] = {};
		end
		for j = n, 8, 1 do
			LBSaved[i][j] = {};
			if j == 1 then
				LBSaved[i][j].N = "";
			elseif j == 2 then
				LBSaved[i][j].N = "shift-";
			elseif j == 3 then
				LBSaved[i][j].N = "ctrl-";
			elseif j == 4 then
				LBSaved[i][j].N = "alt-";
			elseif j == 5 then
				LBSaved[i][j].N = "ctrl-shift-";
			elseif j == 6 then
				LBSaved[i][j].N = "alt-shift-";
			elseif j == 7 then
				LBSaved[i][j].N = "alt-ctrl-";
			elseif j == 8 then
				LBSaved[i][j].N = "alt-ctrl-shift-";
			end
			if i == 1 then
				LBSaved[i][j].T = "target";
				LBSaved[i][j].S = "Target";
			else
				LBSaved[i][j].T = "";
				LBSaved[i][j].S = "None";
			end
		end
	end
end

function Lifebloomer_Check_Deprecated_Spells()
	for i = 1, 5, 1 do
		for j = 1, 8, 1 do
			-- Unfortunately, I don't think there is a way to
			-- localize no-longer-existent spells.
			if LBSaved[i][j].S == "Abolish Poison" or
			   LBSaved[i][j].S == "Remove Curse" then
				LBSaved[i][j].S = LIFEBLOOMER_Remove_Curse;
			end
		end
	end
end

function Lifebloomer_SetAttributes(frame)
	if LBSaved.Bind then
		ClickCastFrames[frame] = nil;
		for i = 1 , 5, 1 do
			for j = 1, 8, 1 do
				--DEFAULT_CHAT_FRAME:AddMessage(i.."  "..j.."  ");
				frame:SetAttribute((LBSaved[i][j].N).."type"..i, LBSaved[i][j].T);
				frame:SetAttribute((LBSaved[i][j].N)..(LBSaved[i][j].T)..i, LBSaved[i][j].S);
			end
		end
	else
		for j = 1, 8, 1 do
			frame:SetAttribute((LBSaved[1][j].N).."type1", "target");
			frame:SetAttribute((LBSaved[1][j].N)..(LBSaved[1][j].T)..1, nil);
		end
		for i = 2, 5, 1 do
			for j = 1, 8, 1 do
				frame:SetAttribute((LBSaved[i][j].N).."type"..i, nil);
				frame:SetAttribute((LBSaved[i][j].N)..(LBSaved[i][j].T)..i, nil);
			end
		end
		ClickCastFrames[frame] = true;
	end
end

function Lifebloomer_SetBindings()
	Lifebloomer_UpdateBindings(LB_Buffer.Button);
	for i = 1, 5, 1 do
		for j = 1, 8, 1 do
			Lifebloomer_BindOne(i, j, tostring(LB_Buffer.LBBind[i][j]));
		end
	end
	local i = getn(LBV) + LBVFF;
	while i > 0 do
		local frame = _G["LifebloomerMainFrameUnitFrame"..i];
		Lifebloomer_SetAttributes(frame);
		i = i - 1;
	end
	LB_Buffer.Button = 0;
	LB_Buffer.LBBind = {};
end

function Lifebloomer_BindOne(i, j, text)
	local Type = "target";
	local Spell = "Target";
	if not (text == "Target") then
		Type = "spell";
		Spell = text;
	end
	LBSaved[i][j].T = Type;
	LBSaved[i][j].S = Spell;
end

function Lifebloomer_UpdateBindings(n)
	if not (LB_Buffer.Button == 0) then
		for j = 1, 8, 1 do
			LB_Buffer.LBBind[LB_Buffer.Button][j] = _G["LifebloomerOptionsBindingsCBox"..j.."Text"]:GetText();
		end
	else n = 1;
	end
	for j = 1, 8, 1 do
		_G["LifebloomerOptionsBindingsCBox"..j.."Text"]:SetText(tostring(LB_Buffer.LBBind[n][j]));
		LB_Buffer.Button = n;
	end
end

function Lifebloomer_BindingsCopy()
	for i = 1, 5, 1 do
		if not LB_Buffer.LBBind[i] then
			LB_Buffer.LBBind[i] = {};
		end
		for j = 1, 8, 1 do
			if not LB_Buffer.LBBind[i][j] then
				LB_Buffer.LBBind[i][j] = tostring(LBSaved[i][j].S);
			end
		end
	end
end

function Lifebloomer_OptionsBindings_Cancel()
	LB_Buffer.Button = 0;
	LB_Buffer.LBBind = {};
end

function Lifebloomer_OptionsBindings_Default()
	for i = 1, 5, 1 do
		if not LB_Buffer.LBBind[i] then
			LB_Buffer.LBBind[i] = {};
		end
		for j = 1, 8, 1 do
			if i == 1 then
				LB_Buffer.LBBind[i][j] = "Target";
			else
				LB_Buffer.LBBind[i][j] = "None";
			end
		end
	end
	local n = LB_Buffer.Button;
	LB_Buffer.Button = 0;
	Lifebloomer_UpdateBindings(n);
end
-- vim: sw=8 sts=8 noexpandtab 
