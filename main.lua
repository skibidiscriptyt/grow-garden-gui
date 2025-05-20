--[[
Gang Hub | Grow a Garden
GUI Script made by: @SkibidiScript
Executor-ready script with draggable UI, rainbow text, and buttons:
- Auto Correct Full Fruits
- Auto Seal Inventory
- Buy Any Seed (with textbox)
- Buy Seed (with textbox input)
- Warning label
]]

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GangHubGUI"

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

-- Rainbow effect
task.spawn(function()
    while true do
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
    btn.MouseButton1Click:Connect(onClick)
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

-- Buttons
makeButton("Auto correct full fruits", 40, function()
    for _, plant in pairs(workspace.Plants:GetChildren()) do
        if plant:FindFirstChild("Owner") and plant.Owner.Value == LocalPlayer.Name then
            local harvest = plant:FindFirstChild("Harvest")
            if harvest and harvest:IsA("RemoteEvent") then
                harvest:FireServer()
            end
        end
    end
end)

makeButton("Auto seal inventory", 90, function()
    local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local oldPos = pos and pos.Position
    local sealer = workspace:FindFirstChild("InventorySealer")
    if sealer and sealer:FindFirstChild("Sealer") then
        pos.CFrame = sealer.Sealer.CFrame + Vector3.new(0, 3, 0)
        task.wait(2)
        local sealRemote = game.ReplicatedStorage:FindFirstChild("SealInventory")
        if sealRemote then
            sealRemote:FireServer()
        end
        task.wait(2)
        if oldPos then pos.CFrame = CFrame.new(oldPos) end
    end
end)

makeButton("Buy any seed: text", 140, function()
    warn("Seed to buy: ", SeedBox.Text)
end)

makeButton("Buy seed", 250, function()
    local seedName = SeedBox.Text
    local buyRemote = game.ReplicatedStorage:FindFirstChild("BuySeed")
    if buyRemote then
        buyRemote:FireServer(seedName)
    else
        warn("BuySeed RemoteEvent not found")
    end
end)

-- Warning Label
local Warning = Instance.new("TextLabel", Frame)
Warning.Size = UDim2.new(1, 0, 0, 30)
Warning.Position = UDim2.new(0, 0, 1, -30)
Warning.Text = "Be careful with the script!"
Warning.TextColor3 = Color3.fromRGB(0, 0, 0)
Warning.BackgroundTransparency = 1
Warning.TextScaled = true
Warning.Font = Enum.Font.SourceSansBold
