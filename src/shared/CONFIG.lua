--constants used by various scripts in the game

return {
	--how often the contents of all memory stores should be printed by MemoryStoreExplorer.lua (in seconds)
	CONTENTS_REFRESH_RATE = 5;

	MATCHMAKING_QUEUE = {
		--the name of the queue passed to MemoryStoreService. WARNING: changing this while servers are running may have unintended consequences.
		NAME = "Matchmaking";
		--how long read values are hidden
		INVISIBILITY_TIMEOUT = 60;
		--max players to read from queue at a time
		READ_BATCH_SIZE = 20;
		--max wait period before call fails
		WAIT_TIMEOUT = 15;
		--the number of seconds to wait between queue retrievals
		QUEUE_RETRIEVAL_RATE = 1;
		--maximum number of attempts to add a player to the queue
		MAX_ADD_RETRIES = 5;
		--how many seconds the player will be in the matchmaking queue for
		QUEUE_ENTRY_LIFETIME = 300;
	};

	MUTEX = {
		--name of DataStore containing mutex key
		NAME = "MatchmakingMutex";
		--name of mutex key
		KEY = "AssignedServer";
		--how frequently (in seconds) the server attempts to reserve the mutex
		CLAIM_ATTEMPT_RATE = 20;
	};

	MATCH = {
		SIZE = {
			--minimum number of players in a match
			MIN = 2;
			--maximum number of players in a match
			MAX = 8;
		}

	}
}