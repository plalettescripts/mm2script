-- Plalette MM2 - Working Base + Fixes
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Settings = {}
local Connections = {}
local ESPCache = {}

local function ClearESP()
    for _, d in pairs(ESPCache) do pcall(function() d:Remove() end) end
    ESPCache = {}
end

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if (p.Backpack and p.Backpack:FindFirstChild("Knife")) or (p.Character and p.Character:FindFirstChild("Knife")) then
                return p
            end
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if (p.Backpack and p.Backpack:FindFirstChild("Gun")) or (p.Character and p.Character:FindFirstChild("Gun")) then
                return p
            end
        end
    end
    return nil
end

local function FlingPlayer(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(math.random(-3000, 3000), 5000, math.random(-3000, 3000))
        bv.Parent = hrp
        game:GetService("Debris"):AddItem(bv, 0.5)
    end
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlaletteMM2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 4, 1, 4)
Border.Position = UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
Border.BorderSizePixel = 0
Border.Parent = MainFrame
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 13)

local MiniFrame = Instance.new("Frame")
MiniFrame.Size = UDim2.new(0, 200, 0, 35)
MiniFrame.Position = UDim2.new(0.5, -100, 0.02, 0)
MiniFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MiniFrame.BorderSizePixel = 0
MiniFrame.Visible = false
MiniFrame.Active = true
MiniFrame.Draggable = true
MiniFrame.Parent = ScreenGui
Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(0, 6)

