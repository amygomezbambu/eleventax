#!/bin/zsh
ruby --version

echo "✔ Actualizando dependencias de macOS..."
cd macos
pod update Sentry/HybridSDK 

echo "✔ Actualizando dependencias de iOS..."
cd ../ios
pod update Sentry/HybridSDK