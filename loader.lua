--[[
    MM2 Ultimate Script - Made for Plalette
    Optimized, Smooth, Feature-Rich
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Connections table for proper cleanup
local Connections = {}

-- Drawing cache for ESP (prevents flicker)
local ESPCache = {}
local ESPEnabled = {
    Players = false,
    Coins = false,
    Guns = false,
    Tracers = false
}

-- Clean ESP drawings
local function ClearESP()
    for _, drawing in pairs(ESPCache) do
        pcall(function() drawing:Remove() end)
    end
    ESPCache = {}
end

-- Create smooth GUI
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

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Gradient border effect
local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 4, 1, 4)
Border.Position = UDim2.new(0, -2, 0, -2)
Border.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
Border.BorderSizePixel = 0
Border.Parent = MainFrame
local BorderCorner = Instance.new("UICorner", Border)
BorderCorner.CornerRadius = UDim.new(0, 13)
Border.ZIndex = 0

-- Title bar with glowing "Plalette"
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleGlow = Instance.new("TextLabel")
TitleGlow.Size = UDim2.new(0.6, 0, 1, 0)
TitleGlow.Position = UDim2.new(0.02, 0, 0, 0)
TitleGlow.BackgroundTransparency = 1
TitleGlow.TextColor3 = Color3.fromRGB(180, 130, 255)
TitleGlow.Text = "✦ Plalette MM2 ✦"
TitleGlow.Font = Enum.Font.SourceSansBold
TitleGlow.TextSize = 22
TitleGlow.TextXAlignment = Enum.TextXAlignment.Left
TitleGlow.Parent = TitleBar

-- Glow effect
task.spawn(function()
    local hue = 0
    while TitleGlow.Parent do
        hue = (hue + 0.005) % 1
        local color = Color3.fromHSV(hue, 0.7, 1)
        TitleGlow.TextColor3 = color
        Border.BackgroundColor3 = color
        task.wait(0.03)
    end
end)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 8)

CloseButton.MouseButton1Click:Connect(function()
    ClearESP()
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    ScreenGui:Destroy()
end)

-- Tab system
local TabButtons = {}
local TabContents = {}
local CurrentTab = nil

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 130, 1, -50)
TabContainer.Position = UDim2.new(0, 5, 0, 48)
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
ContentFrame.Size = UDim2.new(1, -145, 1, -55)
ContentFrame.Position = UDim2.new(0, 138, 0, 48)
ContentFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 8)

local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -8, 0, 32)
    TabButton.Position = UDim2.new(0, 4, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabButton.Text = icon .. " " .. name
    TabButton.Font = Enum.Font.SourceSansSemibold
    TabButton.TextSize = 13
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = TabContainer
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

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

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(TabContents) do
            tab.Visible = false
        end
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        Content.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurrentTab = Content
    end)

    table.insert(TabButtons, TabButton)
    table.insert(TabContents, Content)

    return {
        Content = Content,
        CreateToggle = function(name, default, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -5, 0, 36)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            ToggleFrame.Parent = Content
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.65, 0, 1, 0)
            Label.Position = UDim2.new(0.03, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(220, 220, 240)
            Label.Text = name .. " : OFF"
            Label.Font = Enum.Font.SourceSansSemibold
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 48, 0, 24)
            Switch.Position = UDim2.new(0.92, -48, 0, 6)
            Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            Switch.Text = ""
            Switch.Parent = ToggleFrame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 12)

            local enabled = default
            local function UpdateVisual()
                Label.Text = name .. " : " .. (enabled and "ON" or "OFF")
                Switch.BackgroundColor3 = enabled and Color3.fromRGB(100, 50, 220) or Color3.fromRGB(60, 60, 75)
                Label.TextColor3 = enabled and Color3.fromRGB(180, 140, 255) or Color3.fromRGB(220, 220, 240)
            end
            UpdateVisual()

            Switch.MouseButton1Click:Connect(function()
                enabled = not enabled
                UpdateVisual()
                callback(enabled)
            end)
        end
    }
end

-- Create all tabs
local CombatTab = CreateTab("Combat", "⚔️")
local ESPTab = CreateTab("ESP", "👁️")
local MovementTab = CreateTab("Movement", "🏃")
local FarmTab = CreateTab("Farming", "💰")
local EmoteTab = CreateTab("Emotes", "🎭")
local WorldTab = CreateTab("World", "🌍")

-- Activate first tab
if TabButtons[1] then
    TabButtons[1].BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
    TabContents[1].Visible = true
    CurrentTab = TabContents[1]
end

-- ==================== COMBAT FEATURES ====================

