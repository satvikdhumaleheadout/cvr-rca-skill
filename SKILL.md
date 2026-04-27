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

Each file owns a distinct concern. They do not overlap:

**`context.md`** — the data vocabulary. Business domain, table schemas, column meanings, counting rules, analytical definitions. Read this before touching any data. Everything you need to write correct BQ queries and interpret results is here.

**`hypothesis.md`** — historical priors. Patterns observed across 21 Headout MMPs, ranked by frequency. Read this after answering the three mandatory questions in Step 2 to orient your hypothesis generation — not to constrain it. Form your own hypotheses from what the data shows. The patterns here are starting points, not a menu.

**`actions.md`** — cause-to-action mapping. Once a root cause is confirmed, find the matching category here and use the listed actions for the action cards in the report. Read this when writing Step 3.

**`report_structure.md`** — output structure. The fixed three-section layout every report follows (Executive Summary → Actions → Supporting Analysis). Read this before writing Step 3.

---

## Your role

A GM has noticed CVR dropped for a specific CE. Your job is to figure out what
actually happened and what to do — not to run every analysis available, but to run
the right ones.

The output is an HTML report that reads like a story: here is what we found, here
is why it matters, here is what to do. The GM should know the answer from the first
section. Everything below that is evidence that earned its place by being necessary
to the finding.

Every cut you show should answer a question that was already raised by something
above it. If you cannot explain why a reader needs a particular table or chart,
leave it out.

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

This runs Q0, Q1, Q3, Q7 and produces `summary.json`.

```
/tmp/cvr_rca_<ce_id>/summary.json          ← read this
/tmp/cvr_rca_<ce_id>/stage{0,1,3,7}.json  ← raw BQ (debugging)
```

`summary.json` contains: CE metadata, headline funnel rates, Shapley, MB/HO +
paid/non-paid mix, mix dominance, daily pre/post trend (`trend`), and the
90-day rolling trend + LY context (`trend_context`).

**Reference SQL templates (not auto-run):** Q2 (dimensions), Q4 (experience
breakdown), Q5 (price), Q6 (URL funnel) are in `references/` as starting
points. Use them when your hypothesis leads there — adapt the WHERE clause for
the specific segment or experience you are testing. Do not run them
speculatively before forming a hypothesis.

If the script fails: check `gcloud auth application-default login` and that `bq`
is on `$PATH`.

---

## Data pull errors — log and continue

At any point in the investigation a query may fail or return empty — BQ permission
errors, table not found, MCP timeouts, or a stage that produced no rows. When this
happens:

**Do not stop. Do not retry in a loop.**

1. **Log the failure immediately** in the investigation transcript:
   ```
   ### [Data pull failure — <query name>]
   Error: <exact error message or "empty result">
   Impact: <which part of the analysis this affects>
   Workaround: <what you will use instead, or "none available">
   ```

2. **Add a data-gap note in the report** wherever the missing data would have
   appeared. Use this format inline in the relevant report section:
   > ⚠️ **Data unavailable — [query name]:** [one sentence explaining what failed
   > and what it means for this finding]. Analysis continues with available data.

3. **Continue the investigation** using everything else that did return. A missing
   stage is a gap in evidence, not a reason to halt — the rest of the analysis
   stands on its own.

4. **Adjust confidence language** in the root cause callout if the missing data
   was material to confirming the hypothesis. Use "consistent with" rather than
   "confirmed by" for that specific claim.

**Scope of this rule:** applies to BQ custom queries, prebuilt pipeline stages
(Q0–Q6), Mixpanel `Get-User-Replays-Data` calls, and any other data pull in the
skill. One failed data source does not invalidate the rest.

---

## Step 2 — Investigate

Read `summary.json`. What follows are not sequential steps — they are the questions
a good analyst must answer, in a logical order, because the answer to each one
determines what to look at next.

### Start the investigation transcript

Before reading the data, open the transcript file:

```
~/Documents/RCA\ skill/transcripts/ce<ce_id>_<post_start>.md
```

Create it if it doesn't exist (`mkdir -p ~/Documents/RCA\ skill/transcripts`).

As you work through the investigation, append an entry each time you make a
meaningful decision — which path you took and why you took it instead of another.
Use this format:

```
### [Decision point name]
Hypothesis: what you were testing
Data: exact fields and values you looked at
Decision: which path you took
Ruled out: what you dismissed and why
```

Required entries — one for each of the three mandatory questions below, one for
each dimension or custom query you ran, and one for the verdict synthesis at the
end. If a path produced nothing actionable, say so and say why you stopped there.

This file is read by the evaluator in Step 4. Write it as if explaining your
reasoning to a senior analyst who is reviewing your work.

---

### The three questions you cannot skip

These are not on a checklist because someone put them there. They are prerequisites.
If you skip any of them, you risk diagnosing the wrong thing.

---

**Question 1: Is this a routing problem or a conversion problem?**

Look at `mix_dominance`. MB traffic converts structurally lower than HO. Paid
search converts higher than organic. If the traffic composition shifted — more MB,
less paid — overall CVR falls even if every individual segment performed normally.
This is not a funnel failure; it is a demand or campaign story.

Before concluding anything about the funnel, establish whether mix explains the
drop. If `mix_dominance.is_dominant` is true and no funnel step shows a meaningful
absolute change (say, ≥ 4–5pp), the diagnosis is in the routing, not the product.
That changes everything about what you investigate next.

If mix is dominant: the interesting question becomes *where did traffic shift*? A
URL-level traffic query (not rates — volumes) will show which pages gained or lost
traffic between periods. That is the lead.

If conversion is dominant: continue to Question 2.

---

**Question 2: Which step is the primary driver?**

Look at `shapley`. The three Shapley values (LP2S, S2C, C2O) sum exactly to ΔCVR.
A step that carries 60% of the change is where the problem lives. A step that
carries 5% is background noise — deep-diving it will not produce an actionable
finding.

Identify which step(s) are primary. Everything in the investigation that follows
is anchored to those steps.

---

**Question 3: Was this sudden, gradual, or seasonal?**

This question now has three branches, not two. Read them in order.

**Step 3a — Read the 90-day trend (`trend_context.series`).**

Plot or mentally trace the CVR line for the 90 days ending at post_end. Three
patterns:

- *Sharp break:* CVR was stable for weeks, then dropped on a specific date.
  Something changed that day — a deploy, pricing update, availability
  configuration, or supply event. That date is the single most important clue
  in the entire investigation.
- *Gradual erosion:* CVR has been drifting down for weeks or months before the
  post period even started. The pre/post Shapley delta may understate the true
  structural change. Dimension cuts and supply trends become the primary tools.
- *Recovery in progress:* CVR dropped earlier and is recovering. The pre/post
  comparison may show no problem while the 90-day trend shows a prior incident.

Also check `trend_context.pre_period_healthy`. If `false`, the pre window was
already below the preceding 60-day trend — Shapley understates the true change,
and the investigation start point should be treated as earlier than pre_start.

**Step 3b — Check the LY overlay (`trend_context.ly_delta_cvr`).**

Compare `current_delta_cvr` to `ly_delta_cvr`:

- If LY shows a similar delta at the same calendar position, the drop is
  consistent with a seasonal pattern. Before treating it as a new incident,
  ask: is `structural_delta_cvr` (current minus LY) large enough to warrant
  investigation? A −3pp drop where LY also showed −2.5pp has only −0.5pp of
  structural change. Calibrate investigation depth accordingly.
- If LY shows flat or positive CVR at the same position, the entire drop is
  structural. No seasonal explanation applies — investigate fully.
- If LY data is unavailable (`trend_context.available` is false), note this
  and proceed without seasonal context.

**Step 3c — Weekday composition check.**

A post period with more weekends than the pre period can produce an apparent
CVR drop with no real change. Check whether the weekday mix differs before
concluding anything about magnitude.

**The answer to Q3 determines what you look for:** sudden → find what changed
on that date; gradual → find what is eroding; seasonal → quantify structural
delta and depth-calibrate accordingly.

---

### Form hypotheses, then query to test them

After answering the three mandatory questions, **consult `hypothesis.md`** for
historical patterns from 21 Headout RCAs. Use it to orient your thinking — not
to constrain it. If the data points to a mechanism not listed there, follow the
data. The patterns in that file are starting points ranked by historical
frequency; they exist to help you not miss the obvious before chasing the
unusual.

