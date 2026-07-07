--[[
    Plalette MM2 Script - Complete Rewrite
    All features fixed and optimized
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    SilentAim = false,
    RightClickAimbot = false,
    HitboxSize = 3,
    HitboxExpander = false,
    InstantReload = false,
    Triggerbot = false,
    SpeedHack = false,
    SpeedValue = 32,
    NoClip = false,
    InfiniteJump = false,
    AntiAFK = false,
    TeleportKiller = false,
    PlayerESP = false,
    CoinESP = false,
    GunESP = false,
    Tracers = false,
    RoleReveal = false,
    AutoFarm = false,
    AutoPickup = false,
    EmoteUnlocker = false,
    AutoEmote = false,
    SelectedEmote = "Dab",
    Fullbright = false,
    FogRemover = false,
    Wireframe = false
}

-- Connections
local Connections = {}
local ESPDrawings = {}
local BodyParts = {}

-- Cleanup function
local function CleanupESP()
    for _, d in pairs(ESPDrawings) do
        pcall(function() d:Remove() end)
    end
    ESPDrawings = {}
end

local function DisconnectAll()
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
end

-- ==================== GUI SYSTEM ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlaletteMM2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Minimized Square
local MiniFrame = Instance.new("Frame")
MiniFrame.Size = UDim2.new(0, 120, 0, 40)
MiniFrame.Position = UDim2.new(0.5, -60, 0.02, 0)
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
MiniLabel.TextColor3 = Color3.fromRGB(180, 130, 255)
MiniLabel.Text = "plalettescripts"
MiniLabel.Font = Enum.Font.SourceSansBold
MiniLabel.TextSize = 14
MiniLabel.Parent = MiniFrame

-- Ctrl Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
        MiniFrame.Visible = not MiniFrame.Visible
    end
end)

-- Glow border effect
local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 4, 1, 4)
Border.Position = UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
Border.BorderSizePixel = 0
Border.Parent = MainFrame
Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 11)
Border.ZIndex = 0

local MiniBorder = Instance.new("Frame")
MiniBorder.Size = UDim2.new(1, 4, 1, 4)
MiniBorder.Position = UDim2.new(0, -2, 0, -2)
MiniBorder.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
MiniBorder.BorderSizePixel = 0
MiniBorder.Parent = MiniFrame
Instance.new("UICorner", MiniBorder).CornerRadius = UDim.new(0, 9)

-- Color animation
task.spawn(function()
    local hue = 0
    while ScreenGui.Parent do
        hue = (hue + 0.004) % 1
        local color = Color3.fromHSV(hue, 0.8, 1)
        Border.BackgroundColor3 = color
        MiniBorder.BackgroundColor3 = color
        MiniLabel.TextColor3 = color
        task.wait(0.03)
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
    CleanupESP()
    DisconnectAll()
    ScreenGui:Destroy()
end)

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 120, 1, -45)
TabContainer.Position = UDim2.new(0, 4, 0, 43)
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 2)
TabList.FillDirection = Enum.FillDirection.Vertical
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabContainer

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -132, 1, -48)
ContentFrame.Position = UDim2.new(0, 128, 0, 43)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 8)

local Tabs = {}
local CurrentContent = nil

