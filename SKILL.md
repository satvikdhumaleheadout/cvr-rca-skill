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
/cvr-rca <ce_id> [<pre_start> <pre_end> <post_start> <post_end>]
```

Dates are optional. When omitted, the script defaults to **last 30 days vs the
30 days before that** (yesterday back 30 days = post; the prior 30 days = pre).

---

## Step 1 — Run the baseline queries

```bash
bash "$SKILL_DIR/scripts/run_analysis.sh" \
  <ce_id> <pre_start> <pre_end> <post_start> <post_end>
```

This produces `summary.json` inside a run folder under
`~/Documents/RCA\ skill/Test\ Runs/`. The folder is named
`ce<ce_id>_<pre_start>_<post_end>/`. If that folder already exists (a previous
run on the same CE and dates), the script auto-increments: `_run2/`, `_run3/`,
etc. The script prints the chosen folder name — call it `<run_dir>` for the
rest of this document.

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

Read `summary.json`. Then run the investigation as a tree: orient at L0 using
everything that is already computed, open branches at L1, descend to a leaf.

### Start the investigation transcript

Before reading the data, open the transcript file. The run directory was
already created by the baseline script — write the transcript there:

```
<run_dir>/transcript.md
```

The transcript has two layers: a **tree map** at the top that shows the full
branch structure at a glance, and **detail sections** below with query results.
Write both as you go.

```markdown
# Investigation Transcript — CE [id] · [name]
Pre: [dates] | Post: [dates]

## Tree map
<!-- Update this block each time a branch resolves. -->
L0: [primary signal summary — e.g. "S2C (83% Δ) · gradual · structural"]
├─ L1a: [hypothesis name]  →  [CONFIRMED / RULED OUT / OPEN] ([one-line evidence])
├─ L1b: [hypothesis name]  →  [CONFIRMED / RULED OUT / OPEN] ([one-line evidence])
│   └─ L2a: [sub-hypothesis]  →  [CONFIRMED / RULED OUT] ([one-line evidence])
│       └─ LEAF: [mechanism in one line]
└─ L1c: [hypothesis name]  →  [RULED OUT] ([why])

---

## L0 — Orient
**mix_dominance:** [is_dominant value + what it means for this CE]
**shapley:** [LP2S Xpp · S2C Xpp · C2O Xpp — primary step and share of ΔCVR]
**trend_context:** [shape: sharp/gradual/recovery + pre_period_healthy + structural_delta_cvr]

## L1 — [descriptive label for this level's focus]
### [Hypothesis A name] · [Hypothesis B name] — parallel

**[Hypothesis A]**
Query: [what you tested and why]
Result: [key numbers — rates, counts, deltas]
→ CONFIRMED — opens L2: [sub-hypotheses] | Closes: [what this rules out]

**[Hypothesis B]**
Query: [...]
Result: [...]
→ RULED OUT — [reason in one line]

## L2 — [descriptive label]
### [Hypothesis C name]

**[Hypothesis C]**
Query: [...]
Result: [...]
→ CONFIRMED — LEAF reached

