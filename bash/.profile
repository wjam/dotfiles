# While .bash_profile would normally be loaded before .profile, the gnome terminal will _only_ load .profile
#  so load the bash profile ourselves if this shell is bash
if [ -n "$BASH_VERSION" ]; then
  . "$HOME/.bash_profile"
fi
