# CVR-RCA Report Structure

Read this file before writing the HTML report (Step 3 of the skill). It defines:
1. The fixed three-section macro-structure every report must follow
2. The exact visual spec (CSS, component HTML patterns) to paste into every report

**The principle:** By the time the GM finishes reading Section 2, they know exactly what happened and what to do. Section 3 is for anyone who needs to verify the conclusion. The analysis is not the report — the analysis is the evidence behind the report.

---

## Styling and language guidelines

These rules apply to every sentence that appears in the HTML output — callouts, verdict lines, subtext paragraphs, and action cards.

**1. No investigation structure labels.**
Path A, Path B, L0, L1, L2, Case A, Case B, Step 1, Step 2 are internal investigation labels. They must not appear in the report. The report presents findings, not the investigation process.

**2. No data-engineering terminology.**
"Data artefact", "extraction artefact", "data quality gap", "pipeline gap" are internal terms leadership will not recognise. If you need to explain synchronized zeros across all variants, describe the observation in plain language:
- ✅ "Availability shows zeros on these dates across all variants — likely a data gap rather than an actual sell-out, as the same pattern appears across all experiences checked."
- ❌ "This is likely an extraction artefact."

**3. No speculative user behavior without a data signal.**
Do not describe what users were thinking, planning, or intending unless there is a data point to ground it — session recordings, a traffic source shift, a lead-time distribution change. Phrases like "high-intent families planning trips" or "students booking spring break" are not findings.
- ✅ "Session recordings show users encountering an empty date picker beyond 7 days — consistent with the 8+ day booking drop."
- ❌ "High-intent families planning Hawaii trips may no longer be converting at the same rate."

**4. External context only when paired with a data signal.**
Seasonal framing, known events, and holidays are permitted when a corresponding data signal exists — e.g., a traffic spike on a specific date, a CVR break that aligns precisely with a holiday weekend. Never use seasonal framing as a catch-all explanation for a drop.
- ✅ "The onset aligns with Easter weekend (Apr 18–20), where the daily chart shows a sharp CVR drop on Apr 18."
- ❌ "The spring season typically brings lower-intent traffic."

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
| Geo / Non-Geo overview | Always — run once after the fixed segment is declared. Shows domestic vs international CVR split across the top countries by volume. If the drop is concentrated in either Geo or Non-Geo, add the downstream-limitation note (see spec below). |
| Daily S2C/LP2S/C2O trend chart | Always — establishes sudden vs gradual onset. All trend charts filtered to the fixed segment. Pre: blue `#6c8ebf`, Post: red `#c62828`. |
| Dimension cut (device / language / page_type) | Only if it produced a concentrated signal OR is being explicitly ruled out. |
| Channel/segment breakdown table | When the drop is concentrated in HO vs MB or a specific channel. |
| Experience-level breakdown | When drop is concentrated in specific experiences. |
| URL-level breakdown | When drop is concentrated in specific page URLs. |
| Lead-time distribution | When availability scarcity is the hypothesis — compare pre/post booking bucket distribution. |
| Inventory TID summary table | When S2C drop is confirmed at a specific TGID — one row per TID, columns: TID · TID Name · Tickets 0–2d · Tickets 3–7d · Tickets 8–13d · Tickets 14–30d. Snapshot from the latest available `extracted_date`. |
| Inventory daily time-series charts | When S2C drop is confirmed at a specific TGID — always run alongside the TID snapshot. Four line charts (one per lead-time bucket), `extracted_date` on x-axis, total tickets on y-axis. Path B: pre and post as overlaid series. Path A: post series only. Path X: omit entirely — add an inline note in the S2C evidence block: *"Inventory data unavailable — post period ended more than 30 days ago. Supply mechanism cannot be confirmed or ruled out from data."* |
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

**Supply gate outcome:** If the time-series confirms tickets were healthy throughout the post period for all limited-capacity TIDs, open the inventory block with the ruled-out verdict: *"Supply checked and ruled out — all limited-capacity TIDs had available tickets throughout the post period. Supply is not the mechanism for this S2C drop."* Always show the line charts when data is available (Path A or Path B) — healthy lines above zero are visual proof, not just an assertion. Do not show the TID snapshot table in this case — it adds no signal beyond the verdict. For Path X (post period outside the 30-day window), omit the charts and add the inline limitation note instead. Move directly to pricing or UX after the inventory block.

