#!/usr/bin/env bash

# https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
# https://www.baeldung.com/linux/check-bash-array-contains-value

echo "Installing Rick and Morty Icon Overlay! Wuba luba dub dub!"
echo "You will need the program 'convert' for this script to work."
echo -e "It comes from the package imagemagick.\n"

_is_package_installed()
{
    local package_name=$1
    dpkg -l | grep $package_name > /dev/null
    if [[ $? -eq 0 ]]; then
        return 0
    fi
    return 1
}

if ! _is_package_installed imagemagick; then
    echo "Installing imagemagick."
    sudo apt-get -y install imagemagick
fi

build_dir=build/Rick-and-Morty-Icon-Overlay
install_dir=$HOME/.local/share/icons/
current_icon_theme=$(gsettings get org.gnome.desktop.interface icon-theme | sed -e 's/^"//' -e 's/"$//')
# Create a Bash array of the themes already installed.
icon_themes=($(/usr/bin/find $install_dir -maxdepth 1 -type d -not -path $install_dir -print))

# Select a fallback icon theme by listing the currently installed themes and asking them to select
# one.
echo -e "Select your fallback icon theme.\n"
for i in ${!icon_themes[@]}; do
    if [[ ${icon_themes[$i]} =~ 'Rick-and-Morty-Icon-Overlay' ]]; then
        continue
    fi
    echo -n "[$i] $(basename ${icon_themes[$i]})"
    if [[ ${icon_themes[$i]} =~ $current_icon_theme ]]; then
        echo -n " <- Current Theme"
    fi
    echo ""
done

valid_input=0
highest_index=$((${#icon_themes[@]} - 1))

while [[ $valid_input -eq 0 ]]; do
    echo -n "Which index is your fallback icon theme?  "
    read fallback_icon_theme_index
    if [[ ${icon_themes[$fallback_icon_theme_index]} =~ 'Rick-and-Morty-Icon-Overlay' ]]; then
        echo -e "\e[0;31mInvalid choice. You can choose the Rick and Morty theme that's already installed.\e[0;0m" >&2
        continue
    fi
    if [[ $fallback_icon_theme_index -lt 0 ]]; then
        echo -e "\e[0;31mChoice can't be below 0.\e[0;0m"
        continue
    fi
    if [[ $fallback_icon_theme_index -gt $highest_index ]]; then
        echo -e "\e[0;31mChoice can't be above $highest_index.\e[0;0m"
        continue
    fi
    valid_input=1
done

fallback_icon_theme=$(basename ${icon_themes[$fallback_icon_theme_index]})

echo -e "Fallback icon theme is $fallback_icon_theme.\n"

# Remove the build directory if it exists.
if [[ -e build ]]; then
    rm -rf build
fi

mkdir -p $build_dir > /dev/null

cp src/index.theme $build_dir/index.theme

# Add the fallback theme.
sed -i "/^Inherits=/s/=.*/=$fallback_icon_theme,hicolor/" $build_dir/index.theme

# Generate the 48x48 icons from the source icons.
mkdir -p $build_dir/48x48/apps
convert src/portal.png -resize 48x48 $build_dir/48x48/apps/system-file-manager.png
convert src/plumbus.png -resize 48x48 $build_dir/48x48/apps/sublime-text.png
convert src/poopy.png -resize 48x48 $build_dir/48x48/apps/google-chrome.png
cd $build_dir/48x48/apps  # We need to make the symbolic links relative paths.
ln -s system-file-manager.png org.gnome.Nautilus.png
cd - > /dev/null

# Generate the 32x32 icons from the source icons.
mkdir -p $build_dir/32x32/apps
convert src/portal.png -resize 32x32 $build_dir/32x32/apps/system-file-manager.png

# Generate the 256x256 icons from the source icons.
mkdir -p $build_dir/256x256/apps
convert src/portal.png -resize 256x256 $build_dir/256x256/apps/org.gnome.Nautilus.png
convert src/plumbus.png -resize 256x256 $build_dir/256x256/apps/sublime-text.png
convert src/poopy.png -resize 256x256 $build_dir/256x256/apps/google-chrome.png

gtk-update-icon-cache $build_dir > /dev/null 2>&1

echo "Do you want to install to the $HOME/.local/share/icons directory?"
echo -n "[yN]  "
read install_theme_choice

if [[ "$install_theme_choice" = "y" ]]; then
    # Remove the Rick-and-Morty-Icon-Overlay from the install directory if it exists.
    if [[ -e $install_dir/Rick-and-Morty-Icon-Overlay ]]; then
        rm -rf $install_dir/Rick-and-Morty-Icon-Overlay
    fi

    mkdir -p $install_dir
    cp -r $build_dir/ $install_dir/
    gsettings set org.gnome.desktop.interface icon-theme 'Rick-and-Morty-Icon-Overlay'
fi

exit 0