local MiniLabel = Instance.new("TextLabel")
MiniLabel.Size = UDim2.new(1, 0, 1, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
MiniLabel.Text = "plalettescripts - Press CTRL"
MiniLabel.Font = Enum.Font.SourceSansBold
MiniLabel.TextSize = 13
MiniLabel.Parent = MiniFrame

task.spawn(function()
    local hue = 0
    while ScreenGui.Parent do
        hue = (hue + 0.005) % 1
        pcall(function() Border.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 1) end)
        task.wait(0.03)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        MiniFrame.Visible = not MiniFrame.Visible
    end
end)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.Position = UDim2.new(0.02, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(180, 130, 255)
TitleText.Text = "✦ Plalette MM2 ✦"
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 20
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 28)
CloseBtn.Position = UDim2.new(1, -42, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ClearESP()
    for _, c in pairs(Connections) do pcall(function() c:Disconnect() end) end
    ScreenGui:Destroy()
end)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 130, 1, -45)
TabContainer.Position = UDim2.new(0, 5, 0, 43)
TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 3)
TabList.FillDirection = Enum.FillDirection.Vertical
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabContainer

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -145, 1, -50)
ContentFrame.Position = UDim2.new(0, 138, 0, 43)
ContentFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 8)

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -8, 0, 32)
    TabBtn.Position = UDim2.new(0, 4, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabBtn.Text = icon .. " " .. name
    TabBtn.Font = Enum.Font.SourceSansSemibold
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabContainer
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -10, 1, -10)
    Content.Position = UDim2.new(0, 5, 0, 5)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 200)
    Content.CanvasSize = UDim2.new(0, 0, 0, 800)
    Content.Visible = false
    Content.Parent = ContentFrame

    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 4)
    ContentList.FillDirection = Enum.FillDirection.Vertical
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = Content

    TabBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
        for _, child in ipairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                child.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
        end
        Content.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    -- Auto-select first tab
    local existingTabs = {}
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("ScrollingFrame") then table.insert(existingTabs, child) end
    end
    if #existingTabs == 0 then
        Content.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    local function CreateToggle(name, settingKey)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -5, 0, 36)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Frame.Parent = Content
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.Position = UDim2.new(0.03, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(220, 220, 240)
        Label.Text = name .. " : OFF"
        Label.Font = Enum.Font.SourceSansSemibold
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 48, 0, 24)
        Switch.Position = UDim2.new(0.92, -48, 0, 6)
        Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        Switch.Text = ""
        Switch.Parent = Frame
        Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 12)

        local enabled = false
        Switch.MouseButton1Click:Connect(function()
            enabled = not enabled
            Settings[settingKey] = enabled
            Label.Text = name .. " : " .. (enabled and "ON" or "OFF")
            Switch.BackgroundColor3 = enabled and Color3.fromRGB(100, 50, 220) or Color3.fromRGB(60, 60, 75)
            Label.TextColor3 = enabled and Color3.fromRGB(180, 140, 255) or Color3.fromRGB(220, 220, 240)
        end)
    end

    local function CreateSlider(name, settingKey, min, max, default)
        Settings[settingKey] = default
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -5, 0, 50)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Frame.Parent = Content
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Position = UDim2.new(0.03, 0, 0, 3)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(220, 220, 240)
        Label.Text = name .. " : " .. tostring(default)
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame

        local Input = Instance.new("TextBox")
        Input.Size = UDim2.new(0.35, 0, 0, 22)
        Input.Position = UDim2.new(0.32, 0, 0, 24)
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

    local function CreateDropdown(name, options, settingKey, default)
        Settings[settingKey] = default or options[1]
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -5, 0, 34)
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Frame.Parent = Content
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

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
        DropBtn.Size = UDim2.new(0.5, 0, 0, 24)
        DropBtn.Position = UDim2.new(0.47, 0, 0, 5)
        DropBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropBtn.Text = Settings[settingKey]
        DropBtn.Font = Enum.Font.SourceSans
        DropBtn.TextSize = 12
        DropBtn.Parent = Frame
        Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)

        local DropList = Instance.new("Frame")
        DropList.Size = UDim2.new(0.5, 0, 0, #options * 26)
        DropList.Position = UDim2.new(0.47, 0, 0, 30)
        DropList.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        DropList.BorderSizePixel = 0
        DropList.Visible = false
        DropList.Parent = Frame
        Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 4)

        local DropLayout = Instance.new("UIListLayout", DropList)
        DropLayout.FillDirection = Enum.FillDirection.Vertical
        DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 26)
            OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptBtn.Text = opt
            OptBtn.Font = Enum.Font.SourceSans
            OptBtn.TextSize = 12
            OptBtn.Parent = DropList
            OptBtn.MouseButton1Click:Connect(function()
                Settings[settingKey] = opt
                DropBtn.Text = opt
                DropList.Visible = false
            end)
        end

        DropBtn.MouseButton1Click:Connect(function()
            DropList.Visible = not DropList.Visible
        end)
    end

    return {
        CreateToggle = CreateToggle,
        CreateSlider = CreateSlider,
        CreateDropdown = CreateDropdown
    }
end

-- Create Tabs
local CombatTab = CreateTab("Combat", "⚔")
local ESPTab = CreateTab("ESP", "👁")
local MoveTab = CreateTab("Move", "🏃")
local FarmTab = CreateTab("Farm", "💰")
local FlingTab = CreateTab("Fling", "💨")
local WorldTab = CreateTab("World", "🌍")

-- Combat
CombatTab.CreateToggle("Right-Click Aimbot", "Aimbot")
CombatTab.CreateSlider("Hitbox Size", "HitboxSize", 1, 8, 3)
CombatTab.CreateToggle("Hitbox Expander", "HitboxExpander")
CombatTab.CreateToggle("Instant Reload", "InstantReload")
CombatTab.CreateToggle("Triggerbot", "Triggerbot")
CombatTab.CreateToggle("God Mode", "GodMode")

-- ESP
ESPTab.CreateToggle("Player Outlines", "PlayerESP")
ESPTab.CreateToggle("Coin ESP", "CoinESP")
ESPTab.CreateToggle("Gun ESP", "GunESP")
ESPTab.CreateToggle("Tracers", "Tracers")
ESPTab.CreateToggle("Role Reveal", "RoleReveal")

