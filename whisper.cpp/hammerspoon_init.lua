
local scriptPath = "/Users/chiragjani/Documents/me/temp/wisp/whisper.cpp"

local mic = hs.menubar.new()
local recording = false

-- Analytics state
local totalWords = 0
local totalSeconds = 0
local recordingStartTime = nil

local function updateMenubar()
  local wpm = 0
  if totalSeconds > 0 then
    wpm = math.floor((totalWords / totalSeconds) * 60)
  end
  mic:setTitle(string.format("IDLE | %dw | %d wpm", totalWords, wpm))
end

mic:setTitle("IDLE")

hs.hotkey.bind({"alt"}, "space",

  function()
    if not recording then
      recording = true
      recordingStartTime = os.time()
      mic:setTitle("REC")

      hs.task.new("/bin/bash", nil, {
        "-c",
        "cd " .. scriptPath .. " && ./start_record.sh"
      }):start()
    end
  end,

  function()
    if recording then
      recording = false
      local elapsed = os.time() - (recordingStartTime or os.time())
      mic:setTitle("PROC")

      hs.task.new("/bin/bash", function(exitCode, stdout, stderr)
        if stdout and stdout ~= "" then
          -- Count words in this transcript
          local words = 0
          for _ in stdout:gmatch("%S+") do
            words = words + 1
          end
          totalWords = totalWords + words
          totalSeconds = totalSeconds + elapsed
        end
        updateMenubar()
      end, {
        "-c",
        "cd " .. scriptPath .. " && ./stop_record.sh"
      }):start()
    end
  end
)
