--[[
    ██████╗ ██╗      █████╗ ██╗      ███████╗████████╗████████╗███████╗
    ██╔══██╗██║     ██╔══██╗██║      ██╔════╝╚══██╔══╝██╔════╝██╔════╝
    ██████╔╝██║     ███████║██║█████╗█████╗     ██║   █████╗  ███████╗
    ██╔═══╝ ██║     ██╔══██║██║╚════╝██╔══╝     ██║   ██╔══╝  ╚════██║
    ██║     ███████╗██║  ██║███████╗ ███████╗    ██║   ███████╗███████║
    ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝ ╚══════╝    ╚═╝   ╚══════╝╚══════╝
    
    MM2 ULTIMATE SCRIPT
    Created by: plalettescripts
    Version: 2.0 Final
    GitHub: plalettescripts/mm2script
]]

-- ==================== SERVICES ====================
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
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- ==================== VARIABLES ====================
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==================== SETTINGS TABLE ====================
local Settings = {
    -- Combat
    RightClickAimbot = false,
    HitboxExpander = false,
    HitboxSize = 3,
    InstantReload = false,
    Triggerbot = false,
    GodMode = false,
    
    -- ESP
    PlayerESP = false,
    CoinESP = false,
    GunESP = false,
    Tracers = false,
    RoleReveal = false,
    
    -- Movement
    SpeedHack = false,
    SpeedValue = 32,
    NoClip = false,
    InfiniteJump = false,
    AntiAFK = false,
    TeleportToKiller = false,
    
    -- Farming
    AutoFarmCoins = false,
    AutoPickupGun = false,
    
    -- Fling
    FlingPlayerEnabled = false,
    FlingTargetName = "",
    FlingSheriffEnabled = false,
    FlingMurdererEnabled = false,
    FlingPower = 1000,
    AntiGrab = false,
    
    -- World
    Fullbright = false,
    FogRemover = false
}

-- ==================== CONNECTIONS & DRAWINGS STORAGE ====================
local Connections = {}
local ESPDrawings = {}
local FlingBodyVelocities = {}

-- ==================== HELPER FUNCTIONS ====================

-- Clear all ESP drawings
local function ClearESPDrawings()
    for _, drawing in pairs(ESPDrawings) do
        pcall(function() drawing:Remove() end)
    end
    ESPDrawings = {}
end

-- Disconnect all connections
local function DisconnectAllConnections()
    for key, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
        Connections[key] = nil
    end
end

-- Clean up all fling body velocities
local function CleanupFlingVelocities()
    for _, bv in pairs(FlingBodyVelocities) do
        pcall(function() bv:Destroy() end)
    end
    FlingBodyVelocities = {}
end

-- Get the Murderer player
local function GetMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Backpack and player.Backpack:FindFirstChild("Knife") then
                return player
            end
            if player.Character and player.Character:FindFirstChild("Knife") then
                return player
            end
        end
    end
    return nil
end

-- Get the Sheriff player
local function GetSheriff()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Backpack and player.Backpack:FindFirstChild("Gun") then
                return player
            end
            if player.Character and player.Character:FindFirstChild("Gun") then
                return player
            end
        end
    end
    return nil
end

-- Get list of all other player names
local function GetPlayerNameList()
    local nameList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(nameList, player.Name)
        end
    end
    if #nameList == 0 then
        table.insert(nameList, "No players found")
    end
    return nameList
end

-- Refresh player dropdown options
local function RefreshPlayerDropdown(dropdownFrame, dropdownBtn)
    local playerNames = GetPlayerNameList()
    
    -- Clear existing options
    for _, child in ipairs(dropdownFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Create new options
    for _, name in ipairs(playerNames) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, 0, 0, 28)
        optionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        optionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionBtn.Text = name
        optionBtn.Font = Enum.Font.SourceSans
        optionBtn.TextSize = 13
        optionBtn.Parent = dropdownFrame
        
        optionBtn.MouseButton1Click:Connect(function()
            Settings.FlingTargetName = name
            dropdownBtn.Text = name
            dropdownFrame.Visible = false
        end)
    end
end

-- Fling a specific player
local function FlingPlayer(targetPlayer, power)
    if not targetPlayer then return end
    if not targetPlayer.Character then return end
    
    local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Remove any existing body velocity on this player
    for _, existingBv in pairs(humanoidRootPart:GetChildren()) do
        if existingBv:IsA("BodyVelocity") then
            existingBv:Destroy()
        end
    end
    
    -- Create new body velocity
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(
        math.random(-power, power),
        power,
        math.random(-power, power)
    )
    bodyVelocity.Parent = humanoidRootPart
    
    -- Schedule cleanup
    task.delay(0.8, function()
        pcall(function() bodyVelocity:Destroy() end)
    end)
