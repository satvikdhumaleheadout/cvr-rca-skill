# CVR-RCA Skill

A Claude Code skill for investigating CVR (conversion rate) drops on Headout
Combined Experiences. It runs a structured root-cause analysis — baseline
queries, hypothesis tree, and a stakeholder-ready HTML report — all from a
single command.

---

## What it does

1. Runs BigQuery queries to pull funnel rates, Shapley attribution, mix signals,
   and trend context for the CE and date range you specify.
2. Walks a hypothesis tree (routing vs conversion, by funnel step) to isolate
   the driver.
3. Writes an HTML report with findings, supporting charts, and action cards —
   ready to share with GMs and product.

---

## Install

See **[INSTALL.md](INSTALL.md)** for step-by-step instructions (no git required).

**TL;DR** for those comfortable with Terminal:

```bash
curl -L https://github.com/satvikdhumaleheadout/cvr-rca-skill/archive/refs/heads/main.zip \
  -o /tmp/cvr-rca-install.zip && \
unzip -q /tmp/cvr-rca-install.zip -d /tmp/ && \
rm -rf ~/.cvr-rca && mv /tmp/cvr-rca-skill-main ~/.cvr-rca && \
rm /tmp/cvr-rca-install.zip && \
mkdir -p ~/.claude/commands && \
cat > ~/.claude/commands/cvr-rca.md << 'EOF'
---
description: CVR Root Cause Analysis for a Headout Combined Experience.
---

Read the skill file at: ~/.cvr-rca/SKILL.md
EOF
mkdir -p ~/Documents/CVR\ RCA\ Runs
```

Restart Claude Code, then type `/cvr-rca`.

---

## Usage

```
/cvr-rca <ce_id> [<pre_start> <pre_end> <post_start> <post_end>]
```

**Examples:**

```
/cvr-rca 167
/cvr-rca 167 2024-03-01 2024-03-30 2024-03-31 2024-04-29
```

Dates are optional — when omitted, defaults to last 30 days vs the prior 30 days.

---

## Requirements

- [Claude Code](https://claude.ai/download) (desktop app or CLI)
- `bq` CLI with `gcloud auth application-default login` completed
- Access to the `headout-analytics` BigQuery project

---

## Updating

To update to the latest version, re-run the install curl command (your runs
folder is untouched). See [INSTALL.md](INSTALL.md) for the exact steps.

The skill checks for updates automatically on each invocation and will notify
you when a newer version is available.

---

## Current version

See [VERSION](VERSION).
