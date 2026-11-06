--[[
███████╗██╗   ██╗██╗██╗         █████╗ ██╗  ██╗███████╗
██╔════╝██║   ██║██║██║        ██╔══██╗╚██╗██╔╝██╔════╝
█████╗  ██║   ██║██║██║        ███████║ ╚███╔╝ █████╗
██╔══╝  ╚██╗ ██╔╝██║██║        ██╔══██║ ██╔██╗ ██╔══╝
███████╗ ╚████╔╝ ██║███████╗   ██║  ██║██╔╝ ██╗███████╗
╚══════╝  ╚═══╝  ╚═╝╚══════╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
--]]

_G.CC = {
		Flags = {},
		UI = { Tabs = {}, Elements = {} },
		Refs = {},
		Lib = nil,
	};
local E = _G.CC;
local H = E.Flags;
local z = E.UI;
local i = "velcloud_key.txt";
local c = tostring((game:GetService("Players")).LocalPlayer.UserId);
local a = "0.7";
_G.VelcloudKeyState = {
		key = nil,
		name = nil,
		valid = false,
		reason = "?? ???????????",
		expires = 0,
	};
local function q(E)
	local H = 0;
	for z = 1, #E, 1 do
		H = ((H * 31 + string.byte(E, z))) % 2147483647;
	end;
	return tostring(H);
end;
local function d()
	local E = math.random(100000, 999999);
	local H = "https://api.github.com/repos/xxqwl1337/neveriscloud/contents/keys.json?ref=main&t=" .. (os.time() .. ("&r=" .. E));
	local z, i = pcall(function()
			return game:HttpGet(H);
		end);
	if not z or not i then
		return nil;
	end;
	local c, a = pcall(function()
			return (game:GetService("HttpService")):JSONDecode(i);
		end);
	if not c or not a or not a.content then
		return nil;
	end;
	local q, d = pcall(function()
			return (game:GetService("HttpService")):Base64Decode((a.content:gsub("%s+", "")));
		end);
	if not q or not d then
		return nil;
	end;
	local Z, C = pcall(function()
			return (game:GetService("HttpService")):JSONDecode(d);
		end);
	if not Z or not C then
		return nil;
	end;
	return C;
end;
local function Z(E, H)
	if not E or E == "" then
		return false, "?????? ????", false;
	end;
	local z = H[E];
	if not z then
		return false, "???? ?? ?????? (?????? ??? ????????)", false;
	end;
	if z.expires ~= 0 and (os.time and os.time() > z.expires) then
		return false, "???? ????? ?????", true;
	end;
	if z.min_version then
		local E = tonumber((a:gsub("v", "")));
		local H = tonumber(((tostring(z.min_version)):gsub("v", "")));
		if E and (H and E < H) then
			return false, "???????? ?????? ?? v" .. tostring(z.min_version), true;
		end;
	end;
	if z.hwid and z.hwid ~= "" then
		if z.hwid == "BANNED" then
			return false, "???? ???????", true;
		end;
		if z.hwid ~= c then
			return false, "???? ???????? ? ??????? ????????", true;
		end;
	end;
	return true, z, false;
end;
local function C(E)
	if not E or E == 0 then
		return "?????????";
	end;
	local H, z = pcall(function()
			return os.date("%d.%m.%y (%H:%M)", E);
		end);
	return H and z or "??????????";
end;
local function B(E, H, z)
	if not writefile then
		return;
	end;
	local c = q(E .. H);
	pcall(writefile, i, c .. ("|" .. (H .. ("|" .. (tostring(z or 0) .. ("|" .. E))))));
end;
local function r()
	if not ((isfile and readfile)) then
		return nil, nil, nil, nil;
	end;
	local E, H = pcall(function()
			if isfile(i) then
				return readfile(i);
			end;
		end);
	if E and H then
		local E = string.split(H:gsub("%s+", ""), "|");
		if #E >= 4 then
			return E[1], E[2], tonumber(E[3] or 0), E[4];
		end;
	end;
	return nil, nil, nil, nil;
end;
local function T()
	if isfile and delfile then
		pcall(function()
			if isfile(i) then
				delfile(i);
			end;
		end);
	end;
end;
local function w()
	local E = Instance.new("ScreenGui");
	E.Name = "VelcloudPrompt_" .. math.random(1000000);
	E.ResetOnSpawn = false;
	E.IgnoreGuiInset = true;
	E.DisplayOrder = 999;
	E.Parent = (gethui and gethui()) or game:GetService("CoreGui");
	local H = Instance.new("Frame");
	H.Size = UDim2.fromOffset(400, 220);
	H.Position = UDim2.fromScale(.5, .5);
	H.AnchorPoint = Vector2.new(.5, .5);
	H.BackgroundColor3 = Color3.fromRGB(18, 18, 18);
	H.BorderSizePixel = 0;
	H.Parent = E;
	(Instance.new("UICorner", H)).CornerRadius = UDim.new(0, 10);
	local z = Instance.new("UIStroke", H);
	z.Color = Color3.fromRGB(60, 60, 60);
	z.Thickness = 1;
	local i = Instance.new("TextLabel");
	i.Size = UDim2.new(1, -24, 0, 28);
	i.Position = UDim2.fromOffset(12, 12);
	i.BackgroundTransparency = 1;
	i.Text = "velcloud.xd \226\128\148 ????? ????";
	i.TextColor3 = Color3.new(1, 1, 1);
	i.Font = Enum.Font.BuilderSansBold;
	i.TextSize = 16;
	i.TextXAlignment = Enum.TextXAlignment.Left;
	i.Parent = H;
	local c = Instance.new("TextBox");
	c.Size = UDim2.new(1, -24, 0, 36);
	c.Position = UDim2.fromOffset(12, 52);
	c.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
	c.TextColor3 = Color3.new(1, 1, 1);
	c.PlaceholderText = "CLOUD-XXXX-XXXX";
	c.PlaceholderColor3 = Color3.fromRGB(120, 120, 120);
	c.Font = Enum.Font.Code;
	c.TextSize = 14;
	c.ClearTextOnFocus = false;
	c.Text = "";
	c.Parent = H;
	(Instance.new("UICorner", c)).CornerRadius = UDim.new(0, 6);
	local a = Instance.new("TextButton");
	a.Size = UDim2.new(1, -24, 0, 36);
	a.Position = UDim2.fromOffset(12, 100);
	a.BackgroundColor3 = Color3.fromRGB(80, 200, 120);
	a.TextColor3 = Color3.new(0, 0, 0);
	a.Font = Enum.Font.BuilderSansBold;
	a.TextSize = 14;
	a.Text = "????????????";
	a.Parent = H;
	(Instance.new("UICorner", a)).CornerRadius = UDim.new(0, 6);
	local q = Instance.new("TextLabel");
	q.Size = UDim2.new(1, -24, 0, 40);
	q.Position = UDim2.fromOffset(12, 148);
	q.BackgroundTransparency = 1;
	q.Text = "";
	q.TextColor3 = Color3.fromRGB(255, 100, 100);
	q.Font = Enum.Font.BuilderSansMedium;
	q.TextSize = 12;
	q.TextWrapped = true;
	q.TextXAlignment = Enum.TextXAlignment.Left;
	q.Parent = H;
	local C = nil;
	local B = 0;
	local r = false;
	local function T()
		if r then
			return;
		end;
		local H = c.Text;
		if not H or H == "" then
			q.Text = "????? ????!";
			q.TextColor3 = Color3.fromRGB(255, 100, 100);
			return;
		end;
		q.Text = "????????...";
		q.TextColor3 = Color3.fromRGB(255, 255, 100);
		local z = d();
		if not z then
			q.Text = "??????: ?? ??????? ??????? ?????";
			q.TextColor3 = Color3.fromRGB(255, 100, 100);
			return;
		end;
		local i, a, T = Z(H, z);
		if i then
			q.Text = "???????? ????: " .. (tostring(a.name) .. "!");
			q.TextColor3 = Color3.fromRGB(100, 255, 100);
			C = H;
			task.wait(1);
			E:Destroy();
		else
			q.Text = "?????: " .. tostring(a);
			q.TextColor3 = Color3.fromRGB(255, 100, 100);
			c.Text = "";
			if T then
				warn("[velcloud.xd] ???? ???????? (hard): " .. tostring(a));
			else
				B = B + 1;
				if B >= 3 then
					r = true;
					q.Text = "??????? ????? ???????. ????? 30 ???...";
					task.wait(30);
					r = false;
					B = 0;
					q.Text = "????? ??????????? ?????";
				end;
			end;
		end;
	end;
	a.MouseButton1Click:Connect(T);
	c.FocusLost:Connect(function(E)
		if E then
			T();
		end;
	end);
	while E.Parent and not C do
		task.wait(.1);
	end;
	return C;
end;
local function V()
	local E, H, z, i = r();
	if not E or not H or not i then
		return false;
	end;
	if H ~= c then
		return false;
	end;
	if z and (z ~= 0 and os.time() > z) then
		return false;
	end;
	return true, z, i;
end;
local function G()
	local E, H, z = V();
	if E then
		local E = d();
		if not E then
			_G.VelcloudKeyState = {
					key = nil,
					name = "Offline",
					valid = true,
					reason = "OK",
					expires = H,
				};
			return true;
		end;
		local i, a = Z(z, E);
		if i then
			_G.VelcloudKeyState = {
					key = nil,
					name = a.name,
					valid = true,
					reason = "OK",
					expires = a.expires,
				};
			B(z, c, a.expires);
			return true;
		else
			print("[velcloud.xd] ??????????? ???? ???????? ????????: " .. tostring(a));
			T();
		end;
	end;
	local i = d();
	if not i then
		warn("[velcloud.xd] ?? ??????? ??????? ????? ? GitHub. ??????? ????????.");
		(game:GetService("Players")).LocalPlayer:Kick("velcloud.xd: ?? ??????? ????????? ???????? (??? ?????????)");
		return false;
	end;
	local a, q, C, G = r();
	if a and (q and G) then
		if q ~= c then
			print("[velcloud.xd] ???? ????? ??????????? ??????? ????????. ???????.");
			T();
		else
			local E, H = Z(G, i);
			if E then
				_G.VelcloudKeyState = {
						key = nil,
						name = H.name,
						valid = true,
						reason = "OK",
						expires = H.expires,
					};
				B(G, c, H.expires);
				return true;
			else
				T();
			end;
		end;
	end;
	while true do
		local E = w();
		if not E then
			_G.VelcloudKeyState = {
					key = nil,
					name = nil,
					valid = false,
					reason = "????????",
					expires = 0,
				};
			return false;
		end;
		i = d() or i;
		local H, z = Z(E, i);
		if H then
			B(E, c, z.expires);
			_G.VelcloudKeyState = {
					key = nil,
					name = z.name,
					valid = true,
					reason = "OK",
					expires = z.expires,
				};
			return true;
		else
			print("[velcloud.xd] ???? ????????: " .. tostring(z));
			T();
		end;
	end;
end;
if not G() then
	pcall(function()
		(game:GetService("Players")).LocalPlayer:Kick("velcloud.xd: ?????? ?? ???????????");
	end);
	return;
end;
local function Q()
	local E = _G.VelcloudKeyState;
	if not E or not E.valid then
		return "??? ?????";
	end;
	if not E.expires or E.expires == 0 then
		return "?????????";
	end;
	if E.expires - os.time() <= 0 then
		return "?????";
	end;
	return C(E.expires);
end;
E.Lib = (loadstring(game:HttpGet("https://raw.githubusercontent.com/xxqwl1337/neveriscloud/main/neverisUI2.lua")))();
local J = game:GetService("Players");
local W = game:GetService("RunService");
local X = game:GetService("UserInputService");
local u = game:GetService("Stats");
local O = game:GetService("Lighting");
local A = J.LocalPlayer;
local g = workspace.CurrentCamera;
local l = A:GetMouse();
z.Window = E.Lib:CreateWindow({
		Title = "velcloud.xd",
		Theme = "Velcloud",
		AccentColor = Color3.fromRGB(50, 100, 220),
		LogoID = 1.1003448701821e+14,
		Size = { 820, 480 },
	});
z.Window:CreateTag("Rust Decoy", Color3.fromRGB(235, 80, 80), nil, "gamepad-2");
z.Window:CreateTag("Beta", Color3.fromRGB(235, 190, 60), nil, "flask-conical");
z.Window:CreateTag("v0.7", Color3.fromRGB(150, 150, 150), nil, "git-branch");
z.Window:CreateTag("Premium", Color3.fromRGB(255, 215, 0), nil, "crown");
z.Window:Notify({
	Title = "Welcome",
	Text = "velcloud.xd v0.7 loaded",
	Icon = "check",
	Duration = 4,
});
H.ESP = false;
H.ESPMode = "Chams";
H.ESP_Sleeper = false;
H.TeamCheck = true;
H.ESPColor = Color3.fromRGB(255, 0, 0);
H.SleeperColor = Color3.fromRGB(0, 200, 255);
H.BoxColor = Color3.fromRGB(255, 255, 255);
H.TextColor = Color3.fromRGB(255, 255, 255);
H.LineColor = Color3.fromRGB(255, 0, 0);
H.SkeletonColor = Color3.fromRGB(69, 0, 0);
H.TeamColor = Color3.fromRGB(0, 255, 0);
H.NPCColor = Color3.fromRGB(255, 165, 0);
H.AnimalColor = Color3.fromRGB(255, 20, 147);
H.Box = false;
H.Distance = false;
H.Name = false;
H.Health = false;
H.Line = false;
H.Skeleton = false;
H.WeaponESP = false;
H.MaxDistance = 600;
H.ESP_NPC = false;
H.NPCDistance = 200;
H.NPC_Name = true;
H.NPC_Box = true;
H.NPC_Health = true;
H.NPC_Distance = true;
H.ESP_Animals = false;
H.AnimalDistance = 500;
H.Animal_Name = true;
H.Animal_Box = true;
H.Animal_Health = true;
H.Animal_Distance = true;
H.AimbotEnabled = false;
H.AimbotType = "Mouse";
H.AimbotKey = Enum.UserInputType.MouseButton2;
H.AimbotBone = "Head";
H.AimbotIgnoreTeam = true;
H.AimbotIgnoreSleepers = true;
H.AimbotIgnoreNPC = true;
H.AimbotIgnoreAnimals = true;
H.AimbotVisibleCheck = true;
H.AimbotFOV = 120;
H.AimbotSmooth = 5;
H.AimbotPrediction = 1;
H.AimbotBulletSpeed = 450;
H.AimbotHitChance = 100;
H.AimbotDistanceLimit = 400;
H.AimbotDrawFOV = false;
H.AimbotDrawTarget = false;
H.AimbotDrawTargetColor = Color3.fromRGB(255, 0, 0);
H.AimbotDrawFOVColor = Color3.fromRGB(255, 255, 255);
H.AimbotAutoSwitch = true;
H.DynamicPrediction = true;
H.Ballistic = true;
H.HumanoidCheck = true;
H.NoSpread = false;
H.FreeCam = false;
H.CameraZoom = false;
H.ZoomActive = false;
H.FPSPing = false;
H.Fullbright = false;
H.WorldTimeEnabled = false;
H.WorldTimeValue = 12;
H.HitboxEnabled = false;
H.HitboxSize = 2;
H.HitboxTransparency = 50;
H.NoRecoil = false;
H.SkyColorEnabled = false;
H.SkyColor = Color3.fromRGB(100, 150, 255);
H.WeaponColorEnabled = false;
H.WeaponColor = Color3.fromRGB(255, 0, 255);
H.WeaponMaterial = Enum.Material.Neon;
H.AspectRatioEnabled = false;
H.AspectRatioMode = "16:9";
H.AspectRatioValue = 1;
H.Crosshair = false;
H.CrosshairType = "Cross";
H.CrosshairColor = Color3.fromRGB(0, 255, 0);
H.CrosshairSize = 10;
H.CrosshairThickness = 1;
H.CrosshairTransparency = 0;
H.CrosshairDistance = 5;
H.CrosshairDot = false;
H.CrosshairOutline = false;
H.CrosshairDotSize = 2;
H.FOVEnabled = false;
H.FOVValue = 70;
H.DefaultFOV = 70;
H.RemoveConstructions = false;
H.RemoveDistance = 75;
H.Spider = false;
H.SpiderSpeed = 30;
H.BindHUD = false;
local function P(E)
	if not E then
		return false;
	end;
	local H = E:FindFirstChildOfClass("Humanoid");
	return H and H.Health > 0;
end;
local function R(E)
	if not E then
		return Vector3.zero;
	end;
	return E.AssemblyLinearVelocity or E.Velocity or Vector3.zero;
end;
local function t()
	local E = H.AimbotKey;
	if typeof(E) == "EnumItem" then
		if E.EnumType == Enum.UserInputType then
			return X:IsMouseButtonPressed(E);
		elseif E.EnumType == Enum.KeyCode then
			return X:IsKeyDown(E);
		end;
	end;
	return false;
end;
local e = {};
local Y = 0;
local function m(E)
	if not E or E == "" then
		return "";
	end;
	local H = E:gsub("^[%s%.\226\128\162%-]+", "");
	H = H:gsub("[%s%.\226\128\162%-]+$", "");
	return H;
end;
local function F()
	local E = os.clock();
	if E - Y < .5 then
		return;
	end;
	Y = E;
	local H = A:FindFirstChild("PlayerGui");
	if not H then
		e = {};
		return;
	end;
	local z = H:FindFirstChild("TeamUI");
	if not z then
		e = {};
		return;
	end;
	local i = z:FindFirstChild("Team");
	if not i then
		e = {};
		return;
	end;
	local c = {};
	for E, H in ipairs(i:GetChildren()) do
		if H:IsA("TextLabel") and H.Text ~= "" then
			local E = m(H.Text);
			if E ~= "" then
				c[E] = true;
			end;
		end;
	end;
	e = c;
end;
local function o(E)
	if not E or not A then
		return false;
	end;
	if E == A then
		return false;
	end;
	F();
	return e[E.Name] == true or e[E.DisplayName] == true;
end;
local S = {
		Head = "Head",
		Chest = "UpperTorso",
		Pelvis = "LowerTorso",
		Nearest = nil,
	};
local function I(E, H)
	if not E then
		return nil;
	end;
	if H == "Nearest" then
		local H = E:FindFirstChild("Head");
		local z = E:FindFirstChild("HumanoidRootPart") or E:FindFirstChild("Torso");
		if H and z then
			local E = g.CFrame.Position;
			local i = ((H.Position - E)).Magnitude;
			local c = ((z.Position - E)).Magnitude;
			if i < c then
				return H;
			else
				return z;
			end;
		end;
		return H or z;
	end;
	local z = S[H];
	if not z then
		return nil;
	end;
	local i = E:FindFirstChild(z);
	if not i and z == "UpperTorso" then
		i = E:FindFirstChild("Torso");
	end;
	if not i and z == "LowerTorso" then
		i = E:FindFirstChild("Torso");
	end;
	return i;
