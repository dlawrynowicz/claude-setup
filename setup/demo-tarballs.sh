#!/usr/bin/env bash
# Demo-machine tarball helper for the Claude Code curation workshop.
# Captures or restores ~/.claude snapshots ("before" = overloaded, "after" = curated).
#
# Usage:
#   ./demo-tarballs.sh make before     # snapshot current ~/.claude as "before"
#   ./demo-tarballs.sh make after      # snapshot current ~/.claude as "after"
#   ./demo-tarballs.sh load before     # restore "before" state (auto-backup of current)
#   ./demo-tarballs.sh load after      # restore "after" state (auto-backup of current)
#
# Snapshots exclude cache/, sessions/, projects/, backups/ (large + ephemeral).
# Tarballs land in $HOME/claude-demo-{before,after}.tar.gz.

set -euo pipefail

mode="${1:-}"
state="${2:-}"

if [[ "$mode" != "make" && "$mode" != "load" ]] || [[ "$state" != "before" && "$state" != "after" ]]; then
  echo "Usage: $0 {make|load} {before|after}" >&2
  exit 1
fi

archive="$HOME/claude-demo-${state}.tar.gz"

case "$mode" in
  make)
    if [ ! -d "$HOME/.claude" ]; then
      echo "ERROR: $HOME/.claude does not exist — nothing to snapshot." >&2
      exit 1
    fi
    echo "Snapshotting $HOME/.claude → $archive"
    tar czf "$archive" \
      --exclude=".claude/cache" \
      --exclude=".claude/sessions" \
      --exclude=".claude/projects" \
      --exclude=".claude/backups" \
      -C "$HOME" .claude
    echo "Done. Size: $(du -h "$archive" | cut -f1)"
    ;;
  load)
    if [ ! -f "$archive" ]; then
      echo "ERROR: $archive not found. Run '$0 make $state' first." >&2
      exit 1
    fi
    if [ -d "$HOME/.claude" ]; then
      backup="$HOME/.claude.bak.$(date +%Y%m%d-%H%M%S)"
      echo "Backing up current $HOME/.claude → $backup"
      mv "$HOME/.claude" "$backup"
    fi
    echo "Restoring $archive → $HOME/.claude"
    tar xzf "$archive" -C "$HOME"
    echo "Done. Restart Claude Code to pick up the new state."
    ;;
esac