**TID summary table (all paths — current-state snapshot):** One row per TID. Columns: TID · TID Name · Tickets 0–2d · Tickets 3–7d · Tickets 8–13d · Tickets 14–30d · Capacity type. This shows today's inventory state, not the post period. Use it to scope the time-series (which TIDs have near-zero buckets now, which are unlimited-capacity) and to give orientation context. Highlight near-zero rows with `.highlight-row` as a scoping signal. Append `Capacity type` (`Limited` / `Unlimited`) from `is_fully_unlimited_capacity`. Omit unlimited-capacity TIDs from the supply finding — note in subtext: "excluded from supply analysis (unlimited capacity)." For Path A, add the orange block-level note above the table: *"Pre-period inventory data unavailable — pre period is more than 30 days ago. Current-state snapshot shown."*

**Daily time-series charts:** Four Plotly line charts, one per lead-time bucket. x-axis: `extracted_date`. y-axis: total tickets (TGID aggregate of limited-capacity TIDs — do not include unlimited-capacity TIDs in the traces). These are the primary supply RCA evidence.

- **Single TGID investigated:** one trace per chart, scoped to that TGID.
- **Multiple TGIDs investigated (2–3 significant contributors):** one colored trace per TGID on each chart. Label traces by experience name, not TGID number ("UTV Raptor Tour", not "TGID 37536"). One set of 4 charts covers all investigated TGIDs — do not produce separate chart sets per TGID.
- **Path A (pre period outside 30-day window):** post-period dates only on x-axis.
- **Path B (pre period within 30-day window):** full date range on x-axis (`pre_start` to `post_end`). Add a shaded post-period region and vertical dashed line at `post_start`, matching the 90-day chart convention. One continuous trace per TGID — do not split into separate pre/post series. The pre→post transition is visible on the same timeline.
- **Omit non-informative buckets:** If a lead-time bucket shows uniformly healthy supply across all experiences throughout the post period — no sustained near-zero values, no progressive decline — do not render a chart for that bucket. Replace it with a single inline sentence immediately before the next chart heading: *"[X–Yd bucket: all experiences maintained available tickets throughout (range: N–M tickets). Not charted.]"* Only render a chart when the time-series shows a pattern that is directly relevant to the finding.

**TID selection for charts — contribution-based**

Before building the charts, identify contributing TIDs from the median table (Path A: post-period median; Path B: pre/post median comparison):

- **One TID depleted** → chart that TID individually as a single trace
- **Multiple TIDs depleted within one TGID** → aggregate their ticket counts into one trace; label by TGID / experience name
- **Mixed (some depleted, some healthy within one TGID)** → chart depleted TIDs only; note excluded healthy TIDs in the disclosure banner
- **All TIDs healthy** → aggregate all limited-capacity TIDs (supply ruled out context)

For multiple TGIDs: apply this logic independently per TGID → one trace per TGID on the same set of 4 charts.

**Always query the time-series through the `experience_id → dim_tours` bridge. Never scope to a hardcoded `tour_id` without first confirming via the median table which TIDs are the contributing locus.**

**Yellow disclosure banner — always render immediately before the charts:**

```html
<div style="background:#fff8e1;border-left:4px solid #f9a825;border-radius:4px;padding:10px 14px;margin-bottom:16px;font-size:13px;color:#5d4037;">
  <strong>Charts cover:</strong>
  <!-- Use the applicable form: -->
  <!-- Single TID: -->
  TID [id] ([name]) — [post period only, no pre-period baseline | pre and post period shown]
  <!-- Multiple aggregated TIDs from one TGID: -->
  Combined data for TID [id1] ([name1]) + TID [id2] ([name2]) — [Path A/B note]
  <!-- Mixed — depleted only: -->
  TID [id] ([name]) — TID [id2] ([name2]) had healthy availability throughout and is excluded.
  <!-- Multiple TGIDs — one line per TGID: -->
  [TGID 1 name]: TID [id] ([name]) &nbsp;|&nbsp; [TGID 2 name]: Combined TID [id1] + TID [id2]
</div>
```

**Plotly implementation — inventory time-series:**

