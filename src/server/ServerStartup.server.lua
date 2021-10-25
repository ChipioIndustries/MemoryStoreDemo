local ServerScriptService = game:GetService("ServerScriptService")

local MemoryStoreExplorer = require(ServerScriptService.MemoryStoreExplorer)
local PlayerTeleportHandler = require(ServerScriptService.PlayerTeleportHandler)
local MessagingProcessor = require(ServerScriptService.MessagingProcessor)
local MatchmakingProcessor = require(ServerScriptService.MatchmakingProcessor)
local CrossServerMutex = require(ServerScriptService.CrossServerMutex)
local ClientRequestHandler = require(ServerScriptService.ClientRequestHandler)

MemoryStoreExplorer:init()
PlayerTeleportHandler:init()
MessagingProcessor:init()
MatchmakingProcessor:init()
CrossServerMutex:init()
ClientRequestHandler:init()