end;
local function b(E, z)
	if not E then
		return Vector3.zero;
	end;
	local i = E.Position;
	if H.DynamicPrediction then
		local E = ((i - g.CFrame.Position)).Magnitude;
		if E < 30 or E > 500 then
			return i;
		end;
	end;
	local c = H.AimbotPrediction or 0;
	if c <= 0 then
		return i;
	end;
	local a = g.CFrame.Position;
	local q = i - a;
	local d = q.Magnitude;
	if d < 1 then
		return i;
	end;
	local Z = R(E);
	local C = q.Unit;
	local B = Z - C * Z:Dot(C);
	local r = Vector3.new(B.X, 0, B.Z);
	local T = math.max(50, H.AimbotBulletSpeed or 450);
	local w = d / T;
	if H.HumanoidCheck and z then
		local H = z:FindFirstChildOfClass("Humanoid");
		if H and H:GetState() == Enum.HumanoidStateType.Freefall then
			if E.Name == "Head" then
				local E = z:FindFirstChild("UpperTorso") or z:FindFirstChild("Torso");
				if E then
					i = E.Position + Vector3.new(0, .5, 0);
				end;
			end;
		end;
	end;
	local V = i + (r * w) * c;
	if H.Ballistic then
		local E = 196.2;
		local H = ((.5 * E) * w) * w;
		V = V + Vector3.new(0, H, 0);
	end;
	return V;
end;
E.Refs.CurrentTarget = nil;
E.Refs.CurrentTargetPart = nil;
E.Refs.weaponColorConn = nil;
E.Refs.lastWeaponModels = {};
E.Refs.aspectConn = nil;
E.Refs.OriginalHitboxSizes = {};
E.Refs.OriginalWeaponProps = {};
E.Refs.freecamConn = nil;
E.Refs.freecamMouseConn = nil;
E.Refs.savedCamType = nil;
E.Refs.savedMouseBehavior = nil;
E.Refs.savedWS = 16;
E.Refs.savedJP = 50;
E.Refs.freecamPos = Vector3.new(0, 0, 0);
E.Refs.freecamYaw = 0;
E.Refs.freecamPitch = 0;
E.Refs.noRecoilConn = nil;
E.Refs.noRecoilShotConn = nil;
E.Refs.lockedCamCF = nil;
E.Refs.recoilActive = false;
E.Refs.recoilLastInput = 0;
E.Refs.savedMotorTransforms = {};
E.Refs.origLight = {
		Brightness = O.Brightness,
		ClockTime = O.ClockTime,
		FogEnd = O.FogEnd,
		FogStart = O.FogStart,
		GlobalShadows = O.GlobalShadows,
		Ambient = O.Ambient,
		OutdoorAmbient = O.OutdoorAmbient,
	};
E.Refs.origAtmosphere = nil;
E.Refs.origClouds = nil;
E.Refs.origSky = nil;
E.Refs.customSky = nil;
E.Refs.Drawings = {};
E.Refs.Highlights = {};
E.Refs.Skeletons = {};
E.Refs.WeaponLabels = {};
E.Refs.SleeperDrawings = {};
E.Refs.SleeperHighlights = {};
E.Refs.SleeperSkeletons = {};
E.Refs.SleeperWeaponLabels = {};
E.Refs.SleeperList = {};
E.Refs.NPCHighlights = {};
E.Refs.NPCList = {};
E.Refs.NPCDrawings = {};
E.Refs.AnimalHighlights = {};
E.Refs.AnimalList = {};
E.Refs.AnimalDrawings = {};
E.Refs.HudPanel = nil;
E.Refs.BindHudPanel = nil;
E.Refs.fpsRow = nil;
E.Refs.pingRow = nil;
E.Refs.hpRow = nil;
E.Refs.posRow = nil;
E.Refs.onlineRow = nil;
E.Refs.hudFrames = 0;
E.Refs.hudLast = os.clock();
E.Refs.DefaultFOV = 70;
E.Refs.fovAnimValue = g.FieldOfView;
E.Refs.gameWantsFOV = g.FieldOfView;
E.Refs.fovAnimActive = false;
E.Refs.lastRealFOV = g.FieldOfView;
E.Refs._fovWriting = false;
E.Refs._fovReading = false;
local function n()
	if H.CameraZoom and H.ZoomActive then
		return 35;
	end;
	if H.FOVEnabled then
		return H.FOVValue;
	end;
	return nil;
end;
local function j(H)
	E.Refs._fovWriting = true;
	pcall(function()
		g.FieldOfView = H;
	end);
	E.Refs._fovWriting = false;
end;
local v = (typeof(hookmetamethod) == "function");
if v then
	pcall(function()
		local H, z = pcall(function()
				local H;
				H = hookmetamethod(game, "__newindex", function(z, i, c)
						if i == "FieldOfView" and (typeof(z) == "Instance" and z:IsA("Camera")) then
							E.Refs.gameWantsFOV = c;
							E.Refs.lastRealFOV = c;
							if E.Refs._fovWriting then
								return H(z, i, c);
							end;
							if n() then
								return H(z, i, E.Refs.fovAnimValue);
							end;
						end;
						return H(z, i, c);
					end);
			end);
		if not H then
			warn("[velcloud.xd] FOV __newindex hook failed:", z);
		end;
	end);
	pcall(function()
		local H, z = pcall(function()
				local H;
				H = hookmetamethod(game, "__index", function(z, i)
						if i == "FieldOfView" and (typeof(z) == "Instance" and z:IsA("Camera")) then
							if E.Refs._fovWriting or E.Refs._fovReading then
								return H(z, i);
							end;
							if n() then
								return E.Refs.gameWantsFOV;
							end;
						end;
						return H(z, i);
					end);
			end);
		if not H then
			warn("[velcloud.xd] FOV __index hook failed:", z);
		end;
	end);
end;
local function y()
	if E.Refs.zoomConn then
		return;
	end;
	if not E.Refs.DefaultFOV or E.Refs.DefaultFOV <= 0 then
		E.Refs.DefaultFOV = g.FieldOfView;
		H.DefaultFOV = E.Refs.DefaultFOV;
	end;
	E.Refs.fovAnimValue = g.FieldOfView;
	E.Refs.gameWantsFOV = g.FieldOfView;
	E.Refs.zoomConn = W.RenderStepped:Connect(function(H)
			local z = n();
			if not z then
				if math.abs(E.Refs.fovAnimValue - E.Refs.DefaultFOV) > .1 then
					E.Refs.fovAnimActive = true;
					local z = math.min(H * 12, 1);
					E.Refs.fovAnimValue = E.Refs.fovAnimValue + ((E.Refs.DefaultFOV - E.Refs.fovAnimValue)) * z;
					if math.abs(E.Refs.fovAnimValue - E.Refs.DefaultFOV) <= .1 then
						E.Refs.fovAnimValue = E.Refs.DefaultFOV;
						E.Refs.fovAnimActive = false;
					end;
					j(E.Refs.fovAnimValue);
				elseif E.Refs.fovAnimActive then
					E.Refs.fovAnimActive = false;
				end;
				return;
			end;
			E.Refs.fovAnimActive = true;
			local i = E.Refs.fovAnimValue;
			if math.abs(i - z) <= .01 then
				E.Refs.fovAnimValue = z;
			else
				local c = math.min(H * 12, 1);
				E.Refs.fovAnimValue = i + ((z - i)) * c;
				if math.abs(E.Refs.fovAnimValue - z) <= .1 then
					E.Refs.fovAnimValue = z;
				end;
			end;
			j(E.Refs.fovAnimValue);
		end);
end;
local function N()
	if E.Refs.zoomConn then
		E.Refs.zoomConn:Disconnect();
		E.Refs.zoomConn = nil;
	end;
	E.Refs.fovAnimActive = false;
end;
local function p()
	y();
end;
p();
local function U(H)
	local z = n() and E.Refs.fovAnimValue or g.FieldOfView;
	local i = g.CFrame:PointToObjectSpace(H);
	if i.Z >= 0 then
		return Vector3.new(0, 0, -1);
	end;
	local c = math.tan(math.rad(z) * .5);
	local a = g.ViewportSize;
	local q = a.X / a.Y;
	local d = i.X / (((-i.Z * c) * q));
	local Z = i.Y / ((-i.Z * c));
	local C = (((d + 1)) * .5) * a.X;
	local B = (((1 - Z)) * .5) * a.Y;
	return Vector3.new(C, B, -i.Z);
end;
if v then
	pcall(function()
		local E = Random.new;
		Random.new = function(z)
				local i = E(z);
				if H.NoSpread then
					local E = i.NextNumber;
					i.NextNumber = function(E, H, z)
							return H or 0;
						end;
					local H = i.NextInteger;
					i.NextInteger = function(E, H, z)
							return H or 0;
						end;
				end;
				return i;
			end;
	end);
end;
E.Refs.CleanerConn = nil;
E.Refs.LastWallScan = 0;
E.Refs.HiddenWalls = {};
local x = Instance.new("Folder");
x.Name = "VEL_HiddenWalls";
local function M(z)
	H.RemoveConstructions = z;
	if z then
		x.Parent = game:GetService("ReplicatedStorage");
		if E.Refs.CleanerConn then
			E.Refs.CleanerConn:Disconnect();
		end;
		E.Refs.CleanerConn = W.Heartbeat:Connect(function()
				if os.clock() - ((E.Refs.LastWallScan or 0)) < .4 then
					return;
				end;
				E.Refs.LastWallScan = os.clock();
				local z = A.Character;
				local i = z and z:FindFirstChild("HumanoidRootPart");
				if not i then
					return;
				end;
				local c = OverlapParams.new();
				c.FilterType = Enum.RaycastFilterType.Exclude;
				c.FilterDescendantsInstances = { z };
				local a = workspace:GetPartBoundsInRadius(i.Position, H.RemoveDistance, c);
				local q = {};
				for H, z in ipairs(a) do
					local i = z.Parent;
					if i and (i:IsA("Model") and not q[i]) then
						local H = string.lower(i.Name);
						if string.find(H, "wall", 1, true) and (not string.find(H, "door") and not string.find(H, "roof")) then
							q[i] = true;
							table.insert(E.Refs.HiddenWalls, { model = i, originalParent = i.Parent });
							i.Parent = x;
						end;
					end;
				end;
			end);
	else
		if E.Refs.CleanerConn then
			E.Refs.CleanerConn:Disconnect();
			E.Refs.CleanerConn = nil;
		end;
		for E, H in ipairs(E.Refs.HiddenWalls) do
			if H.model and H.model.Parent == x then
				H.model.Parent = H.originalParent;
			end;
		end;
		E.Refs.HiddenWalls = {};
		x.Parent = nil;
	end;
end;
local s = nil;
local D = RaycastParams.new();
D.FilterType = Enum.RaycastFilterType.Exclude;
D.FilterDescendantsInstances = { A.Character };
local function h()
	if s then
		pcall(function()
			s:Destroy();
		end);
		s = nil;
	end;
end;
local function f(E)
	if s and s.Parent == E then
		return s;
	end;
	h();
	s = Instance.new("BodyVelocity");
	s.Name = "VEL_Spider";
	s.MaxForce = Vector3.new(0, 15000, 0);
	s.P = 2000;
	s.Velocity = Vector3.zero;
	s.Parent = E;
	return s;
end;
local function L()
	local E = A.Character;
	local z = E and E:FindFirstChild("HumanoidRootPart");
	local i = E and E:FindFirstChildOfClass("Humanoid");
	if not z or not i or i.Health <= 0 then
		h();
		return;
	end;
	if not H.Spider then
		h();
		return;
	end;
	D.FilterDescendantsInstances = { E };
	local c = z.Position;
	local a = {
			g.CFrame.LookVector,
			-g.CFrame.LookVector,
			g.CFrame.RightVector,
			-g.CFrame.RightVector,
		};
	local q = nil;
	for E, H in ipairs(a) do
		local z = Vector3.new(H.X, 0, H.Z);
		if z.Magnitude > .01 then
			local E = workspace:Raycast(c, z.Unit * 2.5, D);
			if E and (E.Instance and E.Instance.CanCollide) then
				q = E;
				break;
			end;
		end;
	end;
	if not q then
		h();
		return;
	end;
	local d = 0;
	if X:IsKeyDown(Enum.KeyCode.W) or X:IsKeyDown(Enum.KeyCode.Space) then
		d = H.SpiderSpeed;
	elseif X:IsKeyDown(Enum.KeyCode.S) or X:IsKeyDown(Enum.KeyCode.LeftControl) then
		d = -H.SpiderSpeed;
	end;
	if d == 0 then
		if s then
			s.Velocity = Vector3.zero;
		end;
		return;
	end;
	local Z = f(z);
	local C = z.AssemblyLinearVelocity or z.Velocity or Vector3.zero;
	Z.Velocity = Vector3.new(C.X, d, C.Z);
end;
W.Heartbeat:Connect(L);
A.CharacterAdded:Connect(function()
	task.wait(.1);
	h();
end);
A.CharacterRemoving:Connect(function()
	h();
end);
local function k(E)
	H.Spider = E;
	if not E then
		h();
	end;
end;
E.Refs.LightingOverride = false;
E.Refs.OrigLighting = {};
E.Refs.DisabledScripts = {};
local function K()
	if E.Refs.LightingOverride then
		return;
	end;
	E.Refs.LightingOverride = true;
	E.Refs.OrigLighting = {
			Ambient = O.Ambient,
			Brightness = O.Brightness,
			ClockTime = O.ClockTime,
			ColorShift_Bottom = O.ColorShift_Bottom,
			ColorShift_Top = O.ColorShift_Top,
			EnvironmentDiffuseScale = O.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = O.EnvironmentSpecularScale,
			FogColor = O.FogColor,
			FogEnd = O.FogEnd,
			FogStart = O.FogStart,
			GlobalShadows = O.GlobalShadows,
			OutdoorAmbient = O.OutdoorAmbient,
			ShadowSoftness = O.ShadowSoftness,
			ExposureCompensation = O.ExposureCompensation,
		};
	local H = { O, A:FindFirstChild("PlayerScripts"), (game:GetService("StarterPlayer")):FindFirstChild("StarterPlayerScripts") };
	for H, z in ipairs(H) do
		if z then
			for H, z in ipairs(z:GetDescendants()) do
				if z:IsA("Script") or z:IsA("LocalScript") then
					local H = z.Source;
					if H and ((string.find(H, "ClockTime") or string.find(H, "Atmosphere") or string.find(H, "Lighting"))) then
						if not z.Disabled then
							z.Disabled = true;
							table.insert(E.Refs.DisabledScripts, z);
						end;
					end;
				end;
			end;
		end;
	end;
end;
local function Ea()
	if not E.Refs.LightingOverride then
		return;
	end;
	E.Refs.LightingOverride = false;
	for E, H in pairs(E.Refs.OrigLighting) do
		if type(E) == "string" then
			pcall(function()
				O[E] = H;
			end);
		end;
	end;
	for E, H in ipairs(E.Refs.DisabledScripts) do
		if H and H.Parent then
			pcall(function()
				H.Disabled = false;
			end);
		end;
	end;
	E.Refs.DisabledScripts = {};
end;
local function Ha()
	if not H.Fullbright then
		return;
	end;
	pcall(function()
		O.Brightness = 2;
		O.ClockTime = 12;
		O.GlobalShadows = false;
		O.FogEnd = 100000;
		O.FogStart = 0;
		O.Ambient = Color3.fromRGB(178, 178, 178);
		O.OutdoorAmbient = Color3.fromRGB(178, 178, 178);
	end);
	for E, H in ipairs(O:GetChildren()) do
		if H:IsA("Atmosphere") or H:IsA("Clouds") then
			H:Destroy();
		end;
	end;
end;
local function za()
	if not H.WorldTimeEnabled then
		return;
	end;
	pcall(function()
		O.ClockTime = H.WorldTimeValue;
		O.Brightness = 1;
		O.GlobalShadows = true;
		O.Ambient = Color3.fromRGB(100, 100, 100);
		O.OutdoorAmbient = Color3.fromRGB(100, 100, 100);
		O.FogEnd = 1000;
	end);
end;
task.spawn(function()
	while true do
		task.wait(.05);
		if H.Fullbright then
			Ha();
		elseif H.WorldTimeEnabled then
			za();
		end;
	end;
end);
if v then
	local E, z = pcall(function()
			local E;
			E = hookmetamethod(game, "__newindex", function(z, i, c)
					if z == O then
						if H.Fullbright or H.WorldTimeEnabled then
							if i == "ClockTime" or i == "Brightness" or i == "GlobalShadows" or i == "Ambient" or i == "OutdoorAmbient" or i == "FogEnd" or i == "FogStart" then
								return;
							end;
						end;
					end;
					return E(z, i, c);
				end);
		end);
	if not E then
		warn("[velcloud.xd] Lighting hook failed:", z);
	end;
end;
local function ia(z, i)
	local c = O;
	if not E.Refs.origSky then
		for H, z in ipairs(c:GetChildren()) do
			if z:IsA("Sky") then
				E.Refs.origSky = z:Clone();
				break;
			end;
		end;
	end;
	if z then
		if not E.Refs.customSky then
			E.Refs.customSky = Instance.new("Sky");
			E.Refs.customSky.Name = "VelcloudCustomSky";
			E.Refs.customSky.Parent = c;
		end;
		local z = i or H.SkyColor;
		E.Refs.customSky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex";
		E.Refs.customSky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex";
		E.Refs.customSky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex";
		E.Refs.customSky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex";
		E.Refs.customSky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex";
		E.Refs.customSky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex";
		E.Refs.customSky.SunAngularSize = 0;
		E.Refs.customSky.MoonAngularSize = 0;
		local a = c:FindFirstChild("VelcloudSkyTint");
		if not a then
			a = Instance.new("ColorCorrectionEffect");
			a.Name = "VelcloudSkyTint";
			a.Parent = c;
		end;
		a.TintColor = z;
		a.Brightness = 0;
		a.Contrast = 0;
		a.Saturation = 0;
	else
		if E.Refs.customSky then
			E.Refs.customSky:Destroy();
			E.Refs.customSky = nil;
		end;
		local H = c:FindFirstChild("VelcloudSkyTint");
		if H then
			H:Destroy();
		end;
	end;
end;
local ca = {
		"Neon",
		"ForceField",
		"Glass",
		"Ice",
		"Marble",
		"Granite",
		"Metal",
		"DiamondPlate",
	};
local function aa(H)
	if E.Refs.OriginalWeaponProps[H] then
		return;
	end;
	local z = H:FindFirstChildOfClass("SpecialMesh");
	local i = H:FindFirstChildOfClass("SurfaceAppearance");
	local c = {};
	for E, H in ipairs(H:GetChildren()) do
		if H:IsA("Decal") or H:IsA("Texture") then
			c[H] = H.Transparency;
		end;
	end;
	E.Refs.OriginalWeaponProps[H] = {
			Color = H.Color,
			Material = H.Material,
			TextureID = H:IsA("MeshPart") and H.TextureID or nil,
			SpecialMeshTexture = z and z.TextureId or nil,
			SpecialMeshId = z and z.MeshId or nil,
			SurfaceAppearanceClone = i and i:Clone() or nil,
			Decals = c,
		};
end;
local function qa(E)
	if not E then
		return;
	end;
	for E, z in ipairs(E:GetDescendants()) do
		if z:IsA("BasePart") then
			aa(z);
			if z:IsA("MeshPart") then
				pcall(function()
					z.TextureID = "";
				end);
			end;
			for E, H in ipairs(z:GetChildren()) do
				if H:IsA("SpecialMesh") then
					pcall(function()
						H.TextureId = "";
					end);
					pcall(function()
						H.MeshId = "";
					end);
				elseif H:IsA("SurfaceAppearance") then
					pcall(function()
						H:Destroy();
					end);
				elseif H:IsA("Decal") or H:IsA("Texture") then
					pcall(function()
						H.Transparency = 1;
					end);
				end;
			end;
			pcall(function()
				z.Color = H.WeaponColor;
			end);
			pcall(function()
				z.Material = H.WeaponMaterial;
			end);
			task.defer(function()
				pcall(function()
					z.Color = H.WeaponColor;
				end);
				pcall(function()
					z.Material = H.WeaponMaterial;
				end);
			end);
		end;
	end;
