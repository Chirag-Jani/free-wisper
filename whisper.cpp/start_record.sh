#!/bin/bash

cd /Users/chiragjani/Documents/me/temp/wisp/whisper.cpp

AUDIO_FILE="recording.wav"
SOX="/opt/homebrew/bin/sox"

rm -f $AUDIO_FILE
rm -f .rec_pid

$SOX -d -r 16000 -c 1 -b 16 $AUDIO_FILE &
REC_PID=$!

# IMPORTANT: save PID so stop script can kill it

echo $REC_PID > .rec_pid

# keep recording alive

wait $REC_PID

