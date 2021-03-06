local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CONFIG = require(ReplicatedStorage.CONFIG)
local Log = require(ReplicatedStorage.Log)

local RETRY_DELAY = CONFIG.RETRY_DELAY

local MUTEX_CONFIG = CONFIG.MUTEX
local MUTEX_NAME = MUTEX_CONFIG.NAME
local MUTEX_KEY = MUTEX_CONFIG.KEY
local MUTEX_RELEASED_KEY = MUTEX_CONFIG.RELEASED_KEY
local CLAIM_ATTEMPT_RATE = MUTEX_CONFIG.CLAIM_ATTEMPT_RATE

local Enums = require(ReplicatedStorage.Enums)
local GetServerType = require(ServerScriptService.GetServerType)

local mutexStore = DataStoreService:GetDataStore(MUTEX_NAME)

local serverType = GetServerType()
local jobId = game.JobId
local assignedJobs = {}

local CrossServerMutex = {}

function CrossServerMutex:requestReservation()
	Log:print("Attempting mutex reservation...")
	local success, result = pcall(mutexStore.UpdateAsync, mutexStore, MUTEX_KEY, function(currentValue)
		if not currentValue or currentValue == MUTEX_RELEASED_KEY then
			return jobId
		end
	end)
	if result == self.jobId then
		Log:print("Reserved mutex!")
		for _, job in pairs(assignedJobs) do
			job.startJob()
		end
	elseif not success then
		Log:warn(result, debug.traceback())
	end
end

function CrossServerMutex:releaseAsync()
	Log:print("Releasing mutex...")
	local jobResults = {}

	local function isFinished()
		for index, value in pairs(assignedJobs) do
			if not jobResults[index] then
				return false
			end
		end
		return true
	end

	for index, job in pairs(assignedJobs) do
		task.spawn(function()
			job.releaseAsync()
			jobResults[index] = true
		end)
	end

	repeat
		task.wait()
	until not isFinished()

	local success, result
	repeat
		success, result = pcall(mutexStore.UpdateAsync, mutexStore, MUTEX_KEY, function(currentValue)
			if currentValue == jobId then
				return MUTEX_RELEASED_KEY
			end
		end)
		task.wait(RETRY_DELAY)
	until success

	Log:print("Mutex released!")

	return true
end

function CrossServerMutex:assignJob(job)
	local index = HttpService:GenerateGUID(false)
	assignedJobs[index] = job
end

function CrossServerMutex:init()
	if serverType == Enums.ServerType.Lobby then
		task.spawn(function()
			while true do
				task.wait(CLAIM_ATTEMPT_RATE)
				self:requestReservation()
			end
		end)

		game:BindToClose(self.releaseAsync)
	end
end

return CrossServerMutex