#!/bin/bash
# Build with open source tools
if [ -z "$1" ]
then
    echo Usage: build.sh main_name [other .v files]
    echo Example: ./build.sh demo library.v
    exit 1
fi    
set -e   # exit if any tool errors
MAIN=$1
shift
echo Using yosys to synthesize design
yosys -p "synth_ice40 -blif $MAIN.blif" $MAIN.v $@
echo Place and route with arachne-pnr
arachne-pnr -d 1k -p icestick.pcf $MAIN.blif -o $MAIN.txt
echo Converting ASCII output to bitstream
icepack $MAIN.txt $MAIN.bin
echo Sending bitstream to device
iceprog $MAIN.bin

