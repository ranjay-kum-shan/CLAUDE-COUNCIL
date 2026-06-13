#!/usr/bin/env bash
# Install the LLM Council skill + slash commands into your personal ~/.claude config.
# This is the no-plugin route. For one-line install via the plugin system, see README.md.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugin="$here/plugins/llm-council"

skills_dir="$HOME/.claude/skills"
cmds_dir="$HOME/.claude/commands"

mkdir -p "$skills_dir" "$cmds_dir"

# The skill is self-contained (it bundles personas/).
rm -rf "$skills_dir/llm-council"
cp -R "$plugin/skills/llm-council" "$skills_dir/llm-council"

# Optional slash-command wrappers: /council, /council-quick, /ideate
cp "$plugin/commands/"*.md "$cmds_dir/"

echo "✅ Installed the LLM Council:"
echo "   skill    → $skills_dir/llm-council"
echo "   commands → $cmds_dir/{council,council-quick,ideate}.md"
echo
echo "Try it:  /council  should we add caching or fix the slow query first?"
echo "   or just ask:  \"convene the council on <your question>\""
