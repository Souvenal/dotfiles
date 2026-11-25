#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

usage() {
  cat <<'EOF'
Usage:
  ./sync_dsh.sh [options]

Synchronize already-managed DSH configuration into this chezmoi repository.
No upgrade is performed unless --upgrade is supplied.

Options:
  --upgrade              Upgrade DSH and update profile plugins.
  --dsh-version VERSION  DSH npm version/dist-tag; implies --upgrade.
                         Required for upgrades; use "latest" explicitly if wanted.
  --latest-plugins      Ignore plugin version ranges and update to latest.
  --dry-run             Run checks and show status without changing anything.
  --yes                 Skip the interactive confirmation (for automation).
  --assume-dsh-stopped  Skip the process check when pgrep is unavailable or
                        produces a known false positive. Use with care.
  -h, --help            Show this help.

Environment overrides:
  CHEZMOI_SOURCE        Chezmoi source directory (default: script directory).
  CHEZMOI_DESTINATION   Destination home directory (default: $HOME).
  DSH_HOME              DSH data directory (default: $DESTINATION/.dsh).
  DSH_PROFILE           Profile to synchronize (default: web).
  DSH_VERSION           Alternative to --dsh-version.

Examples:
  ./sync_dsh.sh --dry-run
  ./sync_dsh.sh --yes
  ./sync_dsh.sh --upgrade --dsh-version 1.2.3
  ./sync_dsh.sh --upgrade --dsh-version latest --latest-plugins
EOF
}

log() {
  printf '[sync-dsh] %s\n' "$*"
}

warn() {
  printf '[sync-dsh] WARNING: %s\n' "$*" >&2
}

die() {
  printf '[sync-dsh] ERROR: %s\n' "$*" >&2
  exit 1
}

UPGRADE=0
LATEST_PLUGINS=0
DRY_RUN=0
ASSUME_YES=0
ASSUME_DSH_STOPPED=0
DSH_VERSION="${DSH_VERSION:-}"

while (($#)); do
  case "$1" in
    --upgrade)
      UPGRADE=1
      shift
      ;;
    --dsh-version)
      (($# >= 2)) || die "--dsh-version requires a value"
      DSH_VERSION="$2"
      UPGRADE=1
      shift 2
      ;;
    --latest-plugins)
      LATEST_PLUGINS=1
      UPGRADE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    --assume-dsh-stopped)
      ASSUME_DSH_STOPPED=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "unknown option: $1"
      ;;
  esac
done

[[ ${EUID:-} != 0 ]] || die "do not run as root; use the account that owns DSH and chezmoi"
[[ -n ${HOME:-} ]] || die "HOME is not set"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_DIR="${CHEZMOI_SOURCE:-$SCRIPT_DIR}"
DESTINATION_DIR="${CHEZMOI_DESTINATION:-$HOME}"

[[ -d $SOURCE_DIR ]] || die "chezmoi source directory not found: $SOURCE_DIR"
[[ -d $DESTINATION_DIR ]] || die "destination directory not found: $DESTINATION_DIR"
SOURCE_DIR="$(cd -- "$SOURCE_DIR" && pwd -P)"
DESTINATION_DIR="$(cd -- "$DESTINATION_DIR" && pwd -P)"

DSH_ROOT="${DSH_HOME:-$DESTINATION_DIR/.dsh}"
PROFILE="${DSH_PROFILE:-web}"
AGENT_PRESETS_TARGET="$DSH_ROOT/.agent-presets"
CREDENTIALS_TARGET="$DSH_ROOT/.credentials.yaml"
TARGETS=(
  "$AGENT_PRESETS_TARGET"
  "$DSH_ROOT/profiles/$PROFILE/cordis.patch.yml"
  "$DSH_ROOT/profiles/$PROFILE/package.json"
  "$DSH_ROOT/profiles/$PROFILE/pnpm-lock.yaml"
  "$DSH_ROOT/profiles/$PROFILE/pnpm-workspace.yaml"
  "$CREDENTIALS_TARGET"
)

for command_name in chezmoi git; do
  command -v "$command_name" >/dev/null 2>&1 || die "required command not found: $command_name"
done
if ((UPGRADE)); then
  for command_name in npm dsh; do
    command -v "$command_name" >/dev/null 2>&1 || die "required command not found: $command_name"
  done
  [[ -n $DSH_VERSION ]] || die "upgrades require --dsh-version VERSION (or explicitly 'latest')"
  [[ $DSH_VERSION != *[[:space:]]* ]] || die "DSH version must not contain whitespace"
fi

if ! REPOSITORY_ROOT="$(git -C "$SOURCE_DIR" rev-parse --show-toplevel 2>/dev/null)"; then
  die "chezmoi source is not inside a Git repository: $SOURCE_DIR"
fi
REPOSITORY_ROOT="$(cd -- "$REPOSITORY_ROOT" && pwd -P)"
[[ $REPOSITORY_ROOT == "$SOURCE_DIR" ]] || die "chezmoi source must be the Git repository root: $SOURCE_DIR"

