#!/bin/bash

VERSION="v1.0"

# Basado en:
# https://github.com/vendasta/setup-new-computer-script/
# 
#   Instrucciones:
#
#   1. Hacer el script ejecutable:
#      chmod +x ./tools/setup_new_mac.sh
#
#   2. Ejecutar el script:
#      ./tools/setup_new_mac.sh
#
#   3. Algunas instalaciones requerirán tu contraseña
#

# Funciones auxiliares para facilitar la lectura en la terminal
printHeading() {
    printf "\n\n\n\e[0;36m$1\e[0m \n"
}

printDivider() {
    printf %"$COLUMNS"s |tr " " "-"
    printf "\n"
}

printError() {
    printf "\n\e[1;31m"
    printf %"$COLUMNS"s |tr " " "-"
    if [ -z "$1" ]      # Is parameter #1 zero length?
    then
        printf "     Ocurrió un error...\n"  # no parameter passed.
    else
        printf "\n     Error al instalar: $1\n" # parameter passed.
    fi
    printf %"$COLUMNS"s |tr " " "-"
    printf " \e[0m\n"
}

printStep() {
    printf %"$COLUMNS"s |tr " " "-"
    printf "\nInstalling $1...\n";
    $2 || printError "$1"
}

# El primer requisito es tener las XCode tools
printHeading "Instalando XCode Tools necesarios para desarrollo de iOS, brew, etc..."
printDivider
    xcode-select --install && \
        read -n 1 -r -s -p $'\n\nCuando terminen de instalarse las XCode tools, presiona cualquier tecla...\n\n' || \
            printDivider && echo "✔ XCode Tools ya están instaladas. Avanzando"
printDivider


printHeading "Instalando Apps..."
printStep "Visual Studio Code" "brew install --cask visual-studio-code"

printHeading "Instalando Homebrew"
printDivider
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
printDivider
    echo "✔ Estableciendo Path a /usr/local/bin:\$PATH"
        export PATH=/usr/local/bin:$PATH
printDivider

print "Instalando Flutter"
printStep "Flutter" "brew install --cask flutter"
printStep "Extensiones de Dart y Flutter..." "code --install-extension dart-code.dart-code --install-extension dart-code.flutter"
printStep "LiveSharing" "code --install-extension ms-vsliveshare.vsliveshare"
printDivider

# Instalar tweaks de sistema
echo "✔ Tweak: Deshabilitar los smart quotes que interfieren al teclear código"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "✔ Instalando GitHooks locales"
bash setup_githooks.sh

echo "✔ Instalar cliente 1Password para obtener credenciales de dev"
brew install --cask 1password/tap/1password-cli