```javascript
// One IIFE per inventory section. One trace per contributing scope.
// Scope = single TID, or aggregated TIDs for one TGID, or one trace per TGID if multi-TGID.
// Path A: dates = post-period dates only.
// Path B: dates = pre_start→post_end; add shaded post region and vertical line (see below).
(function () {
  var dates = [/* extracted_date strings across the charted range */];

  // One data array per trace per bucket — from the daily time-series query.
  var scope1_02 = [/* tickets_0_2d for scope 1 */];
  var scope2_02 = [/* tickets_0_2d for scope 2 — omit if single trace */];
  // Repeat _37, _813, _1430 for each scope.

  var colors = { scope1: '#1a56db', scope2: '#2e7d32', scope3: '#e07b00' };

  var layout = {
    height: 220,
    margin: { t: 10, r: 10, b: 40, l: 50 },
    xaxis: { tickfont: { size: 10 }, nticks: 9 },
    yaxis: { tickfont: { size: 10 }, rangemode: 'tozero' },
    legend: { orientation: 'h', y: -0.28, font: { size: 10 } },
    plot_bgcolor: '#fafafa',
    paper_bgcolor: '#fff'
  };

  var cfg = { responsive: true, displayModeBar: false };

  function trace(name, y, color) {
    return { x: dates, y: y, name: name, type: 'scatter', mode: 'lines+markers',
             line: { color: color, width: 2 }, marker: { color: color, size: 4 } };
  }

  Plotly.newPlot('inv-chart-0-2d',
    [trace('[Scope 1 label]', scope1_02, colors.scope1)
     /* add trace('[Scope 2 label]', scope2_02, colors.scope2) if multi-scope */],
    Object.assign({}, layout), cfg);

  // Repeat newPlot calls for inv-chart-3-7d, inv-chart-8-13d, inv-chart-14-30d.
})();

// Path B additions to layout.shapes:
// { type:'rect', x0:POST_START, x1:POST_END, y0:0, y1:1, xref:'x', yref:'paper',
//   fillcolor:'rgba(198,40,40,0.06)', line:{width:0} }
// { type:'line', x0:POST_START, x1:POST_START, y0:0, y1:1, xref:'x', yref:'paper',
//   line:{color:'#c62828', dash:'dot', width:1} }
// Path B annotation: { x:midPostDate, y:0.92, xref:'x', yref:'paper',
//   text:'Post period', font:{color:'#c62828',size:10}, showarrow:false }
```

**Subtext paragraph:** State the pattern and when it started, and what the supply team should check. Do not assert the mechanism — the data shows *where* and *when*, not *why*. Never write "this was caused by [specific mechanism]" without corroborating evidence from the supply team.

**Path A — post-period median table:**

```html
<!-- Path A: pre period is outside the 30-day window — only post-period data available.
     One row per limited-capacity TID. Columns show median ticket counts across all
     extracted_dates within the post period (not today's snapshot).
     Apply highlight-row to TIDs where the post-period median is near-zero —
     this means the TID was typically constrained during the period under investigation.
     Omit rows where is_fully_unlimited_capacity = TRUE; note them in subtext. -->
<div class="analysis-block">
  <div class="block-title">Availability during post period — [Experience name]</div>
  <div class="verdict-line">[State the actual pattern using the correct verdict form from the spec above]</div>

  <p style="font-size:13px;color:#e07b00;margin-bottom:10px;">
    Pre-period availability data unavailable — pre period falls outside the 30-day window.
    Showing median daily ticket availability across the post period. No before/after comparison possible.
  </p>

  <table>
    <thead>
      <tr>
        <th>TID</th>
        <th>TID Name</th>
        <th class="num">Median 0–2d</th>
        <th class="num">Median 3–7d</th>
        <th class="num">Median 8–13d</th>
        <th class="num">Median 14–30d</th>
        <th>Capacity</th>
      </tr>
    </thead>
    <tbody>
      <!-- highlight-row on TIDs where the post-period median is near-zero -->
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
    [State which TIDs show near-zero median (typically constrained during the post period)
     and which are healthy. The time-series charts below confirm the daily pattern.
     If any TIDs were excluded: "TID [id] ([name]) excluded — unlimited capacity."]
  </p>
</div>
```

**Path B — TID pre/post median comparison (2×2 bucket grid):**

