--[[
    Plalette MM2 Ultimate - Clean & Optimized
    All features properly implemented
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    SilentAim = false,
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
    EmoteUnlocker = false,
    SelectedEmote = "Dab",
    AutoEmote = false,
    Fullbright = false,
    FogRemover = false
}

-- Connections & Drawings
local Connections = {}
local ESPDrawings = {}

-- Cleanup
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

-- Get Murderer
local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Backpack and p.Backpack:FindFirstChild("Knife") then return p end
            if p.Character and p.Character:FindFirstChild("Knife") then return p end
        end
    end
    return nil
end

-- Get Sheriff
local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if p.Backpack and p.Backpack:FindFirstChild("Gun") then return p end
            if p.Character and p.Character:FindFirstChild("Gun") then return p end
        end
    end
    return nil
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlaletteMM2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Border glow
local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 4, 1, 4)
Border.Position = UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
Border.BorderSizePixel = 0
Border.Parent = MainFrame
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 11)

-- Minimized square
local MiniFrame = Instance.new("Frame")
MiniFrame.Size = UDim2.new(0, 140, 0, 40)
MiniFrame.Position = UDim2.new(0.5, -70, 0.02, 0)
MiniFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MiniFrame.BorderSizePixel = 0
MiniFrame.Visible = false
MiniFrame.Active = true
MiniFrame.Draggable = true
MiniFrame.Parent = ScreenGui
Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(0, 8)

local MiniBorder = Instance.new("Frame")
MiniBorder.Size = UDim2.new(1, 4, 1, 4)
MiniBorder.Position = UDim2.new(0, -2, 0, -2)
MiniBorder.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
MiniBorder.BorderSizePixel = 0
MiniBorder.Parent = MiniFrame
Instance.new("UICorner", MiniBorder).CornerRadius = UDim.new(0, 9)

local MiniLabel = Instance.new("TextLabel")
MiniLabel.Size = UDim2.new(1, 0, 1, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
MiniLabel.Text = "plalettescripts"
MiniLabel.Font = Enum.Font.SourceSansBold
MiniLabel.TextSize = 16
MiniLabel.Parent = MiniFrame

-- Glow animation
task.spawn(function()
    local hue = 0
    while ScreenGui.Parent do
        hue = (hue + 0.004) % 1
        local c = Color3.fromHSV(hue, 0.8, 1)
        Border.BackgroundColor3 = c
        MiniBorder.BackgroundColor3 = c
        MiniLabel.TextColor3 = c
        task.wait(0.03)
    end
end)

-- Ctrl toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        MiniFrame.Visible = not MiniFrame.Visible
    end
end)

-- Title
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.02, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
TitleLabel.Text = "✦ Plalette MM2 ✦"
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

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 130, 1, -45)
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
ContentFrame.Size = UDim2.new(1, -142, 1, -48)
ContentFrame.Position = UDim2.new(0, 138, 0, 43)
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
    Content.CanvasSize = UDim2.new(0, 0, 0, 700)
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

    if #ContentFrame:GetChildren() == 0 then
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
        DropBtn.Text = default
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

    return tab
end

-- Create Tabs
local CombatTab = CreateTab("Combat", "⚔")
local ESPTab = CreateTab("ESP", "👁")
local MoveTab = CreateTab("Move", "🏃")
local FarmTab = CreateTab("Farm", "💰")
local EmoteTab = CreateTab("Emotes", "🎭")
local WorldTab = CreateTab("World", "🌍")

-- Combat
CombatTab:CreateToggle("Silent Aim", "SilentAim")
CombatTab:CreateToggle("Right-Click Aimbot", "RightClickAimbot")
CombatTab:CreateSlider("Hitbox Size", "HitboxSize", 1, 10, 3)
CombatTab:CreateToggle("Hitbox Expander", "HitboxExpander")
CombatTab:CreateToggle("Instant Reload", "InstantReload")
CombatTab:CreateToggle("Triggerbot", "Triggerbot")

-- ESP
ESPTab:CreateToggle("Player ESP (Red Outline)", "PlayerESP")
ESPTab:CreateToggle("Coin ESP", "CoinESP")
ESPTab:CreateToggle("Gun ESP", "GunESP")
ESPTab:CreateToggle("Tracers", "Tracers")
ESPTab:CreateToggle("Role Reveal", "RoleReveal")

-- Movement
MoveTab:CreateSlider("Speed", "SpeedValue", 16, 100, 32)
MoveTab:CreateToggle("Speed Hack", "SpeedHack")
MoveTab:CreateToggle("NoClip", "NoClip")
MoveTab:CreateToggle("Infinite Jump", "InfiniteJump")
MoveTab:CreateToggle("Anti-AFK", "AntiAFK")
MoveTab:CreateToggle("Teleport to Killer", "TeleportKiller")

