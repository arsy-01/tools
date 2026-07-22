-- ==========================================
-- ARSY CONSOLE V2.0 (LIGHTWEIGHT TERMINAL)
-- RESCALED & DISCORD STATUS NOTIFY
-- ==========================================
local Players = game:GetService("Players")
while not Players.LocalPlayer do task.wait(0.5) end
local LocalPlayer = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local guiName = "ArsyTerminal_Light_Final"

if getgenv().Arsy_V2_Cleanup then pcall(getgenv().Arsy_V2_Cleanup) end
local targetParent
if gethui then targetParent = gethui() elseif pcall(function() return CoreGui.Name end) then targetParent = CoreGui else targetParent = LocalPlayer:WaitForChild("PlayerGui", 5) end
if targetParent and targetParent:FindFirstChild(guiName) then targetParent[guiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
ScreenGui.Parent = targetParent

-- ==========================================
-- 1. DATABASE & CONFIGURATION
-- ==========================================
local CONFIG_FILE = "ArsyV2_Config.json"
local states = { 
	AAFK = false, Ping = false, Opt = false, 
	HideUSN = false, HideOthers = false, FishNotif = false,
	Webhook = "", WebhookEnabled = false,
	SelectedTiers = {},
	CustomFilters = {
		{fish = "None", mut = "None"},
		{fish = "None", mut = "None"},
		{fish = "None", mut = "None"}
	},
	AutoSave = false, AutoLoad = false
}

local function saveConfig() pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(states)) end) end
local function loadConfig()
	pcall(function()
		if isfile(CONFIG_FILE) then
			local saved = HttpService:JSONDecode(readfile(CONFIG_FILE))
			if saved then
				for k, v in pairs(saved) do
					if type(v) == "table" and type(states[k]) == "table" then
						for subK, subV in pairs(v) do states[k][subK] = subV end
					else
						states[k] = v
					end
				end
			end
		end
	end)
end
loadConfig()
local function triggerAutoSave() if states.AutoSave then saveConfig() end end

-- ==========================================
-- 2. FULL LOGIC
-- ==========================================
local function destroyAudio()
	pcall(function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Sound") then v:Destroy() end end end)
	pcall(function() for _, v in pairs(SoundService:GetDescendants()) do if v:IsA("Sound") then v:Destroy() end end end)
end
task.spawn(destroyAudio)
local cleanerThread = task.spawn(function()
	while task.wait(600) do 
		pcall(function() if clearconsole then clearconsole() elseif rconsoleclear then rconsoleclear() elseif consoleclear then consoleclear() end; destroyAudio(); collectgarbage("collect") end)
	end
end)

local afkConnections = {}
local function applyAAFK()
	if states.AAFK then
		pcall(function() if getconnections then for _, connection in pairs(getconnections(LocalPlayer.Idled)) do table.insert(afkConnections, connection); connection:Disable() end end end)
	else
		for _, connection in ipairs(afkConnections) do pcall(function() connection:Enable() end) end; afkConnections = {}
	end
end

local PingLabel = Instance.new("TextLabel", ScreenGui)
PingLabel.Size = UDim2.new(0, 180, 0, 25); PingLabel.Position = UDim2.new(0.5, -90, 0, 10);
PingLabel.BackgroundTransparency = 1; PingLabel.TextColor3 = Color3.fromHex("#4ec9b0"); PingLabel.Font = Enum.Font.RobotoMono; PingLabel.TextSize = 16; PingLabel.Visible = false
local pingFpsConnection, frameCount, lastUpdate = nil, 0, os.clock()
local function applyPing()
	PingLabel.Visible = states.Ping
	if states.Ping then
		if not pingFpsConnection then
			pingFpsConnection = RunService.RenderStepped:Connect(function()
				frameCount = frameCount + 1; local currentTime = os.clock()
				if currentTime - lastUpdate >= 1 then
					local ping = 0; pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
					PingLabel.Text = "[ FPS: " .. frameCount .. " | MS: " .. ping .. " ]"; frameCount = 0; lastUpdate = currentTime
				end
			end)
		end
	else
		if pingFpsConnection then pingFpsConnection:Disconnect(); pingFpsConnection = nil end
	end
end

local origVisuals, hasCapturedOriginals, optConnections = {}, false, {}
local function applyOpt()
	if not hasCapturedOriginals then 
		hasCapturedOriginals = true; pcall(function() 
			origVisuals.GlobalShadows = Lighting.GlobalShadows; origVisuals.Brightness = Lighting.Brightness; 
			local Terrain = Workspace.Terrain
			if Terrain then pcall(function() origVisuals.Decoration = Terrain.Decoration end); pcall(function() origVisuals.WaterWaveSize = Terrain.WaterWaveSize end) end 
		end) 
	end
	if states.Opt then
		pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01; Lighting.GlobalShadows = false; Lighting.Brightness = 0; for _, effect in ipairs(Lighting:GetChildren()) do if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") or effect:IsA("Clouds") then if effect:GetAttribute("OrigEnabled") == nil then pcall(function() effect:SetAttribute("OrigEnabled", effect.Enabled) end) end; pcall(function() effect.Enabled = false end) end end end)
		local Terrain = Workspace.Terrain
		if Terrain then 
			pcall(function() Terrain.Decoration = false end); pcall(function() Terrain.WaterWaveSize = 0 end); pcall(function() Terrain.WaterReflectance = 0 end)
			local conn1 = Terrain:GetPropertyChangedSignal("WaterWaveSize"):Connect(function() pcall(function() if Terrain.WaterWaveSize > 0 then Terrain.WaterWaveSize = 0 end end) end)
			table.insert(optConnections, conn1) 
		end
	else
		for _, conn in ipairs(optConnections) do if conn.Connected then conn:Disconnect() end end; table.clear(optConnections)
		pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic; Lighting.GlobalShadows = origVisuals.GlobalShadows; Lighting.Brightness = origVisuals.Brightness; for _, effect in ipairs(Lighting:GetChildren()) do if effect:GetAttribute("OrigEnabled") ~= nil then pcall(function() effect.Enabled = effect:GetAttribute("OrigEnabled") end) end end end)
		local Terrain = Workspace.Terrain
		if Terrain then pcall(function() Terrain.Decoration = origVisuals.Decoration end); pcall(function() Terrain.WaterWaveSize = origVisuals.WaterWaveSize end) end
	end
