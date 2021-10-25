local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CONFIG = require(ReplicatedStorage.CONFIG)
local Log = require(ReplicatedStorage.Log)

local RETRY_DELAY = CONFIG.RETRY_DELAY

local TOPIC = CONFIG.MATCH_MESSAGING.TOPIC
local MAX_SEND_RETRIES = CONFIG.MATCH_MESSAGING.MAX_SEND_RETRIES
local MAX_SUBSCRIBE_RETRIES = CONFIG.MATCH_MESSAGING.MAX_SUBSCRIBE_RETRIES

local MessagingProcessor = {}

local matchReceiptCallbacks = {}

function MessagingProcessor:sendMatch(match)
	local success, result
	local attempts = 0

	repeat
		attempts += 1
		success, result = pcall(MessagingService.PublishAsync, MessagingService, TOPIC, match)
		task.wait(RETRY_DELAY)
	until success or attempts >= MAX_SEND_RETRIES

	if not success then
		Log:warn(result, debug.traceback())
	end

	return success
end

function MessagingProcessor:bindToMatchReceipt(callback)
	table.insert(matchReceiptCallbacks, callback)
end

function MessagingProcessor:init()
	local success, result
	local attempts = 0

	repeat
		attempts += 1
		success, result = pcall(
			MessagingService.SubscribeAsync,
			MessagingService,
			TOPIC,
			function(message)
				for _, callback in pairs(matchReceiptCallbacks) do
					task.spawn(callback, message.Data)
				end
			end
		)
		task.wait(RETRY_DELAY)
	until success or attempts >= MAX_SUBSCRIBE_RETRIES

	if not success then
		Log:warn(result, debug.traceback())
	end
end

return MessagingProcessor