local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CONFIG = require(ReplicatedStorage.CONFIG)

local QUEUE_ENTRY_LIFETIME = CONFIG.MATCHMAKING_QUEUE.QUEUE_ENTRY_LIFETIME

local remotes = ReplicatedStorage.Remotes
local addToMatchmaking = remotes.AddToMatchmaking
local endMatch = remotes.endMatch

local ClientRequestHandler = {}

function ClientRequestHandler:requestAddToMatchmaking()

end

function ClientRequestHandler:requestEndMatch()

end

function ClientRequestHandler:init()

end

return ClientRequestHandler