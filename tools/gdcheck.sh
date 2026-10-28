#!/bin/sh
# Parse-checks GDScript files in the Godot project, with a time limit so a broken script can't hang.
# Usage: tools/gdcheck.sh res://scripts/rules/game.gd [more...]
cd "$(dirname "$0")/../godot" || exit 1
for f in "$@"; do
  perl -e 'alarm 60; exec @ARGV' godot --headless --path . --check-only --script "$f" 2>&1 | grep -E "ERROR|error" | head -8
done
