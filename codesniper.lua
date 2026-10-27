-- =======================================================
-- ULTIMATE REMOTE & CHAT MESSAGE SNIPER
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if CoreGui:FindFirstChild("CodeSniperPanel") then
    CoreGui.CodeSniperPanel:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CodeSniperPanel"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 210)
Frame.Position = UDim2.new(0.5, -160, 0.4, -105)
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
Title.Text = "⚡ ULTIMATE EVENT SNIPER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 35)
StatusLabel.Position = UDim2.new(0.06, 0, 0.18, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Siap menyadap event game..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(0.88, 0, 0, 35)
CodeInput.Position = UDim2.new(0.06, 0, 0.42, 0)
CodeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodeInput.PlaceholderText = "Kode tertangkap..."
CodeInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
CodeInput.Text = ""
CodeInput.TextColor3 = Color3.fromRGB(241, 196, 15)
CodeInput.TextSize = 13
CodeInput.Font = Enum.Font.SourceSansBold
CodeInput.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.88, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.06, 0, 0.60, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Text = "AKTIFKAN AUTO SNIPER"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = Frame

local ManualInput = Instance.new("TextBox")
ManualInput.Size = UDim2.new(0.88, 0, 0, 30)
ManualInput.Position = UDim2.new(0.06, 0, 0.82, 0)
ManualInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ManualInput.PlaceholderText = "Ketik manual lalu Enter..."
ManualInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ManualInput.Text = ""
ManualInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualInput.TextSize = 12
ManualInput.Font = Enum.Font.SourceSans
ManualInput.Parent = Frame

-- Fungsi Eksekusi
local function fireCodeToServer(fullCode)
    local cleanCode = fullCode:gsub("%s+", ""):upper()
    if cleanCode == "" or #cleanCode > 20 then return end
    
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(cleanCode) end)
        end
    end

    pcall(function()
        for _, guiObj in pairs(PlayerGui:GetDescendants()) do
            if guiObj:IsA("TextBox") then
                local placeholder = guiObj.PlaceholderText:lower()
                if placeholder:find("code") or placeholder:find("here") then
                    guiObj.Text = cleanCode
                end
            end
            if guiObj:IsA("TextButton") then
                local btnText = guiObj.Text:lower()
                if btnText:find("submit") or btnText:find("redeem") then
                    if firesignal then
                        firesignal(guiObj.MouseButton1Click)
                    else
                        for _, conn in pairs(getconnections(guiObj.MouseButton1Click)) do
                            conn:Fire()
                        end
                    end
                end
            end
        end
    end)
end

local function startSpamming(code)
    StatusLabel.Text = "🔥 SPAM KODE: " .. code
    task.spawn(function()
        for i = 1, 15 do
            fireCodeToServer(code)
            task.wait(0.01)
        end
        StatusLabel.Text = "✅ Selesai Spam: " .. code
    end)
end

local isListening = false
ToggleBtn.MouseButton1Click:Connect(function()
    isListening = not isListening
    if isListening then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleBtn.Text = "MATIKAN SNIPER"
        StatusLabel.Text = "Status: Menyadap event server..."
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleBtn.Text = "AKTIFKAN AUTO SNIPER"
        StatusLabel.Text = "Status: Dimatikan."
    end
end)

-- Menyimak semua komunikasi RemoteEvent dari Server ke Client
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        v.OnClientEvent:Connect(function(...)
            if not isListening then return end
            local args = {...}
            for _, arg in ipairs(args) do
                if type(arg) == "string" then
                    print("[REMOTE EVENT DATA]:", arg)
                    if arg:lower():find("use code") or #arg >= 3 and #arg <= 15 then
                        local clean = arg:gsub("[^%w]", ""):upper()
                        if clean ~= "" and clean ~= "USECODE" then
                            CodeInput.Text = clean
                            startSpamming(clean)
                        end
                    end
                end
            end
        end)
    end
end

ManualInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and ManualInput.Text ~= "" then
        startSpamming(ManualInput.Text)
    end
end)