```html
<!-- Path B: pre period is within the 30-day window — median across all extracted_dates
     available for both periods.
     Pre Median = median of daily ticket counts across all extracted_dates in [pre_start, pre_end].
     Post Median = median of daily ticket counts across all extracted_dates in [post_start, post_end].
     Apply highlight-row to TIDs where post median dropped significantly vs pre median.
     Omit rows where is_fully_unlimited_capacity = TRUE from all tables; list them in subtext.
     No orange limitation banner — pre data is available for Path B. -->
<div class="analysis-block">
  <div class="block-title">Availability — [Experience name] (pre vs post median)</div>
  <div class="verdict-line">[State the actual pattern — which bucket(s) dropped and by how much, or ruled-out if healthy throughout]</div>

  <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:16px;">

    <!-- 0–2 day bucket -->
    <div>
      <p style="font-size:12px;font-weight:600;color:#444;margin:0 0 6px;">Same / next day (0–2d)</p>
      <table>
        <thead>
          <tr>
            <th>TID</th>
            <th>TID Name</th>
            <th class="num">Pre Median</th>
            <th class="num">Post Median</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>[tour_id]</td>
            <td>[tour_name]</td>
            <td class="num">[n]</td>
            <td class="num">[n]</td>
          </tr>
          <!-- add rows for remaining TIDs -->
        </tbody>
      </table>
    </div>

    <!-- 3–7 day bucket -->
    <div>
      <p style="font-size:12px;font-weight:600;color:#444;margin:0 0 6px;">3–7 days out</p>
      <table>
        <thead>
          <tr>
            <th>TID</th>
            <th>TID Name</th>
            <th class="num">Pre Median</th>
            <th class="num">Post Median</th>
          </tr>
        </thead>
        <tbody>
          <tr class="highlight-row">
            <td>[tour_id]</td>
            <td>[tour_name]</td>
            <td class="num">[n]</td>
            <td class="num neg">[n]</td>
          </tr>
          <!-- add rows for remaining TIDs -->
        </tbody>
      </table>
    </div>

    <!-- 8–13 day bucket -->
    <div>
      <p style="font-size:12px;font-weight:600;color:#444;margin:0 0 6px;">8–13 days out</p>
      <table>
        <thead>
          <tr>
            <th>TID</th>
            <th>TID Name</th>
            <th class="num">Pre Median</th>
            <th class="num">Post Median</th>
          </tr>
        </thead>
        <tbody>
          <tr class="highlight-row">
            <td>[tour_id]</td>
            <td>[tour_name]</td>
            <td class="num">[n]</td>
            <td class="num neg">[n]</td>
          </tr>
          <!-- add rows for remaining TIDs -->
        </tbody>
      </table>
    </div>

    <!-- 14–30 day bucket -->
    <div>
      <p style="font-size:12px;font-weight:600;color:#444;margin:0 0 6px;">14–30 days out</p>
      <table>
        <thead>
          <tr>
            <th>TID</th>
            <th>TID Name</th>
            <th class="num">Pre Median</th>
            <th class="num">Post Median</th>
          </tr>
        </thead>
        <tbody>
          <tr class="highlight-row">
            <td>[tour_id]</td>
            <td>[tour_name]</td>
            <td class="num">[n]</td>
            <td class="num neg">[n]</td>
          </tr>
          <!-- add rows for remaining TIDs -->
        </tbody>
      </table>
    </div>

  </div><!-- end grid -->

  <p style="font-size:13px;color:#555;margin-top:16px;">
    [State which buckets show a meaningful median drop and by how much. The time-series charts
     below confirm when the depletion started within the post period. Do not assert a supply
     verdict here — describe the pattern.
     If any TIDs were excluded: "TID [id] ([name]) excluded — unlimited capacity."]
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

### Geo / Non-Geo overview block

Render immediately after the Fixed Segment banner, before the Shapley block. Always present — this is a mandatory diagnostic, not conditional on finding a geographic signal.

**Four verdict forms:**

- **Geo-concentrated** (home-market rate dropped, international held): `"Drop concentrated in domestic users — international visitors held flat."`
- **Non-Geo-concentrated** (international rate dropped, home market held): `"Drop concentrated in international visitors — home market held flat."`
- **Uniform** (both dropped similarly): `"No geographic concentration — domestic and international rates dropped similarly. Geography does not isolate the issue."`
- **Mix-dominant** (share shifted, per-group rates held): `"Geographic mix shifted — per-group rates held while composition changed. This is a traffic sourcing change, not a funnel quality issue."`

**Downstream-limitation note:** For Geo-concentrated and Non-Geo-concentrated outcomes only, add this as the subtext paragraph:
> "Note: downstream analysis — inventory availability and pricing — is not filtered by geography. Geo-specific root causes (local supply, domestic pricing, geo-targeted campaign change) should be investigated separately with the supply and BDM teams."

For Uniform and Mix-dominant outcomes, omit the note and continue to Shapley.

```html
<div class="analysis-block">
  <div class="block-title">Geographic Overview — Domestic vs International</div>
  <div class="verdict-line">
    <!-- Use ONE of the four verdict forms above -->
    [Verdict]
  </div>

  <table>
    <thead>
      <tr>
        <th>Country</th>
        <th>Segment</th>
        <th class="num">Pre Users</th>
        <th class="num">Post Users</th>
        <th class="num">Pre CVR</th>
        <th class="num">Post CVR</th>
        <th class="num">ΔCVR</th>
      </tr>
    </thead>
    <tbody>
      <!-- highlight-row on Geo row if Geo-concentrated; Non-Geo rows if Non-Geo-concentrated; no highlight-row if Uniform or Mix-dominant -->
      <tr class="highlight-row">
        <td>[Home country]</td>
        <td>Domestic</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[±x.xxpp]</td>
      </tr>
      <tr>
        <td>[Country 2]</td>
        <td>International</td>
        <td class="num">[n]</td><td class="num">[n]</td>
        <td class="num">[x%]</td><td class="num">[x%]</td>
        <td class="num">[±x.xxpp]</td>
      </tr>
      <!-- repeat for top countries by volume; always include home country regardless of rank -->
    </tbody>
  </table>

  <!-- For Geo-concentrated or Non-Geo-concentrated only: -->
  <p style="font-size:13px;color:#555;margin-top:12px;">
    Note: downstream analysis — inventory availability and pricing — is not filtered by geography.
    [Geo-concentrated: "Geo-specific root causes (local supply, domestic pricing, geo-targeted campaign change) should be investigated separately with the supply and BDM teams."]
    [Non-Geo-concentrated: "Language, UX friction, and international supply hypotheses should be investigated separately."]
  </p>