CombatTab.CreateToggle("Silent Aim", false, function(state)
    if state then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" and (tostring(self) == "Shoot" or tostring(self) == "ShootGun") and LocalPlayer.Character then
                local target = nil
                local closest = math.huge
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if onScreen and dist < 250 and dist < closest then
                            closest = dist
                            target = player
                        end
                    end
                end
                if target then
                    args[1] = target.Character.Head.Position
                end
            end
            return oldNamecall(self, unpack(args))
        end)
        Connections.SilentAim = {Disconnect = function() hookmetamethod(game, "__namecall", oldNamecall) end}
    else
        if Connections.SilentAim then Connections.SilentAim:Disconnect() end
    end
end)

CombatTab.CreateToggle("Hitbox Expander", false, function(state)
    if state then
        task.spawn(function()
            while state do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.Size = Vector3.new(3, 3, 3)
                        player.Character.HumanoidRootPart.Transparency = 0.7
                    end
                end
                task.wait(0.3)
            end
        end)
    end
end)

CombatTab.CreateToggle("Instant Reload", false, function(state)
    if state then
        task.spawn(function()
            while state do
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                        tool.Ammo.Value = 99
                    end
                end
                local charTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if charTool and charTool:FindFirstChild("Ammo") then
                    charTool.Ammo.Value = 99
                end
                task.wait(0.2)
            end
        end)
    end
end)

CombatTab.CreateToggle("Triggerbot", false, function(state)
    if state then
        task.spawn(function()
            while state do
                pcall(function()
                    local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 500)
                    local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                    if hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent ~= LocalPlayer.Character then
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool and tool:FindFirstChild("Shoot") then
                            tool:FindFirstChild("Shoot"):FireServer()
                        end
                    end
                end)
                task.wait(0.08)
            end
        end)
    end
end)

-- ==================== ESP FEATURES ====================

ESPTab.CreateToggle("Player ESP", false, function(state)
    ESPEnabled.Players = state
    if not state then ClearESP() end
    if state then
        task.spawn(function()
            while ESPEnabled.Players do
                local drawings = {}
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
                        local head = player.Character.Head
                        local hrp = player.Character.HumanoidRootPart
                        local headPos, headOn = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.6, 0))
                        local legPos = Camera:WorldToScreenPoint(hrp.Position - Vector3.new(0, 3, 0))
                        if headOn then
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height / 2
                            local box = Drawing.new("Square")
                            box.Color = Color3.fromRGB(255, 80, 80)
                            box.Thickness = 1.2
                            box.Size = Vector2.new(width, height)
                            box.Position = Vector2.new(headPos.X - width/2, headPos.Y)
                            box.Visible = true
                            box.Filled = false
                            table.insert(drawings, box)

                            local name = Drawing.new("Text")
                            name.Text = player.Name
                            name.Color = Color3.fromRGB(255, 255, 255)
                            name.Size = 13
                            name.Position = Vector2.new(headPos.X, headPos.Y - 28)
                            name.Center = true
                            name.Visible = true
                            table.insert(drawings, name)

                            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                            local distText = Drawing.new("Text")
                            distText.Text = dist .. "m"
                            distText.Color = Color3.fromRGB(200, 200, 200)
                            distText.Size = 12
                            distText.Position = Vector2.new(headPos.X, headPos.Y - 16)
                            distText.Center = true
                            distText.Visible = true
                            table.insert(drawings, distText)
                        end
                    end
                end
                ESPCache = drawings
                task.wait(0.02)
                for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
            end
        end)
    end
end)

ESPTab.CreateToggle("Coin ESP", false, function(state)
    ESPEnabled.Coins = state
    if state then
        task.spawn(function()
            while ESPEnabled.Coins do
                local drawings = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "Coin" and obj:IsA("BasePart") then
                        local pos, onScreen = Camera:WorldToScreenPoint(obj.Position)
                        if onScreen then
                            local txt = Drawing.new("Text")
                            txt.Text = "💰"
                            txt.Color = Color3.fromRGB(255, 215, 0)
                            txt.Size = 18
                            txt.Position = Vector2.new(pos.X, pos.Y)
                            txt.Center = true
                            txt.Visible = true
                            table.insert(drawings, txt)
                        end
                    end
                end
                task.wait(0.08)
                for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
            end
        end)
    end
end)

ESPTab.CreateToggle("Gun ESP", false, function(state)
    ESPEnabled.Guns = state
    if state then
        task.spawn(function()
            while ESPEnabled.Guns do
                local drawings = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                        local pos, onScreen = Camera:WorldToScreenPoint(obj.Position)
                        if onScreen then
                            local txt = Drawing.new("Text")
                            txt.Text = "🔫 Gun"
                            txt.Color = Color3.fromRGB(0, 180, 255)
                            txt.Size = 13
                            txt.Position = Vector2.new(pos.X, pos.Y)
                            txt.Center = true
                            txt.Visible = true
                            table.insert(drawings, txt)
                        end
                    end
                end
                task.wait(0.08)
                for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
            end
        end)
    end
end)

ESPTab.CreateToggle("Tracers", false, function(state)
    ESPEnabled.Tracers = state
    if state then
        task.spawn(function()
            while ESPEnabled.Tracers do
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
        end)
    end
end)

