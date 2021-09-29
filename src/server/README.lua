--[[

CROSS-SERVER MATCHMAKING WITH MEMORYSTORESERVICE, DATASTORESERVICE, MESSAGINGSERVICE, AND TELEPORTSERVICE

This serves as an example of how MemoryStoreService can be utilized to create a matchmaking system for players in different servers.

When a player joins a "lobby" server (non-reserved server) they are added to a MemoryStoreQueue automatically.

One server (assigned by a mutex, also tracked using MemoryStoreService) is responsible for reading the queue and grouping players into matches.

When enough players are present to create a match, the server reserves a server to host the match and then broadcasts the server ID along with a list of user IDs via MessagingService to the other lobby servers.

When a lobby server detects a broadcast with one of its players' user IDs, it teleports the player to the server ID.

SYSTEM CONFIGURATION

All contstants are hosted within the ReplicatedStorage.CONFIG module for easy configuration. For more advanced modification, refer to the module API reference below.

MODULE API REFERENCE

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

	MatchmakingProcessor.lua
	A module that controls the matchmaking job.

		void init() - Send matchmaking job to CrossServerMutex.lua

	CrossServerMutex.lua
	A module that handles delegation of tasks to a specific server.

		void init() - Begin occasional attempts to claim control
		void assignJob(table job) - Adds job to a list of jobs to start when mutex control is claimed
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

NOTES

	GetRangeAsync sorts by keys, which are strings. This means numbers must be padded with 0's to sort correctly.
	The exclusiveBounds parameters control where the range starts and ends - these should be key values.
	For example, lower="001" higher="015" will return all values from "002" to "014".

	ReadAsync returns nil if queue is empty.

]]