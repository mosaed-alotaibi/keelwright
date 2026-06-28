#!/usr/bin/env bash
#
# init.sh — install the Keel framework into a target project.
#
# Copies the Keel doc funnel (and, optionally, the Claude Code adapter) into a
# target project, strips the .tmpl suffix, and substitutes the placeholders it
# can. Idempotent-safe: it refuses to overwrite existing files unless --force.
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

# --- locate ourselves + the Keel root ---------------------------------------
# Resolve the directory this script lives in, following one symlink level if any.
_self="$0"
case "$_self" in */*) : ;; *) _self="./$_self" ;; esac
SCRIPT_DIR="$(cd "$(dirname "$_self")" && pwd)"
KEEL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

usage() {
  sed -n '3,23p' "$0" | sed 's/^# \{0,1\}//'
}

# --- defaults / arg parsing --------------------------------------------------
TARGET=""
OPT_NAME=""
OPT_SLUG=""
OPT_OWNER=""
OPT_STACK=""
OPT_REPO=""
WITH_CC=0
FORCE=0
DRY=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --name)    OPT_NAME="${2:-}"; shift 2 ;;
    --slug)    OPT_SLUG="${2:-}"; shift 2 ;;
    --owner)   OPT_OWNER="${2:-}"; shift 2 ;;
    --stack)   OPT_STACK="${2:-}"; shift 2 ;;
    --repo-url) OPT_REPO="${2:-}"; shift 2 ;;
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

[ -n "$TARGET" ] || { usage; echo; die "missing <target-project-dir>"; }

# --- validate target ---------------------------------------------------------
if [ ! -d "$TARGET" ]; then
  die "target is not a directory: $TARGET (create it first, or check the path)"
fi
TARGET="$(cd "$TARGET" && pwd)"   # absolute, normalized

# Refuse to install onto Keel itself (would be writing under the source).
if [ "$TARGET" = "$KEEL_ROOT" ]; then
  die "target is the Keel repo itself; point at the project you want to adopt Keel"
fi

# --- derive substitution values ---------------------------------------------
slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//'
}

PROJECT_NAME="${OPT_NAME:-$(basename "$TARGET")}"
PROJECT_SLUG="${OPT_SLUG:-$(slugify "$PROJECT_NAME")}"

if [ -n "$OPT_OWNER" ]; then
  OWNER="$OPT_OWNER"
else
  OWNER="$(git -C "$TARGET" config user.name 2>/dev/null || true)"
  [ -n "$OWNER" ] || OWNER="${USER:-unknown}"
fi

DATE="$(keel_today)"

# STACK is left as a placeholder when not supplied, so a project that fills it
# later still sees {{STACK}}. (Computed here to avoid brace-nesting ambiguity in
# the substitution call below.)
if [ -n "$OPT_STACK" ]; then STACK_VALUE="$OPT_STACK"; else STACK_VALUE="{{STACK}}"; fi

if [ -n "$OPT_REPO" ]; then
  REPO_URL="$OPT_REPO"
else
  REPO_URL="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
  [ -n "$REPO_URL" ] || REPO_URL="$TARGET"
fi

# Relative path from <target>/docs back to the installed Keel core/adapter, so
# the PROJECT_RULES pointer resolves whether Keel is vendored or sits alongside.
# We can't know the final layout, so emit a best-guess relative path the checklist
# tells the user to verify and repoint.
KEEL_CORE_PATH="../../keel/core"
KEEL_ADAPTER_PATH="../../keel/adapters/claude-code"

log "installing ${_C_BLU}Keel${_C_RST} into: $TARGET"
dim "  name=$PROJECT_NAME  slug=$PROJECT_SLUG  owner=$OWNER  date=$DATE"
[ "$DRY" = "1" ] && warn "dry-run: no files will be written"
[ "$FORCE" = "1" ] && warn "force: existing files WILL be overwritten"

# --- substitution applied to every installed file ---------------------------
apply_subst() {
  _file="$1"
  [ "$DRY" = "1" ] && return 0
  subst_placeholders "$_file" \
    PROJECT_NAME      "$PROJECT_NAME" \
    PROJECT_SLUG      "$PROJECT_SLUG" \
    OWNER             "$OWNER" \
    DATE              "$DATE" \
    STACK             "$STACK_VALUE" \
    REPO_URL          "$REPO_URL" \
    REPO_PATH         "$REPO_URL" \
    KEEL_CORE_PATH    "$KEEL_CORE_PATH" \
    KEEL_ADAPTER_PATH "$KEEL_ADAPTER_PATH"
}

# install_tree <src-dir> <dst-dir> — copy every file under src to dst, stripping
# one trailing .tmpl per file and applying substitution. Honors --force/--dry-run.
# Per-file status is printed as it goes; the checklist summarizes leftovers at the end.
install_tree() {
  _src="$1"; _dst="$2"
  [ -d "$_src" ] || { warn "no template dir: $_src"; return 0; }
  # Portable recursive walk (no GNU find -printf needed).
  find "$_src" -type f | while IFS= read -r _f; do
    _rel="${_f#"$_src"/}"
    _out="$_dst/$(strip_tmpl "$_rel")"
    if [ "$DRY" = "1" ]; then
      if [ -e "$_out" ] && [ "$FORCE" != "1" ]; then
        warn "would skip (exists): $_out"
      else
        ok "would write: $_out"
      fi
      continue
    fi
    if copy_one "$_f" "$_out" "$FORCE"; then
      apply_subst "$_out"
    fi
  done
}

# --- 1. doc funnel: templates/docs/* -> <target>/docs/ ----------------------
log "1/4  doc funnel  →  docs/"
install_tree "$KEEL_ROOT/templates/docs" "$TARGET/docs"

# --- 2. spec + plan skeletons -> <target>/docs/spec-and-plan/ ---------------
log "2/4  spec + plan →  docs/spec-and-plan/"
install_tree "$KEEL_ROOT/templates/spec-and-plan" "$TARGET/docs/spec-and-plan"

# --- 3. optional Claude Code adapter ----------------------------------------
if [ "$WITH_CC" = "1" ]; then
  log "3/4  Claude Code adapter"
  ADAPTER="$KEEL_ROOT/adapters/claude-code"

  # CLAUDE.md.tmpl -> <target>/CLAUDE.md
  if [ "$DRY" = "1" ]; then
    if [ -e "$TARGET/CLAUDE.md" ] && [ "$FORCE" != "1" ]; then
      warn "would skip (exists): $TARGET/CLAUDE.md"
    else
      ok "would write: $TARGET/CLAUDE.md"
    fi
  else
    if copy_one "$ADAPTER/CLAUDE.md.tmpl" "$TARGET/CLAUDE.md" "$FORCE"; then
      apply_subst "$TARGET/CLAUDE.md"
    fi
  fi

  # Memory seeds -> <target>/.keel/memory-seeds/ (the user installs these into
  # their Claude Code auto-memory dir, which lives OUTSIDE the repo).
  if [ "$DRY" = "1" ]; then
    ok "would write: $TARGET/.keel/memory-seeds/{MEMORY.md,_SEED_MEMORIES.md}"
  else
    if copy_one "$ADAPTER/memory/MEMORY.md.tmpl" "$TARGET/.keel/memory-seeds/MEMORY.md" "$FORCE"; then
      apply_subst "$TARGET/.keel/memory-seeds/MEMORY.md"
    fi
    copy_one "$ADAPTER/memory/_SEED_MEMORIES.md" "$TARGET/.keel/memory-seeds/_SEED_MEMORIES.md" "$FORCE" || true
  fi

  # Hook snippet -> <target>/.keel/hooks/settings.snippet.json (to be merged).
  if [ "$DRY" = "1" ]; then
    ok "would write: $TARGET/.keel/hooks/settings.snippet.json (merge into .claude/settings.json)"
  else
    copy_one "$ADAPTER/hooks/settings.snippet.json" "$TARGET/.keel/hooks/settings.snippet.json" "$FORCE" || true
    copy_one "$ADAPTER/hooks/README.md" "$TARGET/.keel/hooks/README.md" "$FORCE" || true
  fi
else
  log "3/4  Claude Code adapter  →  skipped (pass --with-cc-adapter to install)"
fi

# --- 4. post-install checklist ----------------------------------------------
log "4/4  done"

if [ "$DRY" = "1" ]; then
  warn "dry-run complete — nothing was written. Re-run without --dry-run to install."
  exit 0
fi

# Detect placeholders still left in the freshly-installed docs, so the checklist
# can point at exactly what needs filling.
# Scan the installed docs (plus the root CLAUDE.md when the adapter was installed)
# for placeholders still left to fill. The .keel/ seeds are intentionally
# example-laden, so they're excluded to avoid false warnings.
_scan=( "$TARGET/docs" )
[ "$WITH_CC" = "1" ] && _scan+=( "$TARGET/CLAUDE.md" )
REMAINING="$(grep -rlE '\{\{[A-Z0-9_]+\}\}' "${_scan[@]}" 2>/dev/null || true)"

cat >&2 <<EOF

${_C_GRN}Keel installed.${_C_RST}  Post-install checklist:

  1. Fill the remaining {{PLACEHOLDERS}} in the installed docs. Find them with:
       grep -rE '\\{\\{[A-Z0-9_]+\\}\\}' "$TARGET/docs"
  2. Set the live cursor in docs/NEXT-STEPS.md §1 (the single source of resume truth).
  3. Repoint the Keel paths in docs/PROJECT_RULES.md (installed as a guess:
     $KEEL_CORE_PATH and $KEEL_ADAPTER_PATH) to wherever you
     actually keep Keel — see the inline comment near the source-of-truth table.
EOF

if [ "$WITH_CC" = "1" ]; then
  cat >&2 <<EOF
  4. (Claude Code) Install the memory seeds: copy each block in
       $TARGET/.keel/memory-seeds/_SEED_MEMORIES.md
     into your Claude Code auto-memory dir as its own file, and use
       $TARGET/.keel/memory-seeds/MEMORY.md
     as the index.
  5. (Claude Code) Merge the hooks into .claude/settings.json — see
       $TARGET/.keel/hooks/README.md
  6. (Claude Code) Add a ritual-6 headless-browser driver under your scripts/
     (Keel ships none; stacks vary). See the adapter's scripts/README.md.
EOF
fi

if [ -n "$REMAINING" ]; then
  warn "files that still contain placeholders:"
  printf '%s\n' "$REMAINING" | sed 's/^/       /' >&2
fi

ok "Open $TARGET/docs/NEXT-STEPS.md to begin."