local function CreateTab(name, icon)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 30)
    Btn.Position = UDim2.new(0, 3, 0, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Btn.Text = icon .. "  " .. name
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
    ContentList.Padding = UDim.new(0, 3)
    ContentList.FillDirection = Enum.FillDirection.Vertical
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = Content

    Btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            tab.Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        Content.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentContent = Content
    end)

    local tabData = {Btn = Btn, Content = Content}
    table.insert(Tabs, tabData)
    if #Tabs == 1 then
        Content.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentContent = Content
    end

    return {
        CreateToggle = function(name, settingKey)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -2, 0, 34)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            ToggleFrame.Parent = Content
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 5)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0.03, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(220, 220, 240)
            Label.Text = name .. " : OFF"
            Label.Font = Enum.Font.SourceSansSemibold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 44, 0, 22)
            Switch.Position = UDim2.new(0.92, -44, 0, 6)
            Switch.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
            Switch.Text = ""
            Switch.Parent = ToggleFrame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 11)

            Switch.MouseButton1Click:Connect(function()
                Settings[settingKey] = not Settings[settingKey]
                local enabled = Settings[settingKey]
                Label.Text = name .. " : " .. (enabled and "ON" or "OFF")
                Switch.BackgroundColor3 = enabled and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(55, 55, 70)
                Label.TextColor3 = enabled and Color3.fromRGB(180, 150, 255) or Color3.fromRGB(220, 220, 240)
            end)
        end,
        CreateSlider = function(name, settingKey, min, max, default)
            Settings[settingKey] = default
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -2, 0, 55)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            SliderFrame.Parent = Content
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 5)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.Position = UDim2.new(0.03, 0, 0, 3)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(220, 220, 240)
            Label.Text = name .. " : " .. tostring(default)
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(0.3, 0, 0, 22)
            InputBox.Position = UDim2.new(0.35, 0, 0, 28)
            InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            InputBox.Text = tostring(default)
            InputBox.Font = Enum.Font.SourceSans
            InputBox.TextSize = 12
            InputBox.PlaceholderText = "Value"
            InputBox.Parent = SliderFrame
            Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)

            InputBox.FocusLost:Connect(function()
                local val = tonumber(InputBox.Text)
                if val and val >= min and val <= max then
                    Settings[settingKey] = val
                    Label.Text = name .. " : " .. tostring(val)
                else
                    InputBox.Text = tostring(Settings[settingKey])
                end
            end)
        end,
        CreateDropdown = function(name, options, settingKey, default)
            Settings[settingKey] = default
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, -2, 0, 34)
            DropFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            DropFrame.Parent = Content
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 5)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.4, 0, 1, 0)
            Label.Position = UDim2.new(0.03, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(220, 220, 240)
            Label.Text = name .. ":"
            Label.Font = Enum.Font.SourceSansSemibold
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropFrame

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(0.4, 0, 0, 24)
            DropBtn.Position = UDim2.new(0.55, 0, 0, 5)
            DropBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropBtn.Text = default
            DropBtn.Font = Enum.Font.SourceSans
            DropBtn.TextSize = 12
            DropBtn.Parent = DropFrame
            Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)

            local DropList = Instance.new("Frame")
            DropList.Size = UDim2.new(0.4, 0, 0, #options * 24)
            DropList.Position = UDim2.new(0.55, 0, 0, 30)
            DropList.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            DropList.BorderSizePixel = 0
            DropList.Visible = false
            DropList.Parent = DropFrame
            Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 4)

            local DropListLayout = Instance.new("UIListLayout")
            DropListLayout.FillDirection = Enum.FillDirection.Vertical
            DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropListLayout.Parent = DropList

            for _, option in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                OptBtn.Text = option
                OptBtn.Font = Enum.Font.SourceSans
                OptBtn.TextSize = 12
                OptBtn.Parent = DropList
                OptBtn.MouseButton1Click:Connect(function()
                    Settings[settingKey] = option
                    DropBtn.Text = option
                    DropList.Visible = false
                end)
            end

            DropBtn.MouseButton1Click:Connect(function()
                DropList.Visible = not DropList.Visible
            end)
        end
    }
end

-- Create Tabs
local CombatTab = CreateTab("Combat", "⚔")
local ESPTab = CreateTab("Visuals", "👁")
local MoveTab = CreateTab("Move", "🏃")
local FarmTab = CreateTab("Farm", "💰")
local EmoteTab = CreateTab("Emotes", "🎭")
local WorldTab = CreateTab("World", "🌍")

-- ==================== COMBAT ====================
CombatTab.CreateToggle("Silent Aim", "SilentAim")

CombatTab.CreateToggle("Right-Click Aimbot (Murderer)", "RightClickAimbot")

CombatTab.CreateSlider("Hitbox Size", "HitboxSize", 1, 8, 3)
CombatTab.CreateToggle("Hitbox Expander", "HitboxExpander")

