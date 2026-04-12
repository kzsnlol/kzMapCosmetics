local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICornerMain = Instance.new("UICorner")
local UIStrokeMain = Instance.new("UIStroke")
local GlassBlur = Instance.new("BlurEffect")
local MobileToggle = Instance.new("TextButton")

getgenv().ResValue = 1.0
getgenv().ToggleKey = Enum.KeyCode.K
local GlassColor = Color3.fromRGB(255, 255, 255)
local GlassTrans = 0.8
local DarkColor = Color3.fromRGB(10, 10, 10)
local MainFont = Enum.Font.Highway 
local MobileToggleFont = Enum.Font.FredokaOne
local MapToggled = false
local SpqrToggled = false
local OriginalSettings = {}

local ParentObj = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

ScreenGui.Name = "kzMapCosmetics_Final_Quartz"
ScreenGui.Parent = ParentObj
ScreenGui.ResetOnSpawn = false

GlassBlur.Parent = Lighting
GlassBlur.Size = 20
GlassBlur.Enabled = true

MobileToggle.Name = "MobileToggle"
MobileToggle.Parent = ScreenGui
MobileToggle.Size = UDim2.new(0, 60, 0, 60)
MobileToggle.Position = UDim2.new(0, 10, 0.5, -30)
MobileToggle.BackgroundColor3 = GlassColor
MobileToggle.BackgroundTransparency = 0.5
MobileToggle.Text = "kzX"
MobileToggle.TextColor3 = Color3.fromRGB(30, 30, 30)
MobileToggle.Font = MobileToggleFont
MobileToggle.TextSize = 22
MobileToggle.Draggable = true
MobileToggle.Visible = UserInputService.TouchEnabled 
local CircleCorner = Instance.new("UICorner", MobileToggle)
CircleCorner.CornerRadius = UDim.new(1, 0)

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = GlassColor
MainFrame.BackgroundTransparency = GlassTrans
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

UICornerMain.Parent = MainFrame
UICornerMain.CornerRadius = UDim.new(0, 12)
UIStrokeMain.Parent = MainFrame
UIStrokeMain.Thickness = 2
UIStrokeMain.Transparency = 0.4
UIStrokeMain.Color = Color3.white 

local NavHolder = Instance.new("Frame", MainFrame)
NavHolder.Size = UDim2.new(0, 140, 1, 0)
NavHolder.BackgroundTransparency = 1

local NavLayout = Instance.new("UIListLayout", NavHolder)
NavLayout.Padding = UDim.new(0, 5)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

local NavPadding = Instance.new("UIPadding", NavHolder)
NavPadding.PaddingTop = UDim.new(0, 75)
NavPadding.PaddingLeft = UDim.new(0, 15)

local ContentHolder = Instance.new("Frame", MainFrame)
ContentHolder.Position = UDim2.new(0, 150, 0, 0)
ContentHolder.Size = UDim2.new(1, -150, 1, 0)
ContentHolder.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", MainFrame)
Title.Position = UDim2.new(0, 15, 0, 15)
Title.Size = UDim2.new(0, 120, 0, 20)
Title.BackgroundTransparency = 1
Title.Font = MainFont
Title.Text = "kzMapCosmetics"
Title.TextColor3 = Color3.fromRGB(30, 30, 30)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel", MainFrame)
Subtitle.Position = UDim2.new(0, 15, 0, 35)
Subtitle.Size = UDim2.new(0, 120, 0, 15)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = MainFont
Subtitle.Text = "Version Quartz (1.0)"
Subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local CurrentTabLabel = Instance.new("TextLabel", ContentHolder)
CurrentTabLabel.Position = UDim2.new(0, 15, 0, 25)
CurrentTabLabel.Size = UDim2.new(1, -30, 0, 30)
CurrentTabLabel.BackgroundTransparency = 1
CurrentTabLabel.Font = MainFont
CurrentTabLabel.Text = "MAP"
CurrentTabLabel.TextColor3 = Color3.fromRGB(50, 50, 50)
CurrentTabLabel.TextSize = 24
CurrentTabLabel.TextXAlignment = Enum.TextXAlignment.Left

local function CreateContainer()
    local frame = Instance.new("Frame", ContentHolder)
    frame.Position = UDim2.new(0, 15, 0, 70)
    frame.Size = UDim2.new(1, -30, 1, -85)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return frame
end

local MapContainer = CreateContainer()
local FunContainer = CreateContainer()
local OtherContainer = CreateContainer()
local SettingsContainer = CreateContainer()
local CreditsContainer = CreateContainer()

