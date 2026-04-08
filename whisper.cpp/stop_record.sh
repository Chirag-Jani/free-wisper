#!/bin/bash

cd /Users/chiragjani/Documents/me/temp/wisp/whisper.cpp

BASE_MODEL="./models/ggml-base.en.bin"
LARGE_MODEL="./models/ggml-large-v3.bin"

AUDIO_FILE="recording.wav"
OLLAMA="/usr/local/bin/ollama"

USE_LLM=false
USE_LARGE=false

# ===== STOP RECORDING =====

if [ ! -f .rec_pid ]; then
exit 0
fi

REC_PID=$(cat .rec_pid)

kill -2 $REC_PID 2>/dev/null
sleep 0.5
kill -9 $REC_PID 2>/dev/null

rm -f .rec_pid

# ===== CHECK FILE =====

if [ ! -f $AUDIO_FILE ]; then
exit 1
fi

# ===== SELECT MODEL =====

MODEL_PATH=$BASE_MODEL

if [ "$USE_LARGE" = true ]; then
MODEL_PATH=$LARGE_MODEL
fi

# ===== TRANSCRIBE =====

TRANSCRIPT=$(./build/bin/whisper-cli -m $MODEL_PATH -f $AUDIO_FILE -nt)

FINAL="$TRANSCRIPT"

# ===== OPTIONAL LLM =====

if [ "$USE_LLM" = true ]; then
PROMPT="Fix grammar and punctuation only. Do not change meaning:

$TRANSCRIPT"

FINAL=$($OLLAMA run qwen2.5:7b "$PROMPT")
fi

# ===== COPY + PASTE (FIXED) =====

echo "$FINAL" | /usr/bin/pbcopy

osascript -e 'tell application "System Events" to keystroke "v" using command down'

# ===== CLEANUP =====

rm -f $AUDIO_FILE

# ===== OUTPUT FOR LUA =====
echo "$FINAL"