CombatTab.CreateToggle("Instant Reload", "InstantReload")
CombatTab.CreateToggle("Triggerbot", "Triggerbot")

-- ==================== ESP ====================
ESPTab.CreateToggle("Player ESP (Red Skin)", "PlayerESP")
ESPTab.CreateToggle("Coin ESP", "CoinESP")
ESPTab.CreateToggle("Gun ESP", "GunESP")
ESPTab.CreateToggle("Tracers", "Tracers")
ESPTab.CreateToggle("Role Reveal", "RoleReveal")

-- ==================== MOVEMENT ====================
MoveTab.CreateSlider("Speed Value", "SpeedValue", 16, 100, 32)
MoveTab.CreateToggle("Speed Hack", "SpeedHack")
MoveTab.CreateToggle("NoClip", "NoClip")
MoveTab.CreateToggle("Infinite Jump", "InfiniteJump")
MoveTab.CreateToggle("Anti-AFK", "AntiAFK")
MoveTab.CreateToggle("Teleport to Killer", "TeleportKiller")

-- ==================== FARM ====================
FarmTab.CreateToggle("Auto-Farm Coins", "AutoFarm")
FarmTab.CreateToggle("Auto-Pickup Gun", "AutoPickup")

-- ==================== EMOTES ====================
EmoteTab.CreateDropdown("Select Emote", {"Dab", "Floss", "Laugh", "Wave", "Point", "Salute", "ThumbsUp", "Boo", "Cheers", "Dance1", "Dance2", "Shrug", "Stretch"}, "SelectedEmote", "Dab")
EmoteTab.CreateToggle("Emote Unlocker", "EmoteUnlocker")
EmoteTab.CreateToggle("Auto-Emote (When Idle)", "AutoEmote")

-- ==================== WORLD ====================
WorldTab.CreateToggle("Fullbright", "Fullbright")
WorldTab.CreateToggle("Fog Remover", "FogRemover")
WorldTab.CreateToggle("Wireframe", "Wireframe")

-- ==================== FEATURE IMPLEMENTATIONS ====================