</div>
```

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

### Ruled-out dimensions block (second-to-last in Section 3)

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

### Hypotheses explored (always last in Section 3)

A structured log of every hypothesis generated and tested during the
investigation. Shows the full exploration shape: what was proposed, what the
test was, what it led to, and — critically — what was attempted but couldn't
be resolved. This block earns its place by being honest about the
investigation's limits, not just its conclusions.

Render as an `.analysis-block` table at the very end of Section 3, after the
ruled-out dimensions block. Every hypothesis generated during the
investigation must appear — confirmed, ruled out, and open alike. A
hypothesis that was tested and ruled out is as valuable to show as one that
was confirmed. A `🔄` row is an honest acknowledgment that the investigation
reached a data boundary; it invites the stakeholder to pick it up.

**Outcome values:**
- ✅ **Confirmed** — test produced a specific positive finding
- ❌ **Ruled out** — test produced a specific negative result
- ⚠️ **Data gap** — couldn't test; name the data or tool that would close it
- 🔄 **Consistent with, not directly tested** — data pattern fits the
  hypothesis but no direct test was run; name what the direct test would be

```html
<div class="analysis-block">
  <div class="block-title">Hypotheses Explored</div>
  <p style="font-size:13px;color:#555;margin-bottom:14px;">
    Every hypothesis generated during this investigation — confirmed, ruled out, and open.
  </p>
  <table>
    <thead>
      <tr>
        <th>Hypothesis</th>
        <th>Test run</th>
        <th class="num" style="width:100px;">Outcome</th>
        <th>What this means</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>[Hypothesis — what was proposed and why]</td>
        <td>[What was checked — e.g. "inventory daily time-series for TID 80074"]</td>
        <td class="num">✅ Confirmed</td>
        <td>[One sentence: what the finding means for the CE]</td>
      </tr>
      <tr>
        <td>[Hypothesis — what was proposed and why]</td>
        <td>[What was checked — e.g. "price table for all TGIDs pre vs post"]</td>
        <td class="num">❌ Ruled out</td>
        <td>[One sentence: why this hypothesis was eliminated]</td>
      </tr>
      <tr>
        <td>[Hypothesis — what was proposed and why]</td>
        <td>[What you would have checked — e.g. "session recordings on select page"]</td>
        <td class="num">⚠️ Data gap</td>
        <td>[One sentence: what data or tool is missing and who could provide it]</td>
      </tr>
      <tr>
        <td>[Hypothesis — what was proposed and why]</td>
        <td>[Indirect evidence only — e.g. "supply healthy, price flat; no direct user-journey test"]</td>
        <td class="num">🔄 Untested</td>
        <td>[One sentence: what the direct test would be]</td>
      </tr>
    </tbody>
  </table>
