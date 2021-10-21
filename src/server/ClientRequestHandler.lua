local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MatchmakingProcessor = require(ServerScriptService.MatchmakingProcessor)
local PlayerTeleportHandler =  require(ServerScriptService.PlayerTeleportHandler)
local GetServerType = require(ServerScriptService.GetServerType)

local CONFIG = require(ReplicatedStorage.CONFIG)
local Enums = require(ReplicatedStorage.Enums)

local QUEUE_ENTRY_LIFETIME = CONFIG.MATCHMAKING_QUEUE.QUEUE_ENTRY_LIFETIME

local remotes = ReplicatedStorage.Remotes
local addToMatchmaking = remotes.AddToMatchmaking
local endMatch = remotes.EndMatch
local getServerType = remotes.GetServerType

local serverType = GetServerType()

local matchmakingCache = {}
local endMatchVotes = {}

local ClientRequestHandler = {}

local function checkMatchEndVotes()
	local voteCount = 0
	local players = Players:GetPlayers()

	for _, player in pairs(players) do
		if endMatchVotes[player.UserId] then
			voteCount += 1
		end
	end

	if voteCount > #players / 2 then
		PlayerTeleportHandler:endMatch()
	end
end

local function onPlayerRemoving(player)
	local userId = player.UserId
	matchmakingCache[userId] = nil
	endMatchVotes[userId] = nil
end

function ClientRequestHandler:requestAddToMatchmaking(player)
	local userId = player.UserId
	if serverType == Enums.ServerType.Lobby then
		local timestamp = matchmakingCache[userId]
		if tick() - timestamp > QUEUE_ENTRY_LIFETIME then
			local result = MatchmakingProcessor:addPlayer(userId)
			if result then
				matchmakingCache[player] = tick()
			end
		end
	end
end

function ClientRequestHandler:requestEndMatch(player)
	local userId = player.UserId
	if serverType == Enums.ServerType.Match then
		if not endMatchVotes[userId] then
			endMatchVotes[userId] = true
			checkMatchEndVotes()
		end
	end
end

function ClientRequestHandler:init()
	addToMatchmaking.OnServerEvent:Connect(self.requestAddToMatchmaking)
	endMatch.OnServerEvent:Connect(self.requestEndMatch)

	getServerType.OnServerInvoke = GetServerType
	
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return ClientRequestHandler