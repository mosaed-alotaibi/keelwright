#!/usr/bin/env bash
# Keelwright bootstrap — the install engine.
#
# One job: given a fully-resolved config (project name/slug/owner/stack/repo,
# which adapter, force/dry flags), copy the Keelwright doc funnel (+ optional
# adapter) into a target project, strip the .tmpl suffix, and substitute the
# placeholders it can. Idempotent-safe: never overwrites without FORCE.
#
# Sourced by BOTH front-ends — the interactive `keel init` CLI and the
# non-interactive `bootstrap/init.sh` — so the behavior is identical and lives
# in exactly one place. Not meant to run on its own; it reads these globals,
# which the caller must set first:
#
#   KEELWRIGHT_ROOT   absolute path to the Keelwright source checkout
#   KEELWRIGHT_VERSION the version string to stamp into the marker
#   TARGET            absolute, normalized target project dir
#   PROJECT_NAME PROJECT_SLUG OWNER DATE  the substitution values
#   STACK_VALUE       the {{STACK}} value (may be the literal placeholder)
#   REPO_URL          the {{REPO_URL}}/{{REPO_PATH}} value
#   WITH_CC           1 to install the Claude Code adapter, else 0
#   ADAPTER_LABEL     marker label: "claude-code" or "none"
#   FORCE DRY         1/0 flags
#
# Requires common.sh (logging, subst_placeholders, copy_one, strip_tmpl) sourced first.

# Relative path from <target>/docs back to the installed Keelwright core/adapter,
# so the PROJECT_RULES pointer resolves whether Keelwright is vendored or sits
# alongside. We can't know the final layout, so emit a best-guess relative path
# the checklist tells the user to verify and repoint.
KEELWRIGHT_CORE_PATH="../../keelwright/core"
KEELWRIGHT_ADAPTER_PATH="../../keelwright/adapters/claude-code"

# kw_apply_subst <file> — fill every placeholder this installer knows.
kw_apply_subst() {
  _file="$1"
  [ "$DRY" = "1" ] && return 0
  subst_placeholders "$_file" \
    PROJECT_NAME            "$PROJECT_NAME" \
    PROJECT_SLUG            "$PROJECT_SLUG" \
    OWNER                   "$OWNER" \
    DATE                    "$DATE" \
    STACK                   "$STACK_VALUE" \
    REPO_URL                "$REPO_URL" \
    REPO_PATH               "$REPO_URL" \
    KEELWRIGHT_CORE_PATH    "$KEELWRIGHT_CORE_PATH" \
    KEELWRIGHT_ADAPTER_PATH "$KEELWRIGHT_ADAPTER_PATH"
}

# kw_copy_counted <src> <dst> <apply-subst:1|0> — the one place a copy is counted.
# copy_one, then: on success optionally substitute placeholders; on a REAL failure
# (rc 2 from cp/mkdir) bump KW_COPY_ERRORS; a no-overwrite skip (rc 1) is fine.
# Never returns non-zero itself, so callers under `set -e` are safe. Used by BOTH
# the doc-funnel walk and the adapter copies, so neither path can silently swallow
# a failure and let the installer claim success.
kw_copy_counted() {
  _kc_src="$1"; _kc_dst="$2"; _kc_subst="${3:-0}"
  _kc_rc=0; copy_one "$_kc_src" "$_kc_dst" "$FORCE" || _kc_rc=$?
  if [ "$_kc_rc" = "0" ]; then
    if [ "$_kc_subst" = "1" ]; then kw_apply_subst "$_kc_dst"; fi
  elif [ "$_kc_rc" = "2" ]; then
    KW_COPY_ERRORS=$((KW_COPY_ERRORS + 1))
  fi
  return 0
}

