local mic = hs.menubar.new()
mic:setTitle("⚪️")

local recording = false
local audioFile = "/tmp/whisper.wav"
local recorder = nil

local WHISPER = "/Users/chiragjani/Documents/me/temp/wisp/whisper.cpp/build/bin/whisper-cli"
local MODEL = "/Users/chiragjani/Documents/me/temp/wisp/whisper.cpp/models/ggml-base.en.bin"
local OLLAMA_MODEL = "qwen2.5:7b"

hs.hotkey.bind({"alt"}, "space",

  function() -- key down
    if not recording then
      recording = true
      mic:setTitle("🔴")

      recorder = hs.audiodevice.defaultInputDevice():startRecording(audioFile)
    end
  end,

  function() -- key up
    if recording then
      recording = false
      mic:setTitle("🟡")

      recorder:stop()

      -- run whisper + ollama
      hs.task.new("/bin/bash", function(_, out, err)
        mic:setTitle("⚪️")
        print(out)
        print(err)
        hs.alert.show("✅ Done")
      end, {
        "-c",
        WHISPER .. " -m " .. MODEL .. " -f " .. audioFile .. " -nt | " ..
        "ollama run " .. OLLAMA_MODEL .. " \"Fix grammar only. Keep meaning same:\" | pbcopy && osascript -e 'tell application \"System Events\" to keystroke \"v\" using command down'"
      }):start()
    end
  end
)
