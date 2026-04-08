local scriptPath = "/Users/chiragjani/Documents/me/temp/wisp/whisper.cpp"
local statsFile = os.getenv("HOME") .. "/.hammerspoon/whisper_stats.json"

local mic = hs.menubar.new()
local recording = false

-- Analytics state
local totalWords = 0
local totalSeconds = 0
local recordingStartTime = nil

-- ===== STATS HELPERS =====

local function getToday()
  return os.date("%Y-%m-%d")
end

local function loadStats()
  local f = io.open(statsFile, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(hs.json.decode, content)
  if ok and data then return data end
  return {}
end

local function saveStats(data)
  local f = io.open(statsFile, "w")
  if not f then return end
  f:write(hs.json.encode(data))
  f:close()
end

local function initToday(data)
  local today = getToday()
  if not data[today] then
    data[today] = { words = 0, seconds = 0 }
  end
  return today
end

-- ===== LOAD ON STARTUP =====

local stats = loadStats()
local today = initToday(stats)
totalWords = stats[today].words
totalSeconds = stats[today].seconds

-- ===== MENUBAR =====

local function updateMenubar()
  local wpm = 0
  if totalSeconds > 0 then
    wpm = math.floor((totalWords / totalSeconds) * 60)
  end
  mic:setTitle(string.format("IDLE | %dw | %d wpm", totalWords, wpm))
end

updateMenubar()

-- ===== HOTKEY =====

hs.hotkey.bind({"alt"}, "space", function()
  if not recording then
    recording = true
    recordingStartTime = os.time()
    mic:setTitle("REC")

    hs.task.new("/bin/bash", nil, {
      "-c",
      "cd " .. scriptPath .. " && ./start_record.sh"
    }):start()
  else
    recording = false
    local elapsed = os.time() - (recordingStartTime or os.time())
    mic:setTitle("PROC")

    hs.task.new("/bin/bash", function(exitCode, stdout, stderr)
      if stdout and stdout ~= "" then
        local words = 0
        for _ in stdout:gmatch("%S+") do
          words = words + 1
        end
        totalWords = totalWords + words
        totalSeconds = totalSeconds + elapsed

        -- Save to file
        local data = loadStats()
        local day = initToday(data)
        data[day].words = totalWords
        data[day].seconds = totalSeconds
        saveStats(data)
      end
      updateMenubar()
    end, {
      "-c",
      "cd " .. scriptPath .. " && ./stop_record.sh"
    }):start()
  end
end)
