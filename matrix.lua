local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Pelindung GUI agar tidak terdeteksi (Support Delta/Executor lain)
local targetGui = (gethui and gethui()) or CoreGui

-- 1. SETUP UI MENU UTAMA
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MatrixControl"
MainGui.Parent = targetGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 50)
MainFrame.Position = UDim2.new(0.5, -75, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa digeser
MainFrame.Parent = MainGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.7, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "Hacker FX: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

-- 2. FUNGSI MATRIX EFFECT
local matrixContainer = nil
local isRunning = false
local chars = "01" -- Menggunakan 01 agar lebih ringan, bisa ditambah karakter lain

local function getRandomText(len)
    local s = ""
    for i = 1, len do
        s = s .. string.sub(chars, math.random(1, #chars), math.random(1, #chars)) .. "\n"
    end
    return s
end

local function stopMatrix()
    isRunning = false
    if matrixContainer then
        matrixContainer:Destroy()
        matrixContainer = nil
    end
    ToggleBtn.Text = "Hacker FX: OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

local function startMatrix()
    if isRunning then return end
    isRunning = true
    
    ToggleBtn.Text = "ACTIVE (5s)"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0)

    -- Container Efek
    matrixContainer = Instance.new("Frame")
    matrixContainer.Size = UDim2.new(1, 0, 1, 0)
    matrixContainer.BackgroundTransparency = 1
    matrixContainer.Parent = MainGui
    matrixContainer.ZIndex_Order = -1 -- Di belakang tombol

    local columns = 15 -- Jumlah kolom dikurangi agar ringan
    local labels = {}

    for i = 1, columns do
        local lbl = Instance.new("TextLabel")
        lbl.Parent = matrixContainer
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 16
        lbl.Position = UDim2.new((i-1)/columns, 0, math.random(-100, 0)/100, 0)
        lbl.Text = getRandomText(20)
        table.insert(labels, lbl)
    end

    -- Animasi Berjalan
    task.spawn(function()
        local startTime = tick()
        while isRunning and (tick() - startTime < 5) do
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
        stopMatrix()
    end)
end

-- 3. LOGIC TOMBOL
ToggleBtn.MouseButton1Click:Connect(function()
    if not isRunning then
        startMatrix()
    else
        stopMatrix() -- Jika diklik saat sedang jalan, langsung off
    end
end)