end;
local function da(H)
	if not H then
		return;
	end;
	for H, z in ipairs(H:GetDescendants()) do
		if z:IsA("BasePart") then
			local H = E.Refs.OriginalWeaponProps[z];
			if H then
				pcall(function()
					z.Color = H.Color;
				end);
				pcall(function()
					z.Material = H.Material;
				end);
				if H.TextureID and z:IsA("MeshPart") then
					pcall(function()
						z.TextureID = H.TextureID;
					end);
				end;
				if H.SpecialMeshTexture then
					local E = z:FindFirstChildOfClass("SpecialMesh");
					if E then
						pcall(function()
							E.TextureId = H.SpecialMeshTexture;
						end);
					end;
				end;
				if H.SpecialMeshId then
					local E = z:FindFirstChildOfClass("SpecialMesh");
					if E then
						pcall(function()
							E.MeshId = H.SpecialMeshId;
						end);
					end;
				end;
				if H.SurfaceAppearanceClone then
					local E = z:FindFirstChildOfClass("SurfaceAppearance");
					if E then
						E:Destroy();
					end;
					local i = H.SurfaceAppearanceClone:Clone();
					i.Parent = z;
				end;
				if H.Decals then
					for E, H in pairs(H.Decals) do
						if E and E.Parent then
							pcall(function()
								E.Transparency = H;
							end);
						end;
					end;
				end;
				E.Refs.OriginalWeaponProps[z] = nil;
			end;
		end;
	end;
end;
local Za = {
		Head = true,
		Torso = true,
		UpperTorso = true,
		LowerTorso = true,
		HumanoidRootPart = true,
		Humanoid = true,
		["Left Arm"] = true,
		["Right Arm"] = true,
		["Left Leg"] = true,
		["Right Leg"] = true,
		LeftUpperArm = true,
		RightUpperArm = true,
		LeftLowerArm = true,
		RightLowerArm = true,
		LeftHand = true,
		RightHand = true,
		LeftUpperLeg = true,
		RightUpperLeg = true,
		LeftLowerLeg = true,
		RightLowerLeg = true,
		LeftFoot = true,
		RightFoot = true,
	};
local Ca = {
		Humanoid = true,
		Animator = true,
		HumanoidDescription = true,
		Accessory = true,
		Accoutrement = true,
		Shirt = true,
		Pants = true,
		ShirtGraphic = true,
		CharacterMesh = true,
		BodyColors = true,
		Script = true,
		LocalScript = true,
		ModuleScript = true,
		Sound = true,
		Animation = true,
		ParticleEmitter = true,
		Fire = true,
		Smoke = true,
		Sparkles = true,
		BillboardGui = true,
		SurfaceGui = true,
		Highlight = true,
		Folder = true,
	};
local function Ba()
	local E = {};
	local H = {};
	local z = A.Character;
	if not z then
		return E;
	end;
	local function i(z)
		if z and (typeof(z) == "Instance" and not H[z]) then
			H[z] = true;
			table.insert(E, z);
		end;
	end;
	for E, H in ipairs(z:GetChildren()) do
		if H:IsA("Tool") then
			i(H);
		end;
	end;
	for E, H in ipairs(z:GetChildren()) do
		if H:IsA("Model") and not H:IsA("Tool") then
			if not Za[H.Name] and not Ca[H.ClassName] then
				local E = false;
				for H, z in ipairs(H:GetChildren()) do
					if z:IsA("BasePart") then
						E = true;
						break;
					end;
				end;
				if E then
					i(H);
				end;
			end;
		end;
	end;
	for E, H in ipairs(z:GetChildren()) do
		if H:IsA("BasePart") and not Za[H.Name] then
			i(H);
		end;
	end;
	for E, H in ipairs(g:GetChildren()) do
		if H:IsA("Model") then
			i(H);
		end;
	end;
	return E;
end;
local function ra()
	if E.Refs.weaponColorConn then
		E.Refs.weaponColorConn:Disconnect();
		E.Refs.weaponColorConn = nil;
	end;
	for E, H in ipairs(E.Refs.lastWeaponModels) do
		da(H);
	end;
	E.Refs.lastWeaponModels = {};
	E.Refs.weaponColorConn = W.Heartbeat:Connect(function()
			if not H.WeaponColorEnabled then
				for E, H in ipairs(E.Refs.lastWeaponModels) do
					da(H);
				end;
				E.Refs.lastWeaponModels = {};
				return;
			end;
			local z = Ba();
			for E, H in ipairs(E.Refs.lastWeaponModels) do
				local i = false;
				for E, z in ipairs(z) do
					if H == z then
						i = true;
						break;
					end;
				end;
				if not i then
					da(H);
				end;
			end;
			E.Refs.lastWeaponModels = z;
			for E, H in ipairs(z) do
				qa(H);
			end;
		end);
end;
local Ta = { ["4:3"] = .75, ["16:9"] = 1 };
local function wa()
	if E.Refs.aspectConn then
		E.Refs.aspectConn:Disconnect();
		E.Refs.aspectConn = nil;
	end;
end;
local function Va()
	wa();
	if not H.AspectRatioEnabled then
		return;
	end;
	local z = Ta[H.AspectRatioMode] or 1;
	H.AspectRatioValue = z;
	E.Refs.aspectConn = W.RenderStepped:Connect(function()
			if not H.AspectRatioEnabled then
				return;
			end;
			g.CFrame = g.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, z, 0, 0, 0, 1);
		end);
end;
local function Ga()
	if H.AspectRatioEnabled then
		Va();
	else
		wa();
	end;
end;
local Qa = {
		lines = {},
		outline = {},
		dot = Drawing.new("Square"),
		dotOutline = Drawing.new("Square"),
		circle = nil,
		circleOutline = nil,
		circleDot = nil,
		circleDotOutline = nil,
	};
local function Ja()
	local E = H.Crosshair or H.CrosshairDot;
	if not E then
		for E, H in pairs(Qa.lines) do
			H.Visible = false;
		end;
		for E, H in pairs(Qa.outline) do
			H.Visible = false;
		end;
		if Qa.circle then
			Qa.circle.Visible = false;
		end;
		if Qa.circleOutline then
			Qa.circleOutline.Visible = false;
		end;
		if Qa.circleDot then
			Qa.circleDot.Visible = false;
		end;
		if Qa.circleDotOutline then
			Qa.circleDotOutline.Visible = false;
		end;
		return;
	end;
	local z = g.ViewportSize;
	local i = math.floor(z.X / 2);
	local c = math.floor(z.Y / 2);
	local a = H.CrosshairColor;
	local q = 1 - (H.CrosshairTransparency / 100);
	local d = H.CrosshairType;
	local Z = math.max(1, math.floor(H.CrosshairThickness));
	if Z % 2 == 0 then
		Z = Z + 1;
	end;
	local C = math.max(2, math.floor(H.CrosshairSize));
	if C % 2 == 1 then
		C = C + 1;
	end;
	local B = math.max(0, math.floor(H.CrosshairDistance));
	for E, H in pairs(Qa.lines) do
		H.Visible = false;
	end;
	for E, H in pairs(Qa.outline) do
		H.Visible = false;
	end;
	if Qa.circle then
		Qa.circle.Visible = false;
	end;
	if Qa.circleOutline then
		Qa.circleOutline.Visible = false;
	end;
	if Qa.circleDot then
		Qa.circleDot.Visible = false;
	end;
	if Qa.circleDotOutline then
		Qa.circleDotOutline.Visible = false;
	end;
	local function r(E, H, z, i, c, d)
		local C = d and Qa.outline or Qa.lines;
		if not C[E] then
			C[E] = Drawing.new("Line");
		end;
		local B = C[E];
		B.Visible = true;
		B.From = Vector2.new(H + .5, z + .5);
		B.To = Vector2.new(i + .5, c + .5);
		B.Color = d and Color3.new(0, 0, 0) or a;
		B.Thickness = d and (Z + 1) or Z;
		B.Transparency = d and (q * .7) or q;
	end;
	if H.Crosshair then
		if d == "Cross" then
			r(1, i, (c - B) - C, i, c - B);
			if H.CrosshairOutline then
				r(1, i, (c - B) - C, i, c - B, true);
			end;
			r(2, i, c + B, i, (c + B) + C);
			if H.CrosshairOutline then
				r(2, i, c + B, i, (c + B) + C, true);
			end;
			r(3, (i - B) - C, c, i - B, c);
			if H.CrosshairOutline then
				r(3, (i - B) - C, c, i - B, c, true);
			end;
			r(4, i + B, c, (i + B) + C, c);
			if H.CrosshairOutline then
				r(4, i + B, c, (i + B) + C, c, true);
			end;
		elseif d == "T-Shape" then
			r(1, i, c + B, i, (c + B) + C);
			if H.CrosshairOutline then
				r(1, i, c + B, i, (c + B) + C, true);
			end;
			r(2, (i - B) - C, c, i - B, c);
			if H.CrosshairOutline then
				r(2, (i - B) - C, c, i - B, c, true);
			end;
			r(3, i + B, c, (i + B) + C, c);
			if H.CrosshairOutline then
				r(3, i + B, c, (i + B) + C, c, true);
			end;
		elseif d == "Circle" then
			if not Qa.circle then
				Qa.circle = Drawing.new("Circle");
				Qa.circle.Filled = false;
				Qa.circle.NumSides = 32;
				Qa.circleOutline = Drawing.new("Circle");
				Qa.circleOutline.Filled = false;
				Qa.circleOutline.NumSides = 32;
			end;
			if H.CrosshairOutline then
				Qa.circleOutline.Visible = true;
				Qa.circleOutline.Position = Vector2.new(i + .5, c + .5);
				Qa.circleOutline.Radius = C + B;
				Qa.circleOutline.Thickness = Z + 1;
				Qa.circleOutline.Color = Color3.new(0, 0, 0);
				Qa.circleOutline.Transparency = q * .5;
			end;
			Qa.circle.Visible = true;
			Qa.circle.Position = Vector2.new(i + .5, c + .5);
			Qa.circle.Radius = C + B;
			Qa.circle.Thickness = Z;
			Qa.circle.Color = a;
			Qa.circle.Transparency = q;
		end;
	end;
	if H.CrosshairDot then
		if not Qa.circleDot then
			Qa.circleDot = Drawing.new("Circle");
			Qa.circleDot.Filled = true;
			Qa.circleDot.NumSides = 16;
			Qa.circleDotOutline = Drawing.new("Circle");
			Qa.circleDotOutline.Filled = true;
			Qa.circleDotOutline.NumSides = 16;
		end;
		local E = math.max(1, math.floor(H.CrosshairDotSize));
		if H.CrosshairOutline then
			Qa.circleDotOutline.Visible = true;
			Qa.circleDotOutline.Position = Vector2.new(i + .5, c + .5);
			Qa.circleDotOutline.Radius = E + 1;
			Qa.circleDotOutline.Color = Color3.new(0, 0, 0);
			Qa.circleDotOutline.Transparency = q * .5;
		end;
		Qa.circleDot.Visible = true;
		Qa.circleDot.Position = Vector2.new(i + .5, c + .5);
		Qa.circleDot.Radius = E;
		Qa.circleDot.Color = a;
		Qa.circleDot.Transparency = q;
	end;
end;
W.RenderStepped:Connect(Ja);
local function Wa(H)
	if not H then
		return;
	end;
	for E, H in pairs(E.Refs.OriginalHitboxSizes) do
		if E and E.Parent then
			pcall(function()
				E.Size = H;
			end);
			pcall(function()
				E.CanCollide = true;
			end);
		end;
	end;
	for H in pairs(E.Refs.OriginalHitboxSizes) do
		if H and not H.Parent then
			E.Refs.OriginalHitboxSizes[H] = nil;
		end;
	end;
end;
local function Xa()
	for E, H in ipairs(J:GetPlayers()) do
		if H.Character then
			Wa(H.Character);
		end;
	end;
end;
local function ua(z)
	if not z then
		return;
	end;
	local i = z:FindFirstChildOfClass("Humanoid");
	if not i or i.Health <= 0 then
		return;
	end;
	local c = H.HitboxSize or 2;
	for z, i in ipairs(z:GetChildren()) do
		if i:IsA("BasePart") then
			local z = i.Name;
			if z == "Head" or z == "Torso" or z == "UpperTorso" or z == "LowerTorso" or z == "HumanoidRootPart" or z == "Left Arm" or z == "Right Arm" or z == "Left Leg" or z == "Right Leg" or z == "LeftUpperArm" or z == "RightUpperArm" or z == "LeftLowerArm" or z == "RightLowerArm" or z == "LeftUpperLeg" or z == "RightUpperLeg" or z == "LeftLowerLeg" or z == "RightLowerLeg" then
				if not E.Refs.OriginalHitboxSizes[i] then
					E.Refs.OriginalHitboxSizes[i] = i.Size;
				end;
				pcall(function()
					i.Size = E.Refs.OriginalHitboxSizes[i] * c;
				end);
				if H.HitboxTransparency > 0 then
					pcall(function()
						i.Transparency = math.clamp(H.HitboxTransparency / 100, 0, 1);
					end);
				end;
			end;
		end;
	end;
end;
local function Oa()
	for E, z in ipairs(J:GetPlayers()) do
		if z ~= A and z.Character then
			if H.HitboxEnabled and P(z.Character) then
				ua(z.Character);
			else
				Wa(z.Character);
			end;
		end;
	end;
end;
local Aa = RaycastParams.new();
Aa.FilterType = Enum.RaycastFilterType.Exclude;
local function ga(E)
	if not E then
		return false;
	end;
	Aa.FilterDescendantsInstances = { A.Character, E.Parent };
	local H = g.CFrame.Position;
	local z = (E.Position - H);
	local i = workspace:Raycast(H, z, Aa);
	return i == nil;
end;
local function la(E)
	for H, z in ipairs(J:GetPlayers()) do
		if z.Character == E then
			return true;
		end;
	end;
	return false;
end;
local function Pa(E)
	local H = string.lower(E.Name);
	return H == "scientist";
end;
local function Ra(E)
	local H = string.lower(E.Name);
	return H == "bear" or H == "wolf" or H == "boar" or H == "stag";
end;
local function ta()
	local z, i;
	local c = math.huge;
	local a = A.Character and A.Character:FindFirstChild("HumanoidRootPart");
	if not a then
		return nil, nil;
	end;
	local q = a.Position;
	local d = g.ViewportSize;
	local Z = Vector2.new(d.X / 2, d.Y / 2);
	for E, a in ipairs(J:GetPlayers()) do
		if a ~= A and P(a.Character) then
			if H.AimbotIgnoreTeam and o(a) then
				continue;
			end;
			local E = a.Character;
			local d = I(E, H.AimbotBone);
			if d then
				local E = ((d.Position - q)).Magnitude;
				if E > H.AimbotDistanceLimit then
					continue;
				end;
				local C = U(d.Position);
				if C.Z > 0 then
					local q = ((Z - Vector2.new(C.X, C.Y))).Magnitude;
					if q < H.AimbotFOV then
						if H.AimbotVisibleCheck and not ga(d) then
							continue;
						end;
						if E < c then
							c = E;
							z = a;
							i = d;
						end;
					end;
				end;
			end;
		end;
	end;
	if not H.AimbotIgnoreNPC then
		for E, a in ipairs(E.Refs.NPCList or {}) do
			if a.Parent and (P(a) and (not la(a) and Pa(a))) then
				local E = I(a, H.AimbotBone);
				if E then
					local d = ((E.Position - q)).Magnitude;
					if d > H.AimbotDistanceLimit then
						continue;
					end;
					local C = U(E.Position);
					if C.Z > 0 then
						local q = ((Z - Vector2.new(C.X, C.Y))).Magnitude;
						if q < H.AimbotFOV then
							if H.AimbotVisibleCheck and not ga(E) then
								continue;
							end;
							if d < c then
								c = d;
								z = a;
								i = E;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	if not H.AimbotIgnoreAnimals then
		for E, a in ipairs(E.Refs.AnimalList or {}) do
			if a.Parent and (P(a) and (not la(a) and Ra(a))) then
				local E = I(a, H.AimbotBone);
				if E then
					local d = ((E.Position - q)).Magnitude;
					if d > H.AimbotDistanceLimit then
						continue;
					end;
					local C = U(E.Position);
					if C.Z > 0 then
						local q = ((Z - Vector2.new(C.X, C.Y))).Magnitude;
						if q < H.AimbotFOV then
							if H.AimbotVisibleCheck and not ga(E) then
								continue;
							end;
							if d < c then
								c = d;
								z = a;
								i = E;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	return z, i;
end;
W:BindToRenderStep("VelcloudAimbot", Enum.RenderPriority.Last.Value, function(z)
	if not H.AimbotEnabled then
		E.Refs.CurrentTargetPart = nil;
		if g.CameraType == Enum.CameraType.Scriptable then
			g.CameraType = Enum.CameraType.Custom;
		end;
		return;
	end;
	local i, c = ta();
	if H.AimbotAutoSwitch then
		if not c then
			E.Refs.CurrentTarget = nil;
			E.Refs.CurrentTargetPart = nil;
		else
			E.Refs.CurrentTarget = i;
			E.Refs.CurrentTargetPart = c;
		end;
	else
		if not E.Refs.CurrentTargetPart or not E.Refs.CurrentTargetPart.Parent then
			E.Refs.CurrentTarget = i;
			E.Refs.CurrentTargetPart = c;
		end;
	end;
	if not E.Refs.CurrentTargetPart then
		if g.CameraType == Enum.CameraType.Scriptable then
			g.CameraType = Enum.CameraType.Custom;
		end;
		return;
	end;
	if not t() then
		if g.CameraType == Enum.CameraType.Scriptable then
			g.CameraType = Enum.CameraType.Custom;
		end;
		return;
	end;
	if H.AimbotType == "Mouse" then
		local i = g.CFrame.Position;
		local c = b(E.Refs.CurrentTargetPart, E.Refs.CurrentTargetPart.Parent);
		local a = CFrame.lookAt(i, c);
		local q = 1 / math.max(1, H.AimbotSmooth);
		local d = 1 - ((1 - q)) ^ ((z * 60));
		g.CFrame = g.CFrame:Lerp(a, d);
	end;
end);
local ea = Drawing.new("Circle");
ea.Thickness = 1;
ea.Color = Color3.fromRGB(255, 255, 255);
ea.Filled = false;
ea.Visible = false;
ea.NumSides = 64;
local Ya = Drawing.new("Circle");
Ya.Thickness = 2;
Ya.Color = Color3.fromRGB(255, 0, 0);
Ya.Filled = false;
Ya.Visible = false;
Ya.NumSides = 32;
W.RenderStepped:Connect(function()
	if H.AimbotEnabled and H.AimbotDrawFOV then
		ea.Position = Vector2.new(g.ViewportSize.X / 2, g.ViewportSize.Y / 2);
		ea.Radius = H.AimbotFOV;
		ea.Color = H.AimbotDrawFOVColor;
		ea.Visible = true;
	else
		ea.Visible = false;
	end;
	if H.AimbotEnabled and (H.AimbotDrawTarget and E.Refs.CurrentTargetPart) then
		local z = U(E.Refs.CurrentTargetPart.Position);
		if z.Z > 0 then
			Ya.Position = Vector2.new(z.X, z.Y);
			Ya.Radius = 20;
			Ya.Color = H.AimbotDrawTargetColor;
			Ya.Visible = true;
		else
			Ya.Visible = false;
		end;
	else
		Ya.Visible = false;
	end;
end);
local function ma()
	if E.Refs.freecamConn then
		E.Refs.freecamConn:Disconnect();
		E.Refs.freecamConn = nil;
	end;
	if E.Refs.freecamMouseConn then
		E.Refs.freecamMouseConn:Disconnect();
		E.Refs.freecamMouseConn = nil;
	end;
	if E.Refs.savedCamType then
		g.CameraType = E.Refs.savedCamType;
		E.Refs.savedCamType = nil;
	end;
	if E.Refs.savedMouseBehavior then
		X.MouseBehavior = E.Refs.savedMouseBehavior;
		E.Refs.savedMouseBehavior = nil;
	end;
	local z = A.Character and A.Character:FindFirstChildOfClass("Humanoid");
	if z then
		z.WalkSpeed = E.Refs.savedWS;
		z.JumpPower = E.Refs.savedJP;
	end;
	H.FreeCam = false;
