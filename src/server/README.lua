--[[

CROSS-SERVER MATCHMAKING WITH MEMORYSTORESERVICE, DATASTORESERVICE, MESSAGINGSERVICE, AND TELEPORTSERVICE

This serves as an example of how MemoryStoreService can be utilized to create a matchmaking system for players in different servers.

When a player joins a "lobby" server (non-reserved server) they are added to a MemoryStoreQueue automatically.

One server (assigned by a mutex, also tracked using MemoryStoreService) is responsible for reading the queue and grouping players into matches.

When enough players are present to create a match, the server reserves a server to host the match and then broadcasts the server ID along with a list of user IDs via MessagingService to the other lobby servers.

When a lobby server detects a broadcast with one of its players' user IDs, it teleports the player to the server ID.

LICENSE

You are free to use this code in any way for any reason.
If it breaks or causes something to break, it's not my fault.
Whatever you make with this must be extremely cool.
If you ask me a question that is already answered in this file I will scream incoherently.

SYSTEM CONFIGURATION

All contstants are hosted within the ReplicatedStorage/CONFIG.lua module for easy configuration. For more advanced modification, refer to the module API reference below.

MODULE API REFERENCE

	CONFIG.lua
	Duh. Change stuff in here.

	CrossServerMutex.lua
	A module that handles delegation of tasks to a specific server.

		void init() - Begin occasional attempts to claim control
		void assignJob(dictionary job) - Adds job to a list of jobs to start when mutex control is claimed
		boolean releaseAsync() - Waits for all jobs to complete and then releases control over the mutex
		void requestReservation() - Attempt to claim mutex control. This is primarily to be called by the init method.

		Sample Job:
		{
			void function startJob() - callback to start job
			void function releaseAsync() - callback to end job as soon as possible. should yield until job is cleaned up.
		}

	GetServerType.lua
	A function that returns the current server type based on whether or not a reserved server ID is present.

		Usage:
		if GetServerType() == Enums.ServerType.Lobby then
			print("lobby")
		end

	Enums.lua
	A dictionary of strings to be compared against one another.

	MatchmakingProcessor.lua
	A module that controls the matchmaking job.

		void init() - Send matchmaking job to CrossServerMutex.lua
		bool addPlayer(int userId) - Add player to matchmaking queue. Returns whether or not it was successful.

	MemoryStoreExplorer.lua
	Occasionally prints contents of all MemoryStores across the game. Useful for debugging.

		void init() - Begin printing memorystore contents
		boolean registerQueueKey(string queueKey) - Enables tracking on the given queue key.
		boolean registerSortedMapKey(string sortedMapKey) - Enables tracking on the given sorted map key.
		dictionary getQueuesContents() - Returns full contents of all tracked queues.
		dictionary getSortedMapsContents() - Returns full contents of all tracked sorted maps.
		dictionary getAllContents() - Returns full contents of all tracked queues and sorted maps.

		Example getAllContents result:
		{
			queuesContents = {
				myQueue = {
					"hello world";
					"hello world again"
				}
			};
			sortedMapsContents = {
				myMap = {
					{
						"key" = "hello";
						"value" = "world"
					}
				}
			}
		}

	MessagingProcessor.lua
	Handles the sending and receiving of match data across servers.

		void init() - Start listening for new matches.
		void bindToMatchReceipt(function(dictionary match) callback) - Add function to run when a match is received
		bool sendMatch(dictionary match) - Sends match data to other servers and returns if the call succeeded

		Example match data:
		{
			players = {18697683, 904822237};
			reservedServerCode = "pretendthisisareservedservercode";
		}

	PlayerTeleportHandler.lua
	Handles the teleportation of players to lobby and match servers.

		void init() - Start listening for matches if the server is a lobby
		void endMatch() - Teleport all players back to a lobby, allowing the server to close

	SafeTeleport.lua
	A teleport function with integrated retries. A drop-in replacement for TeleportService:TeleportAsync().

	TableUtility.lua
	A module of functions for dealing with immutable tables (it's not Cryo, don't think it's Cryo)

		table removeRange(table table, int start, int stop) - returns new table minus [start, stop] range.
		table join(table1, table2...) - returns a new table containing contents of all provided tables.
										order of arguments determines final order in table.

NOTES

	GetRangeAsync sorts by keys, which are strings. This means numbers must be padded with 0's to sort correctly.
	The exclusiveBounds parameters control where the range starts and ends - these should be key values.
	For example, lower="001" higher="015" will return all values from "002" to "014".

	ReadAsync returns nil if queue is empty.

	I wish I could have syntax higlighting in comments, my eyes are bleeding.

	What happens if a group teleport fails for a select number of players?
	Can I retry with the same table of players or will that throw an error?
	TODO: ask eric

]]