--[[
    Plalette MM2 Ultimate Script
    Credits: Plalette
    Final Version - All Features Optimized
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    RightClickAimbot = false,
    HitboxExpander = false,
    HitboxSize = 3,
    InstantReload = false,
    Triggerbot = false,
    PlayerESP = false,
    CoinESP = false,
    GunESP = false,
    Tracers = false,
    RoleReveal = false,
    SpeedHack = false,
    SpeedValue = 32,
    NoClip = false,
    InfiniteJump = false,
    AntiAFK = false,
    TeleportKiller = false,
    AutoFarm = false,
    AutoPickup = false,
    Fullbright = false,
    FogRemover = false,
    GodMode = false,
    KillAll = false,
    AntiGrab = false,
    FlingPlayer = false,
    FlingTarget = nil,
    FlingSheriff = false,
    FlingMurderer = false,
    FlingPower = 1000
}

local Connections = {}
local ESPDrawings = {}

local function ClearDrawings()
    for _, d in pairs(ESPDrawings) do
        pcall(function() d:Remove() end)
    end
    ESPDrawings = {}
end

local function DisconnectAll()
    for _, c in pairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    Connections = {}
end

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Backpack and p.Backpack:FindFirstChild("Knife") then return p end
            if p.Character and p.Character:FindFirstChild("Knife") then return p end
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Backpack and p.Backpack:FindFirstChild("Gun") then return p end
            if p.Character and p.Character:FindFirstChild("Gun") then return p end
        end
    end
    return nil
end

local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local function FlingPlayer(target, power)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(math.random(-power, power), power, math.random(-power, power))
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = hrp
        game:GetService("Debris"):AddItem(bv, 0.5)
    end
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlaletteMM2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 430)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Border
local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 4, 1, 4)
Border.Position = UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
Border.BorderSizePixel = 0
Border.Parent = MainFrame
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 11)

-- Minimized Square
local MiniFrame = Instance.new("Frame")
MiniFrame.Size = UDim2.new(0, 200, 0, 40)
MiniFrame.Position = UDim2.new(0.5, -100, 0.02, 0)
MiniFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MiniFrame.BorderSizePixel = 0
MiniFrame.Visible = false
MiniFrame.Active = true
MiniFrame.Draggable = true
MiniFrame.Parent = ScreenGui
Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(0, 8)

local MiniLabel = Instance.new("TextLabel")
MiniLabel.Size = UDim2.new(1, 0, 1, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
MiniLabel.Text = "plalettescripts - Press CTRL"
MiniLabel.Font = Enum.Font.SourceSansBold
MiniLabel.TextSize = 13
MiniLabel.Parent = MiniFrame

-- Color animation for main frame border only
task.spawn(function()
    local hue = 0
    while ScreenGui.Parent do
        hue = (hue + 0.004) % 1
        Border.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 1)
        task.wait(0.03)
    end
end)

-- Ctrl Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        MiniFrame.Visible = not MiniFrame.Visible
    end
end)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.02, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
TitleLabel.Text = "✦ Plalette MM2 Ultimate ✦"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 26)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ClearDrawings()
    DisconnectAll()
    ScreenGui:Destroy()
end)

-- Tab System
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 135, 1, -45)
TabContainer.Position = UDim2.new(0, 5, 0, 43)
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 3)
TabList.FillDirection = Enum.FillDirection.Vertical
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabContainer

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -147, 1, -48)
ContentFrame.Position = UDim2.new(0, 143, 0, 43)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 8)

