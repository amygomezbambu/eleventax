#!/usr/bin/env bash

GIT_DIR=$(git rev-parse --git-dir)

echo "Instalando hooks..."

# this command creates symlink to our pre-commit script
echo "Creando symbolic link en directorio $GIT_DIR"
ln -s ../../.githooks/pre-commit.sh $GIT_DIR/hooks/pre-commit
chmod +x ../.githooks/pre-commit.sh

echo "Listo!" 