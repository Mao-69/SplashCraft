#!/bin/bash

BASE_THEMES_DIR="./themes"

if [ ! -d "$BASE_THEMES_DIR" ]; then
    echo "Error: Directory '$BASE_THEMES_DIR' does not exist."
    exit 1
fi

display_ascii_art() {
    echo "$(tput setaf 2)────────────────────────────────────────────────────────────────────────────────$(tput sgr 0)";
    echo " ";
    echo "
    ➖➖➖🟩🟩➖🟩🟩          ╔═╗╔═╗╦  ╔═╗╔═╗╦ ╦  ╔═╗╦═╗╔═╗╔═╗╔╦╗
    ➖➖🟩🟩🟩🟩🟩🟩🟩        ╚═╗╠═╝║  ╠═╣╚═╗╠═╣  ║  ╠╦╝╠═╣╠╣  ║
    ➖🟩🟩⬜⬛⬜⬜⬛🟩        ╚═╝╩  ╩═╝╩ ╩╚═╝╩ ╩  ╚═╝╩╚═╩ ╩╚   ╩
    ➖🟩🟩🟩🟩🟩🟩🟩
    🟩🟩🟩🟩🟥🟥🟥🟥           \"Dis Themes ain't even mine\"
    🟩🟩🟩🟩🟩🟩🟩
    🟦🟦🟦🟦🟦🟦🟦
";
    echo " ";
    echo "$(tput setaf 2)────────────────────────────────────────────────────────────────────────────────$(tput sgr 0)";
}

exit_banner(){
    echo "$(tput setaf 2)│$(tput sgr 0)";
    echo "$(tput setaf 2)│$(tput sgr 0)";
}

display_menu() {
    local selected_option=$1
    echo " "
    echo "$(tput setaf 2)┌─($(tput sgr 0)$(tput setaf 6)SplashCraft$(tput sgr 0)$(tput setaf 2))─[$(tput sgr 0)$(tput setaf 6)Version: 1.0$(tput sgr 0)$(tput setaf 2)]$(tput sgr 0)"
    echo "$(tput setaf 2)│$(tput sgr 0)"
    echo "$(tput setaf 2)│$(tput sgr 0) $(tput dim)\"Now your boot screen can look less sad than your last Tinder date!\"$(tput sgr 0)"
}

Help_Menu() {
    echo "$(tput setaf 2)│$(tput sgr 0)"
    echo "$(tput setaf 2)│$(tput sgr 0)$(tput setaf 6)>$(tput sgr 0) LIST - $(tput setaf 6)List the available themes$(tput sgr 0)"
    echo "$(tput setaf 2)│$(tput sgr 0)$(tput setaf 6)>$(tput sgr 0) CHANGE - $(tput setaf 6)Select and set theme to default$(tput sgr 0)"
    echo "$(tput setaf 2)│$(tput sgr 0)$(tput setaf 6)>$(tput sgr 0) PREVIEW - $(tput setaf 6)Preview the current default theme$(tput sgr 0)"
    echo "$(tput setaf 2)│$(tput sgr 0)"
    echo "$(tput setaf 2)└──($(tput sgr 0)$(tput setaf 6)End of List$(tput sgr 0)$(tput setaf 2))$(tput sgr 0)"
}


list_themes() {
    echo "$(tput setaf 2)┌─($(tput sgr 0)$(tput setaf 6)SplashCraft$(tput sgr 0)$(tput setaf 2))─[$(tput sgr 0)$(tput setaf 6)Version: 1.0$(tput sgr 0)$(tput setaf 2)]$(tput sgr 0)"
    echo "$(tput setaf 2)│$(tput sgr 0)"
    echo "$(tput setaf 2)├──($(tput sgr 0)Available themes:$(tput setaf 2))$(tput sgr 0)"

    themes=($(find "$BASE_THEMES_DIR" -mindepth 2 -maxdepth 2 -type d | sed 's|.*/||' | sort))

    for ((i = 0; i < ${#themes[@]}; i++)); do
        if (( i % 5 == 0 )); then
            printf "$(tput setaf 2)│$(tput sgr 0)$(tput setaf 6)>$(tput sgr 0) "
        fi
        printf "%s" "${themes[i]}"

        if (( (i + 1) % 5 == 0 || i == ${#themes[@]} - 1 )); then
            echo ""
        else
            printf "$(tput setaf 4) | $(tput sgr 0)"
        fi
    done

    echo "$(tput setaf 2)│$(tput sgr 0)"
    echo "$(tput setaf 2)└──($(tput sgr 0)$(tput setaf 6)Available Themes$(tput sgr 0)$(tput setaf 2))$(tput sgr 0)"
}


preview_theme() {
    R='\033[1;31m'

    check_root () {
        if [ ! $( id -u ) -eq 0 ]; then
            echo -e $R"Must be run as root"
            exit
        fi
    }

    check_root

    duration=30

    plymouthd
    plymouth change-mode --boot-up
    plymouth --show-splash
    for ((I=0; I<duration; I++)); do
        plymouth --update=test$I
        sleep 1
    done
    plymouth quit
}

change_theme() {
    list_themes
    read -p "Enter the theme name from the above list: " THEME_NAME

    THEME_PATH=""

    for pack in "$BASE_THEMES_DIR"/pack_*; do
        if [ -d "$pack/$THEME_NAME" ]; then
            THEME_PATH="$pack/$THEME_NAME"
            break
        fi
    done

    if [ -z "$THEME_PATH" ]; then
        echo "Error: Theme '$THEME_NAME' does not exist."
        return
    fi

    sudo cp -r "$THEME_PATH" /usr/share/plymouth/themes/
    sudo plymouth-set-default-theme -R "$THEME_NAME"
    sudo update-initramfs -u

    echo "Plymouth theme '$THEME_NAME' has been updated and set as default successfully."
}

check_package() {
    dpkg -l | grep -qw "$1"
}

packages=("plymouth" "plymouth-x11")

for package in "${packages[@]}"; do
    echo "checking if Plymouth and Plymouth-x11 is installed"
    if check_package "$package"; then
        echo "$package is already installed."
    else
        echo "$package is not installed. Installing..."
        sudo apt update
        sudo apt install -y "$package"
    fi
done

while true; do
    clear
    display_ascii_art
    display_menu 0
    echo "$(tput setaf 2)│$(tput sgr 0)"
    read -p "$(tput setaf 2)└──$(tput sgr 0)$(tput setaf 6)$ $(tput sgr 0) " option

    case $option in
        help)
            clear
            display_menu 1
            Help_Menu
            read -r -p "Press any key to continue..." key
            ;;
        list)
            clear
            list_themes
            read -r -p "Press any key to continue..." key
            ;;
        change)
            clear
            change_theme
            read -r -p "Press any key to continue..." key
            ;;
        preview)
            clear
            preview_theme
            read -r -p "Press any key to continue..." key
            ;;
        exit)
            clear
            display_menu 2
            exit_banner
            read -r -p "Press any key to exit..." key
            clear
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            read -r -p "Press any key to continue..." key
            ;;
    esac
done