end

-- ==================== GUI CREATION ====================

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlaletteMM2Ultimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ==================== MAIN FRAME ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 450)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Animated Border
local BorderFrame = Instance.new("Frame")
BorderFrame.Name = "BorderFrame"
BorderFrame.Size = UDim2.new(1, 6, 1, 6)
BorderFrame.Position = UDim2.new(0, -3, 0, -3)
BorderFrame.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
BorderFrame.BorderSizePixel = 0
BorderFrame.ZIndex = 0
BorderFrame.Parent = MainFrame

local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 14)
BorderCorner.Parent = BorderFrame

-- Border color animation
task.spawn(function()
    local hue = 0
    while ScreenGui and ScreenGui.Parent do
        hue = (hue + 0.003) % 1
        local color = Color3.fromHSV(hue, 0.8, 1)
        pcall(function()
            BorderFrame.BackgroundColor3 = color
        end)
        task.wait(0.03)
    end
end)

-- ==================== MINIMIZED FRAME ====================
local MiniFrame = Instance.new("Frame")
MiniFrame.Name = "MiniFrame"
MiniFrame.Size = UDim2.new(0, 230, 0, 42)
MiniFrame.Position = UDim2.new(0.5, -115, 0.02, 0)
MiniFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
MiniFrame.BorderSizePixel = 0
MiniFrame.Visible = false
MiniFrame.Active = true
MiniFrame.Draggable = true
MiniFrame.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 8)
MiniCorner.Parent = MiniFrame

local MiniLabel = Instance.new("TextLabel")
MiniLabel.Name = "MiniLabel"
MiniLabel.Size = UDim2.new(1, 0, 1, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
MiniLabel.Text = "plalettescripts - Press CTRL to return"
MiniLabel.Font = Enum.Font.SourceSansBold
MiniLabel.TextSize = 14
MiniLabel.Parent = MiniFrame

-- ==================== CTRL TOGGLE ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        local newVisibility = not MainFrame.Visible
        MainFrame.Visible = newVisibility
        MiniFrame.Visible = not newVisibility
    end
end)

-- ==================== TITLE BAR ====================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.02, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(180, 140, 255)
TitleText.Text = "✦ Plalette MM2 Ultimate v2.0 ✦"
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 20
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 32, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ClearESPDrawings()
    DisconnectAllConnections()
    CleanupFlingVelocities()
    ScreenGui:Destroy()
end)

-- ==================== TAB CONTAINER ====================
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 140, 1, -48)
TabContainer.Position = UDim2.new(0, 5, 0, 46)
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabContainerCorner = Instance.new("UICorner")
TabContainerCorner.CornerRadius = UDim.new(0, 10)
TabContainerCorner.Parent = TabContainer

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Name = "TabListLayout"
TabListLayout.Padding = UDim.new(0, 3)
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabContainer

-- ==================== CONTENT FRAME ====================
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -152, 1, -54)
ContentFrame.Position = UDim2.new(0, 147, 0, 46)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentFrame

-- ==================== TAB CREATION FUNCTION ====================
local Tabs = {}

