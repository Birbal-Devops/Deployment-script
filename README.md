# WebTrack Deployment

## Project Structure

Before starting, make sure to place all files in the correct locations:

---

First, clone both the frontend and backend repositories with their respective branches.

### Clone Frontend
```bash
git clone -b <frontend-branch> <frontend-repo-url>

Clone Backend

git clone -b <backend-branch> <backend-repo-url>
Replace <frontend-branch> and <backend-branch> with the correct branch names, and <repo-url> with the actual Git URLs.
```

## Step 2: Configure Paths and Files
Set the root working directory in the deploy.sh file:
```bash 
ROOT_DIR="/home/birbal/"
```
Place docker-compose.yml in the root directory:
/home/birbal/

Place wait-for-it.sh inside the backend directory:
/home/birbal/webtrak/

Update your environment variables by copying .env.example to .env:

cp .env.example .env

## Step 3: Running
Use the deploy.sh script to set up and start the services:

bash deploy.sh


