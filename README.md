
Rick and Morty Icon Overlay for Gtk

* 48x48 is what is used in the Ubuntu dock.
* 256x256 is what is used in the Ubuntu applications menu.

You can find the name of applications at "/usr/share/applications"
and "~/.local/share/applications". Print the file with `cat` and look at the
field `Icon` that's the file name you should use for your PNG.

I'm not sure what you can do about programs that are using a PNG file path in
the `Icon` field.

# References

* https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html
* https://www.reddit.com/r/gnome/comments/yxm32e/comment/iwphtm1/
* https://www.reddit.com/r/gnome/comments/yzwsji/how_to_change_the_default_icon_for_folders_in/
* https://help.gnome.org/admin//system-admin-guide/2.32/themes-11.html.en
* https://github.com/surajmandalcell/Gtk-Theming-Guide
