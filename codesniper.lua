-- =======================================================
-- SEQUENTIAL FRAGMENT SNIPER (HANDLE PAUSE PER KALIMAT)
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
Frame.Size = UDim2.new(0, 320, 0, 200)
Frame.Position = UDim2.new(0.5, -160, 0.4, -100)
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
Title.Text = "⚡ SEQUENTIAL SNIPER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.06, 0, 0.20, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Menunggu trigger 'use code'..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

local RedeemBtn = Instance.new("TextButton")
RedeemBtn.Size = UDim2.new(0.88, 0, 0, 45)
RedeemBtn.Position = UDim2.new(0.06, 0, 0.45, 0)
RedeemBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
RedeemBtn.Text = "AKTIFKAN AUTO SNIPER"
RedeemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedeemBtn.TextSize = 14
RedeemBtn.Font = Enum.Font.SourceSansBold
RedeemBtn.Parent = Frame

local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(0.88, 0, 0, 35)
CodeInput.Position = UDim2.new(0.06, 0, 0.72, 0)
CodeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodeInput.PlaceholderText = "Gabungan kode berurutan..."
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
    StatusLabel.Text = "🔥 SPAM GABUNGAN: " .. fullCode
    task.spawn(function()
        for i = 1, 15 do
            fireCodeToServer(fullCode)
            task.wait(0.01)
        end
        StatusLabel.Text = "✅ Selesai Spam: " + fullCode
    end)
end

-- =======================================================
-- 3. SISTEM TANGKAP BERUNTUN (MULTI-LINE PAUSE HANDLER)
-- =======================================================
local isListening = false
local accumulatedCode = ""
local isCollecting = false
local expireTime = 0
local COLLECTION_WINDOW = 8 -- Batas waktu jeda antar kalimat (detik)

RedeemBtn.MouseButton1Click:Connect(function()
    isListening = not isListening
    if isListening then
        RedeemBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        RedeemBtn.Text = "MATIKAN SNIPER"
        StatusLabel.Text = "Status: Siaga memantau kalimat..."
        accumulatedCode = ""
        isCollecting = false
    else
        RedeemBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        RedeemBtn.Text = "AKTIFKAN AUTO SNIPER"
        StatusLabel.Text = "Status: Dimatikan."
        accumulatedCode = ""
        isCollecting = false
    end
end)

local function hookTextLabel(obj)
    if obj:IsA("TextLabel") and not obj:IsDescendantOf(ScreenGui) then
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            if not isListening then return end
            local txt = obj.Text
            local lower = txt:lower()
            local currentTime = tick()

            -- SKenario A: Menemukan kalimat utama "use code"
            if lower:find("use code") then
                isCollecting = true
                expireTime = currentTime + COLLECTION_WINDOW
                accumulatedCode = "" -- Reset untuk kode baru
                
                -- Ambil sisa teks di baris yang sama jika ada
                local fragment = txt:gsub("(?i).*use%s*code[:%s]*", ""):gsub("[^%w]", ""):upper()
                if fragment ~= "" and fragment ~= "USECODE" then
                    accumulatedCode = accumulatedCode .. fragment
                    CodeInput.Text = accumulatedCode
                    startSpamming(accumulatedCode)
                end
                
            -- Skenario B: Kalimat lanjutan berikutnya (meskipun tidak ada kata "use code") selama dalam jeda waktu
            elseif isCollecting then
                if currentTime <= expireTime then
                    local fragment = txt:gsub("[^%w]", ""):upper()
                    if fragment ~= "" and fragment ~= "USECODE" then
                        -- Gabungkan jika bukan fragmen duplikat yang sama persis
                        if accumulatedCode:sub(-#fragment) ~= fragment then
                            accumulatedCode = accumulatedCode .. fragment
                            CodeInput.Text = accumulatedCode
                            startSpamming(accumulatedCode)
                            -- Perpanjang waktu tunggu untuk kalimat berikutnya
                            expireTime = currentTime + COLLECTION_WINDOW
                        end
                    end
                else
                    isCollecting = false
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
