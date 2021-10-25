--constants used by various scripts in the game

return {
	--how often the contents of all memory stores should be printed by MemoryStoreExplorer.lua (in seconds)
	CONTENTS_REFRESH_RATE = 5;
	--seconds between network call retry attempts
	RETRY_DELAY = 0.3;
	--should status messages be loggged?
	LOGGING = true;

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
		
		PROCESSING_YIELD = {
			--how long to wait between each processing of the cache
			YIELD = 0.2;
			--how long to wait between each processing of the cache during low player count
			EXTENDED_YIELD = 3;
			--how large the cache can be before yield is used instead of extended yield
			EXTENDED_YIELD_MAX_CACHE_SIZE = 30;
		};
	};

	TELEPORTATION = {
		--maximum number of attempts to teleport players to the match
		MAX_TELEPORT_RETRIES = 5;
	};

	MATCH_MESSAGING = {
		--the topic to subscribe and publish to with messagingservice
		TOPIC = "Matchmaking";
		--maximum number of attempts to start a match
		MAX_SEND_RETRIES = 5;
		--maximum number of attempts to subscribe to the topic
		MAX_SUBSCRIBE_RETRIES = 500; --we REALLY don't want this failing
	};

	MUTEX = {
		--name of DataStore containing mutex key
		NAME = "MatchmakingMutex";
		--name of mutex key
		KEY = "AssignedServer";
		--how frequently (in seconds) the server attempts to reserve the mutex
		CLAIM_ATTEMPT_RATE = 10;
	};

	MATCH = {
		SIZE = {
			--minimum number of players in a match
			MIN = 1;
			--maximum number of players in a match
			MAX = 8;
		}
	}
}