end

local function executeBrute()
	local flatColor = Color3.fromRGB(150, 150, 150)
	for _, obj in pairs(Workspace:GetDescendants()) do 
		pcall(function()
			if obj:IsA("BasePart") then 
				if not obj:IsA("Terrain") then obj.Material = Enum.Material.SmoothPlastic; obj.CastShadow = false; obj.Color = flatColor; if obj:IsA("MeshPart") then obj.TextureID = "" end end
			elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SpecialMesh") then obj:Destroy()
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Sparkles") or obj:IsA("Fire") or obj:IsA("Smoke") then obj:Destroy()
			elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then obj:Destroy()
			elseif obj:IsA("ShirtGraphic") or obj:IsA("Shirt") or obj:IsA("Pants") then obj:Destroy() end
		end)
	end
	pcall(function() Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Brightness = 0; Lighting.Ambient = Color3.fromRGB(120, 120, 120); Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120); for _, effect in ipairs(Lighting:GetChildren()) do if effect:IsA("PostEffect") or effect:IsA("Sky") or effect:IsA("Atmosphere") or effect:IsA("Clouds") or effect:IsA("SunRaysEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") then effect:Destroy() end end end)
	pcall(function() local Terrain = Workspace.Terrain; if Terrain then Terrain.WaterWaveSize = 0; Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0; Terrain.Decoration = false end end)
end

local hideUsnConnections = {} 
local function isTargetText(text)
	if not text then return false end
	if string.match(text, "^[Ll][Vv]%.?%s*%d+") then return true end
	for _, p in pairs(Players:GetPlayers()) do if text == p.Name or text == p.DisplayName then return true end end; return false
end
local function hideBillboard(gui) if not gui:GetAttribute("WasEnabled") then gui:SetAttribute("WasEnabled", gui.Enabled) end; gui.Enabled = false end
local function processCharacterUsn(character)
	for _, desc in pairs(character:GetDescendants()) do if desc:IsA("TextLabel") then local billboard = desc:FindFirstAncestorWhichIsA("BillboardGui"); if billboard and isTargetText(desc.Text) then hideBillboard(billboard) end end end
	local conn = character.DescendantAdded:Connect(function(desc) task.defer(function() if desc:IsA("TextLabel") then local billboard = desc:FindFirstAncestorWhichIsA("BillboardGui"); if billboard and isTargetText(desc.Text) then hideBillboard(billboard) end end end) end)
	table.insert(hideUsnConnections, conn)
end
local function applyHideUSN()
	if states.HideUSN then
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false); StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) end)
		for _, player in pairs(Players:GetPlayers()) do if player.Character then processCharacterUsn(player.Character) end end
		local conn = Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(processCharacterUsn) end); table.insert(hideUsnConnections, conn)
	else
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true); StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end)
		for _, conn in ipairs(hideUsnConnections) do if conn.Connected then conn:Disconnect() end end; table.clear(hideUsnConnections)
		for _, player in pairs(Players:GetPlayers()) do if player.Character then for _, desc in pairs(player.Character:GetDescendants()) do if desc:IsA("BillboardGui") and desc:GetAttribute("WasEnabled") ~= nil then desc.Enabled = desc:GetAttribute("WasEnabled") end end end end
	end
end

local hideOthersConnections = {}
local function updateCharacterVisibility(character, isHidden)
	if not character then return end
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then if not part:GetAttribute("OrigTrans") then part:SetAttribute("OrigTrans", part.Transparency) end; part.Transparency = isHidden and 1 or part:GetAttribute("OrigTrans")
		elseif part:IsA("Decal") or part:IsA("Texture") or part:IsA("Accessory") then if part:IsA("BasePart") then part.LocalTransparencyModifier = isHidden and 1 or 0 elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then part.Handle.LocalTransparencyModifier = isHidden and 1 or 0 end end
	end
end
local function applyHideOthers()
	if states.HideOthers then
		for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer and player.Character then updateCharacterVisibility(player.Character, true) end end
		local conn = Players.PlayerAdded:Connect(function(player) if player ~= LocalPlayer then local charConn = player.CharacterAdded:Connect(function(char) task.wait(0.1); if states.HideOthers then updateCharacterVisibility(char, true) end end); table.insert(hideOthersConnections, charConn) end end); table.insert(hideOthersConnections, conn)
	else
		for _, conn in ipairs(hideOthersConnections) do if conn.Connected then conn:Disconnect() end end; table.clear(hideOthersConnections)
		for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer and player.Character then updateCharacterVisibility(player.Character, false) end end
	end
end

