# CVR-RCA Report Structure

Read this file before writing the HTML report (Step 3 of the skill). It defines:
1. The fixed three-section macro-structure every report must follow
2. The exact visual spec (CSS, component HTML patterns) to paste into every report

**The principle:** By the time the GM finishes reading Section 2, they know exactly what happened and what to do. Section 3 is for anyone who needs to verify the conclusion. The analysis is not the report — the analysis is the evidence behind the report.

---

## Section 1 — Executive Summary

**Purpose:** The GM reads this in under 60 seconds and understands the full picture. Nothing in this section requires interpretation.

### 1a. Metric cards (always — all five)

Five cards in this order: **CVR · LP2S · S2C · C2O · Traffic (users_lp)**

Each card shows: pre value (grey, smaller), post value (large bold), delta badge on its own line.
Delta format: `Δ −0.33pp / −7.0%` — absolute pp change and percentage change together.
Badge color: `delta-neg` (red) for drops, `delta-pos` (green) for gains, `delta-flat` (grey) for near-zero.

These cards are orientation, not conclusion. The conclusion comes in 1b.

### 1b. 90-day CVR trend chart (always)

Place this immediately after the metric cards, before the callout. It gives the reader instant seasonal and structural context before they read the finding — whether CVR improved or declined, they can see the shape of the trend and the LY comparison at a glance.

See the 90-day chart spec in the Plotly section below.

**Section 1 hard constraint:** no other charts or tables in this section — only the metric cards, the 90-day chart, and the callout.

### 1c. Root cause callout (always)

One callout box — the most important element in the entire report. It answers three questions, each as a `.callout-item` with a `.q` label (uppercase grey, 11px) and an `.a` answer (15px, dark, 1–3 sentences).

**When CVR declined:** Red left border (`#e53935`), heading "Root Cause". Three questions:

- **What broke?** Name the specific thing that failed — not just a metric name.
  - ❌ "LP2S declined"
  - ✅ "S2C fell from 25.6% to 24.2%, concentrated almost entirely in the HO segment — where S2C collapsed from 35.7% to 23.4% on 21% more select-page visitors"
- **Why did it break?** The mechanism — what it means, not what the data shows.
- **When did it break?** Exact date (sudden) or window (gradual).

**When CVR improved:** Green left border (`#2e7d32`), heading "CVR Improved — What's Driving It & What's Holding It Back". Three questions:

- **What drove the improvement?** Lead with the positive driver — which step improved, by how much, and the mechanism (seasonal uplift, paid mix growth, supply improvement, etc.). Include the structural delta vs LY: a large seasonal improvement with only +0.09pp structural delta reads very differently from +0.5pp structural gain.
- **What's holding it back?** Name any step that declined despite overall CVR being up. Quantify both the rate drop and the checkout impact. If CVR improved across all steps, write "No significant headwinds — all funnel steps improved."
- **When did the headwind emerge?** (or "When did improvement begin?" if no headwind). Timing classification as for the decline case.

**If multiple root causes confirmed:** callout names the primary driver. Secondary findings get action cards in Section 2.

**On uncertainty:** If the evidence strongly points to a mechanism but doesn't fully confirm it, say "consistent with X" — but still commit to the most actionable explanation. Do not hedge into "multiple possible factors."

**Section 1 hard constraints:**
- No tables or Shapley visualizations in this section (90-day chart is the only chart)
- No hedging language ("possibly", "may be related to", "could be")

---

## Section 2 — Actions

**Purpose:** Immediately follows Section 1. A GM who reads only Sections 1 and 2 should be able to forward the relevant action card directly to the DRI.

### Structure of each action card

One card per confirmed root cause:
- **Priority badge** — P1 / P2 / P3 pill (red/amber/green), top-left of header row
- **Cause line** — 15px bold, the finding in one sentence (same precision as callout)
- **DRI row** — `dri-badge` pill (blue-grey) + secondary team text
- **Action bullet list** — specific, named steps (not generic template text). Name the experience, date, or URL where known.

### Limits and ordering

- Maximum 3 action cards, ranked P1 first
- If more than 3 distinct causes, top 3 get full cards. Additional findings get a one-paragraph summary at the start of Section 3 under "Additional findings"
- If only one root cause, one card is correct. Do not pad with unconfirmed hypotheses
- No card saying "monitor the situation" or "investigate further"

### DRI naming standard

Specific enough to forward directly:
- ❌ "Supply team — investigate availability"
- ✅ "Supply team — check availability configuration for Keukenhof Entry Tickets (TGID 10118) for dates Apr 20 – May 11; API cut-off period may be restricting inventory the SP has available"

---

## Section 3 — Supporting Analysis

**Purpose:** Evidence that the conclusions in Sections 1–2 are correct. A reader who doubts the conclusion reads this to verify it.

### Opening rule for every analysis block

Every analysis block opens with a **verdict line** — a colored inline callout (red for a finding, neutral blue for a ruled-out result) — before showing any chart or table. The verdict states what the evidence confirms or rules out, not what the chart shows.

- ✅ Red verdict: "HO S2C collapsed −12.3pp. MB S2C held flat (−0.6pp). The drop is entirely in the headout.com segment."
- ✅ Neutral verdict: "Mix ruled out — both MB and HO show conversion-dominant effects. Traffic share held stable."
- ❌ "The following table shows S2C by distribution channel:" (describes the chart, not the finding)

### Subtext paragraphs

After a table or chart, add a grey `<p>` (13px, `#555`) that explains the **interpretive meaning** — not what the table shows, but what it implies. This is where the investigative reasoning lives.

Example after the lead-time chart:
> "From Apr 13–19, dates 15+ days out = April 28 and beyond — including the April 26 Flower Parade weekend. Dates in this range appear sold through. Users who had planned trips for those dates abandoned the funnel; those who could visit near-term still booked, causing the 0–3 day bucket to surge."

### What belongs in Section 3

Include only analyses that directly support or rule out a claim made in Sections 1–2:

| Analysis | When to include |
|---|---|
| Shapley decomposition | Always — establishes which funnel step drove ΔCVR and by how much. Use the proportional flex bar (see visual spec), not a Plotly waterfall. |
| Mix cascade (three levels) | Always — MB/HO → paid/organic → channel breakdown. Opens with a Fixed Segment banner declaring the filters applied to all subsequent analysis. See Fixed Segment banner spec below. |
| Daily S2C/LP2S/C2O trend chart | Always — establishes sudden vs gradual onset. All trend charts filtered to the fixed segment. Pre: blue `#6c8ebf`, Post: red `#c62828`. |
| Dimension cut (device / language / page_type) | Only if it produced a concentrated signal OR is being explicitly ruled out. |
| Channel/segment breakdown table | When the drop is concentrated in HO vs MB or a specific channel. |
| Experience-level breakdown | When drop is concentrated in specific experiences. |
| URL-level breakdown | When drop is concentrated in specific page URLs. |
| Lead-time distribution | When availability scarcity is the hypothesis — compare pre/post booking bucket distribution. |
| Inventory TID summary table | When S2C drop is confirmed at a specific TGID — one row per TID, columns: TID · TID Name · Tickets 0–2d · Tickets 3–7d · Tickets 8–13d · Tickets 14–30d. Snapshot from the latest available `extracted_date`. |
| Inventory daily time-series charts | When the TID summary table shows depleted buckets — four line charts (one per lead-time bucket), `extracted_date` on x-axis, total tickets on y-axis. Path B: pre and post as overlaid series. Path A: post series only with a note that pre-period data is unavailable. |
| Price analysis | When price changed and timing correlates with LP2S onset. |
| Session recordings | When recordings were pulled — present as a structured table (see below). |

### Inventory section format

Present as a `.analysis-block` within the S2C evidence section, immediately after the experience-level S2C breakdown confirms the TGID locus.

**Verdict line — two patterns, two forms:**

- **Window-specific drop** (one bucket near zero, others hold):
  - ✅ "Ticket counts in the 8–13 day window for Experience 8821 fell to zero in the post period — the 0–7 day and 14–30 day buckets were unaffected. Points to a window-specific supply constraint."
  - Highlight zero or near-zero bucket rows in the TID summary table with `.highlight-row`.

- **Uniform decline** (all buckets dropped together):
  - ✅ "Ticket counts fell across all lead-time windows for Experience 8821 — no single window is uniquely affected. Consistent with a platform-wide or full-product supply reduction."
  - No `.highlight-row` — the finding is product-wide, not bucket-specific.

- ❌ "The following table shows inventory by lead time." (describes data, not finding)

**Supply gate outcome:** If the time-series confirms tickets were healthy throughout the post period for all limited-capacity TIDs, open the inventory block with the ruled-out verdict: *"Supply checked and ruled out — all limited-capacity TIDs had available tickets throughout the post period. Supply is not the mechanism for this S2C drop."* You may still show the line charts as positive confirmation (lines staying well above zero is visual proof, not just a claim). Do not show the TID snapshot table in this case — it adds no signal beyond the verdict. Move directly to pricing or UX after the inventory block.

**TID summary table — Path B** (pre within 30-day window): One row per TID. Columns: TID · TID Name · Pre tickets 0–2d · Post tickets 0–2d · Pre tickets 3–7d · Post tickets 3–7d · Pre tickets 8–13d · Post tickets 8–13d · Pre tickets 14–30d · Post tickets 14–30d. Where pre-to-post change in a bucket is the material drop, highlight that bucket pair with `.highlight-row`. Append a column `Capacity type` showing `Limited` or `Unlimited` (derived from `is_fully_unlimited_capacity`). Omit unlimited-capacity TIDs from the supply scarcity finding — note them in the subtext as "excluded from supply analysis (unlimited capacity)."

**TID summary table — Path A** (pre outside 30-day window): Same structure but post-only columns (no pre). Add a block-level note above the table: *"Pre-period inventory data unavailable — pre period is more than 30 days ago. Current-state snapshot shown."*

**Daily time-series charts:** Four charts, one per lead-time bucket. x-axis: `extracted_date`. y-axis: total tickets (scoped to one TID if Step 2 identified a single locus; TGID aggregate if all TIDs depleted equally). For Path B: two overlaid series — pre (blue) and post (red), aligned by day-of-period so the shapes are directly comparable. For Path A: post series only.

**Subtext paragraph:** State the pattern and when it started, and what the supply team should check. Do not assert the mechanism — the data shows *where* and *when*, not *why*. Write: "The [bucket] bucket dropped from [X] to [Y] tickets starting around [date] — the other buckets were unaffected. Supply team should verify whether the cut-off period setting or allotment was changed around that date for TID [id]." Never write "this was caused by [specific mechanism]" without corroborating evidence from the supply team.

**Path B — pre period within 30-day window (pre/post comparison available):**

```html
<!-- One row per TID from Step 2 query results.
     Apply highlight-row to TIDs where the affected bucket pair shows the material drop.
     Remove highlight-row entirely if the pattern is uniform across all buckets (no single window is uniquely affected).
     Omit rows where is_fully_unlimited_capacity = TRUE from the table body; list them in the subtext note instead. -->
<div class="analysis-block">
  <div class="block-title">Inventory by lead-time bucket — [Experience name]</div>
  <div class="verdict-line">[State the actual pattern — window-specific or uniform decline — using the correct verdict form from the spec above]</div>

  <table>
    <thead>
      <tr>
        <th>TID</th>
        <th>TID Name</th>
        <th class="num">Pre 0–2d</th>
        <th class="num">Post 0–2d</th>
        <th class="num">Pre 3–7d</th>
        <th class="num">Post 3–7d</th>
        <th class="num">Pre 8–13d</th>
        <th class="num">Post 8–13d</th>
        <th class="num">Pre 14–30d</th>
        <th class="num">Post 14–30d</th>
        <th>Capacity type</th>
      </tr>
    </thead>
    <tbody>
      <!-- highlight-row on TIDs where the affected bucket pair is near zero in post -->
      <tr class="highlight-row">
        <td>[tour_id]</td>
        <td>[tour_name]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td>Limited</td>
      </tr>
      <tr>
        <td>[tour_id]</td>
        <td>[tour_name]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td>Limited</td>
      </tr>
    </tbody>
  </table>

  <p style="font-size:13px;color:#555;margin-top:12px;">
    [Describe the pattern — which bucket pair dropped, when it started, which TIDs are affected.
     State what the supply team should check. Do not assert a mechanism — the table shows where and when, not why.
     If any TIDs were excluded: "TID [id] ([name]) excluded from supply analysis — unlimited capacity."]
  </p>
</div>
```