-- Movement
MoveTab.CreateSlider("Speed", "SpeedValue", 16, 100, 32)
MoveTab.CreateToggle("Speed Hack", "SpeedHack")
MoveTab.CreateToggle("NoClip", "NoClip")
MoveTab.CreateToggle("Infinite Jump", "InfiniteJump")
MoveTab.CreateToggle("Anti-AFK", "AntiAFK")
MoveTab.CreateToggle("Teleport to Killer", "TeleportKiller")

-- Farm
FarmTab.CreateToggle("Auto-Farm Coins", "AutoFarm")
FarmTab.CreateToggle("Auto-Pickup Guns", "AutoPickup")

-- Fling
FlingTab.CreateToggle("Fling Murderer", "FlingMurderer")
FlingTab.CreateToggle("Fling Sheriff", "FlingSheriff")
FlingTab.CreateToggle("Anti-Grab", "AntiGrab")

-- World
WorldTab.CreateToggle("Fullbright", "Fullbright")
WorldTab.CreateToggle("Fog Remover", "FogRemover")

-- ==================== FEATURES ====================

-- Aimbot
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.Aimbot then
        Connections.Aimbot = RunService.RenderStepped:Connect(function()
            local murd = GetMurderer()
            if murd and murd.Character and murd.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, murd.Character.Head.Position)
            end
        end)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Connections.Aimbot then Connections.Aimbot:Disconnect() Connections.Aimbot = nil end
    end
end)

-- Hitbox Expander
task.spawn(function()
    while task.wait(0.3) do
        if Settings.HitboxExpander then
            local s = Settings.HitboxSize or 3
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(s, s, s)
                    p.Character.HumanoidRootPart.Transparency = 0.5
                end
            end
        end
    end
end)

-- Instant Reload
task.spawn(function()
    while task.wait(0.12) do
        if Settings.InstantReload then
            pcall(function()
                for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("Ammo") then t.Ammo.Value = 99 end
                end
                local ct = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if ct and ct:FindFirstChild("Ammo") then ct.Ammo.Value = 99 end
            end)
        end
    end
end)

-- Triggerbot
task.spawn(function()
    while task.wait(0.06) do
        if Settings.Triggerbot and LocalPlayer.Character then
            pcall(function()
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Shoot") then
                    local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 300)
                    local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                    if hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent ~= LocalPlayer.Character then
                        tool.Shoot:FireServer(pos)
                    end
                end
            end)
        end
    end
end)

-- God Mode
task.spawn(function()
    while task.wait(0.2) do
        if Settings.GodMode and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
    end
end)

-- Player ESP
task.spawn(function()
    while task.wait(0.5) do
        if Settings.PlayerESP then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("PlaletteESP")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "PlaletteESP"
                        hl.FillTransparency = 1
                        hl.OutlineTransparency = 0
                        hl.Parent = p.Character
                    end
                    local isMurderer = (p.Backpack and p.Backpack:FindFirstChild("Knife")) or (p.Character and p.Character:FindFirstChild("Knife"))
                    local isSheriff = (p.Backpack and p.Backpack:FindFirstChild("Gun")) or (p.Character and p.Character:FindFirstChild("Gun"))
                    if isMurderer then hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                    elseif isSheriff then hl.OutlineColor = Color3.fromRGB(0, 100, 255)
                    else hl.OutlineColor = Color3.fromRGB(0, 255, 0) end
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("PlaletteESP") then
                    p.Character.PlaletteESP:Destroy()
                end
            end
        end
    end
end)

