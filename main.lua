--[[
Gang Hub | Grow a Garden (Safe Version)
Script made by: @SkibidiScript
Supports: Delta, Codex, KRNL, Fluxus, Xeno, Kiwi X, Vegax
Kicks others. Fixed GUI for Codex. Safe fire + drag.
]]

-- Executor Whitelist
local allowed = {
    ["Delta"] = true,
    ["delta"] = true,
    ["Codex"] = true,
    ["codex"] = true,
    ["Krnl"] = true,
    ["krnl"] = true,
    ["Fluxus"] = true,
    ["fluxus"] = true,
    ["Xeno"] = true,
    ["xeno"] = true,
    ["Kiwi X"] = true,
    ["kiwi x"] = true,
    ["Vegax"] = true,
    ["vegax"] = true,
}

local executor = identifyexecutor and identifyexecutor() or "unknown"
if not allowed[executor] then
    game.Players.LocalPlayer:Kick("This script does not allow your executor to run it on!")
    return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Game Structure Check
if not workspace:FindFirstChild("Plants") or not ReplicatedStorage:FindFirstChild("BuySeed") then
    warn("Unsupported game or missing RemoteEvents. Exiting.")
    return
end

-- Safe Remote Firing
local lastFire = 0
local function safeFire(remote, ...)
    if tick() - lastFire >= 1 then
        lastFire = tick()
        remote:FireServer(...)
    end
end

local function randomWait(min, max)
    task.wait(math.random(min * 100, max * 100) / 100)
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrowSafeUI"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
end)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Custom Drag
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Rainbow Label
local RainbowText = Instance.new("TextLabel", Frame)
RainbowText.Size = UDim2.new(1, 0, 0, 30)
RainbowText.Position = UDim2.new(0, 0, 0, 0)
RainbowText.Text = "Script Made By: @SkibidiScript"
RainbowText.TextScaled = true
RainbowText.Font = Enum.Font.SourceSansBold
RainbowText.BackgroundTransparency = 1
RainbowText.Parent = Frame

task.spawn(function()
    while RainbowText.Parent do
        for hue = 0, 1, 0.01 do
            RainbowText.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end
end)

-- TextBox
local SeedBox = Instance.new("TextBox", Frame)
SeedBox.Size = UDim2.new(0.9, 0, 0, 40)
SeedBox.Position = UDim2.new(0.05, 0, 0, 200)
SeedBox.PlaceholderText = "Type seed name here..."
SeedBox.TextColor3 = Color3.fromRGB(255, 0, 0)
SeedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SeedBox.TextScaled = true
SeedBox.Font = Enum.Font.SourceSansBold
SeedBox.Parent = Frame

-- Button Helper
local function makeButton(text, yPos, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Parent = Frame
    btn.MouseButton1Click:Connect(function()
        randomWait(0.4, 1)
        pcall(onClick)
    end)
end

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
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local oldPos = root and root.CFrame
    local sealer = workspace:FindFirstChild("InventorySealer")
    if root and sealer and sealer:FindFirstChild("Sealer") then
        root.CFrame = sealer.Sealer.CFrame + Vector3.new(0, 3, 0)
        randomWait(1.5, 2.5)
        local sealRemote = ReplicatedStorage:FindFirstChild("SealInventory")
        if sealRemote then
            safeFire(sealRemote)
        end
        randomWait(1.5, 2.5)
        if oldPos then root.CFrame = oldPos end
    end
end)

makeButton("Buy any seed: text", 140, function()
    warn("Buy seed typed only:", SeedBox.Text)
end)

makeButton("Buy seed", 250, function()
    local seedName = SeedBox.Text
    if typeof(seedName) == "string" and seedName ~= "" then
        local buyRemote = ReplicatedStorage:FindFirstChild("BuySeed")
        if buyRemote then
            safeFire(buyRemote, seedName)
        else
            warn("BuySeed RemoteEvent not found.")
        end
    else
        warn("Invalid seed name.")
    end
end)

-- Warning Label
local Warning = Instance.new("TextLabel", Frame)
Warning.Size = UDim2.new(1, 0, 0, 30)
Warning.Position = UDim2.new(0, 0, 1, -30)
Warning.Text = "Be smart. Use with caution!"
Warning.TextColor3 = Color3.fromRGB(0, 0, 0)
Warning.BackgroundTransparency = 1
Warning.TextScaled = true
Warning.Font = Enum.Font.SourceSansBold
Warning.Parent = Frame
