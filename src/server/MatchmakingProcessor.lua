local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local ServerScriptService = game:GetService("ServerScriptService")

local CrossServerMutex = require(ServerScriptService.CrossServerMutex)

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
			task.wait()
			if not isReleasing then

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