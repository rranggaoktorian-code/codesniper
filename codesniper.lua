-- =======================================================
-- REAL-TIME FRAGMENTED CODE SNIPER & AUTO SPAMMER
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if CoreGui:FindFirstChild("CodeSniperPanel") then
    CoreGui.CodeSniperPanel:Destroy()
end

-- 1. DESAIN PANEL UTAMA
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
Title.Text = "⚡ LIVE FRAGMENT SNIPER (USE CODE)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.06, 0, 0.20, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Menunggu potongan kode..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

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

local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(0.88, 0, 0, 35)
CodeInput.Position = UDim2.new(0.06, 0, 0.70, 0)
CodeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodeInput.PlaceholderText = "Hasil gabungan kode..."
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
-- 2. FUNGSI EKSEKUSI SPAM KE SERVER / UI GAME
-- =======================================================
local function fireCodeToServer(fullCode)
    local cleanCode = fullCode:gsub("%s+", ""):upper()
    if cleanCode == "" then return end
    
    -- Jalur 1: Cari RemoteEvent
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("code") or n:find("redeem") or n:find("submit") then
                pcall(function()
                    if v:IsA("RemoteEvent") then
                        v:FireServer(cleanCode)
                    else
                        v:InvokeServer(cleanCode)
                    end
                end)
            end
        end
    end
    
    -- Jalur 2: Masukkan ke TextBox game dan klik Submit otomatis
    pcall(function()
        for _, guiObj in pairs(PlayerGui:GetDescendants()) do
            if guiObj:IsA("TextBox") and (guiObj.Name:lower():find("code") or guiObj.PlaceholderText:lower():find("code")) then
                guiObj.Text = cleanCode
            end
            if guiObj:IsA("TextButton") and guiObj.Text:lower():find("submit") then
                for _, conn in pairs(getconnections(guiObj.MouseButton1Click)) do
                    conn:Fire()
                end
            end
        end
    end)
end

local function startSpamming(fullCode)
    StatusLabel.Text = "🔥 SPAM KODE: " .. fullCode
    StatusLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
    
    task.spawn(function()
        for i = 1, 20 do -- Spam sebanyak 20 kali kilat
            fireCodeToServer(fullCode)
            task.wait(0.005) -- Jeda super cepat (5 milidetik)
        end
        StatusLabel.Text = "✅ Selesai Spam: " .. fullCode
        StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    end)
end

-- =======================================================
-- 3. LOGIKA PENGGABUNGAN FRAGMEN KATA BERURUTAN
-- =======================================================
local accumulatedText = ""
local isListening = false

RedeemBtn.MouseButton1Click:Connect(function()
    isListening = not isListening
    if isListening then
        RedeemBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        RedeemBtn.Text = "MATIKAN SNIPER"
        StatusLabel.Text = "Status: Memantau fragmen 'use code'..."
    else
        RedeemBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        RedeemBtn.Text = "AKTIFKAN AUTO SNIPER"
        StatusLabel.Text = "Status: Dimatikan."
        accumulatedText = ""
    end
end)

-- Memantau perubahan teks secara real-time
game:GetService("RunService").Heartbeat:Connect(function()
    if not isListening then return end
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local rawText = obj.Text
            if rawText:lower():find("use code") then
                -- Ambil bagian setelah kata "use code"
                local fragment = rawText:gsub("(?i).*use%s*code[:%s]*", "")
                fragment = fragment:gsub("%s+", "") -- Buang spasi di dalam fragmen
                
                if fragment ~= "" and fragment ~= accumulatedText then
                    -- Jika ada potongan baru, gabungkan dengan yang sebelumnya tanpa spasi
                    accumulatedText = accumulatedText .. fragment
                    CodeInput.Text = accumulatedText
                    
                    -- Langsung jalankan spam gabungan kalimat tersebut secara instan
                    startSpamming(accumulatedText)
                    
                    -- Beri jeda singkat agar tidak menumpuk teks lama
                    task.wait(1)
                end
            end
        end
    end
end)
