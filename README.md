
# Volume widget for Awesome-WM

Connect widget `volume_widget` to your widgets with commands, for
example

    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(volume_widget)
    layout:set_right(right_layout)

Widget use `modkey` (as in awesomewm config) to extend the
functionality.  The package uses `amixer` to manipulate the volume
(now only 'Master').

Format of the string is "Vol: <volume value in perc><%|M>", if the
volume is unmuted, displayed "%", if one is muted displayed "M".

Widget can't catch changes in volume, so volume changed from another
source will be updated with next changing volume from within the
widget.

Steps for volume now is 2 ("small") and 10 ("large") percents.

Keys:
- Mouse on widget:
  - LMB(Left mouse button): toggle mute/unmute
    - modkey + LMB: start `pavucontrol`
  - WUP(Wheel up): increase volume (small step)
    - modkey + WUP: increase volume (large step)
  - WDOWN(Wheel down): decrease volume (small step)
    - modkey + WDOWN: decrease volume (large step)
  - Ctrl + WUP: move balance to left (left channel +, right channel -)
  - Ctrl + WDOWN: move balance to right (left channel -, right channel +)
- Keyboard:
  - XF86AudioRaiseVolume: increase volume (small step)
    - modkey + XF86AudioRaiseVolume: increase volume (large step)
  - XF86AudioLowerVolume: decrease volume (small step)
    - modkey + XF86AudioLowerVolume: decrease volume (large step)
  - XF86AudioMute: toggle muted/unmuted

TODO:
- [ ] If balance is very unsymmetrical, there is an error in volume value
- [ ] Timer to catch external volume changes
