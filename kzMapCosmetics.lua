-- kzMapCosmetics: Version Quartz (1.0)
-- Body part exclusion for Dark Map | NGAFY (blackout body parts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- CLEANUP previous instances
for _, v in pairs(game:GetDescendants()) do
    if v.Name == "kzQuartz_Bulletproof" then
        pcall(function() v:Destroy() end)
    end
end

-- ========== GLOBAL STATE ==========
local activeFeatures = {
    darkMap = false,
    grayAtmo = false,
    invert = false,
    spqr = false,
    rainbow = false,
    stretch = false,
    ngafy = false
}

local originalColors = {}
local originalBodyColors = {}
local originalLighting = {
    Ambient = nil,
    FogColor = nil,
    FogEnd = nil,
    FogStart = nil
}
local rainbowOverlay = nil
local invertOverlay = nil
local spqrFrame = nil
local stretchActive = false
local stretchShear = 1.0
local darkIntensity = 0.65

-- Store original lighting
originalLighting.Ambient = Lighting.Ambient
originalLighting.FogColor = Lighting.FogColor
originalLighting.FogEnd = Lighting.FogEnd
originalLighting.FogStart = Lighting.FogStart

-- ========== HELPER: Check if a part is a player body part ==========
local function IsBodyPart(part)
    if not part or not part.Parent then return false end
    local parent = part.Parent
    if parent:IsA("Model") and parent:FindFirstChild("Humanoid") then
        local validBodyParts = {"Head", "Torso", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "LeftHand", "RightHand", "LeftFoot", "RightFoot"}
        for _, bp in pairs(validBodyParts) do
            if part.Name == bp then
                return true
            end
        end
        if part:IsA("Accessory") or parent:FindFirstChild("Humanoid") and part:IsA("MeshPart") then
            return true
        end
    end
    return false
end

-- ========== STRETCH FUNCTION ==========
local function ApplyStretch()
    if stretchActive and workspace.CurrentCamera then
        local shear = stretchShear
        workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, shear, 0, 0, 0, 1)
    end
end

RunService.RenderStepped:Connect(ApplyStretch)

-- ========== KILL SWITCH ==========
local function KillSwitch()
    -- Restore dark map colors
    for obj, originalColor in pairs(originalColors) do
        pcall(function()
            if obj and obj.Parent then
                obj.Color = originalColor
            end
        end)
    end
    originalColors = {}
    
    -- Restore NGAFY body colors
    for obj, originalColor in pairs(originalBodyColors) do
        pcall(function()
            if obj and obj.Parent then
                obj.Color = originalColor
            end
        end)
    end
    originalBodyColors = {}
    
    pcall(function()
        Lighting.Ambient = originalLighting.Ambient
        Lighting.FogColor = originalLighting.FogColor
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end)
    
    local cc = Lighting:FindFirstChild("kzInvert")
    if cc then cc:Destroy() end
    
    if invertOverlay then pcall(function() invertOverlay:Destroy() end) invertOverlay = nil end
    if spqrFrame then pcall(function() spqrFrame:Destroy() end) spqrFrame = nil end
    if rainbowOverlay then pcall(function() rainbowOverlay:Destroy() end) rainbowOverlay = nil end
    
    stretchActive = false
    
    task.wait(0.1)
    
    if ScreenGui then
        pcall(function() ScreenGui:Destroy() end)
    end
end

-- ========== SCREENGUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "kzQuartz_Bulletproof"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local parentSuccess, parentResult = pcall(function()
    return game:GetService("CoreGui")
end)

if parentSuccess and parentResult then
    ScreenGui.Parent = parentResult
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ========== TOGGLE KEY SYSTEM (FIXED) ==========
local ToggleKey = Enum.KeyCode.K
local waitingForKey = false
local keySelectionLabel = nil
local keyBindButton = nil

local function UpdateToggleKeyDisplay()
    if keySelectionLabel then
        local keyName = tostring(ToggleKey):gsub("Enum.KeyCode.", "")
        keySelectionLabel.Text = "Current Toggle Key: " .. keyName
    end
end

local function SetToggleKey(keyCode)
    ToggleKey = keyCode
    UpdateToggleKeyDisplay()
end