end;
local function Fa()
	if E.Refs.freecamConn then
		return;
	end;
	E.Refs.savedCamType = g.CameraType;
	g.CameraType = Enum.CameraType.Scriptable;
	E.Refs.savedMouseBehavior = X.MouseBehavior;
	X.MouseBehavior = Enum.MouseBehavior.LockCenter;
	E.Refs.freecamPos = g.CFrame.Position;
	local z = g.CFrame.LookVector;
	E.Refs.freecamYaw = math.atan2(-z.X, -z.Z);
	E.Refs.freecamPitch = math.asin(math.clamp(z.Y, -1, 1));
	local i = A.Character and A.Character:FindFirstChildOfClass("Humanoid");
	if i then
		E.Refs.savedWS = i.WalkSpeed;
		E.Refs.savedJP = i.JumpPower;
		i.WalkSpeed = 0;
		i.JumpPower = 0;
	end;
	E.Refs.freecamMouseConn = X.InputChanged:Connect(function(H)
			if H.UserInputType == Enum.UserInputType.MouseMovement then
				E.Refs.freecamYaw = E.Refs.freecamYaw - H.Delta.X * .005;
				E.Refs.freecamPitch = math.clamp(E.Refs.freecamPitch - H.Delta.Y * .005, -math.rad(89), math.rad(89));
			end;
		end);
	E.Refs.freecamConn = W.RenderStepped:Connect(function(H)
			local z = X:IsKeyDown(Enum.KeyCode.LeftShift) and 150 or 50;
			local i = CFrame.fromEulerAnglesYXZ(E.Refs.freecamPitch, E.Refs.freecamYaw, 0);
			local c = Vector3.new(0, 0, 0);
			if X:IsKeyDown(Enum.KeyCode.W) then
				c = c + i.LookVector;
			end;
			if X:IsKeyDown(Enum.KeyCode.S) then
				c = c - i.LookVector;
			end;
			if X:IsKeyDown(Enum.KeyCode.A) then
				c = c - i.RightVector;
			end;
			if X:IsKeyDown(Enum.KeyCode.D) then
				c = c + i.RightVector;
			end;
			if X:IsKeyDown(Enum.KeyCode.Space) then
				c = c + Vector3.new(0, 1, 0);
			end;
			if X:IsKeyDown(Enum.KeyCode.LeftControl) then
				c = c - Vector3.new(0, 1, 0);
			end;
			if c.Magnitude > 0 then
				E.Refs.freecamPos = E.Refs.freecamPos + (c.Unit * z) * H;
			end;
			g.CFrame = CFrame.new(E.Refs.freecamPos) * i;
		end);
	H.FreeCam = true;
end;
A.CharacterAdded:Connect(function()
	task.wait(.1);
	if E.Refs.freecamConn then
		ma();
	end;
end);
local oa = nil;
local Sa = {};
local function Ia()
	if oa then
		oa:Disconnect();
	end;
	Sa = {};
	oa = W.RenderStepped:Connect(function()
			if not H.NoRecoil then
				return;
			end;
			local E = A.Character;
			if not E then
				return;
			end;
			local z = E:FindFirstChildOfClass("Humanoid");
			if not z then
				return;
			end;
			if z.CameraOffset.Magnitude > .001 then
				z.CameraOffset = Vector3.zero;
			end;
			local i = X:IsMouseButtonPressed(Enum.UserInputType.MouseButton1);
			for E, H in ipairs(E:GetDescendants()) do
				if H:IsA("Motor6D") then
					if H.Name == "Neck" or H.Name == "RightShoulder" or H.Name == "LeftShoulder" then
						if i then
							if not Sa[H] then
								Sa[H] = H.Transform;
							end;
							if H.Transform ~= Sa[H] then
								H.Transform = Sa[H];
							end;
						else
							Sa[H] = nil;
						end;
					end;
				end;
			end;
		end);
end;
local function ba()
	if oa then
		oa:Disconnect();
		oa = nil;
	end;
	Sa = {};
	local E = A.Character;
	if E then
		local H = E:FindFirstChildOfClass("Humanoid");
		if H then
			H.CameraOffset = Vector3.zero;
		end;
	end;
end;
local function na(H)
	if H == A or E.Refs.Drawings[H] then
		return;
	end;
	local z = {};
	z.Box = Drawing.new("Square");
	z.Box.Thickness = 1;
	z.Box.Filled = false;
	z.Box.Visible = false;
	z.Name = Drawing.new("Text");
	z.Name.Size = 14;
	z.Name.Center = true;
	z.Name.Outline = true;
	z.Name.Visible = false;
	z.Health = Drawing.new("Text");
	z.Health.Size = 12;
	z.Health.Center = true;
	z.Health.Outline = true;
	z.Health.Visible = false;
	z.Line = Drawing.new("Line");
	z.Line.Thickness = 1;
	z.Line.Visible = false;
	z.Distance = Drawing.new("Text");
	z.Distance.Size = 12;
	z.Distance.Center = true;
	z.Distance.Outline = true;
	z.Distance.Visible = false;
	z.Weapon = Drawing.new("Text");
	z.Weapon.Size = 12;
	z.Weapon.Center = true;
	z.Weapon.Outline = true;
	z.Weapon.Visible = false;
	E.Refs.Drawings[H] = z;
end;
local function ja(H)
	if E.Refs.Highlights[H] then
		pcall(function()
			E.Refs.Highlights[H]:Destroy();
		end);
		E.Refs.Highlights[H] = nil;
	end;
end;
local function va(H)
	if E.Refs.Drawings[H] then
		for E, H in pairs(E.Refs.Drawings[H]) do
			if H then
				pcall(function()
					H:Remove();
				end);
			end;
		end;
		E.Refs.Drawings[H] = nil;
	end;
	ja(H);
	if E.Refs.Skeletons[H] then
		for E, H in pairs(E.Refs.Skeletons[H].lines) do
			pcall(function()
				H:Remove();
			end);
		end;
		E.Refs.Skeletons[H] = nil;
	end;
	if E.Refs.WeaponLabels[H] then
		pcall(function()
			E.Refs.WeaponLabels[H]:Remove();
		end);
		E.Refs.WeaponLabels[H] = nil;
	end;
end;
local function ya(z)
	if z == A then
		return;
	end;
	local i = z.Character;
	local c = H.ESP and H.MaxDistance > 0;
	if not c or not i or not P(i) then
		ja(z);
		return;
	end;
	local a = E.Refs.Highlights[z];
	if not a or not a.Parent then
		if a then
			pcall(function()
				a:Destroy();
			end);
		end;
		a = Instance.new("Highlight");
		a.Name = "VelcloudESP";
		a.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
		a.Parent = i;
		E.Refs.Highlights[z] = a;
	end;
	if a.DepthMode ~= Enum.HighlightDepthMode.AlwaysOnTop then
		a.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
	end;
	local q = H.TeamCheck and o(z);
	local d = q and H.TeamColor or H.ESPColor;
	if H.ESPMode == "Chams" then
		a.FillColor = d;
		a.FillTransparency = 0;
		a.OutlineColor = d;
		a.OutlineTransparency = 1;
	else
		a.FillColor = d;
		a.FillTransparency = 1;
		a.OutlineColor = d;
		a.OutlineTransparency = 0;
	end;
end;
local Na = {
		{ "Head", "UpperTorso" },
		{ "UpperTorso", "LowerTorso" },
		{ "UpperTorso", "LeftUpperArm" },
		{ "LeftUpperArm", "LeftLowerArm" },
		{ "UpperTorso", "RightUpperArm" },
		{ "RightUpperArm", "RightLowerArm" },
		{ "LowerTorso", "LeftUpperLeg" },
		{ "LeftUpperLeg", "LeftLowerLeg" },
		{ "LowerTorso", "RightUpperLeg" },
		{ "RightUpperLeg", "RightLowerLeg" },
	};
local pa = {
		{ "Head", "Torso" },
		{ "Torso", "Left Arm" },
		{ "Torso", "Right Arm" },
		{ "Torso", "Left Leg" },
		{ "Torso", "Right Leg" },
	};
local function Ua(H, z)
	local i = E.Refs.Skeletons[H];
	local c = z and Na or pa;
	if i and #i.lines == #c then
		return;
	end;
	if i then
		for E, H in pairs(i.lines) do
			pcall(function()
				H:Remove();
			end);
		end;
	end;
	local a = {};
	for E = 1, #c, 1 do
		local H = Drawing.new("Line");
		H.Thickness = 1;
		H.Visible = false;
		a[E] = H;
	end;
	E.Refs.Skeletons[H] = { lines = a, conns = c };
end;
local function xa(z, i)
	local c = i:FindFirstChild("UpperTorso") ~= nil;
	Ua(z, c);
	local a = E.Refs.Skeletons[z];
	if not a then
		return;
	end;
	local q = H.TeamCheck and o(z);
	local d = q and H.TeamColor or H.SkeletonColor;
	for E, H in ipairs(a.conns) do
		local z = i:FindFirstChild(H[1]);
		local c = i:FindFirstChild(H[2]);
		local q = a.lines[E];
		if z and c then
			local E = U(z.Position);
			local H = U(c.Position);
			if E.Z > 0 and H.Z > 0 then
				q.From = Vector2.new(E.X, E.Y);
				q.To = Vector2.new(H.X, H.Y);
				q.Color = d;
				q.Visible = true;
			elseif q.Visible then
				q.Visible = false;
			end;
		elseif q.Visible then
			q.Visible = false;
		end;
	end;
end;
local Ma = {
		Handle = true,
		Grip = true,
		Attachment = true,
		Attachment1 = true,
		LeftGrip = true,
		RightGrip = true,
		Tool = true,
		Head = true,
		Torso = true,
		UpperTorso = true,
		LowerTorso = true,
		["Left Arm"] = true,
		["Right Arm"] = true,
		["Left Leg"] = true,
		["Right Leg"] = true,
		LeftUpperArm = true,
		RightUpperArm = true,
		LeftLowerArm = true,
		RightLowerArm = true,
		LeftUpperLeg = true,
		RightUpperLeg = true,
		LeftLowerLeg = true,
		RightLowerLeg = true,
		HumanoidRootPart = true,
		Humanoid = true,
		[""] = true,
		None = true,
		Nil = true,
		Part = true,
		Mesh = true,
	};
local function sa(E)
	if not E or E == "" then
		return false;
	end;
	if Ma[E] then
		return false;
	end;
	if #E < 2 then
		return false;
	end;
	if tonumber(E) then
		return false;
	end;
	return true;
end;
local function Da(E)
	if not E then
		return nil;
	end;
	local H = E:FindFirstChildOfClass("Tool");
	if not H then
		return nil;
	end;
	if sa(H.Name) then
		return H.Name;
	end;
	for E, H in ipairs(H:GetChildren()) do
		if H:IsA("BasePart") and sa(H.Name) then
			return H.Name;
		end;
	end;
	return nil;
end;
local function ha(z, i, c)
	local a = E.Refs.Highlights[z];
	if not a or not a.Parent then
		return;
	end;
	local q = H.ESP and (H.MaxDistance > 0 and (c and i <= H.MaxDistance));
	if a.Enabled ~= q then
		a.Enabled = q;
	end;
end;
local function fa()
	for E, H in pairs(E.Refs.Drawings) do
		if H.Box.Visible then
			H.Box.Visible = false;
		end;
		if H.Name.Visible then
			H.Name.Visible = false;
		end;
		if H.Health.Visible then
			H.Health.Visible = false;
		end;
		if H.Line.Visible then
			H.Line.Visible = false;
		end;
		if H.Distance.Visible then
			H.Distance.Visible = false;
		end;
		if H.Weapon.Visible then
			H.Weapon.Visible = false;
		end;
	end;
	for E, H in pairs(E.Refs.Skeletons) do
		for E, H in pairs(H.lines) do
			if H.Visible then
				H.Visible = false;
			end;
		end;
	end;
	for E, H in pairs(E.Refs.Highlights) do
		if H and (H.Parent and H.Enabled) then
			H.Enabled = false;
		end;
	end;
end;
local function La()
	if not H.ESP or H.MaxDistance <= 0 then
		fa();
		return;
	end;
	local z = A.Character and A.Character:FindFirstChild("HumanoidRootPart");
	if not z then
		fa();
		return;
	end;
	local i = z.Position;
	local c = g.ViewportSize;
	for z, a in pairs(E.Refs.Drawings) do
		local q = z.Character;
		local d = q and q:FindFirstChild("HumanoidRootPart");
		local Z = q and q:FindFirstChildOfClass("Humanoid");
		if not d or not Z or Z.Health <= 0 then
			if a.Box.Visible then
				a.Box.Visible = false;
			end;
			if a.Name.Visible then
				a.Name.Visible = false;
			end;
			if a.Health.Visible then
				a.Health.Visible = false;
			end;
			if a.Line.Visible then
				a.Line.Visible = false;
			end;
			if a.Distance.Visible then
				a.Distance.Visible = false;
			end;
			if a.Weapon.Visible then
				a.Weapon.Visible = false;
			end;
			local H = E.Refs.Skeletons[z];
			if H then
				for E, H in pairs(H.lines) do
					if H.Visible then
						H.Visible = false;
					end;
				end;
			end;
			ha(z, math.huge, false);
			continue;
		end;
		local C = ((d.Position - i)).Magnitude;
		if C > H.MaxDistance then
			if a.Box.Visible then
				a.Box.Visible = false;
			end;
			if a.Name.Visible then
				a.Name.Visible = false;
			end;
			if a.Health.Visible then
				a.Health.Visible = false;
			end;
			if a.Line.Visible then
				a.Line.Visible = false;
			end;
			if a.Distance.Visible then
				a.Distance.Visible = false;
			end;
			if a.Weapon.Visible then
				a.Weapon.Visible = false;
			end;
			local H = E.Refs.Skeletons[z];
			if H then
				for E, H in pairs(H.lines) do
					if H.Visible then
						H.Visible = false;
					end;
				end;
			end;
			ha(z, C, false);
			continue;
		end;
		local B = U(d.Position);
		if B.Z <= 0 then
			if a.Box.Visible then
				a.Box.Visible = false;
			end;
			if a.Name.Visible then
				a.Name.Visible = false;
			end;
			if a.Health.Visible then
				a.Health.Visible = false;
			end;
			if a.Line.Visible then
				a.Line.Visible = false;
			end;
			if a.Distance.Visible then
				a.Distance.Visible = false;
			end;
			if a.Weapon.Visible then
				a.Weapon.Visible = false;
			end;
			local H = E.Refs.Skeletons[z];
			if H then
				for E, H in pairs(H.lines) do
					if H.Visible then
						H.Visible = false;
					end;
				end;
			end;
			ha(z, C, false);
			continue;
		end;
		local r, T = B.X, B.Y;
		local w = q:FindFirstChild("Head") or d;
		local V = w.Position + Vector3.new(0, 1.5, 0);
		local G = d.Position - Vector3.new(0, 2.5, 0);
		local Q = U(V);
		local J = U(G);
		local W = H.TeamCheck and o(z);
		local X = W and H.TeamColor or H.BoxColor;
		local u = W and H.TeamColor or H.TextColor;
		local O = W and H.TeamColor or H.LineColor;
		if H.Box and (Q.Z > 0 and J.Z > 0) then
			local E = math.abs(Q.Y - J.Y);
			local H = E * .5;
			a.Box.Size = Vector2.new(H, E);
			a.Box.Position = Vector2.new(r - H / 2, Q.Y);
			a.Box.Color = X;
			if not a.Box.Visible then
				a.Box.Visible = true;
			end;
		elseif a.Box.Visible then
			a.Box.Visible = false;
		end;
		if H.Name then
			a.Name.Text = z.Name;
			a.Name.Position = Vector2.new(r, Q.Y - 18);
			a.Name.Color = u;
			if not a.Name.Visible then
				a.Name.Visible = true;
			end;
		elseif a.Name.Visible then
			a.Name.Visible = false;
		end;
		if H.Health then
			a.Health.Text = "HP: " .. (math.floor(Z.Health) .. ("/" .. math.floor(Z.MaxHealth)));
			a.Health.Position = Vector2.new(r, J.Y + 2);
			a.Health.Color = u;
			if not a.Health.Visible then
				a.Health.Visible = true;
			end;
		elseif a.Health.Visible then
			a.Health.Visible = false;
		end;
		if H.Distance then
			a.Distance.Text = math.floor(C) .. "m";
			a.Distance.Position = Vector2.new(r, J.Y + 18);
			a.Distance.Color = u;
			if not a.Distance.Visible then
				a.Distance.Visible = true;
			end;
		elseif a.Distance.Visible then
			a.Distance.Visible = false;
		end;
		if H.Line then
			a.Line.From = Vector2.new(c.X / 2, c.Y);
			a.Line.To = Vector2.new(r, T);
			a.Line.Color = O;
			if not a.Line.Visible then
				a.Line.Visible = true;
			end;
		elseif a.Line.Visible then
			a.Line.Visible = false;
		end;
		if H.WeaponESP then
			local E = Da(q);
			if E then
				a.Weapon.Text = "[" .. (E .. "]");
				a.Weapon.Position = Vector2.new(r, J.Y + 34);
				a.Weapon.Color = u;
				if not a.Weapon.Visible then
					a.Weapon.Visible = true;
				end;
			elseif a.Weapon.Visible then
				a.Weapon.Visible = false;
			end;
		elseif a.Weapon.Visible then
			a.Weapon.Visible = false;
		end;
		if H.Skeleton then
			xa(z, q);
		else
			local H = E.Refs.Skeletons[z];
			if H then
				for E, H in pairs(H.lines) do
					if H.Visible then
						H.Visible = false;
					end;
				end;
			end;
		end;
		ha(z, C, true);
		local A = E.Refs.Highlights[z];
		if A and A.Parent then
			local E = H.TeamCheck and o(z);
			local i = E and H.TeamColor or H.ESPColor;
			if A.FillColor ~= i then
				A.FillColor = i;
				if H.ESPMode == "Chams" then
					A.FillTransparency = 0;
					A.OutlineColor = i;
					A.OutlineTransparency = 1;
				else
					A.FillTransparency = 1;
					A.OutlineColor = i;
					A.OutlineTransparency = 0;
				end;
			end;
		end;
	end;
