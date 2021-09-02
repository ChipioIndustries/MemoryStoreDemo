local MemoryStoreService = game:GetService("MemoryStoreService")

local MemoryStoreExplorer: table = {}

local queueKeys: table = {}

function MemoryStoreExplorer:registerQueueKey(queueKey: string): bool
	queueKeys[queueKey] = queueKey
end

function MemoryStoreExplorer:getQueuesContents()
	local queues = {}
	for queueKey, alsoQueueKey in pairs(queueKeys) do
		local queue = MemoryStoreService:GetQueue(queueKey, 0)
		local contents = {}
		repeat
			local success, result, deletionKey = pcall(queue.ReadAsync, queue, 100, false, 0.1)
			if not success then
				warn(result)
			elseif result then
				for index, value in pairs(result) do
					table.insert(contents, value)
				end
			else
				break
			end
		until (#contents)%100 ~= 0 or not success
		queues[queueKey] = contents
	end

	return queues
end

task.spawn(function()
	while true do
		task.wait(5)
		print(MemoryStoreExplorer:getQueuesContents())
	end
end)

return MemoryStoreExplorer