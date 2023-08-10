#! /usr/bin/env fish

echo "Installing Rick and Morty Icon Overlay! Wuba luba dub dub!"
echo "You will need the program `convert` for this script to work."

set -l build_dir build/Rick-and-Morty-Icon-Overlay
set -l install_dir $HOME/.local/share/icons/

set -l current_icon_theme (string replace -a \' '' (gsettings get org.gnome.desktop.interface icon-theme))
set -l fallback_icon_theme ''

set -l icon_themes (ls $HOME/.local/share/icons)
if contains 'Rick-and-Morty-Icon-Overlay' $icon_themes
	set -l this_themes_index (contains -i 'Rick-and-Morty-Icon-Overlay' $icon_themes)
	set -e icon_themes[$this_themes_index]
end
set -l index 1
for icon_theme in $icon_themes
	if test $icon_theme = 'Rick-and-Morty-Icon-Overlay'
		continue
	end
	echo -n "[$index] $icon_theme"
	if test $current_icon_theme = $icon_theme
		echo -n "  *Current Theme"
	end
	echo ""
	set index (math $index + 1)
end
read -l --prompt-str="Select your fallback icon theme:  " icon_theme_index_choice
set fallback_icon_theme $icon_themes[$icon_theme_index_choice]
echo "Fallback icon theme is $fallback_icon_theme."

if test -e build
	rm -rf build
end

if test -e $install_dir/Rick-and-Morty-Icon-Overlay
	rm -rf $install_dir/Rick-and-Morty-Icon-Overlay
end

mkdir -p $build_dir

cp src/index.theme $build_dir/index.theme

sed -i "/^Inherits=/s/=.*/=$fallback_icon_theme,hicolor/" $build_dir/index.theme

mkdir -p $build_dir/48x48/apps
convert src/portal.png -resize 48x48 $build_dir/48x48/apps/system-file-manager.png
convert src/plumbus.png -resize 48x48 $build_dir/48x48/apps/sublime-text.png
convert src/poopy.png -resize 48x48 $build_dir/48x48/apps/google-chrome.png
cd $build_dir/48x48/apps  # We need to make the symbolic links relative paths.
ln -s system-file-manager.png org.gnome.Nautilus.png
cd -

mkdir -p $build_dir/32x32/apps
convert src/portal.png -resize 32x32 $build_dir/32x32/apps/system-file-manager.png

mkdir -p $build_dir/256x256/apps
convert src/portal.png -resize 256x256 $build_dir/256x256/apps/org.gnome.Nautilus.png
convert src/plumbus.png -resize 256x256 $build_dir/256x256/apps/sublime-text.png
convert src/poopy.png -resize 256x256 $build_dir/256x256/apps/google-chrome.png

gtk-update-icon-cache $build_dir

echo "Do you want to install to the $HOME/.local/share/icons directory?"
read -l --prompt-str='[yN]  ' install_theme

if test $install_theme = 'y'
	mkdir -p $install_dir
	cp -r $build_dir/ $install_dir/
	gsettings set org.gnome.desktop.interface icon-theme 'Rick-and-Morty-Icon-Overlay'
end
