local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CONFIG = require(ReplicatedStorage.CONFIG)
local Enums = require(ReplicatedStorage.Enums)

local LOGGING = CONFIG.LOGGING

local printFunctionMap = {
	[Enums.LogType.Print] = print;
	[Enums.LogType.Warn] = warn;
	[Enums.LogType.Error] = error;
}

local Log = {}

function log(type, ...)
	if LOGGING then
		local stack = debug.traceback(3)
		local logFunction = printFunctionMap[type]
		logFunction(...)
		logFunction(stack)
	end
end

function Log:print(...)
	log(Enums.LogType.Print, ...)
end

function Log:warn(...)
	log(Enums.LogType.Warn, ...)
end

function Log:error(...)
	log(Enums.LogType.Error, ...)
end

return Log