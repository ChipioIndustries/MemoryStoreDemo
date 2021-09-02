local ServerScriptService = game:GetService("ServerScriptService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local MemoryStoreExplorer = require(ServerScriptService.MemoryStoreExplorer)

MemoryStoreExplorer:registerQueueKey("TestKey")
MemoryStoreService:GetQueue("TestKey", 10):AddAsync("Hello World", 60, 0)