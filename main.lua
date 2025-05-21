--[[
Gang Hub | Grow a Garden (Safe Version + Executor Check)
Script made by: @SkibidiScript
Enhanced safety: human-like delays, event throttling, structure checks
Only runs on selected executors, kicks otherwise.
]]

-- Executor Detection (returns string executor name or nil)
local function detectExecutor()
    local identifiers = {
        Delta = function() return _G.Deltra and "Delta" end,
        Codex = function() return getexecutorname and getexecutorname():lower():find("codex") and "Codex" end,
        KRNL = function() return getexecutorname and getexecutorname():lower():find("krnl") and "KRNL" end,
        Fluxus = function() return getexecutorname and getexecutorname():lower():find("fluxus") and "Fluxus" end,
        Xeno = function() return getexecutorname and getexecutorname():lower():find("xen") and "Xeno" end,
        ["Kiwi X"] = function() return getexecutorname and getexecutorname():lower():find("kiwi") and "Kiwi X" end,
        Vegax = function() return getexecutorname and getexecutorname():lower():find("vegax") and "Vegax" end,
    }

    for name, func in pairs(identifiers) do
        local ok, result = pcall(func)
        if ok and result then
            return result
        end
    end
    return nil
end

-- Allowed executors
local allowedExecutors = {
    Delta = true,
    Codex = true,
    KRNL = true,
    Fluxus = true,
    Xeno = true,
    ["Kiwi X"] = true,
    Vegax = true,
}

-- Check executor
local executorName = detectExecutor()
if not executorName or not allowedExecutors[executorName] then
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer:Kick("This script do not allow your executor to run it on!")
    else
        -- fallback kick
        Players.LocalPlayer:Kick("This script do not allow your executor to run it on!")
    end
    return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Safety Check: Exit if game structure isn't expected
if not workspace:FindFirstChild("Plants") or not ReplicatedStorage:FindFirstChild("BuySeed") then
    warn("Game structure not recognized. Exiting script to avoid detection.")
    return
end

-- RemoteEvent throttle and random delay system
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

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GrowSafeUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 350)
Frame.Position = UDim2.new(0.5, -150, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1

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
        for hue = 0, 1, 0.01 do
            RainbowText.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end
end)

-- Button Helper
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
        randomWait(0.4, 1)
        pcall(onClick)
    end)
end

-- TextBox
local SeedBox = Instance.new("TextBox", Frame)
SeedBox.Size = UDim2.new(0.9, 0, 0, 40)
SeedBox.Position = UDim2.new(0.05, 0, 0, 200)
SeedBox.PlaceholderText = "Type seed name here..."
SeedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SeedBox.TextColor3 = Color3.fromRGB(255, 0, 0)
SeedBox.Font = Enum.Font.SourceSansBold
SeedBox.TextScaled = true

-- Auto Correct Full Fruits
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

-- Auto Seal Inventory
makeButton("Auto seal inventory", 90, function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
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

-- Buy Any Seed (Warning Log Only)
makeButton("Buy any seed: text", 140, function()
    warn("Buy seed requested (text only):", SeedBox.Text)
end)

-- Buy Seed via RemoteEvent
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