## Root cause confirmed
[One paragraph: the mechanism, the segment, the timing — fully stated.
Every number here must trace to a named query result in the detail sections above.]
```

**How to use the tree map:** Start it after L0 with all L1 branches marked
`OPEN`. Update each entry to `CONFIRMED` or `RULED OUT` as results come in.
Add child branches (`└─ L2a`) only when a parent confirms. When the leaf is
reached, mark it `LEAF` and stop. Anyone reading the transcript sees the full
investigation shape in the map before reading a single detail section.

If a branch produces nothing actionable, mark it `RULED OUT` in the map and
write one line in the detail section explaining why. Do not descend further.

---

### L0 — Orient from summary.json

Read `summary.json` and extract all three orientation signals at once. These
three signals are read simultaneously — they are not a sequential gate.

**Signal 1 — mix_dominance (routing vs conversion)**

Check `mix_dominance.is_dominant`. If true, the primary story is traffic
composition: MB/HO share or channel mix shifted enough to explain the drop
without any funnel step breaking. The investigation pivots to "where and why
did traffic shift" rather than "which step broke". If false, the drop is a
conversion problem — continue to shapley.

See `context.md` → "MB vs HO" and "Channels" for what mix signals mean.

**Signal 2 — shapley (which step is the story)**

Check `shapley`. Identify which step(s) carry the majority of ΔCVR. The entire
investigation is anchored to those steps. Do not deep-dive steps that carry
less than ~10% of the delta — even if a rate change is visible there, it is not
the driver.

See `context.md` → "Investigation tree — L0 to L1 branch map" for how each
shapley outcome opens specific L1 branches.

**Signal 3 — trend_context (timing and seasonal calibration)**

Read the 90-day trend shape, `pre_period_healthy`, `structural_delta_cvr`, and
the weekday composition:

- **Sharp break** → something changed on a specific date. That date is the
  most important clue. L1 branches should include a date-of-change cut.
- **Gradual erosion** → something has been compounding. Look for trends in
  supply, pricing, or traffic quality rather than a single event.
- **Recovery in progress** → the pre window may already be below normal; the
  pre/post delta understates the real change.
- **seasonal component** → compare `current_delta_cvr` to `ly_delta_cvr`. If
  `structural_delta_cvr` is small, calibrate investigation depth accordingly.
  A small structural delta raises the bar for concluding "new problem".
- **Weekday composition** → count weekday vs weekend days in pre and post. A
  post period heavy in weekends can produce apparent drop with no real change.

See `context.md` → "Q3 Trend Interpretation" for full interpretation guide.

---

### L1 — Mix cascade (always first, before any funnel hypotheses)

Before forming any hypothesis about LP2S / S2C / C2O, run the mix cascade to
fix the primary segment. This is mandatory — running funnel analysis on the
full CE mixes cohorts with very different base CVRs and produces noisy findings.

**Step 1 — MB vs HO:** Read from `summary.json` (no query needed).
**Step 2 — Paid vs organic within primary brand:** Run Level 2 query.
**Step 3 — Channel breakdown within paid:** Run Level 3 query (if paid is primary).

Full query templates and the decision rule for fixing each level are in
`context.md` → "Mix Cascade — Fixing the Primary Segment".

Once the cascade is done, declare the fixed segment in the transcript:

```
Fixed segment: [MB/HO] · [Paid/Organic] · [channel if applicable]
Filters for all subsequent queries: AND is_microbrand_page = ... AND channel_name = ...
```

Log the cascade in the tree map as its own L1 batch, then add the fixed segment
declaration as a persistent note before L2 branches open.

### L2+ — Branch and descend (all queries filtered to fixed segment)

With the segment fixed and the primary funnel step identified from Shapley,
open L2 branches. Each branch is a specific, falsifiable hypothesis about why
that funnel step dropped in the fixed segment. Every query from this point
carries the fixed segment filters.

A branch is a hypothesis, not an observation. Name the mechanism, the segment
or experience, and the pattern you would expect if it were true:

- *Observation* (wrong): "S2C dropped on mobile"
- *Hypothesis* (right): "The Apr 8 mobile deploy broke date-picker rendering
  on iOS, causing users to see no available slots and abandon the select page"

**Where branches come from:** Open the first set of branches using the
investigation patterns in `context.md` for the primary funnel step — those
patterns are the default starting set. Run the first set in parallel, then read
the results. Each result either opens a new branch, closes one, or concentrates
the investigation — and what the data shows determines what the next branches
are. The branches are not written upfront as a fixed list; they grow level by
level from what the data actually shows. Consult `hypothesis.md` for historical
priors, but don't treat any list as a ceiling.

Run all branches within a level in parallel — one query batch, results read
together.

Each result either:
- **Confirms** → descend: open a child branch that tests the mechanism more
  specifically — write that branch from what you just saw, not from a template
- **Rules out** → close the branch, state why in one line, do not revisit
- **Concentrates** → the segment or experience with the largest impact becomes
  the anchor; the next branch asks *why* it concentrated — what mechanism
  explains that specific segment being affected?
- **Surprises** → something unexpected appeared (an unexplained number, a
  pattern inconsistent with the story so far) — open a new branch to test it,
  even if it wasn't in the default set

Continue descending (L2, L3 if needed) until you reach a leaf: a specific
mechanism at a specific segment/experience/URL/date that fully explains both
the rate delta and the volume impact. The investigation is complete when you
reach the leaf — not when the starting pattern list is exhausted. If you've
run the default patterns and have no leaf, that is a signal to look harder —
at cross-cuts not yet tested, finer grain not yet drilled, or tables beyond
the funnel table. Queries at each level are written from scratch — full table
schemas and column definitions are in `context.md`.

Run queries with:
```bash
bq query --use_legacy_sql=false --format=json --quiet \
  --project_id=headout-analytics \
  <<'SQL'
  ... your query ...
