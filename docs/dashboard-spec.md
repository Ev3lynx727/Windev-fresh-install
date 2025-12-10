# Script Dashboard Application - Design Specification

**Status**: Draft / Future Plan
**Style Reference**: Balena Etcher (Dark, Minimalist, Card-based)

## 1. Overview
This application will serve as a visual index for the custom developer scripts (PowerShell, Bash, Batch) in the `Windev-fresh-install` repository. It provides a user-friendly generic "Storefront" interface to find and eventually execute tools.

## 2. Technology Stack
- **Framework**: [React](https://react.dev/) (via [Vite](https://vitejs.dev/))
- **Styling**: [Tailwind CSS](https://tailwindcss.com/)
- **Icons**: [Lucide React](https://lucide.dev/) or [React Icons](https://react-icons.github.io/react-icons/)
- **Runtime (Future)**: Browseable as a Static Web App (index only) or wrapper in [Electron](https://www.electronjs.org/) for local execution.

## 3. Design Aesthetics (Etcher Style)
- **Color Palette**:
  - Background: Very dark blue/gray (`#1e1f29` / similar to `slate-900`)
  - Surface: Slightly lighter dark blue for cards (`#2a2b3d`)
  - Accents: Cyan/Electric Blue for primary actions, Green for success/ready.
  - Text: White/Off-white (`slate-200`)
- **Layout**:
  - **Sidebar (Optional)**: For categories (e.g., "Installers", "Docker", "Utils").
  - **Main Grid**: Comfortable grid of cards representing scripts.
  - **Micro-interactions**: Subtle hover lifts on cards, smooth transitions.
  - **Window Dimensions (Base Build)**:
    - Default: `1000px x 700px` (Optimized for modern desktops)
    - Minimum: `800px x 600px` (Prevent breaking layout)
    - Resizable: Yes

### 3.1 Asset Specifications (Guidelines)
To maintain the premium "Etcher-like" feel, use these standards for assets:

| Asset Type | Format | Recommended Size | Notes |
| :--- | :--- | :--- | :--- |
| **App Logo** | SVG (Best) or PNG | 512x512px (min) | Transparent background. Ensure visibility on dark backgrounds. |
| **Icons** | SVG | 24x24px (viewbox) | Use 2px stroke width for consistency. Optimize with SVGO. |
| **Thumbnails** | WebP / PNG | 600x400px | Aspect ratio 3:2. Keep file size under 100KB per image. |
| **Backgrounds** | WebP | 1920x1080px | Abstract, dark patterns. Low contrast to avoid fighting text. |
| **Fonts** | WOFF2 | Variable or 400/600/700 | Inter or Roboto are safe defaults. Avoid TTF/OTF for web. |


## 4. Proposed File Structure (Robust / Hybrid)
This structure separates the **Frontend** (UI) from the **Core** (Backend/Native), making it ready for Electron or Wails.

```text
script-dashboard/
├── build/                  <-- Compiled binaries (.exe) go here
├── core/                   <-- "Backend" Logic (Electron Main or Go)
│   ├── services/           <-- ScriptExecutor, Indexer
│   └── api/                <-- IPC Bridge definitions
├── frontend/               <-- The React Application
│   ├── public/             <-- Static files
│   └── src/
│       ├── assets/         <-- Images, Icons, Fonts
│       ├── components/     <-- Reusable UI (Buttons, Cards)
│       ├── layouts/        <-- Page structures (SidebarLayout)
│       ├── hooks/          <-- Data fetching & Logic
│       ├── stores/         <-- Global State (e.g., ScriptListStore)
│       └── App.jsx
└── package.json            <-- Project config
```

## 5. Data Model (`scripts_index.json`)
To avoid complex backend logic initially, we will use a "Generate Index" script (Node.js or PowerShell) that scans the repo and produces this JSON:

```json
[
  {
    "id": "install-fullstack",
    "filename": "Install-FullStackTools.ps1",
    "name": "Full Stack Installer",
    "description": "Installs Git, Node, Python, and other core tools.",
    "type": "powershell",
    "tags": ["setup", "install"],
    "path": "./Install-FullStackTools.ps1"
  },
  {
    "id": "docker-utils",
    "filename": "docker-utils.sh",
    "name": "Docker Utilities",
    "description": "Helper functions for WSL2 Docker management.",
    "type": "shell",
    "tags": ["docker", "wsl"],
    "path": "./docker-utils-wsl2/docker-utils.sh"
  }
]
```

## 6. Implementation Steps (When Ready)

### Phase 1: Setup
1. Run `npx create-vite@latest script-dashboard --template react`
2. Install Tailwind: `npm install -D tailwindcss postcss autoprefixer && npx tailwindcss init -p`
3. Configure `tailwind.config.js` with the custom dark palette.

### Phase 2: Indexing Script
Create a helper (e.g., `tools/generate-index.js`) that:
1. Recursively finds `.ps1` and `.sh` files.
2. Extracts comment headers (if available) for descriptions.
3. Saves to `script-dashboard/public/scripts_index.json`.

### Phase 3: Frontend Dev
1. Build `ScriptCard` component.
2. Fetch `scripts_index.json` in `Dashboard.jsx`.
3. Implement Filter/Search logic.

### Phase 4: Execution (Future)
- **Option A (Simple)**: "Copy Command" button.
- **Option B (Advanced)**: Wrap app in Electron. Use `ipcMain` to spawn `powershell.exe` or `wsl.exe` processes when a "Run" button is clicked.

## 7. Distribution & Runtime (No Node.js Required)
To ensure the app runs on clients **without** Node.js or NPM installed:

### Option A: Static Web Application (Browser)
- **Output**: `index.html`, `.css`, and `.js` files.
- **Run**: Open `index.html` in Chrome/Edge.
- **Limit**: Cannot execute system scripts directly (sandboxed).

### Option B: Standalone Executable (Recommended)
- **Technology**: **Electron** or **Tauri**.
- **Output**: A single `.exe` file (e.g., `ScriptDashboard.exe`).
- **Technology**: **[Electron](https://www.electronjs.org/)** or **[Tauri](https://tauri.app/)**.
- **Output**: A single `.exe` file (bundled with runtime).
- **How it works**: Wraps the web app (React) in a standalone shell.
- **Why**: Best compatibility. We will build the React app first (Option A), and later wrap it in Electron/Tauri (Option B) to allow executing system scripts from the UI.

### Option C: Wails (Go + React) -- *Best Match if you like Go*
- **Technology**: **[Wails](https://wails.io/)**.
- **Output**: Single `.exe`, very small file size (native).
- **How it works**: Uses Go for the backend (running your scripts) and React for the UI.
- **Client Requirement**: **None**. The `go build` process compiles everything into machine code. The user does **NOT** need Go installed.
- **Why**: Since you already use Go, this might be the most "native" feeling approach.


## 8. Roadmap / Future Phases

After the frontend is built, the development path proceeds as follows:

### Phase A: Architecture Decision (The Bridge)
**Decision**: Choose between **Electron** (JS) or **Wails** (Go) to handle the "Backend" logic.
- *Why?* A browser app cannot execute `.ps1` files directly. We need a native wrapper to spawn processes.

### Phase B: Execution Integration
**Goal**: Make the "Run" button work.
- **Action**: Write the "Backend" function that takes a script path (e.g., `./Install-FullStackTools.ps1`) and runs it using `powershell.exe`.

### Phase C: Automated Indexing
**Goal**: Stop editing `scripts_index.json` manually.
- **Action**: Create a "Watcher" or "Scanner" that runs on app startup, reads the directory, and auto-generates the list of available scripts.

### Phase D: Installer / Packaging
**Goal**: Distribute to clients.
- **Action**: Configure the build pipeline (GitHub Actions or local script) to output a final `setup.exe` or portable `.zip`.

### Phase E: Hardware Support (Optional GPU)
**Goal**: Detect and configure NVIDIA GPUs for Docker/WSL2 AI workloads.
- **Action (Detection)**: App optionally checks for `nvidia-smi` on the host.
- **Action (Setup)**: If GPU is detected but Docker support is missing, offer to install the **NVIDIA Container Toolkit**.
- **Logic**:
    1. Check `wsl --list` (Must be WSL 2).
    2. Check Host Driver: `nvidia-smi`.
    3. Check Docker Runtime: `docker info | grep nvidia`.


## 9. Development Workflow (Windows Host vs. Container)
Since the app needs to run scripts on the **Host Windows**, but we build in a **Linux Container**, we need a specific workflow:

### A. The "Mock" Mode (Inside Container)
When developing the UI inside the Dev Container, the app cannot see your Windows PowerShell.
- **Solution**: The app detects it is in "Dev Mode".
- **Action**: Clicking "Run" logs to the console: `[Mock] Executing ./Install-FullStackTools.ps1`.
- **Benefit**: You can design the UI safely without breaking your host.

### B. The "Prod" build (On Host)
When you build the final `.exe` and run it on Windows:
- **Solution**: The app detects it is in "Production".
- **Action**: Clicking "Run" spawns the real `powershell.exe` process.
- **Paths**: The app expects scripts to be in the folder **relative to itself** (e.g., `../Install-FullStackTools.ps1` if the app is in `build/`).

## 10. Verification & Testing Strategy
To verify the "Fresh Install" scripts without nuking your main PC:

**Recommended Tool**: [Windows 11 Dev Environments (VMs)](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/)
- **Why**: These are official, free, pre-configured VMs from Microsoft.
- **Expiry**: They expire after ~90 days (perfect for testing).
- **Workflow**:
    1.  Download the Hyper-V or VMWare version.
    2.  Snapshot the VM state immediately as "Clean State".
    3.  Run your `Install-FullStackTools.ps1` or `ScriptDashboard.exe`.
    4.  Verify everything works.
    5.  Revert to "Clean State" for the next test.




