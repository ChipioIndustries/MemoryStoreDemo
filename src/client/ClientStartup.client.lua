local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientModules = ReplicatedStorage.ClientModules

local InterfaceController = require(clientModules.InterfaceController)

InterfaceController:init()