</div>
```

---

### Plotly chart conventions

**Color palette:** Pre-period: `#6c8ebf` (blue). Post-period: `#c62828` (red). LY overlay: `#9e9e9e` (grey, dashed). Post window background shade: `rgba(198,40,40,0.05)`.

**Color names in callout text must be derived from chart code, not assumed.** When any verdict line, callout, or subtext paragraph names a trace by color (e.g. "UTV Raptor (red)"), the name must match the hex value explicitly assigned in that chart's `colors` object or trace definition — never inferred from Plotly's default color sequence or trace order. Write color references after the `colors` object is defined in the script; never before. If colors are not explicitly set, set them explicitly before writing any text that references them.

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

**Step 2 — LY data guard (mandatory).** A CE that had no Headout history last year will have all-zero LY CVR entries (not nulls). The guard must reject zeros as well as nulls — a flat line at 0% is not a valid LY overlay. The chart always renders with current-year data. When LY is absent, insert a visible amber badge immediately after the chart div — do not replace the chart with a warning or bury the note in grey subtext below it.

```javascript
// Guard: requires at least one LY value that is non-null AND > 0
const hasLyData = lyCvr.some(v => v !== null && v !== undefined && v > 0);
// The chart always renders — traces90d already excludes the LY trace when hasLyData is false.
// Do NOT replace the chart div with a warning banner.
```

After the `Plotly.newPlot('trend-90day', ...)` call, add:

