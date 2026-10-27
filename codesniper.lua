-- =======================================================
-- LIGHTWEIGHT & LAG-FREE "USE CODE" SNIPER
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if CoreGui:FindFirstChild("CodeSniperPanel") then
    CoreGui.CodeSniperPanel:Destroy()
end

-- 1. PEMBUATAN PANEL GUI
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
Title.Text = "⚡ LIGHTWEIGHT SNIPER (NO LAG)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.06, 0, 0.20, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Siaga (Anti-Ngeframe)..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

local RedeemBtn = Instance.new("TextButton")
RedeemBtn.Size = UDim2.new(0.88, 0, 0, 45)
RedeemBtn.Position = UDim2.new(0.06, 0, 0.43, 0)
RedeemBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
RedeemBtn.Text = "AKTIFKAN AUTO SNIPER"
RedeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.TextSize = 14
RedeemBtn.Font = Enum.Font.SourceSansBold
RedeemBtn.Parent = Frame

local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(0.88, 0, 0, 35)
CodeInput.Position = UDim2.new(0.06, 0, 0.70, 0)
CodeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodeInput.PlaceholderText = "Kode tertangkap..."
CodeInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
CodeInput.Text = ""
CodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeInput.TextSize = 13
CodeInput.Font = Enum.Font.SourceSans
CodeInput.Parent = Frame

-- =======================================================
-- 2. LOGIKA PENEMBAKAN KE SERVER & TOMBOL SUBMIT
-- =======================================================
local function fireCodeToServer(fullCode)
    local cleanCode = fullCode:gsub("%s+", ""):upper()
    if cleanCode == "" or cleanCode == "USECODE" then return end
    
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("code") or n:find("redeem") or n:find("promo") or n:find("gift") or n:find("submit") then
                pcall(function() v:FireServer(cleanCode) end)
            end
        end
    end

    pcall(function()
        for _, guiObj in pairs(PlayerGui:GetDescendants()) do
            if guiObj:IsA("TextBox") then
                local name = guiObj.Name:lower()
                local placeholder = guiObj.PlaceholderText:lower()
                if name:find("code") or placeholder:find("code") or placeholder:find("here") then
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

local function startSpamming(fullCode)
    StatusLabel.Text = "🔥 SPAM SUBMIT: " .. fullCode
    task.spawn(function()
        for i = 1, 20 do
            fireCodeToServer(fullCode)
            task.wait(0.005)
        end
        StatusLabel.Text = "✅ Selesai Spam: " .. fullCode
    end)
end

-- =======================================================
-- 3. PEMANTAUAN BERBASIS EVENT (SUPER RINGAN, TANPA LAG)
-- =======================================================
local isListening = false
local connections = {}

local function watchTextLabel(textLabel)
    local conn = textLabel:GetPropertyChangedSignal("Text"):Connect(function()
        if not isListening then return end
        local rawText = textLabel.Text
        local cleanText = rawText:gsub("[^%w]", ""):upper()
        
        if cleanText ~= "" and cleanText ~= "USECODE" then
            if #cleanText >= 3 and #cleanText <= 15 then
                CodeInput.Text = cleanText
                startSpamming(cleanText)
            end
        end
    end)
    table.insert(connections, conn)
end

RedeemBtn.MouseButton1Click:Connect(function()
    isListening = not isListening
    if isListening then
        RedeemBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        RedeemBtn.Text = "MATIKAN SNIPER"
        StatusLabel.Text = "Status: Memantau teks (Ringan)..."
        
        -- Pasang pengamat pada setiap TextLabel yang ada di Workspace & PlayerGui
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("TextLabel") then
                watchTextLabel(obj)
            end
        end
        for _, obj in pairs(PlayerGui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                watchTextLabel(obj)
            end
        end
    else
        RedeemBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        RedeemBtn.Text = "AKTIFKAN AUTO SNIPER"
        StatusLabel.Text = "Status: Dimatikan."
        -- Bersihkan koneksi saat dimatikan
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        connections = {}
    end
end)

-- Menangkap TextLabel baru yang muncul di kemudian hari
Workspace.DescendantAdded:Connect(function(obj)
    if isListening and obj:IsA("TextLabel") then
        watchTextLabel(obj)
    end
end)

PlayerGui.DescendantAdded:Connect(function(obj)
    if isListening and obj:IsA("TextLabel") then
        watchTextLabel(obj)
    end
end)
