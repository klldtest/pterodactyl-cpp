# Pterodactyl C++ Development Container

This is a Docker container designed for C++ development in the Pterodactyl panel environment. It provides a pre-configured Debian 12 environment with all necessary tools for C++ development and execution.

## Features

- **Debian 12** base with essential development packages
- **C++ Development Tools**: GCC, G++, Clang, CMake, Make, GDB, Valgrind
- **Automatic Build**: Compiles your C++ application on startup
- **Git Integration**: Auto-pull from GitHub repositories
- **Shell Access**: Optional bash shell for direct environment interaction

## Environment Variables

| Variable | Description |
|----------|-------------|
| `AUTO_BUILD` | Set to `1` to automatically build `main.cpp` into an executable called `app` on startup |
| `GIT_AUTO_PULL` | Set to `TRUE` to automatically pull code from a Git repository on startup |
| `GITHUB_REPO` | URL of the GitHub repository to pull from |
| `GITHUB_BRANCH` | Specific branch to checkout (optional) |
| `GITHUB_USERNAME` | Username for private GitHub repositories (optional) |
| `GITHUB_TOKEN` | Personal access token for private GitHub repositories (optional) |
| `SHELL_ACCESS` | Set to `TRUE` to enable shell access before starting the application |
| `STARTUP_SCRIPT_1` | Command to execute at startup (defaults to `./app`) |

## Quick Start

1. Create a C++ project with at least a `main.cpp` file
2. Configure your server in the Pterodactyl panel using this image
3. Start the server
4. Your C++ application will be compiled and run automatically if `AUTO_BUILD` is enabled

## Example main.cpp

```cpp
#include <iostream>

int main()
{
    std::cout << "Hello World" << std::endl;
    return 0;
}
```

## Using Git Integration

To use your GitHub repository with this container:

1. Set `GIT_AUTO_PULL` to `TRUE`
2. Set `GITHUB_REPO` to your repository URL (e.g., `https://github.com/username/repo.git`)
3. For private repositories, set `GITHUB_USERNAME` and `GITHUB_TOKEN`
4. Optionally set `GITHUB_BRANCH` to checkout a specific branch

## Building with CMake

For projects using CMake, you can set a custom startup command:

1. Disable `AUTO_BUILD` or ensure your `main.cpp` is properly integrated
2. Set a custom `STARTUP_SCRIPT_1` similar to:
   ```
   mkdir -p build && cd build && cmake .. && make && ./your_executable
   ```

## Customization

You can modify the container by:

1. Adding additional dependencies through a custom startup command that runs `apt-get`
2. Creating a custom Dockerfile that extends this image
3. Modifying the build process through custom startup scripts

## Support

For issues, questions, or contributions, please open an issue or pull request on the GitHub repository.