local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientModules = ReplicatedStorage.ClientModules

local Log = require(ReplicatedStorage.Log)

local InterfaceController = require(clientModules.InterfaceController)

InterfaceController:init()