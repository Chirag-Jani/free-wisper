local scriptPath = "/Users/chiragjani/Documents/me/temp/wisp/whisper.cpp"

local mic = hs.menubar.new()
local recording = false

mic:setTitle("IDLE")

hs.hotkey.bind({"alt"}, "space",

  function()
    if not recording then
      recording = true
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
      mic:setTitle("PROC")

      hs.task.new("/bin/bash", function()
        mic:setTitle("IDLE")
      end, {
        "-c",
        "cd " .. scriptPath .. " && ./stop_record.sh"
      }):start()
    end
  end
)