ESPTab.CreateToggle("Role Reveal", false, function(state)
    if state then
        task.spawn(function()
            while state do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local role = "Innocent"
                        local color = Color3.fromRGB(0, 255, 0)
                        if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
                            role = "🔪 Murderer"
                            color = Color3.fromRGB(255, 0, 0)
                        elseif player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then
                            role = "🔫 Sheriff"
                            color = Color3.fromRGB(0, 180, 255)
                        end
                        local bb = player.Character.Head:FindFirstChild("RoleTag") or Instance.new("BillboardGui", player.Character.Head)
                        bb.Name = "RoleTag"
                        bb.Size = UDim2.new(0, 120, 0, 35)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        local tl = bb:FindFirstChild("Label") or Instance.new("TextLabel", bb)
                        tl.Name = "Label"
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.BackgroundTransparency = 1
                        tl.TextColor3 = color
                        tl.Text = role
                        tl.Font = Enum.Font.SourceSansBold
                        tl.TextSize = 16
                        tl.TextStrokeTransparency = 0
                        tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- ==================== MOVEMENT FEATURES ====================

MovementTab.CreateToggle("Speed Hack", false, function(state)
    if state then
        Connections.SpeedHack = RunService.Stepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 32
            end
        end)
    else
        if Connections.SpeedHack then
            Connections.SpeedHack:Disconnect()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
end)

MovementTab.CreateToggle("NoClip", false, function(state)
    if state then
        Connections.NoClip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.NoClip then
            Connections.NoClip:Disconnect()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end)

MovementTab.CreateToggle("Infinite Jump", false, function(state)
    if state then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.InfJump then Connections.InfJump:Disconnect() end
    end
end)

MovementTab.CreateToggle("Anti-AFK", false, function(state)
    if state then
        task.spawn(function()
            while state do
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                    task.wait(0.1)
                    VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
                end)
                task.wait(120)
            end
        end)
    end
end)

MovementTab.CreateToggle("Teleport to Killer", false, function(state)
    if state then
        task.spawn(function()
            while state do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

-- ==================== FARMING FEATURES ====================

FarmTab.CreateToggle("Auto-Farm Coins", false, function(state)
    if state then
        task.spawn(function()
            while state do
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "Coin" and obj:IsA("BasePart") and LocalPlayer.Character then
                        if (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 200 then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                        end
                    end
                end
                task.wait(0.15)
            end
        end)
    end
end)

FarmTab.CreateToggle("Auto-Pickup Gun", false, function(state)
    if state then
        task.spawn(function()
            while state do
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "GunDrop" and obj:IsA("BasePart") and LocalPlayer.Character then
                        if (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 60 then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

-- ==================== EMOTE FEATURES ====================

EmoteTab.CreateToggle("Emote Unlocker", false, function(state)
    if state then
        task.spawn(function()
            while state do
                pcall(function()
                    -- Attempt to unlock all emotes by firing purchase events
                    local emotes = {"Dab", "Floss", "Laugh", "Wave", "Point", "Salute", "ThumbsUp", "Boo", "Cheers", "Dance1", "Dance2"}
                    for _, emote in ipairs(emotes) do
                        local args = {[1] = emote, [2] = true}
                        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and (remote.Name == "Emote" or remote.Name == "PurchaseEmote" or remote.Name == "UnlockEmote") then
                                remote:FireServer(unpack(args))
                            end
                        end
                    end
                end)
                task.wait(5)
            end
        end)
    end
end)

EmoteTab.CreateToggle("Auto-Emote", false, function(state)
    if state then
        task.spawn(function()
            local emoteList = {"Dab", "Floss", "Laugh", "Wave", "Point", "Salute", "ThumbsUp", "Dance1", "Dance2"}
            local index = 1
            while state do
                pcall(function()
                    local emote = emoteList[index]
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and (remote.Name == "Emote" or remote.Name == "PlayEmote" or remote.Name == "DoEmote") then
                            remote:FireServer(emote)
                        end
                    end
                    index = (index % #emoteList) + 1
                end)
                task.wait(3)
            end
        end)
    end
end)

-- ==================== WORLD FEATURES ====================

WorldTab.CreateToggle("Fullbright", false, function(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 10000
        Lighting.GlobalShadows = true
    end
end)

WorldTab.CreateToggle("Fog Remover", false, function(state)
    if state then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = 10000
    end
end)

WorldTab.CreateToggle("Wireframe", false, function(state)
    if state then
        task.spawn(function()
            while state do
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                        obj.Wireframe = true
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

-- Success notification
print("✅ Plalette MM2 Ultimate Script Loaded Successfully!")
print("🎨 GUI with color-changing theme, organized tabs, glowing title")
print("⚡ All features optimized for smooth performance")
print("👁️ ESP: No flickering, smooth rendering")
print("🎭 Emote Unlocker and Auto-Emote included")
print("✦ Made for Plalette ✦")
