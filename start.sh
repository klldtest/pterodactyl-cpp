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
export INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')

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

# Check if auto build is enabled
if [ "${AUTO_BUILD}" == "TRUE" ] || [ "${AUTO_BUILD}" == "true" ]; then
    echo "Auto Build enabled. Building C++ application..."
    
    # Check for CMake
    if [ -f "CMakeLists.txt" ]; then
        echo "CMake build system detected"
        mkdir -p build && cd build
        cmake ..
        make -j$(nproc)
        cd ..
    # Check for Makefile
    elif [ -f "Makefile" ]; then
        echo "Makefile detected"
        make -j$(nproc)
    # Basic g++ compilation
    elif [ -n "${SOURCE_FILE}" ]; then
        echo "Compiling source file: ${SOURCE_FILE}"
        g++ ${SOURCE_FILE} -o app ${COMPILER_FLAGS}
    else
        echo "No recognized build system found. Please provide SOURCE_FILE or create a CMakeLists.txt/Makefile."
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

# Run the Server
eval ${MODIFIED_STARTUP}
