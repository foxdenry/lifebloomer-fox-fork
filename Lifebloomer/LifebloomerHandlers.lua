
function Lifebloomer_OnLoad_Handlers()
	if LBHandles then
	else
		LBHandles = {};
		Lifebloomer_Handlers_Default(1,1);
	end
	LB_Buffer.LBHandle = {};
	LB_Buffer.HButton = 0;
end

function Lifebloomer_Handlers_Default(m, n)
	for i = m, 2, 1 do
		if not LBHandles[i] then
			LBHandles[i] = {};
		end
		for j = n, 8, 1 do
			LBHandles[i][j] = {};
			if j == 1 then
				LBHandles[i][j].N = "";
			elseif j == 2 then
				LBHandles[i][j].N = "shift-";
			elseif j == 3 then
				LBHandles[i][j].N = "ctrl-";
			elseif j == 4 then
				LBHandles[i][j].N = "alt-";
			elseif j == 5 then
				LBHandles[i][j].N = "ctrl-shift-";
			elseif j == 6 then
				LBHandles[i][j].N = "alt-shift-";
			elseif j == 7 then
				LBHandles[i][j].N = "alt-ctrl-";
			elseif j == 8 then
				LBHandles[i][j].N = "alt-ctrl-shift-";
			end
			LBHandles[i][j].T = "";
			LBHandles[i][j].S = "None";
		end
	end
end

function Lifebloomer_SetHandlerAttributes(frame)
	for i = 1 , 2, 1 do
		for j = 1, 8, 1 do
			frame:SetAttribute((LBHandles[i][j].N).."type-Handler"..i, LBHandles[i][j].T);
			frame:SetAttribute((LBHandles[i][j].N)..(LBHandles[i][j].T).."-Handler"..i, LBHandles[i][j].S);
		end
	end
end

function Lifebloomer_SetHandlers()
	Lifebloomer_UpdateHandlers(LB_Buffer.HButton);
	for i = 1, 2, 1 do
		for j = 1, 8, 1 do
			Lifebloomer_HandleOne(i, j, tostring(LB_Buffer.LBHandle[i][j]));
		end
	end
	local i = getn(LBV) + LBVFF;
	while i > 0 do
		local frame = _G["LifebloomerMainFrameUnitFrame"..i];
		Lifebloomer_SetHandlerAttributes(frame);
		i = i - 1;
	end
	LB_Buffer.HButton = 0;
	LB_Buffer.LBHandle = {};
end

function Lifebloomer_HandleOne(i, j, text)
	local Type = "target";
	local Spell = "Target";
	if not (text == "Target") then
		Type = "spell";
		Spell = text;
	end
	LBHandles[i][j].T = Type;
	LBHandles[i][j].S = Spell;
end

function Lifebloomer_UpdateHandlers(n)
	if not (LB_Buffer.HButton == 0) then
		for j = 1, 8, 1 do
			LB_Buffer.LBHandle[LB_Buffer.HButton][j] = _G["LifebloomerOptionsHandlersHBox"..j.."Text"]:GetText();
		end
	else n = 1;
	end
	for j = 1, 8, 1 do
		_G["LifebloomerOptionsHandlersHBox"..j.."Text"]:SetText(tostring(LB_Buffer.LBHandle[n][j]));
		LB_Buffer.HButton = n;
	end
end

function Lifebloomer_HandlersCopy()
	for i = 1, 2, 1 do
		if not LB_Buffer.LBHandle[i] then
			LB_Buffer.LBHandle[i] = {};
		end
		for j = 1, 8, 1 do
			if not LB_Buffer.LBHandle[i][j] then
				LB_Buffer.LBHandle[i][j] = tostring(LBHandles[i][j].S);
			end
		end
	end
end

function Lifebloomer_OptionsHandlers_Cancel()
	LB_Buffer.HButton = 0;
	LB_Buffer.LBHandle = {};
end

function Lifebloomer_OptionsHandlers_Default()
	for i = 1, 2, 1 do
		if not LB_Buffer.LBHandle[i] then
			LB_Buffer.LBHandle[i] = {};
		end
		for j = 1, 8, 1 do
			if i == 1 then
				LB_Buffer.LBHandle[i][j] = "Target";
			else
				LB_Buffer.LBHandle[i][j] = "None";
			end
		end
	end
	local n = LB_Buffer.HButton;
	LB_Buffer.HButton = 0;
	Lifebloomer_UpdateHandlers(n);
end

-- vim: sw=8 sts=8 noexpandtab 
