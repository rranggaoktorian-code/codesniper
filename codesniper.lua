-- =======================================================
-- TAHAP 1B: PELACAK GLOBAL (WORKSPACE & PLAYERGUI)
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if CoreGui:FindFirstChild("CodeSniperPanel") then
    CoreGui.CodeSniperPanel:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CodeSniperPanel"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 180)
Frame.Position = UDim2.new(0.5, -160, 0.4, -90)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Title.Text = "🔍 PELACAK TEKS GLOBAL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 45)
StatusLabel.Position = UDim2.new(0.06, 0, 0.22, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Siap melacak teks game..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

local ResultBox = Instance.new("TextBox")
ResultBox.Size = UDim2.new(0.88, 0, 0, 40)
ResultBox.Position = UDim2.new(0.06, 0, 0.53, 0)
ResultBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ResultBox.PlaceholderText = "Teks tertangkap..."
ResultBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ResultBox.Text = ""
ResultBox.TextColor3 = Color3.fromRGB(241, 196, 15)
ResultBox.TextSize = 14
ResultBox.Font = Enum.Font.SourceSansBold
ResultBox.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.88, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.06, 0, 0.78, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Text = "MULAI LACAK GLOBAL"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = Frame

local isTracking = false

ToggleBtn.MouseButton1Click:Connect(function()
    isTracking = not isTracking
    if isTracking then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleBtn.Text = "STOP LACAK"
        StatusLabel.Text = "Status: Melacak Workspace & PlayerGui..."
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleBtn.Text = "MULAI LACAK GLOBAL"
        StatusLabel.Text = "Status: Berhenti."
        ResultBox.Text = ""
    end
end)

local function checkText(obj)
    if obj:IsA("TextLabel") and not obj:IsDescendantOf(ScreenGui) then
        local rawText = obj.Text
        if rawText and rawText ~= "" then
            -- Cetak ke konsol F9 Roblox
            print("[LACAK TEKS]:", rawText)
            
            if rawText:lower():find("use code") then
                StatusLabel.Text = "Ketemu: " .. rawText
                ResultBox.Text = rawText
            end
        end
        
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            if not isTracking then return end
            local newText = obj.Text
            if newText and newText ~= "" then
                print("[PERUBAHAN TEKS]:", newText)
                if newText:lower():find("use code") then
                    StatusLabel.Text = "Ketemu: " .. newText
                    ResultBox.Text = newText
                end
            end
        end)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    if isTracking then
        for _, obj in pairs(Workspace:GetDescendants()) do checkText(obj) end
        for _, obj in pairs(PlayerGui:GetDescendants()) do checkText(obj) end
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    if isTracking then checkText(obj) end
end)

PlayerGui.DescendantAdded:Connect(function(obj)
    if isTracking then checkText(obj) end
end)
