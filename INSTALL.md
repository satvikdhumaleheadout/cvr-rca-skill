# CVR-RCA Skill — Install & Update Guide

This skill runs inside **Claude Code** (the desktop app or CLI). It adds a
`/cvr-rca` command that investigates CVR drops for Headout Combined Experiences.

---

## Prerequisites

| Tool | How to check | Install if missing |
|------|-------------|-------------------|
| Claude Code | Open the app | [claude.ai/download](https://claude.ai/download) |
| `bq` (BigQuery CLI) | `bq version` in Terminal | Install Google Cloud SDK and run `gcloud auth application-default login` |
| `curl` + `unzip` | Both built into macOS — nothing to do | — |

---

## Fresh install

Open **Terminal** and run these commands one at a time:

```bash
# 1. Download the skill (no git required)
curl -L https://github.com/satvikdhumaleheadout/cvr-rca-skill/archive/refs/heads/main.zip \
  -o /tmp/cvr-rca-install.zip

# 2. Unzip and move to the standard install location
unzip -q /tmp/cvr-rca-install.zip -d /tmp/
rm -rf ~/.cvr-rca
mv /tmp/cvr-rca-skill-main ~/.cvr-rca
rm /tmp/cvr-rca-install.zip

# 3. Register the /cvr-rca command with Claude Code
mkdir -p ~/.claude/commands
cat > ~/.claude/commands/cvr-rca.md << 'EOF'
---
description: CVR Root Cause Analysis for a Headout Combined Experience.
---

Read the skill file at: ~/.cvr-rca/SKILL.md
EOF

# 4. Create the default runs folder
mkdir -p ~/Documents/CVR\ RCA\ Runs

# 5. Confirm installed version
echo "Installed CVR-RCA version: $(cat ~/.cvr-rca/VERSION)"
```

After this, **restart Claude Code** (quit and reopen). Then type `/cvr-rca` in
any conversation — it should appear in the command picker.

---

## Update to latest version

Run the same download steps (1–2 above), then restart Claude Code. Your runs
folder (`~/Documents/CVR RCA Runs/`) is untouched — only the skill files update.

```bash
curl -L https://github.com/satvikdhumaleheadout/cvr-rca-skill/archive/refs/heads/main.zip \
  -o /tmp/cvr-rca-install.zip
unzip -q /tmp/cvr-rca-install.zip -d /tmp/
rm -rf ~/.cvr-rca
mv /tmp/cvr-rca-skill-main ~/.cvr-rca
rm /tmp/cvr-rca-install.zip
echo "Updated to CVR-RCA version: $(cat ~/.cvr-rca/VERSION)"
```

---

## Optional: keep runs in a custom folder

By default runs land in `~/Documents/CVR RCA Runs/`. To change this, add one
line to `~/.zshrc`:

```bash
export CVR_RCA_OUTPUT_DIR=~/Documents/your-preferred-folder
```

Then run `source ~/.zshrc` (or open a new Terminal window).

---

## Verify the install

In Claude Code, open a new conversation and type:

```
/cvr-rca
```

Claude should acknowledge the command and ask for a CE ID.

---

## Troubleshooting

**`/cvr-rca` not in the command picker after installing**
→ Quit Claude Code fully (Cmd+Q) and reopen. The command file is read at startup.

**`bq: command not found` when the skill runs**
→ Install Google Cloud SDK: `brew install --cask google-cloud-sdk`, then:
  `gcloud auth application-default login`

**Version mismatch error at startup**
→ Run the update steps above to get the latest version.

---

## File locations summary

| Path | What it is |
|------|-----------|
| `~/.cvr-rca/` | Skill files (hidden — use `ls -la ~/` to see it) |
| `~/.claude/commands/cvr-rca.md` | Claude Code command registration |
| `~/Documents/CVR RCA Runs/` | Where run outputs land (visible in Finder) |