local function CreateTab(name, icon)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 30)
    Btn.Position = UDim2.new(0, 3, 0, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Btn.Text = icon .. " " .. name
    Btn.Font = Enum.Font.SourceSansSemibold
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = TabContainer
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)

    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -8, 1, -8)
    Content.Position = UDim2.new(0, 4, 0, 4)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(130, 80, 255)
    Content.CanvasSize = UDim2.new(0, 0, 0, 900)
    Content.Visible = false
    Content.Parent = ContentFrame

    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 4)
    ContentList.FillDirection = Enum.FillDirection.Vertical
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = Content

    Btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
        for _, child in ipairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                child.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
        end
        Content.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    local children = ContentFrame:GetChildren()
    local hasVisible = false
    for _, c in ipairs(children) do
        if c:IsA("ScrollingFrame") and c.Visible then hasVisible = true end
    end
    if not hasVisible and #children <= 1 then
        Content.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    local tab = {}
    function tab:CreateToggle(name, settingKey)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -2, 0, 34)
        Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        Frame.Parent = Content
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Position = UDim2.new(0.03, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(220, 220, 240)
        Label.Text = name .. " : OFF"
        Label.Font = Enum.Font.SourceSansSemibold
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 44, 0, 22)
        Switch.Position = UDim2.new(0.92, -44, 0, 6)
        Switch.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        Switch.Text = ""
        Switch.Parent = Frame
        Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 11)

        Switch.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            local on = Settings[settingKey]
            Label.Text = name .. " : " .. (on and "ON" or "OFF")
            Switch.BackgroundColor3 = on and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(55, 55, 70)
            Label.TextColor3 = on and Color3.fromRGB(180, 150, 255) or Color3.fromRGB(220, 220, 240)
        end)
    end

    function tab:CreateSlider(name, settingKey, min, max, default)
        Settings[settingKey] = default
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -2, 0, 50)
        Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        Frame.Parent = Content
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 18)
        Label.Position = UDim2.new(0.03, 0, 0, 3)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(220, 220, 240)
        Label.Text = name .. " : " .. tostring(default)
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local Input = Instance.new("TextBox")
        Input.Size = UDim2.new(0.3, 0, 0, 22)
        Input.Position = UDim2.new(0.35, 0, 0, 24)
        Input.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        Input.TextColor3 = Color3.fromRGB(255, 255, 255)
        Input.Text = tostring(default)
        Input.Font = Enum.Font.SourceSans
        Input.TextSize = 12
        Input.Parent = Frame
        Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)

        Input.FocusLost:Connect(function()
            local val = tonumber(Input.Text)
            if val and val >= min and val <= max then
                Settings[settingKey] = val
                Label.Text = name .. " : " .. tostring(val)
            else
                Input.Text = tostring(Settings[settingKey])
            end
        end)
    end

    function tab:CreateDropdown(name, options, settingKey, default)
        Settings[settingKey] = default
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -2, 0, 34)
        Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        Frame.Parent = Content
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.35, 0, 1, 0)
        Label.Position = UDim2.new(0.03, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(220, 220, 240)
        Label.Text = name .. ":"
        Label.Font = Enum.Font.SourceSansSemibold
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local DropBtn = Instance.new("TextButton")
        DropBtn.Size = UDim2.new(0.45, 0, 0, 24)
        DropBtn.Position = UDim2.new(0.5, 0, 0, 5)
        DropBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropBtn.Text = tostring(default)
        DropBtn.Font = Enum.Font.SourceSans
        DropBtn.TextSize = 12
        DropBtn.Parent = Frame
        Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)

        local DropList = Instance.new("Frame")
        DropList.Size = UDim2.new(0.45, 0, 0, #options * 24)
        DropList.Position = UDim2.new(0.5, 0, 0, 30)
        DropList.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        DropList.BorderSizePixel = 0
        DropList.Visible = false
        DropList.Parent = Frame
        Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 4)

        local Layout = Instance.new("UIListLayout", DropList)
        Layout.FillDirection = Enum.FillDirection.Vertical
        Layout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, option in ipairs(options) do
            local Opt = Instance.new("TextButton")
            Opt.Size = UDim2.new(1, 0, 0, 24)
            Opt.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            Opt.TextColor3 = Color3.fromRGB(255, 255, 255)
            Opt.Text = option
            Opt.Font = Enum.Font.SourceSans
            Opt.TextSize = 12
            Opt.Parent = DropList
            Opt.MouseButton1Click:Connect(function()
                Settings[settingKey] = option
                DropBtn.Text = option
                DropList.Visible = false
            end)
        end

        DropBtn.MouseButton1Click:Connect(function()
            DropList.Visible = not DropList.Visible
        end)
    end

    function tab:CreateButton(name, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -2, 0, 30)
        Btn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Text = name
        Btn.Font = Enum.Font.SourceSansBold
        Btn.TextSize = 13
        Btn.Parent = Content
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
        Btn.MouseButton1Click:Connect(callback)
    end

    return tab