end;
E.Refs.SleeperList = {};
E.Refs.SleeperDrawings = {};
E.Refs.SleeperHighlights = {};
E.Refs.SleeperSkeletons = {};
local function ka()
	if not H.ESP_Sleeper then
		E.Refs.SleeperList = {};
		return;
	end;
	local z = {};
	local i = workspace:FindFirstChild("SleepingPlayers");
	if i then
		for E, H in ipairs(i:GetChildren()) do
			if H:IsA("Model") and H.Name == "Sleeper" then
				local E = H:FindFirstChildOfClass("Humanoid");
				if E then
					z[#z + 1] = H;
				end;
			end;
		end;
	end;
	E.Refs.SleeperList = z;
end;
local function Ka(H)
	if E.Refs.SleeperDrawings[H] then
		return E.Refs.SleeperDrawings[H];
	end;
	local z = {};
	z.Box = Drawing.new("Square");
	z.Box.Thickness = 1;
	z.Box.Filled = false;
	z.Box.Visible = false;
	z.Name = Drawing.new("Text");
	z.Name.Size = 14;
	z.Name.Center = true;
	z.Name.Outline = true;
	z.Name.Visible = false;
	z.Health = Drawing.new("Text");
	z.Health.Size = 12;
	z.Health.Center = true;
	z.Health.Outline = true;
	z.Health.Visible = false;
	z.Line = Drawing.new("Line");
	z.Line.Thickness = 1;
	z.Line.Visible = false;
	z.Distance = Drawing.new("Text");
	z.Distance.Size = 12;
	z.Distance.Center = true;
	z.Distance.Outline = true;
	z.Distance.Visible = false;
	z.Weapon = Drawing.new("Text");
	z.Weapon.Size = 12;
	z.Weapon.Center = true;
	z.Weapon.Outline = true;
	z.Weapon.Visible = false;
	E.Refs.SleeperDrawings[H] = z;
	return z;
end;
local function E6(H)
	local z = E.Refs.SleeperDrawings[H];
	if z then
		for E, H in pairs(z) do
			pcall(function()
				H:Remove();
			end);
		end;
		E.Refs.SleeperDrawings[H] = nil;
	end;
	local i = E.Refs.SleeperHighlights[H];
	if i then
		pcall(function()
			i:Destroy();
		end);
		E.Refs.SleeperHighlights[H] = nil;
	end;
	local c = E.Refs.SleeperSkeletons[H];
	if c then
		for E, H in pairs(c.lines) do
			pcall(function()
				H:Remove();
			end);
		end;
		E.Refs.SleeperSkeletons[H] = nil;
	end;
end;
local function H6(H, z)
	local i = E.Refs.SleeperSkeletons[H];
	local c = z and Na or pa;
	if i and #i.lines == #c then
		return;
	end;
	if i then
		for E, H in pairs(i.lines) do
			pcall(function()
				H:Remove();
			end);
		end;
	end;
	local a = {};
	for E = 1, #c, 1 do
		local H = Drawing.new("Line");
		H.Thickness = 1;
		H.Visible = false;
		a[E] = H;
	end;
	E.Refs.SleeperSkeletons[H] = { lines = a, conns = c };
end;
local function z6(z)
	local i = z:FindFirstChild("UpperTorso") ~= nil;
	H6(z, i);
	local c = E.Refs.SleeperSkeletons[z];
	if not c then
		return;
	end;
	for E, i in ipairs(c.conns) do
		local a = z:FindFirstChild(i[1]);
		local q = z:FindFirstChild(i[2]);
		local d = c.lines[E];
		if a and q then
			local E = U(a.Position);
			local z = U(q.Position);
			if E.Z > 0 and z.Z > 0 then
				d.From = Vector2.new(E.X, E.Y);
				d.To = Vector2.new(z.X, z.Y);
				d.Color = H.SleeperColor;
				d.Visible = true;
			elseif d.Visible then
				d.Visible = false;
			end;
		elseif d.Visible then
			d.Visible = false;
		end;
	end;
end;
local function i6()
	for E, H in pairs(E.Refs.SleeperDrawings) do
		H.Box.Visible = false;
		H.Name.Visible = false;
		H.Health.Visible = false;
		H.Distance.Visible = false;
		H.Line.Visible = false;
		H.Weapon.Visible = false;
	end;
	for E, H in pairs(E.Refs.SleeperHighlights) do
		if H and H.Parent then
			H.Enabled = false;
		end;
	end;
	for E, H in pairs(E.Refs.SleeperSkeletons) do
		for E, H in pairs(H.lines) do
			if H.Visible then
				H.Visible = false;
			end;
		end;
	end;
end;
local function c6()
	if not H.ESP_Sleeper then
		i6();
		return;
	end;
	local z = A.Character and A.Character:FindFirstChild("HumanoidRootPart");
	if not z then
		i6();
		return;
	end;
	local i = z.Position;
	local c = g.ViewportSize;
	local a = E.Refs.SleeperList or {};
	local q = {};
	local d = H.SleeperColor;
	for z, a in ipairs(a) do
		if a.Parent then
			local z = a:FindFirstChild("HumanoidRootPart") or a:FindFirstChild("Torso") or a:FindFirstChild("Head");
			if z and z:IsA("BasePart") then
				local Z = a:FindFirstChildOfClass("Humanoid");
				local C = ((z.Position - i)).Magnitude;
				if C <= H.MaxDistance then
					q[a] = true;
					local i = E.Refs.SleeperHighlights[a];
					if not i or not i.Parent then
						if i then
							pcall(function()
								i:Destroy();
							end);
						end;
						i = Instance.new("Highlight");
						i.Name = "VelcloudSleeper";
						i.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
						i.Parent = a;
						E.Refs.SleeperHighlights[a] = i;
					end;
					if i.FillColor ~= d then
						i.FillColor = d;
						i.OutlineColor = d;
					end;
					if H.ESPMode == "Chams" then
						i.FillTransparency = 0;
						i.OutlineTransparency = 1;
					else
						i.FillTransparency = 1;
						i.OutlineTransparency = 0;
					end;
					i.Enabled = true;
					local B = a:FindFirstChild("Head");
					local r = Ka(a);
					local T = U(z.Position);
					if B and T.Z > 0 then
						local E = U(B.Position + Vector3.new(0, 1.5, 0));
						local i = U(z.Position - Vector3.new(0, 2.5, 0));
						if E.Z > 0 and i.Z > 0 then
							local z = math.abs(E.Y - i.Y);
							local q = z * .5;
							if H.Box then
								r.Box.Size = Vector2.new(q, z);
								r.Box.Position = Vector2.new(T.X - q / 2, E.Y);
								r.Box.Color = d;
								r.Box.Visible = true;
							else
								r.Box.Visible = false;
							end;
							if H.Name then
								r.Name.Text = a.Name;
								r.Name.Position = Vector2.new(T.X, E.Y - 18);
								r.Name.Color = d;
								r.Name.Visible = true;
							else
								r.Name.Visible = false;
							end;
							if H.Health then
								if Z then
									r.Health.Text = "HP: " .. (math.floor(Z.Health) .. ("/" .. math.floor(Z.MaxHealth)));
									r.Health.Position = Vector2.new(T.X, i.Y + 2);
									r.Health.Color = d;
									r.Health.Visible = true;
								else
									r.Health.Visible = false;
								end;
							else
								r.Health.Visible = false;
							end;
							if H.Distance then
								r.Distance.Text = math.floor(C) .. "m";
								r.Distance.Position = Vector2.new(T.X, i.Y + 18);
								r.Distance.Color = d;
								r.Distance.Visible = true;
							else
								r.Distance.Visible = false;
							end;
							if H.Line then
								r.Line.From = Vector2.new(c.X / 2, c.Y);
								r.Line.To = Vector2.new(T.X, T.Y);
								r.Line.Color = d;
								r.Line.Visible = true;
							else
								r.Line.Visible = false;
							end;
							if H.WeaponESP then
								local E = Da(a);
								if E then
									r.Weapon.Text = "[" .. (E .. "]");
									r.Weapon.Position = Vector2.new(T.X, i.Y + 34);
									r.Weapon.Color = d;
									r.Weapon.Visible = true;
								else
									r.Weapon.Visible = false;
								end;
							else
								r.Weapon.Visible = false;
							end;
						else
							r.Box.Visible = false;
							r.Name.Visible = false;
							r.Health.Visible = false;
							r.Distance.Visible = false;
							r.Line.Visible = false;
							r.Weapon.Visible = false;
						end;
					else
						r.Box.Visible = false;
						r.Name.Visible = false;
						r.Health.Visible = false;
						r.Distance.Visible = false;
						r.Line.Visible = false;
						r.Weapon.Visible = false;
					end;
					if H.Skeleton then
						z6(a);
					else
						local H = E.Refs.SleeperSkeletons[a];
						if H then
							for E, H in pairs(H.lines) do
								if H.Visible then
									H.Visible = false;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	for E, H in pairs(E.Refs.SleeperDrawings) do
		if not q[E] then
			E6(E);
		end;
	end;
	for H, z in pairs(E.Refs.SleeperHighlights) do
		if not q[H] and z then
			pcall(function()
				z:Destroy();
			end);
			E.Refs.SleeperHighlights[H] = nil;
		end;
	end;
end;
task.spawn(function()
	while true do
		task.wait(.5);
		pcall(ka);
	end;
end);
W.RenderStepped:Connect(function()
	pcall(c6);
end);
E.Refs.NPCList = {};
E.Refs.NPCDrawings = {};
E.Refs.NPCHighlights = {};
local function a6(E)
	for H, z in ipairs(J:GetPlayers()) do
		if z.Character == E then
			return true;
		end;
	end;
	return false;
end;
local function q6()
	if not H.ESP_NPC then
		E.Refs.NPCList = {};
		return;
	end;
	local z = {};
	local i = {};
	local c = { workspace:FindFirstChild("GeneratedMonuments"), workspace:FindFirstChild("Junkpiles") };
	for E, H in ipairs(c) do
		if H then
			for E, H in ipairs(H:GetDescendants()) do
				if H:IsA("Model") and not a6(H) then
					local E = string.lower(H.Name);
					if E == "scientist" then
						local E = H:FindFirstChildOfClass("Humanoid");
						if E and (E.Health > 0 and not i[H]) then
							i[H] = true;
							table.insert(z, H);
						end;
					end;
				end;
			end;
		end;
	end;
	E.Refs.NPCList = z;
end;
local function d6(H)
	if E.Refs.NPCDrawings[H] then
		return E.Refs.NPCDrawings[H];
	end;
	local z = {};
	z.Box = Drawing.new("Square");
	z.Box.Thickness = 1;
	z.Box.Filled = false;
	z.Box.Visible = false;
	z.Name = Drawing.new("Text");
	z.Name.Size = 13;
	z.Name.Center = true;
	z.Name.Outline = true;
	z.Name.Visible = false;
	z.Health = Drawing.new("Text");
	z.Health.Size = 11;
	z.Health.Center = true;
	z.Health.Outline = true;
	z.Health.Visible = false;
	z.Distance = Drawing.new("Text");
	z.Distance.Size = 11;
	z.Distance.Center = true;
	z.Distance.Outline = true;
	z.Distance.Visible = false;
	E.Refs.NPCDrawings[H] = z;
	return z;
end;
local function Z6(H)
	local z = E.Refs.NPCDrawings[H];
	if z then
		for E, H in pairs(z) do
			pcall(function()
				H:Remove();
			end);
		end;
		E.Refs.NPCDrawings[H] = nil;
	end;
	local i = E.Refs.NPCHighlights[H];
	if i then
		pcall(function()
			i:Destroy();
		end);
		E.Refs.NPCHighlights[H] = nil;
	end;
end;
local function C6()
	for E, H in pairs(E.Refs.NPCDrawings) do
		H.Box.Visible = false;
		H.Name.Visible = false;
		H.Health.Visible = false;
		H.Distance.Visible = false;
	end;
	for E, H in pairs(E.Refs.NPCHighlights) do
		if H and H.Parent then
			H.Enabled = false;
		end;
	end;
end;
local function B6()
	if not H.ESP_NPC or H.NPCDistance <= 0 then
		C6();
		return;
	end;
	local z = A.Character and A.Character:FindFirstChild("HumanoidRootPart");
	if not z then
		C6();
		return;
	end;
	local i = z.Position;
	local c = E.Refs.NPCList or {};
	local a = {};
	for z, c in ipairs(c) do
		if c.Parent then
			local z = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("Head");
			if z and z:IsA("BasePart") then
				local q = ((z.Position - i)).Magnitude;
				if q <= H.NPCDistance then
					a[c] = true;
					local i = c:FindFirstChildOfClass("Humanoid");
					local d = not i or i.Health <= 0;
					local Z = E.Refs.NPCHighlights[c];
					if not Z or not Z.Parent then
						if Z then
							pcall(function()
								Z:Destroy();
							end);
						end;
						Z = Instance.new("Highlight");
						Z.Name = "VelcloudNPC";
						Z.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
						Z.Parent = c;
						E.Refs.NPCHighlights[c] = Z;
					end;
					if d then
						if Z.FillColor ~= Color3.fromRGB(90, 90, 90) then
							Z.FillColor = Color3.fromRGB(90, 90, 90);
							Z.OutlineColor = Color3.fromRGB(60, 60, 60);
						end;
						Z.FillTransparency = .6;
						Z.OutlineTransparency = .3;
					else
						if Z.FillColor ~= H.NPCColor then
							Z.FillColor = H.NPCColor;
							Z.OutlineColor = H.NPCColor;
						end;
						Z.FillTransparency = .4;
						Z.OutlineTransparency = 0;
					end;
					Z.Enabled = true;
					local C = c:FindFirstChild("Head");
					if C then
						local E = d6(c);
						local a = U(C.Position + Vector3.new(0, 1, 0));
						local Z = U(z.Position - Vector3.new(0, 2.5, 0));
						local B = U(z.Position);
						if B.Z > 0 and (a.Z > 0 and Z.Z > 0) then
							local z = math.abs(a.Y - Z.Y);
							local C = z * .5;
							if H.NPC_Box then
								E.Box.Size = Vector2.new(C, z);
								E.Box.Position = Vector2.new(B.X - C / 2, a.Y);
								E.Box.Color = d and Color3.fromRGB(120, 120, 120) or H.NPCColor;
								E.Box.Visible = true;
							else
								E.Box.Visible = false;
							end;
							if H.NPC_Name then
								E.Name.Text = c.Name .. ((d and " [DEAD]" or ""));
								E.Name.Position = Vector2.new(B.X, a.Y - 16);
								E.Name.Color = d and Color3.fromRGB(150, 150, 150) or H.NPCColor;
								E.Name.Visible = true;
							else
								E.Name.Visible = false;
							end;
							if H.NPC_Health then
								if i then
									E.Health.Text = d and "DEAD" or ("HP: " .. (math.floor(i.Health) .. ("/" .. math.floor(i.MaxHealth))));
									E.Health.Position = Vector2.new(B.X, Z.Y + 2);
									E.Health.Color = d and Color3.fromRGB(150, 150, 150) or H.NPCColor;
									E.Health.Visible = true;
								else
									E.Health.Visible = false;
								end;
							else
								E.Health.Visible = false;
							end;
							if H.NPC_Distance then
								E.Distance.Text = math.floor(q) .. "m";
								E.Distance.Position = Vector2.new(B.X, Z.Y + 18);
								E.Distance.Color = d and Color3.fromRGB(150, 150, 150) or H.NPCColor;
								E.Distance.Visible = true;
							else
								E.Distance.Visible = false;
							end;
						else
							E.Box.Visible = false;
							E.Name.Visible = false;
							E.Health.Visible = false;
							E.Distance.Visible = false;
						end;
					end;
				end;
			end;
		end;
	end;
	for E, H in pairs(E.Refs.NPCDrawings) do
		if not a[E] then
			Z6(E);
		end;
	end;
	for H, z in pairs(E.Refs.NPCHighlights) do
		if not a[H] and z then
			pcall(function()
				z:Destroy();
			end);
			E.Refs.NPCHighlights[H] = nil;
		end;
	end;
end;
task.spawn(function()
	while true do
		task.wait(3);
		pcall(q6);
	end;
end);
W.RenderStepped:Connect(function()
	pcall(B6);
end);
E.Refs.AnimalList = {};
E.Refs.AnimalDrawings = {};
E.Refs.AnimalHighlights = {};
local r6 = "bear";
local function T6(E)
	return string.lower(E) == r6;
end;
local function w6()
	if not H.ESP_Animals then
		E.Refs.AnimalList = {};
		return;
	end;
	local z = {};
	local i = workspace:FindFirstChild("Animals");
	if i then
		for E, H in ipairs(i:GetDescendants()) do
			if H:IsA("Model") and (not a6(H) and T6(H.Name)) then
				local E = H:FindFirstChildOfClass("Humanoid");
				if E then
					z[#z + 1] = H;
				end;
			end;
		end;
	end;
	E.Refs.AnimalList = z;
end;
local function V6(H)
	if E.Refs.AnimalDrawings[H] then
		return E.Refs.AnimalDrawings[H];
	end;
	local z = {};
	z.Box = Drawing.new("Square");
	z.Box.Thickness = 1;
	z.Box.Filled = false;
	z.Box.Visible = false;
	z.Name = Drawing.new("Text");
	z.Name.Size = 13;
	z.Name.Center = true;
	z.Name.Outline = true;
	z.Name.Visible = false;
	z.Health = Drawing.new("Text");
	z.Health.Size = 11;
	z.Health.Center = true;
	z.Health.Outline = true;
	z.Health.Visible = false;
	z.Distance = Drawing.new("Text");
	z.Distance.Size = 11;
	z.Distance.Center = true;
	z.Distance.Outline = true;
	z.Distance.Visible = false;
	E.Refs.AnimalDrawings[H] = z;
	return z;
end;
local function G6(H)
	local z = E.Refs.AnimalDrawings[H];
	if z then
		for E, H in pairs(z) do
			pcall(function()
				H:Remove();
			end);
		end;
		E.Refs.AnimalDrawings[H] = nil;
	end;
	local i = E.Refs.AnimalHighlights[H];
	if i then
		pcall(function()
			i:Destroy();
		end);
		E.Refs.AnimalHighlights[H] = nil;
	end;
end;
local function Q6()
	for E, H in pairs(E.Refs.AnimalDrawings) do
		H.Box.Visible = false;
		H.Name.Visible = false;
		H.Health.Visible = false;
		H.Distance.Visible = false;
	end;
	for E, H in pairs(E.Refs.AnimalHighlights) do
		if H and H.Parent then
			H.Enabled = false;
		end;
	end;
end;
local function J6()
	if not H.ESP_Animals or H.AnimalDistance <= 0 then
		Q6();
		return;
	end;
	local z = A.Character and A.Character:FindFirstChild("HumanoidRootPart");
	if not z then
		Q6();
		return;
	end;
	local i = z.Position;
	local c = E.Refs.AnimalList or {};
	local a = {};
	for z, c in ipairs(c) do
		if c.Parent then
			local z = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("Head");
			if z and z:IsA("BasePart") then
				local q = ((z.Position - i)).Magnitude;
				if q <= H.AnimalDistance then
					a[c] = true;
					local i = c:FindFirstChildOfClass("Humanoid");
					local d = not i or i.Health <= 0;
					local Z = E.Refs.AnimalHighlights[c];
					if not Z or not Z.Parent then
						if Z then
							pcall(function()
								Z:Destroy();
							end);
						end;
						Z = Instance.new("Highlight");
						Z.Name = "VelcloudAnimal";
						Z.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
						Z.Parent = c;
						E.Refs.AnimalHighlights[c] = Z;
					end;
					if d then
						if Z.FillColor ~= Color3.fromRGB(90, 90, 90) then
							Z.FillColor = Color3.fromRGB(90, 90, 90);
							Z.OutlineColor = Color3.fromRGB(60, 60, 60);
						end;
						Z.FillTransparency = .6;
						Z.OutlineTransparency = .3;
					else
						if Z.FillColor ~= H.AnimalColor then
							Z.FillColor = H.AnimalColor;
							Z.OutlineColor = H.AnimalColor;
						end;
						Z.FillTransparency = .4;
						Z.OutlineTransparency = 0;
					end;
					Z.Enabled = true;
					local C = c:FindFirstChild("Head");
					if C then
						local E = V6(c);
						local a = U(C.Position + Vector3.new(0, 1, 0));
						local Z = U(z.Position - Vector3.new(0, 2.5, 0));
						local B = U(z.Position);
						if B.Z > 0 and (a.Z > 0 and Z.Z > 0) then
							local z = math.abs(a.Y - Z.Y);
							local C = z * .5;
							if H.Animal_Box then
								E.Box.Size = Vector2.new(C, z);
								E.Box.Position = Vector2.new(B.X - C / 2, a.Y);
								E.Box.Color = d and Color3.fromRGB(120, 120, 120) or H.AnimalColor;
								E.Box.Visible = true;
							else
								E.Box.Visible = false;
							end;
							if H.Animal_Name then
								E.Name.Text = c.Name .. ((d and " [DEAD]" or ""));
								E.Name.Position = Vector2.new(B.X, a.Y - 16);
								E.Name.Color = d and Color3.fromRGB(150, 150, 150) or H.AnimalColor;
								E.Name.Visible = true;
							else
								E.Name.Visible = false;
							end;
							if H.Animal_Health then
								if i then
									E.Health.Text = d and "DEAD" or ("HP: " .. (math.floor(i.Health) .. ("/" .. math.floor(i.MaxHealth))));
									E.Health.Position = Vector2.new(B.X, Z.Y + 2);
									E.Health.Color = d and Color3.fromRGB(150, 150, 150) or H.AnimalColor;
									E.Health.Visible = true;
								else
									E.Health.Visible = false;
								end;
							else
								E.Health.Visible = false;
							end;
							if H.Animal_Distance then
								E.Distance.Text = math.floor(q) .. "m";
								E.Distance.Position = Vector2.new(B.X, Z.Y + 18);
								E.Distance.Color = d and Color3.fromRGB(150, 150, 150) or H.AnimalColor;
								E.Distance.Visible = true;
							else
								E.Distance.Visible = false;
							end;
						else
							E.Box.Visible = false;
							E.Name.Visible = false;
							E.Health.Visible = false;
							E.Distance.Visible = false;
						end;
					end;
				end;
			end;
		end;
	end;
	for E, H in pairs(E.Refs.AnimalDrawings) do
		if not a[E] then
			G6(E);
		end;
	end;
	for H, z in pairs(E.Refs.AnimalHighlights) do
		if not a[H] and z then
			pcall(function()
				z:Destroy();
			end);
			E.Refs.AnimalHighlights[H] = nil;
		end;
	end;
end;
task.spawn(function()
	while true do
		task.wait(3);
		pcall(w6);
	end;
end);
W.RenderStepped:Connect(function()
	pcall(J6);
end);
local function W6(E)
	if E == A then
		return;
	end;
	na(E);
	E.CharacterAdded:Connect(function()
		task.wait(.2);
		ya(E);
	end);
	E.CharacterRemoving:Connect(function()
		ja(E);
	end);
	ya(E);
end;
for E, H in ipairs(J:GetPlayers()) do
	W6(H);
end;
J.PlayerAdded:Connect(W6);
J.PlayerRemoving:Connect(va);
local X6 = game:GetService("Stats");
local u6 = 0;
local O6 = os.clock();
local A6 = 0;
W.RenderStepped:Connect(function()
	if H.FPSPing then
		u6 = u6 + 1;
		local E = os.clock();
		if E - O6 >= 1 then
			A6 = u6;
			u6 = 0;
			O6 = E;
		end;
	else
		u6 = 0;
		A6 = 0;
	end;
end);
local function g6()
	E.Refs.HudPanel = E.Lib:CreateNewWindow({
			Title = "Stats",
			Name = "VelcloudStats",
			Size = { 220 },
			Minimizable = true,
			Position = UDim2.new(1, -240, 0, 20),
			OnClose = function()
				if z.Elements.statsHudToggle then
					z.Elements.statsHudToggle:Set(false);
				end;
			end,
		});
	E.Refs.HudPanel:AddHeader("Performance");
	E.Refs.fpsRow = E.Refs.HudPanel:AddRow("FPS");
	E.Refs.pingRow = E.Refs.HudPanel:AddRow("Ping");
	E.Refs.HudPanel:AddSeparator();
	E.Refs.HudPanel:AddHeader("Player");
	E.Refs.hpRow = E.Refs.HudPanel:AddRow("Health");
	E.Refs.posRow = E.Refs.HudPanel:AddRow("Position", { Style = "Vertical", AccentKey = "white", ValueColorKey = "text" });
	E.Refs.HudPanel:AddSeparator();
	E.Refs.HudPanel:AddHeader("Status");
	E.Refs.onlineRow = E.Refs.HudPanel:AddRow("Online");
	E.Refs.onlineRow:Set("0");
end;
local function l6()
	if E.Refs.HudPanel then
		pcall(function()
			E.Refs.HudPanel:Destroy();
		end);
		E.Refs.HudPanel = nil;
	end;
	E.Refs.fpsRow, E.Refs.pingRow, E.Refs.hpRow, E.Refs.posRow, E.Refs.onlineRow = nil, nil, nil, nil, nil;
end;
task.spawn(function()
	while true do
		if H.FPSPing then
			if not E.Refs.HudPanel then
				g6();
			end;
			if E.Refs.fpsRow then
				E.Refs.fpsRow:Set(tostring(A6));
			end;
			local H, z = pcall(function()
					return X6.Network.ServerStatsItem["Data Ping"]:GetValue();
				end);
			if E.Refs.pingRow then
				E.Refs.pingRow:Set(H and (z and (math.floor(z) .. " ms")) or "n/a");
			end;
			local i = A.Character;
			local c = i and i:FindFirstChild("HumanoidRootPart");
			local a = i and i:FindFirstChildOfClass("Humanoid");
			if c and E.Refs.posRow then
				local H = c.Position;
				E.Refs.posRow:Set(string.format("%d, %d, %d", H.X, H.Y, H.Z));
			end;
			if a and E.Refs.hpRow then
				E.Refs.hpRow:Set(string.format("%d / %d", math.floor(a.Health), math.floor(a.MaxHealth)));
			end;
			if E.Refs.onlineRow then
				E.Refs.onlineRow:Set(tostring(#J:GetPlayers()));
			end;
		elseif E.Refs.HudPanel then
			l6();
		end;
		task.wait(.2);
	end;
end);
local function P6(E)
	if not E then
		return "NONE";
	end;
	if typeof(E) == "EnumItem" then
		if E == Enum.KeyCode.Unknown or E == Enum.UserInputType.None then
			return "NONE";
		end;
		local H = E.Name;
		H = ((H:gsub("MouseButton", "M")):gsub("Left", "L")):gsub("Right", "R");
		return H;
	end;
	return tostring(E);
end;
local function R6()
	E.Refs.BindHudPanel = E.Lib:CreateNewWindow({
			Title = "Binds",
			Name = "VelcloudBinds",
			Size = { 240 },
			Minimizable = true,
			Position = UDim2.new(1, -500, 0, 20),
			OnClose = function()
				if z.Elements.bindHudToggle then
					z.Elements.bindHudToggle:Set(false);
				end;
			end,
		});
	local i = E.Refs.BindHudPanel.Body or E.Refs.BindHudPanel.Gui:FindFirstChild("Body", true) or E.Refs.BindHudPanel.Gui;
	local c = Instance.new("Frame");
	c.Name = "CustomBindList";
	c.BackgroundTransparency = 1;
	c.Size = UDim2.new(1, -24, 0, 0);
	c.Position = UDim2.new(0, 12, 0, 45);
	c.AutomaticSize = Enum.AutomaticSize.Y;
	c.ZIndex = 10;
	c.Parent = i;
	local a = Instance.new("UIListLayout", c);
	a.SortOrder = Enum.SortOrder.LayoutOrder;
	a.Padding = UDim.new(0, 4);
	local function q()
		if not E.Refs.BindHudPanel or not c.Parent then
			return;
		end;
		for E, H in ipairs(c:GetChildren()) do
			if H:IsA("TextLabel") then
				H:Destroy();
			end;
		end;
		local function i(E)
			if E and E.Get then
				return E:Get();
			end;
			return nil;
		end;
		local function a(E, H, z)
			local i = P6(z);
			local a = Instance.new("TextLabel");
			a.Size = UDim2.new(1, 0, 0, 20);
			a.BackgroundTransparency = 1;
			a.Font = Enum.Font.BuilderSansMedium;
			a.TextSize = 12;
			a.TextXAlignment = Enum.TextXAlignment.Left;
			a.TextColor3 = H and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150);
			a.Text = string.format("%s [%s]", E, i);
			a.Parent = c;
			local q = Instance.new("TextLabel");
			q.Size = UDim2.new(.4, 0, 1, 0);
			q.Position = UDim2.new(.6, 0, 0, 0);
			q.BackgroundTransparency = 1;
			q.Font = Enum.Font.BuilderSansBold;
			q.TextSize = 12;
			q.TextXAlignment = Enum.TextXAlignment.Right;
			q.TextColor3 = H and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100);
			q.Text = H and "ON" or "OFF";
			q.Parent = a;
		end;
		a("ESP", H.ESP, i(z.Elements.keybindESP));
		a("Aimbot", H.AimbotEnabled, H.AimbotKey);
		a("FreeCam", H.FreeCam, i(z.Elements.keybindFreecam));
		a("No Recoil", H.NoRecoil, i(z.Elements.keybindNoRecoil));
		a("FOV", H.FOVEnabled, i(z.Elements.keybindFOV));
		a("Spider", H.Spider, i(z.Elements.keybindSpider));
		a("Fullbright", H.Fullbright, i(z.Elements.keybindFullbright));
		a("Cam Zoom", H.CameraZoom, i(z.Elements.keybindCameraZoom));
		a("Walls", H.RemoveConstructions, i(z.Elements.keybindRemoveConstructions));
	end;
	task.spawn(function()
		task.wait(1);
		while E.Refs.BindHudPanel do
			pcall(q);
			task.wait(.5);
		end;
	end);
end;
local function t6()
	if E.Refs.BindHudPanel then
		pcall(function()
			E.Refs.BindHudPanel:Destroy();
		end);
		E.Refs.BindHudPanel = nil;
	end;
end;
W.RenderStepped:Connect(function()
	if H.ESP and H.MaxDistance > 0 then
		local E, H = pcall(La);
		if not E then
			warn("[velcloud.xd] ESP error:", H);
			pcall(fa);
		end;
	else
		fa();
	end;
end);
z.Tabs.Aimbot = z.Window:AddTab("Aimbot", "crosshair");
z.Tabs.Aimbot:AddLabel("AIMBOT SYSTEM", "crosshair");
z.Tabs.Aimbot:AddSeparator();
z.Elements.aimbotEnabled = z.Tabs.Aimbot:AddToggle({
		Title = "Aimbot",
		Icon = "crosshair",
		Default = false,
		Callback = function(E)
			H.AimbotEnabled = E;
		end,
	});
z.Elements.aimbotType = z.Tabs.Aimbot:AddDropdown({
		Title = "Aimbot Type",
		Icon = "layers",
		Options = { "Mouse", "Silent" },
		Default = "Mouse",
		Callback = function(E)
			H.AimbotType = E;
		end,
	});
z.Elements.aimbotBone = z.Tabs.Aimbot:AddDropdown({
		Title = "Bone",
		Icon = "user",
		Options = {
			"Nearest",
			"Head",
			"Chest",
			"Pelvis",
		},
		Default = "Head",
		Callback = function(E)
			H.AimbotBone = E;
		end,
	});
z.Elements.aimbotKey = z.Tabs.Aimbot:AddDropdown({
		Title = "Aim Key",
		Icon = "mouse-pointer",
		Options = {
			"MouseButton2",
			"MouseButton1",
			"LeftShift",
			"Q",
			"E",
			"C",
		},
		Default = "MouseButton2",
		Callback = function(E)
			H.AimbotKey = Enum.UserInputType[E] or Enum.KeyCode[E] or Enum.UserInputType.MouseButton2;
		end,
	});
z.Elements.aimbotVisibleCheck = z.Tabs.Aimbot:AddToggle({
		Title = "Visible Check",
		Icon = "eye",
		Default = true,
		Callback = function(E)
			H.AimbotVisibleCheck = E;
		end,
	});
z.Elements.aimbotAutoSwitch = z.Tabs.Aimbot:AddToggle({
		Title = "Auto Switch",
		Icon = "repeat",
		Default = true,
		Callback = function(E)
			H.AimbotAutoSwitch = E;
		end,
	});
z.Tabs.Aimbot:AddSeparator();
z.Tabs.Aimbot:AddLabel("SMART AIMBOT SYSTEM", "cpu");
z.Tabs.Aimbot:AddSeparator();
z.Elements.dynamicPred = z.Tabs.Aimbot:AddToggle({
		Title = "Dynamic Prediction",
		Subtitle = "????????? ???????????? ? ???? (< 30?) ? ?? ???????? (> 500?)",
		Icon = "activity",
		Default = true,
		Callback = function(E)
			H.DynamicPrediction = E;
		end,
	});
z.Elements.ballisticToggle = z.Tabs.Aimbot:AddToggle({
		Title = "Ballistic Prediction",
		Subtitle = "???? ?????????? ????",
		Icon = "trending-down",
		Default = true,
		Callback = function(E)
			H.Ballistic = E;
		end,
	});
z.Elements.humanoidCheckToggle = z.Tabs.Aimbot:AddToggle({
		Title = "Humanoid State Check",
		Subtitle = "??? ?? ????????? (? ?????)",
		Icon = "user",
		Default = true,
		Callback = function(E)
			H.HumanoidCheck = E;
		end,
	});
z.Elements.noSpreadToggle = z.Tabs.Aimbot:AddToggle({
		Title = "No Spread",
		Subtitle = "??????? ??????? ??????",
		Icon = "crosshair",
		Default = false,
		Callback = function(E)
			H.NoSpread = E;
		end,
	});
z.Tabs.Aimbot:AddSeparator();
z.Elements.aimbotFOV = z.Tabs.Aimbot:AddSlider({
		Title = "Target FOV",
		Icon = "circle",
		Min = 1,
		Max = 400,
		Default = 120,
		Callback = function(E)
			H.AimbotFOV = E;
		end,
	});
z.Elements.aimbotSmooth = z.Tabs.Aimbot:AddSlider({
		Title = "Mouse Aimbot Time",
		Icon = "activity",
		Min = 1,
		Max = 100,
		Default = 5,
		Callback = function(E)
			H.AimbotSmooth = E;
		end,
	});
z.Elements.aimbotPrediction = z.Tabs.Aimbot:AddSlider({
		Title = "Aim Prediction",
		Subtitle = "0=???? \194\183 1=????? \194\183 >1 ???? ?????? ????? ?????",
		Icon = "trending-up",
		Min = 0,
		Max = 2,
		Step = .1,
		Default = 1,
		Callback = function(E)
			H.AimbotPrediction = E;
		end,
	});
z.Elements.aimbotBulletSpeed = z.Tabs.Aimbot:AddSlider({
		Title = "Bullet Speed",
		Subtitle = "??? ~90 \194\183 ????? ~450 \194\183 ??????? ~375",
		Icon = "wind",
		Min = 50,
		Max = 800,
		Step = 25,
		Default = 450,
		Callback = function(E)
			H.AimbotBulletSpeed = E;
		end,
	});
z.Elements.aimbotHitChance = z.Tabs.Aimbot:AddSlider({
		Title = "Hit Chance %",
		Icon = "percent",
		Min = 0,
		Max = 100,
		Default = 100,
		Callback = function(E)
			H.AimbotHitChance = E;
		end,
	});
z.Elements.aimbotDistanceLimit = z.Tabs.Aimbot:AddSlider({
		Title = "Distance Limit",
		Icon = "ruler",
		Min = 1,
		Max = 600,
		Default = 400,
		Callback = function(E)
			H.AimbotDistanceLimit = E;
		end,
	});
z.Tabs.Aimbot:AddSeparator();
z.Elements.aimbotDrawFOV = z.Tabs.Aimbot:AddToggle({
		Title = "Draw FOV",
		Icon = "circle",
		Default = false,
		Callback = function(E)
			H.AimbotDrawFOV = E;
		end,
	});
z.Elements.aimbotDrawFOVColor = z.Tabs.Aimbot:AddColorPicker({
		Title = "Draw FOV Color",
		Icon = "palette",
		Default = H.AimbotDrawFOVColor,
		Callback = function(E)
			H.AimbotDrawFOVColor = E;
		end,
	});
z.Elements.aimbotDrawTarget = z.Tabs.Aimbot:AddToggle({
		Title = "Draw Target",
		Icon = "crosshair",
		Default = false,
		Callback = function(E)
			H.AimbotDrawTarget = E;
		end,
	});
z.Elements.aimbotDrawTargetColor = z.Tabs.Aimbot:AddColorPicker({
		Title = "Draw Target Color",
		Icon = "palette",
		Default = H.AimbotDrawTargetColor,
		Callback = function(E)
			H.AimbotDrawTargetColor = E;
		end,
	});
z.Tabs.Aimbot:AddSeparator();
z.Tabs.Aimbot:AddLabel("IGNORE", "users");
z.Tabs.Aimbot:AddSeparator();
z.Elements.aimbotIgnoreTeam = z.Tabs.Aimbot:AddToggle({
		Title = "Ignore Team",
		Icon = "users",
		Default = true,
		Callback = function(E)
			H.AimbotIgnoreTeam = E;
		end,
	});
z.Elements.aimbotIgnoreSleepers = z.Tabs.Aimbot:AddToggle({
		Title = "Ignore Sleepers",
		Icon = "bed",
		Default = true,
		Callback = function(E)
			H.AimbotIgnoreSleepers = E;
		end,
	});
z.Elements.aimbotIgnoreNPC = z.Tabs.Aimbot:AddToggle({
		Title = "Ignore NPC",
		Icon = "users",
		Default = true,
		Callback = function(E)
			H.AimbotIgnoreNPC = E;
		end,
	});
z.Elements.aimbotIgnoreAnimals = z.Tabs.Aimbot:AddToggle({
		Title = "Ignore Animals",
		Icon = "paw-print",
		Default = true,
		Callback = function(E)
			H.AimbotIgnoreAnimals = E;
		end,
	});
z.Tabs.Aimbot:AddSeparator();
z.Tabs.Aimbot:AddLabel("HITBOX EXPANDER", "box");
z.Tabs.Aimbot:AddSeparator();
z.Elements.hitboxToggle = z.Tabs.Aimbot:AddToggle({
		Title = "Hitbox Expander",
		Icon = "box",
		Default = false,
		Callback = function(E)
			H.HitboxEnabled = E;
			if not E then
				Xa();
			end;
		end,
	});
z.Elements.hitboxSizeSlider = z.Tabs.Aimbot:AddSlider({
		Title = "Hitbox Size",
		Icon = "ruler",
		Min = 1,
		Max = 5,
		Step = .1,
		Default = 2,
		Callback = function(E)
			H.HitboxSize = E;
		end,
	});
z.Elements.hitboxTranspSlider = z.Tabs.Aimbot:AddSlider({
		Title = "Hitbox Transparency %",
		Icon = "eye-off",
		Min = 0,
		Max = 100,
		Default = 50,
		Callback = function(E)
			H.HitboxTransparency = E;
		end,
	});
z.Tabs.Visuals = z.Window:AddTab("Visuals", "eye");
z.Tabs.Visuals:AddLabel("ESP PLAYER", "user");
z.Tabs.Visuals:AddSeparator();
z.Elements.espToggle = z.Tabs.Visuals:AddToggle({
		Title = "Esp Player",
		Icon = "eye",
		Default = false,
		Callback = function(E)
			H.ESP = E;
			for E, H in ipairs(J:GetPlayers()) do
				ya(H);
			end;
		end,
	});
z.Elements.espColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "Esp Color",
		Icon = "palette",
		Default = H.ESPColor,
		Callback = function(z)
			H.ESPColor = z;
			for E, i in pairs(E.Refs.Highlights) do
				if i and i.Parent then
					local c = H.TeamCheck and o(E);
					if not c then
						i.FillColor = z;
						i.OutlineColor = z;
					end;
				end;
			end;
		end,
	});
