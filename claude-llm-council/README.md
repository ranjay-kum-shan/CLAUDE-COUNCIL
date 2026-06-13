# 🏛️ LLM Council for Claude Code

Convene a panel of independent expert personas that **answer a hard question independently,
blind-rank each other's answers, and let a chairman synthesize one verdict** — with the
disagreement surfaced instead of averaged away.

This is a portable [Claude Code](https://code.claude.com) **skill** (packaged as a plugin) that
adapts the [LLM Council](https://github.com/karpathy/llm-council)-style deliberation pattern.

> **The idea.** The original LLM Council got its diversity from different model *providers*
> (GPT, Gemini, Claude). Claude Code can't easily mix providers per sub-agent, so this version gets
> its diversity from four orthogonal *personas* — and **optionally** lets you assign a different
> model to each member to restore true multi-model decorrelation. It works **across agents and
> models**: no hardcoded model, no dependency on any pre-installed agents — every persona ships
> inside the skill.

---

## The council

| Member | Lens |
| --- | --- |
| 🏛️ **Architect** | Systems thinking, correctness, long-term consequences, edge cases |
| 💡 **Innovator** | Reframing, lateral alternatives, the option nobody else mentions |
| 🔍 **Skeptic** | Failure modes, hidden assumptions, what breaks at 3 a.m. |
| 🔧 **Pragmatist** | What actually ships, effort vs. value, the cheap 80% solution |
| ⚖️ **Chairman** | Synthesizes all answers + rankings into one final verdict |

---

## Install

### Option A — as a plugin (one-line, recommended)

In Claude Code, replace `YOUR_GITHUB_USERNAME` with your handle after you push this repo:

```
/plugin marketplace add YOUR_GITHUB_USERNAME/claude-llm-council
/plugin install llm-council@llm-council-marketplace
```

That installs the `llm-council` skill **and** the `/council`, `/council-quick`, `/ideate` commands.
Update later with `/plugin marketplace update llm-council-marketplace`.

### Option B — as a plain skill (no plugin system)

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/claude-llm-council.git
cd claude-llm-council
./install.sh
```

This copies the self-contained skill to `~/.claude/skills/llm-council/` and the slash commands to
`~/.claude/commands/`. To scope it to a single project instead, copy
`plugins/llm-council/skills/llm-council/` into that project's `.claude/skills/`.

---

## Use

Three equivalent ways to trigger it:

```
/council            <your question, decision, or "review src/auth.ts">
/council-quick      <a question you want fused fast>
/ideate             <a problem you want fresh, divergent ideas for>
```

…or just ask in natural language: **“convene the council on whether to rewrite the parser.”**
Claude will invoke the skill automatically.

### Modes

| Mode | What it does | Use when |
| --- | --- | --- |
| **full** (`/council`) | 3 stages: independent answers → blind peer ranking → chairman verdict | High-stakes decisions, designs, "stress-test my thinking" |
| **quick** (`/council-quick`) | Parallel answers → chairman fuses them (no ranking) | You want several strong angles, fast |
| **ideate** (`/ideate`) | 5 creatively-constrained generators → clustered directions, no winner picked | Brainstorming, novel approaches |

> **Power move:** `/ideate` to open up the option space → pick a direction → `/council` to
> pressure-test it. **Diverge, then converge.**

---

## How it works

```
/council "your question"
   │
   ├─ Stage 0   Scope it (find files, write the Council Question)
   ├─ Stage 1   architect ║ innovator ║ skeptic ║ pragmatist     ← parallel, independent
   ├─ Stage 2   answers shuffled → relabeled A/B/C/D → same four blind-rank them   ← parallel
   ├─ Stage 2.5 Average the rankings → aggregate verdict
   └─ Stage 3   chairman synthesizes everything → final answer
                  ↓
        🏛️ Verdict + 📊 ranking + 🔍 transparency (disagreements flagged)
```

- **Blind review** — reviewers see `Response A/B/C/D`, never who wrote what (including their own).
  This is the original's key trick: it stops members from playing favorites.
- **Graceful degradation** — if a member fails, the council continues with whoever answered (min 2).
- **No sub-agent tool?** The skill falls back to running each persona inline and sequentially, so it
  still works inside restricted agents.

---

## Customize

Everything lives in `plugins/llm-council/skills/llm-council/`:

- **Tune a voice** — edit `personas/<member>.md` (each is the single source of truth for that lens).
- **Add a member** — drop a new `personas/<name>.md` with a Mode A + Mode B (keep the exact
  `FINAL RANKING:` format) and add it to the member list in `SKILL.md`.
- **True multi-model council** — when spawning members, assign a different model to each (a strong
  reasoning model for the Skeptic, a fast one for the Pragmatist, …). See the Stage 1 note in
  `SKILL.md`. This is the closest thing to the original's cross-provider ensemble.

---

## Repository layout

```
claude-llm-council/
├── .claude-plugin/marketplace.json        # makes the repo an installable plugin marketplace
├── plugins/llm-council/
│   ├── .claude-plugin/plugin.json         # plugin manifest
│   ├── skills/llm-council/
│   │   ├── SKILL.md                        # the skill: orchestration protocol + all 3 modes
│   │   └── personas/                       # the five council members (bundled, portable)
│   │       ├── architect.md  innovator.md  skeptic.md  pragmatist.md  chairman.md
│   └── commands/                           # thin /council, /council-quick, /ideate wrappers
├── install.sh                              # no-plugin install into ~/.claude
├── LICENSE                                 # MIT
└── README.md
```

## Credits

Adapts the **LLM Council** deliberation pattern (Andrej Karpathy's
[llm-council](https://github.com/karpathy/llm-council)) for Claude Code sub-agents.

## License

MIT © Ranjay Kumar
