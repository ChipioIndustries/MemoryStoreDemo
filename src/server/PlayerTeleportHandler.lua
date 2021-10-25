local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MessagingProcessor = require(ServerScriptService.MessagingProcessor)
local SafeTeleport = require(ServerScriptService.SafeTeleport)
local GetServerType = require(ServerScriptService.GetServerType)

local CONFIG = require(ReplicatedStorage.CONFIG)
local Enums = require(ReplicatedStorage.Enums)

local serverType = GetServerType()

local PlayerTeleportHandler = {}

local function receiveMatch(match)
	local players = match.players
	local reservedServerCode = match.reservedServerCode

	local foundPlayers = {}

	for _, userId in pairs(players) do
		local player = Players:GetPlayerByUserId(userId)

		if player then
			table.insert(foundPlayers, player)
		end
	end

	if #foundPlayers > 0 then
		local teleportOptions = Instance.new("TeleportOptions")
		teleportOptions.ReservedServerAccessCode = reservedServerCode

		SafeTeleport(game.PlaceId, foundPlayers, teleportOptions)
	end
end

function PlayerTeleportHandler:endMatch()
	local players = Players:GetPlayers()

	SafeTeleport(game.PlaceId, players)
	-- not including a reservedservercode will send players to a
	-- random public lobby server
end

function PlayerTeleportHandler:init()
	if serverType == Enums.ServerType.Lobby then
		MessagingProcessor:bindToMatchReceipt(receiveMatch)
	end
end

return PlayerTeleportHandler