**Path A — pre period outside 30-day window (post-only snapshot):**

```html
<!-- Pre-period data unavailable — show post-only columns.
     Same row-per-TID structure; omit all Pre columns.
     Add the block-level note above the table as shown. -->
<div class="analysis-block">
  <div class="block-title">Inventory by lead-time bucket — [Experience name]</div>
  <div class="verdict-line">[State the actual pattern using the correct verdict form from the spec above]</div>

  <p style="font-size:13px;color:#e07b00;margin-bottom:10px;">
    Pre-period inventory data unavailable — pre period is more than 30 days ago. Current-state snapshot shown.
  </p>

  <table>
    <thead>
      <tr>
        <th>TID</th>
        <th>TID Name</th>
        <th class="num">Tickets 0–2d</th>
        <th class="num">Tickets 3–7d</th>
        <th class="num">Tickets 8–13d</th>
        <th class="num">Tickets 14–30d</th>
        <th>Capacity type</th>
      </tr>
    </thead>
    <tbody>
      <tr class="highlight-row">
        <td>[tour_id]</td>
        <td>[tour_name]</td>
        <td class="num">[n]</td>
        <td class="num">[n]</td>
        <td class="num">[n]</td>
        <td class="num">[n]</td>
        <td>Limited</td>
      </tr>
      <tr>
        <td>[tour_id]</td>
        <td>[tour_name]</td>
        <td class="num">[n]</td>
        <td class="num">[n]</td>
        <td class="num">[n]</td>
        <td class="num">[n]</td>
        <td>Limited</td>
      </tr>
    </tbody>
  </table>

  <p style="font-size:13px;color:#555;margin-top:12px;">
    [Describe which buckets show near-zero tickets and what the supply team should verify.
     If any TIDs were excluded: "TID [id] ([name]) excluded from supply analysis — unlimited capacity."]
  </p>
</div>
```

### Session recordings format

Present as a `.analysis-block` with the locus described in the verdict line, then a table with columns: Recording | Steps observed | Inference. Each recording gets one row. The inference column (one sentence) states what the recording proves or rules out.

**Anti-pattern:** Writing session recording evidence as a multi-paragraph text block. The table forces structured thinking and makes the inference scannable.

### Ruled-out dimensions section

Collect dimensions that were checked and found uninformative into a single `.analysis-block` at the end of Section 3, titled "Dimensions Checked — ruled out as independent drivers". Use a `<p>` intro sentence, then a `<ul>` with one `<li>` per dimension, each naming what moved and why it is not an independent driver.

Example:
> **Device:** Desktop S2C −2.5pp, iOS Mweb +0.7pp. Desktop drop is consistent with HO users being predominantly desktop (paid search). No evidence of a mobile UX regression.

Do not show separate tables for dimensions that produced no signal. The ruled-out block is the right home for those findings.

### What does NOT belong in Section 3

