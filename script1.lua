--// INSTANT PROXIMITY PROMPT KEY
--// LocalScript
--// StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local boundKey = nil
local binding = false

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "InstantPromptKeybind"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(340, 180)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.ZIndex = 999999
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 50)
title.Position = UDim2.fromOffset(10, 10)
title.BackgroundTransparency = 1
title.Text = "Instant Prompt"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.ZIndex = 1000000
title.Parent = frame

local info = Instance.new("TextLabel")
info.Name = "Info"
info.Size = UDim2.new(1, -20, 0, 25)
info.Position = UDim2.fromOffset(10, 55)
info.BackgroundTransparency = 1
info.Text = "Choose a key to instantly interact"
info.TextColor3 = Color3.fromRGB(180, 180, 180)
info.TextSize = 14
info.Font = Enum.Font.Gotham
info.ZIndex = 1000000
info.Parent = frame

local bindButton = Instance.new("TextButton")
bindButton.Name = "BindButton"
bindButton.Size = UDim2.fromOffset(280, 60)
bindButton.Position = UDim2.fromScale(0.5, 0.72)
bindButton.AnchorPoint = Vector2.new(0.5, 0.5)
bindButton.BackgroundColor3 = Color3.fromRGB(55, 120, 255)
bindButton.BorderSizePixel = 0
bindButton.Text = "Bind Key"
bindButton.TextColor3 = Color3.new(1, 1, 1)
bindButton.TextSize = 20
bindButton.Font = Enum.Font.GothamBold
bindButton.ZIndex = 1000000
bindButton.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = bindButton

--------------------------------------------------
-- GET PROMPT POSITION
--------------------------------------------------

local function getPromptPosition(prompt)

	local parent = prompt.Parent

	if not parent then
		return nil
	end

	if parent:IsA("BasePart") then
		return parent.Position
	end

	if parent:IsA("Attachment") then
		return parent.WorldPosition
	end

	return nil
end

--------------------------------------------------
-- FIND NEAREST PROMPT
--------------------------------------------------

local function getNearestPrompt()

	local character = player.Character

	if not character then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil
	end

	local nearestPrompt = nil
	local nearestDistance = math.huge

	for _, object in ipairs(workspace:GetDescendants()) do

		if object:IsA("ProximityPrompt") and object.Enabled then

			local position = getPromptPosition(object)

			if position then

				local distance = (root.Position - position).Magnitude

				if distance <= object.MaxActivationDistance then

					if distance < nearestDistance then
						nearestDistance = distance
						nearestPrompt = object
					end

				end
			end
		end
	end

	return nearestPrompt
end

--------------------------------------------------
-- BIND KEY
--------------------------------------------------

bindButton.MouseButton1Click:Connect(function()

	if binding then
		return
	end

	binding = true
	bindButton.Text = "PRESS A KEY..."
	bindButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)

	local connection

	connection = UserInputService.InputBegan:Connect(function(input)

		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == Enum.KeyCode.Unknown then
			return
		end

		boundKey = input.KeyCode
		binding = false

		connection:Disconnect()

		bindButton.Text = "KEY: " .. boundKey.Name
		bindButton.BackgroundColor3 = Color3.fromRGB(40, 180, 90)

		task.wait(0.5)

		-- Hide GUI
		gui.Enabled = false
	end)
end)

--------------------------------------------------
-- INSTANT PROMPT
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if binding then
		return
	end

	if not boundKey then
		return
	end

	if input.KeyCode ~= boundKey then
		return
	end

	local prompt = getNearestPrompt()

	if not prompt then
		return
	end

	--------------------------------------------------
	-- INSTANTLY COMPLETE PROMPT
	--------------------------------------------------

	local oldDuration = prompt.HoldDuration

	prompt.HoldDuration = 0

	prompt:InputHoldBegin()
	prompt:InputHoldEnd()

	-- Restore original duration
	task.defer(function()
		if prompt and prompt.Parent then
			prompt.HoldDuration = oldDuration
		end
	end)

end)
