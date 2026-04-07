#!/bin/bash

# ===== CONFIG =====

MODEL_PATH="./models/ggml-base.en.bin"
AUDIO_FILE="recording.wav"
OLLAMA_MODEL="qwen2.5:7b"

# ===== RECORD AUDIO (controlled) =====

echo "🎤 Recording... (waiting for stop)"

sox -d $AUDIO_FILE &
REC_PID=$!

# wait for ENTER (sent by Hammerspoon on key release)

read -r

echo "⏹ Stopping recording..."
kill -INT $REC_PID
wait $REC_PID

# ===== TRANSCRIBE =====

echo "🧠 Transcribing..."
TRANSCRIPT=$(./build/bin/whisper-cli -m $MODEL_PATH -f $AUDIO_FILE -nt)

echo "RAW:"
echo "$TRANSCRIPT"

# ===== CLEAN WITH LLM =====

echo "✨ Formatting..."

PROMPT="Fix grammar and punctuation only. Do not change meaning. Return a single clean sentence:

$TRANSCRIPT"

CLEANED=$(ollama run $OLLAMA_MODEL "$PROMPT")

# ===== COPY + PASTE =====

echo "$CLEANED" | pbcopy
osascript -e 'tell application "System Events" to keystroke "v" using command down'

# ===== CLEANUP =====

rm $AUDIO_FILE

