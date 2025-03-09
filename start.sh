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

# Function to build the application
build_app() {
    if [ -f "main.cpp" ]; then
        echo "Compiling source file: main.cpp"
        g++ -std=c++17 -o app main.cpp
        
        if [ $? -eq 0 ]; then
            echo "Build successful."
            chmod +x ./app
            return 0
        else
            echo "Build failed. Please check your code."
            return 1
        fi
    else
        echo "Error: main.cpp not found."
        return 1
    fi
}

# Check if AUTO_BUILD is enabled
if [ "${AUTO_BUILD}" = "1" ]; then
    echo "Auto Build enabled. Building C++ application..."
    build_app
fi

# Shell access if enabled
if [ "${SHELL_ACCESS}" == "TRUE" ] || [ "${SHELL_ACCESS}" == "true" ]; then
    echo "Shell access enabled. Type 'exit' to continue with application startup."
    /bin/bash
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP_SCRIPT_1} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Check if we need to run the app and make sure it exists
if [[ "${MODIFIED_STARTUP}" == "./app" || "${MODIFIED_STARTUP}" == "app" ]]; then
    if [ ! -f "./app" ]; then
        echo "Warning: The app executable does not exist. Attempting to build it now..."
        if build_app; then
            echo "Running the newly built app..."
        else
            echo "ERROR: Could not build the app. Please ensure main.cpp exists and is valid."
            echo "Creating a simple default main.cpp file that you can modify later..."
            cat > main.cpp << 'EOL'
#include <iostream>

int main() {
    std::cout << "Hello from Pterodactyl C++ container!" << std::endl;
    std::cout << "This is a default program. Edit main.cpp to create your own application." << std::endl;
    return 0;
}
EOL
            echo "Building the default application..."
            build_app || { echo "ERROR: Could not build default app. Something is wrong with the environment."; exit 1; }
        fi
    fi
    
    # Make sure it's executable
    chmod +x ./app
fi

# Run the Server
eval ${MODIFIED_STARTUP}
