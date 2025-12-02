allow-empty-blocks = false

[persistence]
data-path="/opt/consensys/maru/data"
private-key-path="/opt/consensys/maru/key"

[qbft]
fee-recipient = "0x0000000000000000000000000000000000000000"

[p2p]
port = 9000
ip-address = "0.0.0.0"
static-peers = []
reconnect-delay = "500 ms"

[p2p.discovery]
port = 9000
refresh-interval = "2 seconds"

[p2p.reputation]
cooldown-period = "2 seconds"
ban-period = "30 seconds"

[payload-validator]
engine-api-endpoint = { endpoint = "http://{{ include "linea.fullname" . }}-sequencer-svc:8550" }
eth-api-endpoint    = { endpoint = "http://{{ include "linea.fullname" . }}-sequencer-svc:8545" }

[follower-engine-apis]
follower-besu = { endpoint = "http://{{ include "linea.fullname" . }}-besu-svc:8550" }

[observability]
port = 9545
jvm-metrics-enabled = false
prometheus-metrics-enabled = true

[api]
port = 8080

[syncing]
peer-chain-height-polling-interval = "1 seconds"
el-sync-status-refresh-interval = "1 seconds"
use-unconditional-random-download-peer = false
sync-target-selection = "Highest"