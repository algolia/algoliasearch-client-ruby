module Algolia
  module Defaults
    TTL = 300
    READ_TIMEOUT = 5000
    WRITE_TIMEOUT = 30000
    CONNECT_TIMEOUT = 2000

    # How many times a 429 is waited out on the same host before it is raised.
    MAX_RATE_LIMIT_RETRIES = 3
    # Seconds waited before a 429 retry when Retry-After is missing or invalid.
    RATE_LIMIT_WAIT = 1
    # Largest wait Kernel#sleep accepts (a 64-bit long, in seconds). A runtime
    # ceiling like the Go and Swift clients', not a client-side maximum wait.
    MAX_RATE_LIMIT_WAIT = 2 ** 63 - 1
  end
end