local fishNotifConns = {}
local function applyFishNotif()
	local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not PlayerGui then return end; local notifUI = PlayerGui:FindFirstChild("Small Notification")
	if states.FishNotif then if notifUI then notifUI.Enabled = false; local conn = notifUI:GetPropertyChangedSignal("Enabled"):Connect(function() if notifUI.Enabled then notifUI.Enabled = false end end); table.insert(fishNotifConns, conn) end
	else for _, conn in ipairs(fishNotifConns) do if conn.Connected then conn:Disconnect() end end; table.clear(fishNotifConns); if notifUI then notifUI.Enabled = true end end
end

-- ==========================================
-- 3. AUTO FETCH TIERS, ITEMS & VARIANTS
-- ==========================================
local tierDataList = {}
local tierToName = {}
local fishDictionary = {}
local fishNamesArray = {"None", "All"}
local knownMutations = {"None", "All"}

local function SyncDataFetch()
	local tiersModule = ReplicatedStorage:WaitForChild("Tiers", 5)
	if tiersModule and tiersModule:IsA("ModuleScript") then
		local success, tData = pcall(require, tiersModule)
		if success and type(tData) == "table" then
			for _, data in pairs(tData) do
				if type(data) == "table" and data.Name and type(data.Tier) == "number" then
					table.insert(tierDataList, {level = data.Tier, name = data.Name})
					tierToName[data.Tier] = data.Name
				end
			end
			table.sort(tierDataList, function(a, b) return a.level < b.level end)
		end
	end

	local itemsFolder = ReplicatedStorage:WaitForChild("Items", 5)
	if itemsFolder then
		local tempFish = {}
		for _, instance in ipairs(itemsFolder:GetDescendants()) do
			if instance:IsA("ModuleScript") then
				pcall(function()
					local data = require(instance)
					if type(data) == "table" and data.Data and data.Data.Type == "Fish" and data.Data.Name then
						local fishName = data.Data.Name
						if not fishDictionary[string.lower(fishName)] then table.insert(tempFish, fishName) end
						local assetId = nil; local rawIconData = data.Data.Icon or data.Data.Image or data.Data.ThumbnailId; if rawIconData then assetId = string.match(tostring(rawIconData), "%d+") end
						fishDictionary[string.lower(fishName)] = { Tier = data.Data.Tier or 1, AssetId = assetId }
					end
				end)
			end
		end
		table.sort(tempFish); for _, name in ipairs(tempFish) do table.insert(fishNamesArray, name) end
	end

	local variantsFolder = ReplicatedStorage:WaitForChild("Variants", 5)
	if variantsFolder then
		local tempMut = {}
		for _, v in ipairs(variantsFolder:GetChildren()) do table.insert(tempMut, tostring(v.Name)) end
		table.sort(tempMut); for _, name in ipairs(tempMut) do table.insert(knownMutations, name) end
	end
end
SyncDataFetch()