z.Elements.espModeDropdown = z.Tabs.Visuals:AddDropdown({
		Title = "Esp Player Mode",
		Icon = "layers",
		Options = { "Chams", "Glow" },
		Default = "Chams",
		Callback = function(E)
			H.ESPMode = E;
			for E, H in ipairs(J:GetPlayers()) do
				ya(H);
			end;
		end,
	});
z.Elements.keybindESP = z.Tabs.Visuals:AddKeybind({ Title = "ESP Keybind", Icon = "eye", Callback = function()
			z.Elements.espToggle:Set(not H.ESP);
		end });
z.Tabs.Visuals:AddSeparator();
z.Elements.espDistSlider = z.Tabs.Visuals:AddSlider({
		Title = "Distance Player",
		Icon = "ruler",
		Min = 250,
		Max = 2500,
		Default = H.MaxDistance,
		Callback = function(E)
			H.MaxDistance = E;
			for E, H in ipairs(J:GetPlayers()) do
				ya(H);
			end;
		end,
	});
z.Tabs.Visuals:AddSeparator();
z.Elements.sleeperToggle = z.Tabs.Visuals:AddToggle({
		Title = "Sleeper",
		Icon = "bed",
		Default = false,
		Callback = function(E)
			H.ESP_Sleeper = E;
		end,
	});