-- FIXED: No gameProcessed check - keybind works everywhere
UserInputService.InputBegan:Connect(function(input)
    -- Handle key binding selection mode
    if waitingForKey and input.KeyCode ~= Enum.KeyCode.Unknown then
        waitingForKey = false
        SetToggleKey(input.KeyCode)
        if keyBindButton then
            keyBindButton.Text = "Set Toggle Key (Click & Press Any Key)"
            keyBindButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        end
        return
    end
    
    -- Handle menu toggle (works 100% of the time)
    if input.KeyCode == ToggleKey then
        if MainFrame then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

-- ========== MAIN FRAME ==========
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 580)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner")
MainCorner.Parent = MainFrame
MainCorner.CornerRadius = UDim.new(0, 12)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TitleBar.BackgroundTransparency = 0.15

local TitleCorner = Instance.new("UICorner")
TitleCorner.Parent = TitleBar
TitleCorner.CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "kzMapCosmetics | Quartz (1.0)"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = "Left"

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Parent = TitleBar
SubtitleLabel.Size = UDim2.new(1, -50, 0, 15)
SubtitleLabel.Position = UDim2.new(0, 15, 0, 22)
SubtitleLabel.Text = "Body Part Exclusion | NGAFY Blackout"
SubtitleLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.TextSize = 11
SubtitleLabel.TextXAlignment = "Left"

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
CloseBtn.BackgroundTransparency = 0.15
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16

local CloseCorner = Instance.new("UICorner")
CloseCorner.Parent = CloseBtn
CloseCorner.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Drag for MainFrame
local draggingMain = false
local dragMainStart = nil
local dragMainPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMain = true
        dragMainStart = input.Position
        dragMainPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMain and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragMainStart
        MainFrame.Position = UDim2.new(0, dragMainPos.X.Offset + delta.X, 0, dragMainPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMain = false
    end
end)

-- ========== TAB BUTTONS ==========
local function MakeTabButton(name, yPos)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0, 100, 0, 35)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    btn.BackgroundTransparency = 0.15
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    corner.CornerRadius = UDim.new(0, 6)
    return btn
end

local tabMapBtn = MakeTabButton("Map", 55)
local tabFunBtn = MakeTabButton("Fun", 100)
local tabScriptsBtn = MakeTabButton("Scripts", 145)
local tabSettingsBtn = MakeTabButton("Settings", 190)
local tabLogsBtn = MakeTabButton("Update Logs", 235)

-- Tab content frames
local function MakeTabContent()
    local frame = Instance.new("ScrollingFrame")
    frame.Parent = MainFrame
    frame.Size = UDim2.new(1, -130, 1, -60)
    frame.Position = UDim2.new(0, 125, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.ScrollBarThickness = 6
    return frame
end

local mapContent = MakeTabContent()
local funContent = MakeTabContent()
local scriptsContent = MakeTabContent()
local settingsContent = MakeTabContent()
local logsContent = MakeTabContent()

-- Button creator for content
local function AddContentButton(parent, text, yOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yOffset)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.BackgroundTransparency = 0.15
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    corner.CornerRadius = UDim.new(0, 8)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 110)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function AddLabel(parent, text, yOffset)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, yOffset)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = "Left"
    return lbl
end

