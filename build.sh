#!/bin/bash

# Parse some command line arguments
while [ $# -gt 0 ]
do
    case "$1" in
        -1k)    PCF=icestick.pcf
                DEV=1k
                shift
                ;;
        -8k)    PCF=ice40hx8k-bb.pcf
                DEV=8k
                shift
                ;;
        -S)     ICEPROG_ARGS=-S
                shift
                ;;
        *)
                break
                ;;
    esac
done

# Build with open source tools
if [ -z "$1" ]
then
    echo Usage: build.sh [-1k] [-8k] [-S] main_name [other .v files]
    echo Example: ./build.sh demo library.v
    exit 1
fi    
set -e   # exit if any tool errors
MAIN=$1
shift
echo Using yosys to synthesize design
yosys -p "synth_ice40 -blif $MAIN.blif" $MAIN.v $@
echo Place and route with arachne-pnr
arachne-pnr -d ${DEV} -p ${PCF} $MAIN.blif -o $MAIN.txt
echo Converting ASCII output to bitstream
icepack $MAIN.txt $MAIN.bin
echo Sending bitstream to device
iceprog ${ICEPROG_ARGS} $MAIN.bin