local function MakeButton(txt, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.white
    btn.BackgroundTransparency = 0.5
    btn.Text = txt
    btn.TextColor3 = Color3.white 
    btn.Font = MainFont
    btn.TextSize = 15
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", btn).Transparency = 0.8
    return btn
end

local function SwitchTab(name, container)
    MapContainer.Visible = false
    FunContainer.Visible = false
    OtherContainer.Visible = false
    SettingsContainer.Visible = false
    CreditsContainer.Visible = false
    container.Visible = true
    CurrentTabLabel.Text = name:upper()
end

local function NavBtn(txt, container)
    local btn = Instance.new("TextButton", NavHolder)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundTransparency = 1
    btn.Text = txt
    btn.Font = MainFont
    btn.TextColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.MouseButton1Click:Connect(function() SwitchTab(txt, container) end)
    return btn
end

NavBtn("Map", MapContainer)
NavBtn("Fun", FunContainer)
NavBtn("kzScripts", OtherContainer)
NavBtn("Settings", SettingsContainer)
NavBtn("Credits", CreditsContainer)

local DarkToggle = MakeButton("Dark Map", MapContainer)
local SliderLabel = Instance.new("TextLabel", MapContainer)
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Stretch: 1.0"
SliderLabel.Font = MainFont

local SliderBack = Instance.new("Frame", MapContainer)
SliderBack.Size = UDim2.new(1, 0, 0, 6)
SliderBack.BackgroundColor3 = Color3.white
SliderBack.BackgroundTransparency = 0.4
local SliderMain = Instance.new("TextButton", SliderBack)
SliderMain.Size = UDim2.new(0, 16, 0, 16)
SliderMain.Position = UDim2.new(0, 0, 0.5, 0)
SliderMain.AnchorPoint = Vector2.new(0, 0.5)
SliderMain.BackgroundColor3 = Color3.white
Instance.new("UICorner", SliderMain)

local ReverseBtn = MakeButton("esrever roloc", FunContainer)
local SpqrBtn = MakeButton("SPQR Overlay", FunContainer)

local TintOverlay = Instance.new("Frame", ScreenGui)
TintOverlay.Size = UDim2.new(1, 0, 1, 0)
TintOverlay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TintOverlay.BackgroundTransparency = 1
TintOverlay.ZIndex = -1

local SpqrText = Instance.new("TextLabel", TintOverlay)
SpqrText.Size = UDim2.new(1, 0, 1, 0)
SpqrText.BackgroundTransparency = 1
SpqrText.Font = Enum.Font.Antique
SpqrText.Text = "SPQR"
SpqrText.TextColor3 = Color3.fromRGB(255, 255, 0)
SpqrText.TextSize = 100
SpqrText.TextTransparency = 1

local SkinBtn = MakeButton("Execute kzSkins", OtherContainer)
local AnimBtn = MakeButton("Execute kzAnims", OtherContainer)

local UnloadBtn = MakeButton("Fully Unload", SettingsContainer)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 180)

local CredText = Instance.new("TextLabel", CreditsContainer)
CredText.Size = UDim2.new(1, 0, 1, 0)
CredText.BackgroundTransparency = 1
CredText.Font = MainFont
CredText.TextSize = 16
CredText.TextColor3 = Color3.fromRGB(40, 40, 40)
CredText.TextWrapped = true
CredText.Text = "Created By kzsn\n\nJoin .gg/DbdVfuf6Zv For More Scripts"

DarkToggle.MouseButton1Click:Connect(function()
    MapToggled = not MapToggled
    DarkToggle.TextColor3 = MapToggled and Color3.fromRGB(180, 180, 180) or Color3.white
    for _, p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.Size.Magnitude > 5 and not p:FindFirstAncestorOfClass("Tool") then
            if MapToggled then
                OriginalSettings[p] = {C = p.Color, M = p.Material}
                p.Material, p.Color = Enum.Material.SmoothPlastic, DarkColor
            elseif OriginalSettings[p] then
                p.Color, p.Material = OriginalSettings[p].C, OriginalSettings[p].M
            end
        end
    end
end)

ReverseBtn.MouseButton1Click:Connect(function()
    for _, p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Color = Color3.new(1 - p.Color.R, 1 - p.Color.G, 1 - p.Color.B)
        end
    end
end)

SpqrBtn.MouseButton1Click:Connect(function()
    SpqrToggled = not SpqrToggled
    TintOverlay.BackgroundTransparency = SpqrToggled and 0.5 or 1
    SpqrText.TextTransparency = SpqrToggled and 0.5 or 1
end)

SkinBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/kzsnlol/kzSkins/refs/heads/main/kzSkins.lua'))() end)
AnimBtn.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/kzsnlol/kzAnim/refs/heads/main/kzAnim.lua"))() end)

local dragging = false
local function UpdateSlider(input)
    local relativePos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
    SliderMain.Position = UDim2.new(relativePos, 0, 0.5, 0)
    getgenv().ResValue = 1.0 - (relativePos * 0.9)
    SliderLabel.Text = "Stretch: " .. string.format("%.2f", getgenv().ResValue)
end

SliderMain.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end
end)

local function ToggleMenu()
    MainFrame.Visible = not MainFrame.Visible
    GlassBlur.Size = MainFrame.Visible and 20 or 0
end

MobileToggle.MouseButton1Click:Connect(ToggleMenu)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == getgenv().ToggleKey then ToggleMenu() end
end)

UnloadBtn.MouseButton1Click:Connect(function()
    GlassBlur:Destroy()
    getgenv().ResValue = 1.0
    getgenv().ResLoopStarted = false
    ScreenGui:Destroy()
end)

if not getgenv().ResLoopStarted then
    getgenv().ResLoopStarted = true
    RunService.RenderStepped:Connect(function()
        if not getgenv().ResLoopStarted then return end
        workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0,0,0,1,0,0,0,getgenv().ResValue,0,0,0,1)
    end)
end

SwitchTab("Map", MapContainer)
