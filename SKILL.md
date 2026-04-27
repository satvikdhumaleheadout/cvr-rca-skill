---
name: cvr-rca
description: >
  CVR Root Cause Analysis for a Headout Combined Experience (CE). Use this skill
  whenever someone mentions a CVR drop, conversion decline, funnel performance
  issue, or asks for an RCA on bookings/orders for a specific CE — even if they
  don't use the phrase "CVR-RCA". Also triggers when someone says "why did CVR
  fall for CE X", "diagnose this funnel", "conversion is down on experience Y",
  or any similar phrasing. Run /cvr-rca or invoke whenever a funnel investigation
  is needed.
---

# CVR Root Cause Analysis

## Before you begin

```bash
SKILL_DIR=~/Documents/RCA\ skill/cvr-rca
cat "$SKILL_DIR/references/context.md"
cat "$SKILL_DIR/references/hypothesis.md"
cat "$SKILL_DIR/references/actions.md"
cat "$SKILL_DIR/references/report_structure.md"
```

Each file owns a distinct concern:

**`context.md`** — data vocabulary, table schemas, query rules, dimension meanings,
funnel step definitions, investigation patterns, and analytical principles. Read
this before touching any data or forming hypotheses.

**`hypothesis.md`** — historical priors from 21 Headout RCAs, ranked by frequency.
Read after answering the three mandatory questions. Use to orient hypothesis
generation — not to constrain it.

**`actions.md`** — cause-to-action mapping. Once a root cause is confirmed, find
the matching category here and use the listed actions for the report's action cards.

**`report_structure.md`** — output structure and visual spec. The fixed three-section
layout every report follows. Read before writing Step 3.

---

## Your role

A GM has noticed CVR dropped for a specific CE. Your job is to figure out what
actually happened and what to do — not to run every analysis available, but to
run the right ones.

The output is an HTML report that reads like a story: here is what we found, here
is why it matters, here is what to do. Every chart and table earns its place by
being necessary to the finding.

---

## Invocation

```
/cvr-rca <ce_id> <pre_start> <pre_end> <post_start> <post_end>
```

---

## Step 1 — Run the baseline queries

```bash
bash "$SKILL_DIR/scripts/run_analysis.sh" \
  <ce_id> <pre_start> <pre_end> <post_start> <post_end>
```

This produces `summary.json` at `/tmp/cvr_rca_<ce_id>/summary.json`.

`summary.json` contains: CE metadata, headline funnel rates, Shapley, MB/HO +
paid/non-paid mix, mix dominance, daily pre/post trend (`trend`), and the
90-day rolling trend + LY context (`trend_context`).

Everything beyond the baseline — dimensions, experience breakdowns, price,
URL-level funnels — is your responsibility to query from scratch. `context.md`
has every table schema and column definition you need. Write the query that
tests your specific hypothesis.

If the script fails: check `gcloud auth application-default login` and that `bq`
is on `$PATH`.

---

## Data pull errors — log and continue

At any point a query may fail or return empty. When this happens:

**Do not stop. Do not retry in a loop.**

1. **Log the failure** in the investigation transcript:
   ```
   ### [Data pull failure — <query name>]
   Error: <exact error message or "empty result">
   Impact: <which part of the analysis this affects>
   Workaround: <what you will use instead, or "none available">
   ```

2. **Add a data-gap note in the report** wherever the missing data would have
   appeared:
   > ⚠️ **Data unavailable — [query name]:** [one sentence on what failed and
   > what it means for this finding]. Analysis continues with available data.

3. **Continue the investigation** using everything else that did return.

4. **Adjust confidence language** in the root cause callout if the missing data
   was material. Use "consistent with" rather than "confirmed by" for that claim.

**Scope:** applies to all data pulls — BQ queries, the baseline pipeline, and
Mixpanel MCP calls.

---

## Step 2 — Investigate

Read `summary.json`. Answer the three mandatory questions in order — each
determines what to look at next. Then form hypotheses and query.

### Start the investigation transcript

