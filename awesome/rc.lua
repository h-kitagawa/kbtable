-- Standard awesome library
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")



-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/h7k/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "st"
editor = "emacs"
editor_cmd = "st -e jed"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "Manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   -- { "Restart Awesome", awesome.restart },
   { "Logout", function() awesome.quit() end },
   { "Suspend", "sudo systemctl suspend" },
   { "Reboot", "sudo systemctl reboot" },
   { "Shutdown", "sudo systemctl poweroff" }
}

myvmmenu = {
	    { "VM  OpenBSD", terminal .. " -e /opt/home-supp/qemu-vm/openbsd.sh"},
	    { "SSH OpenBSD", terminal .. " -e ssh -p 10022 localhost"},
}

mymainmenu = awful.menu({ items = { { "Terminal", terminal },
				    { "Jed", editor_cmd },
				    { "Emacs", 'emacs' },
				    { "nano", terminal .. " -e nano"},
				    { "VMs", myvmmenu },
				    { "Firefox", "/opt/firefox/firefox --private-window"},
				    { "Google Chrome", "google-chrome-beta"},
				    { "Sylpheed", "sylpheed"},
				    { "Simutrans", "/opt/home-supp/simutrans/sim"},
				    { "awesome", myawesomemenu, beautiful.awesome_icon }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%H%M.%S ",1,'+09:00')
-- Create a textclock widget
mykblayout = wibox.widget.textbox()
mykblayout:set_align("right")
-- Create a systray
mysystray = wibox.widget.systray()
mysystray:set_base_size(nil)
mysystray:set_horizontal(true)


-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local cpu_temp = {}
function cpu_update()
   local max_temp = 0
   for s = 0, 3 do
      file = io.open("/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp" .. (s+1) .. "_input", "r")
      cpu_temp[s]= file:read ("*n")/1000
      if cpu_temp[s]>max_temp then max_temp = cpu_temp[s] end
      file:close()
  end
end 

local mem_info = {}
function mem_update()
   local memtotal, memfree, buff, cached, swapfree, swaptotal
   local str, val
   local file = assert(io.open("/proc/meminfo", "r"))
   for line in file:lines() do
      str, val = string.match(line, "([%w_]+):\ +(%d+)")
      if str == "MemTotal" then
	 memtotal = val
      elseif str == "MemFree" then
	 memfree = val
      elseif str == "Buffers" then
	 buff = val
      elseif str == "Cached" then
	 cached = val
      elseif str == "SwapFree" then
	 swapfree = val
      elseif str == "SwapTotal" then
	 swaptotal = val
      end
   end
   file:close()
   mem_info ["usage"] = memtotal - ( memfree + buff + cached ) 
   mem_info ["total"] = memtotal
   mem_info ["cached"] = cached
   mem_info ["swapusage"] = swaptotal-swapfree
   mem_info ["swaptotal"] = swaptotal
   return 
end 

local net_info = nil
function net_update()
   local file = io.open("/proc/net/dev")
   local recv = 0
   local send = 0
   for line in file:lines() do
      -- Match wmaster0 as well as rt0 (multiple leading spaces)
      if string.match(line, "^[%s]?[%s]?[%s]?[%s]?[%w]+:") then
	 -- Received bytes, first value after the name
	 recv = recv + tonumber(string.match(line, ":[%s]*([%d]+)"))
	 -- Transmited bytes, 7 fields from end of the line
	 send = send + tonumber(string.match(line,
					    "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))
      end
   end
   file:close()
   if net_info == nil then
      -- Default values on the first run
      net_info = {}
      net_info[ "drate" ]=0
      net_info[ "urate" ]=0
      net_info.time = os.time()
   else
      -- Net stats are absolute, substract our last reading
      local interval = os.time() - net_info.time
      net_info.time = os.time()
      net_info["drate"]= (recv - net_info["dall"])/interval
      net_info["urate"]= (send - net_info["uall"])/interval
   end
   net_info["dall"]=recv
   net_info["uall"]=send
   return 
end 

function num_readable(nume)
   local num = tonumber(nume)
   local unit
   if num==nil then return "  N/A " end
   if num < 1024 then return string.format(" %4i ",num) end
   if num < 1048576 then 
      num = num / 1024
      unit = "K"
   else if num < 1073741824 then 
	 num = num / 1048576
	 unit = "M"
      else 
	 num = num / 1073741824
	 unit = "G"
      end
   end
   if num < 10 then
      return string.format("%5.2f",math.floor(num*100+0.5)/100) .. unit
   end
   if num < 100 then
      return string.format("%5.2f",math.floor(num*100+0.5)/100) .. unit
   end
   return string.format("%5d",math.floor(num+0.5)) .. unit

end

timers  = {}
widgets = {}

widgets["Clbl"] = wibox.widget.textbox()
widgets["Clbl"]:set_align("left")
widgets["Clbl"]:set_text("CPU")

function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end

widgets["caps"] = wibox.widget.textbox()
widgets["caps"]:set_text("Caps")

timers[1]  = timer({ timeout = 2 })
timers[1]:connect_signal("timeout", cpu_update)
timers[1]:start()
timers[2] = timer({ timeout = 2 })
timers[2]:connect_signal("timeout",
			   function() 
				local y =  "<b><span color=\"#00ffff\">CPU</span></b> "
				for s = 0, 3 do
				   y = y .. string.format("%2i ", cpu_temp[s] or 0);
				end

				mem_update()
				y = y .. " <b><span color=\"#00ffff\">RAM</span></b> " .. num_readable(mem_info["usage"]*1024) 
				y = y .. "/" .. num_readable(mem_info["cached"]*1024) .. "/" .. num_readable(mem_info["total"]*1024)
				y = y .. " <b><span color=\"#00ffff\">SWAP</span></b> " .. num_readable(mem_info["swapusage"]*1024)
				y = y .. "/" .. num_readable(mem_info["swaptotal"]*1024)
				
				net_update()
				y = y .. " <b><span color=\"#00ffff\">Net </span></b>" 
				y = y .. "<span color=\"#ff5f5f\">D "
				y = y ..  num_readable(net_info["drate"]) 
				y = y ..  "[" .. num_readable(net_info["dall"]) .. "]</span> "
				y = y .. "<span color=\"#5fff5f\">U "
				y = y ..  num_readable(net_info["urate"]) 
				y = y ..  "[" .. num_readable(net_info["uall"]) .. "]</span>"
				
				widgets["Clbl"]:set_markup(y)
			     end)

timers[2]:stop()

-- Quake like console on top
local quake = require("quake")

local quakeconsole = {}
do
    local quake = require("quake")
    awful.screen.connect_for_each_screen(function(s)
    quakeconsole[s] = quake({ terminal = "st",
                             argname = "-n %s",
			     width =  1280,
			     offset = 0.1,
			     height = 0.4,
			     screen = s })
    end)
end


do
   mystatusbar = awful.wibox.new({position='bottom', height=15})
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(widgets["Clbl"])
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   mystatusbar:set_widget(layout)
   mystatusbar.visible = false
end


awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6"}, s, awful.layout.layouts[2])
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height =15, width = s.geometry.width-96,
      x = 0, stretch = false})
    awful.placement.top_left(s.mywibox);
    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(s.mytaglist)
    left_layout:add(s.mypromptbox)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(mykblayout)
    right_layout:add(wibox.widget.systray())
    right_layout:add(mytextclock)
    right_layout:add(s.mylayoutbox)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(s.mytasklist)
    layout:set_right(right_layout)

    s.mywibox:set_widget(layout)
end)
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({}, "Caps_Lock", function() naughty.notify{ text = "Caps!" } end),
    awful.key({ modkey }, "`",
	     function () quakeconsole[mouse.screen]:toggle() end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
      function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    --awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
    awful.key({ modkey,           }, "e", function () awful.spawn(editor_cmd) end),
    awful.key({ modkey, "Shift"   }, "e", function () awful.spawn("emacs") end),
    awful.key({ modkey,           }, "b", function () awful.spawn("/opt/firefox/firefox --private-window") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end),

    -- Toggle Statusbar
    awful.key({ modkey }, "s",     
	      function ()
		 mystatusbar.visible = not mystatusbar.visible
		 awful.screen.connect_for_each_screen(function(s)
		     awful.placement.top_left(s.mywibox);
                 end)
                 if mystatusbar.visible then
                    timers[2]:start()
                 else
                    timers[2]:stop()
                 end
	      end),

    awful.key({ modkey }, "x",
    function()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
	textbox      = awful.screen.focused().mypromptbox.widget,
	exe_callback = awful.util.eval,
	history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end),

    awful.key({ }, "XF86Explorer",    function () awful.spawn("xdotool click 2") end),
    awful.key({ }, "XF86AudioRaiseVolume",    function () awful.spawn("amixer set Master 2%+") end),
    awful.key({ }, "XF86AudioLowerVolume",    function () awful.spawn("amixer set Master 2%-") end),
    awful.key({ }, "XF86AudioMute",           function () awful.spawn("amixer set Master toggle") end),
    awful.key({ }, "XF86Standby",             function () awful.spawn("sudo systemctl suspend") end),
    awful.key({ }, "XF86Display",             function () awful.spawn("toggledisp.sh") end),
    awful.key({ }, "XF86ScreenSaver",         function () awful.spawn("xtrlock") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ modkey, "Shift" }, "m",
	function (c)
	    c.maximized = false
	    c.maximized_vertical=false
	    c.maximized_horizontal=false
	    c.floating=false
	    c:raise()
	end)
)

awful.menu.menu_keys = { up    = { "k", "Up" },
                         down  = { "j", "Down" },
                         exec  = { "l", "Return", "Right" },
                         -- the new item
                         enter = { "Right" },
                         --
                         back  = { "h", "Left" },
                         close = { "q", "Escape" },
                       }



-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 6 do
    globalkeys = awful.util.table.join(globalkeys,
      -- View tag only.
      awful.key({ modkey }, "#" .. i + 9,
      function ()
	  local screen = awful.screen.focused()
	  local tag = screen.tags[i]
	  if tag then
	      tag:view_only()
	  end
      end),
      -- Toggle tag display.
      awful.key({ modkey, "Control" }, "#" .. i + 9,
      function ()
	  local screen = awful.screen.focused()
	  local tag = screen.tags[i]
	  if tag then
	      awful.tag.viewtoggle(tag)
	  end
      end),
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function ()
	  if client.focus then
	      local tag = client.focus.screen.tags[i]
	      if tag then
		  client.focus:move_to_tag(tag)
	      end
	  end
      end),
      -- Toggle tag on focused client.
      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function ()
	  if client.focus then
	      local tag = client.focus.screen.tags[i]
	      if tag then
		  client.focus:toggle_tag(tag)
	      end
	  end
      end)
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
		     buttons = clientbuttons,
		     screen = awful.screen.preferred,
		     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
		     sticky = false,
		     } },
    { rule = { class = "uim-toolbar-gtk" },
      properties = { floating = true, sticky = true } },
    { rule = { class = "Google-chrome" }, 
      properties = { floating = false, sticky = false } },
    { rule = { class = "Ogle" },
      properties = { floating = true } },
    { rule = { class = "sim" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "fontforge" },
      properties = { floating = true } },
    { rule = { class = "indicator-xkbmod" },
      properties = {
	 floating = true, sticky = true,
	 placement = awful.placement.align.top_right+awful.placement.no_offscreen,
	 border_width = 0, ontop = true, above = true, skip_taskbar= true,
      }
    },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = {  screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) 
			 c.border_color = beautiful.border_focus 
			       end)
client.connect_signal("unfocus", function(c) 
			 c.border_color = beautiful.border_normal
				 end)
-- }}}
