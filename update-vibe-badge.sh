#!/bin/bash
set -eo pipefail

# Environment variables with defaults
README_PATH="${README_PATH:-README.md}"
BADGE_STYLE="${BADGE_STYLE:-for-the-badge}"
BADGE_COLOR="${BADGE_COLOR:-ff69b4}"
BADGE_TEXT="${BADGE_TEXT:-Vibe_Coded}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Update vibe-coded badge}"
DEBUG="${DEBUG:-false}"
SKIP_ON_ERROR="${SKIP_ON_ERROR:-true}"
CACHE_FILE="${CACHE_FILE:-.vibe-cache.json}"

# Parse debug flag from environment or command line
if [[ "${1:-}" == "--debug" || "${1:-}" == "-d" || "$DEBUG" == "true" ]]; then
  DEBUG=true
fi

# Initialize counters
TOTAL_LINES=0
AI_LINES=0
CACHE_HITS=0
CACHE_MISSES=0

# Initialize line counts by AI type
declare -A AI_TYPE_LINES=(
  ["Claude"]=0 ["Cursor"]=0 ["Windsurf"]=0 ["Zed"]=0 ["OpenAI"]=0
  ["OpenCode"]=0 ["Terragon"]=0 ["Gemini"]=0 ["Qwen"]=0 ["Amp"]=0
  ["Droid"]=0 ["Copilot"]=0 ["Aider"]=0 ["Cline"]=0 ["Crush"]=0
  ["Kimi"]=0 ["Goose"]=0 ["Bot"]=0 ["Renovate"]=0 ["Semantic"]=0 ["Jules"]=0
)

# AI type to logo mapping
declare -A AI_LOGOS=(
  ["Claude"]="claude" ["Terragon"]="claude" ["Cline"]="claude"
  ["OpenAI"]="openai" ["Aider"]="openai" ["Kimi"]="openai"
  ["Cursor"]="githubcopilot" ["OpenCode"]="githubcopilot" ["Copilot"]="githubcopilot"
  ["Windsurf"]="windsurf" ["Zed"]="zedindustries"
  ["Gemini"]="google" ["Jules"]="google"
  ["Qwen"]="alibabacloud" ["Amp"]="sourcegraph"
  ["Droid"]="robot" ["Crush"]="robot"
  ["Goose"]="block" ["Renovate"]="renovatebot" ["Semantic"]="semanticrelease"
  ["Bot"]="githubactions"
)

