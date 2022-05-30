-- Default save behavior that comes with REFRAMEWORK
local cfg = json.load_file("number_fantasy.json")

if not cfg then
  cfg = {
    multi = 25,
    rng = 50,
    randomize = false
  }
end

-- auto creates this file in DATA folder
re.on_config_save(
  function()
    json.dump_file("number_fantasy.json", cfg)
  end
)

-- The actual mod
-- local dmg
local d
local t
-- seems like modifying everything here instead of in POSTDMG worked out better
local function PreDMG(args)
  -- store the incoming arguments in a table
  t = args
  -- original damage for debug
  -- local orig = sdk.to_int64(t[4])
  -- the 4th argument (2 in the actual in game method) is the DMG argument its an INT32
  if not cfg.randomize then
    d = sdk.to_int64(t[4]) * cfg.multi
  else
    local rand = math.random(cfg.multi, cfg.rng)
    d = sdk.to_int64(t[4]) * rand
  end
  -- convert this value back to something the game can read
  t[4] = sdk.to_ptr(d)
  -- display for debugging in REFRAMEWORK UI
  -- dmg = tostring(orig)
end

local function PostDMG(retval)
  return retval
end

-- there are a couple different versions of this behavior in the game but this one seems to do the job
sdk.hook(sdk.find_type_definition("snow.gui.GuiManager"):get_method("setDamageDisp"), PreDMG, PostDMG)

re.on_draw_ui(
  function()
    local changed = false

    if not imgui.collapsing_header("Number Fantasy") then return end
    imgui.text("This mod is purely Cosmetic. I like big damage numbers.")
    imgui.text("1 = no multiplier (default damage numbers)")
    changed, cfg.multi = imgui.slider_int("Multiplier", cfg.multi, 1, 500)

    changed, cfg.randomize = imgui.checkbox("Randomize?", cfg.randomize)
    if cfg.randomize then
      imgui.text("Randomize between Regular Multiplier and This Value.")
      changed, cfg.rng = imgui.slider_int("", cfg.rng, 1, 500)
    end

    imgui.text("Changes will save automatically.")
    imgui.new_line()
    -- imgui.text("Damage: " .. dmg)
  end)
