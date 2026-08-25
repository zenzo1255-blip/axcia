if game.ReplicatedStorage:FindFirstChild("Systems") then
pcall(function()
	workspace.FallenPartsDestroyHeight = -1000000000
end)
local _lp = game:GetService("Players").LocalPlayer
local _pg = _lp:WaitForChild("PlayerGui")
local _menu = _pg:FindFirstChild("MasterScreenGui")
local _bg = _menu and _menu:FindFirstChild("MenuBackground")
if _bg then
	local _t = os.clock() + 15
	while _bg.Visible and os.clock() < _t do
		task.wait()
	end
end
local p = game:GetService("Players").LocalPlayer
local function mod(a, b)
	return ((a % b) + b) % b
end
local function snap(v)
	return math.floor(v / 4 + 0.5) * 4
end
_G.getChunk = function(pos)
	pos = pos or p.Character.HumanoidRootPart.Position
	local tx_old = math.floor(pos.X / 64)
	local tz_old = math.floor(pos.Z / 64)
	local id = mod(tx_old, 16) + mod(tz_old, 16) * 16
	local chunkX = math.floor(pos.X / 1024)
	local chunkZ = math.floor(pos.Z / 1024)
	return {
		Id = id,
		Chunk = chunkX .. "." .. chunkZ,
		X = chunkX,
		Z = chunkZ
	}
end
_G.getBlock = function(pos)
	pos = pos or p.Character.HumanoidRootPart.Position
	local px = snap(pos.X)
	local py = snap(pos.Y)
	local pz = snap(pos.Z)
	local x = mod(px / 4, 16)
	local z = mod(pz / 4, 16)
	local y = math.floor(py / 4)
	return {
		X = x,
		Y = y,
		Z = z,
		Id = x * 4096 + z * 256 + y
	}
end
_G.getSnap = function(pos)
	pos = pos or p.Character.HumanoidRootPart.Position
	return {
		X = snap(pos.X),
		Y = snap(pos.Y),
		Z = snap(pos.Z)
	}
end
local Library
do
	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
	end)
	if not ok or not result then return end
	Library = result
end
do
    local ok, Lucide = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"))()
    end)
    if ok and Lucide and typeof(Lucide.GetAsset) == "function" then
        local oldGetIcon = Library.GetIcon
        function Library:GetIcon(name)
            local good, icon = pcall(Lucide.GetAsset, name)
            if good and icon then return icon end
            if oldGetIcon then
                local ok2, icon2 = pcall(oldGetIcon, self, name)
                if ok2 then return icon2 end
            end
        end
    end