Before reading the data, open the transcript file:

```
~/Documents/RCA\ skill/transcripts/ce<ce_id>_<post_start>.md
```

Create it if it doesn't exist (`mkdir -p ~/Documents/RCA\ skill/transcripts`).

Append an entry each time you make a meaningful decision:

```
### [Decision point name]
Hypothesis: what you were testing
Data: exact fields and values you looked at
Decision: which path you took
Ruled out: what you dismissed and why
```

Required entries: one for each of the three mandatory questions, one for each
dimension or custom query you ran, and one for the verdict synthesis. If a path
produced nothing actionable, say so and say why you stopped.

---

### The three questions you cannot skip

**Question 1: Is this a routing problem or a conversion problem?**

Check `mix_dominance.is_dominant`. If true and no funnel step shows a meaningful
rate change, this is a traffic composition story — investigate where and why
traffic shifted, not the funnel steps themselves. If false, continue to Question 2.

See `context.md` → "MB vs HO" and "Channels" for what mix signals mean.

---

**Question 2: Which step is the primary driver?**

Check `shapley`. Identify which step(s) carry the majority of ΔCVR. Everything
that follows is anchored to those steps — do not deep-dive steps that carry
less than ~10% of the delta.

---

**Question 3: Was this sudden, gradual, or seasonal?**

Using `trend_context` from `summary.json`:

- **Step 3a:** Read the 90-day trend shape — sharp break, gradual erosion, or
  recovery in progress. Also check `trend_context.pre_period_healthy`.
- **Step 3b:** Compare `current_delta_cvr` to `ly_delta_cvr`. Compute whether
  the drop has a seasonal component or is fully structural.
- **Step 3c:** Check weekday composition — a post period with more weekends can
  produce an apparent drop with no real change.

See `context.md` → "Q3 Trend Interpretation" for what each pattern implies and
how to calibrate investigation depth from `structural_delta_cvr`.

The answer to Q3 determines what you look for: sudden → what changed on that
date; gradual → what is eroding; seasonal → quantify structural delta and
calibrate depth accordingly.

---

### Form hypotheses, then query to test them

After the three questions, consult `hypothesis.md` for historical patterns.
Use it to orient thinking — not to constrain it. Then write 2–4 specific,
falsifiable hypotheses before running another query. These must be mechanisms,
not observations:

- *Observation* (wrong): "S2C dropped on mobile"
- *Hypothesis* (right): "The Apr 8 mobile deploy broke date-picker rendering
  on iOS, causing users to see no available slots and abandon the select page"

Each hypothesis should name a cause, a segment or experience, and the pattern
you would expect to see if it were true. Then test each one with a targeted
BQ query.

---

### Writing and running custom queries

Custom queries are the primary investigation tool from this point forward.
Write each query from scratch to test your specific hypothesis. Full table
schemas, column definitions, query rules, investigation patterns per funnel
step, and dimension guidance are all in `context.md`.

Run queries with:
```bash
bq query --use_legacy_sql=false --format=json --quiet \
  --project_id=headout-analytics \
  <<'SQL'
  ... your query ...
SQL
```

Log each query in the transcript with the hypothesis it was testing and what
you found.

---

### Mixpanel session recordings

Once a specific locus is confirmed — a particular URL, experience (TGID), device
type, page type, or cross-cut — pull session recordings using the Mixpanel MCP
(`Get-User-Replays-Data`). Any concentrated dimension cut is sufficient; you do
not need all dimensions confirmed simultaneously. Pass the CE ID, the post-period
date range, and the dimension that defines the locus.

This is a required step once a locus is confirmed — recordings move a finding
from "consistent with" to "directly observed."

If recordings are skipped, the report must explicitly state why (volume too low,
or no concentrated locus identified). Skipping without explanation is not
acceptable once a locus has been confirmed.

Do not pull recordings speculatively before a locus has been identified.

See `context.md` → "Session Recordings" for what to look for and how to
interpret results.

---

## Step 3 — Write the report

