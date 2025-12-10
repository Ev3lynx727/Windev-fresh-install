# Build Walkthrough: Clean Build with Dev Containers

**Goal**: Build the Script Dashboard (Wails/Go app) without installing Go or Node.js on your main Windows host.
**Prerequsite**: Docker Desktop and VS Code (with Dev Containers extension).

## 1. Concept
We will use a **Dev Container**—a Docker container that acts as a full development environment.
- **Host (Your PC)**: Only has Docker & VS Code. Clean.
- **Container**: Has Go, Node.js, Wails, and build tools installed.
- **Output**: The container builds the `.exe` and places it in your project folder (which is shared/mounted), so you can access it from Windows.

## 2. Setup Configuration
Create a `.devcontainer` folder in your project root with the following files.

### `script-dashboard/.devcontainer/devcontainer.json`
```json
{
  "name": "Wails Builder",
  "image": "mcr.microsoft.com/devcontainers/go:1-1.21-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "configureZshAsDefaultShell": true,
      "installOhMyZsh": true
    }
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "golang.go",
        "dbaeumer.vscode-eslint"
      ]
    }
  },
  "postCreateCommand": "go install github.com/wailsapp/wails/v2/cmd/wails@latest && sudo apt-get update && sudo apt-get install -y libgtk-3-dev libwebkit2gtk-4.0-dev",
  "remoteUser": "vscode"
}
```

> **Note**: Wails requires Linux GTK libraries to *run* inside the container (for testing), but for *compiling* a Windows `.exe` from Linux, we need a cross-compiler (MinGW) or simply **use a Windows container**?
>
> **Wait!** To build a **Windows .exe** from a **Linux container** is tricky (requires cross-compilation setup).
> **Easier Path**: Since you are on WSL2, you are effectively in Linux.
> **Correction**: The simplest reliable way to build a Windows binary from a container is to use a container set up for **cross-compilation** (Linux -> Windows).

### Updated `devcontainer.json` for Windows Cross-Compilation
We will install `mingw-w64` inside the container to allow building Windows `.exe` files from Linux.

```json
{
  "name": "Wails Cross-Build",
  "image": "mcr.microsoft.com/devcontainers/go:1-1.21-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {}
  },
  "postCreateCommand": "sudo apt-get update && sudo apt-get install -y build-essential mingw-w64 && go install github.com/wailsapp/wails/v2/cmd/wails@latest",
  "remoteUser": "vscode"
}
```

## 3. The Build Process

1.  **Open Project in Container**:
    - Open VS Code.
    - Press `F1` -> `Dev Containers: Open Folder in Container...`
    - Select your `script-dashboard` folder.
    - *Coffee break*: It will download the image and install Go/Node/Wails (5-10 mins first time).

2.  **Verify Environment** (Inside VS Code Terminal):
    ```bash
    wails doctor
    ```
    Should show Go and Node installed.

3.  **Build the App**:
    Run this command in the container terminal to build a Windows executable:
    ```bash
    wails build -platform windows
    ```

4.  **Retrieve Output**:
    - The build process will create `build/bin/script-dashboard.exe`.
    - Because the folder is mounted, **this file instantly appears on your Windows host**.
    - You can now close VS Code and run the `.exe` from Windows!

## 4. Summary
You successfully built a native Windows app using a disposable Docker container. Your Windows registry remains clean of Go/NPM clutter.
