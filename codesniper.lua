-- =======================================================
-- AUTO-TRIGGER "USE CODE" SNIPER PANEL
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if CoreGui:FindFirstChild("AutoCodeSniper") then
    CoreGui.AutoCodeSniper:Destroy()
end

-- 1. Membuat Panel GUI Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoCodeSniper"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 220)
Frame.Position = UDim2.new(0.5, -160, 0.4, -110)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

-- Judul Panel
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Title.Text = "⚡ AUTO TRIGGER 'USE CODE'"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

-- Kotak Status Trigger
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 45)
StatusLabel.Position = UDim2.new(0.06, 0, 0.20, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Menunggu trigger 'use code'..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

-- Tombol Manual Redeem (REDDEM CODE NOW)
local RedeemBtn = Instance.new("TextButton")
RedeemBtn.Size = UDim2.new(0.88, 0, 0, 45)
RedeemBtn.Position = UDim2.new(0.06, 0, 0.48, 0)
RedeemBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
RedeemBtn.Text = "REDDEM CODE NOW"
RedeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.TextSize = 14
RedeemBtn.Font = Enum.Font.SourceSansBold
RedeemBtn.Parent = Frame

-- Kotak Input Manual
local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(0.88, 0, 0, 35)
CodeInput.Position = UDim2.new(0.06, 0, 0.75, 0)
CodeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodeInput.PlaceholderText = "Atau ketik manual di sini..."
CodeInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
CodeInput.Text = ""
CodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeInput.TextSize = 13
CodeInput.Font = Enum.Font.SourceSans
CodeInput.Parent = Frame

-- =======================================================
-- LOGIKA REMOTE & SPAM OTOMATIS
-- =======================================================
local function getRemoteEvent()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("redeem") or v.Name:lower():find("code")) then
            return v
        end
    end
    return nil
end

local function executeSpam(codeText)
    local cleanCode = codeText:gsub("%s+", ""):upper()
    local remote = getRemoteEvent()
    
    if remote and cleanCode ~= "" then
        StatusLabel.Text = "🔥 SPAMMING KODE: " .. cleanCode
        task.spawn(function()
            for i = 1, 15 do
                remote:FireServer(cleanCode)
                task.wait(0.01) -- Spam kilat (10 milidetik)
            end
            StatusLabel.Text = "✅ Sukses Spam: " .. cleanCode
        end)
    else
        StatusLabel.Text = "⚠️ RemoteEvent tidak ditemukan!"
    end
end

-- 1. FITUR TRIGGER OTOMATIS BERDASARKAN TEKS DI LAYAR
PlayerGui.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("TextLabel") then
        descendant:GetPropertyChangedSignal("Text"):Connect(function()
            local currentText = descendant.Text
            -- Jika teks mengandung frasa "use code"
            if currentText:lower():find("use code") then
                -- Mengambil teks kode yang ada di belakang kata "use code"
                local extractedCode = currentText:gsub("(?i)use%s*code[:%s]*", "")
                if extractedCode ~= "" then
                    executeSpam(extractedCode)
                end
            end
        end)
    end
end)

-- 2. Tombol Manual (REDDEM CODE NOW)
RedeemBtn.MouseButton1Click:Connect(function()
    executeSpam(CodeInput.Text)
end)