local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CONFIG = require(ReplicatedStorage.CONFIG)

local RETRY_DELAY = CONFIG.RETRY_DELAY
local MAX_TELEPORT_RETRIES = CONFIG.TELEPORTATION.MAX_TELEPORT_RETRIES

local function SafeTeleport(placeId, players, options)
	local attempt = 0
	local success, result --define pcall results outside of loop so results can be reported later on

	repeat
		attempt += 1
		success, result = pcall(function()
			--teleport the player in a protected call to prevent erroring
			return TeleportService:TeleportAsync(placeId, players, options)
		end)
		task.wait(RETRY_DELAY)
	until success or attempt == MAX_TELEPORT_RETRIES --stop trying to teleport if call was successful, or if retry limit has been reached

	if not success then
		warn(result, debug.traceback()) --print the failure reason to output
	end

	return success, result
end

return SafeTeleport