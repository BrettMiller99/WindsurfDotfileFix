# Toggle Gitignore Script Documentation

This script helps manage visibility of your projects in IDEs by dynamically modifying the parent directory's `.gitignore` file. It's particularly useful when working with multiple projects and you want to selectively expose only the current project to your IDE.

## Installation

1. **Download the Script**:

   - Place `toggle-gitignore.sh` in a convenient location (recommended: `~/.local/bin/`)

   ```bash
   mkdir -p ~/.local/bin
   cp toggle-gitignore.sh ~/.local/bin/
   chmod +x ~/.local/bin/toggle-gitignore.sh
   ```
2. **Add to PATH**:

   - Add the following line to your shell configuration file (`~/.zshrc` for Zsh or `~/.bashrc` for Bash):

   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

   - Reload your shell configuration:

   ```bash
   source ~/.zshrc  # or source ~/.bashrc for Bash
   ```

## First-Time Setup

1. **Identify Your Codebase Directory**:

   - This is the parent directory containing all your projects
   - Example: If your projects are in `/Users/username/Documents/Codebase/`, that's your codebase directory
2. **Initial Run**:

   ```bash
   CODEBASE_PATH="/path/to/your/codebase/parent" toggle-gitignore.sh
   ```

   - Example: `CODEBASE_PATH="/Users/username/Documents" toggle-gitignore.sh`
   - The script will save this configuration to `~/.toggle-gitignore.conf`

## Regular Usage

1. **Navigate to Project**:

   ```bash
   cd /path/to/your/project
   ```
2. **Toggle Project Visibility**:

   ```bash
   toggle-gitignore.sh
   ```

   - First run: Makes your current project visible to the IDE
   - Second run: Hides all projects again

## How It Works

1. **Configuration Storage**:

   - The script stores your codebase path in `~/.toggle-gitignore.conf`
   - You only need to set `CODEBASE_PATH` once during first-time setup
2. **Gitignore Management**:

   - Creates/modifies the parent directory's `.gitignore`
   - Toggles between two states:
     - Hide all projects: `/Codebase/*`
     - Show current project: `/Codebase/* + exception for current project`
3. **IDE Integration**:

   - Automatically reloads IDE (currently supports Windsurf on macOS)
   - Clears Git cache to ensure changes take effect

## Supported Operating Systems

- **macOS**: Full support with IDE reload
- **Linux**: Basic support (no IDE reload)
- **Windows**: Basic support with Git Bash (no IDE reload)

## Troubleshooting

1. **Script Not Found**:

   - Ensure the script is in your PATH
   - Verify script permissions (`chmod +x`)
2. **Wrong Codebase Path**:

   - Delete `~/.toggle-gitignore.conf`
   - Run again with correct `CODEBASE_PATH`
3. **IDE Not Reloading**:

   - Currently, automatic IDE reload only works with Windsurf on macOS
   - For other IDEs, manually refresh your project view

## Example Directory Structure

```
/Users/username/Documents/          <- CODEBASE_PATH
├── Codebase/                      <- Default project directory
│   ├── Project1/
│   ├── Project2/
│   └── Project3/
└── .gitignore                     <- Managed by the script
```

## Notes

- The script must be run from within a project directory under your codebase path
- Each toggle operation clears Git's cache to ensure changes take effect
- Configuration is persistent across sessions
- IDE reload feature is currently macOS/Windsurf-specific
