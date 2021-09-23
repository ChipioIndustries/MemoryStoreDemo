local MemoryStoreService: MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MemoryStoreExplorer: table = {}

local CONFIG = require(ReplicatedStorage.CONFIG)
local CONTENTS_REFRESH_RATE = CONFIG.CONTENTS_REFRESH_RATE

local queueKeys: table = {}
local sortedMapKeys: table = {}

function MemoryStoreExplorer:registerQueueKey(queueKey: string): boolean
	queueKeys[queueKey] = queueKey
	return true
end

function MemoryStoreExplorer:registerSortedMapKey(sortedMapKey: string): boolean
	sortedMapKeys[sortedMapKey] = sortedMapKey
	return true
end

function MemoryStoreExplorer:getQueuesContents(): table
	local queues: table = {}

	for queueKey: string, alsoQueueKey: string in pairs(queueKeys) do
		local queue: MemoryStoreQueue = MemoryStoreService:GetQueue(queueKey, 0)
		local contents: table = {}

		repeat
			local success: boolean, result, deletionKey: string = pcall(queue.ReadAsync, queue, 100, false, 0.1)
			if not success then
				warn(result)
			elseif result then
				for index, value in pairs(result) do
					table.insert(contents, value)
				end
			else
				break
			end
		until #contents % 100 ~= 0 or not success or (result and table.getn(result) == 0)

		queues[queueKey] = contents
	end

	return queues
end

function MemoryStoreExplorer:getSortedMapsContents(): table
	local sortedMaps: table = {}

	for sortedMapKey: string, alsoSortedMapKey: string in pairs(sortedMapKeys) do
		local sortedMap: MemoryStoreSortedMap = MemoryStoreService:GetSortedMap(sortedMapKey)
		local contents: table = {}
		local lastKey

		repeat
			local success: boolean, result = pcall(sortedMap.GetRangeAsync, sortedMap, Enum.SortDirection.Ascending, 200, lastKey)
			if not success then
				warn(result)
			elseif result and table.getn(result) > 0 then
				for index, value in pairs(result) do
					contents[index] = value
				end
			else
				break
			end
		until #contents % 100 ~= 0 or not success or (result and table.getn(result) == 0)
	end

	return sortedMaps
end

function MemoryStoreExplorer:getAllContents(): table
	local queuesContents: table = self:getQueuesContents()
	local sortedMapsContents: table = self:getSortedMapsContents()

	return {
		queuesContents = queuesContents;
		sortedMapsContents = sortedMapsContents;
	}
end

function MemoryStoreExplorer:init()
	task.spawn(function()
		while true do
			task.wait(CONTENTS_REFRESH_RATE)
			print(MemoryStoreExplorer:getAllContents())
		end
	end)
end

return MemoryStoreExplorer