```javascript
// When LY data is absent, insert a visible amber badge after the chart — not grey subtext
if (!hasLyData) {
  document.getElementById('trend-90day').insertAdjacentHTML('afterend',
    '<div style="display:inline-flex;align-items:center;gap:6px;background:#fff8e1;border:1px solid #f9a825;' +
    'border-radius:4px;padding:5px 10px;margin-top:8px;font-size:12px;color:#7a5c00;">' +
    '<span>⚠️</span><span><strong>No LY overlay:</strong> ' +
    '[state the specific reason — e.g. "CE launched in 2025, fewer than 10 users on scattered dates last year"]. ' +
    'LY line suppressed to avoid a misleading comparison.</span></div>'
  );
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
| c013 | 2026-05-07 | Inventory section redesigned to reflect snapshot-vs-time-series architecture: (1) "What belongs in Section 3" time-series row: changed trigger from "when TID summary table shows depleted buckets" (old supply gate) to "when S2C drop is confirmed at a specific TGID — always run alongside the TID snapshot"; added Path X inline note (omit entirely; add limitation sentence to S2C evidence block). (2) TID summary table spec unified: Path B and Path A separate paragraphs merged into one "all paths — current-state snapshot" spec with single-set bucket columns (removed pre/post pair format). (3) HTML template simplified: 8 pre/post column headers (Pre 0–2d / Post 0–2d, etc.) replaced with 4 single-set headers; data rows simplified from 4 pairs to 4 individual cells; comment updated to clarify snapshot source and that highlight-row is a scoping signal, not a supply verdict. |
| c014 | 2026-05-07 | Inventory table templates split into Path A and Path B variants: (1) "Path B and Path A — same table structure" header renamed to "Path A — TID snapshot table (current-state snapshot)"; HTML comment updated — "For Path A only:" qualifier removed (template is now exclusively Path A); orange limitation note is always shown. (2) New "Path B — TID pre/post comparison (2×2 bucket grid)" template added — four small tables in a CSS grid (one per lead-time bucket), each with Pre and Post columns from the pre_end/post_end snapshots respectively. highlight-row on TIDs where the bucket dropped significantly. Unlimited-capacity TIDs excluded per subtext note. No orange banner (pre data available). (3) Supply gate always-show rule reinforced: "Always show the line charts when data is available (Path A or Path B)" — replaced earlier "may still show" wording. (4) Daily time-series chart spec expanded: explicit multi-TGID sub-case (one colored trace per TGID, labeled by experience name, not TGID number); Path A/B date range guidance added. (5) Plotly implementation snippet added for multi-TGID time-series, including Path B shading comment. |
| c015 | 2026-05-07 | Added mandatory TGID-aggregate disclosure note to the daily time-series charts spec: always render a subtext paragraph above the charts stating that the charts show total tickets aggregated across all limited-capacity TIDs per experience, that a dip reflects combined availability (not a specific TID), and that TID-level detail is in the summary table above or the investigation transcript. |
| c016 | 2026-05-07 | Added "Styling and language guidelines" section before Section 1: four rules — (1) no investigation structure labels (Path A/B, L0/L1/L2, Step 1/2/3, Case A/B) in rendered output; (2) no data-engineering terminology ("artefact", "extraction artefact", "pipeline gap"); (3) no speculative user behavior without a data signal; (4) external context (seasonality, events) only when paired with a corresponding data signal. |
| c017 | 2026-05-07 | Restored mandatory Geo / Non-Geo overview block: (1) added "Geo / Non-Geo overview" row to "What belongs in Section 3" table as always-present; (2) added "### Geo / Non-Geo overview block" section between the Fixed Segment banner and Shapley block — includes four verdict forms (Geo-concentrated / Non-Geo-concentrated / Uniform / Mix-dominant), HTML table template (top countries by volume, home country always included, highlight-row on concentrated segment), and downstream-limitation note for Geo/Non-Geo concentrated outcomes only. |
| c018 | 2026-05-07 | Three output-quality fixes from CE 6495 evaluation: (1) Inventory time-series — added "Omit non-informative buckets" rule: if a lead-time bucket is uniformly healthy across all experiences for the full post period, replace the chart with a single inline sentence rather than rendering an empty-signal chart. (2) LY data guard — changed behavior from replacing the chart div with a warning banner to always rendering the chart and inserting a visible amber ⚠️ badge after it; grey subtext is no longer an acceptable placement for the LY-absent notice. (3) Plotly conventions — added rule requiring color names in verdict lines, callouts, and subtext to be derived from the explicitly-assigned hex values in the chart's `colors` object, not inferred from Plotly default color order or trace position. |
| c019 | 2026-05-07 | Inventory section redesigned for multi-TID accuracy and period-median summary tables: (1) TID selection for charts changed from hardcoded multi-TGID traces to contribution-based: one depleted TID → individual trace; multiple depleted TIDs within one TGID → aggregate into one trace; mixed → depleted only with healthy TIDs noted in disclosure banner; all healthy → aggregate all. For multiple TGIDs: one trace per TGID applying the same logic. (2) Yellow disclosure banner added — always rendered immediately before the 4 line charts. Amber style matching LY callout. States exactly which TIDs/data the charts cover, with single-TID, aggregated, mixed-exclusion, and multi-TGID text variants. (3) Path A table replaced: "current-state snapshot" (today's MAX extracted_date) replaced with "post-period median table" — columns renamed to Median 0–2d/3–7d/8–13d/14–30d; orange banner updated; highlight-row now signals near-zero post-period median, not today's state. (4) Path B table replaced: snapshot-based Pre/Post columns replaced with Pre Median / Post Median columns from the period-median queries. Plotly implementation simplified: scope-based traces (scope1/scope2) replace hardcoded tgid1/tgid2/tgid3. |
| c020 | 2026-05-13 | Added "Hypotheses explored" block — always last in Section 3, after the ruled-out dimensions block (which is now second-to-last). Four-column table (Hypothesis · Test run · Outcome · What this means) with four outcome values: ✅ Confirmed, ❌ Ruled out, ⚠️ Data gap (name what would close it), 🔄 Consistent with — not directly tested (name what the direct test would be). Every hypothesis generated during the investigation must appear — confirmed, ruled out, and open alike. Forces honest documentation of data limits and untested inferences rather than allowing them to disappear into narrative subtext. |
