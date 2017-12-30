local wibox = require("wibox")
local awful = require("awful")

function append_global_keys(keys)
   for i = 1, #keys do
      globalkeys = awful.util.table.join(globalkeys, keys[i])
   end
end

-- Widget
volume_widget = wibox.widget.textbox()
volume_widget:set_align("right")

-- Mod to increase volume step
vol_modkey = modkey

-- Getting, formatting and updating widget
function get_vol()
   local fd = io.popen("amixer sget Master")
   local status = fd:read("*all")
   fd:close()
   return status
end

function parse_vol(str)
   local vleft, vright, vstate = string.match(str, "Left:.*%[(%d?%d?%d)%%%].*Right:.*%[(%d?%d?%d)%%%].*%[(o[^%]]*)%]")
   return {volume = string.format("%3d", (vleft + vright)/2), status = vstate}
end

function format_vol(t)
   statuses = { ["on"] = "%", ["off"] = "M" }
   space = " "
   prefix = "Vol:"
   value = t['volume']
   status = statuses[t['status']]
   return (prefix .. space .. value .. status .. space)
end

function update_volume(widget)
   widget:set_markup(format_vol(parse_vol(get_vol())))
end

update_volume(volume_widget)

-- Changing volume
function exec_n_call_exit(cmd, exit_func)
   awful.spawn.with_line_callback(cmd, {exit = exit_func})
end

function exec_n_upd_volume(cmd)
   exec_n_call_exit(cmd, function() update_volume(volume_widget) end)
end

vol_s_step = 2
vol_l_step = 10
function volume_change(t)
   setmetatable(t,{__index={step=vol_s_step}})
   local dir, step =
      t[1],
      t[2] or t.step
   exec_n_upd_volume("amixer set Master " .. step .. "%" .. dir)
end

function balance_change(t)
   setmetatable(t,{__index={step=vol_s_step}})
   local dir, step =
      t[1],
      t[2] or t.step
   if dir == 'L' then
      dir_left = "+"
      dir_right = "-"
   elseif dir == 'R' then
      dir_left = "-"
      dir_right = "+"
   end
   exec_n_upd_volume("amixer set Master " .. step .. "%" .. dir_left .. "," .. step .. "%" .. dir_right)
end

function volume_toggle()
   exec_n_upd_volume("amixer set Master toggle")
end

-- Widget keys
volume_widget:buttons(awful.util.table.join(
  awful.button({ }, 1, function()
	volume_toggle()
  end),
  awful.button({ vol_modkey },
     1,
     function()
	awful.util.spawn("pavucontrol")
     end
  ),
  awful.button({ }, 4, function()
	volume_change({"+"})
  end),
  awful.button({ }, 5, function()
	volume_change({"-"})
  end),
  awful.button({ vol_modkey }, 4, function()
	volume_change({"+", step = vol_l_step})
  end),
  awful.button({ "Control" }, 4, function()
	balance_change({"L"})
  end),
  awful.button({ "Control" }, 5, function()
	balance_change({"R"})
  end),
  awful.button({ vol_modkey }, 5, function()
	volume_change({"-", step = vol_l_step})
  end)
))

-- Global keys
append_global_keys(
   {
      awful.key({ }, "XF86AudioRaiseVolume", function () volume_change({"+"}) end),
      awful.key({ }, "XF86AudioLowerVolume", function () volume_change({"-"}) end),
      awful.key({ vol_modkey }, "XF86AudioRaiseVolume", function () volume_change({"+", step = vol_l_step}) end),
      awful.key({ vol_modkey }, "XF86AudioLowerVolume", function () volume_change({"-", step = vol_l_step}) end),
      awful.key({ }, "XF86AudioMute", function () volume_toggle() end)
   }
)
