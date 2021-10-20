local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CrossServerMutex = require(ServerScriptService.CrossServerMutex)

local CONFIG = require(ReplicatedStorage.CONFIG)

local QUEUE_NAME = CONFIG.MATCHMAKING_QUEUE.NAME
local QUEUE_INVISIBILITY_TIMEOUT = CONFIG.MATCHMAKING_QUEUE.INVISIBILITY_TIMEOUT
local READ_BATCH_SIZE = CONFIG.MATCHMAKING_QUEUE.READ_BATCH_SIZE
local QUEUE_RETRIEVAL_RATE = CONFIG.MATCHMAKING_QUEUE.QUEUE_RETRIEVAL_RATE
local MAX_ADD_RETRIES = CONFIG.MATCHMAKING_QUEUE.MAX_ADD_RETRIES
local QUEUE_ENTRY_LIFETIME = CONFIG.MATCHMAKING_QUEUE.QUEUE_ENTRY_LIFETIME

local MAX_MATCH_SIZE = CONFIG.MATCH.SIZE.MAX
local MIN_MATCH_SIZE = CONFIG.MATCH.SIZE.MIN

local queue = MemoryStoreService:GetQueue(QUEUE_NAME, QUEUE_INVISIBILITY_TIMEOUT)

local matchmakingJob = {}
local isReleasing = false
local isProcessing = false
local isRetrieving = false

function matchmakingJob.startJob()
	local cache = {}

	isProcessing = true
	isRetrieving = true

	--processing loop
	task.spawn(function()
		while true do
			task.wait()

			if not isReleasing then
				local pool = {}

				for i, v in pairs(cache) do
					pool[i] = v
				end

				repeat
					local nextMatch = {}

					for i = 1, MAX_MATCH_SIZE do
						nextMatch[i] = pool[i]
					end

					for i = 1, MAX_MATCH_SIZE do
						if nextMatch[1] then
							table.remove(nextMatch, 1)
						end
					end

				until #nextMatch < MIN_MATCH_SIZE
			else
				isProcessing = false
				break
			end
		end
	end)

	--retrieval loop
	task.spawn(function()
		while true do
			task.wait(QUEUE_RETRIEVAL_RATE)

			if not isReleasing then
				local deletionKeys = {}
				local success, results, deletionKey

				repeat
					success, results, deletionKey = pcall(
						queue.ReadAsync,
						MemoryStoreService,
						READ_BATCH_SIZE,
						false,
						3
					)

					local failedCall = (not success or not results or #results == 0)

					if not failedCall then
						table.insert(deletionKeys, deletionKey)

						for _, result in pairs(results) do
							table.insert(cache, result)
						end
					end
				until failedCall

				if not success then
					warn(results)
				end

				for _, deletionKey in pairs(deletionKeys) do
					local success, result = pcall(
						queue.RemoveAsync,
						MemoryStoreService,
						deletionKey
					)

					if not success then
						warn(result)
					end
				end
			else
				isRetrieving = false

				break
			end
		end
	end)
end

function matchmakingJob.releaseAsync()
	isReleasing = true

	while isProcessing or isRetrieving do
		task.wait()
	end

	isReleasing = false

	return true
end

local MatchmakingProcessor = {}

function MatchmakingProcessor:init()
	CrossServerMutex:assignJob(matchmakingJob)
end

function MatchmakingProcessor:addPlayer(userId)
	local success, result
	local attempts = 0
	
	repeat
		attempts += 1
		success, result = pcall(queue.AddAsync, queue, userId, QUEUE_ENTRY_LIFETIME)
	until success or attempts >= MAX_ADD_RETRIES

	if not success then
		warn(result)
	end

	return success
end

return MatchmakingProcessor