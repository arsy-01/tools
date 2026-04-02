local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Pelindung GUI
local targetGui = (gethui and gethui()) or CoreGui

-- 1. SETUP UI MENU UTAMA (Dibuat Lebih Kecil)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MatrixControl"
MainGui.Parent = targetGui
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true -- Memastikan efek menutupi seluruh layar

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 100, 0, 30) -- Ukuran diperkecil
MainFrame.Position = UDim2.new(0.5, -50, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MainFrame.Active = true -- Penting: Mencegah sentuhan tembus ke layar game (kamera tidak ikut geser)
MainFrame.ZIndex = 10
MainFrame.Parent = MainGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Text = "FX: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 12 -- Font diperkecil
ToggleBtn.ZIndex = 11
ToggleBtn.Parent = MainFrame

-- 2. CUSTOM DRAG SYSTEM (Agar kamera game tidak ikut muter saat UI digeser)
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 3. FUNGSI MATRIX EFFECT
local matrixContainer = nil
local isRunning = false
local currentRunId = 0 -- Digunakan untuk mencegah konflik jika tombol ditekan berkali-kali
local chars = "01"

local function getRandomText(len)
    local s = ""
    for i = 1, len do
        s = s .. string.sub(chars, math.random(1, #chars), math.random(1, #chars)) .. "\n"
    end
    return s
end

local function stopMatrix()
    isRunning = false
    currentRunId = currentRunId + 1 
    
    if matrixContainer then
        matrixContainer:Destroy()
        matrixContainer = nil
    end
    
    ToggleBtn.Text = "FX: OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

local function startMatrix()
    if isRunning then return end
    isRunning = true
    
    currentRunId = currentRunId + 1
    local thisRun = currentRunId 
    
    ToggleBtn.Text = "ACTIVE (5s)"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0)

    -- Container Efek
    matrixContainer = Instance.new("Frame")
    matrixContainer.Size = UDim2.new(1, 0, 1, 0)
    matrixContainer.BackgroundTransparency = 1
    matrixContainer.ZIndex = 0 -- Pastikan berada di belakang UI tombol
    matrixContainer.Parent = MainGui

    local columns = 15 
    local labels = {}

    for i = 1, columns do
        local lbl = Instance.new("TextLabel")
        lbl.Parent = matrixContainer
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 16
        lbl.ZIndex = 1
        lbl.Position = UDim2.new((i-1)/columns, 0, math.random(-100, 0)/100, 0)
        lbl.Text = getRandomText(20)
        table.insert(labels, lbl)
    end

    -- Animasi Berjalan
    task.spawn(function()
        while isRunning and currentRunId == thisRun do
            for _, lbl in ipairs(labels) do
                lbl.Position = lbl.Position + UDim2.new(0, 0, 0.02, 0)
                if lbl.Position.Y.Scale > 1 then
                    lbl.Position = UDim2.new(lbl.Position.X.Scale, 0, -0.5, 0)
                end
                if math.random(1, 10) > 8 then
                    lbl.Text = getRandomText(20)
                end
            end
            RunService.RenderStepped:Wait()
        end
    end)

    -- Auto-Off setelah 5 detik
    task.delay(5, function()
        -- Pastikan hanya mematikan jika belum dimatikan manual
        if currentRunId == thisRun then
            stopMatrix()
        end
    end)
end

-- 4. LOGIC TOMBOL
ToggleBtn.MouseButton1Click:Connect(function()
    if not isRunning then
        startMatrix()
    else
        stopMatrix() 
    end
end)
