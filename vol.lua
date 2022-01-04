local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local vol = {}

-- Widget
vol.widget = wibox.widget.textbox()
vol.widget:set_align("right")
vol.widget:set_text("VOLUME")
vol.level = 150
vol.state = ""
vol.mode = "Mono"
vol.channel = "Master"
vol.step = {}
vol.step.small = 3
vol.step.large = 10

-- Getting, formatting and updating widget
function vol.update()
   vol.get()
end

function vol.change(args)
   local cmd = "amixer set " .. vol.channel
   if args.set then
      cmd = cmd .. " " .. args.set .. "%"
   elseif args.dir then
      if args.val then
	 cmd = cmd .. " " .. args.val .. "%"
      else
	 cmd = cmd .. " " .. vol.step.small .. "%"
      end
	 cmd = cmd .. args.dir
   end
   -- naughty.notify { text = "CMD:"..cmd }
   awful.spawn.easy_async_with_shell(cmd,
				     function()
					vol.update()
   end)
end
   

function vol.get()
   awful.spawn.with_line_callback(
      "amixer sget " .. vol.channel,
      {stdout = function(line)
	  -- naughty.notify { text = "LINE:"..line }
	  if string.match(line, "Playback channels") then
	     vol.mode = string.match(line, "Playback channels: (%a+)")
	  end
	  if vol.mode == "Mono" then
	     -- naughty.notify { text = "MONO MODE" }
	     if string.match(line, "Mono:") then
		-- naughty.notify { text = "MONO MODE DATA" }
		local level = string.match(line, "%[(%d+)%%%]")
		vol.level = level
		local state = string.match(line, "%[(%a+)%]")
		vol.state = state
		-- naughty.notify { text = "STATE "..vol.state }
	     end
	  end
	  -- naughty.notify { text = "MODE:"..vol.mode }
	  -- naughty.notify { text = "LEVEL:"..vol.level }
	  vol.refresh()
      end,
       stderr = function(line)
   	  naughty.notify { title = "VOLUME", text = "ERR:"..line }
   end})
      
      -- function(stdout, stderr, reason, exit_code)
      -- 	 naughty.notify({ title = "VOLUME", text = stdout })
      -- 	 for str in stdout do
      -- 	    local mode = string.match(str, "Playback channels: ")
      -- 	    vol.mode = mode
      -- 	    naughty.notify({ title = "VOLUME", text = vol.mode })


	       -- local left, right, state = string.match(str, "Left:.*%[(%d?%d?%d)%%%].*Right:.*%[(%d?%d?%d)%%%].*%[(o[^%]]*)%]")
	       -- vol.left = left
	       -- vol.right = right
	       -- vol.state = state
end

function vol.refresh()
   local prefix = "Vol:"
   -- if vol.mode == "Mono" then
   --    local value = vol.level
   -- end
   local state = "?"
   if vol.state == "on" then
      state = "%"
   elseif vol.state == "off" then
      state = "M"
   end
   -- vol.widget:set_text(prefix .. space .. value .. state .. space)
   vol.widget:set_text(prefix .. vol.level .. state)
   -- naughty.notify({ title = "Volume", text = vol.mode })
end
-- function parse_vol(str)
--    return {volume = string.format("%3d", (vleft + vright)/2), status = vstate}
-- end

-- function format_vol(t)
--    statuses = { ["on"] = "%", ["off"] = "M" }
--    space = " "
--    prefix = "Vol:"
--    value = t['volume']
--    status = statuses[t['status']]
--    return (prefix .. space .. value .. status .. space)
-- end

-- function update_volume(widget)
--    widget:set_markup(format_vol(parse_vol(get_vol())))
-- end

-- update_volume(volume_widget)

-- -- Changing volume
-- function exec_n_call_exit(cmd, exit_func)
--    awful.spawn.with_line_callback(cmd, {exit = exit_func})
-- end

-- function exec_n_upd_volume(cmd)
--    exec_n_call_exit(cmd, function() update_volume(volume_widget) end)
-- end

-- vol_s_step = 2
-- vol_l_step = 10
-- function volume_change(t)
--    setmetatable(t,{__index={step=vol_s_step}})
--    local dir, step =
--       t[1],
--       t[2] or t.step
--    exec_n_upd_volume("amixer set Master " .. step .. "%" .. dir)
-- end

-- function balance_change(t)
--    setmetatable(t,{__index={step=vol_s_step}})
--    local dir, step =
--       t[1],
--       t[2] or t.step
--    if dir == 'L' then
--       dir_left = "+"
--       dir_right = "-"
--    elseif dir == 'R' then
--       dir_left = "-"
--       dir_right = "+"
--    end
--    exec_n_upd_volume("amixer set Master " .. step .. "%" .. dir_left .. "," .. step .. "%" .. dir_right)
-- end

-- function volume_toggle()
--    exec_n_upd_volume("amixer set Master toggle")
-- end

-- -- Widget keys
-- volume_widget:buttons(awful.util.table.join(
--   awful.button({ }, 1, function()
-- 	volume_toggle()
--   end),
--   awful.button({ vol_modkey },
--      1,
--      function()
-- 	awful.util.spawn("pavucontrol")
--      end
--   ),
--   awful.button({ }, 4, function()
-- 	volume_change({"+"})
--   end),
--   awful.button({ }, 5, function()
-- 	volume_change({"-"})
--   end),
--   awful.button({ vol_modkey }, 4, function()
-- 	volume_change({"+", step = vol_l_step})
--   end),
--   awful.button({ "Control" }, 4, function()
-- 	balance_change({"L"})
--   end),
--   awful.button({ "Control" }, 5, function()
-- 	balance_change({"R"})
--   end),
--   awful.button({ vol_modkey }, 5, function()
-- 	volume_change({"-", step = vol_l_step})
--   end)
-- ))

return vol
