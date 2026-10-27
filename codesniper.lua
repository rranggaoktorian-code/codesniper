-- =======================================================
-- ULTIMATE WORKSPACE & GUI CODE SNIPER
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
Title.Text = "⚡ WORKSPACE CODE SNIPER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.06, 0, 0.20, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Memantau perubahan teks di map..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- Tombol Aktivasi Sniper Utama
local RedeemBtn = Instance.new("TextButton")
RedeemBtn.Size = UDim2.new(0.88, 0, 0, 45)
RedeemBtn.Position = UDim2.new(0.06, 0, 0.43, 0)
RedeemBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
RedeemBtn.Text = "AKTIFKAN AUTO SNIPER"
RedeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.TextSize = 14
RedeemBtn.Font = Enum.Font.SourceSansBold
RedeemBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = RedeemBtn

-- Kotak Tampilan Hasil Kode
local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(0.88, 0, 0, 35)
CodeInput.Position = UDim2.new(0.06, 0, 0.70, 0)
CodeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodeInput.PlaceholderText = "Kode tertangkap muncul di sini..."
CodeInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
CodeInput.Text = ""
CodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeInput.TextSize = 13
CodeInput.Font = Enum.Font.SourceSans
CodeInput.Parent = Frame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = CodeInput

-- =======================================================
-- 2. LOGIKA PENEMBAKAN KE SERVER & TOMBOL SUBMIT GAME
-- =======================================================
local function fireCodeToServer(fullCode)
    local cleanCode = fullCode:gsub("%s+", ""):upper()
    if cleanCode == "" or cleanCode == "USECODE" then return end
    
    -- A. Tembak RemoteEvent
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n = v.Name:lower()
            if n:find("code") or n:find("redeem") or n:find("promo") or n:find("gift") or n:find("submit") then
                pcall(function()
                    v:FireServer(cleanCode)
                end)
            end
        end
    end

    -- B. Masukkan ke TextBox game & klik Submit
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
                        firesignal(guiObj.Activated)
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
    StatusLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
    
    task.spawn(function()
        for i = 1, 25 do
            fireCodeToServer(fullCode)
            task.wait(0.005)
        end
        StatusLabel.Text = "✅ Selesai Spam: " .. fullCode
        StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    end)
end

-- =======================================================
-- 3. PEMANTAUAN WORKSPACE & PLAYERGUI OTOMATIS
-- =======================================================
local isListening = false
local lastProcessedText = ""

RedeemBtn.MouseButton1Click:Connect(function()
    isListening = not isListening
    if isListening then
        RedeemBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        RedeemBtn.Text = "MATIKAN SNIPER"
        StatusLabel.Text = "Status: Memantau teks map & UI..."
        lastProcessedText = ""
    else
        RedeemBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        RedeemBtn.Text = "AKTIFKAN AUTO SNIPER"
        StatusLabel.Text = "Status: Dimatikan."
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if not isListening then return end
    
    -- Memindai Workspace (teks 3D di map) dan PlayerGui
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local rawText = obj.Text
            local cleanText = rawText:gsub("[^%w]", ""):upper()
            
            -- Jika teks berubah dan bukan kata umum seperti "USECODE" atau kosong
            if cleanText ~= "" and cleanText ~= "USECODE" and cleanText ~= lastProcessedText then
                -- Pastikan panjang teks wajar untuk sebuah kode (misal 3 s.d 15 karakter)
                if #cleanText >= 3 and #cleanText <= 15 then
                    lastProcessedText = cleanText
                    CodeInput.Text = cleanText
                    startSpamming(cleanText)
                end
            end
        end
    end
end)
