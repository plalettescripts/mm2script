-- Plalette MM2 Script - Clean Working Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Settings storage
local Enabled = {}

-- Helper functions
local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if (p.Backpack and p.Backpack:FindFirstChild("Knife")) or (p.Character and p.Character:FindFirstChild("Knife")) then
                return p
            end
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if (p.Backpack and p.Backpack:FindFirstChild("Gun")) or (p.Character and p.Character:FindFirstChild("Gun")) then
                return p
            end
        end
    end
    return nil
end

-- GUI Setup
local GUI = Instance.new("ScreenGui")
GUI.Name = "PlaletteMM2"
GUI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.7, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.BorderSizePixel = 0
Main.Draggable = true
Main.Active = true
Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.TextColor3 = Color3.fromRGB(180, 140, 255)
Title.Text = "Plalette MM2"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = Main

-- Close button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 24)
Close.Position = UDim2.new(1, -35, 0, 3)
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Text = "X"
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 14
Close.Parent = Main
Close.MouseButton1Click:Connect(function() GUI:Destroy() end)

-- Scrolling frame for toggles
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 3)
List.FillDirection = Enum.FillDirection.Vertical
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Scroll

-- Toggle creation function
local toggleCount = 0
local function CreateToggle(name, callback)
    toggleCount = toggleCount + 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, toggleCount * 38)
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -5, 0, 34)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.Parent = Scroll
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0.03, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Text = name .. " : OFF"
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 44, 0, 22)
    Btn.Position = UDim2.new(0.92, -44, 0, 6)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Btn.Text = ""
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 11)
    
    local on = false
    Btn.MouseButton1Click:Connect(function()
        on = not on
        Label.Text = name .. " : " .. (on and "ON" or "OFF")
        Btn.BackgroundColor3 = on and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(60, 60, 80)
        callback(on)
    end)
end

-- ==================== FEATURES ====================

-- Right-Click Aimbot
CreateToggle("Right-Click Aimbot", function(state)
    Enabled.RightClickAimbot = state
end)

local aimbotConnection = nil
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Enabled.RightClickAimbot then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local murd = GetMurderer()
            if murd and murd.Character and murd.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, murd.Character.Head.Position)
            end
        end)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
    end
end)

-- Instant Reload
CreateToggle("Instant Reload", function(state)
    Enabled.InstantReload = state
end)
task.spawn(function()
    while task.wait(0.15) do
        if Enabled.InstantReload then
            pcall(function()
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("Ammo") then t.Ammo.Value = 99 end
                end
                local ct = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if ct and ct:FindFirstChild("Ammo") then ct.Ammo.Value = 99 end
            end)
        end
    end
end)

