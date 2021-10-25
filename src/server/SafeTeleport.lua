local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CONFIG = require(ReplicatedStorage.CONFIG)

local RETRY_DELAY = CONFIG.RETRY_DELAY
local MAX_TELEPORT_RETRIES = CONFIG.TELEPORTATION.MAX_TELEPORT_RETRIES
local TELEPORT_ALL_TIMEOUT = CONFIG.TELEPORTATION.TELEPORT_ALL_TIMEOUT
local FLOOD_DELAY = CONFIG.TELEPORTATION.FLOOD_DELAY

local function SafeTeleport(placeId, players, options)
	local teleportStart = tick()
	local attemptIndex = 0
	local success, result -- define pcall results outside of loop so results can be reported later on
	local teleportFailedError = ""

	local connection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage) -- listen for individual fails
		if table.find(players, player) then -- is this a player this call was teleporting?
			local newOptions

			if success then
				-- if a reserved server was created by the original teleportasync call we need to
				-- avoid making yet another reserved server and instead use the server code returned by TeleportAsync
				if options.ShouldReserveServer then
					newOptions = Instance.new("TeleportOptions")
					newOptions.ReservedServerAccessCode = result.ReservedServerAccessCode
					-- grab the old teleport data
					local oldTeleportData = options:GetTeleportData()
					newOptions:SetTeleportData(oldTeleportData)
				end
			end

			if teleportResult == Enum.TeleportResult.GameFull then
				teleportFailedError = "Target server is full"
				return
			elseif teleportResult == Enum.TeleportResult.Flooded then
				-- hold off for a while, there are too many requests
				task.wait(FLOOD_DELAY)
			else
				task.wait(RETRY_DELAY)
			end

			-- recursively safely teleport the individual player
			local success, result = SafeTeleport(placeId, {player}, (newOptions or options))

			if not success then
				teleportFailedError = result
			end
		end
	end)

	repeat
		success, result = pcall(function()
			return TeleportService:TeleportAsync(placeId, players, options) -- teleport the player in a protected call to prevent erroring
		end)
		attemptIndex += 1
		if not success then
			task.wait(RETRY_DELAY)
		end
	until success or attemptIndex == MAX_TELEPORT_RETRIES -- stop trying to teleport if call was successful, or if retry limit has been reached

	if not success then
		warn(result) -- print the failure reason to output
		connection:Disconnect()
	else
		-- wait until all players have teleported successfully
		local isTimedOut = false
		repeat
			local anyPlayersLeft = false
			for _, player in pairs(players) do
				if player then
					anyPlayersLeft = true
				end
			end
			task.wait()
			isTimedOut = tick() - teleportStart > TELEPORT_ALL_TIMEOUT
		until not anyPlayersLeft or isTimedOut
		connection:Disconnect()
		if isTimedOut then
			return false, teleportFailedError
		end
	end

	return success, result
end

return SafeTeleport