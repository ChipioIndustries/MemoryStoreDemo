local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CrossServerMutex = require(ServerScriptService.CrossServerMutex)

local CONFIG = require(ReplicatedStorage.CONFIG)
local QUEUE_NAME = CONFIG.MATCHMAKING_QUEUE.NAME
local QUEUE_INVISIBILITY_TIMEOUT = CONFIG.MATCHMAKING_QUEUE.INVISIBILITY_TIMEOUT
local READ_BATCH_SIZE = CONFIG.MATCHMAKING_QUEUE.READ_BATCH_SIZE

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

			else
				isProcessing = false
				break
			end
		end
	end)

	--retrieval loop
	task.spawn(function()
		while true do
			task.wait(0.5)
			if not isReleasing then
				local success, results
				repeat
					success, results = pcall(
						queue.ReadAsync,
						MemoryStoreService,
						READ_BATCH_SIZE,
						
					)
				until not success or not results or #results == 0

				if not success then
					warn(results)
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

return MatchmakingProcessor