-- ==========================================
-- 4. DISCORD SENDER & CHAT RADAR
-- ==========================================
local function SendToDiscord(pName, fName, fTier, fWeight, fMutation, fChance, fAssetId)
	if not req or states.Webhook == "" or not states.WebhookEnabled then return end
	local rarityName = tierToName[fTier] or ("Tier " .. tostring(fTier))
	local cleanChance = string.gsub(fChance, " in ", "/")
	local combinedRarity = rarityName .. " | " .. cleanChance
	local finalImageUrl = ""
	if fAssetId then pcall(function() local res = req({Url = "https://thumbnails.roproxy.com/v1/assets?assetIds=" .. fAssetId .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false", Method = "GET"}); if res and res.Body then local jsonData = HttpService:JSONDecode(res.Body); finalImageUrl = jsonData.data[1].imageUrl end end) end

	local embedToSend = {
		["title"] = "New Fish Caught!", 
		["color"] = tonumber(0x0A84FF),
		["fields"] = {
			{ ["name"] = "Player Name", ["value"] = "||**" .. pName .. "**||", ["inline"] = false },
			{ ["name"] = "Fish Name", ["value"] = "**" .. fName .. "**", ["inline"] = false },
			{ ["name"] = "Rarity", ["value"] = combinedRarity, ["inline"] = true },
			{ ["name"] = "Weight", ["value"] = fWeight, ["inline"] = true },
			{ ["name"] = "Mutation", ["value"] = fMutation, ["inline"] = true }
		},
		["footer"] = { ["text"] = "Arsy Server Notification" }, 
		["timestamp"] = DateTime.now():ToIsoDate()
	}
	if finalImageUrl ~= "" then embedToSend["thumbnail"] = { ["url"] = finalImageUrl } end
	task.spawn(function() pcall(function() req({Url = string.gsub(states.Webhook, "%?wait=true", ""), Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode({["content"] = "", ["embeds"] = {embedToSend}})}) end) end)
end

local recentMessages = {}
local function checkMessage(rawMsg)
	if not states.WebhookEnabled or states.Webhook == "" or not rawMsg then return end
	local cleanMsg = string.gsub(rawMsg, "<[^>]+>", ""); cleanMsg = string.gsub(cleanMsg, "[\194\160]", " "); cleanMsg = string.gsub(cleanMsg, "%s+", " "); local lowerMsg = string.lower(cleanMsg)
	if not string.find(lowerMsg, "obtained") then return end
	if recentMessages[lowerMsg] then return end

	local foundBaseName, foundTier, foundAssetId
	for dictName, fishData in pairs(fishDictionary) do
		if string.find(lowerMsg, dictName, 1, true) then if not foundBaseName or string.len(dictName) > string.len(foundBaseName) then foundBaseName = dictName; foundTier = fishData.Tier; foundAssetId = fishData.AssetId end end
	end

	if foundBaseName then
		local playerName = string.match(cleanMsg, "%[.-%]%s*:?%s*(.-)%s+obtained")
		if not playerName then
			playerName = string.match(cleanMsg, "^%s*(.-)%s+obtained")
		end
		playerName = playerName or "Unknown"
		
		local itemStr = string.match(cleanMsg, "obtained%s+an?%s+(.-)%s+with") or ""
		local chance = string.match(cleanMsg, "with%s+a%s+(.-)%s+chance") or "N/A"
		local fullFishName, weight = string.match(itemStr, "^(.-)%s*%((.-)%)%s*$"); if not fullFishName then fullFishName = itemStr; weight = "N/A" end
		fullFishName = string.match(fullFishName, "^%s*(.-)%s*$") or fullFishName
		
		local mutation = "None"; local pureFishName = fullFishName
		local s_start = string.find(string.lower(fullFishName), foundBaseName, 1, true)
		if s_start and s_start > 1 then mutation = string.match(string.sub(fullFishName, 1, s_start - 2), "^%s*(.-)%s*$") or "None"; pureFishName = string.sub(fullFishName, s_start) end

		local isPassed = false
		if states.SelectedTiers[tostring(foundTier)] then isPassed = true end
		if not isPassed then
			for i = 1, 3 do
				local fFish, fMut = states.CustomFilters[i].fish, states.CustomFilters[i].mut
				local matchFish = (fFish == "None" or fFish == "" or string.find(string.lower(pureFishName), string.lower(fFish), 1, true))
				local matchMut = (fMut == "None" or fMut == "" or string.find(string.lower(mutation), string.lower(fMut), 1, true))
				if (fFish ~= "None" or fMut ~= "None") and matchFish and matchMut then isPassed = true; break end
			end
		end

		if isPassed then
			recentMessages[lowerMsg] = true; task.delay(5, function() recentMessages[lowerMsg] = nil end)
			SendToDiscord(playerName, pureFishName, foundTier, weight, mutation, chance, foundAssetId)
		end
	end
end

local connectionTCS, connectionLegacy
local function StartChatRadar()
	if connectionTCS then connectionTCS:Disconnect() end; if connectionLegacy then connectionLegacy:Disconnect() end
	pcall(function() connectionTCS = game:GetService("TextChatService").MessageReceived:Connect(function(t) checkMessage((t.PrefixText or "") .. " " .. (t.Text or "")) end) end)
	pcall(function() local ce = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents", 5); if ce then connectionLegacy = ce:WaitForChild("OnMessageDoneFiltering", 5).OnClientEvent:Connect(function(d) checkMessage((d.FromSpeaker or "")=="" and ("["..d.OriginalChannel.."] "..d.Message) or ("["..d.OriginalChannel.."] "..d.FromSpeaker..": "..d.Message)) end) end end)
end

-- ==========================================
-- 5. DESAIN UI 
-- ==========================================
local scriptConnections = {}
local function addConnection(connection) table.insert(scriptConnections, connection); return connection end

local ColorBG = Color3.fromHex("#1e1e1e")
local ColorPanel = Color3.fromHex("#252526")
local ColorText = Color3.fromHex("#d4d4d4")
local ColorAccent = Color3.fromHex("#569cd6")
local ColorToggleOn = Color3.fromHex("#4ec9b0")
local ColorStroke = Color3.fromHex("#3e3e42")
local FontUI = Enum.Font.RobotoMono

-- Toggle Widget
local ToggleWidget = Instance.new("TextButton", ScreenGui)
ToggleWidget.Size = UDim2.new(0, 50, 0, 50); ToggleWidget.AnchorPoint = Vector2.new(1, 0.5); ToggleWidget.Position = UDim2.new(1, -10, 0.5, 0); 
ToggleWidget.BackgroundColor3 = ColorPanel; ToggleWidget.Text = "</>"; ToggleWidget.TextColor3 = ColorAccent; ToggleWidget.Font = FontUI; ToggleWidget.TextSize = 18
local wStroke = Instance.new("UIStroke", ToggleWidget); wStroke.Color = ColorStroke; wStroke.Thickness = 1
local ToggleScale = Instance.new("UIScale", ToggleWidget)

-- Main Interface
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 815, 0, 440); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = ColorBG; MainFrame.Visible = false; MainFrame.Active = true; MainFrame.Draggable = true
local mStroke = Instance.new("UIStroke", MainFrame); mStroke.Color = ColorAccent; mStroke.Thickness = 1
local MenuScale = Instance.new("UIScale", MainFrame)

-- FUNGSI SCALING (DIJALANKAN 1x SAAT AWAL SAJA)
local function UpdateUIScale()
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local vSize = cam.ViewportSize
	local baseScale = vSize.Y / 600
	baseScale = math.clamp(baseScale, 0.4, 1.5)
	
	-- Menu di perkecil 20% dari skala standarnya
	MenuScale.Scale = baseScale * 0.8
	-- Widget icon dibuat 50% dari skala standarnya
	ToggleScale.Scale = baseScale * 0.5
end
UpdateUIScale()

local TopBar = Instance.new("TextLabel", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30); TopBar.BackgroundColor3 = ColorPanel; TopBar.Text = " arsyV2 "; TopBar.TextColor3 = ColorAccent
TopBar.Font = FontUI; TopBar.TextSize = 15; TopBar.TextXAlignment = Enum.TextXAlignment.Left
local bStroke = Instance.new("UIStroke", TopBar); bStroke.Color = ColorStroke; bStroke.Thickness = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0); CloseBtn.BackgroundColor3 = Color3.fromHex("#f44336")
CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Font = FontUI; CloseBtn.TextSize = 15; CloseBtn.BorderSizePixel = 0

local isMenuOpen = false
addConnection(ToggleWidget.MouseButton1Click:Connect(function() isMenuOpen = not isMenuOpen; MainFrame.Visible = isMenuOpen end))
addConnection(CloseBtn.MouseButton1Click:Connect(function() isMenuOpen = false; MainFrame.Visible = false end))

-- Columns Container
local ColumnsContainer = Instance.new("Frame", MainFrame)
ColumnsContainer.Size = UDim2.new(1, -10, 1, -40); ColumnsContainer.Position = UDim2.new(0, 5, 0, 35); ColumnsContainer.BackgroundTransparency = 1
local ColLayout = Instance.new("UIListLayout", ColumnsContainer)
ColLayout.FillDirection = Enum.FillDirection.Horizontal; ColLayout.Padding = UDim.new(0, 5)

local function CreateColumn(titleText)
	local ColFrame = Instance.new("Frame", ColumnsContainer)
	ColFrame.Size = UDim2.new(0.33, -3, 1, 0); ColFrame.BackgroundColor3 = ColorPanel
	local cStr = Instance.new("UIStroke", ColFrame); cStr.Color = ColorStroke; cStr.Thickness = 1
	
	local CTitle = Instance.new("TextLabel", ColFrame)
	CTitle.Size = UDim2.new(1, 0, 0, 25); CTitle.BackgroundTransparency = 1; CTitle.Text = "> " .. titleText; CTitle.TextColor3 = ColorAccent
	CTitle.Font = FontUI; CTitle.TextSize = 14; CTitle.TextXAlignment = Enum.TextXAlignment.Left
	local padT = Instance.new("UIPadding", CTitle); padT.PaddingLeft = UDim.new(0, 5)
	
	local Divider = Instance.new("Frame", ColFrame)
	Divider.Size = UDim2.new(1, 0, 0, 1); Divider.Position = UDim2.new(0, 0, 0, 25); Divider.BackgroundColor3 = ColorStroke; Divider.BorderSizePixel = 0
	
	local Scroll = Instance.new("ScrollingFrame", ColFrame)
	Scroll.Size = UDim2.new(1, 0, 1, -30); Scroll.Position = UDim2.new(0, 0, 0, 30); Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 3; Scroll.ScrollBarImageColor3 = ColorAccent; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	
	local SLayout = Instance.new("UIListLayout", Scroll)
	SLayout.Padding = UDim.new(0, 4)
	SLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local sPad = Instance.new("UIPadding", Scroll); sPad.PaddingLeft = UDim.new(0, 5); sPad.PaddingRight = UDim.new(0, 5); sPad.PaddingBottom = UDim.new(0, 5)
	
	return Scroll
end

-- ==========================================
-- 6. UI ELEMENTS LOGIC
-- ==========================================
local function CreateToggle(parent, text, defaultState, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, 0, 0, 25); btn.BackgroundTransparency = 1; btn.Text = ""; btn.AutoButtonColor = false
	
	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
	lbl.RichText = true
	lbl.Text = defaultState and ("<b>[+] " .. text .. "</b>") or ("[-] " .. text)
	lbl.TextColor3 = defaultState and ColorToggleOn or ColorText
	lbl.Font = FontUI; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local isOn = defaultState
	addConnection(btn.MouseButton1Click:Connect(function()
		isOn = not isOn
		lbl.Text = isOn and ("<b>[+] " .. text .. "</b>") or ("[-] " .. text)
		lbl.TextColor3 = isOn and ColorToggleOn or ColorText
		if callback then callback(isOn) end
	end))
end

local function CreateButton(parent, text, colorOverride, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, 0, 0, 25); btn.BackgroundColor3 = colorOverride or ColorBG
	btn.Text = text; btn.TextColor3 = colorOverride and Color3.new(1,1,1) or ColorAccent
	btn.Font = FontUI; btn.TextSize = 12; btn.AutoButtonColor = false
	local str = Instance.new("UIStroke", btn); str.Color = ColorStroke; str.Thickness = 1
	
	addConnection(btn.MouseButton1Click:Connect(function() 
		btn.BackgroundColor3 = ColorStroke; task.wait(0.05); btn.BackgroundColor3 = colorOverride or ColorBG
		if callback then callback() end 
	end))
end

local function CreateInput(parent, placeholder, defaultVal, callback)
	local box = Instance.new("TextBox", parent)
	box.Size = UDim2.new(1, 0, 0, 25); box.BackgroundColor3 = ColorBG; box.Text = defaultVal or ""
	box.PlaceholderText = placeholder; box.TextColor3 = ColorAccent; box.Font = FontUI; box.TextSize = 12
	box.TextXAlignment = Enum.TextXAlignment.Left; box.ClearTextOnFocus = false; box.TextTruncate = Enum.TextTruncate.AtEnd
	local str = Instance.new("UIStroke", box); str.Color = ColorStroke; str.Thickness = 1
	local pad = Instance.new("UIPadding", box); pad.PaddingLeft = UDim.new(0, 4)
	
	addConnection(box.FocusLost:Connect(function() if callback then callback(box.Text) end end))
	return box
end

local function CreateLabel(parent, text)
	local lbl = Instance.new("TextLabel", parent)
	lbl.Size = UDim2.new(1, 0, 0, 18); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.fromHex("#808080")
	lbl.Font = FontUI; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
	return lbl
end

local function CreateCollapsible(parent, title)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.AutomaticSize = Enum.AutomaticSize.Y
	
	local rootLayout = Instance.new("UIListLayout", frame)
	rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, 0, 0, 25)
	btn.BackgroundColor3 = ColorPanel
	btn.Text = "[>] " .. title
	btn.TextColor3 = ColorAccent
	btn.Font = FontUI
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.AutoButtonColor = false
	btn.LayoutOrder = 1
	local str = Instance.new("UIStroke", btn)
	str.Color = ColorStroke
	str.Thickness = 1
	local pad = Instance.new("UIPadding", btn)
	pad.PaddingLeft = UDim.new(0, 5)
	
	local content = Instance.new("Frame", frame)
	content.Size = UDim2.new(1, 0, 0, 0)
	content.BackgroundTransparency = 1
	content.Visible = false
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.LayoutOrder = 2
	local layout = Instance.new("UIListLayout", content)
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	local cPad = Instance.new("UIPadding", content)
	cPad.PaddingLeft = UDim.new(0, 6)
	cPad.PaddingTop = UDim.new(0, 4)
	
	local isOpen = false
	addConnection(btn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		btn.Text = (isOpen and "[v] " or "[>] ") .. title
		content.Visible = isOpen
	end))
	
	return content
