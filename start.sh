#!/bin/bash

cd /home/container

# Output Current Version Information
echo "Running on Debian $(cat /etc/debian_version)"
echo "Current C++ version: $(g++ --version | head -n 1)"
echo "Current CMake version: $(cmake --version | head -n 1)"

# Set default startup command if not set
if [ -z "${STARTUP_SCRIPT_1}" ]; then
    export STARTUP_SCRIPT_1="./app"
fi

# Make internal Docker IP address available to processes.
# Just use localhost as fallback to avoid errors
export INTERNAL_IP="127.0.0.1"

# Check if Git pull is enabled
if [ "${GIT_AUTO_PULL}" == "TRUE" ] || [ "${GIT_AUTO_PULL}" == "true" ]; then
    if [ -z "${GITHUB_REPO}" ]; then
        echo "No GitHub Repository provided"
    else
        echo "Pulling from GitHub repository: ${GITHUB_REPO}"
        
        # Check if directory exists
        if [ -d ".git" ]; then
            if [ -n "${GITHUB_USERNAME}" ] && [ -n "${GITHUB_TOKEN}" ]; then
                echo "Using authentication for git..."
                git remote set-url origin https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@$(echo ${GITHUB_REPO} | cut -d/ -f3-)
            fi
            
            echo "Pulling latest code from GitHub..."
            git pull
        else
            echo "Cloning repository..."
            if [ -n "${GITHUB_USERNAME}" ] && [ -n "${GITHUB_TOKEN}" ]; then
                echo "Using authentication for git..."
                git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@$(echo ${GITHUB_REPO} | cut -d/ -f3-) .
            else
                git clone ${GITHUB_REPO} .
            fi
        fi
        
        if [ -n "${GITHUB_BRANCH}" ]; then
            echo "Checking out branch: ${GITHUB_BRANCH}"
            git checkout ${GITHUB_BRANCH}
        fi
    fi
fi

# Check if AUTO_BUILD is enabled
if [ "${AUTO_BUILD}" = "1" ]; then
    echo "Auto Build enabled. Building C++ application..."
    
    # Check if main.cpp exists
    if [ -f "main.cpp" ]; then
        echo "Compiling source file: main.cpp"
        g++ -std=c++17 -o app main.cpp
        
        # Check if build was successful
        if [ $? -eq 0 ]; then
            echo "Build successful. Running application..."
            ./app
        else
            echo "Build failed. Please check your code."
        fi
    else
        echo "Error: main.cpp not found."
        echo "Please create a main.cpp file or disable Auto Build."
    fi
fi

# Shell access if enabled
if [ "${SHELL_ACCESS}" == "TRUE" ] || [ "${SHELL_ACCESS}" == "true" ]; then
    echo "Shell access enabled. Type 'exit' to continue with application startup."
    /bin/bash
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP_SCRIPT_1} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Ensure app exists before trying to run it
if [[ "${MODIFIED_STARTUP}" == "./app" || "${MODIFIED_STARTUP}" == "app" ]]; then
    if [ ! -f "./app" ]; then
        echo "ERROR: The app executable does not exist. Please check your build process."
        exit 1
    fi
    
    # Make sure it's executable
    chmod +x ./app
fi

# Run the Server
eval ${MODIFIED_STARTUP}