# install_tree <src-dir> <dst-dir> — copy every file under src to dst, stripping
# one trailing .tmpl per file and applying substitution. Honors FORCE/DRY, and
# counts genuine copy failures into KW_COPY_ERRORS so the caller can refuse to
# claim success. The walk uses process substitution (not `find | while`) so the
# loop runs in THIS shell and its counter survives; the find walk stays portable
# (no GNU -printf).
install_tree() {
  _src="$1"; _dst="$2"
  [ -d "$_src" ] || { warn "no template dir: $_src"; return 0; }
  while IFS= read -r _f; do
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
    kw_copy_counted "$_f" "$_out" 1
  done < <(find "$_src" -type f)
}

# kw_write_marker — record the init metadata so `keel` can tell this is a
# Keelwright project (and refuse a silent re-init). Safe to hand-edit.
kw_write_marker() {
  [ "$DRY" = "1" ] && { ok "would write: $TARGET/.keelwright/config"; return 0; }
  mkdir -p "$TARGET/.keelwright" || return 1
  cat > "$TARGET/.keelwright/config" <<EOF
# Keelwright project — written by \`keel init\`. Safe to read; safe to edit.
# This marker is how \`keel\` recognises an already-initialised project.
name=$PROJECT_NAME
slug=$PROJECT_SLUG
owner=$OWNER
created=$DATE
adapter=$ADAPTER_LABEL
keelwright_version=$KEELWRIGHT_VERSION
EOF
  ok "$TARGET/.keelwright/config"
}

