--[[

CROSS-SERVER MATCHMAKING WITH MEMORYSTORESERVICE, DATASTORESERVICE, MESSAGINGSERVICE, AND TELEPORTSERVICE

This serves as an example of how MemoryStoreService can be utilized to create a matchmaking system for players in different servers.

When a player joins a "lobby" server (non-reserved server) they are added to a MemoryStoreQueue automatically.

One server (assigned by a mutex, tracked using DataStoreService) is responsible for reading the queue and grouping players into matches.

When enough players are present to create a match, the server reserves a server to host the match and then broadcasts the server ID along with a list of user IDs via MessagingService to the other lobby servers.

When a lobby server detects a broadcast with one of its players' user IDs, it teleports the player to the server ID.

LICENSE

You are free to use this code in any way for any reason.
If it breaks or causes something to break, it's not my fault.
Whatever you make with this must be extremely cool.
If you ask me a question that is already answered in this file I will scream incoherently.

SYSTEM CONFIGURATION

All contstants are hosted within the ReplicatedStorage/CONFIG.lua module for easy configuration. For more advanced modification, refer to the module API reference below.

ARCHITECTURE

This example uses a Single-Script Architecture (SSA) where the code is divided up into "modules" which are required by a single script
on the server and client and initialized in a specific order. This is done to make the individual systems easier to understand and easier
to move to other projects, as well as preventing race conditions (i.e. the cross-server mutex starting all jobs before the matchmaking job has registered.)

MODULE API REFERENCE

	CONFIG.lua
	Duh. Change stuff in here.

	ClientRequestHandler.lua
	A module that receives user input and processes it accordingly.

		void init() - Bind functions to their associated remotes
		void requestAddToMatchmaking(Player player) - Add player to matchmaking queue if they aren't already in it
		void requestEndMatch(Player player) - Cast player vote to end the match and return to lobby

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

	Enums.lua
	A dictionary of strings to be compared against one another.

	GetServerType.lua
	A function that returns the current server type based on whether or not a reserved server ID is present.

		Usage:
		if GetServerType() == Enums.ServerType.Lobby then
			print("lobby")
		end

	InterfaceController.lua
	Loads the interface into the PlayerGui and handles transmitting user input to the server.

		void init() - Loads the interface, updates UI, and connects listeners.

	Log.lua
	Drop-in replacements for logging functions (print, warn, error) with a shutoff switch and call stacks

		void print(tuple contents) - print contents with plain white text
		void warn(tuple contents) - print contents with bold yellow text
		void error(tuple contents) - print contents in red and kill the thread

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
		table join(tuple tables) - returns a new table containing contents of all provided tables.
									order of arguments determines final order in table.

NOTES

	GetRangeAsync sorts by keys, which are strings. This means numbers must be padded with 0's to sort correctly.
	The exclusiveBounds parameters control where the range starts and ends - these should be key values.
	For example, lower="001" higher="015" will return all values from "002" to "014".

	ReadAsync returns nil if queue is empty.

	I wish I could have syntax higlighting in comments, my eyes are bleeding.

	GetServerType MUST be called on the server because game.PrivateServerId doesn't replicate
	to the client for some reason.

]]