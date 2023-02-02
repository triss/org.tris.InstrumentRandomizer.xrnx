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

-- Applys a function to every selected line produced by an iterator
local function apply_to_lines_in_iterator(it, fn)
  for _,line in it do
    fn(line)
  end
end

-- Applys a function to every selected line in a track
local function apply_to_lines_in_selected_track(fn)
  local rs = renoise.song()
  apply_to_lines_in_iterator(
    rs.pattern_iterator:note_columns_in_track(rs.selected_track_index),
    fn
  )
end

-- Applys a function to every selected line in a pattern
local function apply_to_lines_in_selected_pattern(fn)
  local rs = renoise.song()
  apply_to_lines_in_iterator(
    rs.pattern_iterator:note_columns_in_pattern(rs.selected_pattern_index),
    fn
  )
end

-- Applys a function to every selected line in the current pattern selection
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

-- Randomize's the instrument used by note on line
-- If no instrument number is specified on the line it's skipped
function randomize_instrument(line)
  if line.instrument_value ~= renoise.PatternLine.EMPTY_INSTRUMENT then
    line.instrument_value = math.random(
      options.low_instrument.value, options.high_instrument.value)
  end
end

-- Randomize's the instrument used by every note in a given selection.
local function randomize_instruments_in_selection()
  math.randomseed(os.time())
  apply_to_selected_lines(randomize_instrument)
end

local function randomize_instruments_on_track()
  math.randomseed(os.time())
  apply_to_lines_in_selected_track(randomize_instrument)
end

local function randomize_instruments_in_pattern()
  math.randomseed(os.time())
  apply_to_lines_in_selected_pattern(randomize_instrument)
end

-- Shift the instrument used by a note up within the range specified by options.
-- Wraps the value back round if too high.
local function shift_instrument_up(line)
  if line.instrument_value ~= renoise.PatternLine.EMPTY_INSTRUMENT then
    if line.instrument_value < options.high_instrument.value then
      line.instrument_value = line.instrument_value + 1
    else
      line.instrument_value = options.low_instrument.value
    end
  end
end

-- Shift the instrument used by a note up within the range specified by options.
-- Wraps the value back round if too low.
local function shift_instrument_down(line)
  if line.instrument_value ~= renoise.PatternLine.EMPTY_INSTRUMENT then
    if line.instrument_value > options.low_instrument.value then
      line.instrument_value = line.instrument_value - 1
    else
      line.instrument_value = options.high_instrument.value
    end
  end
end

local function shift_up_instruments_in_selection()
  apply_to_selected_lines(shift_instrument_up)
end

local function shift_down_instruments_in_selection()
  apply_to_selected_lines(shift_instrument_down)
end

local function shift_up_instruments_in_track()
  apply_to_lines_in_selected_track(shift_instrument_up)
end

local function shift_down_instruments_in_track()
  apply_to_lines_in_selected_track(shift_instrument_down)
end

local function shift_up_instruments_in_pattern()
  apply_to_lines_in_selected_pattern(shift_instrument_up)
end

local function shift_down_instruments_in_pattern()
  apply_to_lines_in_selected_pattern(shift_instrument_down)
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
  invoke = randomize_instruments_in_selection
}

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Track:Randomize Instruments",
  invoke = randomize_instruments_on_track
}

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Pattern:Randomize Instruments",
  invoke = randomize_instruments_in_pattern
}

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Selection:Shift Instruments Down",
  invoke = shift_down_instruments_in_selection
}

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Selection:Shift Instruments Up",
  invoke = shift_up_instruments_in_selection
}

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Track:Shift Instruments Down",
  invoke = shift_down_instruments_in_track
}

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Track:Shift Instruments Up",
  invoke = shift_up_instruments_in_track
}

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Pattern:Shift Instruments Down",
  invoke = shift_down_instruments_in_pattern
}

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Pattern:Shift Instruments Up",
  invoke = shift_up_instruments_in_pattern
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Instrument Randomizer:Options",
  invoke = show_options
}

--------------------------------------------------------------------------------
-- Keyboard shortcuts
--------------------------------------------------------------------------------

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Randomize Instruments in Selection",
  invoke = randomize_instruments_in_selection
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Shift Instrument Up in Selection",
  invoke = shift_up_instruments_in_selection
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Shift Instrument Down in Selection",
  invoke = shift_down_instruments_in_selection
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Randomize Instruments on Track",
  invoke = randomize_instruments_on_track
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Randomize Instruments in Pattern",
  invoke = randomize_instruments_in_pattern
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Shift Instrument Up in Track",
  invoke = shift_up_instruments_in_track
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Shift Instrument Down in Track",
  invoke = shift_down_instruments_in_track
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Shift Instrument Up in Pattern",
  invoke = shift_up_instruments_in_pattern
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Shift Instrument Down in Pattern",
  invoke = shift_down_instruments_in_pattern
}

renoise.tool():add_keybinding {
  name = "Pattern Editor:Pattern Operations:Randomize Instruments Options",
  invoke = show_options
}
