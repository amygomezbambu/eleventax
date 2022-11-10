#!/bin/zsh
source ~/.zshrc
ruby --version

echo "✔ Actualizando dependencias de macOS..."
cd macos
pod repo update
pod update

echo "✔ Actualizando dependencias de macOS..."
cd ../ios
pod repo update
pod update