local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Enums)

local function GetServerType()
	if game.PrivateServerId ~= "" then
		return Enums.ServerType.Match
	else
		return Enums.ServerType.Lobby
	end
end

return GetServerType