CHEZMOI=(chezmoi --source "$SOURCE_DIR" --destination "$DESTINATION_DIR" --no-pager)
SOURCE_PATHS=()
for target in "${TARGETS[@]}"; do
  [[ -e $target || -L $target ]] || die "target does not exist: $target"
  if ! source_path="$("${CHEZMOI[@]}" source-path "$target")"; then
    die "target is not managed by chezmoi; add it explicitly first: $target"
  fi
  # Windows chezmoi prints C:/..., while Git Bash pwd prints /c/....
  if [[ $source_path =~ ^[[:alpha:]]:[/\\] ]] && command -v cygpath >/dev/null 2>&1; then
    source_path="$(cygpath -u "$source_path")"
  fi
  case "$source_path" in
    "$SOURCE_DIR"/*) ;;
    *) die "target resolves outside the expected source directory: $source_path" ;;
  esac
  SOURCE_PATHS+=("${source_path#"$SOURCE_DIR"/}")
done
[[ -d $AGENT_PRESETS_TARGET ]] || die "agent presets target is not a directory: $AGENT_PRESETS_TARGET"

credential_source="$("${CHEZMOI[@]}" source-path "$CREDENTIALS_TARGET")"
credential_name="${credential_source##*/}"
case "$credential_name" in
  encrypted_private_*|private_encrypted_*) ;;
  *)
    die "credentials must retain encrypted_ and private_ source attributes; got: $credential_name"
    ;;
esac

if ! unmanaged_files="$("${CHEZMOI[@]}" unmanaged --include files "$AGENT_PRESETS_TARGET")"; then
  die "could not check for unmanaged agent preset files"
fi
if [[ -n $unmanaged_files ]]; then
  printf '[sync-dsh] Unmanaged preset files:\n%s\n' "$unmanaged_files" >&2
  die "add or ignore these files before syncing; re-add would silently skip them"
fi

if ! source_status="$(git -C "$SOURCE_DIR" status --short -- "${SOURCE_PATHS[@]}")"; then
  die "could not inspect the chezmoi source Git status"
fi
if [[ -n $source_status ]]; then
  printf '[sync-dsh] Related source changes:\n%s\n' "$source_status" >&2
  die "commit or stash related source changes first; sync would overwrite them"
fi

if ((ASSUME_DSH_STOPPED)); then
  warn "DSH process check skipped by request"
else
  command -v pgrep >/dev/null 2>&1 ||
    die "pgrep is unavailable; stop DSH and rerun with --assume-dsh-stopped"
  dsh_pids="$(pgrep -u "$UID" -f '@deepseek-ai/dsh|[/]dsh/profiles/' || true)"
  if [[ -n $dsh_pids ]]; then
    printf '[sync-dsh] Running DSH-related PIDs:\n%s\n' "$dsh_pids" >&2
    die "stop all DSH processes before upgrading or synchronizing"
  fi
fi

if ! target_status="$("${CHEZMOI[@]}" status "${TARGETS[@]}")"; then
  die "could not inspect DSH target status"
fi
log "Source: $SOURCE_DIR"
log "Destination: $DESTINATION_DIR"
log "Profile: $PROFILE"
if [[ -n $target_status ]]; then
  printf '[sync-dsh] Pending target status (paths only; no secret diffs):\n%s\n' "$target_status"
else
  log "No target-state differences reported"
fi
if ((UPGRADE)); then
  log "Upgrade plan: @deepseek-ai/dsh@$DSH_VERSION"
  if [[ $DSH_VERSION == latest ]]; then
    warn "DSH is explicitly set to an unpinned latest release"
  fi
  if ((LATEST_PLUGINS)); then
    warn "plugins will ignore package.json ranges and update to latest"
  else
    log "Plugin updates will respect package.json version ranges"
  fi
fi

if ((DRY_RUN)); then
  log "Dry run passed; no changes made"
  exit 0
fi

if ((!ASSUME_YES)); then
  [[ -t 0 ]] || die "confirmation required; rerun with --yes in non-interactive use"
  read -r -p "Proceed with the displayed plan? [y/N] " reply
  case "$reply" in
    y|Y|yes|YES) ;;
    *) log "Cancelled; no changes made"; exit 0 ;;
  esac
fi

LOCK_DIR="${SYNC_DSH_LOCK_DIR:-${TMPDIR:-/tmp}/sync-dsh-$UID.lock}"
CHANGES_STARTED=0
LOCK_ACQUIRED=0
cleanup() {
  local exit_status=$?
  if ((LOCK_ACQUIRED)); then
    rmdir -- "$LOCK_DIR" 2>/dev/null || true
  fi
  if ((exit_status != 0 && CHANGES_STARTED)); then
    warn "failed after changes began; DSH or chezmoi source may be partially updated"
    warn "inspect 'git -C \"$SOURCE_DIR\" diff' before retrying"
  fi
}
trap cleanup EXIT

if ! mkdir -- "$LOCK_DIR" 2>/dev/null; then
  die "another sync appears to be running, or a stale lock exists: $LOCK_DIR"
fi
LOCK_ACQUIRED=1
CHANGES_STARTED=1

if ((UPGRADE)); then
  log "Installing @deepseek-ai/dsh@$DSH_VERSION"
  npm install --global "@deepseek-ai/dsh@$DSH_VERSION"

  plugin_update=(plugin --profile "$PROFILE" update)
  if ((LATEST_PLUGINS)); then
    plugin_update+=(--latest)
  fi
  log "Updating plugins for profile $PROFILE"
  DSH_HOME="$DSH_ROOT" dsh "${plugin_update[@]}"
fi

# re-add preserves encrypted_ and private_ attributes. Prechecks and the
# post-sync verification make silent skips fail closed instead.
log "Re-adding managed DSH configuration"
"${CHEZMOI[@]}" re-add --include files "${TARGETS[@]}"

if ! "${CHEZMOI[@]}" verify "${TARGETS[@]}"; then
  die "post-sync verification failed; destination and chezmoi source still differ"
fi

log "Chezmoi source updated and verified"
log "Review the Git diff, then commit and push separately if desired"
