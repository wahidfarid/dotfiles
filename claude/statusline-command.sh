#!/usr/bin/env bash
input=$(cat)

# ── JSON fields ───────────────────────────────────────────────────────────────

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hr_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
ctx_used=$(echo "$input" | jq -r '
  (.context_window.current_usage |
    (.input_tokens // 0) +
    (.output_tokens // 0) +
    (.cache_creation_input_tokens // 0) +
    (.cache_read_input_tokens // 0)
  ) // empty')
ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# ── segment 1: CWD — bold blue, strip /mnt/c/workspace/ prefix ───────────────

display_cwd="${cwd#/mnt/c/workspace/}"
display_cwd="${display_cwd//\/.claude\/worktrees\// ▶ }"
cwd_seg="\033[01;34m${display_cwd}\033[00m"

# ── segment 2: git branch + status ────────────────────────────────────────────
# Bold green if clean, bold yellow if dirty.

git_seg=""
if git_branch=$(timeout 0.5 git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null); then
  if timeout 0.5 git -C "$cwd" diff --quiet HEAD 2>/dev/null &&
    [ -z "$(timeout 0.5 git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)" ]; then
    git_seg="\033[01;32m⑂ ${git_branch} ✓\033[00m"
  else
    git_seg="\033[01;33m⑂ ${git_branch} ✗\033[00m"
  fi
fi

# ── segment 3: lines changed ──────────────────────────────────────────────────

lines_seg=""
if [ -n "$cwd" ]; then
  diff_stat=$(timeout 0.5 git -C "$cwd" diff --numstat HEAD 2>/dev/null | awk '{a+=$1; d+=$2} END {printf "%d %d", a, d}')
  added="${diff_stat%% *}"
  removed="${diff_stat##* }"
  if [ "${added:-0}" -gt 0 ] || [ "${removed:-0}" -gt 0 ]; then
    lines_seg="\033[01;32m+${added}\033[00m\033[01;31m -${removed}\033[00m"
  fi
fi

# ── segment 4: model name ─────────────────────────────────────────────────────

model_seg=""
[ -n "$model" ] && model_seg="\033[00;37m${model}\033[00m"

# ── segment 4: context window usage ──────────────────────────────────────────
# Icon reflects fullness; color green <50%, yellow 50-79%, red 80%+.

ctx_seg=""
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 75 ]; then
    ctx_icon="◉"
  elif [ "$used_int" -ge 50 ]; then
    ctx_icon="◕"
  elif [ "$used_int" -ge 25 ]; then
    ctx_icon="◑"
  else
    ctx_icon="◔"
  fi
  if [ "$used_int" -ge 80 ]; then
    ctx_color="\033[01;31m" # bold red
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="\033[01;33m" # bold yellow
  else
    ctx_color="\033[01;32m" # bold green
  fi
  # Format token counts with K suffix
  tok_detail=""
  if [ -n "$ctx_used" ] && [ -n "$ctx_total" ]; then
    used_k=$(awk "BEGIN {printf \"%.0fK\", $ctx_used/1000}")
    total_k=$(awk "BEGIN {printf \"%.0fK\", $ctx_total/1000}")
    tok_detail=" (${used_k} / ${total_k})"
  fi
  ctx_seg="${ctx_color}${ctx_icon} ${used_int}%${tok_detail}\033[00m"
fi

# ── segment 5: 5-hour rate limit ─────────────────────────────────────────────
# Color green <50%, yellow 50-79%, red 80%+.

rate_seg=""
if [ -n "$five_hr_pct" ]; then
  rate_int=$(printf '%.0f' "$five_hr_pct")
  if [ "$rate_int" -ge 80 ]; then
    rate_color="\033[01;31m"
  elif [ "$rate_int" -ge 50 ]; then
    rate_color="\033[01;33m"
  else
    rate_color="\033[01;32m"
  fi
  rate_seg="${rate_color}5h: ${rate_int}%\033[00m"
fi

# ── assemble ──────────────────────────────────────────────────────────────────

parts=("$cwd_seg")
[ -n "$git_seg" ] && parts+=("$git_seg")
[ -n "$lines_seg" ] && parts+=("$lines_seg")
[ -n "$model_seg" ] && parts+=("$model_seg")
[ -n "$ctx_seg" ] && parts+=("$ctx_seg")
[ -n "$rate_seg" ] && parts+=("$rate_seg")

out=""
for part in "${parts[@]}"; do
  [ -n "$out" ] && out+="  "
  out+="$part"
done

printf '%b' "$out"
