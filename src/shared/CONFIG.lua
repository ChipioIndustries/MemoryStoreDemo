--constants used by various scripts in the game

return {
	--how often the contents of all memory stores should be printed by MemoryStoreExplorer.lua (in seconds)
	CONTENTS_REFRESH_RATE = 5;

	MATCHMAKING_QUEUE = {
		--the name of the queue passed to MemoryStoreService. WARNING: changing this while servers are running may have unintended consequences.
		NAME = "Matchmaking";
		--how long read values are hidden
		INVISIBILITY_TIMEOUT = 30;
		--max players to read from queue at a time
		READ_BATCH_SIZE = 20;
		--max wait period before call fails
		WAIT_TIMEOUT = 15;
	};

	MUTEX = {
		--name of DataStore containing mutex key
		NAME = "MatchmakingMutex";
		--name of mutex key
		KEY = "AssignedServer";
		--how frequently (in seconds) the server attempts to reserve the mutex
		CLAIM_ATTEMPT_RATE = 20;
	};
}