z.Elements.sleeperColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "Color Sleeper",
		Icon = "palette",
		Default = H.SleeperColor,
		Callback = function(z)
			H.SleeperColor = z;
			for E, H in pairs(E.Refs.SleeperHighlights) do
				if H and H.Parent then
					H.FillColor = z;
					H.OutlineColor = z;
				end;
			end;
		end,
	});
z.Tabs.Visuals:AddSeparator();
z.Elements.boxToggle = z.Tabs.Visuals:AddToggle({
		Title = "Box",
		Icon = "box",
		Default = false,
		Callback = function(E)
			H.Box = E;
		end,
	});
z.Elements.boxColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "Box Color",
		Icon = "square",
		Default = H.BoxColor,
		Callback = function(E)
			H.BoxColor = E;
		end,
	});
z.Elements.nameToggle = z.Tabs.Visuals:AddToggle({
		Title = "Name",
		Icon = "user",
		Default = false,
		Callback = function(E)
			H.Name = E;
		end,
	});
z.Elements.healthToggle = z.Tabs.Visuals:AddToggle({
		Title = "Health",
		Icon = "heart",
		Default = false,
		Callback = function(E)
			H.Health = E;
		end,
	});
z.Elements.distToggle = z.Tabs.Visuals:AddToggle({
		Title = "Distance",
		Icon = "ruler",
		Default = false,
		Callback = function(E)
			H.Distance = E;
		end,
	});
z.Elements.weaponToggle = z.Tabs.Visuals:AddToggle({
		Title = "Weapon",
		Icon = "sword",
		Default = false,
		Callback = function(E)
			H.WeaponESP = E;
		end,
	});
z.Elements.textColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "Text Color",
		Icon = "type",
		Default = H.TextColor,
		Callback = function(E)
			H.TextColor = E;
		end,
	});
z.Elements.lineToggle = z.Tabs.Visuals:AddToggle({
		Title = "Line",
		Icon = "move",
		Default = false,
		Callback = function(E)
			H.Line = E;
		end,
	});
z.Elements.lineColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "Line Color",
		Icon = "move",
		Default = H.LineColor,
		Callback = function(E)
			H.LineColor = E;
		end,
	});
z.Elements.skeletonToggle = z.Tabs.Visuals:AddToggle({
		Title = "Skeleton",
		Icon = "bone",
		Default = false,
		Callback = function(E)
			H.Skeleton = E;
		end,
	});
z.Elements.skelColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "Skeleton Color",
		Icon = "bone",
		Default = H.SkeletonColor,
		Callback = function(E)
			H.SkeletonColor = E;
		end,
	});
z.Tabs.Visuals:AddSeparator();
z.Tabs.Visuals:AddLabel("TEAM CHECK", "users");
z.Tabs.Visuals:AddSeparator();
z.Elements.teamCheckVisualToggle = z.Tabs.Visuals:AddToggle({
		Title = "Team Check",
		Subtitle = "???????? ???? ??????? Esp Player",
		Icon = "users",
		Default = true,
		Callback = function(E)
			H.TeamCheck = E;
			for E, H in ipairs(J:GetPlayers()) do
				ya(H);
			end;
		end,
	});
z.Elements.teamColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "Team Color",
		Icon = "palette",
		Default = H.TeamColor,
		Callback = function(z)
			H.TeamColor = z;
			for E, i in pairs(E.Refs.Highlights) do
				if i and i.Parent then
					local c = H.TeamCheck and o(E);
					if c then
						i.FillColor = z;
						i.OutlineColor = z;
					end;
				end;
			end;
		end,
	});
z.Tabs.Visuals:AddSeparator();
z.Tabs.Visuals:AddLabel("OTHER VISUALS", "sparkles");
z.Tabs.Visuals:AddSeparator();
z.Elements.espNpcToggle = z.Tabs.Visuals:AddToggle({
		Title = "Esp NPC",
		Icon = "users",
		Default = false,
		Callback = function(E)
			H.ESP_NPC = E;
		end,
	});
z.Elements.npcColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "NPC Color",
		Icon = "palette",
		Default = H.NPCColor,
		Callback = function(E)
			H.NPCColor = E;
		end,
	});
z.Elements.npcDistSlider = z.Tabs.Visuals:AddSlider({
		Title = "NPC Distance",
		Icon = "ruler",
		Min = 100,
		Max = 500,
		Default = H.NPCDistance,
		Callback = function(E)
			H.NPCDistance = E;
		end,
	});
z.Elements.npcElementsDropdown = z.Tabs.Visuals:AddMultiDropdown({
		Title = "NPC Elements",
		Subtitle = "??? ???????? ?? NPC",
		Icon = "layers",
		Options = {
			"Name",
			"Box",
			"Health",
			"Distance",
		},
		Default = {
			"Name",
			"Box",
			"Health",
			"Distance",
		},
		Callback = function(E)
			H.NPC_Name = E.Name == true;
			H.NPC_Box = E.Box == true;
			H.NPC_Health = E.Health == true;
			H.NPC_Distance = E.Distance == true;
		end,
	});
z.Tabs.Visuals:AddSeparator();
z.Elements.espAnimalsToggle = z.Tabs.Visuals:AddToggle({
		Title = "Esp Animals",
		Icon = "paw-print",
		Default = false,
		Callback = function(E)
			H.ESP_Animals = E;
		end,
	});
z.Elements.animalColorPicker = z.Tabs.Visuals:AddColorPicker({
		Title = "Animal Color",
		Icon = "palette",
		Default = H.AnimalColor,
		Callback = function(E)
			H.AnimalColor = E;
		end,
	});
z.Elements.animalDistSlider = z.Tabs.Visuals:AddSlider({
		Title = "Animal Distance",
		Icon = "ruler",
		Min = 250,
		Max = 1000,
		Default = H.AnimalDistance,
		Callback = function(E)
			H.AnimalDistance = E;
		end,
	});
z.Elements.animalElementsDropdown = z.Tabs.Visuals:AddMultiDropdown({
		Title = "Animal Elements",
		Subtitle = "??? ???????? ?? ????????",
		Icon = "layers",
		Options = {
			"Name",
			"Box",
			"Health",
			"Distance",
		},
		Default = {
			"Name",
			"Box",
			"Health",
			"Distance",
		},
		Callback = function(E)
			H.Animal_Name = E.Name == true;
			H.Animal_Box = E.Box == true;
			H.Animal_Health = E.Health == true;
			H.Animal_Distance = E.Distance == true;
		end,
	});
z.Tabs.Loot = z.Window:AddTab("Loot", "package");
z.Tabs.Loot:AddSeparator();
z.Tabs.Loot:AddLabel("COMING SOON", "clock");
z.Tabs.Loot:AddSeparator();
z.Tabs.World = z.Window:AddTab("World", "sun");
z.Tabs.World:AddLabel("SKY", "cloud");
z.Tabs.World:AddSeparator();
z.Elements.skyColorToggle = z.Tabs.World:AddToggle({
		Title = "Custom Sky Color",
		Subtitle = "????????????? ????",
		Icon = "cloud",
		Default = false,
		Callback = function(E)
			H.SkyColorEnabled = E;
			ia(E, H.SkyColor);
		end,
	});
z.Elements.skyColorPicker = z.Tabs.World:AddColorPicker({
		Title = "Sky Color",
		Icon = "palette",
		Default = H.SkyColor,
		Callback = function(E)
			H.SkyColor = E;
			if H.SkyColorEnabled then
				ia(true, E);
			end;
		end,
	});
z.Tabs.World:AddSeparator();
z.Tabs.World:AddLabel("LIGHTING", "sun");
z.Tabs.World:AddSeparator();
z.Elements.fullbrightToggle = z.Tabs.World:AddToggle({
		Title = "Fullbright",
		Subtitle = "???????? ??? ??????, ???? ?? ??????",
		Icon = "sun",
		Default = false,
		Callback = function(E)
			H.Fullbright = E;
			pcall(function()
				if E then
					K();
					Ha();
				else
					if not H.WorldTimeEnabled then
						Ea();
					end;
				end;
			end);
		end,
	});
z.Elements.keybindFullbright = z.Tabs.World:AddKeybind({
		Title = "Fullbright Keybind",
		Icon = "keyboard",
		Default = Enum.KeyCode.Unknown,
		Callback = function()
			z.Elements.fullbrightToggle:Set(not H.Fullbright);
		end,
	});
z.Tabs.World:AddSeparator();
z.Elements.worldTimeToggle = z.Tabs.World:AddToggle({
		Title = "World Time",
		Subtitle = "????????? ????? ?????",
		Icon = "sun-moon",
		Default = false,
		Callback = function(E)
			H.WorldTimeEnabled = E;
			pcall(function()
				if E then
					K();
					za();
				else
					if not H.Fullbright then
						Ea();
					end;
				end;
			end);
		end,
	});
z.Elements.worldTimeSlider = z.Tabs.World:AddSlider({
		Title = "Hour (1-24)",
		Icon = "clock",
		Min = 1,
		Max = 24,
		Default = 12,
		Callback = function(E)
			H.WorldTimeValue = E;
			pcall(function()
				if H.WorldTimeEnabled then
					za();
				end;
			end);
		end,
	});
z.Tabs.World:AddSeparator();
z.Tabs.World:AddLabel("WEAPON SKIN", "paintbrush");
z.Tabs.World:AddSeparator();
z.Elements.weaponColorToggle = z.Tabs.World:AddToggle({
		Title = "Enable Weapon Color",
		Subtitle = "???? ?? ????? ??????",
		Icon = "palette",
		Default = false,
		Callback = function(z)
			H.WeaponColorEnabled = z;
			if z then
				ra();
			else
				for E, H in ipairs(E.Refs.lastWeaponModels) do
					da(H);
				end;
				E.Refs.lastWeaponModels = {};
				if E.Refs.weaponColorConn then
					E.Refs.weaponColorConn:Disconnect();
					E.Refs.weaponColorConn = nil;
				end;
			end;
		end,
	});
z.Elements.weaponColorPicker = z.Tabs.World:AddColorPicker({
		Title = "Neon Color",
		Icon = "droplet",
		Default = H.WeaponColor,
		Callback = function(z)
			H.WeaponColor = z;
			if H.WeaponColorEnabled then
				for E, H in ipairs(E.Refs.lastWeaponModels) do
					qa(H);
				end;
			end;
		end,
	});
z.Elements.materialDropdown = z.Tabs.World:AddDropdown({
		Title = "Material",
		Icon = "gem",
		Options = ca,
		Default = "Neon",
		Callback = function(z)
			H.WeaponMaterial = Enum.Material[z] or Enum.Material.Neon;
			if H.WeaponColorEnabled then
				for E, H in ipairs(E.Refs.lastWeaponModels) do
					qa(H);
				end;
			end;
		end,
	});
z.Tabs.Misc = z.Window:AddTab("Misc", "settings-2");
z.Tabs.Misc:AddLabel("PLAYER", "user");
z.Tabs.Misc:AddSeparator();
z.Elements.freecamToggle = z.Tabs.Misc:AddToggle({
		Title = "FreeCam",
		Subtitle = "WASD + Space/Ctrl",
		Icon = "camera",
		Default = false,
		Callback = function(E)
			H.FreeCam = E;
			if E then
				Fa();
			else
				ma();
			end;
		end,
	});
z.Elements.keybindFreecam = z.Tabs.Misc:AddKeybind({ Title = "FreeCam Keybind", Icon = "keyboard", Callback = function()
			z.Elements.freecamToggle:Set(not H.FreeCam);
		end });
z.Tabs.Misc:AddSeparator();
z.Elements.noRecoilToggle = z.Tabs.Misc:AddToggle({
		Title = "No Recoil",
		Subtitle = "???????? ?? ???? ??? ??????",
		Icon = "target",
		Default = false,
		Callback = function(E)
			H.NoRecoil = E;
			if E then
				Ia();
			else
				ba();
			end;
		end,
	});
z.Elements.keybindNoRecoil = z.Tabs.Misc:AddKeybind({ Title = "No Recoil Keybind", Icon = "keyboard", Callback = function()
			z.Elements.noRecoilToggle:Set(not H.NoRecoil);
		end });
z.Tabs.Misc:AddSeparator();
z.Elements.cameraZoomToggle = z.Tabs.Misc:AddToggle({
		Title = "Camera Zoom",
		Subtitle = "????? ???? ????? ??????????",
		Icon = "zoom-in",
		Default = false,
		Callback = function(E)
			H.CameraZoom = E;
		end,
	});
z.Elements.keybindCameraZoom = z.Tabs.Misc:AddKeybind({ Title = "Camera Zoom Keybind", Icon = "keyboard", Default = Enum.KeyCode.Unknown });
z.Tabs.Misc:AddSeparator();
z.Elements.fovToggle = z.Tabs.Misc:AddToggle({
		Title = "FOV Changer",
		Subtitle = "????????? FOV, ?????????? ? ??????",
		Icon = "focus",
		Default = false,
		Callback = function(z)
			H.FOVEnabled = z;
			if z then
				H.FOVValue = math.clamp(H.FOVValue, H.DefaultFOV, 120);
				E.Refs.fovSettled = false;
			end;
		end,
	});
z.Elements.fovSlider = z.Tabs.Misc:AddSlider({
		Title = "FOV Value",
		Icon = "move-horizontal",
		Min = 70,
		Max = 120,
		Default = 70,
		Callback = function(z)
			H.FOVValue = z;
			E.Refs.fovSettled = false;
		end,
	});
z.Elements.keybindFOV = z.Tabs.Misc:AddKeybind({
		Title = "FOV Keybind",
		Subtitle = "???/???? FOV",
		Icon = "keyboard",
		Default = Enum.KeyCode.Unknown,
		Callback = function()
			z.Elements.fovToggle:Set(not H.FOVEnabled);
		end,
	});
z.Tabs.Misc:AddSeparator();
z.Elements.removeConstructionsToggle = z.Tabs.Misc:AddToggle({
		Title = "Remove Constructions",
		Subtitle = "???????? ????? ?????? ????",
		Icon = "box",
		Default = false,
		Callback = function(E)
			M(E);
		end,
	});
z.Elements.removeDistanceSlider = z.Tabs.Misc:AddSlider({
		Title = "Remove Distance",
		Icon = "ruler",
		Min = 50,
		Max = 150,
		Default = 75,
		Callback = function(E)
			H.RemoveDistance = E;
		end,
	});
z.Elements.keybindRemoveConstructions = z.Tabs.Misc:AddKeybind({
		Title = "Remove Constructions Keybind",
		Subtitle = "???/???? ?????",
		Icon = "keyboard",
		Default = Enum.KeyCode.Unknown,
		Callback = function()
			z.Elements.removeConstructionsToggle:Set(not H.RemoveConstructions);
		end,
	});
z.Tabs.Misc:AddSeparator();
z.Elements.spiderToggle = z.Tabs.Misc:AddToggle({
		Title = "Spider",
		Subtitle = "??????? ?? ?????? (W/Space ?????, S/Ctrl ????)",
		Icon = "move-vertical",
		Default = false,
		Callback = function(E)
			k(E);
		end,
	});
z.Elements.spiderSpeedSlider = z.Tabs.Misc:AddSlider({
		Title = "Spider Speed",
		Icon = "activity",
		Min = 15,
		Max = 40,
		Default = 30,
		Callback = function(E)
			H.SpiderSpeed = E;
		end,
	});
z.Elements.keybindSpider = z.Tabs.Misc:AddKeybind({
		Title = "Spider Keybind",
		Subtitle = "???/???? Spider",
		Icon = "keyboard",
		Default = Enum.KeyCode.Unknown,
		Callback = function()
			z.Elements.spiderToggle:Set(not H.Spider);
		end,
	});
z.Tabs.Misc:AddSeparator();
z.Tabs.Misc:AddLabel("ASPECT RATIO", "monitor");
z.Tabs.Misc:AddSeparator();
z.Elements.aspectToggle = z.Tabs.Misc:AddToggle({
		Title = "Aspect Ratio",
		Subtitle = "?????? ????????? ??????",
		Icon = "monitor",
		Default = false,
		Callback = function(E)
			H.AspectRatioEnabled = E;
			Ga();
		end,
	});
z.Elements.aspectModeDropdown = z.Tabs.Misc:AddDropdown({
		Title = "Ratio",
		Icon = "rectangle-horizontal",
		Options = { "4:3", "16:9" },
		Default = "16:9",
		Callback = function(E)
			H.AspectRatioMode = E;
			if H.AspectRatioEnabled then
				Va();
			end;
		end,
	});
z.Tabs.Misc:AddSeparator();
z.Tabs.Misc:AddLabel("CROSSHAIR SYSTEM", "crosshair");
z.Tabs.Misc:AddSeparator();
z.Elements.crosshairToggle = z.Tabs.Misc:AddToggle({
		Title = "Enable Crosshair",
		Icon = "crosshair",
		Default = false,
		Callback = function(E)
			H.Crosshair = E;
		end,
	});
