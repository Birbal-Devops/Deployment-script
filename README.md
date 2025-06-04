# Deployment-script

# WebTrack Deployment

## Project Structure

Before starting, make sure to place all files in the correct locations:

- **Set the root working directory in `deploy.sh`:**

  ```bash
  ROOT_DIR="/home/birbal/"
Place docker-compose.yml in the root directory (/home/birbal/).

Place wait-for-it.sh inside the backend directory (e.g., /home/birbal/webtrak).

Update your environment variables by copying and modifying .env.example to .env.

#Running

Use the deploy.sh script to set up and start the services.
