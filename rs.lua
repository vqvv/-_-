local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cleanup existing UI
if playerGui:FindFirstChild("ScriptHubUI") then
	playerGui.ScriptHubUI:Destroy()
end

-- Script Configuration
local scripts = {
	{ Name = "Aimbot", URL = "https://raw.githubusercontent.com/Jakee8718/dh/refs/heads/main/aim.lua", Active = false },
	{ Name = "ESP", URL = "https://raw.githubusercontent.com/Jakee8718/dh/refs/heads/main/esp.lua", Active = false },
	{ Name = "Teleport", URL = "https://raw.githubusercontent.com/Jakee8718/dh/refs/heads/main/tp.lua", Active = false },
}

-- Theme Configuration
local themes = {
	Dark = {
		Background = Color3.fromRGB(20, 20, 20),
		Surface = Color3.fromRGB(30, 30, 30),
		Text = Color3.fromRGB(240, 240, 240),
		Primary = Color3.fromRGB(235, 0, 4),
		Accent = Color3.fromRGB(237, 0, 4)
	},
	Light = {
		Background = Color3.fromRGB(240, 240, 240),
		Surface = Color3.fromRGB(220, 220, 220),
		Text = Color3.fromRGB(30, 30, 30),
		Primary = Color3.fromRGB(94, 13, 225),
		Accent = Color3.fromRGB(114, 38, 227)
	},
	Ocean = {
		Background = Color3.fromRGB(10, 20, 30),
		Surface = Color3.fromRGB(20, 40, 60),
		Text = Color3.fromRGB(220, 240, 255),
		Primary = Color3.fromRGB(0, 150, 200),
		Accent = Color3.fromRGB(0, 170, 220)
	}
}

local currentTheme = themes.Dark

-- Create Main UI
local gui = Instance.new("ScreenGui")
gui.Name = "ScriptHubUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Main Container
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 300, 0, 300)
main.Position = UDim2.new(0.5, -150, 0.5, -150)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = currentTheme.Background
main.ClipsDescendants = true
main.Parent = gui

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 8)

-- Proper draggable logic
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = currentTheme.Surface
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Font = Enum.Font.Gotham
title.Text = "RS"
title.TextColor3 = currentTheme.Primary
title.TextSize = 16
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 12, 0, 0)

local close = Instance.new("TextButton", header)
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -32, 0, 4)
close.Text = "×"
close.TextColor3 = currentTheme.Text
close.TextSize = 20
close.Font = Enum.Font.GothamBold
close.BackgroundTransparency = 1

-- Script List
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -96)
scroll.Position = UDim2.new(0, 8, 0, 48)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, #scripts * 42)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 6)

-- Script buttons
for i, scriptData in ipairs(scripts) do
	local button = Instance.new("TextButton", scroll)
	button.Size = UDim2.new(1, 0, 0, 36)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextColor3 = currentTheme.Text
	button.BackgroundColor3 = currentTheme.Surface
	button.AutoButtonColor = false
	button.Text = scriptData.Name .. ": Off"

	local corner = Instance.new("UICorner", button)
	corner.CornerRadius = UDim.new(0, 6)

	button.MouseButton1Click:Connect(function()
		scriptData.Active = not scriptData.Active
		button.Text = scriptData.Name .. (scriptData.Active and ": On" or ": Off")

		if scriptData.Active then
			pcall(function()
				loadstring(game:HttpGet(scriptData.URL))()
			end)
		end
	end)
end

-- Theme Button
local themeButton = Instance.new("TextButton", main)
themeButton.Size = UDim2.new(1, -16, 0, 32)
themeButton.Position = UDim2.new(0, 8, 1, -40)
themeButton.Font = Enum.Font.Gotham
themeButton.TextSize = 14
themeButton.Text = "Theme: Dark"
themeButton.TextColor3 = currentTheme.Text
themeButton.BackgroundColor3 = currentTheme.Surface
themeButton.AutoButtonColor = false

local themeCorner = Instance.new("UICorner", themeButton)
themeCorner.CornerRadius = UDim.new(0, 6)

local themeIndex = 1
local themeNames = {"Dark", "Light", "Ocean"}

themeButton.MouseButton1Click:Connect(function()
	themeIndex = (themeIndex % #themeNames) + 1
	currentTheme = themes[themeNames[themeIndex]]
	themeButton.Text = "Theme: " .. themeNames[themeIndex]

	main.BackgroundColor3 = currentTheme.Background
	header.BackgroundColor3 = currentTheme.Surface
	title.TextColor3 = currentTheme.Primary
	close.TextColor3 = currentTheme.Text
	themeButton.TextColor3 = currentTheme.Text
	themeButton.BackgroundColor3 = currentTheme.Surface

	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child.BackgroundColor3 = currentTheme.Surface
			child.TextColor3 = currentTheme.Text
		end
	end
end)

-- Close Button
close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Toggle visibility with RightShift
local isVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.RightShift then
		isVisible = not isVisible
		gui.Enabled = isVisible
	end
end)

-- Re-enable GUI on respawn
player.CharacterAdded:Connect(function()
	gui.Enabled = true
end)