end

-- Create Tabs
local CombatTab = CreateTab("Combat", "⚔")
local ESPTab = CreateTab("Visuals", "👁")
local MoveTab = CreateTab("Movement", "🏃")
local FarmTab = CreateTab("Farming", "💰")
local FlingTab = CreateTab("Fling", "💨")
local WorldTab = CreateTab("World", "🌍")
local CreditsTab = CreateTab("Credits", "⭐")

-- Combat Tab
CombatTab:CreateToggle("Right-Click Aimbot (Murderer)", "RightClickAimbot")
CombatTab:CreateSlider("Hitbox Size", "HitboxSize", 1, 10, 3)
CombatTab:CreateToggle("Hitbox Expander", "HitboxExpander")
CombatTab:CreateToggle("Instant Reload", "InstantReload")
CombatTab:CreateToggle("Triggerbot", "Triggerbot")
CombatTab:CreateToggle("God Mode", "GodMode")
CombatTab:CreateButton("Kill All", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.Health = 0
        end
    end
end)

-- ESP Tab
ESPTab:CreateToggle("Player Outlines", "PlayerESP")
ESPTab:CreateToggle("Coin ESP", "CoinESP")
ESPTab:CreateToggle("Gun ESP", "GunESP")
ESPTab:CreateToggle("Tracers", "Tracers")
ESPTab:CreateToggle("Role Reveal", "RoleReveal")

-- Movement Tab
MoveTab:CreateSlider("Speed", "SpeedValue", 16, 150, 32)
MoveTab:CreateToggle("Speed Hack", "SpeedHack")
MoveTab:CreateToggle("NoClip", "NoClip")
MoveTab:CreateToggle("Infinite Jump", "InfiniteJump")
MoveTab:CreateToggle("Anti-AFK", "AntiAFK")
MoveTab:CreateToggle("Teleport to Killer", "TeleportKiller")

-- Farm Tab
FarmTab:CreateToggle("Auto-Farm Coins", "AutoFarm")
FarmTab:CreateToggle("Auto-Pickup Gun", "AutoPickup")

-- Fling Tab
FlingTab:CreateDropdown("Select Player", GetPlayerList(), "FlingTarget", nil)
FlingTab:CreateSlider("Fling Power", "FlingPower", 100, 10000, 1000)
FlingTab:CreateToggle("Fling Selected Player", "FlingPlayer")
FlingTab:CreateToggle("Fling Sheriff", "FlingSheriff")
FlingTab:CreateToggle("Fling Murderer", "FlingMurderer")
FlingTab:CreateToggle("Anti-Grab (Fling Attacker)", "AntiGrab")