Then **write down 2–4 specific, falsifiable hypotheses** based on what you
actually observe, before touching another query. These should be mechanisms, not
observations:

- *Observation* (bad): "S2C dropped on mobile"
- *Hypothesis* (good): "The Apr 8 mobile deploy broke date-picker rendering on iOS,
  causing users to see no available slots and abandon the select page"

Each hypothesis should name a cause, a segment or experience it would affect, and
a date or pattern you'd expect to see if it were true. Then test each one directly
with a targeted BQ query.

`summary.json` gives you the orientation — the direction, the magnitude, the
primary step. It does not complete the investigation. The investigation is the
querying you do after reading it.

---

### Writing and running custom queries

Custom queries are the **primary investigation tool** from this point forward.
The prebuilt pipeline (Q0–Q6) covered the standard cuts. Everything beyond it —
any hypothesis you formed, any cross-dimensional angle, any dimension the pipeline
didn't compute — needs a query you write.

Full table schemas, column names, and query rules are in `context.md`. The rules
that matter in every query:

- Always `COUNT(DISTINCT user_id)` for traffic. The grain is one row per user ×
  session × page; the same user generates multiple rows. Never `COUNT(*)` for people.
- Never sum user counts across dimension cuts. A user who appears in `language = 'French'`
  and `page_type = 'Collection'` is one person in both cuts. Each dimension needs
  its own `COUNT(DISTINCT user_id)` subquery.
- `experience_id` is NULL for LP-level rows. Experience-level queries must filter
  to rows where `has_select_page_viewed = TRUE`.
- Always filter `advertising_channel_type != 'PERFORMANCE_MAX'`.
- `combined_entity_id` is already a STRING — filter with `combined_entity_id = '<ce_id>'`
  (no CAST needed).

**Majority-contributor principle — applies to every entity type.**
When evaluating any URL, TGID, language, device, country, or other dimension value
as a contributor to the overall drop, focus on entities that collectively account
for the majority of CE traffic on the affected metric. Entities in the long tail
produce high-variance rate estimates that are likely noise. A 40% S2C drop on
25 users is not evidence; a 5% S2C drop on 3,000 users is. Before citing any
entity as a driver, ask: does this entity represent a meaningful share of CE
traffic, or is it so small that a few bookings going differently would reverse
the finding? The threshold adapts to the CE — what matters is relative share,
not an absolute user count.

**Rate × volume before declaring a primary driver.**
A rate delta is not impact. When two segments show different rate changes —
one large on a small segment, one small on a large segment — always compute
the absolute checkout or order loss from each before concluding which drives
the overall drop. Impact = rate change × volume of users exposed to that rate.
"Segment A has a much bigger rate drop" and "segment A drives the overall CVR
drop" are not the same claim and can point in opposite directions when volume
is lopsided. State both the rate delta and the absolute impact when reporting
a segment finding.

Run custom queries with:
```bash
bq query --use_legacy_sql=false --format=json --quiet \
  --project_id=headout-analytics \
  <<'SQL'
  ... your query ...
SQL
```

Read the JSON output directly and incorporate the finding into your analysis. Log
each query in the transcript with the hypothesis it was testing and what you found.

---

### Dimensions to explore — beyond the prebuilt pipeline

The pipeline computed device, language, and page_type. These are starting points.
The following dimensions are available in the funnel table and are worth querying
when your hypothesis points there:

**`browsing_country` / `browsing_city`** — Is the drop geographically concentrated?
A CVR drop that is entirely in one market (e.g., United Kingdom) points to
geo-specific pricing, a campaign pause, or a local supply issue, not a
platform-wide problem.

**`channel_name`** (granular, not just Paid/Organic) — Is it specifically Google
Ads, or Affiliates, or a specific CRM campaign? A drop concentrated in one channel
often traces to a campaign quality or budget change rather than a product problem.

**`lead_time_days`** — Did the distribution of booking lead times shift? A sudden
scarcity of near-term availability pushes users toward longer lead times; if those
users convert worse, S2C drops even if the product hasn't changed. Compare the
pre/post lead time distribution for users who reached checkout.

**`page_sub_type`** — For MB microsite traffic, `page_sub_type` distinguishes
specific microsite page variants. A drop concentrated in one sub-type isolates
the issue to that page template.