end

local function CreateMultiSelectDropdown(parent, defaultText, dataList, stateMap, callback)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundColor3 = ColorBG
	frame.AutomaticSize = Enum.AutomaticSize.Y
	local str = Instance.new("UIStroke", frame); str.Color = ColorStroke; str.Thickness = 1

	local rootLayout = Instance.new("UIListLayout", frame)
	rootLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local header = Instance.new("Frame", frame)
	header.Size = UDim2.new(1, 0, 0, 25)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 1

	local btn = Instance.new("TextButton", header)
	btn.Size = UDim2.new(1, -25, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = defaultText; btn.TextColor3 = ColorText
	btn.Font = FontUI; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0, 5)

	local toggleBtn = Instance.new("TextButton", header)
	toggleBtn.Size = UDim2.new(0, 25, 1, 0)
	toggleBtn.Position = UDim2.new(1, -25, 0, 0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = "v"; toggleBtn.TextColor3 = ColorText
	toggleBtn.Font = FontUI; toggleBtn.TextSize = 12

	local listCont = Instance.new("Frame", frame)
	listCont.Size = UDim2.new(1, 0, 0, 0)
	listCont.BackgroundTransparency = 1
	listCont.ClipsDescendants = true
	listCont.LayoutOrder = 2

	local listFrame = Instance.new("ScrollingFrame", listCont)
	listFrame.Size = UDim2.new(1, 0, 1, 0)
	listFrame.BackgroundTransparency = 1
	listFrame.BorderSizePixel = 0
	listFrame.ScrollBarThickness = 2
	listFrame.ScrollBarImageColor3 = ColorAccent
	local listLayout = Instance.new("UIListLayout", listFrame)

	local function updateText()
		local selected = {}
		for _, v in ipairs(dataList) do if stateMap[tostring(v.level)] then table.insert(selected, v.name) end end
		if #selected == 0 then
			btn.Text = defaultText; btn.TextColor3 = ColorText
		else
			btn.Text = " " .. table.concat(selected, ", "); btn.TextColor3 = ColorAccent
		end
	end
	updateText()

	for _, v in ipairs(dataList) do
		local itemBtn = Instance.new("TextButton", listFrame)
		itemBtn.Size = UDim2.new(1, 0, 0, 20)
		itemBtn.BackgroundColor3 = stateMap[tostring(v.level)] and ColorPanel or ColorBG
		itemBtn.RichText = true
		itemBtn.Text = stateMap[tostring(v.level)] and ("<b>[+] " .. v.name .. "</b>") or ("[-] " .. v.name)
		itemBtn.TextColor3 = stateMap[tostring(v.level)] and ColorToggleOn or ColorText
		itemBtn.Font = FontUI; itemBtn.TextSize = 11; itemBtn.TextXAlignment = Enum.TextXAlignment.Left
		local ipad = Instance.new("UIPadding", itemBtn); ipad.PaddingLeft = UDim.new(0, 10)

		addConnection(itemBtn.MouseButton1Click:Connect(function()
			local key = tostring(v.level)
			stateMap[key] = not stateMap[key]
			itemBtn.BackgroundColor3 = stateMap[key] and ColorPanel or ColorBG
			itemBtn.Text = stateMap[key] and ("<b>[+] " .. v.name .. "</b>") or ("[-] " .. v.name)
			itemBtn.TextColor3 = stateMap[key] and ColorToggleOn or ColorText
			updateText()
			if callback then callback() end
		end))
	end

	local isOpen = false
	local function toggle()
		isOpen = not isOpen
		toggleBtn.Text = isOpen and "^" or "v"
		if isOpen then
			listCont.Size = UDim2.new(1, 0, 0, math.min(#dataList * 20, 120))
			listFrame.CanvasSize = UDim2.new(0, 0, 0, #dataList * 20)
		else
			listCont.Size = UDim2.new(1, 0, 0, 0)
		end
	end

	addConnection(btn.MouseButton1Click:Connect(toggle))
	addConnection(toggleBtn.MouseButton1Click:Connect(toggle))

	return frame
end

local function CreateSearchableDropdown(parent, placeholder, entries, defaultVal, callback)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundColor3 = ColorBG
	frame.AutomaticSize = Enum.AutomaticSize.Y
	local str = Instance.new("UIStroke", frame); str.Color = ColorStroke; str.Thickness = 1
	
	local rootLayout = Instance.new("UIListLayout", frame)
	rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local header = Instance.new("Frame", frame)
	header.Size = UDim2.new(1, 0, 0, 25)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 1
	
	local box = Instance.new("TextBox", header)
	box.Size = UDim2.new(1, -25, 1, 0)
	box.BackgroundTransparency = 1
	box.Text = defaultVal or ""
	box.PlaceholderText = placeholder
	box.TextColor3 = ColorAccent
	box.Font = FontUI; box.TextSize = 11
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.ClearTextOnFocus = true
	local pad = Instance.new("UIPadding", box); pad.PaddingLeft = UDim.new(0, 5)
	
	local toggleBtn = Instance.new("TextButton", header)
	toggleBtn.Size = UDim2.new(0, 25, 1, 0)
	toggleBtn.Position = UDim2.new(1, -25, 0, 0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = "v"; toggleBtn.TextColor3 = ColorText
	toggleBtn.Font = FontUI; toggleBtn.TextSize = 12
	
	local listCont = Instance.new("Frame", frame)
	listCont.Size = UDim2.new(1, 0, 0, 0)
	listCont.BackgroundColor3 = ColorPanel
	listCont.BorderSizePixel = 0
	listCont.ClipsDescendants = true
	listCont.LayoutOrder = 2
	
	local listFrame = Instance.new("ScrollingFrame", listCont)
	listFrame.Size = UDim2.new(1, 0, 1, 0)
	listFrame.BackgroundTransparency = 1
	listFrame.BorderSizePixel = 0
	listFrame.ScrollBarThickness = 2
	listFrame.ScrollBarImageColor3 = ColorAccent
	local listLayout = Instance.new("UIListLayout", listFrame)
	
	local isOpen = false
	local itemBtns = {}
	
	local function filterItems()
		local query = string.lower(box.Text)
		local visibleCount = 0
		for _, item in ipairs(itemBtns) do
			if query == "" or string.find(item.text, query, 1, true) then
				item.btn.Visible = true
				visibleCount = visibleCount + 1
			else
				item.btn.Visible = false
			end
		end
		listFrame.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 20)
		if isOpen then
			listCont.Size = UDim2.new(1, 0, 0, math.min(visibleCount * 20, 120))
		end
	end
	
	for _, entry in ipairs(entries) do
		local btn = Instance.new("TextButton", listFrame)
		btn.Size = UDim2.new(1, 0, 0, 20)
		btn.BackgroundTransparency = 1
		btn.Text = entry
		btn.TextColor3 = ColorText
		btn.Font = FontUI; btn.TextSize = 11
		btn.TextXAlignment = Enum.TextXAlignment.Left
		local bpad = Instance.new("UIPadding", btn); bpad.PaddingLeft = UDim.new(0, 5)
		table.insert(itemBtns, {btn = btn, text = string.lower(entry)})
		
		addConnection(btn.MouseButton1Click:Connect(function()
			box.Text = entry
			isOpen = false
			toggleBtn.Text = "v"
			listCont.Size = UDim2.new(1, 0, 0, 0)
			if callback then callback(entry) end
		end))
	end
	
	addConnection(box.Focused:Connect(function()
		isOpen = true
		toggleBtn.Text = "^"
		filterItems()
	end))
	
	addConnection(box:GetPropertyChangedSignal("Text"):Connect(function()
		if box:IsFocused() then filterItems() end
	end))
	
	addConnection(box.FocusLost:Connect(function(enterPressed)
		if enterPressed then if callback then callback(box.Text) end end
	end))
	
	addConnection(toggleBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		toggleBtn.Text = isOpen and "^" or "v"
		if isOpen then filterItems() else listCont.Size = UDim2.new(1, 0, 0, 0) end
	end))
	
	return frame
end

-- ==========================================
-- 7. MENU ASSEMBLY (3 COLUMNS)
-- ==========================================
local ColDash = CreateColumn("DASHBOARD")
local ColWeb = CreateColumn("WEBHOOK")
local ColConf = CreateColumn("CONFIG")

-- [ COL 1 : DASHBOARD ]
CreateLabel(ColDash, "-- MAIN MODULES")
CreateToggle(ColDash, "Ping & FPS", states.Ping, function(s) states.Ping = s; applyPing(); triggerAutoSave() end)
CreateToggle(ColDash, "Fish Notify", states.FishNotif, function(s) states.FishNotif = s; applyFishNotif(); triggerAutoSave() end)
CreateToggle(ColDash, "Hide Username", states.HideUSN, function(s) states.HideUSN = s; applyHideUSN(); triggerAutoSave() end)
CreateToggle(ColDash, "Hide Others", states.HideOthers, function(s) states.HideOthers = s; applyHideOthers(); triggerAutoSave() end)

CreateLabel(ColDash, " ")
CreateLabel(ColDash, "-- UTILITIES")
CreateButton(ColDash, "Execute Brute FPS", Color3.fromHex("#6a1b1a"), function() executeBrute() end)

-- [ COL 2 : WEBHOOK ]
CreateLabel(ColWeb, "-- DISCORD LINK")
CreateToggle(ColWeb, "Enable Webhook", states.WebhookEnabled, function(s) 
	states.WebhookEnabled = s; triggerAutoSave() 
	
	-- PENGIRIMAN NOTIFIKASI DISCORD KETIKA TOMBOL DI-TOGGLE
	if states.Webhook ~= "" and string.find(string.lower(states.Webhook), "http") then
		local notifTitle = s and "🟢 Webhook Connected" or "🔴 Webhook Disconnected"
		local notifDesc = s and "Arsy Console is now actively monitoring chat." or "Monitoring paused."
		local notifColor = s and 0x32D74B or 0xFF3B30
		
		task.spawn(function()
			pcall(function() 
				req({
					Url = string.gsub(states.Webhook, "%?wait=true", ""), 
					Method = "POST", 
					Headers = {["Content-Type"] = "application/json"}, 
					Body = HttpService:JSONEncode({
						embeds = {{
							title = notifTitle, 
							description = notifDesc, 
							color = notifColor, 
							timestamp = DateTime.now():ToIsoDate()
						}}
					})
				}) 
			end)
		end)
	end
end)

CreateInput(ColWeb, "Webhook URL...", states.Webhook, function(txt) states.Webhook = txt; triggerAutoSave() end)

CreateLabel(ColWeb, " ")
CreateLabel(ColWeb, "-- TIER FILTERS")
CreateMultiSelectDropdown(ColWeb, "Select Tiers...", tierDataList, states.SelectedTiers, function() triggerAutoSave() end)

CreateLabel(ColWeb, " ")

-- MENU LIPAT UNTUK TARGET IKAN & MUTASI
local DropdownCustom = CreateCollapsible(ColWeb, "EXACT FILTERS")

for i = 1, 3 do
	local TargetContainer = Instance.new("Frame", DropdownCustom)
	TargetContainer.Size = UDim2.new(1, 0, 0, 0)
	TargetContainer.BackgroundTransparency = 1
	TargetContainer.AutomaticSize = Enum.AutomaticSize.Y
	TargetContainer.LayoutOrder = i 
	
	local containerLayout = Instance.new("UIListLayout", TargetContainer)
	containerLayout.Padding = UDim.new(0, 4)
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local lblTarget = CreateLabel(TargetContainer, "> Target " .. i)
	lblTarget.RichText = true
	lblTarget.Text = "<b>> Target " .. i .. "</b>"
	lblTarget.TextColor3 = ColorToggleOn
	lblTarget.LayoutOrder = 1
	
	local dropFish = CreateSearchableDropdown(TargetContainer, "Select Fish...", fishNamesArray, states.CustomFilters[i].fish, function(val) states.CustomFilters[i].fish = val; triggerAutoSave() end)
	dropFish.LayoutOrder = 2
	
	local dropMut = CreateSearchableDropdown(TargetContainer, "Select Mutation...", knownMutations, states.CustomFilters[i].mut, function(val) states.CustomFilters[i].mut = val; triggerAutoSave() end)
	dropMut.LayoutOrder = 3
	
	local spacer = CreateLabel(TargetContainer, " ") 
	spacer.LayoutOrder = 4
end

-- [ COL 3 : CONFIGURATION ]
CreateLabel(ColConf, "-- SETTINGS")
CreateToggle(ColConf, "Auto Save", states.AutoSave, function(s) states.AutoSave = s; if s then saveConfig() end end)
CreateToggle(ColConf, "Auto Load", states.AutoLoad, function(s) states.AutoLoad = s; triggerAutoSave() end)

CreateLabel(ColConf, " ")
CreateLabel(ColConf, "-- DATA MANAGEMENT")
CreateButton(ColConf, "Save Data", nil, function() saveConfig(); print("[Arsy] Config Saved!") end)
CreateButton(ColConf, "Load Data", nil, function() loadConfig(); print("[Arsy] Config Loaded!") end)

CreateLabel(ColConf, " ")
CreateLabel(ColConf, "-- SCRIPT CONTROL")
local function DestroyScript()
	for _, conn in ipairs(scriptConnections) do if conn.Connected then conn:Disconnect() end end; table.clear(scriptConnections); if ScreenGui then ScreenGui:Destroy() end
	for _, conn in ipairs(afkConnections) do pcall(function() conn:Enable() end) end; for _, conn in ipairs(optConnections) do if conn.Connected then conn:Disconnect() end end; for _, conn in ipairs(hideUsnConnections) do if conn.Connected then conn:Disconnect() end end; for _, conn in ipairs(hideOthersConnections) do if conn.Connected then conn:Disconnect() end end; for _, conn in ipairs(fishNotifConns) do if conn.Connected then conn:Disconnect() end end
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true); StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end)
	if pingFpsConnection then pingFpsConnection:Disconnect() end; if connectionTCS then connectionTCS:Disconnect() end; if connectionLegacy then connectionLegacy:Disconnect() end
end
getgenv().Arsy_V2_Cleanup = DestroyScript
CreateButton(ColConf, "KILL SCRIPT", Color3.fromHex("#b71c1c"), function() DestroyScript() end)

-- ==========================================
-- 8. AUTO-START AWAL
-- ==========================================
task.spawn(function()
	if states.Ping then applyPing() end
	if states.HideUSN then applyHideUSN() end
	if states.HideOthers then applyHideOthers() end
	if states.FishNotif then applyFishNotif() end
	StartChatRadar()
	
	task.delay(5, function()
		states.Opt = true
		applyOpt()
		print("[Arsy] Normal Mode Auto-Activated.")
	end)
	
	task.delay(15, function()
		states.AAFK = true
		applyAAFK()
		print("[Arsy] Anti AFK Auto-Activated.")
	end)
end)

print("[Arsy Terminal Light - Final Polished] Executed Perfectly.")
