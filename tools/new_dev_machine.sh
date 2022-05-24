#!/usr/bin/env bash

print "Instalando Flutter..."
brew install --cask flutter
print "Instalando extensiones de Dart y Flutter..."
code --install-extension dart-code.dart-code --install-extension dart-code.flutter
print "Instalando extensiones útiles opcionales..."
# Aqui pondriamos extensiones adicionales
# code --install-extension nash.awesome-flutter-snippets

# Instalar FVM?