**`previous_page_url`** — Where were users coming from before the session started?
A sudden traffic source change (new referrer, different campaign landing page)
can change the intent profile of users before they even hit the CE.

**Cross-dimensional cuts** — When two dimensions both show a signal, the actual
root cause may be at their intersection. If device shows a mobile drop AND language
shows a French drop, the real number to look at is French × iOS — it may be 10×
larger than either dimension alone. Always test the intersection before concluding
the causes are independent.

**Experience-level with availability proxy** — For S2C hypotheses, join
`product_rankings_features` on `experience_id` + `event_date` to get
`count_days_available_30d` per experience per day. A drop in availability that
coincides with the S2C drop timing is a strong supply signal.

---

### Common investigation patterns

These are not rails — they are the directions the evidence typically points. Start
here, but follow what the data actually shows.

**If mix is the primary explanation:**

Run a query: `COUNT(DISTINCT user_id)` by `page_url` pre vs post for the affected
segment (MB or the channel that shifted). Which URLs gained or lost volume? If a
paid campaign was serving specific collection pages in the pre period and stopped,
those pages will show a sharp traffic drop. That is the finding. Marketing owns it.

**If LP2S is the primary driver:**

LP2S is about whether users landing on the listing page click through to the
select page. Start with trend timing (Question 3), then form hypotheses.

Common angles to query:
- Device × LP2S rate pre/post — mobile-concentrated drops point to a UI/performance change
- Language × LP2S rate — a single language dropping points to geo-specific pricing or a localized UX issue
- Page_type × LP2S rate — a drop in Collection but not Experience pages points to browse-level friction
- Price check: if `price_analysis.available` is true, check whether listed prices increased and
  whether the timing coincides with the LP2S drop
- URL-level: which specific pages drove the drop? A drop concentrated on 2–3 URLs is
  more actionable than a broad CE-wide decline

When a dimension shows a concentrated signal, run the cross-cut to confirm the
intersection, then drill to URL-level within that segment.

**If S2C is the primary driver:**

S2C is about whether users on the select/date-picker page proceed to checkout.

Common angles to query:
- Experience-level S2C from `experiences.S2C` — a concentrated drop in one or two
  experiences points to a supply or pricing issue specific to those products
- Availability from `product_rankings_features`: `count_days_available_30d` pre/post
  per experience — a meaningful drop in available days correlates with S2C drops
- Lead time distribution: did the post period skew toward shorter lead times (less
  available inventory)?
- If broad across experiences and sudden in trend: think checkout flow or
  availability configuration change

**If C2O is the primary driver:**

Check `c2o_sub` first. C2O = C2A × A2O. These point to completely different causes:
- C2A drop → users abandoned before submitting payment: checkout UX friction, price
  display in checkout, coupon code breakage, trust signal missing. DRI: Product.
- A2O drop → users submitted payment but order failed: payment gateway issue, fraud
  rule tightening, card decline rate increase. DRI: Payments.

Knowing which sub-metric moved determines who needs to act and what to query next.

---

### Mixpanel session recordings

Once the investigation has identified a specific locus — a particular URL,
experience (TGID), device type, page type, or cross-cut of these — pull session
recordings using the Mixpanel MCP (`Get-User-Replays-Data`). Any concentrated
dimension cut is sufficient to trigger this step; you do not need all three
(URL + experience + segment) confirmed simultaneously. Pass the CE ID, the
post-period date range, and whichever dimension defines the locus: the page URL
if the drop is URL-concentrated, the experience ID if it is TGID-concentrated,
the device type if mobile is the outlier, and so on.

This is a required step once the locus is confirmed, not an optional one —
recordings move a finding from "consistent with" to "directly observed."

You are looking for patterns in what users actually experienced: an empty
availability calendar, a broken date picker, a slow page load, a confusing
layout. Use what you observe as direct evidence in the root cause callout. It
turns "S2C dropped on the Paris river cruise select page" into "users
consistently encountered an empty date picker on the Paris river cruise select
page after Apr 8, likely because availability for that period was not loaded."

If recordings are skipped, the report must explicitly state why (e.g. volume
too low to return results, or no concentrated locus was identified).
Skipping without explanation is not acceptable once a locus has been confirmed.

