# Vibe Coded Badge Action

[![95% Vibe_Coded](https://img.shields.io/badge/95%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/ai-ecoverse/vibe-coded-badge-action)

A GitHub Action that automatically analyzes your repository's git history to determine what percentage of commits were made by AI tools, and updates a badge in your README accordingly.

![a_futuristic_glow_image](https://github.com/user-attachments/assets/0350cfe6-7631-4613-aa3e-74e2bd53eda4)

## Related Projects

Part of the **[AI Ecoverse](https://github.com/ai-ecoverse/.github)** - a comprehensive ecosystem of tools for AI-assisted development:

- **[yolo](https://github.com/ai-ecoverse/yolo)** - AI CLI launcher with worktree isolation
- **[ai-aligned-git](https://github.com/ai-ecoverse/ai-aligned-git)** - Git wrapper for safe AI commit practices
- **[ai-aligned-gh](https://github.com/ai-ecoverse/ai-aligned-gh)** - GitHub CLI wrapper for proper AI attribution
- **[gh-workflow-peek](https://github.com/ai-ecoverse/gh-workflow-peek)** - Smarter GitHub Actions log filtering
- **[upskill](https://github.com/ai-ecoverse/gh-upskill)** - Install Claude/Agent skills from other repositories
- **[as-a-bot](https://github.com/ai-ecoverse/as-a-bot)** - GitHub App token broker for proper AI attribution

## Features

- **Smart AI Detection**: Identifies commits from Claude, Cursor, Zed, Windsurf, OpenAI, Codex, Gemini, Jules, Qwen, Amp, Droid, GitHub Copilot, Aider, Cline, Crush, Kimi, Goose, Grok, and various bots
- **Dynamic Logo Selection**: Automatically chooses the logo based on which AI tool contributed the most
- **Flexible Configuration**: Customizable badge style, colors, text, and target file
- **Debug Mode**: Detailed analysis of commit classification
- **Skip Logic**: Prevents infinite loops with `[skip vibe-badge]` commits

## Usage

### Basic Usage

```yaml
name: Update Vibe Coded Badge

on:
  push:
    branches: [ main ]

permissions:
  contents: write

jobs:
  update-badge:
    runs-on: ubuntu-latest
    if: "!contains(github.event.head_commit.message, '[skip vibe-badge]')"
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - uses: ai-ecoverse/vibe-coded-badge-action@main
```

### Advanced Usage

```yaml
    - uses: ai-ecoverse/vibe-coded-badge-action@main
      with:
        readme-path: 'docs/README.md'
        badge-style: 'flat-square'
        badge-color: '00ff00'
        badge-text: 'AI_Generated'
        commit-message: 'Bot: Update AI percentage badge'
        debug: 'false'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `readme-path` | Path to the README file to update | No | `README.md` |
| `badge-style` | Badge style (flat, flat-square, plastic, for-the-badge, social) | No | `for-the-badge` |
| `badge-color` | Badge color (hex code without #) | No | `ff69b4` |
| `badge-text` | Text to display after percentage | No | `Vibe_Coded` |
| `commit-message` | Commit message for badge updates | No | `Update vibe-coded badge` |
| `debug` | Enable debug mode for detailed analysis | No | `false` |
| `github-token` | GitHub token for pushing changes | No | `${{ github.token }}` |

## Outputs

| Output | Description |
|--------|-------------|
| `percentage` | The calculated percentage of AI-generated lines of code |
| `changed` | Whether the badge was changed (true/false) |
| `dominant-ai` | The AI tool with the most lines of code |

## AI Detection Logic

The action identifies AI-generated code by analyzing git blame data:

1. **Author Attribution**: Uses `git blame` to determine who wrote each line of code
2. **AI Tool Detection**: Identifies authors with names/emails containing:
   - Claude, Anthropic
   - Cursor
   - Zed
   - Windsurf
   - OpenAI
   - OpenCode
   - Gemini (Google)
   - Jules
   - Qwen (Alibaba)
   - Amp (Sourcegraph)
   - Droid (Factory AI)
   - GitHub Copilot
   - Aider
   - Cline
   - Crush (Charm)
   - Kimi (Moonshot AI)
   - Goose (Block)
   - Terragon
   - Various bot accounts
3. **Line Filtering**: Filters out boilerplate lines (comments, empty lines, imports) for accuracy
4. **File Type Support**: Analyzes source files across multiple programming languages
5. **Bot Detection**: Identifies automated commits from tools like Renovate, semantic-release

## Logo Selection

The badge automatically selects the appropriate logo based on which AI tool has the most commits:

- **Claude** → `claude` logo
- **Terragon** → `claude` logo
- **Codex** → `openai` logo
- **Windsurf** → `windsurf` logo
- **Cursor** → `githubcopilot` logo
- **Zed** → `zedindustries` logo
- **Gemini** → `google` logo
- **Jules** → `google` logo
- **Qwen** → `alibabacloud` logo
- **Amp** → `sourcegraph` logo
- **Droid** → `robot` logo
- **GitHub Copilot** → `githubcopilot` logo
- **Aider** → `openai` logo
- **Cline** → `claude` logo
- **Crush** → `robot` logo
- **Kimi** → `openai` logo
- **Goose** → `block` logo
- **Renovate** → `renovatebot` logo
- **Semantic Release** → `semanticrelease` logo
- **Other Bots** → `githubactions` logo

## Debug Mode

Enable debug mode to see detailed analysis:

```yaml
    - uses: ai-ecoverse/vibe-coded-badge-action@main
      with:
        debug: 'true'
```

This outputs:
- Total lines of code analyzed
- AI vs human line counts  
- Breakdown by AI tool type
- Selected logo information
- File type analysis

## Example Badge

The action generates badges like this:

## Git Aliases for AI Coding Tools

To improve AI detection accuracy, you can set up git aliases that automatically set the author name for different AI coding tools. This ensures commits are properly attributed and detected by the badge action.

### Recommended Aliases

Add these aliases to your git config to make AI tool detection more reliable:

```bash
# Claude Code commits
git config --global alias.claude-commit '!f() { msg="$1"; shift 1; git -c user.name="Claude Code" -c user.email="noreply@anthropic.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Zed AI commits  
git config --global alias.zed-commit '!f() { msg="$1"; shift 1; git -c user.name="Zed AI" -c user.email="noreply@zed.dev" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Cursor commits
git config --global alias.cursor-commit '!f() { msg="$1"; shift 1; git -c user.name="Cursor AI" -c user.email="noreply@cursor.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Windsurf commits
git config --global alias.windsurf-commit '!f() { msg="$1"; shift 1; git -c user.name="Windsurf AI" -c user.email="noreply@codeium.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# OpenAI Codex commits
git config --global alias.openai-commit '!f() { msg="$1"; shift 1; git -c user.name="OpenAI Codex" -c user.email="noreply@openai.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Gemini commits
git config --global alias.gemini-commit '!f() { msg="$1"; shift 1; git -c user.name="Gemini" -c user.email="noreply@google.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Jules commits
git config --global alias.jules-commit '!f() { msg="$1"; shift 1; git -c user.name="google-labs-jules[bot]" -c user.email="noreply@google.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Qwen Code commits
git config --global alias.qwen-commit '!f() { msg="$1"; shift 1; git -c user.name="Qwen Code" -c user.email="noreply@alibaba.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Amp (Sourcegraph) commits
git config --global alias.amp-commit '!f() { msg="$1"; shift 1; git -c user.name="Amp" -c user.email="noreply@sourcegraph.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Droid (Factory AI) commits
git config --global alias.droid-commit '!f() { msg="$1"; shift 1; git -c user.name="Droid" -c user.email="droid@factory.ai" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# GitHub Copilot commits
git config --global alias.copilot-commit '!f() { msg="$1"; shift 1; git -c user.name="GitHub Copilot" -c user.email="copilot@github.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Aider commits
git config --global alias.aider-commit '!f() { msg="$1"; shift 1; git -c user.name="$(git config user.name) (aider)" -c user.email="aider@aider.chat" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Cline commits
git config --global alias.cline-commit '!f() { msg="$1"; shift 1; git -c user.name="Cline" -c user.email="noreply@cline.bot" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Crush commits
git config --global alias.crush-commit '!f() { msg="$1"; shift 1; git -c user.name="Crush" -c user.email="crush@charm.land" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Kimi commits
git config --global alias.kimi-commit '!f() { msg="$1"; shift 1; git -c user.name="Kimi" -c user.email="noreply@moonshot.ai" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'

# Goose commits
git config --global alias.goose-commit '!f() { msg="$1"; shift 1; git -c user.name="Goose User" -c user.email="goose@example.com" -c commit.gpgsign=false commit -m "$msg" -m "Signed-off-by: $(git config user.name) <$(git config user.email)>" "$@"; }; f'
```

### Usage

Instead of regular `git commit`, use the AI-specific aliases:

```bash
# Instead of: git commit -m "Add new feature"
git claude-commit "Add new feature"

# Instead of: git commit -m "Fix bug in parser"
git zed-commit "Fix bug in parser"

# Instead of: git commit -m "Refactor database layer"
git cursor-commit "Refactor database layer"

# For other AI tools:
git jules-commit "Add new component"
git qwen-commit "Optimize algorithm"
git amp-commit "Add search functionality"
git droid-commit "Generate unit tests"
git copilot-commit "Implement feature X"
git aider-commit "Refactor module structure"
git cline-commit "Add validation logic"
git crush-commit "Improve error messages"
git kimi-commit "Implement new API endpoint"
git goose-commit "Add new feature"
```

### Benefits

- **Accurate Attribution**: Each AI tool gets proper credit in git history
- **Better Detection**: The badge action can distinguish between different AI tools
- **Dynamic Logos**: Badge automatically shows the logo of the dominant AI tool
- **Co-authorship**: Your name appears as co-author while AI gets primary credit
- **Consistent Format**: Standardized commit attribution across projects

### Alternative: Manual Override

You can also manually set the author for individual commits:

```bash
git -c user.name="Claude Code" -c user.email="noreply@anthropic.com" commit -m "Your message"
```

## Prerequisites

- Repository must have at least one commit
- Action needs `contents: write` permission to update README
- Use `fetch-depth: 0` to get full git history

## License

MIT License - see LICENSE file for details.

## Contributing

Pull requests welcome! Please ensure your commits follow the existing patterns for proper AI detection.