# Load existing cache if available
declare -A FILE_CACHE=()
load_cache() {
  local count=0
  if [ -f "$CACHE_FILE" ]; then
    echo "Loading cache from $CACHE_FILE..."
    while IFS= read -r line; do
      if [[ "$line" =~ \"([^\"]+)\":[[:space:]]*\{\"hash\":\"([^\"]+)\",\"total\":([0-9]+),\"ai\":([0-9]+),\"breakdown\":\{([^\}]*)\}\} ]]; then
        local file="${BASH_REMATCH[1]}"
        local hash="${BASH_REMATCH[2]}"
        local total="${BASH_REMATCH[3]}"
        local ai="${BASH_REMATCH[4]}"
        local breakdown="${BASH_REMATCH[5]}"
        FILE_CACHE["$file"]="$hash|$total|$ai|$breakdown"
        count=$((count + 1))
      fi
    done < "$CACHE_FILE"
    echo "Loaded $count cached file entries"
  else
    echo "No cache file found, starting fresh analysis"
  fi
}

# Save cache to file
save_cache() {
  echo "Saving cache to $CACHE_FILE..."
  echo "{" > "$CACHE_FILE"
  local first=true
  for file in "${!FILE_CACHE[@]}"; do
    IFS='|' read -r hash total ai breakdown <<< "${FILE_CACHE[$file]}"
    if [ "$first" = true ]; then
      first=false
    else
      printf ",\n" >> "$CACHE_FILE"
    fi
    printf '  "%s": {"hash": "%s", "total": %d, "ai": %d, "breakdown": {%s}}' \
      "$file" "$hash" "$total" "$ai" "$breakdown" >> "$CACHE_FILE"
  done
  printf "\n}\n" >> "$CACHE_FILE"
}

# Get git blob hash for a file (content-based hash)
get_file_hash() {
  git hash-object "$1" 2>/dev/null || echo ""
}

# Detect AI actor and return the AI type name
detect_ai_actor() {
  local actor_name="$1"
  local actor_email="$2"

  if echo "$actor_name" | grep -i 'terragon' >/dev/null || echo "$actor_email" | grep -i 'terragon' >/dev/null; then
    echo "Terragon"; return 0
  elif echo "$actor_name" | grep -iE 'claude|anthropic' >/dev/null || echo "$actor_email" | grep -iE 'claude|anthropic' >/dev/null; then
    echo "Claude"; return 0
  elif echo "$actor_name" | grep -i 'cursor' >/dev/null; then
    echo "Cursor"; return 0
  elif echo "$actor_name" | grep -i 'windsurf' >/dev/null; then
    echo "Windsurf"; return 0
  elif echo "$actor_name" | grep -i 'zed' >/dev/null; then
    echo "Zed"; return 0
  elif echo "$actor_name" | grep -i 'openai' >/dev/null; then
    echo "OpenAI"; return 0
  elif echo "$actor_name" | grep -i 'opencode' >/dev/null; then
    echo "OpenCode"; return 0
  elif echo "$actor_name" | grep -i 'qwen code' >/dev/null || echo "$actor_email" | grep -E 'noreply@alibaba\.com' >/dev/null; then
    echo "Qwen"; return 0
  elif echo "$actor_name" | grep -i 'gemini' >/dev/null || echo "$actor_email" | grep -E 'noreply@google\.com' >/dev/null; then
    echo "Gemini"; return 0
  elif echo "$actor_name" | grep -i 'google-labs-jules\[bot\]' >/dev/null; then
    echo "Jules"; return 0
  elif echo "$actor_name" | grep -iw 'amp' >/dev/null || echo "$actor_email" | grep -E 'noreply@sourcegraph\.com' >/dev/null; then
    echo "Amp"; return 0
  elif echo "$actor_name" | grep -iw 'droid' >/dev/null || echo "$actor_email" | grep -E 'droid@factory\.ai' >/dev/null; then
    echo "Droid"; return 0
  elif echo "$actor_name" | grep -i 'copilot' >/dev/null || echo "$actor_email" | grep -E 'copilot@github\.com' >/dev/null; then
    echo "Copilot"; return 0
  elif echo "$actor_name" | grep -iE '\(aider\)|^aider' >/dev/null || echo "$actor_email" | grep -E 'aider@aider\.chat' >/dev/null; then
    echo "Aider"; return 0
  elif echo "$actor_name" | grep -iw 'cline' >/dev/null || echo "$actor_email" | grep -iE 'cline@|noreply@cline\.bot' >/dev/null; then
    echo "Cline"; return 0
  elif echo "$actor_name" | grep -iw 'crush' >/dev/null || echo "$actor_email" | grep -E 'crush@charm\.land' >/dev/null; then
    echo "Crush"; return 0
  elif echo "$actor_name" | grep -iw 'kimi' >/dev/null || echo "$actor_email" | grep -E 'kimi@moonshot\.' >/dev/null; then
    echo "Kimi"; return 0
  elif echo "$actor_name" | grep -iw 'goose' >/dev/null || echo "$actor_email" | grep -E 'goose@(example\.com|opensource\.block\.xyz)' >/dev/null; then
    echo "Goose"; return 0
  elif echo "$actor_name" | grep -i '\[bot\]' >/dev/null || echo "$actor_name" | grep -iE 'renovate|semantic-release' >/dev/null; then
    if echo "$actor_name" | grep -i 'renovate' >/dev/null; then
      echo "Renovate"; return 0
    elif echo "$actor_name" | grep -iE 'semantic-release|semantic' >/dev/null; then
      echo "Semantic"; return 0
    else
      echo "Bot"; return 0
    fi
  fi
  return 1
}

# Analyze a single file and return results
analyze_file() {
  local file="$1"
  local file_total=0
  local file_ai=0
  declare -A file_breakdown

  while IFS= read -r LINE; do
    if [[ "$LINE" =~ ^([a-f0-9]{40})[[:space:]] ]]; then
      COMMIT_HASH="${BASH_REMATCH[1]}"
      
      # Skip null commit
      [ "$COMMIT_HASH" = "0000000000000000000000000000000000000000" ] && continue
      
      # Skip merge commits
      PARENT_COUNT=$(git rev-list --parents -n 1 "$COMMIT_HASH" 2>/dev/null | wc -w)
      [ "$PARENT_COUNT" -gt 2 ] && continue
      
      AUTHOR=$(git show -s --format='%an' "$COMMIT_HASH" 2>/dev/null || echo "")
      AUTHOR_EMAIL=$(git show -s --format='%ae' "$COMMIT_HASH" 2>/dev/null || echo "")
      COMMIT_BODY=$(git show -s --format='%B' "$COMMIT_HASH" 2>/dev/null || echo "")
      
      file_total=$((file_total + 1))
      
      AI_TYPE=""
      AI_TYPE=$(detect_ai_actor "$AUTHOR" "$AUTHOR_EMAIL") || true

      if [ -z "$AI_TYPE" ] && [ -n "$COMMIT_BODY" ]; then
        co_author_lines=$(printf '%s\n' "$COMMIT_BODY" | grep -i '^[[:space:]]*Co-authored-by:' || true)
        if [ -n "$co_author_lines" ]; then
          while IFS= read -r co_line; do
            co_line=$(printf '%s' "$co_line" | sed -E 's/^[[:space:]]+//; s/^[Cc]o-[Aa]uthored-[Bb]y:[[:space:]]*//; s/[[:space:]]+$//')
            co_name=$(printf '%s' "$co_line" | sed -E 's/<.*//; s/[[:space:]]+$//')
            co_email=$(printf '%s' "$co_line" | sed -nE 's/.*<([^>]+)>.*/\1/p')
            AI_TYPE=$(detect_ai_actor "$co_name" "$co_email") || true
            [ -n "$AI_TYPE" ] && break
          done <<< "$co_author_lines"
        fi
      fi

      if [ -n "$AI_TYPE" ]; then
        file_ai=$((file_ai + 1))
        file_breakdown["$AI_TYPE"]=$((${file_breakdown["$AI_TYPE"]:-0} + 1))
      fi
    fi
  done < <(git blame --line-porcelain "$file" 2>/dev/null | grep '^[a-f0-9]\{40\}')

  # Format breakdown as JSON-like string
  local breakdown_str=""
  for ai_type in "${!file_breakdown[@]}"; do
    [ -n "$breakdown_str" ] && breakdown_str+=","
    breakdown_str+="\"$ai_type\":${file_breakdown[$ai_type]}"
  done

  echo "$file_total|$file_ai|$breakdown_str"
}

# Find files to analyze - all tracked text files
find_source_files() {
  git ls-files --cached | while read -r file; do
    # Skip binary files and common non-source directories
    if [ -f "$file" ] && \
       [[ ! "$file" =~ ^\.git/ ]] && \
       [[ ! "$file" =~ ^node_modules/ ]] && \
       [[ ! "$file" =~ ^\.build/ ]] && \
       [[ ! "$file" =~ ^dist/ ]] && \
       [[ ! "$file" =~ ^build/ ]] && \
       [[ ! "$file" =~ ^vendor/ ]] && \
       [[ ! "$file" =~ \.min\.(js|css)$ ]] && \
       file "$file" 2>/dev/null | grep -qE 'text|ASCII|UTF-8|script'; then
      echo "$file"
    fi
  done
}

# Find files changed since last badge update (incremental mode)
find_changed_files() {
  local last_badge_commit
  last_badge_commit=$(git log -1 --format=%H --grep='\[skip vibe-badge\]' 2>/dev/null || echo "")
  
  if [ -n "$last_badge_commit" ]; then
    echo "Incremental mode: finding files changed since last badge update ($last_badge_commit)" >&2
    git diff --name-only "$last_badge_commit" HEAD 2>/dev/null || find_source_files
  else
    echo "No previous badge commit found, analyzing all files" >&2
    find_source_files
  fi
}

# Main analysis
echo "=== Vibe Coded Badge Analysis ==="
echo ""

# Load cache
load_cache

# Get list of files to analyze
ALL_SOURCE_FILES=$(find_source_files)
CHANGED_FILES=$(find_changed_files)
FILE_COUNT=$(echo "$ALL_SOURCE_FILES" | grep -c . || echo 0)
CHANGED_COUNT=$(echo "$CHANGED_FILES" | grep -c . || echo 0)

echo "Total tracked source files: $FILE_COUNT"
echo "Files changed since last badge: $CHANGED_COUNT"
echo ""

# Process files
for FILE in $ALL_SOURCE_FILES; do
  [ ! -f "$FILE" ] && continue
  
  CURRENT_HASH=$(get_file_hash "$FILE")
  [ -z "$CURRENT_HASH" ] && continue
  
  # Check if file is in cache with matching hash
  if [[ -v "FILE_CACHE[$FILE]" ]]; then
    IFS='|' read -r cached_hash cached_total cached_ai cached_breakdown <<< "${FILE_CACHE[$FILE]}"
    
    if [ "$cached_hash" = "$CURRENT_HASH" ]; then
      # Cache hit - use cached values
      CACHE_HITS=$((CACHE_HITS + 1))
      TOTAL_LINES=$((TOTAL_LINES + cached_total))
      AI_LINES=$((AI_LINES + cached_ai))
      
      # Parse and add breakdown
      if [ -n "$cached_breakdown" ]; then
        while IFS=',' read -ra PAIRS; do
          for pair in "${PAIRS[@]}"; do
            if [[ "$pair" =~ \"([^\"]+)\":([0-9]+) ]]; then
              ai_type="${BASH_REMATCH[1]}"
              count="${BASH_REMATCH[2]}"
              AI_TYPE_LINES["$ai_type"]=$((${AI_TYPE_LINES["$ai_type"]:-0} + count))
            fi
          done
        done <<< "$cached_breakdown"
      fi
      continue
    fi
  fi
  
  # Cache miss - analyze file
  CACHE_MISSES=$((CACHE_MISSES + 1))
  
  if $DEBUG; then
    echo "Analyzing: $FILE"
  fi
  
  RESULT=$(analyze_file "$FILE")
  IFS='|' read -r file_total file_ai file_breakdown <<< "$RESULT"
  
  # Update totals
  TOTAL_LINES=$((TOTAL_LINES + file_total))
  AI_LINES=$((AI_LINES + file_ai))
  
  # Parse and add breakdown
  if [ -n "$file_breakdown" ]; then
    while IFS=',' read -ra PAIRS; do
      for pair in "${PAIRS[@]}"; do
        if [[ "$pair" =~ \"([^\"]+)\":([0-9]+) ]]; then
          ai_type="${BASH_REMATCH[1]}"
          count="${BASH_REMATCH[2]}"
          AI_TYPE_LINES["$ai_type"]=$((${AI_TYPE_LINES["$ai_type"]:-0} + count))
        fi
      done
    done <<< "$file_breakdown"
  fi
  
  # Update cache
  FILE_CACHE["$FILE"]="$CURRENT_HASH|$file_total|$file_ai|$file_breakdown"
done

# Save updated cache
save_cache

# Calculate percentage
if [ "$TOTAL_LINES" -eq 0 ]; then
  PERCENT=0
else
  PERCENT=$((100 * AI_LINES / TOTAL_LINES))
fi

# Determine dominant AI
LOGO="githubcopilot"
MAX_COUNT=0
DOMINANT_AI="unknown"

for ai_type in "${!AI_TYPE_LINES[@]}"; do
  count="${AI_TYPE_LINES[$ai_type]}"
  if [ "$count" -gt "$MAX_COUNT" ]; then
    MAX_COUNT="$count"
    DOMINANT_AI="$ai_type"
    LOGO="${AI_LOGOS[$ai_type]:-githubcopilot}"
  fi
done

# Output summary
echo ""
echo "Cache statistics:"
echo "  Cache hits: $CACHE_HITS files (skipped analysis)"
echo "  Cache misses: $CACHE_MISSES files (analyzed)"
echo ""
echo "Total lines of code: $TOTAL_LINES"
echo "AI-generated lines: $AI_LINES (${PERCENT}%)"
echo "Human-written lines: $((TOTAL_LINES - AI_LINES)) ($((100 - PERCENT))%)"
echo ""
echo "Detected AI Agents/Bots (sorted by contributed lines):"

# Create sorted list of AI agents
declare -a ai_agents=()
for ai_type in "${!AI_TYPE_LINES[@]}"; do
  count="${AI_TYPE_LINES[$ai_type]}"
  [ "$count" -gt 0 ] && ai_agents+=("$count|$ai_type")
done

if [ ${#ai_agents[@]} -gt 0 ]; then
  printf '%s\n' "${ai_agents[@]}" | sort -t'|' -k1 -rn | while IFS='|' read -r lines name; do
    [ "$TOTAL_LINES" -gt 0 ] && percentage=$((100 * lines / TOTAL_LINES)) || percentage=0
    printf "  %-15s: %6d lines (%2d%%)\n" "$name" "$lines" "$percentage"
  done
else
  echo "  No AI agents detected"
fi

echo ""
echo "Dominant AI: $DOMINANT_AI ($MAX_COUNT lines)"
echo "Selected badge logo: $LOGO"
echo ""

# Set GitHub Actions outputs
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "percentage=$PERCENT" >> "$GITHUB_OUTPUT"
  echo "dominant-ai=$DOMINANT_AI" >> "$GITHUB_OUTPUT"
  echo "cache-hits=$CACHE_HITS" >> "$GITHUB_OUTPUT"
  echo "cache-misses=$CACHE_MISSES" >> "$GITHUB_OUTPUT"
fi

# Create GitHub Actions Job Summary
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "## 🤖 Vibe Coded Badge Analysis"
    echo ""
    echo "**Total lines analyzed:** $TOTAL_LINES"
    echo ""
    echo "- 🤖 **AI-generated:** $AI_LINES lines (**${PERCENT}%**)"
    echo "- 👤 **Human-written:** $((TOTAL_LINES - AI_LINES)) lines (**$((100 - PERCENT))%**)"
    echo ""
    echo "### ⚡ Cache Performance"
    echo "- **Cache hits:** $CACHE_HITS files (skipped)"
    echo "- **Cache misses:** $CACHE_MISSES files (analyzed)"
    if [ $((CACHE_HITS + CACHE_MISSES)) -gt 0 ]; then
      echo "- **Hit rate:** $((100 * CACHE_HITS / (CACHE_HITS + CACHE_MISSES)))%"
    fi
    echo ""

    if [ ${#ai_agents[@]} -gt 0 ]; then
      echo "### 🏆 Detected AI Agents/Bots"
      echo ""
      echo "| Rank | AI Agent | Lines | Percentage | Logo |"
      echo "|------|----------|------:|------------|------|"

      rank=1
      printf '%s\n' "${ai_agents[@]}" | sort -t'|' -k1 -rn | while IFS='|' read -r lines name; do
        [ "$TOTAL_LINES" -gt 0 ] && percentage=$((100 * lines / TOTAL_LINES)) || percentage=0
        agent_logo="${AI_LOGOS[$name]:-githubactions}"
        medal=""
        [ "$rank" -eq 1 ] && medal="🥇"
        [ "$rank" -eq 2 ] && medal="🥈"
        [ "$rank" -eq 3 ] && medal="🥉"
        echo "| $medal $rank | **$name** | $lines | $percentage% | ![${agent_logo}](https://img.shields.io/badge/-${agent_logo}-black?style=flat-square&logo=${agent_logo}&logoColor=white) |"
        rank=$((rank + 1))
      done

      echo ""
      echo "**🏅 Dominant AI:** $DOMINANT_AI with $MAX_COUNT lines"
      echo ""
      echo "**🎨 Selected badge logo:** \`$LOGO\`"
    else
      echo "No AI agents detected in this repository."
    fi

    echo ""
    echo "---"
    echo ""
    echo "_Badge updated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')_"
  } >> "$GITHUB_STEP_SUMMARY"
fi

BADGE_CHANGED=false

# Only update badge if not in debug mode
if ! $DEBUG; then
  NEW_BADGE="[![${PERCENT}% ${BADGE_TEXT}](https://img.shields.io/badge/${PERCENT}%25-${BADGE_TEXT}-${BADGE_COLOR}?style=${BADGE_STYLE}&logo=${LOGO}&logoColor=white)](https://github.com/ai-ecoverse/vibe-coded-badge-action)"

  export NEW_BADGE
  export BADGE_TEXT

  if perl -0777 -pi -e '
    my $content = $_;
    my $badge_re = qr#\[!\[\d+%[ _][^\]]*Vibe[ _]Coded[^\]]*\]\(https://img\.shields\.io/badge/\d+%25[^)]*\)\]\([^)]*\)#s;
    $content =~ s/$badge_re\s*//g;
    $content =~ s/\n{3,}/\n\n/g;
    if ($content =~ /^(#+ [^\n]+)\n/m) {
      $content =~ s/^(#+ [^\n]+)\n/$1\n\n$ENV{NEW_BADGE}\n/m;
    } else {
      $content = "$ENV{NEW_BADGE}\n\n$content";
    }
    $_ = $content;
  ' "$README_PATH"; then
    BADGE_CHANGED=true
  else
    echo "Error: Failed to update badge in $README_PATH"
    exit 1
  fi

  if $BADGE_CHANGED; then
    if ! git diff --quiet "$README_PATH" || ! git diff --cached --quiet "$README_PATH"; then
      git config user.name 'github-actions[bot]'
      git config user.email 'github-actions[bot]@users.noreply.github.com'
      git add "$README_PATH"
      git commit -m "$COMMIT_MESSAGE to ${PERCENT}% [skip vibe-badge]"

      if [ -n "${GITHUB_ACTIONS:-}" ]; then
        if [ "$SKIP_ON_ERROR" = "true" ]; then
          if ! git push origin HEAD 2>/dev/null; then
            echo "Warning: Failed to push changes to remote."
            echo "Set SKIP_ON_ERROR=false to fail on push errors instead of skipping."
          fi
        else
          git push origin HEAD
        fi
      fi
    else
      BADGE_CHANGED=false
    fi
  fi
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "changed=$BADGE_CHANGED" >> "$GITHUB_OUTPUT"
fi
