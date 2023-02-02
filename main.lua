--[[============================================================================
Instrument Randomizer
============================================================================]]--

_AUTO_RELOAD_DEBUG = true

--------------------------------------------------------------------------------
--  Preferences
--------------------------------------------------------------------------------

local options = renoise.Document.create("ScriptingToolPreferences") {
  low_instrument=1, high_instrument=5
}

renoise.tool().preferences = options

--------------------------------------------------------------------------------
-- Helper functions
--------------------------------------------------------------------------------

-- Applys a function to every line in the current pattern selection
local function apply_to_selected_lines(fn)
  local rs = renoise.song()

  local p = rs.selected_pattern_index
  local selection = rs.selection_in_pattern

  for t=selection.start_track, selection.end_track do
    for c=selection.start_column, selection.end_column do
      for l=selection.start_line, selection.end_line do
        local line = rs:pattern(p):track(t):line(l):note_column(c)
        fn(line)
      end
    end
  end
end

--------------------------------------------------------------------------------
-- Main function
--------------------------------------------------------------------------------

-- Randomize's the instrument used by every note in a given selection.
-- If no instrument number is specified inthe pattern it's skipped.
local function randomize_instruments()
  math.randomseed(os.time())
  apply_to_selected_lines(function(line)
    if line.instrument_value ~= renoise.PatternLine.EMPTY_INSTRUMENT then
      line.instrument_value = math.random(
        options.low_instrument.value, options.high_instrument.value)
    end
  end)
end

--------------------------------------------------------------------------------
-- Options dialog
--------------------------------------------------------------------------------

local function show_options()
  local vb = renoise.ViewBuilder()

  local v = vb:column {
    vb:row {
      vb:text { text = "Lowest instrument: " },
      vb:valuebox {
        id = "low_instrument",
        min = 0, max = 254,
        value = options.low_instrument.value,
        notifier = function()
          options.low_instrument.value = vb.views["low_instrument"].value
        end
      }
    },
    vb:row {
      vb:text { text = "Highest instrument: " },
      vb:valuebox {
        id = "high_instrument",
        min = 0, max = 254,
        value = options.high_instrument.value,
        notifier = function()
          options.high_instrument.value = vb.views["high_instrument"].value
        end
      }
    }
  }

  renoise.app():show_custom_dialog("Instrument Randomizer options", v)
end

--------------------------------------------------------------------------------
-- Menu entries
--------------------------------------------------------------------------------

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Selection:Randomize Instruments",
  invoke = randomize_instruments
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Instrument Randomizer:Options",
  invoke = show_options
}

--------------------------------------------------------------------------------
-- Keyboard shortcuts
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Randomize Instruments",
  invoke = randomize_instruments
}

renoise.tool():add_keybinding {
  name = "Global:Instrument Randomizer:Options",
  invoke = show_options
}