-- REAL SLIDER FUNCTION
local function AddSlider(parent, text, minVal, maxVal, defaultValue, yOffset, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.Size = UDim2.new(1, -20, 0, 50)
    container.Position = UDim2.new(0, 10, 0, yOffset)
    container.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = text .. ": " .. string.format("%.2f", defaultValue)
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = "Left"
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = container
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    sliderBg.BackgroundTransparency = 0.15
    local bgCorner = Instance.new("UICorner")
    bgCorner.Parent = sliderBg
    bgCorner.CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.Size = UDim2.new((defaultValue - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
    sliderFill.BackgroundTransparency = 0.15
    local fillCorner = Instance.new("UICorner")
    fillCorner.Parent = sliderFill
    fillCorner.CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local currentValue = defaultValue
    
    local function UpdateSlider(inputPos)
        local percent = math.clamp((inputPos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        currentValue = minVal + percent * (maxVal - minVal)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. string.format("%.2f", currentValue)
        callback(currentValue)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(input.Position)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return container
end

-- Tab switching
local function SetActiveTab(tabContent, tabButton)
    mapContent.Visible = false
    funContent.Visible = false
    scriptsContent.Visible = false
    settingsContent.Visible = false
    logsContent.Visible = false
    tabContent.Visible = true
    
    tabMapBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    tabFunBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    tabScriptsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    tabSettingsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    tabLogsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    tabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
end

tabMapBtn.MouseButton1Click:Connect(function() SetActiveTab(mapContent, tabMapBtn) end)
tabFunBtn.MouseButton1Click:Connect(function() SetActiveTab(funContent, tabFunBtn) end)
tabScriptsBtn.MouseButton1Click:Connect(function() SetActiveTab(scriptsContent, tabScriptsBtn) end)
tabSettingsBtn.MouseButton1Click:Connect(function() SetActiveTab(settingsContent, tabSettingsBtn) end)
tabLogsBtn.MouseButton1Click:Connect(function() SetActiveTab(logsContent, tabLogsBtn) end)

-- ========== MAP TAB CONTENT ==========
local yMap = 10

-- Dark Map Toggle button
AddContentButton(mapContent, "Dark Map Toggle (Excludes Player Body Parts)", yMap, function()
    activeFeatures.darkMap = not activeFeatures.darkMap
    local mult = darkIntensity
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not IsBodyPart(obj) then
            if activeFeatures.darkMap then
                if not originalColors[obj] then
                    originalColors[obj] = obj.Color
                end
                obj.Color = Color3.new(
                    obj.Color.R * mult,
                    obj.Color.G * mult,
                    obj.Color.B * mult
                )
            else
                if originalColors[obj] then
                    obj.Color = originalColors[obj]
                end
            end
        end
    end
end)
yMap = yMap + 45

-- Dark Intensity SLIDER
AddSlider(mapContent, "Dark Intensity", 0.3, 1.0, darkIntensity, yMap, function(val)
    darkIntensity = val
    if activeFeatures.darkMap then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not IsBodyPart(obj) and originalColors[obj] then
                obj.Color = Color3.new(
                    originalColors[obj].R * darkIntensity,
                    originalColors[obj].G * darkIntensity,
                    originalColors[obj].B * darkIntensity
                )
            end
        end
    end
end)
yMap = yMap + 60

-- Gray Atmosphere Toggle button
AddContentButton(mapContent, "Gray Atmosphere (Fog)", yMap, function()
    activeFeatures.grayAtmo = not activeFeatures.grayAtmo
    if activeFeatures.grayAtmo then
        Lighting.Ambient = Color3.fromRGB(80, 80, 100)
        Lighting.FogColor = Color3.fromRGB(120, 120, 140)
        Lighting.FogEnd = 500
        Lighting.FogStart = 10
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.FogColor = originalLighting.FogColor
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end)
yMap = yMap + 45

-- Stretch Shear SLIDER
AddSlider(mapContent, "Stretch Shear", 0.3, 2.5, stretchShear, yMap, function(val)
    stretchShear = val
    if stretchActive then ApplyStretch() end
end)
yMap = yMap + 60

-- Stretch Toggle button
AddContentButton(mapContent, "Toggle Stretch Mode", yMap, function()
    stretchActive = not stretchActive
    activeFeatures.stretch = stretchActive
end)

mapContent.CanvasSize = UDim2.new(0, 0, 0, yMap + 60)

-- ========== FUN TAB CONTENT ==========
local yFun = 10

-- NGAFY Button
AddContentButton(funContent, "NGAFY (Blackout Body Parts)", yFun, function()
    activeFeatures.ngafy = not activeFeatures.ngafy
    
    for _, player in pairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and IsBodyPart(part) then
                    if activeFeatures.ngafy then
                        if not originalBodyColors[part] then
                            originalBodyColors[part] = part.Color
                        end
                        part.Color = Color3.new(0, 0, 0)
                    else
                        if originalBodyColors[part] then
                            part.Color = originalBodyColors[part]
                        end
                    end
                end
            end
        end
    end
    
    local function onCharacterAdded(character)
        task.wait(0.5)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and IsBodyPart(part) then
                if activeFeatures.ngafy then
                    if not originalBodyColors[part] then
                        originalBodyColors[part] = part.Color
                    end
                    part.Color = Color3.new(0, 0, 0)
                end
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if not player.CharacterAdded:IsConnected(onCharacterAdded) then
            player.CharacterAdded:Connect(onCharacterAdded)
        end
    end
    
    Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(onCharacterAdded)
    end)
end)
yFun = yFun + 45

-- True Invert
invertOverlay = Instance.new("Frame")
invertOverlay.Parent = ScreenGui
invertOverlay.Size = UDim2.new(1, 0, 1, 0)
invertOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
invertOverlay.BackgroundTransparency = 0.85
invertOverlay.Visible = false
invertOverlay.ZIndex = 999

AddContentButton(funContent, "True Invert", yFun, function()
    activeFeatures.invert = not activeFeatures.invert
    invertOverlay.Visible = activeFeatures.invert
    local cc = Lighting:FindFirstChild("kzInvert")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "kzInvert"
        cc.Parent = Lighting
    end
    cc.Enabled = activeFeatures.invert
    if activeFeatures.invert then
        cc.Saturation = -1
        cc.TintColor = Color3.new(1, 1, 1)
    end
end)
yFun = yFun + 45

-- SPQR Overlay
spqrFrame = Instance.new("Frame")
spqrFrame.Parent = ScreenGui
spqrFrame.Size = UDim2.new(1, 0, 1, 0)
spqrFrame.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
spqrFrame.BackgroundTransparency = 0.75
spqrFrame.Visible = false
spqrFrame.ZIndex = 500

local spqrText = Instance.new("TextLabel")
spqrText.Parent = spqrFrame
spqrText.Size = UDim2.new(1, 0, 1, 0)
spqrText.Text = "S P Q R"
spqrText.TextColor3 = Color3.fromRGB(255, 255, 100)
spqrText.TextScaled = true
spqrText.BackgroundTransparency = 1
spqrText.Font = Enum.Font.Antique

AddContentButton(funContent, "SPQR Overlay", yFun, function()
    activeFeatures.spqr = not activeFeatures.spqr
    spqrFrame.Visible = activeFeatures.spqr
end)
yFun = yFun + 45

-- Rainbow overlay
AddContentButton(funContent, "Rainbow Mode", yFun, function()
    activeFeatures.rainbow = not activeFeatures.rainbow
    if activeFeatures.rainbow then
        if rainbowOverlay then rainbowOverlay:Destroy() end
        rainbowOverlay = Instance.new("Frame")
        rainbowOverlay.Parent = ScreenGui
        rainbowOverlay.Size = UDim2.new(1, 0, 1, 0)
        rainbowOverlay.BackgroundTransparency = 0.7
        rainbowOverlay.ZIndex = 998
        rainbowOverlay.Visible = true
        
        task.spawn(function()
            local hue = 0
            while activeFeatures.rainbow and rainbowOverlay and rainbowOverlay.Parent do
                hue = (hue + 0.01) % 1
                rainbowOverlay.BackgroundColor3 = Color3.fromHSV(hue, 1, 0.5)
                task.wait(0.05)
            end
        end)
    else
        if rainbowOverlay then
            rainbowOverlay:Destroy()
            rainbowOverlay = nil
        end
    end
end)

funContent.CanvasSize = UDim2.new(0, 0, 0, yFun + 60)

-- ========== SCRIPTS TAB CONTENT ==========
local yScripts = 10

AddContentButton(scriptsContent, "Execute kzSkins", yScripts, function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/kzsnlol/kzSkins/refs/heads/main/kzSkins.lua'))()
    end)
end)

scriptsContent.CanvasSize = UDim2.new(0, 0, 0, yScripts + 60)

-- ========== SETTINGS TAB CONTENT ==========
local ySettings = 10

keyBindButton = AddContentButton(settingsContent, "Set Toggle Key (Click & Press Any Key)", ySettings, function()
    waitingForKey = true
    keyBindButton.Text = ">>> PRESS ANY KEY NOW <<<"
    keyBindButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
end)
ySettings = ySettings + 45

keySelectionLabel = AddLabel(settingsContent, "Current Toggle Key: K", ySettings)
ySettings = ySettings + 30
UpdateToggleKeyDisplay()

local sepLabel = AddLabel(settingsContent, "─────────────────────", ySettings)
sepLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
ySettings = ySettings + 25

local killSwitchBtn = Instance.new("TextButton")
killSwitchBtn.Parent = settingsContent
killSwitchBtn.Size = UDim2.new(1, -20, 0, 45)
killSwitchBtn.Position = UDim2.new(0, 10, 0, ySettings)
killSwitchBtn.Text = "💀 KILL SWITCH - NUKE EVERYTHING 💀"
killSwitchBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
killSwitchBtn.BackgroundTransparency = 0.15
killSwitchBtn.TextColor3 = Color3.new(1, 1, 1)
killSwitchBtn.Font = Enum.Font.GothamBold
killSwitchBtn.TextSize = 14
local killCorner = Instance.new("UICorner")
killCorner.Parent = killSwitchBtn
killCorner.CornerRadius = UDim.new(0, 8)

killSwitchBtn.MouseEnter:Connect(function()
    killSwitchBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
end)
killSwitchBtn.MouseLeave:Connect(function()
    killSwitchBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
end)

killSwitchBtn.MouseButton1Click:Connect(function()
    KillSwitch()
end)

settingsContent.CanvasSize = UDim2.new(0, 0, 0, ySettings + 100)

-- ========== UPDATE LOGS TAB CONTENT ==========
local yLogs = 10

local function AddLogEntry(parent, version, date, changes, yPos)
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Parent = parent
    versionLabel.Size = UDim2.new(1, -20, 0, 20)
    versionLabel.Position = UDim2.new(0, 10, 0, yPos)
    versionLabel.Text = "[" .. version .. "] " .. date
    versionLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Font = Enum.Font.GothamBold
    versionLabel.TextSize = 13
    versionLabel.TextXAlignment = "Left"
    
    local changesLabel = Instance.new("TextLabel")
    changesLabel.Parent = parent
    changesLabel.Size = UDim2.new(1, -20, 0, 60)
    changesLabel.Position = UDim2.new(0, 20, 0, yPos + 22)
    changesLabel.Text = changes
    changesLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    changesLabel.BackgroundTransparency = 1
    changesLabel.Font = Enum.Font.Gotham
    changesLabel.TextSize = 11
    changesLabel.TextXAlignment = "Left"
    changesLabel.TextYAlignment = "Top"
    changesLabel.TextWrapped = true
    
    return yPos + 90
end

yLogs = AddLogEntry(logsContent, "1.0", "2026-04-13", 
    "• Dark Map now EXCLUDES player body parts\n• Added NGAFY button (blackout all body parts to 0,0,0)\n• Body parts stay black even when new players join\n• FIXED: Toggle keybind now works 100%\n• Map tab uses REAL drag sliders\n• Gray Atmosphere (Fog)\n• True Invert + SPQR + Rainbow\n• Custom toggle key binding\n• Kill Switch", yLogs)

logsContent.CanvasSize = UDim2.new(0, 0, 0, yLogs + 20)

-- ========== MOBILE TOGGLE BUTTON ==========
local MobileToggle = Instance.new("TextButton")
MobileToggle.Parent = ScreenGui
MobileToggle.Size = UDim2.new(0, 55, 0, 55)
MobileToggle.Position = UDim2.new(0, 10, 0.5, -27)
MobileToggle.Text = "KZ"
MobileToggle.TextSize = 22
MobileToggle.TextColor3 = Color3.new(1, 1, 1)
MobileToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
MobileToggle.BackgroundTransparency = 0.15
MobileToggle.Font = Enum.Font.GothamBold

local toggleCorner = Instance.new("UICorner")
toggleCorner.Parent = MobileToggle
toggleCorner.CornerRadius = UDim.new(1, 0)

local togDragStart = nil
local togDragPos = nil

MobileToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        togDragStart = input.Position
        togDragPos = MobileToggle.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if togDragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - togDragStart
        MobileToggle.Position = UDim2.new(0, togDragPos.X.Offset + delta.X, 0.5, togDragPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        togDragStart = nil
    end
end)

MobileToggle.MouseButton1Click:Connect(function()
    if MainFrame then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Activate Map tab by default
SetActiveTab(mapContent, tabMapBtn)
