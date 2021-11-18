rpi-tuner: scripts for initial Raspberry Pi setup automotion

Usage:

1. connect SD card to your linux host
2. run

```
   sudo ./install-raspios-lite-arm64-bullseye.sh <SD card device> <rpi hostname>
```
e.g.

```
   sudo ./install-raspios-lite-arm64-bullseye.sh /dev/mmcblk0 rpi3b
```

3. insert the SD card into your Raspberry Pi board
4. connect your Raspberry Pi board to Ethernet network with DHCP server
5. turn your Raspberry Pi on
6. connect to your Raspberry Pi via ssh, e.g.

```
   ssh pi@rpi3b
   ...
   pi@rpi3b's password: raspberry
```