- Analyses that produced no signal — if all devices moved equally, no device cut appears anywhere
- "For completeness" tables — every element answers a question raised by something above it
- Metrics that didn't move
- Repeated information from Section 1
- Shapley visualization in a mix-dominant finding (the steps didn't break)

---

## Report length calibration

| Scenario | Expected length |
|---|---|
| Mix-dominant story | Sections 1–2 + mix table + URL traffic comparison. ~4 subsections. No Shapley. |
| Single-step failure, single confirmed mechanism | Sections 1–2 + Shapley + trend + 1–2 cuts + experience or URL table. ~6–8 subsections. |
| Multi-step failure with recording confirmation | Full treatment. Max ~10 subsections. |

---

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Root cause callout says "CVR declined due to multiple factors" | Non-committal — GM doesn't know what happened |
| Actions buried after 6 charts | GM has to read through analysis to find what to do |
| Every analysis run appears in the report | Shows the work, not the conclusion |
| "Investigate further" as an action | Not actionable — the investigation just finished |
| DRI is "Product team" with no specific task | Can't be forwarded |
| Analysis block opens with "The following table shows..." | Describes data, not the finding |
| All dimension cuts present when none showed a concentrated signal | Template-driven, not story-driven |
| Shapley visualization in a mix-dominant finding | The steps didn't break — showing it implies they did |
| Table shows rates/shares with no user counts | Stakeholder can't judge if the finding is substantial — a 10pp drop on 30 users is noise |
| Investigation-internal terminology in the report body (Step 1/2/3, Path A/B, Case A/B/C, "locus", "lost_checkouts_delta", "candidate TGIDs") | These are transcript terms — they mean nothing to a GM or stakeholder. Translate: "the three most-affected experiences" not "the Case B candidate TGIDs"; "supply checked and ruled out" not "Step 3 confirmed supply ruled out". |
| Daily inventory time-series rendered as an HTML table | A 27-row × 4-column date table is unreadable at a glance. The daily time-series is always Plotly line charts. The only table in the inventory section is the TID snapshot summary. |

---

## Visual Spec — HTML patterns

**Every report is written as self-contained HTML.** There is no render.py and no component library. Copy the shared `<style>` block below into every report's `<head>` and write each section using the HTML patterns below.

### Shared `<style>` block — copy into every report's `<head>`

```html
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background: #f5f6fa;
    color: #1a1a2e;
    line-height: 1.55;
  }

  header {
    background: #1a1a2e;
    color: #fff;
    padding: 28px 40px 24px;
  }
  header .eyebrow {
    font-size: 11px;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    color: #8892a4;
    margin-bottom: 6px;
  }
  header h1 { font-size: 24px; font-weight: 700; }
  header .meta { margin-top: 8px; font-size: 13px; color: #b0bec5; }
  header .meta span { margin-right: 20px; }

  .container { max-width: 1050px; margin: 0 auto; padding: 0 24px 60px; }

  .section-label {
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: #8892a4;
    margin: 40px 0 16px;
    padding-bottom: 8px;
    border-bottom: 1px solid #e0e4ef;
  }

  .metric-cards {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 12px;
    margin-bottom: 24px;
  }
  @media (max-width: 800px) { .metric-cards { grid-template-columns: repeat(3, 1fr); } }
  .metric-card {
    background: #fff;
    border-radius: 10px;
    padding: 18px 16px 16px;
    border: 1px solid #e8ebf4;
  }
  .metric-card .label {
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.8px;
    text-transform: uppercase;
    color: #8892a4;
    margin-bottom: 8px;
  }
  .metric-card .values { display: flex; align-items: baseline; gap: 8px; }
  .metric-card .pre  { font-size: 14px; color: #8892a4; }
  .metric-card .post { font-size: 22px; font-weight: 700; color: #1a1a2e; }
  .metric-card .delta {
    font-size: 12px;
    font-weight: 600;
    padding: 2px 7px;
    border-radius: 12px;
    margin-top: 6px;
    display: inline-block;
  }
  .delta-neg  { background: #fdecea; color: #c62828; }
  .delta-pos  { background: #e8f5e9; color: #2e7d32; }
  .delta-flat { background: #f3f4f6; color: #555; }

  .callout {
    background: #fff;
    border-left: 4px solid #e53935;
    border-radius: 0 10px 10px 0;
    padding: 24px 28px;
    margin-bottom: 8px;
    border-top: 1px solid #e8ebf4;
    border-right: 1px solid #e8ebf4;
    border-bottom: 1px solid #e8ebf4;
  }
  .callout h2 { font-size: 16px; font-weight: 700; color: #c62828; margin-bottom: 16px; letter-spacing: 0.2px; }
  .callout-item { margin-bottom: 14px; }
  .callout-item:last-child { margin-bottom: 0; }
  .callout-item .q {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: #8892a4;
    margin-bottom: 4px;
  }
  .callout-item .a { font-size: 15px; color: #1a1a2e; font-weight: 500; }

  .action-card {
    background: #fff;
    border-radius: 10px;
    border: 1px solid #e8ebf4;
    padding: 24px 28px;
    margin-bottom: 16px;
  }
  .action-card .ac-header { display: flex; align-items: flex-start; gap: 12px; margin-bottom: 16px; }
  .priority-badge {
    font-size: 11px;
    font-weight: 700;
    padding: 3px 10px;
    border-radius: 12px;
    white-space: nowrap;
    flex-shrink: 0;
    margin-top: 2px;
  }
  .p1 { background: #fdecea; color: #c62828; }
  .p2 { background: #fff8e1; color: #f57c00; }
  .p3 { background: #e8f5e9; color: #2e7d32; }
  .action-card .cause { font-size: 15px; font-weight: 600; color: #1a1a2e; }
  .action-card .dri-row {
    font-size: 13px;
    color: #555;
    margin-bottom: 16px;
    display: flex;
    gap: 6px;
    align-items: center;
  }
  .dri-badge {
    background: #e8edf7;
    color: #3a4a8a;
    font-weight: 600;
    font-size: 12px;
    padding: 2px 9px;
    border-radius: 8px;
  }
  .action-card ul { padding-left: 18px; font-size: 14px; color: #333; }
  .action-card ul li { margin-bottom: 7px; }

  .analysis-block {
    background: #fff;
    border-radius: 10px;
    border: 1px solid #e8ebf4;
    padding: 24px 28px;
    margin-bottom: 20px;
  }
  .analysis-block .block-title { font-size: 14px; font-weight: 700; color: #1a1a2e; margin-bottom: 6px; }

  .verdict-line {
    font-size: 14px;
    font-weight: 600;
    color: #c62828;
    background: #fdecea;
    border-radius: 6px;
    padding: 8px 14px;
    margin-bottom: 18px;
  }
  .verdict-line.neutral { color: #3a4a8a; background: #e8edf7; }

  table { width: 100%; border-collapse: collapse; font-size: 13px; }
  th {
    text-align: left;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.7px;
    text-transform: uppercase;
    color: #8892a4;
    padding: 8px 12px;
    border-bottom: 2px solid #e8ebf4;
  }
  td { padding: 9px 12px; border-bottom: 1px solid #f0f2f8; color: #1a1a2e; }
  tr:last-child td { border-bottom: none; }
  tr:hover td { background: #f8f9ff; }
  .num { text-align: right; font-variant-numeric: tabular-nums; }
  .neg { color: #c62828; font-weight: 600; }
  .pos { color: #2e7d32; font-weight: 600; }
  .highlight-row td { background: #fff8f8 !important; }

  .shapley-bars { display: flex; gap: 0; border-radius: 8px; overflow: hidden; height: 32px; margin: 16px 0 8px; }
  .shapley-bar { display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; color: #fff; }
  .shapley-lp2s { background: #6c8ebf; }
  .shapley-s2c  { background: #c62828; }
  .shapley-c2o  { background: #d6a832; }
  .shapley-legend { display: flex; gap: 20px; font-size: 12px; color: #555; }
  .legend-dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 5px; }

  .ruled-out { font-size: 13px; color: #777; font-style: italic; padding: 6px 0 0; }
  .chart-container { margin-top: 16px; }

  footer { text-align: center; font-size: 12px; color: #aaa; padding: 24px; margin-top: 20px; }
</style>
```

---

### Page skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CVR-RCA · [CE Name] (CE [ID])</title>
  <script src="https://cdn.plot.ly/plotly-2.27.0.min.js"></script>
  <!-- paste the shared <style> block here -->
</head>
<body>

<header>
  <div class="eyebrow">CVR Root Cause Analysis</div>
  <h1>[CE Name] — CE [ID]</h1>
  <div class="meta">
    <span>📅 Pre: [pre_start]–[pre_end]</span>
    <span>📅 Post: [post_start]–[post_end]</span>
    <span>🌍 [Market] · [Country]</span>
    <span>🔗 <a href="[top_page_url]" target="_blank" style="color:#b0bec5;text-decoration:underline;">[top_page_url]</a></span>
  </div>
</header>

<div class="container">
  <!-- Section 1, 2, 3 blocks go here -->
</div>

<footer>Generated [date] · CVR-RCA · CE [ID] [CE Name]</footer>

<!-- Plotly chart scripts go here -->
</body>
</html>
```

---

### Section label

```html
<div class="section-label">Section 1 — Executive Summary</div>
```

---

### Metric cards (Section 1a)

```html
<div class="metric-cards">
  <div class="metric-card">
    <div class="label">CVR</div>
    <div class="values">
      <span class="pre">4.67%</span>
      <span class="post">4.34%</span>
    </div>
    <div class="delta delta-neg">Δ −0.33pp / −7.0%</div>
  </div>
  <!-- repeat for LP2S, S2C, C2O, Traffic (LP Users) -->
</div>
```

---

### Root cause callout (Section 1b)

```html
<div class="callout">
  <h2>Root Cause</h2>
  <div class="callout-item">
    <div class="q">What broke?</div>
    <div class="a">[specific finding — named metric, segment, magnitude]</div>
  </div>
  <div class="callout-item">
    <div class="q">Why did it break?</div>
    <div class="a">[mechanism — what it means, not what the data shows]</div>
  </div>
  <div class="callout-item">
    <div class="q">When did it break?</div>
    <div class="a">[exact date or window, sudden or gradual characterization]</div>
  </div>
</div>
```

---

### Action card (Section 2)

```html
<div class="action-card">
  <div class="ac-header">
    <div class="priority-badge p1">P1</div>
    <div class="cause">[one sentence — the specific finding that drives this action]</div>
  </div>
  <div class="dri-row">
    <span class="dri-badge">[Team name]</span>
    <span>+ [secondary team if applicable]</span>
  </div>
  <ul>
    <li>[specific action step with named experience, date, or URL]</li>
    <li>[specific action step]</li>
  </ul>
</div>
```

---

### Analysis block (Section 3 — general pattern)

```html
<div class="analysis-block">
  <div class="block-title">[Block title — what this analysis shows]</div>
  <div class="verdict-line">[One-line finding — red for signal, add class "neutral" for ruled-out]</div>

  <!-- table or chart -->

  <p style="font-size:13px;color:#555;margin-top:12px;">
    [Interpretive subtext — what the data implies, not what it shows]
  </p>
</div>
```

---

### Mix cascade analysis block

Render one `.analysis-block` for the cascade — three sub-tables inside it,
one per level. Each table shows the mix_effect vs conversion_effect arithmetic
explicitly so the reader can verify the routing-vs-conversion decision.

The verdict line states the overall cascade outcome. Each sub-table has its own
one-line finding. Highlight the fixed segment row with `.highlight-row`.

```html
<div class="analysis-block">
  <div class="block-title">Mix Cascade — Routing vs Conversion Determination</div>
  <div class="verdict-line">
    <!-- Use ONE of these: -->
    Conversion change at all levels — no routing story. Fixed segment: [MB/HO] · [Paid/Organic] · [Channel].
    <!-- OR: -->
    Routing story — mix change detected at Level [1/2/3]. [One-line reason.]
  </div>

  <!-- Level 1: MB vs HO -->
  <p style="font-size:12px;font-weight:600;margin:16px 0 6px;">Level 1 — MB vs HO</p>
  <table>
    <thead>
      <tr>
        <th>Segment</th>
        <th class="num">Pre users</th><th class="num">Post users</th>
        <th class="num">Pre share</th><th class="num">Post share</th>
        <th class="num">Pre CVR</th><th class="num">Post CVR</th>
        <th class="num">Mix effect</th><th class="num">Conv. effect</th>
        <th>Verdict</th>
      </tr>
    </thead>
    <tbody>
      <tr class="highlight-row">  <!-- highlight the fixed / dominant segment -->
        <td>[MB / HO]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[±x.xxpp]</td><td class="num">[±x.xxpp]</td>
        <td>Fixed — conversion dominates</td>
      </tr>
      <tr>
        <td>[MB / HO]</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[±x.xxpp]</td><td class="num">[±x.xxpp]</td>
        <td>—</td>
      </tr>
    </tbody>
  </table>

  <!-- Level 2: Paid vs Organic -->
  <p style="font-size:12px;font-weight:600;margin:16px 0 6px;">Level 2 — Paid vs Organic (within [MB/HO])</p>
  <table>
    <thead>
      <tr>
        <th>Segment</th>
        <th class="num">Pre users</th><th class="num">Post users</th>
        <th class="num">Pre share</th><th class="num">Post share</th>
        <th class="num">Pre CVR</th><th class="num">Post CVR</th>
        <th class="num">Mix effect</th><th class="num">Conv. effect</th>
        <th>Verdict</th>
      </tr>
    </thead>
    <tbody>
      <tr class="highlight-row">
        <td>Paid</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[±x.xxpp]</td><td class="num">[±x.xxpp]</td>
        <td>Fixed — conversion dominates</td>
      </tr>
      <tr>
        <td>Organic</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[±x.xxpp]</td><td class="num">[±x.xxpp]</td>
        <td>—</td>
      </tr>
    </tbody>
  </table>

  <!-- Level 3: Channel breakdown within Paid -->
  <p style="font-size:12px;font-weight:600;margin:16px 0 6px;">Level 3 — Channel breakdown within Paid</p>
  <table>
    <thead>
      <tr>
        <th>Channel</th>
        <th class="num">Pre users</th><th class="num">Post users</th>
        <th class="num">Pre share</th><th class="num">Post share</th>
        <th class="num">Pre CVR</th><th class="num">Post CVR</th>
        <th class="num">Mix effect</th><th class="num">Conv. effect</th>
        <th>Verdict</th>
      </tr>
    </thead>
    <tbody>
      <!-- One row per paid channel (Google Ads, Microsoft Ads, Facebook Ads, Affiliates).
           highlight-row on the fixed channel. -->
      <tr class="highlight-row">
        <td>Google Ads</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[±x.xxpp]</td><td class="num">[±x.xxpp]</td>
        <td>Fixed — conversion dominates</td>
      </tr>
      <tr>
        <td>Microsoft Ads</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[±x.xxpp]</td><td class="num">[±x.xxpp]</td>
        <td>—</td>
      </tr>
      <!-- add rows for Facebook Ads, Affiliates as applicable -->
    </tbody>
  </table>

  <p style="font-size:13px;color:#555;margin-top:12px;">
    [One paragraph: what the cascade found, which level fixed which segment,
     and why this is a conversion story (or routing story if applicable).
     Do not repeat the numbers — the tables carry them.]
  </p>
</div>
```

**If the cascade exited at a mix level:** render only the levels up to and
including the exit level. The exit level's verdict cell reads "Mix exit —
routing story". Do not render subsequent levels (they were not run).

---

### Fixed Segment banner

After the mix cascade concludes, declare the fixed segment once at the top of the analysis section — before the Shapley block. This banner tells the reader that all funnel data below is scoped to one coherent cohort.

```html
<div style="background:#e8f5e9;border-left:4px solid #2e7d32;border-radius:4px;padding:10px 14px;margin-bottom:20px;font-size:13px;color:#1b5e20;">
  <strong>Fixed segment for all funnel analysis:</strong>
  [MB / HO] · [Paid / Organic] · [Channel if applicable — e.g. "Google Ads"]<br>
  <span style="color:#555;font-size:12px;">
    Post-period users: [N] &nbsp;|&nbsp; Share of CE post traffic: [X]%
    &nbsp;|&nbsp; Checkout impact: [sign][N] vs pre period
  </span>
</div>
```

The banner should appear once, immediately after the mix cascade analysis block and before the Shapley decomposition block. Do not repeat it in every analysis block — subsequent blocks inherit the scope implicitly.

If the mix cascade could not fix a single segment (e.g. the signal is evenly split across MB and HO), omit the banner and note in the first analysis block's verdict line that the funnel analysis covers the full CE.

---

### Shapley decomposition block

Use a proportional flex bar — not a Plotly waterfall. Each segment's `flex` value equals its percentage contribution.

```html
<div class="analysis-block">
  <div class="block-title">Shapley Decomposition — funnel step attribution</div>
  <div class="verdict-line">[Primary step] carries [X]% of ΔCVR. [Other steps] are noise.</div>

  <div class="shapley-bars">
    <div class="shapley-bar shapley-lp2s" style="flex: [lp2s_pct]">[lp2s_pct]%</div>
    <div class="shapley-bar shapley-s2c"  style="flex: [s2c_pct]">S2C [s2c_pct]%</div>
    <div class="shapley-bar shapley-c2o"  style="flex: [c2o_pct]">[c2o_pct]%</div>
  </div>
  <div class="shapley-legend">
    <span><span class="legend-dot" style="background:#6c8ebf"></span>LP2S [delta]pp</span>
    <span><span class="legend-dot" style="background:#c62828"></span>S2C [delta]pp</span>
    <span><span class="legend-dot" style="background:#d6a832"></span>C2O [delta]pp</span>
  </div>
  <p style="font-size:13px;color:#555;margin-top:12px;">
    Total ΔCVR = [total]pp. [Primary step] accounts for [delta]pp. [Other steps] are too small to act on independently.
  </p>
</div>
```

---

### Table with highlight rows

**Raw user counts are mandatory in every table.** Any table that shows rates, shares, or percentages must also show the raw user count for that segment — either as a dedicated column or as a "Pre N / Post N" sub-label. A stakeholder reading a 12pp rate drop on a 40-user segment should be able to judge its significance immediately, without doing arithmetic. Never show shares or rates alone.

The minimum columns for a rate table are: **Segment · Pre Users · Post Users · Pre Rate · Post Rate · Δ Rate**. When checkout or booking impact is the point (e.g. experience-level S2C), add a **Checkout Impact** column.

```html
<table>
  <thead>
    <tr>
      <th>Segment</th>
      <th class="num">Pre Users</th>  <!-- always include raw counts -->
      <th class="num">Post Users</th>
      <th class="num">Pre S2C</th>
      <th class="num">Post S2C</th>
      <th class="num">Δ S2C</th>
    </tr>
  </thead>
  <tbody>
    <tr class="highlight-row">   <!-- use highlight-row for the primary driver row -->
      <td><strong>HO</strong></td>
      <td class="num">8,240</td>
      <td class="num">9,980</td>
      <td class="num">35.7%</td>
      <td class="num">23.4%</td>
      <td class="num neg">−12.3pp</td>
    </tr>
    <tr>
      <td><strong>MB</strong></td>
      <td class="num">41,600</td>
      <td class="num">43,200</td>
      <td class="num">24.8%</td>
      <td class="num">24.2%</td>
      <td class="num">−0.6pp</td>
    </tr>
  </tbody>
</table>
```

Use `.neg` (red, bold) for meaningful drops, `.pos` (green, bold) for gains, plain text for near-zero changes. Use `.highlight-row` to draw the eye to the primary driver rows.

---

### Ruled-out dimensions block (always last in Section 3)

```html
<div class="analysis-block">
  <div class="block-title">Dimensions Checked — ruled out as independent drivers</div>
  <p style="font-size:13px;color:#555;margin-bottom:12px;">
    These were checked and do not add independent signal beyond what the [primary finding] already explains.
  </p>
  <ul style="font-size:14px;color:#333;padding-left:18px;">
    <li style="margin-bottom:8px;"><strong>Device:</strong> [what moved and why it is not independent]</li>
    <li style="margin-bottom:8px;"><strong>Language:</strong> [what moved and why it is not independent]</li>
    <li style="margin-bottom:0;"><strong>Page type:</strong> [what moved or "Not a driver"]</li>
  </ul>
</div>
```

---

### Plotly chart conventions

**Color palette:** Pre-period: `#6c8ebf` (blue). Post-period: `#c62828` (red). LY overlay: `#9e9e9e` (grey, dashed). Post window background shade: `rgba(198,40,40,0.05)`.

**Always add:** dashed mean reference lines (use `shapes` in layout) and annotations for pre/post average values directly on the chart.

**Chart sizing:** trend charts 280px height, bar charts 260px height. Use `responsive: true` in `Plotly.newPlot` config.

**Example — daily S2C trend:**
```javascript
Plotly.newPlot('trend-chart', [
  {
    type: 'scatter', mode: 'lines+markers', name: 'Pre period (Apr 6–12)',
    x: preDates, y: preS2C,
    line: { color: '#6c8ebf', width: 2.5 },
    marker: { size: 4, color: '#6c8ebf' }
  },
  {
    type: 'scatter', mode: 'lines+markers', name: 'Post period (Apr 13–19)',
    x: postDates, y: postS2C,
    line: { color: '#c62828', width: 2.5 },
    marker: { size: 4, color: '#c62828' }
  }
], {
  height: 280,
  yaxis: { tickformat: '.1%', title: 'S2C rate (%)' },
  xaxis: { title: 'Date' },
  plot_bgcolor: '#fff', paper_bgcolor: '#fff',
  font: { family: '-apple-system, BlinkMacSystemFont, Segoe UI, sans-serif', color: '#1a1a2e' },
  legend: { orientation: 'h', y: -0.3 },
  margin: { l: 55, r: 20, t: 30, b: 50 },
  shapes: [
    { type: 'line', x0: preDates[0], x1: preDates[preDates.length-1],
      y0: preMean, y1: preMean, line: { color: '#6c8ebf', dash: 'dot', width: 1.5 } },
    { type: 'line', x0: postDates[0], x1: postDates[postDates.length-1],
      y0: postMean, y1: postMean, line: { color: '#c62828', dash: 'dot', width: 1.5 } }
  ],
  annotations: [
    { x: preDates[Math.floor(preDates.length/2)], y: preMean,
      text: 'Pre avg ' + (preMean*100).toFixed(1) + '%',
      font: { color: '#6c8ebf', size: 11 }, showarrow: false, yshift: 12 },
    { x: postDates[Math.floor(postDates.length/2)], y: postMean,
      text: 'Post avg ' + (postMean*100).toFixed(1) + '%',
      font: { color: '#c62828', size: 11 }, showarrow: false, yshift: -16 }
  ]
}, { responsive: true });
```

**90-day + LY overlay chart:** Two traces — current year (blue solid) and LY (grey dashed) — both plotted against `currentDates` on the x-axis. Do NOT use actual LY calendar dates for the LY line; use the current-year date array so both lines sit at the same calendar position and are directly comparable month-over-month.

**Step 1 — Extract `lyCvr` from summary.json.** LY data is NOT a top-level key. It lives inside `trend_context.series` as entries tagged `"series": "ly"`, interleaved with current-year entries tagged `"series": "current"`. You must filter, extract, and align it to `currentDates` before doing anything else:

```javascript
// Extract currentDates and currentCvr from trend_context.series
const currentSeries = summaryJson.trend_context.series.filter(e => e.series === 'current');
const currentDates = currentSeries.map(e => e.date);
const currentCvr   = currentSeries.map(e => e.cvr);

// Build lyCvr aligned to currentDates (null for dates with no LY entry)
const lyMap = {};
summaryJson.trend_context.series
  .filter(e => e.series === 'ly')
  .forEach(e => { lyMap[e.date] = e.cvr; });
const lyCvr = currentDates.map(d => lyMap[d] ?? null);
```

**Step 2 — LY data guard (mandatory).** A CE that had no Headout history last year will have all-zero LY CVR entries (not nulls). The guard must reject zeros as well as nulls — a flat line at 0% is not a valid LY overlay. If the guard fails, show the warning banner instead of an empty or misleading line:

```javascript
// Guard: requires at least one LY value that is non-null AND > 0
const hasLyData = lyCvr.some(v => v !== null && v !== undefined && v > 0);
if (!hasLyData) {
  document.getElementById('trend-90day').innerHTML =
    '<div style="background:#fff3e0;border-left:4px solid #e65100;padding:8px 12px;font-size:12px;color:#bf360c;">' +
    '⚠️ Last-year overlay unavailable — no meaningful LY CVR data for this CE. Chart shows current period only.</div>';
}
```

X-axis: `tickformat: '%d %b'`, `dtick: 7 * 86400000` (weekly ticks in milliseconds) — shows "01 Jan", "08 Jan", etc., giving week-level resolution across the 90-day window.

Post window: shade with a `rect` shape and a dashed vertical line at `post_start`. Use **red** (`rgba(198,40,40,0.05)`) for CVR decline cases, green (`rgba(46,125,50,0.05)`) for CVR improvement cases.

```javascript
// Define post period bounds and postDates for the annotation midpoint
const POST_START = summaryJson.meta.post_start;
const POST_END   = summaryJson.meta.post_end;
const postDates  = currentDates.filter(d => d >= POST_START && d <= POST_END);

// Both traces use currentDates — lyCvr values plotted at the same seasonal position
const currentYear = new Date(currentDates[0]).getFullYear();
const lyYear = currentYear - 1;
const traces90d = [
  {type:'scatter', mode:'lines', name:'CVR ' + currentYear,
   x: currentDates, y: currentCvr, line:{color:'#6c8ebf', width:2}}
];
if (hasLyData) {
  traces90d.push(
    {type:'scatter', mode:'lines', name:'CVR ' + lyYear + ' (LY)',
     x: currentDates, y: lyCvr, line:{color:'#9e9e9e', dash:'dash', width:1.5}}
  );
}

const postShadeColor = (summaryJson.headline.delta.cvr < 0)
  ? 'rgba(198,40,40,0.06)' : 'rgba(46,125,50,0.05)';
const postLineColor  = (summaryJson.headline.delta.cvr < 0) ? '#c62828' : '#2e7d32';
const midPostDate = postDates[Math.floor(postDates.length / 2)];

Plotly.newPlot('trend-90day', traces90d, {
  height: 280,
  yaxis: {tickformat:'.1%', title:'CVR'},
  xaxis: {tickformat:'%d %b', dtick: 7 * 86400000, title:''},
  plot_bgcolor:'#fff', paper_bgcolor:'#fff',
  font: {family:'-apple-system, BlinkMacSystemFont, Segoe UI, sans-serif', color:'#1a1a2e', size:11},
  legend: {orientation:'h', y:-0.2},
  margin: {l:55, r:20, t:30, b:60},
  shapes: [
    {type:'rect', x0:POST_START, x1:POST_END, y0:0, y1:1,
     xref:'x', yref:'paper', fillcolor: postShadeColor, line:{width:0}},
    {type:'line', x0:POST_START, x1:POST_START, y0:0, y1:1,
     xref:'x', yref:'paper', line:{color: postLineColor, dash:'dot', width:1}}
  ],
  annotations: [{x: midPostDate, y: 0.92, xref:'x', yref:'paper',
    text:'Post period', font:{color: postLineColor, size:10}, showarrow:false}]
}, {responsive:true});
```

---

## Changelog

| # | Date | Changes |
|---|------|---------|
| c001 | 2026-04-24 | Initial version — three-section report structure (Executive Summary → Actions → Supporting Analysis) extracted from SKILL.md Step 3 and formalized |
| c002 | 2026-04-24 | Added Visual Spec section: shared CSS, page skeleton, component HTML patterns for all elements (metric cards, root cause callout, action cards, analysis blocks, Shapley bar, tables, Plotly conventions, ruled-out block). Derived from Keukenhof Tickets (CE 1549) reference report. render.py retired — Claude writes HTML directly using this spec. |
| c003 | 2026-04-24 | Header 🔗 link is now a clickable `<a href>` pointing to `top_page_url` from summary.json (populated by Q0 — most-visited page URL in the post period). |
| c005 | 2026-04-28 | Raw user counts mandatory in every table — any table showing rates or shares must include Pre Users and Post Users columns so stakeholders can judge volume without arithmetic. Added to table spec (with updated example), anti-patterns list, and report length calibration. |
| c004 | 2026-04-28 | Three structural changes: (1) 90-day CVR trend chart moves from Section 3 to Section 1 — always shown after metric cards, before callout, so seasonal context is visible immediately. (2) Callout has a positive-CVR variant: green border, "CVR Improved — What's Driving It & What's Holding It Back" heading, questions reframed around drivers/headwinds rather than what broke. (3) 90-day chart x-axis fix: both current-year and LY lines now use currentDates on the x-axis (aligned by calendar position, not actual date), with tickformat '%b %Y' to show month labels. |
| c006 | 2026-04-28 | Added inventory lead-time bucket table to Section 3 — new row in "What belongs in Section 3" table and a dedicated format spec with HTML pattern. Always follows the availability proxy table; verdict line names the specific window that went empty, not just "availability dropped". |
| c007 | 2026-04-28 | Generalised lead-time bucket spec: two verdict forms (window-specific spike vs uniform decline); HTML pattern replaced specific example rows with placeholders and a note to adapt buckets to the CE's booking horizon; subtext guidance changed from "state the mechanism" to "describe the pattern and what to investigate" to prevent asserting unconfirmed causes. |
| c009 | 2026-04-29 | 90-day chart LY overlay: two fixes. (1) Extraction step added — `lyCvr` must be built by filtering `trend_context.series` where `series === 'ly'` and aligning to `currentDates`; it is not a top-level key in summary.json. Complete extraction snippet added to spec. (2) Data guard strengthened to check `v > 0` in addition to non-null/undefined — zero-filled LY series (CE had no meaningful Headout history last year) now correctly triggers the warning banner instead of rendering a flat line at 0%. Also fixed hardcoded green post-window shade in code sample — shade colour now derived from `headline.delta.cvr` sign (red for decline, green for improvement). |
| c008 | 2026-04-29 | (1) Fixed Segment banner: new HTML component rendered once after the mix cascade and before the Shapley block, declaring the fixed MB/HO × Paid/Organic × Channel scope that applies to all subsequent funnel analysis. Includes fallback note if segment cannot be fixed. (2) 90-day chart x-axis changed from monthly (`dtick:'M1'`) to weekly ticks (`dtick: 7*86400000`, `tickformat:'%d %b'`) for week-level resolution across the 90-day window. (3) LY data guard added: pre-render check for non-empty lyCvr array; shows ⚠️ warning banner instead of silent missing line if LY series is absent from summary.json. (4) "What belongs in Section 3" updated: mix analysis now explicitly "Mix cascade (three levels: MB/HO → Paid/Organic → Channel)" replacing the single mix table entry. |
| c010 | 2026-04-29 | Added `POST_START`, `POST_END`, and `postDates` variable definitions to the 90-day chart spec — previously used in `shapes` and annotation midpoint but never defined in the snippet. Now explicitly derived from `summaryJson.meta.post_start/post_end`. |
| c011 | 2026-05-06 | Inventory section format spec redesigned to match new TID-level query architecture: (1) "Availability proxy table" row removed; replaced with "Inventory TID summary table" (one row per TID, pre+post bucket columns for Path B, post-only for Path A) and "Inventory daily time-series charts" (4 line charts, one per bucket). (2) Supply gate outcome added: if Step 2 shows full tickets, write a ruled-out statement and skip the table/charts. (3) TID summary table now includes `Capacity type` column from `is_fully_unlimited_capacity`; unlimited-capacity TIDs excluded from supply finding with a subtext note. (4) Chart scoping spec added: single TID if Step 2 identified one locus; TGID aggregate if all TIDs depleted equally. (5) Subtext paragraph guidance updated: state pattern + onset date + what supply team should check; never assert mechanism without corroborating evidence. |
| c012 | 2026-05-07 | Three presentation-layer fixes: (1) Supply gate wording updated — removes "Step 2" reference; supply-ruled-out verdict now states charts may still be shown as positive confirmation (lines above zero is visual proof); TID snapshot table is omitted in this case. (2) Added two anti-patterns: "Investigation-internal terminology in the report body (Step 1/2/3, Path A/B, Case A/B/C, locus, lost_checkouts_delta, candidate TGIDs)" and "Daily inventory time-series rendered as HTML table". (3) Both anti-pattern entries include the fix: translate internal labels to business language; always use Plotly line charts for daily data. |
