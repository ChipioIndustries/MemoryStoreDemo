local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CONFIG = require(ReplicatedStorage.CONFIG)

local RETRY_DELAY = CONFIG.RETRY_DELAY

local TOPIC = CONFIG.MATCH_MESSAGING.TOPIC
local MAX_SEND_RETRIES = CONFIG.MATCH_MESSAGING.MAX_SEND_RETRIES
local MAX_SUBSCRIBE_RETRIES = CONFIG.MATCH_MESSAGING.MAX_SUBSCRIBE_RETRIES

local MessagingProcessor = {}

function MessagingProcessor:sendMatch(players)
	local success, result
	local attempts = 0

	repeat
		attempts += 1
		success, result = pcall(MessagingService.PublishAsync, MessagingService, TOPIC, players)
		task.wait(RETRY_DELAY)
	until success or attempts >= MAX_SEND_RETRIES

	if not success then
		warn(result)
	end

	return success
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
				
			end
		)
		task.wait(RETRY_DELAY)
	until success or attempts >= MAX_SUBSCRIBE_RETRIES

	if not success then
		warn(result)
	end
end

return MessagingProcessor