# kw_run_install — the whole install, start to finish.
kw_run_install() {
  KW_COPY_ERRORS=0
  log "installing ${_C_BLD}Keelwright${_C_RST} into: $TARGET"
  dim "  name=$PROJECT_NAME  slug=$PROJECT_SLUG  owner=$OWNER  date=$DATE  adapter=$ADAPTER_LABEL"
  [ "$DRY" = "1" ]   && warn "dry-run: no files will be written"
  [ "$FORCE" = "1" ] && warn "force: existing files WILL be overwritten"

  # --- 1. doc funnel: templates/docs/* -> <target>/docs/ ---
  log "1/5  doc funnel   →  docs/"
  install_tree "$KEELWRIGHT_ROOT/templates/docs" "$TARGET/docs"

  # --- 2. spec + plan skeletons -> <target>/docs/spec-and-plan/ ---
  log "2/5  spec + plan  →  docs/spec-and-plan/"
  install_tree "$KEELWRIGHT_ROOT/templates/spec-and-plan" "$TARGET/docs/spec-and-plan"

  # The doc funnel is the required core of an install. If any of it failed to
  # copy (e.g. a read-only target), do NOT write the marker or claim success —
  # that would be a "done" without verification, the very thing Keelwright forbids.
  if [ "$DRY" != "1" ] && [ "${KW_COPY_ERRORS:-0}" -gt 0 ]; then
    err "doc-funnel install incomplete: $KW_COPY_ERRORS file(s) could not be written (see the errors above)."
    err "Not writing the project marker. Fix the cause (often a permissions/path issue), then re-run."
    return 1
  fi

  # --- 3. optional Claude Code adapter ---
  if [ "$WITH_CC" = "1" ]; then
    log "3/5  Claude Code adapter"
    _adapter="$KEELWRIGHT_ROOT/adapters/claude-code"

    # CLAUDE.md.tmpl -> <target>/CLAUDE.md
    if [ "$DRY" = "1" ]; then
      if [ -e "$TARGET/CLAUDE.md" ] && [ "$FORCE" != "1" ]; then
        warn "would skip (exists): $TARGET/CLAUDE.md"
      else
        ok "would write: $TARGET/CLAUDE.md"
      fi
    else
      kw_copy_counted "$_adapter/CLAUDE.md.tmpl" "$TARGET/CLAUDE.md" 1
    fi

    # Memory seeds -> <target>/.keelwright/memory-seeds/ (the user installs these
    # into their Claude Code auto-memory dir, which lives OUTSIDE the repo).
    if [ "$DRY" = "1" ]; then
      ok "would write: $TARGET/.keelwright/memory-seeds/{MEMORY.md,_SEED_MEMORIES.md}"
    else
      kw_copy_counted "$_adapter/memory/MEMORY.md.tmpl" "$TARGET/.keelwright/memory-seeds/MEMORY.md" 1
      kw_copy_counted "$_adapter/memory/_SEED_MEMORIES.md" "$TARGET/.keelwright/memory-seeds/_SEED_MEMORIES.md" 0
    fi

    # Hook snippet -> <target>/.keelwright/hooks/settings.snippet.json (to be merged).
    if [ "$DRY" = "1" ]; then
      ok "would write: $TARGET/.keelwright/hooks/settings.snippet.json (merge into .claude/settings.json)"
    else
      kw_copy_counted "$_adapter/hooks/settings.snippet.json" "$TARGET/.keelwright/hooks/settings.snippet.json" 0
      kw_copy_counted "$_adapter/hooks/README.md" "$TARGET/.keelwright/hooks/README.md" 0
    fi
  else
    log "3/5  Claude Code adapter  →  skipped"
  fi

  # An explicitly-requested adapter that failed to install is a failure too. The
  # funnel gate above already returned on funnel errors, so any count remaining
  # here is from step 3 — don't write the marker or claim success on a partial adapter.
  if [ "$DRY" != "1" ] && [ "${KW_COPY_ERRORS:-0}" -gt 0 ]; then
    err "adapter install incomplete: $KW_COPY_ERRORS file(s) could not be written (see the errors above)."
    err "Not writing the project marker. Fix the cause (often a permissions/path issue), then re-run."
    return 1
  fi

  # --- 4. project marker ---
  log "4/5  project marker  →  .keelwright/config"
  kw_write_marker

  # --- 5. post-install checklist ---
  log "5/5  done"

  if [ "$DRY" = "1" ]; then
    warn "dry-run complete — nothing was written. Re-run without --dry-run to install."
    return 0
  fi

  # Detect placeholders still left in the freshly-installed docs (plus the root
  # CLAUDE.md when the adapter was installed). The .keelwright/ seeds are
  # intentionally example-laden, so they're excluded to avoid false warnings.
  _scan=( "$TARGET/docs" )
  [ "$WITH_CC" = "1" ] && _scan+=( "$TARGET/CLAUDE.md" )
  REMAINING="$(grep -rlE '\{\{[A-Z0-9_]+\}\}' "${_scan[@]}" 2>/dev/null || true)"

  cat >&2 <<EOF

${_C_GRN}${_C_BLD}Keelwright initialised.${_C_RST}  Next steps:

  1. Fill the remaining {{PLACEHOLDERS}} in the installed docs. Find them with:
       grep -rE '\\{\\{[A-Z0-9_]+\\}\\}' "$TARGET/docs"
  2. Set the live cursor in docs/NEXT-STEPS.md §1 (the single source of resume truth).
  3. Repoint the Keelwright paths in docs/PROJECT_RULES.md (installed as a guess:
     $KEELWRIGHT_CORE_PATH and $KEELWRIGHT_ADAPTER_PATH) to wherever you
     actually keep Keelwright — see the inline comment near the source-of-truth table.
EOF

  if [ "$WITH_CC" = "1" ]; then
    cat >&2 <<EOF
  4. (Claude Code) Install the memory seeds: copy each block in
       $TARGET/.keelwright/memory-seeds/_SEED_MEMORIES.md
     into your Claude Code auto-memory dir as its own file, and use
       $TARGET/.keelwright/memory-seeds/MEMORY.md
     as the index.
  5. (Claude Code) Merge the hooks into .claude/settings.json — see
       $TARGET/.keelwright/hooks/README.md
  6. (Claude Code) Add a Ritual-6 headless-browser driver under your scripts/
     (Keelwright ships none; stacks vary). See the adapter's scripts/README.md.
EOF
  fi

  if [ -n "$REMAINING" ]; then
    warn "files that still contain placeholders:"
    printf '%s\n' "$REMAINING" | sed 's/^/       /' >&2
  fi

  ok "Open $TARGET/docs/NEXT-STEPS.md to begin."
}
