if GRPC == nil then
    return
end

-- Whether the `Eval` method is enabled or not.
GRPC.evalEnabled = false

-- The host the gRPC listens on (use "0.0.0.0" to listen on all IP addresses of the host).
GRPC.host = '0.0.0.0'

-- The port to listen on.
GRPC.port = 50051

-- Whether debug logging is enabled or not.
GRPC.debug = true

-- Limit of calls per second that are executed inside of the mission scripting environment.
--GRPC.throughputLimit = 600

-- Whether the gRPC server should be automatically started for each mission on the DCS instance
-- When `true`, it is not necessary to run `GRPC.load()` inside of a mission anymore.
GRPC.autostart = false

-- Start gRPC
GRPC.load()
