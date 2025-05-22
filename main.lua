--[[
Gang Hub | Grow a Garden (Universal Version)
Script made by: @SkibidiScript
Safe GUI, No executor check, No kick abuse
]]

-- Don't run in Roblox Studio
if game:GetService("RunService"):IsStudio() then
    return
end

-- Safe remote firing with delay
local lastFired = 0
local function safeFire(remote, ...)
    if tick() - lastFired >= 1 then
        lastFired = tick()
        remote:FireServer(...)
    end
end

local function randomWait(min, max)
    task.wait(math.random(min * 100, max * 100) / 100)
end

-- Check if game has expected structure
if not workspace:FindFirstChild("Plants") or not game.ReplicatedStorage:FindFirstChild("BuySeed") then
    warn("Unexpected game structure. Exiting script.")
    return
end

-- GUI Setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowSafeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0

-- Rainbow Label
local RainbowText = Instance.new("TextLabel", Frame)
RainbowText.Size = UDim2.new(1, 0, 0, 30)
RainbowText.Position = UDim2.new(0, 0, 0, 0)
RainbowText.Text = "Script Made By: @SkibidiScript"
RainbowText.TextScaled = true
RainbowText.BackgroundTransparency = 1
RainbowText.Font = Enum.Font.SourceSansBold

task.spawn(function()
    while RainbowText.Parent do
        for h = 0, 1, 0.01 do
            RainbowText.TextColor3 = Color3.fromHSV(h, 1, 1)
            task.wait(0.05)
        end
    end
end)

-- Button helper
local function makeButton(text, yPos, onClick)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(function()
        randomWait(0.3, 0.6)
        pcall(onClick)
    end)
end

-- TextBox for Seed Name
local SeedBox = Instance.new("TextBox", Frame)
SeedBox.Size = UDim2.new(0.9, 0, 0, 40)
SeedBox.Position = UDim2.new(0.05, 0, 0, 200)
SeedBox.PlaceholderText = "Type seed name here..."
SeedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SeedBox.TextColor3 = Color3.fromRGB(255, 0, 0)
SeedBox.Font = Enum.Font.SourceSansBold
SeedBox.TextScaled = true

-- Buttons
makeButton("Auto correct full fruits", 40, function()
    for _, plant in pairs(workspace.Plants:GetChildren()) do
        if plant:FindFirstChild("Owner") and plant.Owner.Value == LocalPlayer.Name then
            local harvest = plant:FindFirstChild("Harvest")
            if harvest and harvest:IsA("RemoteEvent") then
                safeFire(harvest)
                randomWait(0.3, 0.6)
            end
        end
    end
end)

makeButton("Auto seal inventory", 90, function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local oldPos = root and root.CFrame
    local sealer = workspace:FindFirstChild("InventorySealer")

    if root and sealer and sealer:FindFirstChild("Sealer") then
        root.CFrame = sealer.Sealer.CFrame + Vector3.new(0, 3, 0)
        randomWait(1.5, 2.5)

        local sealRemote = game.ReplicatedStorage:FindFirstChild("SealInventory")
        if sealRemote then
            safeFire(sealRemote)
        end

        randomWait(1.5, 2.5)
        if oldPos then root.CFrame = oldPos end
    end
end)

makeButton("Buy any seed: text", 140, function()
    warn("Buy seed requested (text only):", SeedBox.Text)
end)

makeButton("Buy seed", 250, function()
    local seedName = SeedBox.Text
    if typeof(seedName) == "string" and seedName ~= "" then
        local buyRemote = game.ReplicatedStorage:FindFirstChild("BuySeed")
        if buyRemote then
            safeFire(buyRemote, seedName)
        else
            warn("BuySeed RemoteEvent not found.")
        end
    else
        warn("Invalid seed name.")
    end
end)

-- Bottom Warning
local Warning = Instance.new("TextLabel", Frame)
Warning.Size = UDim2.new(1, 0, 0, 30)
Warning.Position = UDim2.new(0, 0, 1, -30)
Warning.Text = "Be smart. Use with caution!"
Warning.TextColor3 = Color3.fromRGB(0, 0, 0)
Warning.BackgroundTransparency = 1
Warning.TextScaled = true
Warning.Font = Enum.Font.SourceSansBold
