local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")

local CONFIG = require(ReplicatedStorage.CONFIG)
local MATCHMAKING_QUEUE = CONFIG.MATCHMAKING_QUEUE
local QUEUE_NAME = MATCHMAKING_QUEUE.NAME

local Matchmaking = {}

function Matchmaking:addPlayerToQueue()

end

function Matchmaking:init()

end

return Matchmaking