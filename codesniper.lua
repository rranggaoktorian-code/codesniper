-- =======================================================
-- FINAL CLEAN FILTER CODE SNIPER
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
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
Frame.Size = UDim2.new(0, 320, 0, 220)
Frame.Position = UDim2.new(0.5, -160, 0.4, -110)
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
Title.Text = "⚡ CLEAN CODE SNIPER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 35)
StatusLabel.Position = UDim2.new(0.06, 0, 0.18, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Menunggu kode bersih..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(0.88, 0, 0, 35)
CodeInput.Position = UDim2.new(0.06, 0, 0.42, 0)
CodeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodeInput.PlaceholderText = "Kode bersih..."
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
ManualInput.PlaceholderText = "Atau ketik manual di sini..."
ManualInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ManualInput.Text = ""
ManualInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualInput.TextSize = 12
ManualInput.Font = Enum.Font.SourceSans
ManualInput.Parent = Frame

-- Fungsi Tembak Server & Submit Game
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
    StatusLabel.Text = "🔥 SPAM KODE: " + code
    task.spawn(function()
        for i = 1, 15 do
            fireCodeToServer(code)
            task.wait(0.01)
        end
        StatusLabel.Text = "✅ Selesai Spam: " + code
    end)
end

-- Listener Utama
local isListening = false
ToggleBtn.MouseButton1Click:Connect(function()
    isListening = not isListening
    if isListening then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleBtn.Text = "MATIKAN SNIPER"
        StatusLabel.Text = "Status: Memantau teks bersih..."
        CodeInput.Text = ""
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleBtn.Text = "AKTIFKAN AUTO SNIPER"
        StatusLabel.Text = "Status: Dimatikan."
    end
end)

-- Fungsi Pembersih Teks Ekstrem (Membuang Tag HTML & Karakter Sampah)
local function cleanGameText(txt)
    -- Hapus tag HTML Roblox seperti <font color="..."> dll
    local noHtml = txt:gsub("<[^<>]+>", "")
    -- Ambil hanya huruf dan angka, ubah ke kapital
    local result = noHtml:gsub("[^%w]", ""):upper()
    return result
end

local function hookText(obj)
    if obj:IsA("TextLabel") and not obj:IsDescendantOf(ScreenGui) then
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            if not isListening then return end
            local txt = obj.Text
            if txt and txt ~= "" then
                local lower = txt:lower()
                -- Filter ketat: Pastikan teks mengandung "use code" dan panjangnya masuk akal
                if lower:find("use code") and #txt < 100 then
                    -- Buang kalimat "use code", ambil sisanya
                    local afterUseCode = txt:gsub("(?i).*use%s*code[:%s]*", "")
                    local finalCode = cleanGameText(afterUseCode)
                    
                    if finalCode ~= "" and #finalCode >= 3 and #finalCode <= 15 then
                        CodeInput.Text = finalCode
                        startSpamming(finalCode)
                    end
                end
            end
        end)
    end
end

for _, obj in pairs(Workspace:GetDescendants()) do hookText(obj) end
for _, obj in pairs(PlayerGui:GetDescendants()) do hookText(obj) end

Workspace.DescendantAdded:Connect(function(obj) if isListening then hookText(obj) end end)
PlayerGui.DescendantAdded:Connect(function(obj) if isListening then hookText(obj) end end)

ManualInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and ManualInput.Text ~= "" then
        startSpamming(ManualInput.Text)
    end
end)