SQL
```

---

### Session recordings — required once a locus is confirmed

Once a specific locus is confirmed (URL, experience, device, page type, or any
concentrated cross-cut), pull session recordings using the Mixpanel MCP
(`Get-User-Replays-Data`). Any single confirmed dimension is sufficient — you
do not need all dimensions locked simultaneously.

Recordings move a finding from "consistent with" to "directly observed." They
are not optional once a locus exists.

If recordings are skipped, the report must explicitly state why (volume too low
or no concentrated locus found). Do not pull recordings speculatively before a
locus is identified.

See `context.md` → "Session Recordings" for what to look for and how to
interpret results.

---

## Step 2b — Synthesise findings and review

Before writing HTML, write a structured findings summary. This is not a draft
report — it is a short markdown file that forces every major claim to be made
explicit and checked before it is committed to the report.

Save to: `<run_dir>/findings.md`

**Write the findings summary:**

```markdown
## Root cause
[One sentence: what broke, in which segment, by how much]

## Mechanism
[The causal chain — what actually happened, not just what the data shows]

## Timing
[Sudden / gradual / seasonal — and the key evidence for that classification]

## Evidence inventory
| Claim | Supporting data | Source | Confidence |
|-------|----------------|--------|------------|
| [claim] | [specific numbers or observation] | [summary.json field / query result / report table row] | Confirmed / Consistent with / Unverified |

## Open items
[Each Consistent with / Unverified row that a query could close]
[Any number surfaced in the investigation that has no place in the narrative]
[Any recommendation you plan to make that you have not verified yourself]
```

**Then re-read it critically and resolve each open item:**

- **Query would close it** → write and run it, update Evidence inventory
- **Arithmetic on existing data** → compute it, add result to Evidence inventory
- **Genuinely unresolvable** → accept "Consistent with" and ensure the report
  language reflects that — do not present it as confirmed

**Specific checks before proceeding:**

- Any calendar event (holiday, peak, school break) cited as a cause → is there
  a controlled comparison showing the metric with vs. without those dates?
- Any number that appeared in the investigation but isn't connected to the root
  cause narrative → either connect it or explicitly rule it out in the report
- Any recommendation you plan to make → did you actually verify the claim that
  justifies it, or are you passing an unverified hypothesis to the DRI?
- **Every count or computed metric cited anywhere in findings.md** — it must
  have a named Source in the Evidence inventory (a `summary.json` field, a
  logged BQ query result, or a specific table row that will appear in the
  report). If you cannot name the source, either derive the number explicitly
  with written arithmetic, or remove it. A number with no named source must not
  enter the report — it is a hallucination risk.

Once all open items are resolved or explicitly accepted, proceed to Step 3.

---

## Step 3 — Write the report

Follow `report_structure.md` exactly. Write from the solidified `findings.md` —
the findings summary is the source of truth for every claim in the report.
Write the output to: `<run_dir>/report.html`

For a concrete walkthrough of how an investigation unfolds end-to-end, see
`references/worked_example.md`.

---

## Step 4 — Evaluate the analysis

**Purpose:** pure scoring and quality tracking. Investigation gaps should have
been closed in Step 2b — the evaluator is not a patch mechanism, it is a record.

Run this after the report is written. Read the rubric first:

```bash
cat "$SKILL_DIR/evals/evaluator.md"
```

The rubric covers 7 themes. To evaluate, re-read:
1. The HTML report — as if you've never seen this CE before
2. Your investigation transcript — what you looked at, why, what you decided
3. The `summary.json` — to verify claims against actual numbers

Score each theme 1–5. Write the evaluation into the run folder:

```bash
EVAL_FILE=<run_dir>/evaluation.md
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