-- Farm
FarmTab:CreateToggle("Auto-Farm Coins", "AutoFarm")
FarmTab:CreateToggle("Auto-Pickup Gun", "AutoPickup")

-- Emotes
EmoteTab:CreateDropdown("Emote", {"Dab", "Floss", "Laugh", "Wave", "Point", "Salute", "ThumbsUp", "Boo", "Cheers", "Dance1", "Dance2", "Shrug", "Stretch"}, "SelectedEmote", "Dab")
EmoteTab:CreateToggle("Emote Unlocker", "EmoteUnlocker")
EmoteTab:CreateToggle("Auto-Emote (When Idle)", "AutoEmote")

-- World
WorldTab:CreateToggle("Fullbright", "Fullbright")
WorldTab:CreateToggle("Fog Remover", "FogRemover")

-- ==================== FEATURES ====================

-- Silent Aim (fixed - doesn't block shooting)
task.spawn(function()
    local oldNamecall
    RunService.RenderStepped:Connect(function()
        if Settings.SilentAim then
            if not oldNamecall then
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    local args = {...}
                    if method == "FireServer" and (tostring(self) == "Shoot" or tostring(self) == "ShootGun") and LocalPlayer.Character then
                        local target, closest = nil, math.huge
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                                local pos, onScreen = Camera:WorldToScreenPoint(p.Character.Head.Position)
                                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                                if onScreen and dist < 300 and dist < closest then
                                    closest = dist
                                    target = p
                                end
                            end
                        end
                        if target then args[1] = target.Character.Head.Position end
                    end
                    return oldNamecall(self, unpack(args))
                end)
            end
        else
            if oldNamecall then
                hookmetamethod(game, "__namecall", oldNamecall)
                oldNamecall = nil
            end
        end
    end)
end)

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
                    p.Character.HumanoidRootPart.Transparency = 0.6
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
        if Settings.Triggerbot then
            pcall(function()
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
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

-- Player ESP (Red outline filled, visible through walls)
task.spawn(function()
    while task.wait(0.03) do
        ClearDrawings()
        if Settings.PlayerESP then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    -- Red highlight through walls
                    local highlight = p.Character:FindFirstChild("PlaletteESP")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "PlaletteESP"
                        highlight.FillColor = Color3.fromRGB(255, 30, 30)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = p.Character
                    end
                    -- Text above head
                    if p.Character:FindFirstChild("Head") then
                        local pos, onScreen = Camera:WorldToScreenPoint(p.Character.Head.Position + Vector3.new(0, 1.5, 0))
                        if onScreen then
                            local txt = Drawing.new("Text")
                            txt.Text = p.Name
                            txt.Color = Color3.fromRGB(255, 50, 50)
                            txt.Size = 14
                            txt.Position = Vector2.new(pos.X, pos.Y)
                            txt.Center = true
                            txt.Visible = true
                            table.insert(ESPDrawings, txt)

                            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude)
                            local dtxt = Drawing.new("Text")
                            dtxt.Text = dist .. "m"
                            dtxt.Color = Color3.fromRGB(255, 180, 180)
                            dtxt.Size = 11
                            dtxt.Position = Vector2.new(pos.X, pos.Y + 15)
                            dtxt.Center = true
                            dtxt.Visible = true
                            table.insert(ESPDrawings, dtxt)
                        end
                    end
                end
            end
        else
            -- Remove highlights when ESP off
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

-- Emote Unlocker
task.spawn(function()
    while task.wait(4) do
        if Settings.EmoteUnlocker then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and string.find(string.lower(remote.Name), "emote") then
                        remote:FireServer(Settings.SelectedEmote, true)
                    end
                end
            end)
        end
    end
end)

-- Auto-Emote when idle
local lastPos = nil
task.spawn(function()
    while task.wait(1) do
        if Settings.AutoEmote and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local currentPos = LocalPlayer.Character.HumanoidRootPart.Position
            if lastPos and (currentPos - lastPos).Magnitude < 0.5 then
                pcall(function()
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and string.find(string.lower(remote.Name), "emote") then
                            remote:FireServer(Settings.SelectedEmote)
                            break
                        end
                    end
                end)
            end
            lastPos = currentPos
        else
            lastPos = nil
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

print("✅ Plalette MM2 Ultimate Loaded!")
print("🔴 Red outline ESP visible through walls")
print("🎯 Right-click locks onto Murderer")
print("⌨️ Ctrl to minimize to plalettescripts square")
print("🎭 Emote selector with idle auto-play")
print("⚡ All features working & optimized")