Do not fish for problems with recordings when no locus has been identified yet.
Recordings are most valuable as confirmation, not discovery.

---

## Step 3 — Write the report

The report structure and visual spec are defined in `report_structure.md`
(already read above). Follow it exactly.

**Write HTML directly.** There is no `report_spec.json` step and no `render.py`
call. `report_structure.md` contains the full CSS, every component pattern, and
the exact HTML structure for each element. Copy the shared `<style>` block from
that file into every report's `<head>` — this is what ensures visual consistency
across all reports.

The three-section macro-structure — Executive Summary → Actions → Supporting
Analysis — is fixed. Content within each section adapts to the investigation.

Write the output file to: `/tmp/cvr_rca_<ce_id>/report.html`

**Plotly charts:** embed the CDN in `<head>` and write figure specs inline as
`<script>` blocks at the bottom of `<body>`. Pre-period color: `#6c8ebf` (blue).
Post-period color: `#c62828` (red). Add dashed mean reference lines and
annotations for pre/post averages directly on the chart.

---

## Step 4 — Evaluate the analysis

Run this after the report is written. Read the rubric first:

```bash
cat "$SKILL_DIR/evals/evaluator.md"
```

The rubric covers 7 themes. To evaluate, re-read:
1. The HTML report you just wrote — as if you've never seen this CE before
2. Your investigation reasoning — what you looked at, why, and what you decided at each fork
3. The `summary.json` — to verify claims in the report against actual numbers

Score each theme 1–5 with a specific justification citing actual report content.
Write the evaluation to a persistent file:

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
[3–4 sentences. What did this RCA get right? What was the main failure mode?
What would a senior analyst say after reading the report?]

## Theme scores

### 1. Narrative Coherence — [score]/5
[Justification citing specific report content. Improvement if ≤ 3.]

### 2. Hypothesis Specificity & Quality — [score]/5
[Were hypotheses mechanisms or symptoms? Cite the actual root cause statement.
Improvement if ≤ 3.]

### 3. Investigation Effort & Adaptivity — [score]/5
[Did depth match what the data warranted? Were custom queries written when needed?
Did it stop when conclusive? Improvement if ≤ 3.]

### 4. Branch Decision Quality — [score]/5
[Were the right forks taken? Was mix checked before funnel? Were alternatives
ruled out explicitly? Improvement if ≤ 3.]

### 5. Evidence Strength — [score]/5
[Are callouts tied to specific numbers, dates, URLs? Were confidence qualifiers
appropriate? Improvement if ≤ 3.]

### 6. Output Appropriateness — [score]/5
[Is the report shaped by the story or by a template? Right visuals for the
finding type? Proportional length? Improvement if ≤ 3.]

### 7. DRI & Actionability — [score]/5
[Could the DRI act on the action card alone? Are action items testable?
Improvement if ≤ 3.]

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

---

## Worked example — how an investigation unfolds

This is not a template. It is an example of what good analytical reasoning looks
like in practice.

**The situation:** CVR for a CE dropped. You run the baseline queries and read
`summary.json`.

---

**Q1: Routing or conversion?**

`mix_dominance` shows MB traffic share grew from 43% to 52% in the post period.
MB CVR is stable. HO CVR is stable. Mix effect explains 58% of total ΔCVR. No
funnel step shows a change larger than 2pp.

*This is a routing story, not a funnel story.* You do not open a Shapley deep-dive.
You ask: why did MB traffic share grow?

You write a custom query: `COUNT(DISTINCT user_id)` by `page_url` for MB sessions,
pre vs post. Two collection-page URLs show a 40% traffic drop. Everything else held.

Those two URLs were receiving paid search traffic in the pre period. In the post
period they were not. The CVR drop is an artefact of a paid campaign that stopped
sending HO-quality traffic to these MB pages, increasing MB's share of organic
(lower-CVR) sessions.

*The report covers:* CVR change card, mix table with the routing finding called
out, URL traffic comparison for those two pages, action card to Marketing to
investigate the campaign change. Four sections total. No dimension cuts. No
experience breakdown. No Shapley waterfall — Shapley would be misleading here
because the steps themselves did not break.

---

**Alternate path: conversion is dominant.**

