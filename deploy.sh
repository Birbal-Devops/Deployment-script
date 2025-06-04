#!/bin/bash

ROOT_DIR="/home/birbal/webknot/webtrack"

echo "Which project do you want to pull?"
echo "1) frontend"
echo "2) backend"
read -p "Enter choice [1 or 2]: " choice

pull_and_update() {
  local dir=$1
  echo "Changing to $dir and pulling latest code..."
  cd "$ROOT_DIR/$dir" || { echo "Directory $dir not found!"; exit 1; }
  git pull || { echo "Git pull failed in $dir"; exit 1; }
}

if [[ "$choice" == "1" ]]; then
  pull_and_update "webtrak-ui"
elif [[ "$choice" == "2" ]]; then
  pull_and_update "webtrak"
else
  echo "Invalid choice."
  exit 1
fi

cd "$ROOT_DIR" || exit

echo "Stopping containers..."
docker-compose down

echo "Removing old backend and frontend Docker images..."
docker rmi -f webtrack_backend:latest 2>/dev/null || echo "No existing backend image found."
docker rmi -f webtrack_frontend:latest 2>/dev/null || echo "No existing frontend image found."

echo "Rebuilding and restarting containers..."
docker-compose up --build -d

echo "✅ Deployment complete."
