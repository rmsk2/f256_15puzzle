# f256_15puzzle
Another block shifting puzzle game for the Foenix F256K and F256jr.

You will need `64tass`, a python interpreter and GNU make to assemble the program from source.
If you call `make dist` the following files will be created in the `dist` subfolder of this repo:

- `cart_15.bin` a cartridge image which can be written to a flash expansion cartridge
- `f256_15_01.bin` - `f256_15_03.bin`  which can be written to onboard flash via FoenixMgr
- `f256_15.pgz` a binary which can be run from any drive via `pexec`

You will also find these binaries in the Release section of this repo. This software is relocatable in
flash memory, i.e. it can be written to arbitrary consecutive blocks in onboard flash or a flash cartridge.