-- Coin ESP
task.spawn(function()
    while task.wait(0.08) do
        if Settings.CoinESP then
            ClearESP()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "Coin" and obj:IsA("BasePart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
                    if onScreen then
                        local d = Drawing.new("Text")
                        d.Text = "💰"
                        d.Color = Color3.fromRGB(255, 215, 0)
                        d.Size = 17
                        d.Position = Vector2.new(pos.X, pos.Y)
                        d.Center = true
                        d.Visible = true
                        table.insert(ESPCache, d)
                    end
                end
            end
        end
    end
end)

-- Gun ESP
task.spawn(function()
    while task.wait(0.08) do
        if Settings.GunESP then
            ClearESP()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
                    if onScreen then
                        local d = Drawing.new("Text")
                        d.Text = "🔫"
                        d.Color = Color3.fromRGB(100, 200, 255)
                        d.Size = 16
                        d.Position = Vector2.new(pos.X, pos.Y)
                        d.Center = true
                        d.Visible = true
                        table.insert(ESPCache, d)
                    end
                end
            end
        end
    end
end)

-- Tracers
task.spawn(function()
    while task.wait(0.02) do
        if Settings.Tracers then
            ClearESP()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local l = Drawing.new("Line")
                        l.Color = Color3.fromRGB(255, 255, 255)
                        l.Thickness = 0.8
                        l.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        l.To = Vector2.new(pos.X, pos.Y)
                        l.Visible = true
                        table.insert(ESPCache, l)
                    end
                end
            end
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
                    if (p.Backpack and p.Backpack:FindFirstChild("Knife")) or (p.Character and p.Character:FindFirstChild("Knife")) then
                        role, color = "Murderer", Color3.fromRGB(255, 0, 0)
                    elseif (p.Backpack and p.Backpack:FindFirstChild("Gun")) or (p.Character and p.Character:FindFirstChild("Gun")) then
                        role, color = "Sheriff", Color3.fromRGB(0, 150, 255)
                    end
                    local bb = p.Character.Head:FindFirstChild("RoleTag")
                    if not bb then
                        bb = Instance.new("BillboardGui")
                        bb.Name = "RoleTag"
                        bb.Size = UDim2.new(0, 100, 0, 30)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = p.Character.Head
                    end
                    local tl = bb:FindFirstChild("Text")
                    if not tl then
                        tl = Instance.new("TextLabel")
                        tl.Name = "Text"
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.BackgroundTransparency = 1
                        tl.Font = Enum.Font.SourceSansBold
                        tl.TextSize = 14
                        tl.TextStrokeTransparency = 0.5
                        tl.Parent = bb
                    end
                    tl.Text = role
                    tl.TextColor3 = color
                end
            end
        end
    end
end)

-- Speed Hack
RunService.Stepped:Connect(function()
    if Settings.SpeedHack and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Settings.SpeedValue or 32 end
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
    if Settings.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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
            local m = GetMurderer()
            if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = m.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0) end
            end
        end
    end
end)

-- Auto-Farm Coins
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoFarm and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "Coin" and obj:IsA("BasePart") then
                        if (obj.Position - hrp.Position).Magnitude < 200 then
                            firetouchinterest(hrp, obj, 0)
                            firetouchinterest(hrp, obj, 1)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto-Pickup Guns
task.spawn(function()
    while task.wait(0.5) do
        if Settings.AutoPickup and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                        if (obj.Position - hrp.Position).Magnitude < 80 then
                            firetouchinterest(hrp, obj, 0)
                            firetouchinterest(hrp, obj, 1)
                        end
                    end
                end
            end
        end
    end
end)

-- Fling Murderer
task.spawn(function()
    while task.wait(0.25) do
        if Settings.FlingMurderer then
            local m = GetMurderer()
            if m then FlingPlayer(m) end
        end
    end
end)

-- Fling Sheriff
task.spawn(function()
    while task.wait(0.25) do
        if Settings.FlingSheriff then
            local s = GetSheriff()
            if s then FlingPlayer(s) end
        end
    end
end)

-- Anti-Grab
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AntiGrab and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude < 5 then
                            FlingPlayer(p)
                        end
                    end
                end
            end
        end
    end
end)

-- Fullbright & Fog
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

print("✅ Plalette MM2 Loaded!")
