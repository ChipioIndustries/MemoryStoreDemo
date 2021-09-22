local ServerScriptService = game:GetService("ServerScriptService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local MemoryStoreExplorer = require(ServerScriptService.MemoryStoreExplorer)

MemoryStoreExplorer:registerQueueKey("TestKey")
MemoryStoreService:GetQueue("TestKey", 10):AddAsync("Hello World", 60, 0)

MemoryStoreExplorer:registerSortedMapKey("TestKey")
local sm = MemoryStoreService:GetSortedMap("TestKey")

for i=1, 20 do
	local key = tostring(i)
	while #key < 3 do
		key = "0"..key
	end
	sm:SetAsync(key, math.random(1, 1000), 10)
end

local results = sm:GetRangeAsync(
	Enum.SortDirection.Ascending,
	10,
	"005",
	"015"
)

print(results)