-- Triggerbot
CreateToggle("Triggerbot", function(state)
    Enabled.Triggerbot = state
end)
task.spawn(function()
    while task.wait(0.08) do
        if Enabled.Triggerbot and LocalPlayer.Character then
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
CreateToggle("God Mode", function(state)
    Enabled.GodMode = state
end)
task.spawn(function()
    while task.wait(0.2) do
        if Enabled.GodMode and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
    end
end)

-- Hitbox Expander
CreateToggle("Hitbox Expander", function(state)
    Enabled.Hitbox = state
end)
task.spawn(function()
    while task.wait(0.3) do
        if Enabled.Hitbox then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(4, 4, 4)
                    p.Character.HumanoidRootPart.Transparency = 0.5
                end
            end
        end
    end
end)

-- Player ESP (Colored outlines)
CreateToggle("Player ESP (Outlines)", function(state)
    Enabled.PlayerESP = state
end)
task.spawn(function()
    while task.wait(0.5) do
        if Enabled.PlayerESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("ESP_Highlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "ESP_Highlight"
                        hl.FillTransparency = 1
                        hl.OutlineTransparency = 0
                        hl.Parent = p.Character
                    end
                    local isMurderer = (p.Backpack and p.Backpack:FindFirstChild("Knife")) or (p.Character and p.Character:FindFirstChild("Knife"))
                    local isSheriff = (p.Backpack and p.Backpack:FindFirstChild("Gun")) or (p.Character and p.Character:FindFirstChild("Gun"))
                    if isMurderer then
                        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                    elseif isSheriff then
                        hl.OutlineColor = Color3.fromRGB(0, 100, 255)
                    else
                        hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("ESP_Highlight") then
                    p.Character.ESP_Highlight:Destroy()
                end
            end
        end
    end
end)

-- Coin ESP
CreateToggle("Coin ESP", function(state)
    Enabled.CoinESP = state
end)
task.spawn(function()
    while task.wait(0.1) do
        if Enabled.CoinESP then
            local draws = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "Coin" and obj:IsA("BasePart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
                    if onScreen then
                        local d = Drawing.new("Text")
                        d.Text = "💰"
                        d.Color = Color3.fromRGB(255, 215, 0)
                        d.Size = 18
                        d.Position = Vector2.new(pos.X, pos.Y)
                        d.Center = true
                        d.Visible = true
                        table.insert(draws, d)
                    end
                end
            end
            task.wait(0.05)
            for _, d in pairs(draws) do pcall(function() d:Remove() end) end
        end
    end
end)

-- Gun ESP
CreateToggle("Gun ESP", function(state)
    Enabled.GunESP = state
end)
task.spawn(function()
    while task.wait(0.1) do
        if Enabled.GunESP then
            local draws = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
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
                        table.insert(draws, d)
                    end
                end
            end
            task.wait(0.05)
            for _, d in pairs(draws) do pcall(function() d:Remove() end) end
        end
    end
end)

-- Tracers
CreateToggle("Tracers", function(state)
    Enabled.Tracers = state
end)
task.spawn(function()
    while task.wait(0.03) do
        if Enabled.Tracers then
            local draws = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local l = Drawing.new("Line")
                        l.Color = Color3.fromRGB(255, 255, 255)
                        l.Thickness = 1
                        l.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        l.To = Vector2.new(pos.X, pos.Y)
                        l.Visible = true
                        table.insert(draws, l)
                    end
                end
            end
            task.wait(0.02)
            for _, d in pairs(draws) do pcall(function() d:Remove() end) end
        end
    end
end)

-- Role Reveal
CreateToggle("Role Reveal", function(state)
    Enabled.RoleReveal = state
end)
task.spawn(function()
    while task.wait(1) do
        if Enabled.RoleReveal then
            for _, p in pairs(Players:GetPlayers()) do
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
CreateToggle("Speed Hack", function(state)
    Enabled.SpeedHack = state
end)
RunService.Stepped:Connect(function()
    if Enabled.SpeedHack and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 32 end
    end
end)

-- NoClip
CreateToggle("NoClip", function(state)
    Enabled.NoClip = state
end)
RunService.Stepped:Connect(function()
    if Enabled.NoClip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Infinite Jump
CreateToggle("Infinite Jump", function(state)
    Enabled.InfJump = state
end)
UserInputService.JumpRequest:Connect(function()
    if Enabled.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti-AFK
CreateToggle("Anti-AFK", function(state)
    Enabled.AntiAFK = state
end)
task.spawn(function()
    while task.wait(100) do
        if Enabled.AntiAFK then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
            end)
        end
    end
end)

-- Teleport to Killer
CreateToggle("Teleport to Killer", function(state)
    Enabled.TeleKiller = state
end)
task.spawn(function()
    while task.wait(2) do
        if Enabled.TeleKiller and LocalPlayer.Character then
            local m = GetMurderer()
            if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = m.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0) end
            end
        end
    end
end)

-- Auto-Farm Coins
CreateToggle("Auto-Farm Coins", function(state)
    Enabled.AutoFarm = state
end)
task.spawn(function()
    while task.wait(0.1) do
        if Enabled.AutoFarm and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(Workspace:GetDescendants()) do
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
CreateToggle("Auto-Pickup Guns", function(state)
    Enabled.AutoPickup = state
end)
task.spawn(function()
    while task.wait(0.5) do
        if Enabled.AutoPickup and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(Workspace:GetDescendants()) do
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

-- Fling Selected Player
local flingTarget = nil
CreateToggle("Fling Murderer", function(state)
    Enabled.FlingMurderer = state
end)
CreateToggle("Fling Sheriff", function(state)
    Enabled.FlingSheriff = state
end)

task.spawn(function()
    while task.wait(0.3) do
        local target = nil
        if Enabled.FlingMurderer then target = GetMurderer() end
        if not target and Enabled.FlingSheriff then target = GetSheriff() end
        
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(math.random(-2000, 2000), 3000, math.random(-2000, 2000))
            bv.Parent = target.Character.HumanoidRootPart
            task.delay(0.5, function() pcall(function() bv:Destroy() end) end)
        end
    end
end)

-- Fullbright
CreateToggle("Fullbright", function(state)
    Enabled.Fullbright = state
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
end)

-- Fog Remover
CreateToggle("Fog Remover", function(state)
    Enabled.FogRemover = state
    if state then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
    end
end)

print("Plalette MM2 Script Loaded - All features active")