end
Library.Scheme.BackgroundColor = Color3.fromRGB(8, 8, 8)
Library.Scheme.MainColor = Color3.fromRGB(18, 18, 18)
Library.Scheme.AccentColor = Color3.fromRGB(255, 255, 255)
Library.Scheme.OutlineColor = Color3.fromRGB(55, 55, 55)
Library.Scheme.FontColor = Color3.fromRGB(245, 245, 245)
Library.Scheme.DarkColor = Color3.fromRGB(0, 0, 0)
Library.Scheme.WhiteColor = Color3.fromRGB(255, 255, 255)
Library.IsLightTheme = false
local function wrapGroup(group)
    local obj = {}
    function obj:CreateSection(text)
        group:AddDivider()
        group:AddLabel(text)
    end
    function obj:CreateDivider()
        return group:AddDivider()
    end
    function obj:CreateToggle(c)
        return group:AddToggle(c.Flag or c.Name, {Text=c.Name, Default=c.CurrentValue or false, Callback=c.Callback})
    end
    function obj:CreateDropdown(c)
        local default = c.CurrentOption
        if c.MultipleOptions then
            if type(default) ~= "table" then default = {} end
        else
            if type(default) == "table" then default = default[1] end
            if default == nil or default == "" then default = c.Options and c.Options[1] end
        end
        local callback = c.Callback
        local dropdown = group:AddDropdown(c.Flag or c.Name, {Text=c.Name, Default=default, Values=c.Options or {}, Multi=c.MultipleOptions or false, Callback=function(value)
            if c.MultipleOptions and type(value) == "table" then
                local selected = {}
                for name,state in pairs(value) do
                    if state then selected[#selected+1] = name end
                end
                if callback then return callback(selected) end
                return
            end
            if callback then return callback(value) end
        end})
        function dropdown:Refresh(values)
            return self:SetValues(values or {})
        end
        return dropdown
    end
    function obj:CreateButton(c)
        return group:AddButton({Text=c.Name, DoubleClick=false, Func=c.Callback})
    end
    function obj:CreateInput(c)
        return group:AddInput(c.Flag or c.Name, {Text=c.Name, Default=c.CurrentValue or "", Placeholder=c.PlaceholderText, Finished=true, Callback=c.Callback})
    end
    function obj:CreateParagraph(c)
        return group:AddLabel({Text=(c.Title and (c.Title .. "\n") or "") .. (c.Content or ""), DoesWrap=true})
    end
    return obj
end
local Window
local function makeTab(name, icon)
    local tab = Window:AddTab(name, icon)
    local left = tab:AddLeftGroupbox(name)
    local right = tab:AddRightGroupbox("Options")
    right:AddLabel({Text = "Options", DoesWrap = false})
    right:AddDivider()
    return wrapGroup(left), wrapGroup(right)
end
local Opt = {}
local Rayfield = {
    Notify = function() end,
    IsVisible = function()
        return true
    end
}
local function exists(v)
    return v ~= nil
end
local RS = game:GetService("ReplicatedStorage")
local support = {
    raknet_desync = false,
    hookfunction = false,
    require = false,
    require_module = false,
    getconnections = false,
    getrawmetatable = false,
    setreadonly = false
}
if true then
    if exists(raknet) and exists(raknet.desync) then
        support.raknet_desync = true
    end
    if type(hookfunction) == "function" then
        support.hookfunction = true
    end
    if type(require) == "function" then
        support.require = true
    end
    if type(getconnections) == "function" then
        support.getconnections = true
    end
    if type(getrawmetatable) == "function" then
        support.getrawmetatable = true
    end
    if type(setreadonly) == "function" then
        support.setreadonly = true
    end
    local ok = pcall(function()
        local assets = RS:FindFirstChild("Assets")
        if assets then
            local mod = assets:FindFirstChild("TextureProvider")
            if mod and mod:IsA("ModuleScript") then
                require(mod)
            else
                error("No Module")
            end
        else
            error("No Assets")
        end
    end)
    support.require_module = ok
end
for k,v in pairs(support) do
end
function msg() end
Window = Library:CreateWindow({
    Title = "Loader.live", Size = UDim2.new(0, 520, 0, 360), Footer = "Loader.live", Center = true, AutoShow = true,
    Resizable = true, ToggleKeybind = Enum.KeyCode.RightShift, EnableSidebarResize = true, NotifyOnError = false,
    SidebarCompacted = true, NotifySide = "Right", ShowCustomCursor = true, CornerRadius = 24,
})
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local chars = workspace:WaitForChild("Characters")
local attackRemote = RS.Systems.ActionsSystem.Network.Attack
local pausedValue = RS.Systems.PlayersSystem.Debug.Paused
local function getPlayerNames()
    local list = {}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            list[#list+1] = plr.Name
        end
    end
    return list
end
local CombatTab, CombatOptions = makeTab("Fight", "swords")
local MineTab, MineOptions = makeTab("Mining", "pickaxe")
local EntityTab, EntityOptions = makeTab("Entities", "users")
local MiscTab, MiscOptions = makeTab("Utility", "settings")
local BetaTab, BetaOptions = makeTab("Testing", "flask-conical")
local PG = LP:WaitForChild("PlayerGui")
local enableFastEat = false
local consumeRemote = RS:WaitForChild("Systems")
    :WaitForChild("ActionsSystem")
    :WaitForChild("Network")
    :WaitForChild("Consume")
local function getInteractButton()
    local btn
    repeat
        local tg = PG:FindFirstChild("TouchGui")
        if tg then
            btn = tg:FindFirstChild("InteractButton")
        end
        task.wait()
    until btn
    return btn
end
local function getCurrentSlot()
    local char = LP.Character or LP.CharacterAdded:Wait()
    return char:GetAttribute("ReplicatedHotbarSlot")
end
local function getQtyLabel(slot)
    local hb = PG:WaitForChild("MasterScreenGui"):WaitForChild("Hotbar")
    return hb:WaitForChild(tostring(slot)):WaitForChild("QtyLabel")
end
local function updateColor(lbl)
    local num = tonumber(lbl.Text)
    if num then
        if num <= -1 then
            lbl.TextColor3 = Color3.new(1,0,0)
        else
            lbl.TextColor3 = Color3.new(1,1,1)
        end
    end
end
for i = 1,9 do
    task.spawn(function()
        local lbl = getQtyLabel(i)
        updateColor(lbl)
        lbl:GetPropertyChangedSignal("Text"):Connect(function()
            updateColor(lbl)
        end)
    end)
end
task.spawn(function()
    while true do
        local btn = getInteractButton()
        btn.MouseButton1Click:Connect(function()
            if not enableFastEat then return end
            local slot = getCurrentSlot()
            if not slot then return end
            pcall(function()
                consumeRemote:InvokeServer(slot)
            end)
            local lbl = getQtyLabel(slot)
            local num = tonumber(lbl.Text) or 0
            lbl.Text = tostring(num - 1)
        end)
        btn.AncestryChanged:Wait()
    end
end)
CombatTab:CreateToggle({
    Name = "Quick Eat",
    CurrentValue = false,
    Flag = "Fast Eat",
    Callback = function(val)
        enableFastEat = val
    end,
})
CombatTab:CreateSection("Hit Aura")
local auraEnabled = false
local auraRange = 50
Opt.auraHits = 5
local auraWhitelist = {}
local defaultWhitelistAura = {
	["whatisthatthing43"] = true,
}
for name,_ in pairs(defaultWhitelistAura) do
	auraWhitelist[name] = true
end
local AuraWhiteListDropdown = CombatTab:CreateDropdown({
	Name = "Hit Aura Whitelist",
	Options = getPlayerNames(),
	CurrentOption = {},
	MultipleOptions = true,
	Flag = "AuraWhitelistPlayers",
	Callback = function(Options)
		auraWhitelist = {}
		for name,_ in pairs(defaultWhitelistAura) do
			auraWhitelist[name] = true
		end
		for _, name in ipairs(Options) do
			auraWhitelist[name] = true
		end
	end,
})
local function getNearestTarget()
	local myChar = LP.Character
	if not myChar then return end
	local myHRP =
	myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	local nearestChar = nil
	local shortestDist = auraRange
	for _, char in ipairs(
		chars:GetChildren()
	) do
		if char.Name ~= LP.Name then
			local plr =
			Players:FindFirstChild(
				char.Name
			)
			if plr
			and not auraWhitelist[plr.Name] then
				local hrp =
				char:FindFirstChild(
					"HumanoidRootPart"
				)
				if hrp then
					local dist =
					(
						myHRP.Position
						-
						hrp.Position
					).Magnitude
					if dist < shortestDist then
						nearestChar = char
						shortestDist = dist
					end
				end
			end
		end
	end
	return nearestChar
end
task.spawn(function()
	while true do
		if auraEnabled then
			local myChar = LP.Character
			if myChar then
				local slot =
				myChar:GetAttribute(
					"ReplicatedHotbarSlot"
				)
				if slot then
					local target =
					getNearestTarget()
					if target then
						for i = 1,Opt.auraHits do
							pcall(function()
								attackRemote:InvokeServer(
									target,
									slot
								)
							end)
						end
					end
				end
			end
		end
		RunService.Heartbeat:Wait()
	end
end)
CombatTab:CreateToggle({
	Name = "Hit Aura",
	CurrentValue = false,
	Flag = "KillAura",
	Callback = function(Value)
msg("killaura", "id", Value)
		auraEnabled = Value
	end,
})
CombatTab:CreateSection("TP Aura")
local protectedList = {}
local hitTest = {}
Opt.tpAttackCount = 15
Opt.tpFailLimit = 10
Opt.tpProtectedTime = 3
Opt.tpOffset = 4
local autoWhitelist = {}
local running = false
local lockedTarget = nil
local defaultWhitelistAuto = {
	["whatisthatthing43"] = true,
}
for n,_ in pairs(defaultWhitelistAuto) do
	autoWhitelist[n] = true
end

local AutoWhiteListDropdown = CombatTab:CreateDropdown({
	Name = "TP Aura Whitelist",
	Options = getPlayerNames(),
	CurrentOption = {},
	MultipleOptions = true,
	Flag = "AutoWhitelistPlayers",
	Callback = function(Options)
		autoWhitelist = {}
		for n,_ in pairs(defaultWhitelistAuto) do
			autoWhitelist[n] = true
		end
		for _,name in ipairs(Options) do
			autoWhitelist[name] = true
		end
	end
})
local function refreshDropdown()
	AutoWhiteListDropdown:Refresh(getPlayerNames())
end
Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(refreshDropdown)
pcall(function()
	game.CoreGui.AutoKillInfo:Destroy()
end)
local gui = Instance.new("ScreenGui",game.CoreGui)
gui.Name = "AutoKillInfo"
local frame = Instance.new("Frame",gui)
frame.Size = UDim2.new(0,300,0,38)
frame.Position = UDim2.new(.5,-150,0,80)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Visible = false
frame.BorderSizePixel = 0
Instance.new("UICorner",frame)
local text = Instance.new("TextLabel",frame)
text.Size = UDim2.new(1,0,1,0)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.new(1,1,1)
text.TextSize = 16
text.Font = Enum.Font.SourceSansBold
local function updateGui(plr)
	if running and plr then
		frame.Visible = true
		text.Text = "Target: "..plr.Name.." | Health: "..tostring(plr:GetAttribute("health") or "?")
	else
		frame.Visible = false
	end
end
local function isProtected(plr)
	local char = chars:FindFirstChild(plr.Name)
	if not char then return false end
	local hum = char:FindFirstChild("Humanoid")
	if hum and hum:FindFirstChild("FightProtection") then
		return true
	end
	return false
end
local function getClosestTarget()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end
	for _,plr in ipairs(Players:GetPlayers()) do
		local hp = plr:GetAttribute("health") or 0
		if plr ~= LP
		and hp > 0
		and not autoWhitelist[plr.Name]
		and not protectedList[plr]
		and not isProtected(plr) then
			local char = chars:FindFirstChild(plr.Name)
			local lastPos = plr:GetAttribute("LastPosition")
			local targetPos = (char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position) or lastPos
			if targetPos then
				local dist = (myHRP.Position - targetPos).Magnitude
				if dist < shortestDistance then
					shortestDistance = dist
					closestPlayer = plr
				end
			end
		end
	end
	return closestPlayer
end
RunService.Heartbeat:Connect(function()
	if not running or not lockedTarget then return end
	if isProtected(lockedTarget) then
		lockedTarget = nil
		return
	end
	local myChar = LP.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	local char = chars:FindFirstChild(lockedTarget.Name)
	local lastPos = lockedTarget:GetAttribute("LastPosition")
	if char and char:FindFirstChild("HumanoidRootPart") then
		local rx = math.random(-Opt.tpOffset*10,Opt.tpOffset*10)/10
		local ry = math.random(0,Opt.tpOffset*10)/10
		local rz = math.random(-Opt.tpOffset*10,Opt.tpOffset*10)/10
		myHRP.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(rx,ry,rz)
	elseif lastPos then
		myHRP.CFrame = CFrame.new(lastPos + Vector3.new(0,2,0))
	end
end)
local function startLoop()
	while running do
		if not lockedTarget
		or not lockedTarget.Parent
		or (lockedTarget:GetAttribute("health") or 0) <= 0
		or isProtected(lockedTarget) then
			lockedTarget = getClosestTarget()
		end
		if not lockedTarget then
			updateGui(nil)
			task.wait()
			continue
		end
		local myChar = LP.Character
		local slot = myChar and myChar:GetAttribute("ReplicatedHotbarSlot")
		if not slot then
			task.wait()
			continue
		end
		updateGui(lockedTarget)
		local targetChar = chars:FindFirstChild(lockedTarget.Name)
		if targetChar then
			local oldHP = lockedTarget:GetAttribute("health")
			for i = 1,Opt.tpAttackCount do
				if not running then break end
				if (lockedTarget:GetAttribute("health") or 0) <= 0 then break end
				if isProtected(lockedTarget) then break end
				task.spawn(function()
					pcall(function()
						attackRemote:InvokeServer(targetChar,slot)
					end)
				end)
			end
			task.wait()
			if lockedTarget then
				local newHP = lockedTarget:GetAttribute("health")
				if oldHP and newHP and newHP >= oldHP and newHP > 0 then
					hitTest[lockedTarget] = (hitTest[lockedTarget] or 0) + 1
					if hitTest[lockedTarget] >= Opt.tpFailLimit then
						protectedList[lockedTarget] = true
						task.delay(Opt.tpProtectedTime,function()
							protectedList[lockedTarget] = nil
						end)
						lockedTarget = nil
					end
				else
					hitTest[lockedTarget] = nil
				end
			end
		end
		task.wait()
	end
	updateGui(nil)
end
CombatTab:CreateToggle({
	Name = "TP Aura",
	CurrentValue = false,
	Flag = "AutoAttackFirst",
	Callback = function(Value)
		running = Value
		pausedValue.Value = Value
		if Value then
			lockedTarget = nil
			task.spawn(startLoop)
		else
			lockedTarget = nil
			updateGui(nil)
		end
	end
})
CombatTab:CreateSection("Defense")
if support.hookfunction then
local FallRemote =
RS.Systems.CombatSystem.Network.FallDamage
local DownRemote =
RS.Systems.CombatSystem.Network.DrownDamage
local afdEnabled = false
local adEnabled = false
if typeof(hookmetamethod) == "function" then
    local oldNamecall
    oldNamecall = hookmetamethod(
        game,
        "__namecall",
        function(self,...)
            local method =
                getnamecallmethod()
            if method == "FireServer" then
                if self == FallRemote
                and afdEnabled then
                    return
                end
                if self == DownRemote
                and adEnabled then
                    return
                end
            end
            return oldNamecall(self,...)
        end
    )
    CombatTab:CreateToggle({
        Name = "No Fall Damage",
        CurrentValue = false,
        Flag = "AntiFallDamage",
        Callback = function(Value)
            afdEnabled = Value
        end,
    })
    CombatTab:CreateToggle({
        Name = "No Drown",
        CurrentValue = false,
        Flag = "AntiDrown",
        Callback = function(Value)
            adEnabled = Value
        end,
    })
end
else

end
CombatTab:CreateSection("Drops")
local Drops = workspace:WaitForChild("Drops")
local hitboxEnabled = false
local hitboxList = {}
Opt.dropTPInterval = 0.1
Opt.dropDescDelay = 0.5
local dropHighlightFill = Color3.fromRGB(255,255,255)
local function getHRP()
	local char = LP.Character
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
end
local function moveHitbox(obj)
	if obj.Name == "Hitbox"
	and obj:IsA("BasePart") then
		hitboxList[obj] = true
		task.spawn(function()
			while hitboxEnabled and obj.Parent do
				local hrp = getHRP()
				if hrp then
					obj.CFrame = hrp.CFrame
				end
				task.wait(0.1)
			end
		end)
	end
end
local function scanHitboxes()
	for _, v in ipairs(
		Drops:GetDescendants()
	) do
		moveHitbox(v)
	end
end
local descConnection
CombatTab:CreateToggle({
	Name = "Teleport Drops To Me",
	CurrentValue = false,
	Flag = "DropsTP",
	Callback = function(Value)
		hitboxEnabled = Value
		if hitboxEnabled then
			scanHitboxes()
			descConnection =
			Drops.DescendantAdded:Connect(function(obj)
				task.wait(Opt.dropDescDelay)
				if hitboxEnabled then
					moveHitbox(obj)
				end
			end)
		else
			if descConnection then
				descConnection:Disconnect()
				descConnection = nil
			end
		end
	end,
})
local highlightEnabled = false
local highlights = {}
local function createHighlight(item)
	if highlights[item] then return end
	local hl = Instance.new("Highlight")
	hl.Parent = item
	highlights[item] = hl
end
local function removeHighlight(item)
	if highlights[item] then
		highlights[item]:Destroy()
		highlights[item] = nil
	end
end
local function scanHighlights()
	for _, item in ipairs(
		Drops:GetChildren()
	) do
		createHighlight(item)
	end
end
local highlightConnection
CombatTab:CreateToggle({
	Name = "Highlight Drops",
	CurrentValue = false,
	Flag = "DropsHighlight",
	Callback = function(Value)
		highlightEnabled = Value
		if highlightEnabled then
			scanHighlights()
			highlightConnection =
			Drops.ChildAdded:Connect(function(item)
				if highlightEnabled then
					createHighlight(item)
				end
			end)
		else
			if highlightConnection then
				highlightConnection:Disconnect()
				highlightConnection = nil
			end
			for item, hl in pairs(highlights) do
				hl:Destroy()
			end
			table.clear(highlights)
		end
	end,
})
CombatTab:CreateSection("Teleport")
local plrTable = {}
local selectedPlayer = nil
local Dropdown = CombatTab:CreateDropdown({
	Name = "Choose Player",
	Options = {},
	CurrentOption = {},
	MultipleOptions = false,
	Flag = "teleportplr",
	Callback = function(Options)
		selectedPlayer = Options[1]
	end,
})
local function refreshPlayers()
	plrTable = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			table.insert(plrTable, plr.Name)
		end
	end
	Dropdown:Refresh(plrTable)
end
refreshPlayers()
Players.PlayerAdded:Connect(function(plr)
	refreshPlayers()
end)
Players.PlayerRemoving:Connect(function(plr)
	refreshPlayers()
end)
CombatTab:CreateButton({
	Name = "Teleport to Player",
	Callback = function()
		if not selectedPlayer then return end
		local plr = Players:FindFirstChild(selectedPlayer)
		if not plr then return end
		local pos = plr:GetAttribute("LastPosition")
		if typeof(pos) ~= "Vector3" then return end
local hrp = LP.Character.HumanoidRootPart
		hrp.CFrame = CFrame.new(pos)
msg("Teleport to " .. plr.Name .. " at X: " .. math.floor(pos.X) .. " , Y: " .. math.floor(pos.Y) .. " ,Z: " .. math.floor(pos.Z))
	end,
})
CombatTab:CreateDivider()
_G.a = false
Opt.espMaxDistance = 500
Opt.espBoxWidth = 35
Opt.espBoxHeight = 60
Opt.espNameSize = 13
Opt.espHPSize = 12
Opt.espDistanceSize = 11
local TweenService = game:GetService("TweenService")
local Folder = workspace:FindFirstChild("LastPositionESP") or Instance.new("Folder")
Folder.Name = "LastPositionESP"
Folder.Parent = workspace
local ESP = {}
local TweenInfoESP = TweenInfo.new(
    0.03,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)
local function createESP(plr)
    if plr == LP or ESP[plr] then
        return
    end
    local part = Instance.new("Part")
    part.Name = plr.Name .. "_ESP"
    part.Size = Vector3.new(2, 5, 1)
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Position = Vector3.new(0, -9999, 0)
    part.Parent = Folder
    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP"
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 90, 0, 135)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 2.8, 0)
    gui.Enabled = false
    gui.Parent = part
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = gui
    local nameText = Instance.new("TextLabel")
    nameText.Size = UDim2.new(1, 0, 0, 16)
    nameText.Position = UDim2.new(0, 0, 0, 0)
    nameText.BackgroundTransparency = 1
    nameText.TextColor3 = Color3.new(1,1,1)
    nameText.TextStrokeTransparency = 0
    nameText.Font = Enum.Font.SourceSansBold
    nameText.TextSize = Opt.espNameSize
    nameText.Text = plr.Name
    nameText.Parent = container
    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0.5, 0)
    box.Position = UDim2.new(0.5, 0, 0, 38)
    box.Size = UDim2.new(0, Opt.espBoxWidth, 0, Opt.espBoxHeight)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = container
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Parent = box
    local hpText = Instance.new("TextLabel")
    hpText.Size = UDim2.new(1, 0, 0, 16)
    hpText.Position = UDim2.new(0, 0, 0, 82)
    hpText.BackgroundTransparency = 1
    hpText.TextColor3 = Color3.fromRGB(0,255,0)
    hpText.TextStrokeTransparency = 0
    hpText.Font = Enum.Font.SourceSansBold
    hpText.TextSize = Opt.espHPSize
    hpText.Text = "? HP"
    hpText.Parent = container
    local distText = Instance.new("TextLabel")
    distText.Size = UDim2.new(1, 0, 0, 16)
    distText.Position = UDim2.new(0, 0, 0, 98)
    distText.BackgroundTransparency = 1
    distText.TextColor3 = Color3.fromRGB(255,255,255)
    distText.TextStrokeTransparency = 0
    distText.Font = Enum.Font.SourceSansBold
    distText.TextSize = Opt.espDistanceSize
    distText.Text = "? Stud"
    distText.Parent = container
    ESP[plr] = {
        Part = part,
        Gui = gui,
        NameText = nameText,
        HealthText = hpText,
        DistanceText = distText,
        Tween = nil,
        LastPos = nil
    }
