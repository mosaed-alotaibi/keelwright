#!/usr/bin/env bash
# Keel bootstrap — shared helpers. Sourced by init.sh; not meant to run alone.
# POSIX-bash, portable across macOS (BSD) and Linux (GNU) userland.

# --- logging -----------------------------------------------------------------
# Colorize only when stderr is a TTY, so piped/CI output stays clean.
if [ -t 2 ]; then
  _C_RED=$'\033[31m'; _C_GRN=$'\033[32m'; _C_YEL=$'\033[33m'
  _C_BLU=$'\033[34m'; _C_DIM=$'\033[2m';  _C_RST=$'\033[0m'
else
  _C_RED=''; _C_GRN=''; _C_YEL=''; _C_BLU=''; _C_DIM=''; _C_RST=''
fi

log()  { printf '%s\n' "${_C_BLU}keel${_C_RST} $*" >&2; }
ok()   { printf '%s\n' "${_C_GRN}  ok${_C_RST} $*" >&2; }
warn() { printf '%s\n' "${_C_YEL}warn${_C_RST} $*" >&2; }
err()  { printf '%s\n' "${_C_RED} err${_C_RST} $*" >&2; }
dim()  { printf '%s\n' "${_C_DIM}$*${_C_RST}" >&2; }
die()  { err "$*"; exit 1; }

# --- placeholder substitution ------------------------------------------------
# Escape a replacement string so it is safe on the right-hand side of sed's
# s/// (escapes &, \, and the delimiter |). Keeps init.sh portable without
# depending on GNU-only sed features.
sed_escape_replacement() {
  printf '%s' "$1" | sed -e 's/[&\\|]/\\&/g'
}

# subst_placeholders <file> <NAME> <VALUE> [<NAME> <VALUE> ...]
# In-place replace every {{NAME}} with VALUE, portably (writes via a temp file
# so it works on both BSD and GNU sed without -i quirks).
subst_placeholders() {
  _sp_file="$1"; shift
  [ -f "$_sp_file" ] || { warn "subst: no such file: $_sp_file"; return 0; }
  _sp_tmp="${_sp_file}.keel.tmp.$$"
  cp "$_sp_file" "$_sp_tmp" || return 1
  while [ "$#" -ge 2 ]; do
    _sp_name="$1"; _sp_val="$2"; shift 2
    _sp_esc=$(sed_escape_replacement "$_sp_val")
    # Use | as the s/// delimiter (escaped in the replacement above) so values
    # containing / (paths, URLs) don't need special handling.
    sed -e "s|{{${_sp_name}}}|${_sp_esc}|g" "$_sp_tmp" > "${_sp_tmp}.2" \
      && mv "${_sp_tmp}.2" "$_sp_tmp"
  done
  mv "$_sp_tmp" "$_sp_file"
}

# --- file copying ------------------------------------------------------------
# copy_one <src> <dst> <force?:0|1>
# Copies src→dst, creating parent dirs. Refuses to overwrite an existing dst
# unless force=1. Returns: 0 copied, 1 skipped (exists), 2 error.
copy_one() {
  _co_src="$1"; _co_dst="$2"; _co_force="$3"
  [ -f "$_co_src" ] || { err "copy: missing source $_co_src"; return 2; }
  if [ -e "$_co_dst" ] && [ "$_co_force" != "1" ]; then
    warn "exists, skipped (use --force): ${_co_dst}"
    return 1
  fi
  mkdir -p "$(dirname "$_co_dst")" || return 2
  cp "$_co_src" "$_co_dst" || return 2
  ok "${_co_dst}"
  return 0
}

# strip_tmpl <path> — drop a single trailing ".tmpl" suffix if present.
strip_tmpl() { printf '%s' "${1%.tmpl}"; }

# today's date in ISO form, portable.
keel_today() { date +%Y-%m-%d; }
