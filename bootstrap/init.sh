#!/usr/bin/env bash
#
# init.sh — non-interactive installer for the Keelwright framework.
#
# This is the scriptable / CI front-end. For a guided, interactive setup prefer
# the top-level `keel init` command (run it like `git init`). Both share the
# same install engine (bootstrap/lib/install.sh), so the result is identical.
#
# Usage:
#   init.sh <target-project-dir> [options]
#
# Options:
#   --name "Project Name"     Value for {{PROJECT_NAME}}     (default: target dir basename)
#   --slug project-slug       Value for {{PROJECT_SLUG}}     (default: slugified --name)
#   --owner "Name"            Value for {{OWNER}}            (default: git user.name, else $USER)
#   --stack "Tech, Tech"      Value for {{STACK}}            (default: left as a placeholder)
#   --repo-url URL            Value for {{REPO_URL}}/{{REPO_PATH}} (default: target dir / git remote)
#   --with-cc-adapter         Also install the Claude Code adapter (CLAUDE.md, memory seeds, hooks).
#   --force                   Overwrite files that already exist (default: skip, never destructive).
#   --dry-run                 Show what would happen; write nothing.
#   -h, --help                This help.
#
# Safe by default: nothing is overwritten and nothing outside <target> is touched.

set -euo pipefail

# --- locate ourselves + the Keelwright root ---------------------------------
_self="$0"
case "$_self" in */*) : ;; *) _self="./$_self" ;; esac
SCRIPT_DIR="$(cd "$(dirname "$_self")" && pwd)"
KEELWRIGHT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KEELWRIGHT_VERSION="$(sed -n '1p' "$KEELWRIGHT_ROOT/VERSION" 2>/dev/null | tr -d '[:space:]')"
[ -n "$KEELWRIGHT_VERSION" ] || KEELWRIGHT_VERSION="0.0.0"

# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/install.sh
. "$SCRIPT_DIR/lib/install.sh"

usage() { sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//'; }

# --- defaults / arg parsing --------------------------------------------------
TARGET=""
OPT_NAME=""; OPT_SLUG=""; OPT_OWNER=""; OPT_STACK=""; OPT_REPO=""
WITH_CC=0; FORCE=0; DRY=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --name|--slug|--owner|--stack|--repo-url)
      [ "$#" -ge 2 ] || die "$1 requires a value (try --help)"
      case "$1" in
        --name) OPT_NAME="$2" ;; --slug) OPT_SLUG="$2" ;; --owner) OPT_OWNER="$2" ;;
        --stack) OPT_STACK="$2" ;; --repo-url) OPT_REPO="$2" ;;
      esac
      shift 2 ;;
    --with-cc-adapter) WITH_CC=1; shift ;;
    --force)   FORCE=1; shift ;;
    --dry-run) DRY=1; shift ;;
    --) shift; break ;;
    -*) die "unknown option: $1 (try --help)" ;;
    *)
      if [ -z "$TARGET" ]; then TARGET="$1"; shift
      else die "unexpected extra argument: $1 (try --help)"; fi
      ;;
  esac
done
# A positional after `--` (POSIX end-of-options) is still the target dir; reject extras.
if [ -z "$TARGET" ] && [ "$#" -gt 0 ]; then TARGET="$1"; shift; fi
if [ "$#" -gt 0 ]; then die "unexpected extra argument: $1 (try --help)"; fi

[ -n "$TARGET" ] || { usage; echo; die "missing <target-project-dir>"; }

# --- validate target ---------------------------------------------------------
[ -d "$TARGET" ] || die "target is not a directory: $TARGET (create it first, or check the path)"
TARGET="$(cd -- "$TARGET" && pwd)"   # absolute, normalized (`--` guards a `-`-prefixed dir)

if [ "$TARGET" = "$KEELWRIGHT_ROOT" ]; then
  die "target is the Keelwright repo itself; point at the project you want to adopt Keelwright"
fi

# --- derive substitution values (flag > smart default) ----------------------
PROJECT_NAME="${OPT_NAME:-$(basename -- "$TARGET")}"
PROJECT_SLUG="${OPT_SLUG:-$(slugify "$PROJECT_NAME")}"

if [ -n "$OPT_OWNER" ]; then
  OWNER="$OPT_OWNER"
else
  OWNER="$(git -C "$TARGET" config user.name 2>/dev/null || true)"
  [ -n "$OWNER" ] || OWNER="${USER:-unknown}"
fi

DATE="$(keelwright_today)"

if [ -n "$OPT_STACK" ]; then STACK_VALUE="$OPT_STACK"; else STACK_VALUE="{{STACK}}"; fi

if [ -n "$OPT_REPO" ]; then
  REPO_URL="$OPT_REPO"
else
  REPO_URL="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
  [ -n "$REPO_URL" ] || REPO_URL="$TARGET"
fi

if [ "$WITH_CC" = "1" ]; then ADAPTER_LABEL="claude-code"; else ADAPTER_LABEL="none"; fi

# --- run the shared engine ---------------------------------------------------
kw_run_install
