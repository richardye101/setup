#!/bin/bash

# setup scroll-switch: reverse scrolling while an external mouse is connected,
# natural scrolling otherwise. No admin or Accessibility permission needed.
set -e

INSTALL_DIR="$HOME/opt/scroll-switch"
LABEL="com.$(whoami).scroll-switch"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

# Build for the running macOS, since Xcode's SDK may be newer than the OS
mkdir -p "$INSTALL_DIR"
MACOSX_DEPLOYMENT_TARGET="$(sw_vers -productVersion | cut -d. -f1).0" \
  cc -O2 -Wall -o "$INSTALL_DIR/scroll-switch" scroll-switch/scroll-switch.c \
  -framework IOKit -framework CoreFoundation

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$LABEL</string>
	<key>ProgramArguments</key>
	<array>
		<string>$INSTALL_DIR/scroll-switch</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<true/>
	<key>ProcessType</key>
	<string>Background</string>
	<key>StandardErrorPath</key>
	<string>$HOME/Library/Logs/scroll-switch.log</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
"$INSTALL_DIR/scroll-switch" status