end
local function removeESP(plr)
    local esp = ESP[plr]
    if esp then
        if esp.Tween then
            esp.Tween:Cancel()
        end
        esp.Part:Destroy()
        ESP[plr] = nil
    end
end
for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(function()
    for plr, esp in pairs(ESP) do
        if not _G.a then
            esp.Gui.Enabled = false
            continue
        end
        local pos = plr:GetAttribute("LastPosition")
        local hp = plr:GetAttribute("Health") or plr:GetAttribute("health")
        if typeof(pos) == "Vector3" and (not Opt.espMaxDistance or Opt.espMaxDistance <= 0 or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or (LP.Character.HumanoidRootPart.Position - pos).Magnitude <= Opt.espMaxDistance) then
            esp.Gui.Enabled = true
            if not esp.LastPos then
                esp.LastPos = pos
                esp.Part.Position = pos
            end
            if (esp.LastPos - pos).Magnitude > 0.05 then
                esp.LastPos = pos
                if esp.Tween then
                    esp.Tween:Cancel()
                end
                esp.Tween = TweenService:Create(
                    esp.Part,
                    TweenInfoESP,
                    {Position = pos}
                )
                esp.Tween:Play()
            end
            esp.NameText.Text = plr.Name
            if typeof(hp) == "number" then
                hp = math.floor(hp)
                esp.HealthText.Text = hp .. " HP"
                if hp > 10 then
                    esp.HealthText.TextColor3 = Color3.fromRGB(0,255,0)
                elseif hp > 6 then
                    esp.HealthText.TextColor3 = Color3.fromRGB(255,255,0)
                else
                    esp.HealthText.TextColor3 = Color3.fromRGB(255,0,0)
                end
            else
                esp.HealthText.Text = "? HP"
            end
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = math.floor((hrp.Position - pos).Magnitude)
                esp.DistanceText.Text = dist .. " Stud"
            else
                esp.DistanceText.Text = "? Stud"
            end
        else
            esp.Gui.Enabled = false
        end
    end
end)
CombatTab:CreateToggle({
    Name = "Esp Player",
    CurrentValue = false,
    Flag = "esp_player",
    Callback = function(val)
        _G.a = val
        if not val then
            for _, esp in pairs(ESP) do
                esp.Gui.Enabled = false
            end
        end
    end,
})
Opt.flySpeed = 55
CombatTab:CreateButton({
Name = "Air Move (P to Toggle)",
Callback = function()
local function toggleAirMove()
    local character = LP.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = hrp:FindFirstChild("LoaderLiveFly")
    if bv then bv:Destroy() return end
    bv = Instance.new("BodyVelocity")
    bv.Name = "LoaderLiveFly"
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    local conn
    conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not bv.Parent then conn:Disconnect() return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        local uis = game:GetService("UserInputService")
        if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * 55 or Vector3.zero
    end)
end
toggleAirMove()
end,
})
local hitboxSize = 15
local connection
local modified = {}
local function expandHitbox(plr)
    if plr == LP then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if hum.Health <= 0 then return end
    if not modified[hrp] then
        modified[hrp] = hrp.Size
    end
    hrp.Size = Vector3.new(
        hitboxSize,
        hitboxSize,
        hitboxSize
    )
    hrp.Transparency = 1
    hrp.CanCollide = false
end
local function resetHitboxes()
    for hrp, oldSize in pairs(modified) do
        if hrp and hrp.Parent then
            hrp.Size = oldSize
            hrp.Transparency = 1
            hrp.CanCollide = true
        end
    end
    modified = {}
end
local function startLoop()
    if connection then
        connection:Disconnect()
    end
    connection = RunService.Heartbeat:Connect(function()
        for _, plr in pairs(Players:GetPlayers()) do
            expandHitbox(plr)
        end
    end)
end
local function stopLoop()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    resetHitboxes()
end
CombatTab:CreateToggle({
    Name = "Enemy Hitbox",
    CurrentValue = false,
    Callback = function(v)
        if v then
            startLoop()
        else
            stopLoop()
        end
    end
})
CombatOptions:CreateSection("Hit Aura")
CombatOptions:CreateInput({
    Name = "Hit Aura Range",
    CurrentValue = "50",
    PlaceholderText = "Range",
    Flag = "AuraRangeOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then auraRange = n end
    end
})
CombatOptions:CreateInput({
    Name = "Hit Aura Hits",
    CurrentValue = "5",
    PlaceholderText = "Hits",
    Flag = "AuraHitsOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.auraHits = math.floor(n) end
    end
})
CombatOptions:CreateDropdown({
    Name = "Hit Aura Whitelist",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AuraWhitelistOptions",
    Callback = function(Options)
        auraWhitelist = {}
        for n,_ in pairs(defaultWhitelistAura) do auraWhitelist[n] = true end
        for _,name in ipairs(Options) do auraWhitelist[name] = true end
    end
})
CombatOptions:CreateInput({
    Name = "TP Aura Hits",
    CurrentValue = "15",
    PlaceholderText = "Hits",
    Flag = "TPAuraHitsOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.tpAttackCount = math.floor(n) end
    end
})
CombatOptions:CreateInput({
    Name = "TP Aura Fail Limit",
    CurrentValue = "10",
    PlaceholderText = "Failures",
    Flag = "TPAuraFailOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.tpFailLimit = math.floor(n) end
    end
})
CombatOptions:CreateInput({
    Name = "TP Aura Protection Time",
    CurrentValue = "3",
    PlaceholderText = "Seconds",
    Flag = "TPAuraProtectOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 then Opt.tpProtectedTime = n end
    end
})
CombatOptions:CreateInput({
    Name = "TP Aura Offset",
    CurrentValue = "4",
    PlaceholderText = "Studs",
    Flag = "TPAuraOffsetOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 then Opt.tpOffset = n end
    end
})
CombatOptions:CreateDropdown({
    Name = "TP Aura Whitelist",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AutoWhitelistOptions",
    Callback = function(Options)
        autoWhitelist = {}
        for n,_ in pairs(defaultWhitelistAuto) do autoWhitelist[n] = true end
        for _,name in ipairs(Options) do autoWhitelist[name] = true end
    end
})
CombatOptions:CreateInput({
    Name = "Drop Teleport Interval",
    CurrentValue = "0.1",
    PlaceholderText = "Seconds",
    Flag = "DropIntervalOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.dropTPInterval = n end
    end
})
CombatOptions:CreateInput({
    Name = "Drop Scan Delay",
    CurrentValue = "0.5",
    PlaceholderText = "Seconds",
    Flag = "DropScanDelayOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 then Opt.dropDescDelay = n end
    end
})
CombatOptions:CreateInput({
    Name = "ESP Distance",
    CurrentValue = "500",
    PlaceholderText = "Studs",
    Flag = "ESPDistanceOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.espMaxDistance = n end
    end
})
CombatOptions:CreateInput({
    Name = "ESP Box Width",
    CurrentValue = "35",
    PlaceholderText = "Size",
    Flag = "ESPWidthOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.espBoxWidth = n end
    end
})
CombatOptions:CreateInput({
    Name = "ESP Box Height",
    CurrentValue = "60",
    PlaceholderText = "Size",
    Flag = "ESPHeightOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.espBoxHeight = n end
    end
})
CombatOptions:CreateInput({
    Name = "Air Move Speed",
    CurrentValue = "55",
    PlaceholderText = "Speed",
    Flag = "AirMoveSpeedOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.flySpeed = n end
    end
})
CombatOptions:CreateInput({
    Name = "Enemy Hitbox Size",
    CurrentValue = "15",
    PlaceholderText = "Size",
    Flag = "EnemyHitboxOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then hitboxSize = n end
    end
})
CombatOptions:CreateDropdown({
    Name = "Teleport Player",
    Options = getPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "TeleportPlayerOptions",
    Callback = function(v)
        selectedPlayer = type(v) == "table" and v[1] or v
    end
})
MineTab:CreateSection("Fast Break")
if support.hookfunction then
local brTime = 0
local ignoredMaterials = {}
local materialList = {}
local ignoreEnabled = true
local MaterialService =
game:GetService("MaterialService")
local camera =
workspace.CurrentCamera
for _, mat in ipairs(
    MaterialService.CompiledMaterials:GetChildren()
) do
    local name = mat.Name
    ignoredMaterials[name] =
        ignoredMaterials[name] or false
    table.insert(materialList, name)
end
MineTab:CreateInput({
   Name = "Break Speed",
   CurrentValue = "0",
   PlaceholderText = "Enter Break Speed",
   RemoveTextAfterFocusLost = false,
   Flag = "InputBreakSpeed",
   Callback = function(str)
        local val = tonumber(str)
        if typeof(val) == "number" then
            brTime = val
        end
   end,
})
local function getLookPart()
    local viewport =
        camera.ViewportSize
    local ray =
        camera:ViewportPointToRay(
            viewport.X/2,
            viewport.Y/2
        )
    local params =
        RaycastParams.new()
    params.FilterType =
        Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances =
        {game.Players.LocalPlayer.Character}
    local result =
        workspace:Raycast(
            ray.Origin,
            ray.Direction * 20,
            params
        )
    if result then
        return result.Instance
    end
