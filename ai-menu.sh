#!/bin/zsh

# This script is called by Helix. It expects the filetype as the first argument.
# e.g., ai_menu.sh python

# Ensure we have a filetype argument
if [ -z "$1" ]; then
    echo "Error: No filetype provided." >&2
    exit 1
fi
FILETYPE="$1"

# --- Use gum to get the user's choice ---
# The header provides context. The options are the actions the user can take.
CHOICE=$(gum choose \
    --header "What do you want to do with the selected $FILETYPE code?" \
    "Refactor" \
    "Generate Docstring" \
    "Generate Tests" \
    "Ask a custom question...")

# Exit if the user pressed Esc
if [ -z "$CHOICE" ]; then
    exit 0
fi

# --- Read the selected code from stdin (piped from Helix) ---
SELECTED_CODE=$(cat pbpaste)

# --- Use a case statement to build the correct prompt for mods ---
case "$CHOICE" in
    "Refactor")
        PROMPT="You are an expert $FILETYPE programmer. Suggest a refactoring for the following code to improve clarity, performance, and idiomatic style. Explain your reasoning."
        ;;
    "Generate Docstring")
        PROMPT="Generate a complete and idiomatic docstring for the following $FILETYPE code. Do not include the original code in your response."
        ;;
    "Generate Tests")
        PROMPT="Generate a comprehensive suite of unit tests for the following $FILETYPE code using a standard testing framework (e.g., pytest for Python, Go's native testing package). Do not include the original code in your response."
        ;;
    "Ask a custom question...")
        # For a custom question, we need another gum prompt to get the user's input
        CUSTOM_QUESTION=$(gum input --placeholder "Your question about the selected code...")
        
        # Exit if the user entered nothing
        if [ -z "$CUSTOM_QUESTION" ]; then
            exit 0
        fi
        
        PROMPT="$CUSTOM_QUESTION. Here is the relevant $FILETYPE code for context:"
        ;;
esac

# --- Execute mods with the selection and the generated prompt ---
# The output of this command is what Helix will receive.
# We use --quiet to remove the spinner and --format-text for clean output.
echo "$SELECTED_CODE" | mods --quiet --format-text "$PROMPT"

