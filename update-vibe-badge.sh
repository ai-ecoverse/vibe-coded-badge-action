#!/bin/bash
set -euo pipefail

# Environment variables with defaults
README_PATH="${README_PATH:-README.md}"
BADGE_STYLE="${BADGE_STYLE:-for-the-badge}"
BADGE_COLOR="${BADGE_COLOR:-ff69b4}"
BADGE_TEXT="${BADGE_TEXT:-Vibe_Coded}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Update vibe-coded badge}"
DEBUG="${DEBUG:-false}"
SKIP_ON_ERROR="${SKIP_ON_ERROR:-true}"

# Parse debug flag from environment or command line
if [[ "${1:-}" == "--debug" || "${1:-}" == "-d" || "$DEBUG" == "true" ]]; then
  DEBUG=true
fi

# Line-based calculation using git blame
TOTAL_LINES=0
AI_LINES=0

# Initialize line counts by AI type
CLAUDE_LINES=0
CURSOR_LINES=0
WINDSURF_LINES=0
ZED_LINES=0
OPENAI_LINES=0
OPENCODE_LINES=0
TERRAGON_LINES=0
GEMINI_LINES=0
QWEN_LINES=0
AMP_LINES=0
DROID_LINES=0
COPILOT_LINES=0
AIDER_LINES=0
CLINE_LINES=0
CRUSH_LINES=0
KIMI_LINES=0
GOOSE_LINES=0
BOT_LINES=0
RENOVATE_LINES=0
SEMANTIC_LINES=0
JULES_LINES=0