end
MineTab:CreateButton({
    Name = "Ignore Block",
    Callback = function()
        if game.CoreGui:FindFirstChild("IgnoreMaterialGUI") then
            return
        end
        local sg =
        Instance.new("ScreenGui")
        sg.Name = "IgnoreMaterialGUI"
        sg.Parent = game.CoreGui
        local frame =
        Instance.new("Frame")
        frame.Size =
        UDim2.new(0,420,0,450)
        frame.Position =
        UDim2.new(0.5,-210,0.5,-225)
        frame.BackgroundColor3 =
        Color3.fromRGB(30,30,30)
        frame.Parent = sg
        local close =
        Instance.new("TextButton")
        close.Text = "X"
        close.Size =
        UDim2.new(0,30,0,30)
        close.Position =
        UDim2.new(1,-30,0,0)
        close.BackgroundColor3 =
        Color3.fromRGB(180,60,60)
        close.TextColor3 =
        Color3.fromRGB(255,255,255)
        close.Parent = frame
        close.MouseButton1Click:Connect(function()
            sg:Destroy()
        end)
        local search =
        Instance.new("TextBox")
        search.PlaceholderText =
        "Search block id..."
        search.Size =
        UDim2.new(1,-20,0,30)
        search.Position =
        UDim2.new(0,10,0,35)
        search.BackgroundColor3 =
        Color3.fromRGB(45,45,45)
        search.TextColor3 =
        Color3.fromRGB(255,255,255)
        search.Parent = frame
        local scroll =
        Instance.new("ScrollingFrame")
        scroll.Size =
        UDim2.new(1,-20,1,-75)
        scroll.Position =
        UDim2.new(0,10,0,70)
        scroll.BackgroundTransparency = 1
        scroll.Parent = frame
        local grid =
        Instance.new("UIGridLayout")
        grid.CellSize =
        UDim2.new(0,120,0,50)
        grid.CellPadding =
        UDim2.new(0,5,0,5)
        grid.Parent = scroll
        grid:GetPropertyChangedSignal("AbsoluteContentSize")
        :Connect(function()
            scroll.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                grid.AbsoluteContentSize.Y
            )
        end)
        local buttons = {}
        local function updateColor(btn, name)
            if ignoredMaterials[name] then
                btn.BackgroundColor3 =
                Color3.fromRGB(60,170,90)
            else
                btn.BackgroundColor3 =
                Color3.fromRGB(70,70,70)
            end
        end
        local function createButton(name)
            local btn =
            Instance.new("TextButton")
            btn.Text = name
            btn.TextColor3 =
            Color3.fromRGB(255,255,255)
            btn.Parent = scroll
            updateColor(btn, name)
            btn.MouseButton1Click:Connect(function()
                ignoredMaterials[name] =
                    not ignoredMaterials[name]
                updateColor(btn, name)
            end)
            buttons[name] = btn
        end
        for _, name in ipairs(materialList) do
            createButton(name)
        end
        search:GetPropertyChangedSignal("Text")
        :Connect(function()
            local text =
            string.lower(search.Text)
            for name, btn in pairs(buttons) do
                if text == ""
                or string.find(
                    string.lower(name),
                    text,
                    1,
                    true
                ) then
                    btn.Visible = true
                else
                    btn.Visible = false
                end
            end
        end)
    end
})
pcall(function()
local gbt =
require(
    RS.Systems.ItemsSystem.Libs.GetBreakingTime
)
local fbEnabled = false
local oldBreak
if typeof(hookfunction) == "function" then
 local fastBreakToggle = MineTab:CreateToggle({
        Name = "Quick Break",
        CurrentValue = false,
        Flag = "FastBreakToggle",
        Callback = function(Value)
            if Value then
                if not fbEnabled then
                    oldBreak =
                    hookfunction(
                        gbt,
                        function(...)
                            local part =
                            getLookPart()
                            if part
                            and part:IsA("BasePart") then
                                local mat =
                                part.MaterialVariant
                                if mat ~= ""
                                and ignoreEnabled
                                and ignoredMaterials[mat] then
                                    return 0/0
                                end
                            end
                            return brTime
                        end
                    )
                    fbEnabled = true
                end
            else
                if fbEnabled
                and oldBreak then
                    hookfunction(
                        gbt,
                        oldBreak
                    )
                    fbEnabled = false
                end
            end
        end,
    })
end
end)
else
end
pcall(function()
MineTab:CreateSection("Hole")
if support.hookfunction then
local breakRadius = 1
local optimization = false
local scriptEnabled = false
local ignoreOre = false
local breakX = true
local breakY = true
local breakZ = true
local Input = MineTab:CreateInput({
    Name = "Radius",
    CurrentValue = tostring(breakRadius),
    PlaceholderText = "Enter Radius",
    RemoveTextAfterFocusLost = false,
    Flag = "InputRadius",
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num > 0 then
            breakRadius = num
        end
    end,
})
local DirectionDropdown = MineTab:CreateDropdown({
    Name = "Directions",
    Options = {"X","Y","Z"},
    CurrentOption = {"X","Y","Z"},
    MultipleOptions = true,
    Flag = "DirectionDropdown",
    Callback = function(Options)
        breakX = false
        breakY = false
        breakZ = false
        for _,v in pairs(Options) do
            if v == "X" then
                breakX = true
            elseif v == "Y" then
                breakY = true
            elseif v == "Z" then
                breakZ = true
            end
        end
    end,
})
local ToggleIgnoreOre = MineTab:CreateToggle({
    Name = "Ignore Ore",
    CurrentValue = ignoreOre,
    Flag = "ToggleIgnoreOre",
    Callback = function(Value)
        ignoreOre = Value
    end,
})
local ToggleOpt = MineTab:CreateToggle({
    Name = "Optimization (Batch)",
    CurrentValue = optimization,
    Flag = "ToggleOptimization",
    Callback = function(Value)
        optimization = Value
    end,
})
local ToggleScript = MineTab:CreateToggle({
    Name = "Nuke Radius",
    CurrentValue = scriptEnabled,
    Flag = "ToggleScript",
    Callback = function(Value)
        scriptEnabled = Value
    end,
})
local player = Players.LocalPlayer
local ActionsSystem = require(game.ReplicatedStorage.Systems.ActionsSystem)
local BlocksSystem = require(game.ReplicatedStorage.Systems.BlocksSystem)
local BlockState = require(game.ReplicatedStorage.Libs.BlockState)
local Coordinates = require(game.ReplicatedStorage.Libs.Coordinates)
local BreakingReplicator = require(game.ReplicatedStorage.Systems.PlayersSystem.Libs.PlayerBreakingReplicator)
local queue = {}
local layerIndex = -breakRadius
local oreList = {
    iron_ore = true,
    gold_ore = true,
    coal_ore = true,
    diamond_ore = true,
    emerald_ore = true,
}
local function isOre(part)
    if not ignoreOre then
        return false
    end
    local variant = part.MaterialVariant
    if variant and oreList[string.lower(variant)] then
        return true
    end
    return false
end
local function buildQueueLayer(center,layerY)
    table.clear(queue)
    if breakY then
        for x = -breakRadius, breakRadius do
            for z = -breakRadius, breakRadius do
                local px = breakX and x or 0
                local py = layerY
                local pz = breakZ and z or 0
                queue[#queue+1] =
                    center +
                    Vector3.new(px*4,py*4,pz*4)
            end
        end
    else
        for y = 0,1 do
            for x = -breakRadius, breakRadius do
                for z = -breakRadius, breakRadius do
                    local px = breakX and x or 0
                    local py = y
                    local pz = breakZ and z or 0
                    queue[#queue+1] =
                        center +
                        Vector3.new(px*4,py*4,pz*4)
                end
            end
        end
    end
end
local function buildFullQueue(center)
    table.clear(queue)
    if breakY then
        for y = -breakRadius, breakRadius do
            for x = -breakRadius, breakRadius do
                for z = -breakRadius, breakRadius do
                    local px = breakX and x or 0
                    local py = y
                    local pz = breakZ and z or 0
                    queue[#queue+1] =
                        center +
                        Vector3.new(px*4,py*4,pz*4)
                end
            end
        end
    else
        for y = 0,1 do
            for x = -breakRadius, breakRadius do
                for z = -breakRadius, breakRadius do
                    local px = breakX and x or 0
                    local py = y
                    local pz = breakZ and z or 0
                    queue[#queue+1] =
                        center +
                        Vector3.new(px*4,py*4,pz*4)
                end
            end
        end
    end
end
local function breakBlock(pos)
    local rayOrigin =
        pos + Vector3.new(0,3,0)
    local ray =
        Ray.new(
            rayOrigin,
            Vector3.new(0,-6,0)
        )
    local part =
        workspace:FindPartOnRayWithIgnoreList(
            ray,
            {player.Character}
        )
    if not part then return end
    if isOre(part) then return end
    local coord =
        Coordinates.coordinatesFromWorkspaceVector3(
            part.Position
        )
    local state =
        BlocksSystem.getBlockState(coord)
    if not state then return end
    local blockId =
        BlockState.getBlockId(state)
    local region =
        Coordinates.regionNameFromCoordinates(coord)
    local chunk =
        Coordinates.chunkNameFromCoordinates(coord)
    local block =
        Coordinates.blockNameFromCoordinates(coord)
    BreakingReplicator.client_updatePlayerTarget(
        region,
        chunk,
        block
    )
    ActionsSystem.client_breakBlock(
        region,
        chunk,
        block,
        blockId
    )
end
task.spawn(function()
    while true do
        if not scriptEnabled then
            task.wait(0.1)
            continue
        end
        local char = player.Character
        if not char then
            task.wait(0.1)
            continue
        end
        local hrp =
            char:FindFirstChild(
                "HumanoidRootPart"
            )
        if not hrp then
            task.wait(0.1)
            continue
        end
        if optimization then
            buildQueueLayer(
                hrp.Position,
                layerIndex
            )
            layerIndex += 1
            if layerIndex > breakRadius then
                layerIndex = -breakRadius
            end
        else
            buildFullQueue(
                hrp.Position
            )
        end
        for i=1,#queue do
            local pos = queue[i]
            task.spawn(function()
                breakBlock(pos)
            end)
        end
        task.wait(0.05)
    end
end)
else
end
local Workspace = game:GetService("Workspace")
local plr = Players.LocalPlayer
local Remote = RS
:WaitForChild("Systems")
:WaitForChild("ActionsSystem")
:WaitForChild("Network")
:WaitForChild("Interact")
_G.radius = _G.radius or 1
_G.r = _G.r or 16
local STEP = 4
local TARGET_IDS = {
	[555] = true,
	[556] = true,
	[557] = true
}
local currentSlot = "1"
local function updateSlot()
	local invStr = plr:GetAttribute("inventory")
	if not invStr then return end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(invStr)
	end)
	if not ok then return end
	for slot, item in pairs(data) do
		if typeof(item) == "table" then
			local id = item.id
			if TARGET_IDS[id] then
				currentSlot = tostring(slot)
				return
			end
		end
	end
end
plr:GetAttributeChangedSignal("inventory"):Connect(function()
	updateSlot()
end)
updateSlot()
local orientationInfos = {
	half = "top",
	face_facing = "south",
	faceSide = "Top",
	face = "floor",
	axis = "y",
	facingXZ = "south",
	isSide = false,
	hinge = "left",
	facing = "down",
	normalId = Enum.NormalId.Top,
	hitFacing = "up",
	rotation = 1
}
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
local lastSent = {}
local LIFE_TIME = 2
local connection
MineTab:CreateInput({
	Name = "Radius",
	PlaceholderText = "number",
	RemoveTextAfterFocusLost = false,
	Callback = function(txt)
		local n = tonumber(txt)
		if n then
			_G.radius = math.floor(n)
		end
	end
})
end)
MineTab:CreateToggle({
	Name = "Mine killer (might not work yo)",
	CurrentValue = false,
	Callback = function(v)
		if connection then
			connection:Disconnect()
			connection = nil
		end
		if not v then return end
		connection = RunService.Heartbeat:Connect(function()
			local char = plr.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			params.FilterDescendantsInstances = {char}
			local center = hrp.Position
			local r = _G.radius
			local depth = _G.r
			for x = -r, r do
				for z = -r, r do
					local offset = Vector3.new(
						x * STEP,
						0,
						z * STEP
					)
					local origin = center + offset
					local result = Workspace:Raycast(
						origin,
						Vector3.new(0, -depth, 0),
						params
					)
					if result then
						local part = result.Instance
						if part
						and part:IsA("BasePart") then
							local variant = part.MaterialVariant
							if typeof(variant) == "string"
							and (
								string.find(variant, "grass_side", 1, true)
								or string.find(variant, "dirt", 1, true)
							) then
								local pos = result.Position
								local normal = result.Normal
								local blockPos = pos - normal * 0.1
								local gx = math.floor(blockPos.X / STEP)
								local gy = math.floor(blockPos.Y / STEP)
								local gz = math.floor(blockPos.Z / STEP)
								local key = gx..","..gy..","..gz
								local now = tick()
								if not lastSent[key]
								or now - lastSent[key] > LIFE_TIME then
									lastSent[key] = now
									local args = {
										{
											orientationInfos = orientationInfos,
											coordinates = vector.create(
												gx,
												gy,
												gz
											),
											action = "rightClickBlock",
											player = plr,
											hotbarSlot = currentSlot
										}
									}
									Remote:InvokeServer(unpack(args))
								end
							end
						end
					end
				end
			end
		end)
	end
})
MineTab:CreateSection("Xray")
local BATCH = 10
local DELAY = 0.2
local OreColors = {
	iron_ore = Color3.fromRGB(170,170,170),
	gold_ore = Color3.fromRGB(255,215,0),
	diamond_ore = Color3.fromRGB(0,255,255),
	coal_ore = Color3.fromRGB(40,40,40)
}
local ores = {}
local queue = {}
local running = false
local xrayEnabled = false
local function add(part)
	if not xrayEnabled then return end
	if part:FindFirstChild("OreHL") then
		return
	end
	local color =
	OreColors[part.MaterialVariant]
	if not color then return end
	local hl = Instance.new("Highlight")
	hl.Name = "OreHL"
	hl.FillColor = color
	hl.OutlineColor = color
	hl.FillTransparency = 0.5
	hl.Parent = part
end
local function process()
	if running
	or not xrayEnabled then
		return
	end
	running = true
	task.spawn(function()
		local count = 0
		while #queue > 0
		and count < BATCH
		and xrayEnabled do
			local part =
			table.remove(queue, 1)
			if part
			and part.Parent then
				add(part)
			end
			count += 1
		end
		running = false
		if #queue > 0
		and xrayEnabled then
			task.delay(
				DELAY,
				process
			)
		end
	end)
end
local function clearXray()
	for _,v in ipairs(ores) do
		if v
		and v:FindFirstChild("OreHL") then
			v.OreHL:Destroy()
		end
	end
end
local function scanWorld()
	table.clear(ores)
	table.clear(queue)
	for _,v in ipairs(
		workspace:GetDescendants()
	) do
		if v:IsA("BasePart") then
			local mat =
			v.MaterialVariant
			if OreColors[mat] then
				table.insert(ores, v)
				table.insert(queue, v)
			end
		end
	end
	process()
end
workspace.DescendantAdded:Connect(function(v)
	if not xrayEnabled then return end
	if v:IsA("BasePart") then
		local mat =
		v.MaterialVariant
		if OreColors[mat] then
			table.insert(ores, v)
			table.insert(queue, v)
			process()
		end
	end
end)
MineTab:CreateToggle({
	Name = "Xray",
	CurrentValue = false,
	Flag = "XrayOre",
	Callback = function(Value)
		xrayEnabled = Value
		if Value then
			scanWorld()
		else
			clearXray()
		end
	end,
})
MineOptions:CreateSection("Fast Break")
MineOptions:CreateInput({
    Name = "Break Speed",
    CurrentValue = "0",
    PlaceholderText = "Seconds",
    Flag = "BreakSpeedOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n then brTime = n end
    end
})
MineOptions:CreateToggle({
    Name = "Ignore Block Filter",
    CurrentValue = ignoreEnabled,
    Flag = "IgnoreEnabledOptions",
    Callback = function(v) ignoreEnabled = v end
})
MineOptions:CreateSection("Hole")
MineOptions:CreateInput({
    Name = "Radius",
    CurrentValue = tostring(breakRadius),
    PlaceholderText = "Radius",
    Flag = "HoleRadiusOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then breakRadius = n end
    end
})
MineOptions:CreateDropdown({
    Name = "Directions",
    Options = {"X","Y","Z"},
    CurrentOption = {"X","Y","Z"},
    MultipleOptions = true,
    Flag = "HoleDirectionsOptions",
    Callback = function(Options)
        breakX,breakY,breakZ = false,false,false
        for _,v in ipairs(Options) do
            if v == "X" then breakX = true elseif v == "Y" then breakY = true elseif v == "Z" then breakZ = true end
        end
    end
})
MineOptions:CreateToggle({Name="Ignore Ore",CurrentValue=ignoreOre,Flag="IgnoreOreOptions",Callback=function(v) ignoreOre=v end})
MineOptions:CreateToggle({Name="Optimization",CurrentValue=optimization,Flag="OptimizationOptions",Callback=function(v) optimization=v end})
MineOptions:CreateToggle({Name="Nuke Radius",CurrentValue=scriptEnabled,Flag="NukeOptions",Callback=function(v) scriptEnabled=v end})
MineOptions:CreateInput({
    Name = "Surface Scan Radius",
    CurrentValue = tostring(_G.radius or 1),
    PlaceholderText = "Radius",
    Flag = "SurfaceRadiusOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n then _G.radius = math.floor(n) end
    end
})
MineOptions:CreateInput({
    Name = "Surface Scan Depth",
    CurrentValue = tostring(_G.r or 16),
    PlaceholderText = "Depth",
    Flag = "SurfaceDepthOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n then _G.r = math.floor(n) end
    end
})
MineOptions:CreateInput({
    Name = "Ore Batch",
    CurrentValue = tostring(BATCH),
    PlaceholderText = "Count",
    Flag = "OreBatchOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then BATCH = math.floor(n) end
    end
})
MineOptions:CreateInput({
    Name = "Ore Delay",
    CurrentValue = tostring(DELAY),
    PlaceholderText = "Seconds",
    Flag = "OreDelayOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 then DELAY = n end
    end
})

EntityTab:CreateSection("Kill Entity Aura")
local entitiesFolder =
workspace:WaitForChild("Entities")
local entityAuraEnabled = false
local entityRange = 50
Opt.entityHits = 5
Opt.spawnHeight = 2
local function getNearestEntity()
	local myChar = LP.Character
	if not myChar then return end
	local myHRP =
	myChar:FindFirstChild(
		"HumanoidRootPart"
	)
	if not myHRP then return end
	local nearestEntity = nil
	local shortestDist = entityRange
	for _, entity in ipairs(
		entitiesFolder:GetChildren()
	) do
		local hrp =
		entity:FindFirstChild(
			"HumanoidRootPart"
		)
		or
		entity:FindFirstChild(
			"PrimaryPart"
		)
		if hrp then
			local dist =
			(
				myHRP.Position
				-
				hrp.Position
			).Magnitude
			if dist < shortestDist then
				nearestEntity = entity
				shortestDist = dist
			end
		end
	end
	return nearestEntity
end
task.spawn(function()
	while true do
		if entityAuraEnabled then
			local myChar = LP.Character
			if myChar then
				local slot =
				myChar:GetAttribute(
					"ReplicatedHotbarSlot"
				)
				if slot then
					local target =
					getNearestEntity()
					if target then
						for i = 1,5 do
							pcall(function()
								attackRemote:InvokeServer(
									target,
									slot
								)
							end)
						end
					end
				end
			end
		end
		RunService.Heartbeat:Wait()
	end
end)
EntityTab:CreateToggle({
	Name = "Entity Hit Aura",
	CurrentValue = false,
	Flag = "KillEntityAura",
	Callback = function(Value)
		entityAuraEnabled = Value
	end,
})
EntityTab:CreateSection("Entity Spawner")
local assetsEntities =
RS:WaitForChild("Assets")
:WaitForChild("Entities")
local workspaceEntities =
workspace:WaitForChild("Entities")
local cursorPosValue =
RS:WaitForChild("Libs")
:WaitForChild("Cursor")
:WaitForChild("HoveredCoordinates")
local function getEntityNames()
	local list = {}
	for _, entity in ipairs(
		assetsEntities:GetChildren()
	) do
		table.insert(
			list,
			entity.Name
		)
	end
	table.sort(list)
	return list
end
local selectedEntity = nil
local EntityDropdown =
EntityTab:CreateDropdown({
	Name = "Select Entity",
	Options = getEntityNames(),
	CurrentOption = {},
	MultipleOptions = false,
	Flag = "SelectedEntity",
	Callback = function(Option)
		if typeof(Option) == "table" then
			selectedEntity = Option[1]
		else
			selectedEntity = Option
		end
	end,
})
EntityTab:CreateButton({
	Name = "Spawn Entity (Client and no AI)",
	Callback = function()
		if not selectedEntity then
			return
		end
		local template =
		assetsEntities:FindFirstChild(
			selectedEntity
		)
		if not template then
			return
		end
		local clone =
		template:Clone()
		clone.Parent =
		workspaceEntities
		local pos =
		cursorPosValue.Value
		local newPos =
		Vector3.new(
			pos.X * 4,
			pos.Y * 4 + Opt.spawnHeight,
			pos.Z * 4
		)
		local hrp =
		clone:FindFirstChild(
			"HumanoidRootPart"
		)
		or clone.PrimaryPart
		if hrp then
			hrp.CFrame =
			CFrame.new(newPos)
		end
	end,
})
EntityOptions:CreateSection("Entity Aura")
EntityOptions:CreateInput({
    Name = "Entity Range",
    CurrentValue = "50",
    PlaceholderText = "Range",
    Flag = "EntityRangeOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then entityRange = n end
    end
})
EntityOptions:CreateInput({
    Name = "Entity Hits",
    CurrentValue = "5",
    PlaceholderText = "Hits",
    Flag = "EntityHitsOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.entityHits = math.floor(n) end
    end
})
EntityOptions:CreateDropdown({
    Name = "Spawn Entity",
    Options = getEntityNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "EntitySelectOptions",
    Callback = function(v)
        if type(v) == "table" then selectedEntity = v[1] else selectedEntity = v end
    end
})
EntityOptions:CreateInput({
    Name = "Spawn Height",
    CurrentValue = "2",
    PlaceholderText = "Height",
    Flag = "EntitySpawnHeightOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n then Opt.spawnHeight = n end
    end
})

local Dropdown
local currentTrack
local selectedAnim = "None"
local animMap = {}
local animList = {"None"}
local function stopAnim()
	if currentTrack then
		currentTrack:Stop()
		currentTrack:Destroy()
		currentTrack = nil
	end
end
local function getChar()
	return LP.Character or LP.CharacterAdded:Wait()
end
local function loadAnimList(Char)
	local AnimFolder = Char:WaitForChild("Animations", 10)
	if not AnimFolder then
		animMap = {}
		animList = {"None"}
		if Dropdown and Dropdown.Refresh then
			Dropdown:Refresh(animList, true)
		end
		return nil
	end
	animMap = {}
	animList = {"None"}
	for _, v in ipairs(AnimFolder:GetChildren()) do
		if v:IsA("Animation") then
			table.insert(animList, v.Name)
			animMap[v.Name] = v
		end
	end
	if Dropdown and Dropdown.Refresh then
		Dropdown:Refresh(animList, true)
	end
	return Char:FindFirstChildOfClass("Humanoid")
end
local function playSelected()
	stopAnim()
	if selectedAnim == "None" then
		return
	end
	local Char = LP.Character
	if not Char then return end
	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum then return end
	local Animator = Hum:FindFirstChildOfClass("Animator")
	if not Animator then return end
	local anim = animMap[selectedAnim]
	if anim then
		currentTrack = Animator:LoadAnimation(anim)
		currentTrack:Play()
	end
end
Dropdown = MiscOptions:CreateDropdown({
	Name = "State",
	Options = animList,
	CurrentOption = {"None"},
	MultipleOptions = false,
	Flag = "PlayAnimDropdown",
	Callback = function(Options)
		selectedAnim = Options[1] or "None"
		playSelected()
	end,
})
local function onCharacter(Char)
	stopAnim()
	loadAnimList(Char)
	playSelected()
end
if LP.Character then
	onCharacter(LP.Character)
end
LP.CharacterAdded:Connect(onCharacter)
local reduceLagAlready = false
MiscTab:CreateButton({
Name = "Performance Mode",
Callback = function()
if not reduceLagAlready then
for _,v in ipairs(workspace:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false end
end
reduceLagAlready = true
else

end
end,
})
MiscTab:CreateToggle({
Name = "Developer Debug",
CurrentValue = false,
Flag = "DevDebug",
Callback = function(val)
game:GetService("ReplicatedStorage").Client.DebugGuiEnabled.Value = val
end,
})
local Map = workspace.Map
local Interact = RS.Systems.ActionsSystem.Network.Interact
Opt.interactDelay = 0.2
local list = {}
local info = {
    half = "bottom",
    face_facing = "west",
    faceSide = "Top",
    face = "floor",
    axis = "y",
    facingXZ = "west",
    isSide = false,
    hinge = "right",
    facing = "down",
    normalId = Enum.NormalId.Top,
    hitFacing = "up",
    rotation = 13
}
local function run(v)
    task.spawn(function()
        while list[v] do
            if _G.InterestObject then
                local pos = list[v]
                pcall(function()
                    Interact:InvokeServer({
                        orientationInfos = info,
                        coordinates = vector.create(pos.X/4,pos.Y/4,pos.Z/4),
                        action = "rightClickBlock",
                        player = LP,
                        hotbarSlot = "1"
                    })
                end)
            else
                task.wait(0.2)
            end
            task.wait()
        end
    end)
end
local function add(v)
    if v:IsA("BasePart") and v.Name == "PrimaryPart" and not list[v] then
        list[v] = v.Position
        run(v)
        v:GetPropertyChangedSignal("Position"):Connect(function()
            list[v] = v.Position
        end)
        v.AncestryChanged:Connect(function()
            if not v.Parent then
                task.wait(3)
                if not v.Parent then
                    list[v] = nil
                end
            end
        end)
    end
end
for _,v in ipairs(Map:GetDescendants()) do
    add(v)
end
Map.DescendantAdded:Connect(add)
MiscTab:CreateToggle({
    Name = "Interact All Blocks",
    CurrentValue = false,
    Flag = "InterestObject",
    Callback = function(v)
        _G.InterestObject = v
    end,
})
MiscTab:CreateButton({
    Name = "Reload Chunk",
    Callback = function()
        local fast = RS.Client.States.FastChunkLoading
        local oldFast = fast.Value
        fast.Value = true
        local char = LP.Character or LP.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local PG = LP:WaitForChild("PlayerGui")
        local function getChunkName()
            RS.Client.DebugGuiEnabled.Value = true
            task.wait()
            local dbg = PG:WaitForChild("MasterScreenGui"):WaitForChild("Debugger")
            local txt = dbg:GetChildren()[4].Text
            RS.Client.DebugGuiEnabled.Value = false
            local x, z = txt:match("Coordinates names:%s*([%-%.%d]+)%s*%-%s*([%-%.%d]+)")
            if x and z then
                return x .. "_" .. z
            end
        end
        local chunkName = getChunkName()
        if not chunkName then
            fast.Value = oldFast
            return
        end
        local pool = RS.Systems.ChunksSystem.ClientPool
        local folder = pool:FindFirstChild(chunkName)
        if folder and folder:FindFirstChild("Unload") then
            hrp.Anchored = true
            folder.Unload.Value = true
            repeat
                task.wait(0.2)
                chunkName = getChunkName()
                folder = chunkName and pool:FindFirstChild(chunkName)
            until folder and folder:GetAttribute("Status") == "Rendered"
            hrp.Anchored = false
        end
        fast.Value = oldFast
    end,
})
if support.raknet_desync then
MiscTab:CreateToggle({
Name = "Blink",
CurrentValue = false,
Flag = "ok",
Callback = function(val)
raknet.desync(val)
end,
})
else

end
if support.getrawmetatable and support.setreadonly then
    local antiSuffHooked = false
    _G.AntiSuffocating = false
    MiscTab:CreateToggle({
        Name = "Anti Suffocating",
        CurrentValue = false,
        Flag = "AntiSuffocating",
        Callback = function(val)
            _G.AntiSuffocating = val
            local v = game:GetService("ReplicatedStorage")
                :WaitForChild("Client")
                :WaitForChild("States")
                :WaitForChild("Suffocating")
            if val then
                v.Value = false
                if not antiSuffHooked then
                    antiSuffHooked = true
                    local mt = getrawmetatable(game)
                    local old = mt.__newindex
                    setreadonly(mt, false)
                    mt.__newindex = newcclosure(function(self, key, value)
                        if _G.AntiSuffocating
                        and self == v
                        and key == "Value"
                        and value == true then
                            return old(self, key, false)
                        end
                        return old(self, key, value)
                    end)
                    setreadonly(mt, true)
                end
            end
        end,
    })
else

end
if support.getrawmetatable and support.setreadonly then
    local antiDamageHooked = false
    _G.AntiDamageEffect = false
    MiscTab:CreateToggle({
        Name = "No Damage Effect",
        CurrentValue = false,
        Flag = "AntiDamageEffect",
        Callback = function(val)
            _G.AntiDamageEffect = val
            if antiDamageHooked then
                return
            end
            antiDamageHooked = true
            local damaged = game:GetService("ReplicatedStorage")
                :WaitForChild("Client")
                :WaitForChild("Events")
                :WaitForChild("Damaged")
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if _G.AntiDamageEffect
                and self == damaged
                and method == "Fire" then
                    return
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end,
    })
else

end
local lastDeadCFrame = nil
local function savePos(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        lastDeadCFrame = hrp.CFrame
    end
end
local function hookCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    hum.Died:Connect(function()
        savePos(char)
    end)
    LP.CharacterRemoving:Connect(function(oldChar)
        if oldChar == char then
            savePos(char)
        end
    end)
end
LP.CharacterAdded:Connect(hookCharacter)
if LP.Character then
    hookCharacter(LP.Character)
end
MiscTab:CreateButton({
    Name = "Teleport Last Dead Position",
    Callback = function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if lastDeadCFrame then
            hrp.CFrame = lastDeadCFrame
        end
    end,
})
MiscOptions:CreateSection("Utility")
MiscOptions:CreateInput({
    Name = "Interact Delay",
    CurrentValue = "0.2",
    PlaceholderText = "Seconds",
    Flag = "InteractDelayOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 then Opt.interactDelay = n end
    end
})
MiscOptions:CreateInput({
    Name = "ESP Name Size",
    CurrentValue = tostring(Opt.espNameSize),
    PlaceholderText = "Text Size",
    Flag = "ESPNameSizeOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.espNameSize = n end
    end
})
MiscOptions:CreateInput({
    Name = "ESP HP Size",
    CurrentValue = tostring(Opt.espHPSize),
    PlaceholderText = "Text Size",
    Flag = "ESPHPSizeOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.espHPSize = n end
    end
})
MiscOptions:CreateInput({
    Name = "ESP Distance Text Size",
    CurrentValue = tostring(Opt.espDistanceSize),
    PlaceholderText = "Text Size",
    Flag = "ESPDistSizeOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.espDistanceSize = n end
    end
})

local chestPreview = {
	enabled = false,
	canLoot = false,
	guiCache = {},
	highlightCache = {},
	watched = {},
	trackedHitboxes = {},
	dropConn = nil,
	moveLoop = nil,
	slot = 42,
	gap = 4,
	cols = 9,
	minDist = 8,
	maxDist = 140,
	highlightTransparency = 0.45,
	guiOffset = 10,
	lootDist = 30
}
local CP = chestPreview
local HttpService = game:GetService("HttpService")
local PlayerGui = LP:WaitForChild("PlayerGui")
local Cam = workspace.CurrentCamera
local Map = workspace:WaitForChild("Map")
local Drops = workspace:WaitForChild("Drops")
local PourIntoSlot = RS.Systems.InventorySystem.Network.PourIntoSlot
local DropRemote = RS.Systems.DropsSystem.Network.Drop
local Replicator = RS.Systems.InventorySystem.Libs.PlayerContainerReplicator.Network
local function safeRequire(obj)
    if not obj then return end
    local ok, result = pcall(require, obj)
    if ok then return result end
end
local ItemsData = safeRequire(RS.Systems.ItemsSystem.Configuration.ItemsData)
local TextureProvider = safeRequire(RS.Assets.TextureProvider)
local TextureBlocks = safeRequire(RS.Assets.TexturePack.blocks)
local UtilsBlocks
if support.require then
    local blockSystem = RS.Systems:FindFirstChild("BlockSystem") or RS.Systems:FindFirstChild("BlocksSystem")
    local libs = blockSystem and blockSystem:FindFirstChild("Libs")
    local module = libs and libs:FindFirstChild("UtilsBlocks")
    if module and module:IsA("ModuleScript") then
        local ok, result = pcall(require, module)
        if ok then UtilsBlocks = result end
    end
end
local function decode(str)
	local ok, data = pcall(function()
		return HttpService:JSONDecode(str)
	end)
	if ok then
		return data
	end
end
local function getRoot()
	local c = LP.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getItemName(id)
	local d = ItemsData and ItemsData[id]
	return d and d.name
end
local function getBlockName(id)
	if not UtilsBlocks then return end
	local ok, name = pcall(function()
		return UtilsBlocks.getBlockNameFromBlockId(id)
	end)
	if ok then
		return name
	end
end
local function getTextureByName(name)
	if not name or not TextureProvider then return end
	local ok, img = pcall(function()
		return TextureProvider.getImage2d(name)
	end)
	if ok and img and img.imageId and img.imageId ~= "" then
		return {
			image = img.imageId,
			size = img.rectSize,
			x = img.x,
			y = img.y,
			sheet = true
		}
	end
	if TextureBlocks then
		local blockImg = TextureBlocks[name]
		if blockImg and blockImg ~= "" then
			return {
				image = "rbxassetid://" .. blockImg,
				sheet = false
			}
		end
	end
end
local function applyTexture(box, itemId, blockId)
	if not support.require then return end
	local name
	if itemId then
		name = getItemName(itemId)
	elseif blockId then
		name = getBlockName(blockId)
	end
	if not name then return end
	local tex = getTextureByName(name)
	if not tex then return end
	box.Image = tex.image
	if tex.sheet then
		box.ImageRectSize = Vector2.new(tex.size, tex.size)
		box.ImageRectOffset = Vector2.new(tex.x * tex.size, tex.y * tex.size)
	end
	box.ResampleMode = Enum.ResamplerMode.Pixelated
end
local function getSlotData(slot)
	if type(slot) == "table" then
		return slot.id, slot.blockId, slot.qty and tostring(slot.qty) or ""
	end
	return nil, nil, ""
end
local function hasAnyItem(inv, isFurnace)
	if isFurnace then
		for i = 1, 3 do
			local s = inv[tostring(i)]
			if type(s) == "table" and (s.id or s.blockId) then
				return true
			end
		end
		return false
	else
		for i = 1, 27 do
			local s = inv[tostring(i)]
			if type(s) == "table" and (s.id or s.blockId) then
				return true
			end
		end
		return false
	end
end
local function lootSlot(slotNumber, part)
	if not CP.canLoot then return end
	if not part or not part.Parent then return end
	local p = part.Position
	pcall(function()
		PourIntoSlot:InvokeServer(
			{
				slot = tostring(slotNumber),
				container = vector.create(p.X / 4, p.Y / 4, p.Z / 4)
			},
			{
				slot = "50",
				container = LP
			},
			1024
		)
	end)
	pcall(function()
		DropRemote:InvokeServer({
			qty = 1024,
			throwDirection = vector.create(0, 0, 0),
			slot = "50"
		})
	end)
end
local function removeGui(part)
	local g = CP.guiCache[part]
	if g then
		g:Destroy()
		CP.guiCache[part] = nil
	end
	local h = CP.highlightCache[part]
	if h then
		h:Destroy()
		CP.highlightCache[part] = nil
	end
end
local function makeSlot(parent, x, y, itemId, blockId, qtyText, slotNumber, part)
	local isImage = support.require
	local box = Instance.new(isImage and "ImageButton" or "TextButton")
	box.Parent = parent
	box.Size = UDim2.new(0, CP.slot, 0, CP.slot)
	box.Position = UDim2.new(0, x, 0, y)
	box.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	box.BackgroundTransparency = 0.35
	box.BorderSizePixel = 0
	if isImage then
		applyTexture(box, itemId, blockId)
	else
		box.TextScaled = true
		box.Text = tostring(itemId or blockId or "")
		box.TextColor3 = Color3.new(1, 1, 1)
	end
	box.Activated:Connect(function()
		lootSlot(slotNumber, part)
	end)
	local qty = Instance.new("TextLabel")
	qty.Parent = box
	qty.BackgroundTransparency = 1
	qty.AnchorPoint = Vector2.new(1, 1)
	qty.Position = UDim2.new(1, -2, 1, -1)
	qty.Size = UDim2.new(0.6, 0, 0.4, 0)
	qty.Font = Enum.Font.SourceSansBold
	qty.TextScaled = true
	qty.TextStrokeTransparency = 0
	qty.TextColor3 = Color3.new(1, 1, 1)
	qty.Text = qtyText or ""
end
local function createHighlight(model, format)
	if not model then return end
	local old = CP.highlightCache[model]
	if old then
		old:Destroy()
		CP.highlightCache[model] = nil
	end
	local hl = Instance.new("Highlight")
	hl.Name = "ChestPreviewHighlight"
	hl.Adornee = model
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = CP.highlightTransparency
	hl.OutlineTransparency = 0
	hl.Enabled = CP.enabled
	if format == "Furnace" then
		hl.FillColor = Color3.fromRGB(130, 130, 130)
		hl.OutlineColor = Color3.fromRGB(90, 90, 90)
	else
		hl.FillColor = Color3.fromRGB(255, 221, 0)
		hl.OutlineColor = Color3.fromRGB(255, 245, 160)
	end
	hl.Parent = model
	CP.highlightCache[model] = hl
end
local function createGui(model, data)
	local inv = data.inventory
	if not inv then return end
	local part = model:FindFirstChild("PrimaryPart") or model:FindFirstChildWhichIsA("BasePart")
	if not part then return end
	local format = inv.format or "Chest"
	local isFurnace = format == "Furnace"
	if not hasAnyItem(inv, isFurnace) then
		removeGui(part)
		return
	end
	removeGui(part)
	if not CP.enabled then return end
	createHighlight(model, format)
	local bb = Instance.new("BillboardGui")
	bb.Parent = PlayerGui
	bb.Adornee = part
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Enabled = false
	bb.Active = true
	bb.MaxDistance = CP.maxDist
	bb.StudsOffset = Vector3.new(0, CP.guiOffset, 0)
	bb.Size = isFurnace and UDim2.new(0, 240, 0, 180) or UDim2.new(0, 475, 0, 170)
	CP.guiCache[part] = bb
	local main = Instance.new("Frame")
	main.Parent = bb
	main.Size = UDim2.new(1, 0, 1, 0)
	main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	main.BackgroundTransparency = 0.48
	main.BorderSizePixel = 0
	local title = Instance.new("TextLabel")
	title.Parent = main
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 8, 0, 0)
	title.Size = UDim2.new(0, 160, 0, 22)
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Text = format
	local stateObj = model:FindFirstChild("State")
	if stateObj then
		local btn1 = Instance.new("ImageButton")
		btn1.Parent = main
		btn1.AnchorPoint = Vector2.new(1, 0)
		btn1.Position = UDim2.new(1, -8, 0, 24)
		btn1.Size = UDim2.new(0, 40, 0, 40)
		btn1.Image = "rbxassetid://126860634030878"
		btn1.BorderSizePixel = 0
		local function updateState()
			btn1.BackgroundColor3 = stateObj.Value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
		end
		updateState()
		stateObj:GetPropertyChangedSignal("Value"):Connect(updateState)
		btn1.Activated:Connect(function()
			stateObj.Value = not stateObj.Value
			if stateObj.Value then
				pcall(function()
					Replicator:FireServer(vector.create(part.Position.X / 4, part.Position.Y / 4, part.Position.Z / 4))
				end)
			else
				pcall(function()
					Replicator:FireServer()
				end)
			end
		end)
	end
	local btn2 = Instance.new("ImageButton")
	btn2.Parent = main
	btn2.AnchorPoint = Vector2.new(1, 0)
	btn2.Position = UDim2.new(1, -8, 0, 70)
	btn2.Size = UDim2.new(0, 40, 0, 40)
	btn2.BorderSizePixel = 0
	btn2.Activated:Connect(function()
		task.spawn(function()
			local max = isFurnace and 3 or 27
			for i = 1, max do
				local s = inv[tostring(i)]
				if type(s) == "table" and (s.id or s.blockId) then
					lootSlot(i, part)
					task.wait(0.15)
				end
			end
		end)
	end)
	if isFurnace then
		local id1, b1, q1 = getSlotData(inv["1"])
		local id2, b2, q2 = getSlotData(inv["2"])
		local id3, b3, q3 = getSlotData(inv["3"])
		makeSlot(main, 20, 35, id1, b1, q1, "1", part)
		makeSlot(main, 20, 105, id2, b2, q2, "2", part)
		makeSlot(main, 145, 70, id3, b3, q3, "3", part)
		local arrow = Instance.new("TextLabel")
		arrow.Parent = main
		arrow.BackgroundTransparency = 1
		arrow.Position = UDim2.new(0, 78, 0, 68)
		arrow.Size = UDim2.new(0, 60, 0, 30)
		arrow.Text = "-->"
		arrow.TextScaled = true
		arrow.TextColor3 = Color3.new(1, 1, 1)
	else
		for i = 1, 27 do
			local slotIndex = 28 - i
			local col = (i - 1) % 9
			local row = math.floor((i - 1) / 9)
			local x = 8 + col * (CP.slot + CP.gap)
			local y = 24 + row * (CP.slot + CP.gap)
			local slot = inv[tostring(slotIndex)]
			makeSlot(
				main,
				x,
				y,
				type(slot) == "table" and slot.id,
				type(slot) == "table" and slot.blockId,
				type(slot) == "table" and slot.qty and tostring(slot.qty) or "",
				slotIndex,
				part
			)
		end
	end
end
local function refresh(model)
	if not CP.enabled then return end
	local b = model:GetAttribute("b")
	if typeof(b) ~= "string" then return end
	local json = b:match("^%d+;%d+;(.+)$")
	if not json then return end
	local data = decode(json)
	if not data then return end
	createGui(model, data)
end
local function refreshAll()
	for model in pairs(CP.watched) do
		if model and model.Parent then
			refresh(model)
		else
			CP.watched[model] = nil
		end
	end
end
local function watch(v)
	if CP.watched[v] then return end
	if not v:IsA("Model") then return end
	CP.watched[v] = true
	task.spawn(function()
		task.wait(0.5)
		refresh(v)
		v:GetAttributeChangedSignal("b"):Connect(function()
			refresh(v)
		end)
	end)
end
for _, v in ipairs(Map:GetDescendants()) do
	watch(v)
end
Map.DescendantAdded:Connect(watch)
RunService.RenderStepped:Connect(function()
	Cam = workspace.CurrentCamera or Cam
	if not CP.enabled then
		for _, gui in pairs(CP.guiCache) do
			if gui then
				gui.Enabled = false
			end
		end
		for _, hl in pairs(CP.highlightCache) do
			if hl then
				hl.Enabled = false
			end
		end
		return
	end
	local bestGui = nil
	local bestScore = math.huge
	for part, gui in pairs(CP.guiCache) do
		if gui and gui.Parent and part and part.Parent then
			local dist3d = (Cam.CFrame.Position - part.Position).Magnitude
			if dist3d <= CP.maxDist then
				local pos, onScreen = Cam:WorldToViewportPoint(part.Position)
				if onScreen then
					local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
					local dist2d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
					local score = dist2d + dist3d * 0.35
					if score < bestScore then
						bestScore = score
						bestGui = gui
					end
				end
			end
		end
	end
	for _, gui in pairs(CP.guiCache) do
		if gui then
			gui.Enabled = (gui == bestGui)
		end
	end
	for _, hl in pairs(CP.highlightCache) do
		if hl then
			hl.Enabled = true
		end
	end
end)
BetaTab:CreateToggle({
	Name = "Chest Preview",
	CurrentValue = false,
	Flag = "ChestPreview",
	Callback = function(val)
		CP.enabled = val
		if val then
			refreshAll()
		else
			for part in pairs(CP.guiCache) do
				removeGui(part)
			end
			for _, hl in pairs(CP.highlightCache) do
				if hl then
					hl:Destroy()
				end
			end
			table.clear(CP.highlightCache)
		end
	end,
})
local function addHitbox(v)
	if not CP.canLoot then return end
	if not v:IsA("BasePart") then return end
	if v.Name ~= "Hitbox" then return end
	local hrp = getRoot()
	if not hrp then return end
	if (v.Position - hrp.Position).Magnitude <= CP.lootDist then
		CP.trackedHitboxes[v] = true
	end
	v.AncestryChanged:Connect(function(_, p)
		if not p then
			CP.trackedHitboxes[v] = nil
		end
	end)
end
local function startDrop()
	if CP.dropConn then return end
	for _, v in ipairs(Drops:GetDescendants()) do
		addHitbox(v)
	end
	CP.dropConn = Drops.DescendantAdded:Connect(addHitbox)
	CP.moveLoop = RunService.Heartbeat:Connect(function()
		if not CP.canLoot then return end
		local hrp = getRoot()
		if not hrp then return end
		for v in pairs(CP.trackedHitboxes) do
			if not v or not v.Parent then
				CP.trackedHitboxes[v] = nil
			else
				v.CFrame = hrp.CFrame
			end
		end
	end)
end
local function stopDrop()
	if CP.dropConn then
		CP.dropConn:Disconnect()
		CP.dropConn = nil
	end
	if CP.moveLoop then
		CP.moveLoop:Disconnect()
		CP.moveLoop = nil
	end
	table.clear(CP.trackedHitboxes)
end
local function SetLoot(v)
	CP.canLoot = v
	if v then
		startDrop()
	else
		stopDrop()
	end
end
BetaTab:CreateToggle({
	Name = "Can Loot",
	CurrentValue = false,
	Flag = "CanLoot",
	Callback = function(val)
		SetLoot(val)
	end,
})
BetaTab:CreateInput({
	Name = "Chest Distance",
	CurrentValue = "140",
	PlaceholderText = "Distance",
	RemoveTextAfterFocusLost = false,
	Flag = "",
	Callback = function(Text)
		local n = tonumber(Text)
		if n and n > 0 then
			CP.maxDist = n
		end
	end,
})
local lp = Players.LocalPlayer
local PG = lp:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")
local Place = RS.Systems.ActionsSystem.Network.Place
local BlockStateChanged = RS.Systems.BlocksSystem.BlockStateChanged
local running = false
local autoBridge = false
local showButton = true
local ghostBlock = false
Opt.bridgeLength = 6
Opt.bridgeDelay = 1/5
Opt.dupeBursts = 16
local invConn, slotConn
local btn
local function getSlot()
	local c = lp.Character
	return c and c:GetAttribute("ReplicatedHotbarSlot")
end
local function getQtyLabel(slot)
	local hb = PG:WaitForChild("MasterScreenGui"):WaitForChild("Hotbar")
	return hb:WaitForChild(tostring(slot)):WaitForChild("QtyLabel")
end
local function readInv()
	local raw = lp:GetAttribute("inventory")
	if not raw then return {} end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	return ok and data or {}
end
BetaTab:CreateSection("Inventory")
BetaTab:CreateButton({
	Name = "Dupe",
	Callback = function()
		local slot = getSlot()
		if not slot then return end
		local inv = readInv()
		local item = inv[tostring(slot)]
		if type(item) ~= "table" or not item.qty then return end
		local amount = tonumber(item.qty) or 0
		if amount <= 0 then return end
		
		local hasDesync = typeof(raknet) ~= "nil" and typeof(raknet.desync) == "function"
		if hasDesync then 
			raknet.desync(true) 
		end

		for i = 1, Opt.dupeBursts do
			task.spawn(function()
				pcall(function()
					DropRemote:InvokeServer({
						qty = amount,
						throwDirection = vector.create(0, 0, 0),
						slot = tostring(slot)
					})
				end)
			end)
		end
		
		if hasDesync then
			task.delay(0.1, function()
				raknet.desync(false)
			end)
		end
	end,
})

BetaTab:CreateButton({
	Name = "chest dupe",
	Callback = function()
		local s = getSlot()
		if not s then return end
		local invData = readInv()
		local itm = invData[tostring(s)]
		if not itm then return end
		
		local activeChest = workspace:FindFirstChild("ActiveChest") or workspace:FindFirstChild("StorageChest")
		if not activeChest then return end
		
		local netOk = typeof(raknet) ~= "nil" and typeof(raknet.desync) == "function"
		if netOk then raknet.desync(true) end
		
		for x = 1, 3 do
			task.spawn(function()
				pcall(function()
					ChestDepositRemote:FireServer(activeChest, {
						Slot = tostring(s),
						Item = itm.Name or "Unknown",
						Count = itm.qty or 1
					})
					DropRemote:InvokeServer({
						qty = itm.qty or 1,
						throwDirection = vector.create(0,0,0),
						slot = tostring(s)
					})
				end)
			end)
		end
		
		if netOk then
			task.delay(0.15, function()
				raknet.desync(false)
			end)
		end
	end,
})

local function updateQty()
	local slot = getSlot()
	if not slot then return end
	local item = readInv()[tostring(slot)]
	local qty = (type(item) == "table" and item.qty) or 0
	local label = getQtyLabel(slot)
	if label then
		label.Text = tostring(qty)
	end
end
local function startInv()
	if invConn then invConn:Disconnect() end
	if slotConn then slotConn:Disconnect() end
	invConn = lp:GetAttributeChangedSignal("inventory"):Connect(updateQty)
	slotConn = lp:GetAttributeChangedSignal("ReplicatedHotbarSlot"):Connect(updateQty)
	updateQty()
end
local function stopInv()
	if invConn then
		invConn:Disconnect()
		invConn = nil
	end
	if slotConn then
		slotConn:Disconnect()
		slotConn = nil
	end
end
local function loop()
	while running do
		task.wait(Opt.bridgeDelay)
		local c = lp.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end
		local origin = Vector3.new(
			math.floor(hrp.Position.X / 4 + 0.5) * 4,
			math.floor(hrp.Position.Y / 4 + 0.5) * 4,
			math.floor(hrp.Position.Z / 4 + 0.5) * 4
		)
		local look = hrp.CFrame.LookVector
		local dir = math.abs(look.X) > math.abs(look.Z)
			and Vector3.new(math.sign(look.X), 0, 0)
			or Vector3.new(0, 0, math.sign(look.Z))
		local slot = getSlot()
		if not slot then continue end
		local state = c:GetAttribute("EquippedItemId") .. ";;[]"
		for i = 0, Opt.bridgeLength do
			local pos = origin + dir * (4 * i)
			task.spawn(function()
				local chunk = _G.getChunk(pos)
				local block = _G.getBlock(pos)
				if not chunk or not block then
					return
				end
				local id = block.Id
				if id > 0 then
					id -= 2
				end
				if ghostBlock and support.getconnections then
					for _, v in pairs(getconnections(BlockStateChanged.OnClientEvent)) do
						pcall(function()
							v.Function(
								chunk.Chunk,
								tostring(chunk.Id),
								tostring(id),
								state,
								{}
							)
						end)
					end
				else
					Place:InvokeServer(
						chunk.Chunk,
						chunk.Id,
						tostring(id),
						slot,
						{
							newState = state,
							half = "bottom",
							face = "floor",
							axis = "y",
							rotation = 6,
							normalId = Enum.NormalId.Top
						}
					)
				end
			end)
		end
	end
end
if support.getconnections then
BetaTab:CreateToggle({
	Name = "Ghost Block Mode",
	CurrentValue = false,
	Flag = "",
	Callback = function(v)
		ghostBlock = v
	end,
})
end
BetaTab:CreateToggle({
	Name = "Auto Bridge",
	CurrentValue = false,
	Flag = "",
	Callback = function(v)
		autoBridge = v
		running = v
		if v then
			task.spawn(loop)
			startInv()
		else
			stopInv()
		end
	end,
})
BetaTab:CreateToggle({
	Name = "Show Bridge Button",
	CurrentValue = false,
	Flag = "",
	Callback = function(v)
		showButton = v
		if btn then
			btn.Visible = v
		end
		if not v then
			stopInv()
		elseif running or autoBridge then
			startInv()
		end
	end,
})
local gui = Instance.new("ScreenGui")
gui.Name = "HoldUI"
gui.ResetOnSpawn = false
gui.Parent = PG
btn = Instance.new("ImageButton")
btn.Size = UDim2.new(0, 140, 0, 140)
btn.Position = UDim2.new(1, -190, 0.5, -30)
btn.Image = "rbxassetid://112807146868348"
btn.ImageTransparency = 0.2
btn.BackgroundTransparency = 1
btn.Visible = false
btn.Parent = gui
btn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		running = true
		startInv()
		task.spawn(loop)
	end
end)
btn.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		if not autoBridge then
			running = false
			stopInv()
		end
	end
end)
task.spawn(function()
while task.wait(0.1) do
if btn.GuiState == Enum.GuiState.Press then
updateQty()
end
end
end)
BetaOptions:CreateSection("Chest Preview")
BetaOptions:CreateInput({
    Name = "Chest Distance",
    CurrentValue = tostring(CP.maxDist),
    PlaceholderText = "Distance",
    Flag = "ChestDistanceOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then CP.maxDist = n end
    end
})
BetaOptions:CreateInput({
    Name = "Chest GUI Height",
    CurrentValue = tostring(CP.guiOffset),
    PlaceholderText = "Offset",
    Flag = "ChestOffsetOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n then CP.guiOffset = n end
    end
})
BetaOptions:CreateInput({
    Name = "Loot Hitbox Distance",
    CurrentValue = tostring(CP.lootDist),
    PlaceholderText = "Distance",
    Flag = "LootDistanceOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then CP.lootDist = n end
    end
})
BetaOptions:CreateInput({
    Name = "Bridge Length",
    CurrentValue = tostring(Opt.bridgeLength),
    PlaceholderText = "Blocks",
    Flag = "BridgeLengthOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 then Opt.bridgeLength = math.floor(n) end
    end
})
BetaOptions:CreateInput({
    Name = "Bridge Delay",
    CurrentValue = tostring(Opt.bridgeDelay),
    PlaceholderText = "Seconds",
    Flag = "BridgeDelayOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.bridgeDelay = n end
    end
})
BetaOptions:CreateInput({
    Name = "Dupe Burst Count",
    CurrentValue = tostring(Opt.dupeBursts),
    PlaceholderText = "Count",
    Flag = "DupeBurstsOptions",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then Opt.dupeBursts = math.floor(n) end
    end
})
BetaOptions:CreateToggle({
    Name = "Ghost Block Mode",
    CurrentValue = ghostBlock,
    Flag = "GhostBlockOptions",
    Callback = function(v) ghostBlock = v end
})
BetaOptions:CreateToggle({
    Name = "Show Bridge Button",
    CurrentValue = showButton,
    Flag = "BridgeButtonOptions",
    Callback = function(v)
        showButton = v
        if btn then btn.Visible = v end
        if not v then stopInv() elseif running or autoBridge then startInv() end
    end
})

local UIS = game:GetService("UserInputService")
local setting = RS.Client.States.SettingsOpened
local lastState
task.spawn(function()
	while task.wait(0.1) do
		if UIS.MouseEnabled then
			local visible = Rayfield:IsVisible()
			if visible ~= lastState then
				setting.Value = visible
				lastState = visible
			end
		end
	end
end)
else

end
