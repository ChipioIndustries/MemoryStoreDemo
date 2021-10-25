local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Enums)
local Log = require(ReplicatedStorage.Log)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage.Remotes
local addToMatchmaking = remotes.AddToMatchmaking
local endMatch = remotes.EndMatch
local getServerType = remotes.GetServerType

local serverType = getServerType:InvokeServer()

local InterfaceController = {}

function InterfaceController:init()
	local interface = ReplicatedStorage.Interface:Clone()
	local menu = interface.Menu
	local button = menu.Button
	local title = menu.Title

	local function requestAddToMatchmaking()
		addToMatchmaking:FireServer()
		button.Text = "Making match..."
		button.Active = false
	end

	local function requestEndMatch()
		endMatch:FireServer()
		button.Text = "Vote submitted..."
		button.Active = false
	end

	local titleText
	local buttonText
	local buttonCallback

	if serverType == Enums.ServerType.Lobby then
		titleText = "LOCATION: LOBBY"
		buttonText = "JOIN MATCHMAKING QUEUE"
		buttonCallback = requestAddToMatchmaking
	elseif serverType == Enums.ServerType.Match then
		titleText = "LOCATION: MATCH"
		buttonText = "VOTE END MATCH"
		buttonCallback = requestEndMatch
	end

	title.Text = titleText
	button.Text = buttonText
	button.Activated:Connect(buttonCallback)

	interface.Parent = playerGui
end

return InterfaceController

