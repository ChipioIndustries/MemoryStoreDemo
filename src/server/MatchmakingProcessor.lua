local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CrossServerMutex = require(ServerScriptService.CrossServerMutex)
local MessagingProcessor = require(ServerScriptService.MessagingProcessor)
local TableUtility = require(ReplicatedStorage.TableUtility)

local CONFIG = require(ReplicatedStorage.CONFIG)
local Log = require(ReplicatedStorage.Log)

local RETRY_DELAY = CONFIG.RETRY_DELAY

local QUEUE_NAME = CONFIG.MATCHMAKING_QUEUE.NAME
local QUEUE_INVISIBILITY_TIMEOUT = CONFIG.MATCHMAKING_QUEUE.INVISIBILITY_TIMEOUT
local READ_BATCH_SIZE = CONFIG.MATCHMAKING_QUEUE.READ_BATCH_SIZE
local QUEUE_RETRIEVAL_RATE = CONFIG.MATCHMAKING_QUEUE.QUEUE_RETRIEVAL_RATE
local MAX_ADD_RETRIES = CONFIG.MATCHMAKING_QUEUE.MAX_ADD_RETRIES
local QUEUE_ENTRY_LIFETIME = CONFIG.MATCHMAKING_QUEUE.QUEUE_ENTRY_LIFETIME

local YIELD = CONFIG.MATCHMAKING_QUEUE.PROCESSING_YIELD.YIELD
local EXTENDED_YIELD = CONFIG.MATCHMAKING_QUEUE.PROCESSING_YIELD.EXTENDED_YIELD
local EXTENDED_YIELD_MAX_CACHE_SIZE = CONFIG.MATCHMAKING_QUEUE.PROCESSING_YIELD.EXTENDED_YIELD_MAX_CACHE_SIZE

local MAX_MATCH_SIZE = CONFIG.MATCH.SIZE.MAX
local MIN_MATCH_SIZE = CONFIG.MATCH.SIZE.MIN

local queue = MemoryStoreService:GetQueue(QUEUE_NAME, QUEUE_INVISIBILITY_TIMEOUT)

local MatchmakingProcessor = {}

local matchmakingJob = {}
local isReleasing = false
local isProcessing = false
local isRetrieving = false

function matchmakingJob.startJob()
	local cache = {}

	isProcessing = true
	isRetrieving = true

	-- processing loop
	task.spawn(function()
		while true do
			if #cache > EXTENDED_YIELD_MAX_CACHE_SIZE then
				task.wait(YIELD)
			else
				task.wait(EXTENDED_YIELD)
			end
			Log:print(cache)

			if not isReleasing then
				local pool = {}

				-- move player cache to pool for processing, then clear cache
				for i, v in pairs(cache) do
					pool[i] = v
				end

				cache = {}

				-- make and start matches until there are not enough players in the pool
				repeat
					local nextMatch = {}

					for i = 1, MAX_MATCH_SIZE do
						nextMatch[i] = pool[i]
					end

					local isLargeEnough = #nextMatch >= MIN_MATCH_SIZE

					if isLargeEnough then
						local reservedServerCode = TeleportService:ReserveServer(game.PlaceId)

						local matchMade = MessagingProcessor:sendMatch({
							players = nextMatch;
							reservedServerCode = reservedServerCode;
						})

						if matchMade then
							pool = TableUtility:removeRange(pool, 1, MAX_MATCH_SIZE)
						end
					end

				until not isLargeEnough

				-- add unprocessed players back to cache
				cache = TableUtility:join(pool, cache)
			else
				-- ensure no new players will be added to the cache
				while isRetrieving do
					task.wait()
				end
				-- add all cached players who won't be processed back to the queue
				for _, player in pairs(cache) do
					MatchmakingProcessor:addPlayer(player)
				end

				isProcessing = false
				break
			end
		end
	end)

	-- retrieval loop
	task.spawn(function()
		while true do
			task.wait(QUEUE_RETRIEVAL_RATE)

			if not isReleasing then
				local deletionKeys = {}
				local success, results, deletionKey

				-- get players from queue until there's an error or the queue is empty
				repeat
					success, results, deletionKey = pcall(
						queue.ReadAsync,
						queue,
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
					Log:warn(results)
				end

				-- remove the grabbed players form the queue
				for _, deletionKey in pairs(deletionKeys) do
					local success, result = pcall(
						queue.RemoveAsync,
						queue,
						deletionKey
					)

					if not success then
						Log:warn(result, debug.traceback())
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

	-- wait until matchmaking processes are finished
	while isProcessing or isRetrieving do
		task.wait()
	end

	isReleasing = false

	return true
end

function MatchmakingProcessor:init()
	CrossServerMutex:assignJob(matchmakingJob)
end

function MatchmakingProcessor:addPlayer(userId)
	local success, result
	local attempts = 0

	repeat
		attempts += 1
		success, result = pcall(queue.AddAsync, queue, userId, QUEUE_ENTRY_LIFETIME)
		task.wait(RETRY_DELAY)
	until success or attempts >= MAX_ADD_RETRIES

	if not success then
		Log:warn(result, debug.traceback())
	end

	return success
end

return MatchmakingProcessor