-- World Tab
WorldTab:CreateToggle("Fullbright", "Fullbright")
WorldTab:CreateToggle("Fog Remover", "FogRemover")
WorldTab:CreateButton("Server Hop", function()
    local servers = {}
    pcall(function()
        local Http = game:GetService("HttpService")
        local req = request({Url = "https://games.roblox.com/v1/games/142823291/servers/Public?limit=100"})
        local data = Http:JSONDecode(req.Body)
        for _, v in ipairs(data.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(142823291, servers[math.random(1, #servers)], LocalPlayer)
        end
    end)
end)

-- Credits Tab
local CreditsFrame = CreditsTab.Content

local CreditInfo = Instance.new("TextLabel")
CreditInfo.Size = UDim2.new(1, -10, 0, 200)
CreditInfo.Position = UDim2.new(0, 5, 0, 10)
CreditInfo.BackgroundTransparency = 1
CreditInfo.TextColor3 = Color3.fromRGB(220, 220, 240)
CreditInfo.Text = [[
╔══════════════════════╗
     Plalette MM2 Ultimate
╚══════════════════════╝

👤 Created by: plalettescripts

📜 Special Thanks:
   • The MM2 Community
   • Script Testers
   • Everyone who supported

🔧 Features:
   • Right-Click Aimbot
   • Player Outlines (Color Coded)
   • Fling System
   • ESP & Visuals
   • Movement Hacks
   • Auto Farm
   • God Mode & More

💾 GitHub:
   plalettescripts/mm2script

⚠️ Use at your own risk
]]
CreditInfo.Font = Enum.Font.SourceSans
CreditInfo.TextSize = 12
CreditInfo.TextXAlignment = Enum.TextXAlignment.Left
CreditInfo.TextYAlignment = Enum.TextYAlignment.Top
CreditInfo.RichText = true
CreditInfo.Parent = CreditsFrame

-- ==================== FEATURES ====================

-- Right-Click Aimbot (Murderer only)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.RightClickAimbot then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local murderer = GetMurderer()
            if murderer and murderer.Character and murderer.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, murderer.Character.Head.Position)
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Connections.Aimbot then
            Connections.Aimbot:Disconnect()
            Connections.Aimbot = nil
        end
    end
end)

-- Hitbox Expander
task.spawn(function()
    while task.wait(0.2) do
        if Settings.HitboxExpander then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    p.Character.HumanoidRootPart.Transparency = 0.5
                end
            end
        end
    end
end)

-- Instant Reload
task.spawn(function()
    while task.wait(0.1) do
        if Settings.InstantReload then
            pcall(function()
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                        tool.Ammo.Value = 99
                    end
                end
                local ct = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if ct and ct:FindFirstChild("Ammo") then
                    ct.Ammo.Value = 99
                end
            end)
        end
    end
end)

-- Triggerbot
task.spawn(function()
    while task.wait(0.05) do
        if Settings.Triggerbot and LocalPlayer.Character then
            pcall(function()
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Shoot") then
                    local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 300)
                    local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                    if hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent ~= LocalPlayer.Character then
                        tool:FindFirstChild("Shoot"):FireServer(pos)
                    end
                end
            end)
        end
    end
end)

-- God Mode
task.spawn(function()
    while task.wait(0.3) do
        if Settings.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
        end
    end
end)

-- Player ESP (Color-coded outlines, not through walls)
task.spawn(function()
    while task.wait(0.5) do
        if Settings.PlayerESP then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local highlight = p.Character:FindFirstChild("PlaletteOutline")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "PlaletteOutline"
                        highlight.FillTransparency = 1
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                        highlight.Parent = p.Character
                    end
                    
                    local isMurderer = p.Backpack and p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    local isSheriff = p.Backpack and p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                    
                    if isMurderer then
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    elseif isSheriff then
                        highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
                    else
                        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    end
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("PlaletteOutline") then
                    p.Character.PlaletteOutline:Destroy()
                end
            end
        end
    end
end)

-- Coin ESP
task.spawn(function()
    while task.wait(0.08) do
        if Settings.CoinESP then
            local drawings = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Coin" and obj:IsA("BasePart") then
                    local pos, onScreen = Camera:WorldToScreenPoint(obj.Position)
                    if onScreen then
                        local txt = Drawing.new("Text")
                        txt.Text = "💰"
                        txt.Color = Color3.fromRGB(255, 215, 0)
                        txt.Size = 17
                        txt.Position = Vector2.new(pos.X, pos.Y)
                        txt.Center = true
                        txt.Visible = true
                        table.insert(drawings, txt)
                    end
                end
            end
            task.wait(0.07)
            for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
        end
    end
end)

-- Gun ESP
task.spawn(function()
    while task.wait(0.08) do
        if Settings.GunESP then
            local drawings = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    local pos, onScreen = Camera:WorldToScreenPoint(obj.Position)
                    if onScreen then
                        local txt = Drawing.new("Text")
                        txt.Text = "🔫"
                        txt.Color = Color3.fromRGB(100, 200, 255)
                        txt.Size = 16
                        txt.Position = Vector2.new(pos.X, pos.Y)
                        txt.Center = true
                        txt.Visible = true
                        table.insert(drawings, txt)
                    end
                end
            end
            task.wait(0.07)
            for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
        end
    end
end)

-- Tracers
task.spawn(function()
    while task.wait(0.02) do
        if Settings.Tracers then
            local drawings = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onScreen = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local line = Drawing.new("Line")
                        line.Color = Color3.fromRGB(255, 255, 255)
                        line.Thickness = 0.8
                        line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        line.To = Vector2.new(pos.X, pos.Y)
                        line.Visible = true
                        table.insert(drawings, line)
                    end
                end
            end
            task.wait(0.02)
            for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
        end
    end
end)

-- Role Reveal
task.spawn(function()
    while task.wait(0.8) do
        if Settings.RoleReveal then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local role, color = "Innocent", Color3.fromRGB(0, 255, 0)
                    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                        role, color = "🔪 Murderer", Color3.fromRGB(255, 0, 0)
                    elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                        role, color = "🔫 Sheriff", Color3.fromRGB(0, 150, 255)
                    end
                    local bb = p.Character.Head:FindFirstChild("RoleTag") or Instance.new("BillboardGui", p.Character.Head)
                    bb.Name = "RoleTag"
                    bb.Size = UDim2.new(0, 110, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 2.8, 0)
                    bb.AlwaysOnTop = true
                    local tl = bb:FindFirstChild("Label") or Instance.new("TextLabel", bb)
                    tl.Name = "Label"
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.TextColor3 = color
                    tl.Text = role
                    tl.Font = Enum.Font.SourceSansBold
                    tl.TextSize = 14
                    tl.TextStrokeTransparency = 0.5
                end
            end
        end
    end
end)

-- Speed Hack
RunService.Stepped:Connect(function()
    if Settings.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.SpeedValue
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if Settings.NoClip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-AFK
task.spawn(function()
    while task.wait(100) do
        if Settings.AntiAFK then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
            end)
        end
    end
end)

-- Teleport to Killer
task.spawn(function()
    while task.wait(2) do
        if Settings.TeleportKiller and LocalPlayer.Character then
            local murderer = GetMurderer()
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
end)

-- Auto-Farm
task.spawn(function()
    while task.wait(0.12) do
        if Settings.AutoFarm and LocalPlayer.Character then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Coin" and obj:IsA("BasePart") then
                    if (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 200 then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                    end
                end
            end
        end
    end
end)

-- Auto-Pickup
task.spawn(function()
    while task.wait(0.5) do
        if Settings.AutoPickup and LocalPlayer.Character then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    if (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 60 then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                    end
                end
            end
        end
    end
end)

-- Fling Selected Player
task.spawn(function()
    while task.wait(0.3) do
        if Settings.FlingPlayer and Settings.FlingTarget then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == Settings.FlingTarget then
                    FlingPlayer(p, Settings.FlingPower)
                end
            end
        end
    end
end)

-- Fling Sheriff
task.spawn(function()
    while task.wait(0.3) do
        if Settings.FlingSheriff then
            local sheriff = GetSheriff()
            if sheriff then FlingPlayer(sheriff, Settings.FlingPower) end
        end
    end
end)

-- Fling Murderer
task.spawn(function()
    while task.wait(0.3) do
        if Settings.FlingMurderer then
            local murderer = GetMurderer()
            if murderer then FlingPlayer(murderer, Settings.FlingPower) end
        end
    end
end)

-- Anti-Grab
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AntiGrab and LocalPlayer.Character then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 5 then
                        FlingPlayer(p, 5000)
                    end
                end
            end
        end
    end
end)

-- World
task.spawn(function()
    while task.wait(1) do
        if Settings.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        end
        if Settings.FogRemover then
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 0
        end
    end
end)

print("╔══════════════════════════════════╗")
print("║  Plalette MM2 Ultimate Loaded!  ║")
print("║  🔴 Murderer - Red Outline      ║")
print("║  🔵 Sheriff  - Blue Outline     ║")
print("║  🟢 Innocent - Green Outline    ║")
print("║  🎯 Right-Click Aimbot         ║")
print("║  💨 Fling System               ║")
print("║  ⌨️  CTRL to Minimize           ║")
print("║  ⭐ Credits Tab Added          ║")
print("╚══════════════════════════════════╝")
