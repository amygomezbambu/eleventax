#!/bin/bash
# Este script configura todas las herramientas del ambiente de desarrollo
# de eleventa que se requieren en macOS para poder trabajar correctamente
# se actualiza conforme agreguemos o cambien las dependencias

VERSION="v1.1"

# Basado en:
# https://github.com/vendasta/setup-new-computer-script/
# 
#   Instrucciones:
#
#   1. Hacer el script ejecutable:
#      chmod +x ./tools/setup_new_mac.sh
#
#   2. Ejecutar el script:
#      ./tools/configurar_mac.sh
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

xcode-select -p 1>/dev/null;
if [ $? -eq 2 ]  
then
    printHeading "🔵 Instalando XCode Tools necesarios para desarrollo de iOS, brew, etc..."
    printDivider        
        xcode-select --install && \
            read -n 1 -r -s -p $'\n\nCuando terminen de instalarse las XCode tools, presiona cualquier tecla...\n\n' || \
                printDivider && echo "✔ XCode Tools ya están instaladas. Avanzando"
    printDivider
    sudo xcodebuild -runFirstLaunch
    sudo xcodebuild -license
else
    echo "✅ XCode instalado."
fi

which brew 1>/dev/null; 
if [ $? -eq 2 ]
then
    printHeading "🔵 Instalando Homebrew, se te solicitará contraseña ..."
    printDivider
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    printDivider
        echo "✔ Estableciendo Path a /usr/local/bin:\$PATH"
            export PATH=/usr/local/bin:$PATH
    printDivider
else
    echo "✅ Home Brew instalado."
fi

echo "🔵 Actualizando fórmulas de Home Brew..."
brew tap homebrew/cask

if ! command -v code &> /dev/null
then
    printHeading "🔵  Instalando Visual Studio Code..."
    printStep "Visual Studio Code" "brew install --cask visual-studio-code"
else
    echo "✅ Visual Studio Code instalado."
fi

printHeading "🔵 Instalando aplicaciones de la AppStore..."
printDivider        
printStep "Visual Studio Code" "brew install mas"
printStep "XCode" "mas install 497799835"
printStep "Android Studio" "brew install --cask android-studio"
printStep "Android Command Line Tools" "brew install --cask android-commandlinetools"
printDivider        

printHeading "🔵 Aceptando EULAs"
flutter doctor --android-licenses
sudo xcodebuild -license

printHeading "🔵 Instalando Java"

echo '\nnexport JABBA_VERSION="0.11.2"\n' >> /Users/$(whoami)/.zshrc
curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh

[ -s "/Users/$(whoami)/.jabba/jabba.sh" ] && source "/Users/$(whoami)/.jabba/jabba.sh"

jabba install openjdk@1.16.0
java -version

# Switch to a different Java version (need to first be installed using Jabba)
jabba use ...

# Actualizar variables de entorno
echo "\nexport JAVA_HOME=/Users/$(whoami)/.jabba/jdk/openjdk@1.16.0/Contents/Home\n" >> /Users/$(whoami)/.zshrc
echo "\nexport PATH=$JAVA_HOME:$PATH\n" >> /Users/$(whoami)/.zshrc


printHeading "🔵 Instalando Graddle"
brew install gradle
## Reinstall Gradle to Latest Version
echo "\nGRADLE_VERSION=$(echo $(arr=($(gradle --version | awk '{ print $2 }')) && echo ${arr[1]}))\n" >> /Users/$(whoami)/.zshrc
echo "\nexport GRADLE_HOME=`brew --prefix`/Cellar/gradle/$GRADLE_VERSION\n" >> /Users/$(whoami)/.zshrc
echo "\nexport PATH=$GRADLE_HOME/bin:$PATH\n" >> /Users/$(whoami)/.zshrc

printHeading "🔵 Instalando herramientas adicionales de Android Studio..."

echo "\nexport ANDROID_HOME=`brew --prefix`/share/android-commandlinetools\n" >> /Users/$(whoami)/.zshrc
echo "\nexport PATH=$ANDROID_HOME:$PATH\n" >> /Users/$(whoami)/.zshrc

echo "\nexport SDK_MANAGER=`brew --prefix`/bin/sdkmanager\n" >> /Users/$(whoami)/.zshrc
echo "\nexport PATH=$SDK_MANAGER:$PATH\n" >> /Users/$(whoami)/.zshrc

echo "\nexport AVD=`brew --prefix`/bin/avdmanager\n" >> /Users/$(whoami)/.zshrc
echo "\nexport PATH=$AVD:$PATH\n" >> /Users/$(whoami)/.zshrc

# Then Install Tools
sdkmanager "cmdline-tools;latest"
sdkmanager "patcher;v4"
sdkmanager "build-tools;30.0.2"
sdkmanager "platforms;android-32"
sdkmanager "emulator"
sdkmanager "tools"
sdkmanager "platform-tools"

yes | sdkmanager --licenses
sdkmanager "ndk-bundle"

print "🔵 Instalando Ruby"
brew install ruby
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
echo 'export PATH=`gem environment gemdir`/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
brew pin ruby

print "🔵 Instalando Cocoapods"
gem install cocoapods

print "🔵 Instalando Simuladores de iOS"
sudo gem install xcode-install
xcversion simulators --install="iOS 16.2 Simulator"


## Abrir Android Studio y abrir la carpeta para aceptar el contrato y que baje los gradle, etc.
if ! command -v flutter &> /dev/null
then
    print "🔵 Instalando Flutter"
    printStep "Flutter" "brew install --cask flutter"
    printStep "Extensiones de Dart y Flutter..." "code --install-extension dart-code.dart-code --install-extension dart-code.flutter"
    printStep "LiveSharing" "code --install-extension ms-vsliveshare.vsliveshare"
    printDivider
else
    echo "✅ Flutter instalado."
fi

if ! command -v gcloud &> /dev/null
then
    print "🔵 Instalando GCloud"
    printStep "GCloud" "curl https://sdk.cloud.google.com | bash"
    exec -l $SHELL
    printDivider
else
    echo "✅ GCloud instalado."
fi

# Instalar tweaks de sistema
echo "✔ Tweak: Deshabilitar los smart quotes que interfieren al teclear código"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "Configurando VSCode como editor de Git"
git config --global core.editor "code --wait"

# echo "✔ Instalando GitHooks locales"
# bash setup_githooks.sh
if brew list 1password-cli &>/dev/null; then
    echo "✅ 1Password Client ya instalado, omitiendo instalación."
else
    echo "🔵 Instalando cliente 1Password para obtener credenciales de desarrollo..."
    brew install --cask 1password/tap/1password-cli    
fi

printDivider "🔵 Evaluando si funciona 1Password Client. Se te pedirá autenticarte..."
echo "Resultado:"
op read "op://Desarrollo/eleventax prueba/credencial" 

printDivider "🔵 Verificando que esté todo en orden"
flutter doctor
