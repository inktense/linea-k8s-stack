# Linea TX Sender

A service that sends transactions to the Linea blockchain at regular intervals.

## Installation

```bash
npm install
```

## Usage

### Option 1: Using .env file

Create a `.env` file with your configuration:

```env
PRIVATE_KEY=0x...
TO_ADDRESS=0x...
RPC_URL=http://localhost:8545
INTERVAL_SECONDS=1
AMOUNT_WEI=10
```

Then run:
```bash
npm start
```

### Option 2: Command-line arguments

```bash
npm start -- \
  --pk 0x... \
  --address 0x... \
  --rpc http://localhost:8545 \
  --interval 5 \
  --amount 100
```

### Option 3: Mix of .env and command-line

The program uses this precedence:
1. Command-line arguments (highest priority)
2. Environment variables
3. .env file
4. Default values

Example:
```bash
# Override just the interval from command line
npm start -- --interval 10
```

## Command-line Options

- `--pk, --privateKey`: Sender private key (required if not in .env)
- `--address`: Recipient address (required if not in .env)
- `--rpc`: RPC endpoint URL (default: http://localhost:8545)
- `--interval`: Interval in seconds between transactions (default: 1)
- `--amount`: Amount in wei to send (default: 10)

## Examples

Send 100 wei every 5 seconds:
```bash
npm start -- --interval 5 --amount 100
```

Use different RPC endpoint:
```bash
npm start -- --rpc http://192.168.139.2:8545
```

Override all settings:
```bash
npm start -- \
  --pk 0xe874f5517dcc2a358482b7fb250eb9606925ec5c8ae75c26e93e1d820d0f36aa \
  --address 0x1DA9B48928EC505040Eb18a4E1e21aBfCc4Ccc46 \
  --rpc http://localhost:8545 \
  --interval 2 \
  --amount 50
```


