#!/bin/bash

ROOT_DIR="/home/birbal/webknot/webtrack"

echo "Which project do you want to pull?"
echo "1) frontend"
echo "2) backend"
read -p "Enter choice [1 or 2]: " choice

# Function to pull and update with branch and stash logic
pull_and_update() {
  local dir=$1
  local branch=$2

  echo "Changing to $dir and pulling latest code from $branch..."
  cd "$ROOT_DIR/$dir" || { echo "Directory $dir not found!"; exit 1; }

  echo "Stashing local changes..."
  git stash || { echo "Git stash failed in $dir"; exit 1; }

  echo "Switching to branch $branch..."
  git checkout "$branch" || { echo "Failed to checkout branch $branch in $dir"; exit 1; }

  echo "Pulling latest changes from $branch..."
  git pull origin "$branch" || { echo "Git pull failed in $dir"; exit 1; }

  echo "Popping stashed changes..."
  git stash pop || echo "Nothing to pop or conflicts need manual resolution."
}

if [[ "$choice" == "1" ]]; then
  read -p "Enter branch name to pull for frontend: " branch
  pull_and_update "webtrak-ui" "$branch"
elif [[ "$choice" == "2" ]]; then
  read -p "Enter branch name to pull for backend: " branch
  pull_and_update "webtrak" "$branch"
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