detect_ai_actor() {
  local actor_name="$1"
  local actor_email="$2"

  if echo "$actor_name" | grep -i 'terragon' >/dev/null || echo "$actor_email" | grep -i 'terragon' >/dev/null; then
    TERRAGON_LINES=$((TERRAGON_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -iE 'claude|anthropic' >/dev/null || echo "$actor_email" | grep -iE 'claude|anthropic' >/dev/null; then
    CLAUDE_LINES=$((CLAUDE_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'cursor' >/dev/null; then
    CURSOR_LINES=$((CURSOR_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'windsurf' >/dev/null; then
    WINDSURF_LINES=$((WINDSURF_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'zed' >/dev/null; then
    ZED_LINES=$((ZED_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'openai' >/dev/null; then
    OPENAI_LINES=$((OPENAI_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'opencode' >/dev/null; then
    OPENCODE_LINES=$((OPENCODE_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'qwen code' >/dev/null || echo "$actor_email" | grep -E 'noreply@alibaba\.com' >/dev/null; then
    QWEN_LINES=$((QWEN_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'gemini' >/dev/null || echo "$actor_email" | grep -E 'noreply@google\.com' >/dev/null; then
    GEMINI_LINES=$((GEMINI_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'google-labs-jules\[bot\]' >/dev/null; then
    JULES_LINES=$((JULES_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -iw 'amp' >/dev/null || echo "$actor_email" | grep -E 'noreply@sourcegraph\.com' >/dev/null; then
    AMP_LINES=$((AMP_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -iw 'droid' >/dev/null || echo "$actor_email" | grep -E 'droid@factory\.ai' >/dev/null; then
    DROID_LINES=$((DROID_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i 'copilot' >/dev/null || echo "$actor_email" | grep -E 'copilot@github\.com' >/dev/null; then
    COPILOT_LINES=$((COPILOT_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -iE '\(aider\)|^aider' >/dev/null || echo "$actor_email" | grep -E 'aider@aider\.chat' >/dev/null; then
    AIDER_LINES=$((AIDER_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -iw 'cline' >/dev/null || echo "$actor_email" | grep -iE 'cline@|noreply@cline\.bot' >/dev/null; then
    CLINE_LINES=$((CLINE_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -iw 'crush' >/dev/null || echo "$actor_email" | grep -E 'crush@charm\.land' >/dev/null; then
    CRUSH_LINES=$((CRUSH_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -iw 'kimi' >/dev/null || echo "$actor_email" | grep -E 'kimi@moonshot\.' >/dev/null; then
    KIMI_LINES=$((KIMI_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -iw 'goose' >/dev/null || echo "$actor_email" | grep -E 'goose@(example\.com|opensource\.block\.xyz)' >/dev/null; then
    GOOSE_LINES=$((GOOSE_LINES + 1))
    return 0
  elif echo "$actor_name" | grep -i '\[bot\]' >/dev/null || echo "$actor_name" | grep -iE 'renovate|semantic-release' >/dev/null; then
    if echo "$actor_name" | grep -i 'renovate' >/dev/null; then
      RENOVATE_LINES=$((RENOVATE_LINES + 1))
    elif echo "$actor_name" | grep -iE 'semantic-release|semantic' >/dev/null; then
      SEMANTIC_LINES=$((SEMANTIC_LINES + 1))
    else
      BOT_LINES=$((BOT_LINES + 1))
    fi
    return 0
  fi

  return 1
}

# Find all relevant source files
SOURCE_FILES=$(find . -type f \
  \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \
  -o -name "*.py" -o -name "*.sh" -o -name "*.bash" -o -name "*.zsh" \
  -o -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \
  -o -name "*.swift" -o -name "*.go" -o -name "*.rs" -o -name "*.java" \
  -o -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" \
  -o -name "*.rb" -o -name "*.php" -o -name "*.css" -o -name "*.scss" \
  -o -name "*.html" -o -name "*.xml" -o -name "*.sql" \) \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./.build/*" \
  -not -path "./dist/*" \
  -not -path "./build/*" \
  -not -path "./vendor/*" \
  -not -name "*.min.js" -not -name "*.min.css" 2>/dev/null)

# Process each source file  
for FILE in $SOURCE_FILES; do
  if [ -f "$FILE" ] && [ -r "$FILE" ]; then
    # Process git blame output line by line
    # Using process substitution to avoid subshell issues
    while IFS= read -r LINE; do
      # Parse the blame metadata
      if [[ "$LINE" =~ ^([a-f0-9]{40})[[:space:]] ]]; then
        COMMIT_HASH="${BASH_REMATCH[1]}"
        
        # Skip if it's the null commit (uncommitted changes)
        if [ "$COMMIT_HASH" = "0000000000000000000000000000000000000000" ]; then
          continue
        fi
        
        # Skip merge commits
        PARENT_COUNT=$(git rev-list --parents -n 1 "$COMMIT_HASH" 2>/dev/null | wc -w)
        if [ "$PARENT_COUNT" -gt 2 ]; then
          continue
        fi
        
        # Get author info for this commit
        AUTHOR=$(git show -s --format='%an' "$COMMIT_HASH" 2>/dev/null || echo "")
        AUTHOR_EMAIL=$(git show -s --format='%ae' "$COMMIT_HASH" 2>/dev/null || echo "")
        COMMIT_BODY=$(git show -s --format='%B' "$COMMIT_HASH" 2>/dev/null || echo "")
        
        # Count the line
        TOTAL_LINES=$((TOTAL_LINES + 1))
        
        # Determine if it's AI-authored
        IS_AI=false

        if detect_ai_actor "$AUTHOR" "$AUTHOR_EMAIL"; then
          IS_AI=true
        fi

        if ! $IS_AI && [ -n "$COMMIT_BODY" ]; then
          co_author_lines=$(printf '%s\n' "$COMMIT_BODY" | grep -i '^[[:space:]]*Co-authored-by:' || true)
          if [ -n "$co_author_lines" ]; then
            while IFS= read -r co_line; do
              co_line=$(printf '%s' "$co_line" | sed -E 's/^[[:space:]]+//; s/^[Cc]o-[Aa]uthored-[Bb]y:[[:space:]]*//; s/[[:space:]]+$//')
              co_name=$(printf '%s' "$co_line" | sed -E 's/<.*//; s/[[:space:]]+$//')
              co_email=$(printf '%s' "$co_line" | sed -nE 's/.*<([^>]+)>.*/\1/p')
              if detect_ai_actor "$co_name" "$co_email"; then
                IS_AI=true
                break
              fi
            done <<< "$co_author_lines"
          fi
        fi

        if $IS_AI; then
          AI_LINES=$((AI_LINES + 1))
        fi
      fi
    done < <(git blame --line-porcelain "$FILE" 2>/dev/null | grep '^[a-f0-9]\{40\}')
  fi
done

# Calculate percentage
if [ "$TOTAL_LINES" -eq 0 ]; then
  PERCENT=0
else
  PERCENT=$((100 * AI_LINES / TOTAL_LINES))
fi

# Determine which logo to use based on most lines by AI type
LOGO="githubcopilot"  # default
MAX_COUNT=0
DOMINANT_AI="unknown"

# Check each AI type based on line counts
if [ "$CLAUDE_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CLAUDE_LINES"
  LOGO="claude"
  DOMINANT_AI="Claude"
fi
if [ "$TERRAGON_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$TERRAGON_LINES"
  LOGO="claude"
  DOMINANT_AI="Terragon"
fi
if [ "$CURSOR_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CURSOR_LINES"
  LOGO="githubcopilot"
  DOMINANT_AI="Cursor"
fi
if [ "$WINDSURF_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$WINDSURF_LINES"
  LOGO="windsurf"
  DOMINANT_AI="Windsurf"
fi
if [ "$ZED_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$ZED_LINES"
  LOGO="zedindustries"
  DOMINANT_AI="Zed"
fi
if [ "$OPENAI_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$OPENAI_LINES"
  LOGO="openai"
  DOMINANT_AI="OpenAI"
fi
if [ "$OPENCODE_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$OPENCODE_LINES"
  LOGO="githubcopilot"
  DOMINANT_AI="OpenCode"
fi
if [ "$GEMINI_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$GEMINI_LINES"
  LOGO="google"
  DOMINANT_AI="Gemini"
fi
if [ "$QWEN_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$QWEN_LINES"
  LOGO="alibabacloud"
  DOMINANT_AI="Qwen"
fi
if [ "$JULES_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$JULES_LINES"
  LOGO="google"
  DOMINANT_AI="Jules"
fi
if [ "$AMP_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$AMP_LINES"
  LOGO="sourcegraph"
  DOMINANT_AI="Amp"
fi
if [ "$DROID_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$DROID_LINES"
  LOGO="robot"
  DOMINANT_AI="Droid"
fi
if [ "$COPILOT_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$COPILOT_LINES"
  LOGO="githubcopilot"
  DOMINANT_AI="Copilot"
fi
if [ "$AIDER_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$AIDER_LINES"
  LOGO="openai"
  DOMINANT_AI="Aider"
fi
if [ "$CLINE_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CLINE_LINES"
  LOGO="claude"
  DOMINANT_AI="Cline"
fi
if [ "$CRUSH_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$CRUSH_LINES"
  LOGO="robot"
  DOMINANT_AI="Crush"
fi
if [ "$KIMI_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$KIMI_LINES"
  LOGO="openai"
  DOMINANT_AI="Kimi"
fi
if [ "$GOOSE_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$GOOSE_LINES"
  LOGO="block"
  DOMINANT_AI="Goose"
fi
if [ "$BOT_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$BOT_LINES"
  LOGO="githubactions"
  DOMINANT_AI="Bot"
fi
if [ "$RENOVATE_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$RENOVATE_LINES"
  LOGO="renovatebot"
  DOMINANT_AI="Renovate"
fi
if [ "$SEMANTIC_LINES" -gt "$MAX_COUNT" ]; then
  MAX_COUNT="$SEMANTIC_LINES"
  LOGO="semanticrelease"
  DOMINANT_AI="Semantic"
fi

# Output summary of detected AI agents (always shown in workflow logs)
echo "=== Vibe Coded Badge Analysis ==="
echo "Total lines of code: $TOTAL_LINES"
echo "AI-generated lines: $AI_LINES (${PERCENT}%)"
echo "Human-written lines: $((TOTAL_LINES - AI_LINES)) ($((100 - PERCENT))%)"
echo ""
echo "Detected AI Agents/Bots (sorted by contributed lines):"

# Create a temporary array for sorting
declare -a ai_agents=()

# Populate array with AI agents that have contributions
[ "$CLAUDE_LINES" -gt 0 ] && ai_agents+=("$CLAUDE_LINES|Claude")
[ "$TERRAGON_LINES" -gt 0 ] && ai_agents+=("$TERRAGON_LINES|Terragon")
[ "$CURSOR_LINES" -gt 0 ] && ai_agents+=("$CURSOR_LINES|Cursor")
[ "$WINDSURF_LINES" -gt 0 ] && ai_agents+=("$WINDSURF_LINES|Windsurf")
[ "$ZED_LINES" -gt 0 ] && ai_agents+=("$ZED_LINES|Zed")
[ "$OPENAI_LINES" -gt 0 ] && ai_agents+=("$OPENAI_LINES|OpenAI")
[ "$OPENCODE_LINES" -gt 0 ] && ai_agents+=("$OPENCODE_LINES|OpenCode")
[ "$GEMINI_LINES" -gt 0 ] && ai_agents+=("$GEMINI_LINES|Gemini")
[ "$QWEN_LINES" -gt 0 ] && ai_agents+=("$QWEN_LINES|Qwen")
[ "$JULES_LINES" -gt 0 ] && ai_agents+=("$JULES_LINES|Jules")
[ "$AMP_LINES" -gt 0 ] && ai_agents+=("$AMP_LINES|Amp")
[ "$DROID_LINES" -gt 0 ] && ai_agents+=("$DROID_LINES|Droid")
[ "$COPILOT_LINES" -gt 0 ] && ai_agents+=("$COPILOT_LINES|Copilot")
[ "$AIDER_LINES" -gt 0 ] && ai_agents+=("$AIDER_LINES|Aider")
[ "$CLINE_LINES" -gt 0 ] && ai_agents+=("$CLINE_LINES|Cline")
[ "$CRUSH_LINES" -gt 0 ] && ai_agents+=("$CRUSH_LINES|Crush")
[ "$KIMI_LINES" -gt 0 ] && ai_agents+=("$KIMI_LINES|Kimi")
[ "$GOOSE_LINES" -gt 0 ] && ai_agents+=("$GOOSE_LINES|Goose")
[ "$BOT_LINES" -gt 0 ] && ai_agents+=("$BOT_LINES|Bot")
[ "$RENOVATE_LINES" -gt 0 ] && ai_agents+=("$RENOVATE_LINES|Renovate")
[ "$SEMANTIC_LINES" -gt 0 ] && ai_agents+=("$SEMANTIC_LINES|Semantic")

# Sort by line count (descending) and display
if [ ${#ai_agents[@]} -gt 0 ]; then
  # Sort numerically in reverse order and format output
  printf '%s\n' "${ai_agents[@]}" | sort -t'|' -k1 -rn | while IFS='|' read -r lines name; do
    percentage=$((100 * lines / TOTAL_LINES))
    printf "  %-15s: %6d lines (%2d%%)\n" "$name" "$lines" "$percentage"
  done
else
  echo "  No AI agents detected"
fi

echo ""
echo "Dominant AI: $DOMINANT_AI ($MAX_COUNT lines)"
echo "Selected badge logo: $LOGO"
echo ""

# Display additional debug output if enabled
if $DEBUG; then
  echo "=== Extended Debug Information ==="
  echo "Selected logo: $LOGO"
  echo ""
fi

# Set GitHub Actions outputs
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "percentage=$PERCENT" >> "$GITHUB_OUTPUT"
  echo "dominant-ai=$DOMINANT_AI" >> "$GITHUB_OUTPUT"
fi

# Create GitHub Actions Job Summary
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  echo "## 🤖 Vibe Coded Badge Analysis" >> "$GITHUB_STEP_SUMMARY"
  echo "" >> "$GITHUB_STEP_SUMMARY"
  echo "**Total lines analyzed:** $TOTAL_LINES" >> "$GITHUB_STEP_SUMMARY"
  echo "" >> "$GITHUB_STEP_SUMMARY"
  echo "- 🤖 **AI-generated:** $AI_LINES lines (**${PERCENT}%**)" >> "$GITHUB_STEP_SUMMARY"
  echo "- 👤 **Human-written:** $((TOTAL_LINES - AI_LINES)) lines (**$((100 - PERCENT))%**)" >> "$GITHUB_STEP_SUMMARY"
  echo "" >> "$GITHUB_STEP_SUMMARY"

  if [ ${#ai_agents[@]} -gt 0 ]; then
    echo "### 🏆 Detected AI Agents/Bots" >> "$GITHUB_STEP_SUMMARY"
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "| Rank | AI Agent | Lines | Percentage | Logo |" >> "$GITHUB_STEP_SUMMARY"
    echo "|------|----------|------:|------------|------|" >> "$GITHUB_STEP_SUMMARY"

    rank=1
    # Sort and create table rows
    printf '%s\n' "${ai_agents[@]}" | sort -t'|' -k1 -rn | while IFS='|' read -r lines name; do
      percentage=$((100 * lines / TOTAL_LINES))

      # Determine logo for each agent
      agent_logo=""
      case "$name" in
        "Claude"|"Terragon"|"Cline") agent_logo="claude" ;;
        "OpenAI"|"Aider"|"Kimi") agent_logo="openai" ;;
        "Cursor"|"OpenCode"|"Copilot") agent_logo="githubcopilot" ;;
        "Windsurf") agent_logo="windsurf" ;;
        "Zed") agent_logo="zedindustries" ;;
        "Gemini"|"Jules") agent_logo="google" ;;
        "Qwen") agent_logo="alibabacloud" ;;
        "Amp") agent_logo="sourcegraph" ;;
        "Droid"|"Crush") agent_logo="robot" ;;
        "Goose") agent_logo="block" ;;
        "Renovate") agent_logo="renovatebot" ;;
        "Semantic") agent_logo="semanticrelease" ;;
        "Bot") agent_logo="githubactions" ;;
      esac

      # Add medal for top 3
      medal=""
      if [ "$rank" -eq 1 ]; then medal="🥇"; fi
      if [ "$rank" -eq 2 ]; then medal="🥈"; fi
      if [ "$rank" -eq 3 ]; then medal="🥉"; fi

      echo "| $medal $rank | **$name** | $lines | $percentage% | ![${agent_logo}](https://img.shields.io/badge/-${agent_logo}-black?style=flat-square&logo=${agent_logo}&logoColor=white) |" >> "$GITHUB_STEP_SUMMARY"
      rank=$((rank + 1))
    done

    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "**🏅 Dominant AI:** $DOMINANT_AI with $MAX_COUNT lines" >> "$GITHUB_STEP_SUMMARY"
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "**🎨 Selected badge logo:** \`$LOGO\`" >> "$GITHUB_STEP_SUMMARY"
  else
    echo "No AI agents detected in this repository." >> "$GITHUB_STEP_SUMMARY"
  fi

  echo "" >> "$GITHUB_STEP_SUMMARY"
  echo "---" >> "$GITHUB_STEP_SUMMARY"
  echo "" >> "$GITHUB_STEP_SUMMARY"
  echo "_Badge updated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')_" >> "$GITHUB_STEP_SUMMARY"
fi

BADGE_CHANGED=false

# Only update badge if not in debug mode
if ! $DEBUG; then
  # Note: Repository information extraction kept for potential future use
  # Currently, badge URL is hardcoded to the action repository

  NEW_BADGE="[![${PERCENT}% ${BADGE_TEXT}](https://img.shields.io/badge/${PERCENT}%25-${BADGE_TEXT}-${BADGE_COLOR}?style=${BADGE_STYLE}&logo=${LOGO}&logoColor=white)](https://github.com/ai-ecoverse/vibe-coded-badge-action)"

  # Export badge for perl to use
  export NEW_BADGE
  export BADGE_TEXT

  # Clean up any existing vibe-coded badges and insert new one
  if perl -0777 -pi -e '
    my $content = $_;
    # Remove all existing vibe-coded badges (more flexible pattern)
    my $badge_re = qr#\[!\[\d+%[ _][^\]]*Vibe[ _]Coded[^\]]*\]\(https://img\.shields\.io/badge/\d+%25[^)]*\)\]\([^)]*\)#s;
    $content =~ s/$badge_re\s*//g;
    # Clean up excessive newlines
    $content =~ s/\n{3,}/\n\n/g;

    # Try to insert after first heading, fallback to beginning if no heading
    if ($content =~ /^(#+ [^\n]+)\n/m) {
      $content =~ s/^(#+ [^\n]+)\n/$1\n\n$ENV{NEW_BADGE}\n/m;
    } else {
      # Fallback: insert at the beginning
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
    # Check if there are actually changes to commit
    if ! git diff --quiet "$README_PATH" || ! git diff --cached --quiet "$README_PATH"; then
      git config user.name 'github-actions[bot]'
      git config user.email 'github-actions[bot]@users.noreply.github.com'
      git add "$README_PATH"
      git commit -m "$COMMIT_MESSAGE to ${PERCENT}% [skip vibe-badge]"

      # Push the changes if we're in GitHub Actions
      if [ -n "${GITHUB_ACTIONS:-}" ]; then
        if [ "$SKIP_ON_ERROR" = "true" ]; then
          if ! git push origin HEAD 2>/dev/null; then
            echo "Warning: Failed to push changes to remote. This is usually caused by concurrent updates."
            echo "The badge has been updated locally but not pushed to the remote repository."
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

# Set GitHub Actions output for badge changed status
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "changed=$BADGE_CHANGED" >> "$GITHUB_OUTPUT"
fi
