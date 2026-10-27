-- =======================================================
-- UJI COBA EKSTRAK LANJUTAN (STEP-BY-STEP)
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
Title.Text = "🔍 DEBUG EKSTRAK KODE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.88, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.06, 0, 0.20, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Status: Menunggu 'use code'..."
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

local ResultBox = Instance.new("TextBox")
ResultBox.Size = UDim2.new(0.88, 0, 0, 35)
ResultBox.Position = UDim2.new(0.06, 0, 0.50, 0)
ResultBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ResultBox.PlaceholderText = "Kode murni muncul di sini..."
ResultBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
ResultBox.Text = ""
ResultBox.TextColor3 = Color3.fromRGB(241, 196, 15)
ResultBox.TextSize = 13
ResultBox.Font = Enum.Font.SourceSansBold
ResultBox.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.88, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.06, 0, 0.73, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Text = "MULAI TES EKSTRAK"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = Frame

local isRunning = false
local waitingForCode = false
local collectedCode = ""

ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        ToggleBtn.Text = "STOP TES"
        StatusLabel.Text = "Status: Memantau teks masuk..."
        collectedCode = ""
        waitingForCode = false
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ToggleBtn.Text = "MULAI TES EKSTRAK"
        StatusLabel.Text = "Status: Berhenti."
        ResultBox.Text = ""
    end
end)

local function hookText(obj)
    if obj:IsA("TextLabel") and not obj:IsDescendantOf(ScreenGui) then
        local function evaluateText(rawText)
            if not isRunning or not rawText or rawText == "" then return end
            
            local lower = rawText:lower()
            print("[DEBUG TEXT]:", rawText)
            
            -- Jika baris ini mengandung "use code"
            if lower:find("use code") then
                waitingForCode = true
                collectedCode = ""
                StatusLabel.Text = "Trigger 'use code' terlihat! Menunggu kodenya..."
                
                -- Cek apakah kodenya langsung ada di baris yang sama setelah "use code"
                local after = rawText:gsub("(?i).*use%s*code[:%s]*", ""):gsub("[^%w]", ""):upper()
                if after ~= "" and after ~= "USECODE" then
                    collectedCode = after
                    ResultBox.Text = collectedCode
                    StatusLabel.Text = "Dapat kode langsung: " .. collectedCode
                    waitingForCode = false
                end
                
            -- Jika sebelumnya sudah menangkap "use code", baris teks berikutnya adalah kodenya
            elseif waitingForCode then
                local cleanFragment = rawText:gsub("[^%w]", ""):upper()
                if cleanFragment ~= "" and cleanFragment ~= "USECODE" then
                    collectedCode = collectedCode .. cleanFragment
                    ResultBox.Text = collectedCode
                    StatusLabel.Text = "Kode terkumpul: " .. collectedCode
                    -- Selesai mengumpulkan setelah mendapatkan potongan teks
                    task.delay(1, function()
                        waitingForCode = false
                    end)
                end
            end
        end

        evaluateText(obj.Text)
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            evaluateText(obj.Text)
        end)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        for _, obj in pairs(Workspace:GetDescendants()) do hookText(obj) end
        for _, obj in pairs(PlayerGui:GetDescendants()) do hookText(obj) end
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    if isRunning then hookText(obj) end
end)

PlayerGui.DescendantAdded:Connect(function(obj)
    if isRunning then hookText(obj) end
end)