-- Silent Aim (fixed to not block shooting)
local SilentAimConnection
task.spawn(function()
    local oldNamecall
    SilentAimConnection = RunService.RenderStepped:Connect(function()
        if Settings.SilentAim then
            if not oldNamecall then
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    local args = {...}
                    if method == "FireServer" and (tostring(self) == "Shoot" or tostring(self) == "ShootGun") then
                        if LocalPlayer.Character then
                            local target = nil
                            local closest = math.huge
                            for _, player in ipairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                                    local pos, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                                    if onScreen and dist < 300 and dist < closest then
                                        closest = dist
                                        target = player
                                    end
                                end
                            end
                            if target and args[1] then
                                args[1] = target.Character.Head.Position
                            end
                        end
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

-- Right-Click Aimbot for Murderer only
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Settings.RightClickAimbot then
            Connections.RCAimbot = RunService.RenderStepped:Connect(function()
                local target = nil
                local closest = math.huge
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local isMurderer = player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")
                        if isMurderer then
                            local pos, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            if onScreen and dist < 400 and dist < closest then
                                closest = dist
                                target = player
                            end
                        end
                    end
                end
                if target then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
                end
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Connections.RCAimbot then
            Connections.RCAimbot:Disconnect()
            Connections.RCAimbot = nil
        end
    end
end)

-- Hitbox Expander
task.spawn(function()
    while task.wait(0.3) do
        if Settings.HitboxExpander then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local size = Settings.HitboxSize
                    player.Character.HumanoidRootPart.Size = Vector3.new(size, size, size)
                    player.Character.HumanoidRootPart.Transparency = 0.6
                    if player.Character:FindFirstChild("Head") then
                        player.Character.Head.Size = Vector3.new(size * 0.7, size * 0.7, size * 0.7)
                    end
                end
            end
        end
    end
end)

-- Instant Reload
task.spawn(function()
    while task.wait(0.15) do
        if Settings.InstantReload then
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                    pcall(function() tool.Ammo.Value = 99 end)
                end
                if tool:IsA("Tool") and tool:FindFirstChild("MaxAmmo") then
                    pcall(function() tool.MaxAmmo.Value = 99 end)
                end
            end
            local charTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if charTool then
                if charTool:FindFirstChild("Ammo") then
                    pcall(function() charTool.Ammo.Value = 99 end)
                end
            end
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
                    if hit and hit.Parent then
                        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
                        if humanoid and hit.Parent ~= LocalPlayer.Character then
                            tool:FindFirstChild("Shoot"):FireServer(pos)
                        end
                    end
                end
            end)
        end
    end
end)

-- Player ESP (Red skin, no boxes)
task.spawn(function()
    while task.wait(0.03) do
        CleanupESP()
        if Settings.PlayerESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    -- Color entire character red
                    for _, part in ipairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.Color = Color3.fromRGB(255, 30, 30)
                            part.Material = Enum.Material.SmoothPlastic
                        end
                    end
                    -- ESP text above head
                    if player.Character:FindFirstChild("Head") then
                        local headPos, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position + Vector3.new(0, 1, 0))
                        if onScreen then
                            local nameTag = Drawing.new("Text")
                            nameTag.Text = player.Name
                            nameTag.Color = Color3.fromRGB(255, 50, 50)
                            nameTag.Size = 14
                            nameTag.Position = Vector2.new(headPos.X, headPos.Y)
                            nameTag.Center = true
                            nameTag.Visible = true
                            table.insert(ESPDrawings, nameTag)

                            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                            local distTag = Drawing.new("Text")
                            distTag.Text = dist .. "m"
                            distTag.Color = Color3.fromRGB(255, 200, 200)
                            distTag.Size = 11
                            distTag.Position = Vector2.new(headPos.X, headPos.Y + 15)
                            distTag.Center = true
                            distTag.Visible = true
                            table.insert(ESPDrawings, distTag)
                        end
                    end
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

-- Tracers (fixed)
task.spawn(function()
    while task.wait(0.02) do
        if Settings.Tracers then
            local drawings = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onScreen = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
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
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local role = "Innocent"
                    local color = Color3.fromRGB(0, 255, 0)
                    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
                        role = "🔪 Murderer"
                        color = Color3.fromRGB(255, 0, 0)
                    elseif player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then
                        role = "🔫 Sheriff"
                        color = Color3.fromRGB(0, 150, 255)
                    end
                    local bb = player.Character.Head:FindFirstChild("RoleTag") or Instance.new("BillboardGui", player.Character.Head)
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
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
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
                VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end)
        end
    end
end)

-- Teleport to Killer
task.spawn(function()
    while task.wait(2) do
        if Settings.TeleportKiller and LocalPlayer.Character then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    end
                end
            end
        end
    end
end)

-- Auto-Farm Coins
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

-- Auto-Pickup Gun
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

-- Auto-Emote when idle (not moving)
local lastPosition = nil
task.spawn(function()
    while task.wait(1) do
        if Settings.AutoEmote and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local currentPos = LocalPlayer.Character.HumanoidRootPart.Position
            if lastPosition and (currentPos - lastPosition).Magnitude < 0.5 then
                -- Player is idle
                pcall(function()
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and (remote.Name == "PlayEmote" or remote.Name == "Emote" or string.find(string.lower(remote.Name), "emote")) then
                            remote:FireServer(Settings.SelectedEmote)
                            break
                        end
                    end
                end)
            end
            lastPosition = currentPos
        else
            lastPosition = nil
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
        if Settings.Wireframe then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                    obj.Wireframe = true
                end
            end
        end
    end
end)

print("✅ Plalette MM2 Script V3 Loaded!")
print("🎯 Right-click aimbot for Murderer")
print("🔴 Red skin ESP - no boxes")
print("⌨️ Ctrl to minimize UI")
print("🎭 Emote selector with idle auto-play")
print("⚡ All features optimized & fixed")
