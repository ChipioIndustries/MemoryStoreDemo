--[[

CROSS-SERVER MATCHMAKING WITH MEMORYSTORESERVICE, DATASTORESERVICE, MESSAGINGSERVICE, AND TELEPORTSERVICE

This serves as an example of how MemoryStoreService can be utilized to create a matchmaking system for players in different servers.

When a player joins a "lobby" server (non-reserved server) they are added to a MemoryStoreQueue automatically.

One server (assigned by a mutex, also tracked using MemoryStoreService) is responsible for reading the queue and grouping players into matches.

When enough players are present to create a match, the server reserves a server to host the match and then broadcasts the server ID along with a list of user IDs via MessagingService to the other lobby servers.

When a lobby server detects a broadcast with one of its players' user IDs, it teleports the player to the server ID.

MODULE API REFERENCE

	MemoryStoreExplorer.lua
	Occasionally prints contents of all MemoryStores across the game. Useful for debugging.
	boolean registerQueueKey(string queueKey) - Enables tracking on the given queue key.
	boolean registerSortedMapKey(string sortedMapKey) - Enables tracking on the given sorted map key.
	dictionary getQueuesContents() - Returns full contents of all tracked queues.
	dictionary getSortedMapsContents() - Returns full contents of all tracked sorted maps.
	dictionary getAllContents() - Returns full contents of all tracked queues and sorted maps.

NOTES

	GetRangeAsync sorts by keys, which are strings. This means numbers must be padded with 0's to sort correctly.
	The exclusiveBounds parameters control where the range starts and ends - these should be key values.
	For example, lower="001" higher="015" will return all values from "002" to "014".

]]