Each run folder in `~/Documents/RCA skill/Test Runs/` accumulates three files:
`report.html`, `transcript.md`, and `evaluation.md`. Evaluations are the signal
for improving the skill over time — not for patching individual reports.

When the same improvement appears across multiple evaluations (e.g., session
recordings consistently not pulled, seasonal events never quantified with a
controlled comparison), that is a signal to update the skill files —
`context.md`, `hypothesis.md`, or `SKILL.md` — so the investigation logic
catches it earlier next time, rather than adding more loops within the skill.

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
| c009 | 2026-04-27 | Default window changed to 30/30 days. Dates are now optional in the invocation — when omitted, the script computes last 30 days as post and the prior 30 days as pre. |
| c010 | 2026-04-27 | Added Step 2b — Synthesise findings and review. Claude writes a structured findings.md (root cause, mechanism, timing, evidence inventory, open items) before writing HTML. Open items — unverified claims, floating data points, unquantified recommendations — are resolved with follow-up queries or arithmetic before proceeding. Step 3 now writes from findings.md as the source of truth. Step 4 clarified as pure scoring; meta-review pattern documented for updating skill files across runs. |
| c011 | 2026-04-27 | Evidence inventory gains a Source column — every claim with a number must name its source (summary.json field, BQ query result, or report table row). Added fourth specific check: any count or metric with no named source must be derived explicitly or removed before entering the report. Quick Reference block updated: date default changed from weekly Mon–Sun windows to 30/30 days (yesterday − 30 days as post, prior 30 days as pre), matching SKILL.md c009. |
| c016 | 2026-04-28 | Run folder auto-increments when same CE + dates are re-run: base folder keeps no suffix, subsequent runs get _run2, _run3, etc. SKILL.md uses <run_dir> shorthand for all output paths. |
| c012 | 2026-04-27 | Investigation model redesigned from sequential three-question gates to an investigation tree. L0 reads all three orientation signals simultaneously (mix_dominance, shapley, trend_context) then opens parallel L1 branches. Investigation descends level-by-level until a leaf (specific mechanism × segment × date). Transcript format mirrors the tree structure (L0 section, L1/L2 sections with parallel batch labels, Root cause confirmed paragraph). context.md gains "Investigation tree — L0 to L1 branch map" lookup table. worked_example.md rewritten with tree-format transcripts and parallel query batches explicit. |
| c017 | 2026-04-29 | Mix cascade redesigned as mandatory L1 step: three levels (MB/HO → Paid/Organic → Channel within Paid). Fixed segment declared from cascade results; all L2+ funnel queries carry the fixed segment filters. L1 and L2+ steps renamed in Step 2 accordingly. context.md gains full Mix Cascade section with three query templates, decision rule, and fixed segment declaration template. report_structure.md gains Fixed Segment banner HTML spec and updated 90-day chart spec (weekly ticks + LY data guard). |
| c018 | 2026-04-29 | L2+ section rewritten to make hypothesis generation self-extending: context.md patterns are explicitly the default *starting set*, not an exhaustive list. Results themselves generate the next hypothesis. Four result types defined: Confirms, Rules out, Concentrates, and Surprises (the last being new — an unexpected result generates a new branch even if not on the default list). "Investigation ends at the leaf, not at list exhaustion" stated explicitly. context.md Common Investigation Patterns header rewritten to match — replaces weak "not rails" disclaimer with explicit loop logic and three common reasons a list runs out before a leaf is reached. |
| c019 | 2026-04-29 | Removed "write 2–4 specific, falsifiable hypotheses" from L2+ — this was a leftover artifact from the old Q1/Q2/Q3 model that contradicted the tree structure. L2+ now opens branches from the context.md default set and grows them level-by-level from what the data shows. Branches are not a fixed upfront list. |
