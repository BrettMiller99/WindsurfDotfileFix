#!/bin/bash

# Configuration
DEFAULT_CODEBASE_DIR="Codebase"
CONFIG_FILE="$HOME/.toggle-gitignore.conf"

# Function to load or create configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    elif [ -n "$CODEBASE_PATH" ]; then
        # First run with CODEBASE_PATH provided, save it
        echo "CODEBASE_PATH='$CODEBASE_PATH'" > "$CONFIG_FILE"
        echo "Configuration saved to $CONFIG_FILE"
    fi
}

# Function to detect OS and IDE reload method
setup_environment() {
    # Detect OS
    OS="$(uname -s)"
    case "${OS}" in
        Darwin*) OS='Mac';;    # macOS
        Linux*)  OS='Linux';;  # Linux
        MSYS*|MINGW*) OS='Windows';; # Windows with Git Bash
        *) echo "Unsupported operating system"; exit 1;;
    esac

    # Load saved configuration or use defaults
    load_config

    # Set up codebase directory
    if [ -n "$CODEBASE_PATH" ]; then
        DOCS_DIR="$CODEBASE_PATH"
    else
        # Default locations based on OS
        case "$OS" in
            Mac)    DOCS_DIR="$HOME/Documents/$DEFAULT_CODEBASE_DIR";;  
            Linux)  DOCS_DIR="$HOME/$DEFAULT_CODEBASE_DIR";;  
            Windows) DOCS_DIR="$HOME/Documents/$DEFAULT_CODEBASE_DIR";;
        esac
    fi

    PARENT_GITIGNORE="$DOCS_DIR/.gitignore"
    BACKUP_CONTENT="#Ignore Code Repo\n/$DEFAULT_CODEBASE_DIR/*"
}

# Function to reload IDE
reload_ide() {
    case "$OS" in
        Mac)
            if pgrep -q "Windsurf"; then
                echo "Reloading Windsurf..."
                osascript -e 'tell application "System Events"
                    keystroke "p" using {command down}
                    delay 0.1
                    keystroke ">dev"
                    delay 0.1
                    keystroke return
                    delay 0.1
                    keystroke return
                end tell'
                sleep 0.5
            fi
            ;;
        *) 
            echo "IDE reload not configured for this OS"
            ;;
    esac
}

# Initialize environment
setup_environment

# Get current directory relative to Documents/Codebase
CURRENT_DIR=$(pwd)
REL_PATH=${CURRENT_DIR#$DOCS_DIR/Codebase/}

# Check if we're actually in a Codebase subdirectory
if [[ "$CURRENT_DIR" != *"$DOCS_DIR"* ]]; then
    echo "Error: This script must be run from within $DOCS_DIR/Codebase/*"
    exit 1
fi

# Get the top-level project directory name
PROJECT_DIR=$(echo "$REL_PATH" | cut -d'/' -f1)

# Create the exception content dynamically
EXCEPT_CONTENT="#Ignore Code Repo except current project ($PROJECT_DIR)\n/Codebase/*\n!/Codebase/$PROJECT_DIR\n!/Codebase/$PROJECT_DIR/**"

# Validate directory exists
if [ ! -d "$DOCS_DIR" ]; then
    echo "Error: Codebase directory not found at $DOCS_DIR"
    echo "You can set CODEBASE_PATH environment variable to specify a custom location"
    exit 1
fi

if [ -f "$PARENT_GITIGNORE" ]; then
    current_content=$(cat "$PARENT_GITIGNORE")
    if [ "$current_content" = "$(echo -e "$BACKUP_CONTENT")" ]; then
        # .gitignore is in original state, modify it to include our project
        echo -e "$EXCEPT_CONTENT" > "$PARENT_GITIGNORE"
        echo "Modified parent .gitignore to include $PROJECT_DIR project."
        # Clear Git's cache to ensure changes take effect
        git -C "$DOCS_DIR" rm -r --cached . >/dev/null 2>&1 || true
        # Reload IDE if configured
        reload_ide
        echo "IDE has been reloaded. Autocomplete should now work."
        echo "Run this script again to restore original .gitignore"
    else
        # .gitignore is modified, restore it
        echo -e "$BACKUP_CONTENT" > "$PARENT_GITIGNORE"
        # Clear Git's cache to ensure changes take effect
        git -C "$DOCS_DIR" rm -r --cached . >/dev/null 2>&1 || true
        # Reload IDE if configured
        reload_ide
        echo "Restored original parent .gitignore content and reloaded IDE."
    fi
else
    echo "Parent .gitignore not found at $PARENT_GITIGNORE"
    exit 1
fi