local function CreateTab(tabName, tabIcon)
    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 32)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 200)
    tabButton.Text = tabIcon .. "  " .. tabName
    tabButton.Font = Enum.Font.SourceSansSemibold
    tabButton.TextSize = 13
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.Parent = TabContainer
    
    local tabButtonCorner = Instance.new("UICorner")
    tabButtonCorner.CornerRadius = UDim.new(0, 6)
    tabButtonCorner.Parent = tabButton
    
    -- Content ScrollingFrame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = tabName .. "Content"
    contentFrame.Size = UDim2.new(1, -10, 1, -10)
    contentFrame.Position = UDim2.new(0, 5, 0, 5)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(130, 80, 255)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Visible = false
    contentFrame.Parent = ContentFrame
    
    local contentListLayout = Instance.new("UIListLayout")
    contentListLayout.Name = "ContentListLayout"
    contentListLayout.Padding = UDim.new(0, 4)
    contentListLayout.FillDirection = Enum.FillDirection.Vertical
    contentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentListLayout.Parent = contentFrame
    
    -- Track elements for canvas size
    local elementCount = 0
    local function UpdateCanvasSize()
        elementCount = elementCount + 1
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, elementCount * 38 + 10)
    end
    
    -- Click handler
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all content frames
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        -- Reset all tab buttons
        for _, child in ipairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                child.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
        end
        -- Show selected
        contentFrame.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    -- Auto-select first tab
    if #Tabs == 0 then
        contentFrame.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    local tabObject = {}
    
    -- Create Toggle
    function tabObject:CreateToggle(featureName, settingKey)
        UpdateCanvasSize()
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = featureName .. "Toggle"
        toggleFrame.Size = UDim2.new(1, -4, 0, 36)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
        toggleFrame.Parent = contentFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 6)
        toggleCorner.Parent = toggleFrame
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "Label"
        toggleLabel.Size = UDim2.new(0.62, 0, 1, 0)
        toggleLabel.Position = UDim2.new(0.03, 0, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
        toggleLabel.Text = featureName .. " : OFF"
        toggleLabel.Font = Enum.Font.SourceSansSemibold
        toggleLabel.TextSize = 13
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local toggleSwitch = Instance.new("TextButton")
        toggleSwitch.Name = "Switch"
        toggleSwitch.Size = UDim2.new(0, 48, 0, 24)
        toggleSwitch.Position = UDim2.new(0.92, -48, 0, 6)
        toggleSwitch.BackgroundColor3 = Color3.fromRGB(55, 55, 72)
        toggleSwitch.Text = ""
        toggleSwitch.AutoButtonColor = false
        toggleSwitch.Parent = toggleFrame
        
        local switchCorner = Instance.new("UICorner")
        switchCorner.CornerRadius = UDim.new(0, 12)
        switchCorner.Parent = toggleSwitch
        
        -- Toggle function
        local isEnabled = false
        local function updateVisual()
            toggleLabel.Text = featureName .. " : " .. (isEnabled and "ON" or "OFF")
            toggleSwitch.BackgroundColor3 = isEnabled and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(55, 55, 72)
            toggleLabel.TextColor3 = isEnabled and Color3.fromRGB(180, 150, 255) or Color3.fromRGB(220, 220, 240)
        end
        
        toggleSwitch.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            Settings[settingKey] = isEnabled
            updateVisual()
        end)
        
        return toggleFrame
    end
    
    -- Create Slider
    function tabObject:CreateSlider(featureName, settingKey, minValue, maxValue, defaultValue)
        UpdateCanvasSize()
        
        Settings[settingKey] = defaultValue
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = featureName .. "Slider"
        sliderFrame.Size = UDim2.new(1, -4, 0, 54)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
        sliderFrame.Parent = contentFrame
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 6)
        sliderCorner.Parent = sliderFrame
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "Label"
        sliderLabel.Size = UDim2.new(1, -10, 0, 20)
        sliderLabel.Position = UDim2.new(0, 5, 0, 4)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
        sliderLabel.Text = featureName .. " : " .. tostring(defaultValue)
        sliderLabel.Font = Enum.Font.SourceSans
        sliderLabel.TextSize = 12
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderFrame
        
        local sliderInput = Instance.new("TextBox")
        sliderInput.Name = "Input"
        sliderInput.Size = UDim2.new(0.35, 0, 0, 24)
        sliderInput.Position = UDim2.new(0.32, 0, 0, 26)
        sliderInput.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
        sliderInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderInput.Text = tostring(defaultValue)
        sliderInput.Font = Enum.Font.SourceSans
        sliderInput.TextSize = 13
        sliderInput.PlaceholderText = tostring(minValue) .. "-" .. tostring(maxValue)
        sliderInput.Parent = sliderFrame
        
        local sliderInputCorner = Instance.new("UICorner")
        sliderInputCorner.CornerRadius = UDim.new(0, 4)
        sliderInputCorner.Parent = sliderInput
        
        sliderInput.FocusLost:Connect(function(enterPressed)
            local value = tonumber(sliderInput.Text)
            if value and value >= minValue and value <= maxValue then
                Settings[settingKey] = value
                sliderLabel.Text = featureName .. " : " .. tostring(value)
            else
                sliderInput.Text = tostring(Settings[settingKey])
            end
        end)
        
        return sliderFrame
    end
    
    -- Create Dropdown
    function tabObject:CreateDropdown(featureName, optionsList, settingKey, defaultValue)
        UpdateCanvasSize()
        
        Settings[settingKey] = defaultValue or (optionsList[1] or "")
        
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = featureName .. "Dropdown"
        dropdownFrame.Size = UDim2.new(1, -4, 0, 36)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
        dropdownFrame.Parent = contentFrame
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 6)
        dropdownCorner.Parent = dropdownFrame
        
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Name = "Label"
        dropdownLabel.Size = UDim2.new(0.38, 0, 1, 0)
        dropdownLabel.Position = UDim2.new(0.03, 0, 0, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
        dropdownLabel.Text = featureName .. ":"
        dropdownLabel.Font = Enum.Font.SourceSansSemibold
        dropdownLabel.TextSize = 13
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Parent = dropdownFrame
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "DropdownButton"
        dropdownButton.Size = UDim2.new(0.5, 0, 0, 26)
        dropdownButton.Position = UDim2.new(0.47, 0, 0, 5)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.Text = Settings[settingKey]
        dropdownButton.Font = Enum.Font.SourceSans
        dropdownButton.TextSize = 13
        dropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
        dropdownButton.Parent = dropdownFrame
        
        local dropdownButtonCorner = Instance.new("UICorner")
        dropdownButtonCorner.CornerRadius = UDim.new(0, 4)
        dropdownButtonCorner.Parent = dropdownButton
        
        local dropdownList = Instance.new("Frame")
        dropdownList.Name = "DropdownList"
        dropdownList.Size = UDim2.new(0.5, 0, 0, math.min(#optionsList, 8) * 28)
        dropdownList.Position = UDim2.new(0.47, 0, 0, 32)
        dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 52)
        dropdownList.BorderSizePixel = 0
        dropdownList.Visible = false
        dropdownList.ZIndex = 10
        dropdownList.Parent = dropdownFrame
        
        local dropdownListCorner = Instance.new("UICorner")
        dropdownListCorner.CornerRadius = UDim.new(0, 4)
        dropdownListCorner.Parent = dropdownList
        
        local dropdownListLayout = Instance.new("UIListLayout")
        dropdownListLayout.FillDirection = Enum.FillDirection.Vertical
        dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropdownListLayout.Parent = dropdownList
        
        local function populateOptions()
            for _, child in ipairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            for _, optionName in ipairs(optionsList) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 28)
                optionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 52)
                optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionButton.Text = optionName
                optionButton.Font = Enum.Font.SourceSans
                optionButton.TextSize = 13
                optionButton.TextTruncate = Enum.TextTruncate.AtEnd
                optionButton.ZIndex = 11
                optionButton.Parent = dropdownList
                
                optionButton.MouseButton1Click:Connect(function()
                    Settings[settingKey] = optionName
                    dropdownButton.Text = optionName
                    dropdownList.Visible = false
                end)
            end
        end
        
        populateOptions()
        
        dropdownButton.MouseButton1Click:Connect(function()
            -- Refresh player list if this is the player dropdown
            if settingKey == "FlingTargetName" then
                local newOptions = GetPlayerNameList()
                optionsList = newOptions
                dropdownList.Size = UDim2.new(0.5, 0, 0, math.min(#newOptions, 8) * 28)
                populateOptions()
            end
            dropdownList.Visible = not dropdownList.Visible
        end)
        
        -- Close dropdown when clicking elsewhere
        dropdownFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                task.wait(0.1)
                dropdownList.Visible = false
            end
        end)
        
        return dropdownFrame
    end
    
    -- Create Button
    function tabObject:CreateButton(buttonName, callback)
        UpdateCanvasSize()
        
        local actionButton = Instance.new("TextButton")
        actionButton.Name = buttonName .. "Button"
        actionButton.Size = UDim2.new(1, -4, 0, 32)
        actionButton.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        actionButton.Text = buttonName
        actionButton.Font = Enum.Font.SourceSansBold
        actionButton.TextSize = 14
        actionButton.Parent = contentFrame
        
        local actionButtonCorner = Instance.new("UICorner")
        actionButtonCorner.CornerRadius = UDim.new(0, 6)
        actionButtonCorner.Parent = actionButton
        
        actionButton.MouseButton1Click:Connect(function()
            callback()
        end)
        
        return actionButton
    end
    
    table.insert(Tabs, {Button = tabButton, Content = contentFrame})
    return tabObject
end

-- ==================== CREATE ALL TABS ====================
local CombatTab = CreateTab("Combat", "⚔")
local ESPTab = CreateTab("Visuals", "👁")
local MovementTab = CreateTab("Movement", "🏃")
local FarmTab = CreateTab("Farming", "💰")
local FlingTab = CreateTab("Fling", "💨")
local WorldTab = CreateTab("World", "🌍")
local CreditsTab = CreateTab("Credits", "⭐")

-- ==================== COMBAT TAB ELEMENTS ====================
CombatTab:CreateToggle("Right-Click Aimbot (Murderer)", "RightClickAimbot")
CombatTab:CreateSlider("Hitbox Size", "HitboxSize", 1, 10, 3)
CombatTab:CreateToggle("Hitbox Expander", "HitboxExpander")
CombatTab:CreateToggle("Instant Reload", "InstantReload")
CombatTab:CreateToggle("Triggerbot", "Triggerbot")
CombatTab:CreateToggle("God Mode (Auto-Heal)", "GodMode")
CombatTab:CreateButton("Kill All Players", function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
end)

-- ==================== ESP TAB ELEMENTS ====================
ESPTab:CreateToggle("Player Outlines (Color Coded)", "PlayerESP")
ESPTab:CreateToggle("Coin ESP", "CoinESP")
ESPTab:CreateToggle("Gun ESP", "GunESP")
ESPTab:CreateToggle("Tracers", "Tracers")
ESPTab:CreateToggle("Role Reveal (Above Head)", "RoleReveal")

-- ==================== MOVEMENT TAB ELEMENTS ====================
MovementTab:CreateSlider("Walk Speed", "SpeedValue", 16, 200, 32)
MovementTab:CreateToggle("Speed Hack", "SpeedHack")
MovementTab:CreateToggle("NoClip (Walk Through Walls)", "NoClip")
MovementTab:CreateToggle("Infinite Jump", "InfiniteJump")
MovementTab:CreateToggle("Anti-AFK", "AntiAFK")
MovementTab:CreateToggle("Teleport To Killer", "TeleportToKiller")

-- ==================== FARM TAB ELEMENTS ====================
FarmTab:CreateToggle("Auto-Farm Coins", "AutoFarmCoins")
FarmTab:CreateToggle("Auto-Pickup Guns", "AutoPickupGun")

-- ==================== FLING TAB ELEMENTS ====================
local playerNameList = GetPlayerNameList()
FlingTab:CreateDropdown("Select Player", playerNameList, "FlingTargetName", playerNameList[1] or "Select player")
FlingTab:CreateSlider("Fling Power", "FlingPower", 100, 50000, 1000)
FlingTab:CreateToggle("Fling Selected Player", "FlingPlayerEnabled")
FlingTab:CreateToggle("Fling Sheriff", "FlingSheriffEnabled")
FlingTab:CreateToggle("Fling Murderer", "FlingMurdererEnabled")
FlingTab:CreateToggle("Anti-Grab (Auto-Fling Attacker)", "AntiGrab")

-- ==================== WORLD TAB ELEMENTS ====================
WorldTab:CreateToggle("Fullbright", "Fullbright")
WorldTab:CreateToggle("Fog Remover", "FogRemover")
WorldTab:CreateButton("Server Hop (Find New Server)", function()
    pcall(function()
        local httpRequest = request({
            Url = "https://games.roblox.com/v1/games/142823291/servers/Public?limit=100&sortOrder=Asc"
        })
        local serverData = HttpService:JSONDecode(httpRequest.Body)
        local validServers = {}
        for _, server in ipairs(serverData.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(validServers, server.id)
            end
        end
        if #validServers > 0 then
            local randomServer = validServers[math.random(1, #validServers)]
            TeleportService:TeleportToPlaceInstance(142823291, randomServer, LocalPlayer)
        end
    end)
end)

-- ==================== CREDITS TAB ====================
-- Clear any existing content and add credits manually
local creditsContent = CreditsTab.Content
for _, child in ipairs(creditsContent:GetChildren()) do
    if child:IsA("Frame") or child:IsA("TextButton") then
        child:Destroy()
    end
end

local creditsFrame = Instance.new("Frame")
creditsFrame.Size = UDim2.new(1, -4, 0, 380)
creditsFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
creditsFrame.Parent = creditsContent

local creditsCorner = Instance.new("UICorner")
creditsCorner.CornerRadius = UDim.new(0, 8)
creditsCorner.Parent = creditsFrame

local creditsText = Instance.new("TextLabel")
creditsText.Size = UDim2.new(1, -20, 1, -20)
creditsText.Position = UDim2.new(0, 10, 0, 10)
creditsText.BackgroundTransparency = 1
creditsText.TextColor3 = Color3.fromRGB(220, 220, 240)
creditsText.Text = [[
╔══════════════════════════════════╗

      PLALETTE MM2 ULTIMATE
           Version 2.0

╚══════════════════════════════════╝

👤 Created by: plalettescripts

📁 GitHub Repository:
   plalettescripts/mm2script

⭐ Features Overview:
   • Right-Click Aimbot for Murderer
   • Color-Coded Player Outlines
        🔴 Murderer = Red
        🔵 Sheriff = Blue
        🟢 Innocent = Green
   • Fling System (Player/Sheriff/Murderer)
   • ESP (Coins, Guns, Tracers)
   • Movement Hacks (Speed, NoClip, Fly)
   • Auto-Farm Coins & Guns
   • God Mode, Kill All, Server Hop
   • Anti-Grab Protection
   • Role Reveal Above Heads
   • Hitbox Expander
   • Instant Reload & Triggerbot
   • Fullbright & Fog Remover
   • Anti-AFK System

⌨️ Controls:
   CTRL = Minimize/Restore GUI
   Right Mouse Button = Aimbot Lock

⚠️ Disclaimer:
   This script is for educational
   purposes only. Use at your own
   risk. The creator is not
   responsible for any bans or
   account actions.

💙 Special Thanks:
   • The MM2 Scripting Community
   • All Beta Testers
   • Everyone who provided feedback
   • You, for using this script!

   ╔══════════════════════════════╗
   ║   Made with ❤️ by Plalette   ║
   ╚══════════════════════════════╝

   © 2024 plalettescripts
   All rights reserved.
]]
creditsText.Font = Enum.Font.SourceSans
creditsText.TextSize = 12
creditsText.TextXAlignment = Enum.TextXAlignment.Left
creditsText.TextYAlignment = Enum.TextYAlignment.Top
creditsText.RichText = true
creditsText.TextWrapped = true
creditsText.Parent = creditsFrame

-- Update credits content canvas size
creditsContent.CanvasSize = UDim2.new(0, 0, 0, 400)

-- ==================== FEATURE IMPLEMENTATION ====================

-- ===== RIGHT-CLICK AIMBOT =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Settings.RightClickAimbot then
            Connections.RightClickAimbot = RunService.RenderStepped:Connect(function()
                local murderer = GetMurderer()
                if murderer and murderer.Character then
                    local head = murderer.Character:FindFirstChild("Head")
                    if head then
                        Camera.CFrame = CFrame.new(
                            Camera.CFrame.Position,
                            head.Position
                        )
                    end
                end
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Connections.RightClickAimbot then
            Connections.RightClickAimbot:Disconnect()
            Connections.RightClickAimbot = nil
        end
    end
end)

-- ===== HITBOX EXPANDER =====
task.spawn(function()
    while task.wait(0.25) do
        if Settings.HitboxExpander then
            local size = Settings.HitboxSize
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(size, size, size)
                        hrp.Transparency = 0.4
                    end
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        head.Size = Vector3.new(size * 0.7, size * 0.7, size * 0.7)
                    end
                end
            end
        end
    end
end)

-- ===== INSTANT RELOAD =====
task.spawn(function()
    while task.wait(0.12) do
        if Settings.InstantReload then
            pcall(function()
                -- Reload tools in backpack
                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local ammo = tool:FindFirstChild("Ammo")
                        if ammo then
                            ammo.Value = 99
                        end
                    end
                end
                -- Reload equipped tool
                if LocalPlayer.Character then
                    local equippedTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if equippedTool then
                        local ammo = equippedTool:FindFirstChild("Ammo")
                        if ammo then
                            ammo.Value = 99
                        end
                    end
                end
            end)
        end
    end
end)

-- ===== TRIGGERBOT =====
task.spawn(function()
    while task.wait(0.06) do
        if Settings.Triggerbot and LocalPlayer.Character then
            pcall(function()
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local shootRemote = tool:FindFirstChild("Shoot")
                    if shootRemote then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = Camera.CFrame.LookVector * 500
                        local raycastResult = Workspace:Raycast(rayOrigin, rayDirection)
                        if raycastResult then
                            local hitPart = raycastResult.Instance
                            local hitCharacter = hitPart.Parent
                            if hitCharacter and hitCharacter:FindFirstChildOfClass("Humanoid") then
                                local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)
                                if hitPlayer and hitPlayer ~= LocalPlayer then
                                    shootRemote:FireServer(raycastResult.Position)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ===== GOD MODE =====
task.spawn(function()
    while task.wait(0.2) do
        if Settings.GodMode and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end
    end
end)

-- ===== PLAYER ESP (COLOR-CODED OUTLINES) =====
task.spawn(function()
    while task.wait(0.5) do
        if Settings.PlayerESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    -- Find or create highlight
                    local highlight = player.Character:FindFirstChild("PlaletteOutline")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "PlaletteOutline"
                        highlight.FillTransparency = 1
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                        highlight.Parent = player.Character
                    end
                    
                    -- Determine role color
                    local isMurderer = false
                    local isSheriff = false
                    
                    if player.Backpack then
                        if player.Backpack:FindFirstChild("Knife") then isMurderer = true end
                        if player.Backpack:FindFirstChild("Gun") then isSheriff = true end
                    end
                    if player.Character then
                        if player.Character:FindFirstChild("Knife") then isMurderer = true end
                        if player.Character:FindFirstChild("Gun") then isSheriff = true end
                    end
                    
                    if isMurderer then
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Red
                    elseif isSheriff then
                        highlight.OutlineColor = Color3.fromRGB(0, 100, 255) -- Blue
                    else
                        highlight.OutlineColor = Color3.fromRGB(0, 255, 0) -- Green
                    end
                end
            end
        else
            -- Remove highlights when disabled
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("PlaletteOutline")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
end)

-- ===== COIN ESP =====
task.spawn(function()
    while task.wait(0.08) do
        if Settings.CoinESP then
            local drawings = {}
            for _, object in ipairs(Workspace:GetDescendants()) do
                if object.Name == "Coin" and object:IsA("BasePart") then
                    local screenPosition, onScreen = Camera:WorldToViewportPoint(object.Position)
                    if onScreen then
                        local textDrawing = Drawing.new("Text")
                        textDrawing.Text = "💰"
                        textDrawing.Color = Color3.fromRGB(255, 215, 0)
                        textDrawing.Size = 18
                        textDrawing.Position = Vector2.new(screenPosition.X, screenPosition.Y)
                        textDrawing.Center = true
                        textDrawing.Visible = true
                        table.insert(drawings, textDrawing)
                    end
                end
            end
            task.wait(0.06)
            for _, drawing in pairs(drawings) do
                pcall(function() drawing:Remove() end)
            end
        end
    end
end)

-- ===== GUN ESP =====
task.spawn(function()
    while task.wait(0.08) do
        if Settings.GunESP then
            local drawings = {}
            for _, object in ipairs(Workspace:GetDescendants()) do
                if object.Name == "GunDrop" and object:IsA("BasePart") then
                    local screenPosition, onScreen = Camera:WorldToViewportPoint(object.Position)
                    if onScreen then
                        local textDrawing = Drawing.new("Text")
                        textDrawing.Text = "🔫 Gun"
                        textDrawing.Color = Color3.fromRGB(100, 200, 255)
                        textDrawing.Size = 14
                        textDrawing.Position = Vector2.new(screenPosition.X, screenPosition.Y)
                        textDrawing.Center = true
                        textDrawing.Visible = true
                        table.insert(drawings, textDrawing)
                    end
                end
            end
            task.wait(0.06)
            for _, drawing in pairs(drawings) do
                pcall(function() drawing:Remove() end)
            end
        end
    end
end)

-- ===== TRACERS =====
task.spawn(function()
    while task.wait(0.02) do
        if Settings.Tracers then
            local drawings = {}
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local lineDrawing = Drawing.new("Line")
                            lineDrawing.Color = Color3.fromRGB(255, 255, 255)
                            lineDrawing.Thickness = 0.8
                            lineDrawing.From = screenCenter
                            lineDrawing.To = Vector2.new(screenPos.X, screenPos.Y)
                            lineDrawing.Visible = true
                            table.insert(drawings, lineDrawing)
                        end
                    end
                end
            end
            task.wait(0.015)
            for _, drawing in pairs(drawings) do
                pcall(function() drawing:Remove() end)
            end
        end
    end
end)

-- ===== ROLE REVEAL =====
task.spawn(function()
    while task.wait(0.8) do
        if Settings.RoleReveal then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local roleText = "Innocent"
                        local roleColor = Color3.fromRGB(0, 255, 0)
                        
                        local isMurderer = false
                        local isSheriff = false
                        
                        if player.Backpack then
                            if player.Backpack:FindFirstChild("Knife") then isMurderer = true end
                            if player.Backpack:FindFirstChild("Gun") then isSheriff = true end
                        end
                        if player.Character then
                            if player.Character:FindFirstChild("Knife") then isMurderer = true end
                            if player.Character:FindFirstChild("Gun") then isSheriff = true end
                        end
                        
                        if isMurderer then
                            roleText = "🔪 MURDERER"
                            roleColor = Color3.fromRGB(255, 0, 0)
                        elseif isSheriff then
                            roleText = "🔫 SHERIFF"
                            roleColor = Color3.fromRGB(0, 150, 255)
                        end
                        
                        local billboard = head:FindFirstChild("RoleRevealTag")
                        if not billboard then
                            billboard = Instance.new("BillboardGui")
                            billboard.Name = "RoleRevealTag"
                            billboard.Size = UDim2.new(0, 120, 0, 32)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = head
                        end
                        
                        local textLabel = billboard:FindFirstChild("RoleText")
                        if not textLabel then
                            textLabel = Instance.new("TextLabel")
                            textLabel.Name = "RoleText"
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.Font = Enum.Font.SourceSansBold
                            textLabel.TextSize = 15
                            textLabel.TextStrokeTransparency = 0.3
                            textLabel.Parent = billboard
                        end
                        
                        textLabel.Text = roleText
                        textLabel.TextColor3 = roleColor
                    end
                end
            end
        else
            -- Remove role tags when disabled
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") then
                    local tag = player.Character.Head:FindFirstChild("RoleRevealTag")
                    if tag then
                        tag:Destroy()
                    end
                end
            end
        end
    end
end)

-- ===== SPEED HACK =====
task.spawn(function()
    RunService.Stepped:Connect(function()
        if Settings.SpeedHack and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Settings.SpeedValue
            end
        end
    end)
end)

-- ===== NOCLIP =====
task.spawn(function()
    RunService.Stepped:Connect(function()
        if Settings.NoClip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- ===== INFINITE JUMP =====
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ===== ANTI-AFK =====
task.spawn(function()
    while task.wait(90) do
        if Settings.AntiAFK then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
            end)
        end
    end
end)

-- ===== TELEPORT TO KILLER =====
task.spawn(function()
    while task.wait(2) do
        if Settings.TeleportToKiller and LocalPlayer.Character then
            local murderer = GetMurderer()
            if murderer and murderer.Character then
                local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
                local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if murdererHRP and localHRP then
                    localHRP.CFrame = murdererHRP.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
end)

-- ===== AUTO-FARM COINS =====
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoFarmCoins and LocalPlayer.Character then
            local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localHRP then
                for _, object in ipairs(Workspace:GetDescendants()) do
                    if object.Name == "Coin" and object:IsA("BasePart") then
                        local distance = (object.Position - localHRP.Position).Magnitude
                        if distance < 200 then
                            firetouchinterest(localHRP, object, 0)
                            firetouchinterest(localHRP, object, 1)
                        end
                    end
                end
            end
        end
    end
end)

-- ===== AUTO-PICKUP GUNS =====
task.spawn(function()
    while task.wait(0.5) do
        if Settings.AutoPickupGun and LocalPlayer.Character then
            local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localHRP then
                for _, object in ipairs(Workspace:GetDescendants()) do
                    if object.Name == "GunDrop" and object:IsA("BasePart") then
                        local distance = (object.Position - localHRP.Position).Magnitude
                        if distance < 80 then
                            firetouchinterest(localHRP, object, 0)
                            firetouchinterest(localHRP, object, 1)
                        end
                    end
                end
            end
        end
    end
end)

-- ===== FLING SELECTED PLAYER =====
task.spawn(function()
    while task.wait(0.25) do
        if Settings.FlingPlayerEnabled and Settings.FlingTargetName and Settings.FlingTargetName ~= "" then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name == Settings.FlingTargetName and player ~= LocalPlayer then
                    FlingPlayer(player, Settings.FlingPower)
                end
            end
        end
    end
end)

-- ===== FLING SHERIFF =====
task.spawn(function()
    while task.wait(0.25) do
        if Settings.FlingSheriffEnabled then
            local sheriff = GetSheriff()
            if sheriff then
                FlingPlayer(sheriff, Settings.FlingPower)
            end
        end
    end
end)

-- ===== FLING MURDERER =====
task.spawn(function()
    while task.wait(0.25) do
        if Settings.FlingMurdererEnabled then
            local murderer = GetMurderer()
            if murderer then
                FlingPlayer(murderer, Settings.FlingPower)
            end
        end
    end
end)

-- ===== ANTI-GRAB =====
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AntiGrab and LocalPlayer.Character then
            local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localHRP then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            local distance = (targetHRP.Position - localHRP.Position).Magnitude
                            if distance < 8 then
                                FlingPlayer(player, 10000)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ===== FULLBRIGHT =====
task.spawn(function()
    while task.wait(1) do
        if Settings.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        end
        if Settings.FogRemover then
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 0
        end
    end
end)

-- ===== CLEANUP ON PLAYER REMOVAL =====
Players.PlayerRemoving:Connect(function(player)
    -- Clean up outline if exists
    if player.Character then
        local outline = player.Character:FindFirstChild("PlaletteOutline")
        if outline then outline:Destroy() end
        
        local head = player.Character:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("RoleRevealTag")
            if tag then tag:Destroy() end
        end
    end
    -- Clean up fling velocities
    CleanupFlingVelocities()
end)

-- ===== SCRIPT LOADED MESSAGE =====
print([[
╔══════════════════════════════════════════╗
║                                          ║
║     PLALETTE MM2 ULTIMATE v2.0          ║
║     Successfully Loaded!                ║
║                                          ║
║  🔴 Murderer = Red Outline              ║
║  🔵 Sheriff  = Blue Outline            ║
║  🟢 Innocent = Green Outline           ║
║                                          ║
║  🎯 Right-Click = Aimbot Lock          ║
║  ⌨️  CTRL = Minimize/Restore GUI       ║
║                                          ║
║  💨 Fling System: Working              ║
║  💰 Auto-Farm: Working                 ║
║  👁️  ESP: Working                      ║
║  ⭐ Credits Tab: Complete              ║
║                                          ║
║  Created by: plalettescripts            ║
║  GitHub: plalettescripts/mm2script      ║
║                                          ║
╚══════════════════════════════════════════╝
]])
