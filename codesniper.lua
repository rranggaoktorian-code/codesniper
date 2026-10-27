-- =======================================================
-- TAHAP 1: UJI COBA BACA TEKS & TRIGGER "USE CODE"
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if CoreGui:FindFirstChild("CodeSniperPanel") then
    CoreGui.CodeSniperPanel:Destroy()
end

-- 1. PANEL SEDERHANA UNTUK MELIHAT HASIL BACAAN
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
Title.Text = "🔍 UJI COBA BACA TRIGGER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

-- Kotak Status untuk melihat teks mentah dari game
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 45)
StatusLabel.Position = UDim2.new(0.06, 0, 0.22, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Menunggu teks 'use code'..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

-- Kotak untuk menampilkan hasil kode yang berhasil dipotong
local ResultBox = Instance.new("TextBox")
ResultBox.Size = UDim2.new(0.88, 0, 0, 40)
ResultBox.Position = UDim2.new(0.06, 0, 0.53, 0)
ResultBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ResultBox.PlaceholderText = "Kode hasil ekstrak..."
ResultBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ResultBox.Text = ""
ResultBox.TextColor3 = Color3.fromRGB(241, 196, 15)
ResultBox.TextSize = 14
ResultBox.Font = Enum.Font.SourceSansBold
ResultBox.Parent = Frame

-- Tombol On/Off Uji Coba
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.88, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.06, 0, 0.78, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Text = "MULAI UJI BACA"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = Frame

-- =======================================================
-- LOGIKA PEMBACAAN DAN EKSTRAK TEKS
-- =======================================================
local isTesting = false

ToggleBtn.MouseButton1Click:Connect(function()
    isTesting = not isTesting
    if isTesting then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleBtn.Text = "STOP UJI BACA"
        StatusLabel.Text = "Status: Sedang memantau PlayerGui..."
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleBtn.Text = "MULAI UJI BACA"
        StatusLabel.Text = "Status: Berhenti."
        ResultBox.Text = ""
    end
end)

local function hookTextLabel(obj)
    if obj:IsA("TextLabel") and not obj:IsDescendantOf(ScreenGui) then
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            if not isTesting then return end
            
            local rawText = obj.Text
            local lowerText = rawText:lower()
            
            -- Cek apakah teks mengandung frasa "use code"
            local findPos = lowerText:find("use code")
            if findPos then
                StatusLabel.Text = "Ditemukan: " .. rawText
                
                -- Ambil teks tepat setelah "use code"
                local afterText = rawText:sub(findPos + 8)
                -- Bersihkan spasi/simbol dan jadikan huruf besar
                local cleanCode = afterText:gsub("[^%w]", ""):upper()
                
                if cleanCode ~= "" then
                    ResultBox.Text = cleanCode
                end
            end
        end)
    end
end

PlayerGui.DescendantAdded:Connect(function(obj)
    hookTextLabel(obj)
end)

for _, obj in pairs(PlayerGui:GetDescendants()) do
    hookTextLabel(obj)
end
