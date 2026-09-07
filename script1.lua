--// Instant ProximityPrompt - F7
--// LocalScript
--// StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Find the nearest ProximityPrompt
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

	for _, prompt in ipairs(workspace:GetDescendants()) do
		if prompt:IsA("ProximityPrompt") and prompt.Enabled then

			local parent = prompt.Parent
			local position

			if parent:IsA("BasePart") then
				position = parent.Position
			elseif parent:IsA("Attachment") then
				position = parent.WorldPosition
			end

			if position then
				local distance = (root.Position - position).Magnitude

				if distance <= prompt.MaxActivationDistance
					and distance < nearestDistance then

					nearestPrompt = prompt
					nearestDistance = distance
				end
			end
		end
	end

	return nearestPrompt
end

-- F7 = instant prompt
UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then
		return
	end

	if input.KeyCode ~= Enum.KeyCode.F7 then
		return
	end

	local prompt = getNearestPrompt()

	if not prompt then
		return
	end

	-- Make the prompt instant
	local oldDuration = prompt.HoldDuration
	prompt.HoldDuration = 0

	prompt:InputHoldBegin()
	prompt:InputHoldEnd()

	-- Restore the original setting
	task.defer(function()
		if prompt and prompt.Parent then
			prompt.HoldDuration = oldDuration
		end
	end)
end)