`mix_dominance.is_dominant` is false. Shapley shows S2C carries 68% of ΔCVR.
LP2S and C2O are small. S2C is the story.

Daily trend: S2C was stable through the pre period, dropped sharply on Apr 8,
and stayed low through the post period. Single-day onset.

*Something changed on Apr 8 affecting S2C.* You look at device and language cuts
for S2C. Device: iOS Mweb shows −4.1pp, Android −2.1pp, Desktop −0.3pp. Mobile
is disproportionately affected. Language: French shows −6pp, English −1.5pp,
Spanish −0.8pp. French is the outlier.

*Two concentrated signals: mobile and French.* You run a custom query: S2C rate
by `page_url` filtered to `language = 'French'` and `device_type LIKE '%Mweb%'`.
One experience's select page shows S2C falling from 19% to 4% in that cut.

You pull Mixpanel session recordings for that URL × French × post period. Users
consistently see an empty date picker — no available dates are loading for the
French locale on that experience.

*The report covers:* CVR verdict (supply/localization issue on one experience's
date-picker for French mobile users), mix ruling-out, Shapley, S2C daily trend,
S2C device + language cuts, URL-level finding for that experience, one session
recording observation as qualitative color, action cards for Supply (check
availability configuration) and Product (check French locale date-picker rendering).

The LP2S and C2O sections do not appear. They were not the story.

---

## Evaluation

The quality rubric lives in `evals/evaluator.md`. It covers 7 themes:
Narrative Coherence · Hypothesis Specificity · Investigation Effort · Branch Decision Quality · Evidence Strength · Output Appropriateness · DRI & Actionability.

Step 4 runs the evaluator automatically after every report. Saved evaluations accumulate in `~/Documents/RCA skill/evals/` — each named `ce<id>_<post_start>.md`. Review them across runs to track where the RCA quality is improving and where it consistently falls short.

When enough real runs have accumulated, compare scores across CEs and time periods to identify systematic weaknesses in the investigation logic worth addressing in the skill itself.

---

## Backlogs

**Under development (shown as banners in the report):**
- Availability correlation with S2C — correlate S2C drops with Hub inventory slot
  availability for the same period
- Inventory level check at C2O — correlate C2A abandonment with availability
  constraints at checkout

**Parked for later:**
- LY baseline comparison / structural delta
- Payment gateway error breakdown for A2O (`order_attempted_events_v2`: `payment_gateway`, `payment_method`, `fraud_evaluation_result_origin`, `failure_reason`)
- LP2S price vs LY baseline
- Bootstrap confidence intervals on Shapley values

---

## Changelog

| # | Date | Changes |
|---|------|---------|
| c001 | 2026-04-24 | Initial version — investigation framework, 3 mandatory questions, Shapley, mix decomp, custom query patterns, render.py integration, Step 4 evaluator |
| c002 | 2026-04-24 | Added `report_structure.md` to "Before you begin" reads; updated file role descriptions to be distinct and non-overlapping; updated hypothesis.md reference to clarify it is a reference for historical priors, not a constraint on hypothesis generation; replaced Step 3 report structure guidance with pointer to `report_structure.md`; updated Backlogs to note A2O query columns |
| c003 | 2026-04-24 | Added majority-contributor principle to query rules (focus on high-volume entities; long-tail rate drops are noise); added rate × volume rule to query rules (absolute impact must be computed before declaring a segment the primary driver); reframed session recordings as a required step once a locus is confirmed rather than optional qualitative color; added explicit requirement to state why recordings were skipped if they were |
| c004 | 2026-04-24 | Fixed session recordings trigger to be disjunctive — any concentrated dimension cut (URL, TGID, device type, page type, or cross-cut) is sufficient; corrected tool call to pass the dimension that defines the locus, not always a page URL; added "Data pull errors — log and continue" section: log failure in transcript, add ⚠️ inline note in report, continue analysis, adjust confidence language if the missing data was material |
| c005 | 2026-04-24 | Replaced sidebar-nav report template with single-column dark-header design (templates/report.html); added `session_recordings_table` component to render.py — session recordings must now use this component instead of prose callouts; added P1/P2/P3 priority badges to action cards; updated Step 3 in SKILL.md and report_structure.md to document new visual standard and recordings table format |
