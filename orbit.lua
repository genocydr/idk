-- Create a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OrbitGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create a Frame as the main container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add a UICorner to make the Frame's corners rounded
local uiCornerMainFrame = Instance.new("UICorner")
uiCornerMainFrame.CornerRadius = UDim.new(0, 10)
uiCornerMainFrame.Parent = mainFrame

-- Make the Frame draggable
mainFrame.Active = true
mainFrame.Draggable = true

-- Create a TextBox for player name input
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.9, 0, 0, 30)
nameBox.Position = UDim2.new(0.05, 0, 0.05, 0)
nameBox.PlaceholderText = "Enter player name"
nameBox.Text = ""
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
nameBox.BorderSizePixel = 0
nameBox.Parent = mainFrame

-- Add a UICorner to make the TextBox's corners rounded
local uiCornerNameBox = Instance.new("UICorner")
uiCornerNameBox.CornerRadius = UDim.new(0, 5)
uiCornerNameBox.Parent = nameBox

-- Create a TextButton for the orbit action
local orbitButton = Instance.new("TextButton")
orbitButton.Size = UDim2.new(0.9, 0, 0, 30)
orbitButton.Position = UDim2.new(0.05, 0, 0.2, 0) -- Adjusted Position for spacing
orbitButton.Text = "Orbit"
orbitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50) -- Set to green
orbitButton.BorderSizePixel = 0
orbitButton.Parent = mainFrame

-- Add a UICorner to make the Orbit Button's corners rounded
local uiCornerOrbitButton = Instance.new("UICorner")
uiCornerOrbitButton.CornerRadius = UDim.new(0, 5)
uiCornerOrbitButton.Parent = orbitButton

-- Create a TextButton for the stop action
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.9, 0, 0, 30)
stopButton.Position = UDim2.new(0.05, 0, 0.35, 0) -- Adjusted Position for spacing
stopButton.Text = "Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.BackgroundColor3 = Color3.fromRGB(255, 69, 58)
stopButton.BorderSizePixel = 0
stopButton.Parent = mainFrame

-- Add a UICorner to make the Stop Button's corners rounded
local uiCornerStopButton = Instance.new("UICorner")
uiCornerStopButton.CornerRadius = UDim.new(0, 5)
uiCornerStopButton.Parent = stopButton

-- Create a ScrollFrame for the player list
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.9, 0, 0.4, 0) -- Adjusted Size for spacing
playerList.Position = UDim2.new(0.05, 0, 0.5, 0) -- Adjusted Position for spacing
playerList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
playerList.BorderSizePixel = 0
playerList.CanvasSize = UDim2.new(0, 0, 0, 400) -- Adjusted for vertical scrolling
playerList.Parent = mainFrame

-- Add a UICorner to make the player list's corners rounded
local uiCornerPlayerList = Instance.new("UICorner")
uiCornerPlayerList.CornerRadius = UDim.new(0, 5)
uiCornerPlayerList.Parent = playerList

-- Function to find a player by name or display name
local function findPlayer(name)
    name = string.lower(name)
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if string.lower(player.Name) == name or string.lower(player.Name):find(name) then
            return player
        end
    end
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if string.lower(player.DisplayName) == name or string.lower(player.DisplayName):find(name) then
            return player
        end
    end
    return nil
end

-- Initialize the control flag
local followPlayer = false
local angle = 0

-- Function to stop orbiting
local function stopOrbiting()
    followPlayer = false
end

-- Button click event handler for starting the orbit
orbitButton.MouseButton1Click:Connect(function()
    local targetName = nameBox.Text
    local targetPlayer = findPlayer(targetName)

    if targetPlayer then
        followPlayer = true
        local character = game.Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if not hrp then
            return
        end

        local bodyPosition = Instance.new("BodyPosition", hrp)
        bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyPosition.P = 3000 -- Increase power for faster movement
        bodyPosition.D = 50   -- Adjust damping factor
        bodyPosition.Position = hrp.Position -- Set initial position to avoid initial jump

        local bodyGyro = Instance.new("BodyGyro", hrp)
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 5000  -- Increase power for faster rotation
        bodyGyro.D = 50    -- Adjust damping factor
        bodyGyro.CFrame = hrp.CFrame -- Set initial rotation

        local distance = 8   -- Decreased distance for closer orbit
        local height = 3     -- Decreased height for closer orbit

        spawn(function()
            while task.wait(0.05) do
                if followPlayer and targetPlayer and targetPlayer.Character and targetPlayer.Character:IsDescendantOf(workspace) and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                    local offset = Vector3.new(math.cos(math.rad(angle)) * distance, height, math.sin(math.rad(angle)) * distance)
                    bodyPosition.Position = targetPosition + offset
                    bodyGyro.CFrame = CFrame.new(hrp.Position, targetPosition)
                    angle = angle + 4 -- Increased angle increment for faster rotation
                else
                    -- Destroy the BodyPosition and BodyGyro instances if the conditions are not met
                    if bodyPosition then bodyPosition:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                    break
                end
            end
        end)
    else
        warn("Player not found: " .. targetName)
    end
end)

-- Button click event handler for stopping the orbit
stopButton.MouseButton1Click:Connect(stopOrbiting)

-- Update the player list
local function updatePlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for index, player in pairs(game:GetService("Players"):GetPlayers()) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0, 25)
        button.Position = UDim2.new(0.05, 0, 0, 25 * (index - 1))
        button.Text = player.Name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        button.BorderSizePixel = 0
        button.Parent = playerList

        button.MouseButton1Click:Connect(function()
            nameBox.Text = player.Name
        end)
    end

    playerList.CanvasSize = UDim2.new(0, 0, 0, 25 * #game:GetService("Players"):GetPlayers())
end

-- Update the player list when a player joins or leaves
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

-- Initialize the player list
updatePlayerList()