Follow `report_structure.md` exactly. Write the output to:
`/tmp/cvr_rca_<ce_id>/report.html`

For a concrete walkthrough of how an investigation unfolds end-to-end, see
`references/worked_example.md`.

---

## Step 4 — Evaluate the analysis

Run this after the report is written. Read the rubric first:

```bash
cat "$SKILL_DIR/evals/evaluator.md"
```

The rubric covers 7 themes. To evaluate, re-read:
1. The HTML report — as if you've never seen this CE before
2. Your investigation transcript — what you looked at, why, what you decided
3. The `summary.json` — to verify claims against actual numbers

Score each theme 1–5. Write the evaluation to:

```bash
EVALS_DIR=~/Documents/RCA\ skill/evals
mkdir -p "$EVALS_DIR"
EVAL_FILE="$EVALS_DIR/ce<ce_id>_<post_start>.md"
```

**Evaluation file structure:**

```markdown
# CVR-RCA Evaluation
CE [id] · [CE name] | [pre period] vs [post period] | [date]

## Overall verdict
[3–4 sentences: what did this RCA get right, what was the main failure mode,
what would a senior analyst say after reading the report?]

## Theme scores

### 1. Narrative Coherence — [score]/5
### 2. Hypothesis Specificity & Quality — [score]/5
### 3. Investigation Effort & Adaptivity — [score]/5
### 4. Branch Decision Quality — [score]/5
### 5. Evidence Strength — [score]/5
### 6. Output Appropriateness — [score]/5
### 7. DRI & Actionability — [score]/5

## Top improvements for next run
1. [Most impactful concrete improvement]
2. [Second most impactful]
3. [Third if applicable]
```

After writing the evaluation file, print two lines to the user:

```
Evaluation → [EVAL_FILE]
[Total X/35] · Strongest: [theme name] ([score]) · Watch: [theme name] ([score])
```

Do not narrate the full evaluation in chat. The file is the record.

Saved evaluations accumulate in `~/Documents/RCA skill/evals/`. Review across
runs to identify systematic weaknesses worth addressing in the skill itself.

---

## Backlogs

**Parked for later:**
- Payment gateway error breakdown for A2O (`order_attempted_events_v2`:
  `payment_gateway`, `payment_method`, `fraud_evaluation_result_origin`,
  `failure_reason`)
- LP2S price vs LY baseline
- Bootstrap confidence intervals on Shapley values

---

## Changelog

| # | Date | Changes |
|---|------|---------|
| c001 | 2026-04-24 | Initial version — investigation framework, 3 mandatory questions, Shapley, mix decomp, custom query patterns, render.py integration, Step 4 evaluator |
| c002 | 2026-04-24 | Added `report_structure.md` to "Before you begin" reads; updated file role descriptions; clarified hypothesis.md is historical priors not a constraint; replaced Step 3 with pointer to `report_structure.md`; updated Backlogs |
| c003 | 2026-04-24 | Added majority-contributor principle; added rate × volume rule; reframed session recordings as required once locus confirmed; added explicit requirement to state why recordings were skipped |
| c004 | 2026-04-24 | Fixed session recordings trigger to disjunctive; added "Data pull errors — log and continue" section |
| c005 | 2026-04-24 | Updated report visual standard; added P1/P2/P3 priority badges |
| c006 | 2026-04-27 | Removed Q2/Q4/Q5/Q6 template pointer; fixed stale summary.json field references in investigation patterns |
| c007 | 2026-04-27 | Stripped SKILL.md to pure process. All domain knowledge, analytical guidance, query rules, dimension guides, investigation patterns, and worked examples moved to context.md and references/worked_example.md. |
| c008 | 2026-04-27 | Removed confusing or redundant lines: "no render.py" negative instruction, internal Q0/Q1/Q3/Q7 stage names, raw stage file paths, Plotly color codes and chart instructions (already in report_structure.md), three-section structure restatement (already in report_structure.md), "Under development" backlog items that implied Claude should add banners for unimplemented features. |
