import sys

BLOCK_LEN = 8192

num_blocks = 1

with open(sys.argv[1], "rb") as f:
    data = f.read()

with open(sys.argv[2], "rb") as f:
    loader = f.read()

bytes_left = (num_blocks * BLOCK_LEN) - (len(data) + len(loader))

if bytes_left < 0:
    print("Binary is too large. We need another 8K block. Adapt this program and the loader")
    sys.exit(42)

print(f"Bytes left in last 8K block: {bytes_left}")

data = loader + data
end_pad = bytearray(BLOCK_LEN)
data = data + end_pad[0:(num_blocks * BLOCK_LEN) - len(data)]

start_offset = 0
end_offset = BLOCK_LEN

with open(sys.argv[3], "wb") as f:
    f.write(data)
    