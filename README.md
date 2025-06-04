# Deployment-script

# WebTrack Deployment

## Project Structure

Before starting, make sure to place all files in the correct locations:

## Step 1: Clone the Repositories

First, clone both the frontend and backend repositories with their respective branches.

### Clone Frontend
```bash
git clone -b <frontend-branch> <frontend-repo-url>

Clone Backend

git clone -b <backend-branch> <backend-repo-url>

Replace <frontend-branch> and <backend-branch> with the correct branch names, and <repo-url> with the actual Git URLs.

- **Set the root working directory in `deploy.sh`:**

  ```bash
  ROOT_DIR="/home/birbal/"
Place docker-compose.yml in the root directory (/home/birbal/).

Place wait-for-it.sh inside the backend directory (e.g., /home/birbal/webtrak).

Update your environment variables by copying and modifying .env.example to .env.

#Running

Use the deploy.sh script to set up and start the services.
