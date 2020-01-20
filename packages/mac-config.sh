#!/usr/bin/env bash

# Exit on error. Append || true if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
#set -o xtrace

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# iTerm2
# Stop confirming when quitting
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
# Font to the LiterationMono - Powerline font
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Normal Font\" \"LiterationMonoPowerline 12\""  ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Non Ascii Font\" \"LiterationMonoPowerline 12\""  ~/Library/Preferences/com.googlecode.iterm2.plist
# New windows to be 124x30
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Columns\" 124"  ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Rows\" 30"  ~/Library/Preferences/com.googlecode.iterm2.plist
# Unlimited Scrollback
/usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Unlimited Scrollback' true" ~/Library/Preferences/com.googlecode.iTerm2.plist
# Reuse previous session directory
/usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Custom Directory' Recycle" ~/Library/Preferences/com.googlecode.iTerm2.plist