z.Elements.crosshairType = z.Tabs.Misc:AddDropdown({
		Title = "Style",
		Icon = "shape",
		Options = { "Cross", "T-Shape", "Circle" },
		Default = "Cross",
		Callback = function(E)
			H.CrosshairType = E;
		end,
	});
z.Elements.crosshairOutlineToggle = z.Tabs.Misc:AddToggle({
		Title = "Outline (???????)",
		Icon = "square",
		Default = false,
		Callback = function(E)
			H.CrosshairOutline = E;
		end,
	});
z.Elements.crosshairDotToggle = z.Tabs.Misc:AddToggle({
		Title = "Center Dot",
		Icon = "circle",
		Default = false,
		Callback = function(E)
			H.CrosshairDot = E;
		end,
	});
z.Elements.crosshairColorPicker = z.Tabs.Misc:AddColorPicker({
		Title = "Crosshair Color",
		Icon = "palette",
		Default = H.CrosshairColor,
		Callback = function(E)
			H.CrosshairColor = E;
		end,
	});
z.Elements.crosshairSizeSlider = z.Tabs.Misc:AddSlider({
		Title = "Size (?????)",
		Icon = "ruler",
		Min = 2,
		Max = 40,
		Default = 10,
		Callback = function(E)
			H.CrosshairSize = E;
		end,
	});
z.Elements.crosshairDistSlider = z.Tabs.Misc:AddSlider({
		Title = "Gap (??????)",
		Icon = "move",
		Min = 0,
		Max = 30,
		Default = 5,
		Callback = function(E)
			H.CrosshairDistance = E;
		end,
	});
z.Elements.crosshairThickSlider = z.Tabs.Misc:AddSlider({
		Title = "Thickness (???????)",
		Icon = "minus",
		Min = 1,
		Max = 6,
		Default = 1,
		Callback = function(E)
			H.CrosshairThickness = E;
		end,
	});
z.Elements.crosshairTranspSlider = z.Tabs.Misc:AddSlider({
		Title = "Transparency (????????????)",
		Icon = "eye-off",
		Min = 0,
		Max = 100,
		Default = 0,
		Callback = function(E)
			H.CrosshairTransparency = E;
		end,
	});
z.Elements.crosshairDotSizeSlider = z.Tabs.Misc:AddSlider({
		Title = "Dot Size",
		Icon = "circle",
		Min = 1,
		Max = 10,
		Default = 2,
		Callback = function(E)
			H.CrosshairDotSize = E;
		end,
	});
z.Tabs.Settings = z.Window:AddTab("Settings", "settings");
z.Elements.keyInfoLabel = z.Tabs.Settings:AddLabel(string.format("????: %s | ??: %s", _G.VelcloudKeyState.name or "\226\128\148", Q()), "key");
z.Tabs.Settings:AddSeparator();
local e6 = {};
for E in pairs(E.Lib.Themes) do
	table.insert(e6, E);
end;
table.sort(e6);
z.Tabs.Settings:AddDropdown({
	Title = "Theme",
	Icon = "swatch-book",
	Options = e6,
	Default = z.Window:GetTheme(),
	Callback = function(E)
		z.Window:SetTheme(E);
	end,
});
z.Tabs.Settings:AddDropdown({
	Title = "Accent Color",
	Icon = "droplet",
	Options = {
		"White",
		"Blue",
		"Red",
		"Green",
		"Purple",
	},
	Default = "White",
	Callback = function(H)
		local z = {
				White = Color3.fromRGB(255, 255, 255),
				Blue = Color3.fromRGB(64, 156, 255),
				Red = Color3.fromRGB(230, 70, 70),
				Green = Color3.fromRGB(80, 210, 120),
				Purple = Color3.fromRGB(170, 110, 240),
			};
		E.Lib:SetAccentColor(z[H]);
	end,
});
z.Tabs.Settings:AddSeparator();
z.Elements.statsHudToggle = z.Tabs.Settings:AddToggle({
		Title = "Stats HUD",
		Icon = "gauge",
		Default = false,
		Callback = function(z)
			H.FPSPing = z;
			if z then
				if not E.Refs.HudPanel then
					g6();
				end;
			else
				l6();
			end;
		end,
	});
z.Elements.bindHudToggle = z.Tabs.Settings:AddToggle({
		Title = "Bind HUD",
		Icon = "list",
		Default = false,
		Callback = function(z)
			H.BindHUD = z;
			if z then
				if not E.Refs.BindHudPanel then
					R6();
				end;
			else
				t6();
			end;
		end,
	});
z.Tabs.Settings:AddSeparator();
z.Tabs.Settings:AddLabel("KEYBINDS", "keyboard");
z.Tabs.Settings:AddSeparator();
z.Elements.keybindHideUI = z.Tabs.Settings:AddKeybind({
		Title = "Hide UI Keybind",
		Icon = "keyboard",
		Default = Enum.KeyCode.Delete,
		Callback = function()
			local E = z.Window.Gui;
			if E then
				E.Enabled = not E.Enabled;
			end;
		end,
	});
X.InputBegan:Connect(function(E, i)
	if i then
		return;
	end;
	if not H.CameraZoom then
		return;
	end;
	local c = z.Elements.keybindCameraZoom and z.Elements.keybindCameraZoom:Get();
	if c and (c ~= Enum.KeyCode.Unknown and E.KeyCode == c) then
		H.ZoomActive = true;
	end;
end);
X.InputEnded:Connect(function(E, i)
	local c = z.Elements.keybindCameraZoom and z.Elements.keybindCameraZoom:Get();
	if c and (c ~= Enum.KeyCode.Unknown and E.KeyCode == c) then
		H.ZoomActive = false;
	end;
end);
z.buildConfig = function(E)
		local H = z.Window.ConfigManager:CreateConfig(E);
		H:RegisterElement("AimbotEnabled", z.Elements.aimbotEnabled);
		H:RegisterElement("AimbotType", z.Elements.aimbotType);
		H:RegisterElement("AimbotBone", z.Elements.aimbotBone);
		H:RegisterElement("DynamicPrediction", z.Elements.dynamicPred);
		H:RegisterElement("Ballistic", z.Elements.ballisticToggle);
		H:RegisterElement("HumanoidCheck", z.Elements.humanoidCheckToggle);
		H:RegisterElement("NoSpread", z.Elements.noSpreadToggle);
		H:RegisterElement("AimbotIgnoreTeam", z.Elements.aimbotIgnoreTeam);
		H:RegisterElement("AimbotIgnoreSleepers", z.Elements.aimbotIgnoreSleepers);
		H:RegisterElement("AimbotIgnoreNPC", z.Elements.aimbotIgnoreNPC);
		H:RegisterElement("AimbotIgnoreAnimals", z.Elements.aimbotIgnoreAnimals);
		H:RegisterElement("AimbotVisibleCheck", z.Elements.aimbotVisibleCheck);
		H:RegisterElement("AimbotFOV", z.Elements.aimbotFOV);
		H:RegisterElement("AimbotSmooth", z.Elements.aimbotSmooth);
		H:RegisterElement("AimbotPrediction", z.Elements.aimbotPrediction);
		H:RegisterElement("AimbotBulletSpeed", z.Elements.aimbotBulletSpeed);
		H:RegisterElement("AimbotHitChance", z.Elements.aimbotHitChance);
		H:RegisterElement("AimbotDistanceLimit", z.Elements.aimbotDistanceLimit);
		H:RegisterElement("AimbotDrawFOV", z.Elements.aimbotDrawFOV);
		H:RegisterElement("AimbotDrawFOVColor", z.Elements.aimbotDrawFOVColor);
		H:RegisterElement("AimbotDrawTarget", z.Elements.aimbotDrawTarget);
		H:RegisterElement("AimbotDrawTargetColor", z.Elements.aimbotDrawTargetColor);
		H:RegisterElement("AimbotAutoSwitch", z.Elements.aimbotAutoSwitch);
		H:RegisterElement("AimbotKey", z.Elements.aimbotKey);
		H:RegisterElement("Hitbox", z.Elements.hitboxToggle);
		H:RegisterElement("HitboxSize", z.Elements.hitboxSizeSlider);
		H:RegisterElement("HitboxTransp", z.Elements.hitboxTranspSlider);
		H:RegisterElement("ESP", z.Elements.espToggle);
		H:RegisterElement("ESPMode", z.Elements.espModeDropdown);
		H:RegisterElement("ESPDistance", z.Elements.espDistSlider);
		H:RegisterElement("ESPColor", z.Elements.espColorPicker);
		H:RegisterElement("Sleeper", z.Elements.sleeperToggle);
		H:RegisterElement("ColorSleeper", z.Elements.sleeperColorPicker);
		H:RegisterElement("TeamCheckVisual", z.Elements.teamCheckVisualToggle);
		H:RegisterElement("TeamColor", z.Elements.teamColorPicker);
		H:RegisterElement("Box", z.Elements.boxToggle);
		H:RegisterElement("Name", z.Elements.nameToggle);
		H:RegisterElement("Health", z.Elements.healthToggle);
		H:RegisterElement("Distance", z.Elements.distToggle);
		H:RegisterElement("Line", z.Elements.lineToggle);
		H:RegisterElement("Skeleton", z.Elements.skeletonToggle);
		H:RegisterElement("Weapon", z.Elements.weaponToggle);
		H:RegisterElement("TextColor", z.Elements.textColorPicker);
		H:RegisterElement("BoxColor", z.Elements.boxColorPicker);
		H:RegisterElement("LineColor", z.Elements.lineColorPicker);
		H:RegisterElement("SkelColor", z.Elements.skelColorPicker);
		H:RegisterElement("ESPNPC", z.Elements.espNpcToggle);
		H:RegisterElement("NPCColor", z.Elements.npcColorPicker);
		H:RegisterElement("NPCDistance", z.Elements.npcDistSlider);
		H:RegisterElement("NPCElements", z.Elements.npcElementsDropdown);
		H:RegisterElement("ESPAnimals", z.Elements.espAnimalsToggle);
		H:RegisterElement("AnimalColor", z.Elements.animalColorPicker);
		H:RegisterElement("AnimalDistance", z.Elements.animalDistSlider);
		H:RegisterElement("AnimalElements", z.Elements.animalElementsDropdown);
		H:RegisterElement("CrosshairOn", z.Elements.crosshairToggle);
		H:RegisterElement("CrosshairType", z.Elements.crosshairType);
		H:RegisterElement("CrosshairOutline", z.Elements.crosshairOutlineToggle);
		H:RegisterElement("CrosshairDot", z.Elements.crosshairDotToggle);
		H:RegisterElement("CrosshairColor", z.Elements.crosshairColorPicker);
		H:RegisterElement("CrosshairSize", z.Elements.crosshairSizeSlider);
		H:RegisterElement("CrosshairDistance", z.Elements.crosshairDistSlider);
		H:RegisterElement("CrosshairThick", z.Elements.crosshairThickSlider);
		H:RegisterElement("CrosshairTransp", z.Elements.crosshairTranspSlider);
		H:RegisterElement("CrosshairDotSize", z.Elements.crosshairDotSizeSlider);
		H:RegisterElement("WeaponColorOn", z.Elements.weaponColorToggle);
		H:RegisterElement("WeaponColorPick", z.Elements.weaponColorPicker);
		H:RegisterElement("WeaponMat", z.Elements.materialDropdown);
		H:RegisterElement("AspectRatio", z.Elements.aspectToggle);
		H:RegisterElement("AspectRatioMode", z.Elements.aspectModeDropdown);
		H:RegisterElement("SkyColorEnabled", z.Elements.skyColorToggle);
		H:RegisterElement("SkyColorPicker", z.Elements.skyColorPicker);
		H:RegisterElement("Fullbright", z.Elements.fullbrightToggle);
		H:RegisterElement("BindFullbright", z.Elements.keybindFullbright);
		H:RegisterElement("WorldTime", z.Elements.worldTimeToggle);
		H:RegisterElement("WorldTimeValue", z.Elements.worldTimeSlider);
		H:RegisterElement("FreeCam", z.Elements.freecamToggle);
		H:RegisterElement("CameraZoom", z.Elements.cameraZoomToggle);
		H:RegisterElement("FOVEnabled", z.Elements.fovToggle);
		H:RegisterElement("FOVValue", z.Elements.fovSlider);
		H:RegisterElement("NoRecoil", z.Elements.noRecoilToggle);
		H:RegisterElement("StatsHUD", z.Elements.statsHudToggle);
		H:RegisterElement("BindHUD", z.Elements.bindHudToggle);
		H:RegisterElement("BindESP", z.Elements.keybindESP);
		H:RegisterElement("BindFreecam", z.Elements.keybindFreecam);
		H:RegisterElement("BindCameraZoom", z.Elements.keybindCameraZoom);
		H:RegisterElement("BindNoRecoil", z.Elements.keybindNoRecoil);
		H:RegisterElement("BindHideUI", z.Elements.keybindHideUI);
		H:RegisterElement("RemoveWall", z.Elements.removeConstructionsToggle);
		H:RegisterElement("RemoveDist", z.Elements.removeDistanceSlider);
		H:RegisterElement("BindRemoveWall", z.Elements.keybindRemoveConstructions);
		H:RegisterElement("BindFOV", z.Elements.keybindFOV);
		H:RegisterElement("Spider", z.Elements.spiderToggle);
		H:RegisterElement("SpiderSpeed", z.Elements.spiderSpeedSlider);
		H:RegisterElement("BindSpider", z.Elements.keybindSpider);
		return H;
	end;
z.Tabs.Settings:AddSeparator();
z.Tabs.Settings:AddLabel("SYSTEM CONFIG", "save");
z.Tabs.Settings:AddSeparator();
z.Window.ConfigManager:SetFolder("velcloud_configs");
z.Elements.configNameBox = z.Tabs.Settings:AddTextBox({ Title = "Config Name", Placeholder = "Enter name...", Default = "default" });
z.Elements.savedConfigs = z.Tabs.Settings:AddDropdown({ Title = "Saved Configs", Options = z.Window.ConfigManager:GetConfigs() });
z.Tabs.Settings:AddButton({ Title = "Save Config", Text = "Save", Callback = function()
		local E, H = pcall(function()
				local E = z.Elements.configNameBox:Get();
				if not E or E == "" then
					error("empty name");
				end;
				(z.buildConfig(E)):Save();
				z.Elements.savedConfigs:SetOptions(z.Window.ConfigManager:GetConfigs());
				z.Window:Notify({ Title = "Config", Text = "????????: " .. E, Duration = 2 });
			end);
		if not E then
			warn("[config] save:", H);
			z.Window:Notify({ Title = "Config", Text = "??????: " .. tostring(H), Duration = 4 });
		end;
	end });
z.Tabs.Settings:AddButton({ Title = "Load Config", Text = "Load", Callback = function()
		local i, c = pcall(function()
				local i = z.Elements.savedConfigs:Get();
				if not i or i == "" then
					error("no config");
				end;
				z.Elements.configNameBox:Set(i);
				(z.buildConfig(i)):Load();
				if H.FreeCam then
					if not E.Refs.freecamConn then
						Fa();
					end;
				else
					if E.Refs.freecamConn then
						ma();
					end;
				end;
				if H.NoRecoil then
					Ia();
				else
					ba();
				end;
				if H.HitboxEnabled then
					Oa();
				else
					Xa();
				end;
				if H.Spider then
					k(true);
				else
					k(false);
				end;
				if not H.ESP_NPC then
					for E, H in pairs(E.Refs.NPCDrawings or {}) do
						for E, H in pairs(H) do
							pcall(function()
								H:Remove();
							end);
						end;
					end;
					E.Refs.NPCDrawings = {};
					for E, H in pairs(E.Refs.NPCHighlights or {}) do
						pcall(function()
							H:Destroy();
						end);
					end;
					E.Refs.NPCHighlights = {};
					E.Refs.NPCList = {};
				end;
				if not H.ESP_Animals then
					for E, H in pairs(E.Refs.AnimalDrawings or {}) do
						for E, H in pairs(H) do
							pcall(function()
								H:Remove();
							end);
						end;
					end;
					E.Refs.AnimalDrawings = {};
					for E, H in pairs(E.Refs.AnimalHighlights or {}) do
						pcall(function()
							H:Destroy();
						end);
					end;
					E.Refs.AnimalHighlights = {};
					E.Refs.AnimalList = {};
				end;
				if not H.ESP_Sleeper then
					for E, H in pairs(E.Refs.SleeperDrawings or {}) do
						for E, H in pairs(H) do
							pcall(function()
								H:Remove();
							end);
						end;
					end;
					E.Refs.SleeperDrawings = {};
					for E, H in pairs(E.Refs.SleeperHighlights or {}) do
						pcall(function()
							H:Destroy();
						end);
					end;
					E.Refs.SleeperHighlights = {};
					for E, H in pairs(E.Refs.SleeperSkeletons or {}) do
						for E, H in pairs(H.lines) do
							pcall(function()
								H:Remove();
							end);
						end;
					end;
					E.Refs.SleeperSkeletons = {};
					E.Refs.SleeperList = {};
				end;
				ia(H.SkyColorEnabled, H.SkyColor);
				if H.Fullbright or H.WorldTimeEnabled then
					K();
					if H.Fullbright then
						Ha();
					end;
					if H.WorldTimeEnabled then
						za();
					end;
				else
					Ea();
				end;
				if H.WeaponColorEnabled then
					if not E.Refs.weaponColorConn then
						ra();
					end;
					for E, H in ipairs(E.Refs.lastWeaponModels) do
						qa(H);
					end;
				else
					for E, H in ipairs(E.Refs.lastWeaponModels) do
						da(H);
					end;
					E.Refs.lastWeaponModels = {};
					if E.Refs.weaponColorConn then
						E.Refs.weaponColorConn:Disconnect();
						E.Refs.weaponColorConn = nil;
					end;
				end;
				E.Refs.fovSettled = false;
				for E, H in ipairs(J:GetPlayers()) do
					ya(H);
				end;
				if not H.FPSPing and E.Refs.HudPanel then
					l6();
				elseif H.FPSPing and not E.Refs.HudPanel then
					g6();
				end;
				if not H.BindHUD and E.Refs.BindHudPanel then
					t6();
				elseif H.BindHUD and not E.Refs.BindHudPanel then
					R6();
				end;
				z.Window:Notify({ Title = "Config", Text = "????????: " .. i, Duration = 2 });
			end);
		if not i then
			warn("[config] load:", c);
			z.Window:Notify({ Title = "Config", Text = "??????: " .. tostring(c), Duration = 4 });
		end;
	end });
z.Tabs.Settings:AddButton({
	Title = "Delete Config",
	Text = "Delete",
	Risky = true,
	Callback = function()
		local E, H = pcall(function()
				local E = z.Elements.savedConfigs:Get();
				if not E or E == "" then
					return;
				end;
				z.Window.ConfigManager:DeleteConfig(E);
				z.Elements.savedConfigs:SetOptions(z.Window.ConfigManager:GetConfigs());
				z.Window:Notify({ Title = "Config", Text = "??????: " .. E, Duration = 2 });
			end);
		if not E then
			warn("[config] delete:", H);
		end;
	end,
});
task.spawn(function()
	while true do
		task.wait(2);
		pcall(function()
			local E = _G.VelcloudKeyState.name or "\226\128\148";
			if E == "????????..." then
				E = "????????...";
			end;
			z.Elements.keyInfoLabel:Set(string.format("????: %s | ??: %s", E, Q()));
		end);
	end;
end);
