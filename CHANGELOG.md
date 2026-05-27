# CVR-RCA Skill — Changelog

This file tracks every meaningful change pushed to this repository. Each entry corresponds to a GitHub push and is written for stakeholder consumption — what changed, why it matters, and what improved.

---

## [v1.13] — 2026-05-22 — Perf-audit companion-skill integration (plug-and-play sub-agent)

**Summary:** CVR-RCA gains a paid-traffic enrichment layer by spawning a separate companion skill — [`perf-audit-skill`](https://github.com/aaradhyaraiHO/perf-audit-skill) — as a background sub-agent whenever the L1 cascade fixes on Paid. Mirrors the Slack fire-and-forget pattern exactly: spawn at the end of the cascade, do not consult during L2+ dimension cuts, read the verdict only at Step 2b synthesis. Two skills stay independent — no schemas, queries, or diagnostic logic moved between them. The sub-agent runs the full perf-audit on the CVR-RCA's pre/post date windows and writes a structured summary (overall verdict, SIS / CPC / Paid CVR trends, campaign status, one-sentence key finding, optional surprise hypothesis) to `<run_dir>/perf_audit_summary.md`. Step 2b check #10 reconciles the verdict using the same four-pattern model as Slack (A direct corroboration, B mechanism explanation, C reframing context, D testable gap, Reject). Funnel data is deliberately excluded from the summary to avoid attribution conflicts with the Mixpanel funnel — CVR-RCA owns the funnel numbers, perf-audit owns the traffic-and-campaign side. Distribution via convention: companion install at `~/.perf-audit-skill/` (added as optional Step 5 in INSTALL.md), with env-var override and sibling-directory + legacy fallbacks. CVR-RCA runs fully without it — if path resolution fails, the run logs `Perf-audit skill not installed — skipped` and continues. The integration is additive evidence, never a gate.

### Changes by file

**`SKILL.md`** — c030
- New section "Perf-audit context — fire and forget (Paid-side only)" inserted at the end of the L1 cascade (immediately before L2+). Trigger conditions, skip conditions, four-step path resolution, full spawn block with structured summary shape, context-isolation note.
- Step 2b gains check #10 "Perf-audit reconciliation" with four-pattern routing (A/B/C/D) + Reject + DATA GAP handling. Explicit reaffirmation that perf-audit is consulted only at this point — never during L2+ — so the data-driven branches must reach their own leaves first.
- Evidence inventory entry shape specified (Verdict / Key metrics / Campaign issues / Implication / Source).
- Root cause callout requirement: Patterns A, B, C must reflect the perf-audit verdict in the final report.

**`references/hypothesis.md`** — c030
- LP2S first-pass branches gain a "Paid fixed segment — perf-audit background context" paragraph explaining the sub-agent runs in parallel and the verdict folds in at Step 2b, not during dimension cuts.
- Mix first-pass branches gain a "Perf-audit background context (Level 2 and Level 3 exits)" paragraph explaining how Pattern B in check #10 routes campaign-level *why* findings into Layer 1 narrative without a second query.

**`INSTALL.md`** — c030
- New optional Step 5 "Install the perf-audit companion skill". Detects existing install, prompts user, fetches from `aaradhyaraiHO/perf-audit-skill` to `~/.perf-audit-skill/`. Previous Step 5 (Confirm) renumbered to Step 6.

### What did not change

- `references/context.md` — perf-audit owns its own data layer (table schemas, queries, diagnostic trees). CVR-RCA does not learn `ads_campaign_stats` or `google_ads_campaign_stats` shapes.
- The perf-audit skill itself — runs as-is, no fork or vendoring.
- Report structure — perf-audit findings appear as evidence entries and Section 3 Market Context rows, never as new sections.
- No blocking dependency — every existing CVR-RCA path continues to work without perf-audit installed.

### Why this design

The plug-and-play sub-agent pattern keeps both skills independently maintainable: perf-audit releases on its own cadence at `aaradhyaraiHO/perf-audit-skill`, CVR-RCA on its cadence here, and the bridge is a thin spawn-and-read contract. The fire-and-forget timing — same as Slack — protects the integrity of the data-driven investigation: dimension cuts reach their own leaves before the perf-audit verdict is read, so traffic-quality signals corroborate or surprise a completed picture rather than steering branch selection. This is the difference between *evidence weighting* (good) and *evidence biasing* (bad).

---

## [v1.12] — 2026-05-22 — Bidirectional RCA support, four-pattern Slack reconciliation, link-to-table styling, jargon preservation

**Summary:** Largest skill release since v1.0. Three connected expansions land together. **(1) Bidirectional RCA support** — the skill now treats CVR improvements as first-class investigations alongside declines. New "Improvement direction" first-pass branch sets in `hypothesis.md` (LP2S / S2C / C2O / Mix in the positive direction). New bidirectional Pattern 11 (Catalogue change — TGID launch, disablement, restructure) with data-driven trigger and query template in `context.md`. New "Improvement direction — action templates" library in `actions.md`: **Protect** / **Extend** / **Investigate-headwind** sub-templates with starter actions and DRIs. Report-structure spec gains improvement-case headwind magnitude threshold (<~10% of ΔCVR → fold into sub-bullet), sign-aware Shapley flex bar for mixed contributions, and direction-aware scoring guidance in the evaluator. Decline path is preserved and strengthened — no decline behaviour is weakened by the bidirectional work; cross-cut trigger rule rephrased to "concentrated movement (in either direction)" with identical threshold. **(2) Four-pattern Slack reconciliation model** — Step 2b check #9 rewritten. Every signal classifies into Pattern A (direct corroboration), B (mechanism explanation), C (reframing context), D (testable gap), or Reject. Each pattern routes to a specific surface in the report: A elevates Section 3 verdict subtext citations (decline-specific), B drives Layer 1 narrative weaving + Market Context block, C drives Layer 2 Important Context callout-item + Market Context block, D triggers a one-query test with `(prompted by Author · date ↗)` citation. Mandatory timeframe-citation rule for different-period Slack metrics. One-citation-per-concept rule. Reaffirms that Slack is consulted **only** at Step 2b — never during L0/L1/L2 — the fire-and-forget pattern is deliberate. New "Slack signal classification" reference table in `hypothesis.md`. High-value gap categories listed for Pattern D (assortment changes, pricing levers, content updates, supplier changes, catalogue events). **(3) Link-to-table styling + jargon preservation.** Every Section 3 analysis block now carries an `id` attribute; canonical anchor ID convention listed in `report_structure.md`. New `.ref-link` CSS (small ↗ icon, blue-grey, smooth scroll, `:target` highlight). ↗ used in Section 1 callout, Section 2 action cards, Hypotheses Explored "Test run" column — never inside Section 3 verdict lines or subtexts. Citation format split: bare `↗` for internal navigation, `Source · date ↗` for Slack citations. New styling rule 5: preserve Headout-native jargon (WBR, SP, GBV, RR vs plan, TGID, TID, VID, CR%, FabriGPT, MB / HO, LP2S, S2C, C2A, A2O, C2O) — paraphrasing reduces stakeholder trust by hiding the source. Does not override the existing investigation-internal-labels-translated rule. **(4) Step 4 footer hardened** — the two output lines (`Evaluation → …` and `[Total X/35] · …`) are the only chat output at end of run. No narrative summary, no Slack recap, no highlights block. **(5) Same-period vs different-period data boundary** documented in `context.md` to prevent fabricated YoY figures while allowing external reframing context.

### Changes by file

**`SKILL.md`** — c029
- Step 2b check #9 rewritten with four-pattern classification (A/B/C/D) + Reject. Explicit reaffirmation that Slack is consulted only at this point.
- Pattern A on declines: citation-elevation rule for DRI-bound actions.
- Pattern C: timeframe-citation rule made mandatory when Slack timeframe ≠ pre/post.
- Pattern D: high-value gap categories listed (assortment changes, pricing levers, content updates, supplier changes, catalogue events).
- One citation per concept rule added.
- Step 4 footer hardened — two output lines are the *only* chat output.
- Session recordings rule extended to improvement loci (decline = look for failure; improvement = verify smooth flow + surface new UI).
- L2+ section gains direction-sensitive language and pointer to `hypothesis.md → "Improvement direction"` when CVR improved.
- Catalogue change called out as a first-class data-driven hypothesis.

**`references/report_structure.md`** — c025
- New "Slack integration & link-to-table styling" section: three-layer model, four-pattern cross-reference table, timeframe-citation rule, Slack-corroboration-upgrades-evidence rule, ↗ link-to-table pattern with usage and citation-format-split rules.
- New Styling rule 5: preserve Headout-native jargon (does not override rule 1).
- Section 1c gains magnitude threshold for "What's holding it back" (improvement variant).
- Section 2 gains improvement-direction action card sub-spec (Protect / Extend / Investigate-headwind).
- Section 3 ordering adds item 6.5 Market Context (conditional).
- New "Market context & operational signals" HTML block spec.
- Shapley block gains sign-aware flex bar rule.
- Visual Spec gains `.ref-link` CSS, scroll-behavior, `.analysis-block:target` highlight.
- New "Anchor ID convention" section listing canonical IDs.
- "What belongs in Section 3" table gains rows for Weekday composition and Market Context.

**`references/hypothesis.md`** — c018
- Cross-cut trigger rule rephrased to "concentrated movement (in either direction)" — same threshold, broader language.
- New "Improvement direction — first-pass branches" section: LP2S/S2C/C2O/Mix in positive direction.
- New "Pattern 11: Catalogue change (bidirectional)" — TGID launch, disablement, restructure as first-class hypothesis.
- New "Slack signal classification" reference table — four patterns + Reject, with high-value gap categories for Pattern D.

**`references/context.md`** — c027
- New "Catalogue change" query section: `dim_experience_management` first-appearance scan (authoritative) plus `product_rankings_features` fallback. Data-driven trigger, no Slack input required.
- New "Same-period vs different-period external metrics" section: prevents fabricated YoY figures while allowing external reframing context via the Layer-1 Slack citation format.

**`references/actions.md`** — c005
- New Root Cause 11: Catalogue change (bidirectional decline/improvement actions).
- New "Improvement direction — action templates" library: Protect, Extend, Investigate-headwind sub-templates.
- New "Slack-corroboration upgrade on decline actions" rule.

**`evals/evaluator.md`**
- New "Direction-aware scoring note" — semantic translation guide for improvement RCAs.
- Theme 3 (Investigation Effort) gains structural-delta-based depth calibration: shallow investigation is correct for small structural deltas (<+0.15pp).

**`templates/report.html`**
- `.ref-link` CSS added to the shared template, with usage guidance comment.
- `html { scroll-behavior: smooth }` and `.analysis-block:target` highlight added.

---

## [v1.11] — 2026-05-21 — Slack context layer (retroactive entry)

**Summary:** Added Slack context layer to the investigation. A fire-and-forget sub-agent is spawned at the top of Step 2 (after `summary.json` is read, before the data-driven investigation starts) and runs three searches: CE-specific global (pre_start − 14 days → post_end), market channel read (pre_start → post_end), and #tf-bugalert (post_start − 2 days → post_end). Output written to `<run_dir>/slack_context.md` in four buckets: Platform/Bug, Supply/Inventory, Campaign/Traffic, CE-specific mentions. The main agent never waits for it — Slack is consulted only at Step 2b. Step 2b gains check #9 (Slack context reconciliation) with corroborate / test gap / reject classification. `report_structure.md` gains optional 5th "Source" column in hypotheses explored table and inline citation format. Sub-agent instruction set lives in `references/slack_context_guide.md`. *(This entry was missed when the v1.11 commit was pushed on 2026-05-21; added retroactively for completeness — see SKILL.md c028 for full file-level detail.)*

---

## [v1.10] — 2026-05-21 — Parallel first-pass batch, cross-cut investigation, inventory/completeness improvements

**Summary:** Three sets of changes bundled together. (1) First-pass branch set now runs via parallel sub-agents — each sub-agent receives only the SQL, an output path, and an explicit output contract (no reference files), enforcing context isolation. Main agent writes all SQL before spawning, waits for the full batch, then synthesises from the combined picture. Batch JSONs saved to `<run_dir>/batch_<cut_name>.json`. (2) Cross-cut added as a first-class investigation step with a formal trigger rule (≥8pp absolute or ≥20% relative), enumerated cross-cuts by funnel step, and a generic 2-dimension query template in `context.md`. (3) Inventory queries overhauled: period-median queries (APPROX_QUANTILES) replace single-date snapshots, bridge table fixed to `dim_experience_management WHERE variant_status = 'Active'`, time-series interpretation rewritten with trend-based classification, multi-TGID verdict patterns added to `report_structure.md`. Investigation completeness rules tightened across SKILL.md c022–c027.

### Changes by file

**`SKILL.md`** — c027
- "Run all branches within a level in parallel" replaced with a five-step spawning protocol. Each sub-agent receives exactly: complete SQL, output path (`<run_dir>/batch_<cut_name>.json`), and output contract. No reference files passed — context isolation enforced. Main agent waits for all results before synthesising. Transcript section opened before spawning, results filled after batch completes. Failure handling: missing JSON = DATA PULL FAILURE, log and continue, do not re-query inline. Applies to first-pass branch set only; deeper levels remain sequential.

**`references/context.md`**
- Cross-cut query template: generic 2-dimension query, funnel step substitution table, worked A2O example (`device_type × experience_id`).
- Inventory period-median queries (APPROX_QUANTILES across all extracted_dates in window) replace single-date snapshots.
- Bridge table fixed from `dim_tours` to `dim_experience_management WHERE variant_status = 'Active'`.
- Time-series interpretation guide rewritten: trend-based classification (sustained depression, onset event, gradual decline, episodic dips). Artifact detection rule for synchronised zeros.

**`references/hypothesis.md`**
- Cross-cut section: trigger rule (≥8pp absolute or ≥20% relative), common cross-cuts by funnel step (A2O, S2C, LP2S, C2A), three-outcome interpretation guide.
- TGID selection simplified to judgment-based language (removed rigid Case A/B/C).
- TID scoping rule: single depleted TID → individual scope; multiple depleted → TGID aggregate; mixed → depleted only.
- Inventory jargon firewall note added before inventory sequence.

---

## [v1.9] — 2026-05-20 — URL breakdown query, S2C secondary-driver scoping, Section 3 ordering, action card quality gates

**Summary:** Five connected quality upgrades, most motivated by gaps identified in recent CE 2330 and CE 189 evaluations. A dedicated URL breakdown query (`pct_of_lp` CTE) is added to `context.md` and wired into `hypothesis.md` and `report_structure.md` — replacing the canonical L2+ query wherever URL routing vs performance disambiguation is needed. `hypothesis.md` gains a secondary-driver scoping block for S2C (prevents unnecessary first-pass branches when S2C is not the primary driver) and a C2O experience-routing follow-up sequence. `report_structure.md` gains a fixed Section 3 ordering, a URL-level breakdown HTML block, an action card evidence threshold rule, and multi-step "What broke?" examples. `actions.md` gains a DATA GAP template for the RC9 unresolved A2O mechanism case. `SKILL.md` gains two new findings-gate items: fixed-segment reflection check and action card data-accessibility check.

### Changes by file

**`SKILL.md`**
- **Depth vs completeness clarification** — Added a note below the branch completeness rule: the rule is about map coverage, not depth. A one-line closure ("same mechanism as C2O — CONFIRMED" or "A2O within-experience improvement: mechanism untested — DATA GAP") satisfies completeness without requiring a full investigation branch for every minor quantified signal.
- **Findings gate item 6 — Fixed segment reflected in analysis** — New checklist item: if a fixed segment was declared at the end of the mix cascade, verify that L2+ queries actually apply those filters. If a broader cut was used as a proxy, note it explicitly and confirm it is a reasonable approximation. No silent mismatches between the declared segment and the data used.
- **Findings gate item 7 — Action cards reference accessible data** — New checklist item: before writing an action card that asks a team to investigate a specific period or data point, confirm that data is reachable via analytics. If it falls outside a rolling window or a backlogged table, name an alternative source (availability system logs, supplier contracts) so the DRI knows where to look.

**`references/context.md`** — c026
- Added dedicated URL breakdown query immediately after the canonical L2+ query pattern. The new query adds a `totals` CTE that computes `pct_of_lp` — each URL's share of CE LP traffic per period. Required to distinguish routing shifts (traffic moved between URLs, rates held) from performance shifts (a URL's own rate dropped, share held). The canonical L2+ query cannot answer the routing question. Carries all fixed segment filters from the cascade declaration; sorts by `users_lp DESC`.

**`references/hypothesis.md`** — c016, c017
- **c016 — S2C secondary-driver scoping block** — Added at the top of the S2C section: when S2C is a secondary driver (primary is C2O or LP2S), run the fixed-segment aggregate first. If flat/improved outside the fixed segment → close as RULED OUT. If declined but directionally explained by the primary finding → close as CONFIRMED with one-line explanation. Only open the full first-pass branch set if S2C shows an independent decline not explained by the primary mechanism. Prevents unnecessary dimension cuts on secondary steps.
- **C2O experience routing follow-up** — When C2O improved via an experience routing shift, two directional follow-up checks added using `product_rankings_features`: pricing signal (compare `final_price_usd` for gaining vs losing experience pre/post) and availability signal (compare `days_to_first_available_date`). Both are directional; if neither explains the shift, flag as DATA GAP rather than forcing a mechanism claim.
- **c017 — URL concentration pointer updated** — URL concentration cross-cutting check now points to the dedicated URL breakdown query from `context.md` instead of the canonical L2+ query. Reason: the section requires `pct_of_lp` to distinguish routing vs performance stories; the canonical query does not produce that column.

**`references/actions.md`** — c004
- **RC9 DATA GAP action template** — Added a template action card for when the A2O locus is confirmed but the specific mechanism is unresolved because `order_attempted_events_v2` was not queried (backlogged). Template provides: a specific BQ query scope (experience ID + post period), and three sub-hypotheses for the DRI to test (inventory sync failure → Ops/Engineering; gateway decline → Payments; fraud over-blocking → Payments rule audit). Ensures the DRI receives a starting hypothesis rather than generic "investigate further" text.

**`references/report_structure.md`** — c021, c022, c023, c024
- **c021 — Section 1c "What broke?" multi-step examples** — When multiple funnel steps each carry >15% Shapley share, name all of them in one sentence. Two examples added: one for multi-step same-mechanism case, one for multi-step different-mechanism case. Cross-reference note added under "Why did it break?" requiring seasonal/event-based framing to be paired with a specific data signal (traffic pattern, daily CVR break, or controlled comparison).
- **c022 — Action card evidence threshold** — Before creating a standalone action card, verify both the rate drop and raw event count. A directional signal from a small sample belongs as a sub-bullet inside the most relevant existing P1/P2 card, not a standalone card. Example sub-bullet wording provided.
- **c023 — Section 3 fixed ordering** — "What belongs in Section 3" now specifies a numbered fixed order for always-present blocks: (1) mix cascade + Fixed Segment banner, (2) Geo/Non-Geo, (3) Shapley, (4) daily trend, (5) primary driver cuts, (6) secondary driver evidence, (7) ruled-out dimensions, (8) hypotheses explored. Conditional blocks (inventory, session recordings, price) slot within primary driver evidence.
- **c024 — URL-level breakdown block HTML pattern** — New section before the inventory section format. Two verdict forms: performance verdict (rate dropped, share held) and routing verdict (share shifted, rates held). Table columns: URL · Period · Users · % of LP · LP2S · S2C · C2O · CVR. `.highlight-row` on URLs where rate dropped meaningfully or `pct_of_lp` shifted substantially. Pointer to the dedicated URL breakdown query in `context.md`.

### Test runs

Three new runs added (`v1.9`):
- **ce189_2026-04-09_2026-05-06** (Vatican Museums) — 31/35. Post-Easter seasonal composition shift confirmed as root cause; supply definitively ruled out (both limited-capacity TIDs show zero tickets in both pre and post periods). Remaining gaps: daily trend charts not filtered to fixed segment; no controlled comparison excluding Italian national holidays.
- **ce2330_2026-03-13_2026-05-12_run2** (Walt Disney World Orlando) — 28/35. Dual-driver: spring break → off-season demand shift (primary) + Magic Kingdom A2O failure for experience 36344 (secondary, DATA GAP pending order_attempted_events_v2). Run 2 closes all three execution errors from Run 1. Remaining gaps: Fixed Segment banner not rendered as standalone HTML component; cross-cut (Android Mweb × experience × A2O) not run.
- **ce6495_2026-03-13_2026-05-12** (Kualoa Ranch) — 27/35. Near-term inventory depletion of UTV Raptor Tour (TID 80074) confirmed as root cause via Jurassic Zipline inverse confirmation. Main gap: C2O branch not opened despite 22% Shapley share.

---

## [v1.0] — 2026-04-27 — Initial release

**Summary:** First versioned release of the CVR-RCA skill. Establishes the full investigation framework, reference files, SQL pipeline, rendering helpers, and evaluation rubric.

### What's included

**Core skill (`SKILL.md`)**
- Full 4-step investigation framework: baseline pipeline → investigation → report → self-evaluation
- Three mandatory pre-investigation questions: routing vs conversion (Q1), primary Shapley driver (Q2), sudden vs gradual onset (Q3)
- Worked example showing both a mix-dominant path and a funnel-conversion path
- Investigation transcript requirement (`transcript.md`) — every decision fork logged with hypothesis, data, decision, and ruled-out paths
- Custom query patterns for all available dimensions (`browsing_country`, `channel_name`, `lead_time_days`, `page_sub_type`, `previous_page_url`, cross-dimensional cuts)
- Mixpanel session recording integration for URL-level qualitative confirmation

**Reference files (`references/`)**
- `context.md` — full business domain vocabulary, table schemas (`mixpanel_user_page_funnel_progression`, `product_rankings_features`, `dim_combined_entities`, `dim_experiences`), column-level notes, counting rules, and analytical definitions
- `hypothesis.md` — 10 historical patterns drawn from 21 Headout MMPs, ranked by frequency across LP2S/S2C/C2O/mix scenarios; framed as priors to orient (not constrain) hypothesis generation
- `actions.md` — 10 root-cause-to-action mappings with DRI, priority, and historical references from real Headout RCAs
- `report_structure.md` — fixed three-section layout (Executive Summary → Actions → Supporting Analysis) with hard constraints, anti-pattern list, and length calibration table

**SQL pipeline (`references/`)**
- `q0_meta.sql` — CE name and top page URL
- `q1_base.sql` — base funnel by MB/HO × Channel × Period with CE-level ALL row
- `q2_dimensions.sql` — device, language, page_type cuts
- `q3_trend.sql` — daily CVR trend for pre and post periods
- `q4_experience.sql` — experience-level S2C and CVR breakdown
- `q5_price.sql` — price analysis (final vs original price, median, pre/post comparison)
- `q6_urls.sql` — top 20 page URLs by LP traffic volume with per-URL funnel rates

**Scripts (`scripts/`)**
- `run_analysis.sh` — orchestrates Q0–Q6, runs Q2–Q6 in parallel, produces `summary.json`
- `aggregate.py` — computes Shapley decomposition, mix vs conversion effects, C2O sub-decomposition, rolls up all stage JSON into structured `summary.json`
- `render.py` — HTML component helpers: metric cards, trend charts, experience tables
- `helpers.py` — shared utilities

**Report template (`templates/`)**
- `report.html` — base HTML template for rendered reports

**Evaluation rubric (`evals/`)**
- `evaluator.md` — 7-theme rubric (Narrative Coherence, Hypothesis Specificity, Investigation Effort, Branch Decision Quality, Evidence Strength, Output Appropriateness, DRI Actionability) scored 1–5 with evaluation file format
- `evals/runs/` — persistent record of past evaluations (accumulates across runs)

### Internal changelogs at time of initial release

The following changelog entries were already tracked inside individual reference files before the repo was created:

**SKILL.md**
| # | Date | Change |
|---|------|--------|
| c001 | 2026-04-24 | Initial version — investigation framework, 3 mandatory questions, Shapley, mix decomp, custom query patterns, render.py integration, Step 4 evaluator |
| c002 | 2026-04-24 | Added `report_structure.md` to "Before you begin" reads; updated file role descriptions; clarified `hypothesis.md` as historical priors not a constraint; replaced Step 3 guidance with pointer to `report_structure.md`; updated Backlogs for A2O query columns |

**`hypothesis.md`**
| # | Date | Change |
|---|------|--------|
| c001 | 2026-04-24 | Initial version — 10 patterns from 21 historical Headout MMPs |
| c002 | 2026-04-24 | Added "How to use this file" preamble; clarified patterns are priors not a constraint; Claude generates its own hypotheses from data |

**`actions.md`**
| # | Date | Change |
|---|------|--------|
| c001 | 2026-04-24 | Initial version — 10 root causes from 21 Headout MMPs and CVR Cause-to-Action Playbook |
| c002 | 2026-04-24 | RC1: competitive intel skill pointer added. RC2: inventory skill pointer added. RC8: pax setup skill pointer added. RC9: `order_attempted_events_v2` column detail added. RC10: content audit sub-skill pointer added |

**`report_structure.md`**
| # | Date | Change |
|---|------|--------|
| c001 | 2026-04-24 | Initial version — three-section report structure extracted from SKILL.md Step 3 and formalized |

---

## [v1.1] — 2026-04-27 — Process/domain separation

**Summary:** The skill was refactored to enforce a clean separation between *process* (what steps to follow and when to pivot) and *domain knowledge* (how to interpret data, what patterns to look for, how to write queries). `SKILL.md` is now a lean process orchestrator. `context.md` is the domain knowledge hub. A new `worked_example.md` file houses the two end-to-end investigation walkthroughs.

This makes the skill easier to maintain: process changes update `SKILL.md`, analytical guidance updates `context.md`, and neither bleeds into the other.

### Changes by file

**`SKILL.md`** (c003 → c007)
- **c003:** Added majority-contributor principle (focus on entities with meaningful CE traffic share, not long-tail noise) and rate × volume rule (impact = rate delta × user volume, not rate delta alone). Strengthened session recordings from optional to required once a locus is confirmed; skipping must be explicitly justified in the report.
- **c004:** Fixed session recordings trigger from conjunctive (URL *and* experience *and* segment) to disjunctive (any concentrated dimension cut is sufficient). Added "Data pull errors — log and continue" section: query failures are logged in the transcript and noted in the report as data gaps; the investigation does not halt.
- **c005:** Updated report visual standard; added P1/P2/P3 priority badges to action cards.
- **c006:** Removed references to Q2/Q4/Q5/Q6 as pre-built templates to run; fixed stale `summary.json` field references in investigation patterns. All custom querying is now framed as write-from-scratch using `context.md` schemas.
- **c007:** Stripped `SKILL.md` to pure process orchestration. All domain content moved out:
  - Query rules, dimension guidance, investigation patterns per funnel step → `context.md`
  - Both worked examples → `references/worked_example.md`
  - Q3 (onset type) expanded from two branches to three (sudden / gradual / seasonal); full interpretation guide lives in `context.md`

**`references/context.md`** (c002)
- Added **Query Principles** section: majority-contributor principle and rate × volume rule (moved from SKILL.md, formalized as domain rules)
- Added **Q3 Trend Interpretation** guide: how to read each 90-day trend shape (sharp break / gradual erosion / recovery in progress), how to use the LY overlay and `structural_delta_cvr` to calibrate investigation depth, and weekday composition check
- Added **Dimensions to Query and When**: `browsing_country`, `browsing_city`, `channel_name`, `lead_time_days`, `page_sub_type`, `previous_page_url`, cross-dimensional cuts, experience-level with availability proxy — each with the hypothesis context that makes it worth querying
- Added **Common Investigation Patterns**: per-funnel-step query angles for mix, LP2S, S2C, and C2O drivers (moved from SKILL.md, expanded)
- Added **Session Recordings** guidance: structured table format (Recording | Steps observed | Inference) rather than prose; inference column must state what each recording proves or rules out

**`references/worked_example.md`** (new file)
- Two complete end-to-end investigation walkthroughs extracted from `SKILL.md`:
  - **Example 1:** Mix-dominant story — MB traffic share shift explains the CVR drop; no funnel step broke; report covers mix table and URL traffic comparison only
  - **Example 2:** Conversion-dominant, concentrated locus — S2C drop, sharp Apr 8 onset, French × iOS Mweb cross-cut, session recordings confirming empty date picker; shows how the investigation narrows from CE-wide to one experience on one locale

---

## [v1.2] — 2026-04-27 — Default analysis window changed to 30 days

**Summary:** The skill previously required explicit date arguments every time it was invoked. Dates are now optional — when omitted, the script automatically uses the last 30 days as the post period and the 30 days before that as the pre period. This removes the most common friction point when starting a quick investigation.

### Changes by file

**`SKILL.md`** (c009)
- Invocation syntax updated from required `<pre_start> <pre_end> <post_start> <post_end>` to optional `[<pre_start> <pre_end> <post_start> <post_end>]`
- Added one-line note explaining the default: last 30 days = post, prior 30 days = pre

**`scripts/run_analysis.sh`** (c002)
- Date arguments are now optional. When not supplied, the script computes: `POST_END` = yesterday, `POST_START` = 30 days ago, `PRE_END` = 31 days ago, `PRE_START` = 61 days ago
- Added cross-platform `_date_offset()` helper that works on both BSD `date` (macOS) and GNU `date` (Linux)
- Script now prints the resolved date windows at the end of every run so it is always visible which periods were used
- Cleaned up header comments: removed stale Q2/Q4/Q5/Q6 "demoted" note that no longer applies

---

## [v1.3] — 2026-04-28 — Investigation tree model + unified run folder

**Summary:** Two significant upgrades in this release. First, the investigation model was rewritten from a sequential three-question gate into a parallel investigation tree (L0 → L1 → leaf), making the analytical reasoning faster and more structured. Second, all run outputs (report, transcript, evaluation, findings, raw data) are now consolidated into a single persistent folder per run, with date-range naming and auto-increment to prevent overwrites.

### Changes by file

**`SKILL.md`** (c012 → c016)
- **c012 — Investigation tree model:** Replaces the sequential Q1/Q2/Q3 gate model with a tree structure. L0 reads all three orientation signals simultaneously (`mix_dominance`, `shapley`, `trend_context`). L1 opens a parallel hypothesis batch based on L0 signals. Each result either confirms (open L2), rules out (close branch), or concentrates (anchor all downstream queries). Investigation terminates at a leaf: a specific mechanism × segment/experience/URL × date. Transcript format mirrors the tree with `## L0`, `## L1`, `## L2`, and `## Root cause confirmed` sections.
- **c013 — Tree map in transcript:** Transcript now has two layers — a tree map block at the top showing the full branch structure (`CONFIRMED / RULED OUT / OPEN / LEAF` per branch) and detail sections below with query results. Tree map is written after L0 with all L1 branches marked `OPEN` and updated as results arrive. Anyone reading the transcript sees the investigation shape immediately without scrolling.
- **c014 — Date range in output directory name:** Output folder renamed from `/tmp/cvr_rca_<ce_id>/` to include the date range (e.g. `ce167_2026-03-01_2026-04-29/`). Running the same CE twice with different windows no longer silently overwrites results.
- **c015 — Consolidated run folder:** All outputs for a run now live in one persistent folder: `~/Documents/RCA skill/Test Runs/ce<ce_id>_<pre_start>_<post_end>/`. Previously, outputs were scattered across `/tmp/`, `~/Documents/RCA skill/transcripts/`, and `~/Documents/RCA skill/evals/`. Report, transcript, evaluation, findings, and raw pipeline data are all co-located.
- **c016 — Auto-increment on folder collision:** If the named run folder already exists (same CE + same dates run twice), the script auto-increments the suffix: `_run2/`, `_run3/`, etc. The chosen folder name is printed at the start of the run. SKILL.md now uses `<run_dir>` shorthand throughout so the naming logic is explained once in Step 1 and not repeated.

**`references/context.md`**
- Added **"Investigation tree — L0 to L1 branch map"** section: a lookup table mapping each combination of L0 signals (mix dominant / LP2S primary / S2C primary / C2O primary / gradual / sudden) to the default set of L1 branches that should open. Removes the need to derive the branch set from first principles on every run.

**`references/worked_example.md`**
- Both examples (mix-dominant and conversion-dominant) rewritten with tree-format transcripts: parallel query batches made explicit, session recordings anchored to L2 leaf, tree map blocks included showing branch resolution.

**`scripts/run_analysis.sh`**
- Output directory updated to `~/Documents/RCA skill/Test Runs/ce<ce_id>_<pre_start>_<post_end>/`
- Auto-increment logic added for folder collisions
- Prints resolved run folder name at start of execution

**`scripts/aggregate.py`**
- Docstring example updated to reflect new output directory pattern

**Removed**
- `assets/headout-logo.svg` — unused since `render.py` was removed in a prior release
- `templates/report copy.html` — stale duplicate, superseded by `templates/report.html`

---

## [v1.4] — 2026-04-29 — Mix cascade, self-extending branches, hypothesis.md restructure

**Summary:** Three interlocking upgrades that make the investigation more rigorous and faster to execute. First, the mix cascade is now a mandatory L1 step that runs before any funnel hypothesis — it fixes the primary segment (MB/HO → Paid/Organic → Channel) so all downstream funnel analysis describes a homogeneous cohort. Second, hypothesis generation is now explicitly self-extending: branches grow level-by-level from what the data shows, not from a pre-written list, and a new "Surprises" result type forces investigation of unexpected findings. Third, `hypothesis.md` is restructured as the central branch reference for the entire investigation — it now owns both the L0 routing map and the first-pass branch sets (moved from `context.md`), keeping `context.md` focused on business vocabulary, schemas, and query rules only.

### Changes by file

**`SKILL.md`** (c017 → c020)
- **c017 — Mix cascade as mandatory L1:** Before forming any funnel hypothesis, run a three-level mix cascade (Level 1: MB vs HO from `summary.json`; Level 2: Paid vs Organic custom BQ query; Level 3: Channel breakdown within Paid). Fixed segment declared once in the transcript; all L2+ queries carry that segment's filters. L1 and L2+ step names updated accordingly.
- **c018 — Self-extending hypothesis loop:** L2+ branches grow from what the data shows, not from a fixed upfront list. Four result types formalised: Confirms, Rules out, Concentrates, and Surprises. "Surprises" is new — an unexpected result generates a new branch even if it wasn't in the default set. Investigation ends at the leaf, not at list exhaustion.
- **c019 — Remove stale artifact:** Removed "write 2–4 specific, falsifiable hypotheses" from L2+ — a leftover from the old Q1/Q2/Q3 model that contradicted the tree structure.
- **c020 — File role descriptions updated:** `context.md` role narrowed to business vocabulary, schemas, and query rules. `hypothesis.md` described as the two-level central branch reference (L0 routing + first-pass branch sets + historical patterns). L2+ pointer updated from `context.md` → `hypothesis.md`.

**`references/context.md`** (c004 → c009)
- **c004/c005 — Inventory table schemas:** Added `analytics_reporting.inventory_availability` and `analytics_intermediate.inventory_changes` with full column-level notes, join path (the two-hop `dim_experiences → dim_tours → inventory_availability` bridge), and lead-time bucket query. Bucket boundaries carry inline guidance to adapt to each CE's booking horizon. Results interpretation covers both window-specific and uniform-decline patterns.
- **c006 — Mix Cascade section:** Full three-level cascade added with BQ query templates for Level 2 (Paid/Organic) and Level 3 (Channel breakdown within Paid), decision rule for when to fix a level (>15% post share + dominant checkout impact), and fixed segment declaration template with filter strings.
- **c007 — Investigation patterns expanded:** LP2S gains three-tier triage (dimension cuts → pricing if no concentration → sessions as fallback). S2C gains language × S2C and device × S2C as first-pass cuts before experience-level; inventory lead-time bucket query integrated into S2C path. C2O expanded with four C2A hypotheses (pax availability, price friction, UX change, sessions) and three A2O hypotheses (gateway failure, fraud tightening, live inventory sync failure) with named DRIs.
- **c008 — Common Investigation Patterns header rewritten:** "Not rails" disclaimer replaced with explicit loop logic — patterns are the default starting set, results generate the next hypothesis, investigation ends at the leaf not at list exhaustion. Three reasons a list runs out before a leaf is reached added.
- **c009 — Moved investigation logic to hypothesis.md:** "Investigation tree — L0 to L1 branch map" and "Common Investigation Patterns" sections removed from `context.md` and moved to `hypothesis.md`.

**`references/hypothesis.md`** (c004)
- **c004 — Restructured as two-level branch reference:** Level 1 (L0 routing map + first-pass branch sets by funnel step) added at the top, moved from `context.md`. Level 2 (historical patterns 1–10) retained and explicitly labelled as "mechanism detail by scenario" — used once a first-pass branch confirms a direction. "How to use this file" updated to reflect full role as the central branch reference for all investigation levels.

**`references/report_structure.md`** (c006 → c010)
- **c006/c007 — Positive CVR framing:** New green-border callout variant for CVR-improvement investigations: heading "CVR Improved — What's Driving It & What's Holding It Back" with three questions (What drove the improvement? What's holding it back? When did the headwind emerge?).
- **c008 — 90-day chart to Section 1:** Chart moves from Section 3 (conditional) to Section 1 (always), appearing after metric cards and before the root cause callout. Post-window shade is green for improvements, red for declines.
- **c009 — Fixed Segment banner:** New HTML component after mix cascade output, before Shapley block. Declares `MB/HO · Paid/Organic · Channel` scope for all downstream funnel analysis.
- **c010 — Raw user counts mandatory:** All tables showing rates or shares must include Pre Users and Post Users columns. "Table shows rates/shares with no user counts" added to anti-patterns list.

---

## [v1.8] — 2026-05-07 — context.md/hypothesis.md structural separation + presentation-layer jargon fixes

**Summary:** Two connected changes. First, investigation decision logic was moved out of `context.md` and into `hypothesis.md`, restoring the intended separation: `context.md` owns business vocabulary, table schemas, and SQL queries; `hypothesis.md` owns the investigation decision tree (when to run what, how to interpret results, which branches to open). Second, three presentation-layer bugs were fixed in `report_structure.md` that were allowing internal investigation terminology to leak into the HTML report, and raw tables to appear where Plotly charts should be.

### Changes by file

**`references/context.md`** — c019

- **Structural separation:** Removed all investigation decision logic from the inventory section. What moved out: TGID locus identification (Case A/B/C + `lost_checkouts_delta` formula), the "before running, determine which path applies" decision framing, the TID scoping decision block ("use Step 2 results to decide single TID vs whole TGID"), and the broad-drop inventory path (Case C).
- **Queries renamed:** "Step 2 — TID summary table" → "TID snapshot query"; "Step 3 — Daily time-series" → "Daily time-series query". The numbered "Step" labels were investigation-layer jargon, not neutral query names.
- **Data availability facts retained neutrally:** Path A/B/X information rewritten as data facts ("`inventory_availability` retains a 30-day rolling window — if `pre_start < CURRENT_DATE − 30`, no pre-period rows exist") without the decision framing. The decision about which path to use now lives in `hypothesis.md`.
- **Pointer added:** "For TGID selection and the inventory investigation decision tree, see `hypothesis.md → S2C investigation → inventory branch`."

**`references/hypothesis.md`** — c007

- **"If experience concentrates" branch now owns the full inventory investigation sequence:** (1) TGID selection via `lost_checkouts_delta` + three-case classification (single dominant TGID ≥60% / multiple significant TGIDs ≥10% each / uniform drop); (2) data availability check before querying; (3) optional gradual-decline pre-check with `days_to_first_available_date`; (4) TID snapshot query usage (flag unlimited-capacity TIDs, scope the time-series); (5) daily time-series query usage (primary evidence — always run); (6) supply confirm/rule-out decision (healthy throughout post → pivot to pricing; depleted during post → supply is mechanism).
- **Broad-drop path moved here:** When no TGID accounts for ≥10% of `lost_checkouts_delta`, pick the top 3 TGIDs by `users_select` volume and run the inventory queries for each. Same bucket depleted across all three → CE-wide supply constraint; tickets healthy across all three → not supply.
- **"Step 2/3" label references removed throughout** — queries now referenced as "TID snapshot query" and "daily time-series query".

**`references/report_structure.md`** — c012

- **Supply gate wording:** Removed "Step 2" reference; the ruled-out verdict is now framed in terms of what the time-series showed, not internal step labels. Clarified that line charts may still be shown in the supply-ruled-out case as positive confirmation (lines staying above zero is visual evidence, not just a claim). TID snapshot table is omitted when supply is ruled out.
- **Anti-pattern added — Investigation-internal terminology:** Step 1/2/3, Path A/B, Case A/B/C, "locus", "lost_checkouts_delta", "candidate TGIDs" must not appear anywhere in the HTML report. These are transcript terms. In the report: "the three most-affected experiences" not "the Case B candidate TGIDs"; "supply checked and ruled out" not "Step 3 confirmed supply ruled out".
- **Anti-pattern added — Daily inventory as HTML table:** A 27-row × 4-column date table is unreadable at a glance. Daily inventory time-series is always Plotly line charts. The only table in the inventory section is the TID snapshot summary.

---

## [v1.6] — 2026-05-06 — Inventory analysis overhaul + Geo/Non-Geo dimension + Mix arithmetic guide

**Summary:** Three separate upgrades shipped together. First, the inventory analysis methodology was comprehensively overhauled: the old `count_days_available_30d` proxy is gone, replaced by direct TID-level queries against `inventory_availability` with a structured three-step path (locus identification → TID snapshot → daily time-series). The query was also corrected for two bugs (CE-wide scope, sold-out overcounting). Second, a Geo/Non-Geo dimension was added as a first-pass S2C and LP2S cut, and the mix cascade investigation path was expanded with a worked arithmetic guide and a canonical L2+ query template. Third, a new `events.md` reference file documents all GTM/Mixpanel funnel events.

### Changes by file

**`references/context.md`** — c012, c013, c014, c015

- **c012 — Mix cascade query fixes and arithmetic guide:** Fixed `COUNTIF` → `COUNT(DISTINCT CASE WHEN)` in Level 2/3 cascade queries and the canonical L2+ template. Added `PERFORMANCE_MAX` exclusion to Level 2/3 queries. Added `mix_effect`/`conversion_effect` arithmetic guide with step-by-step formula and a Level 3 worked example showing how to confirm which cascade level is the routing driver.
- **c012 — Canonical L2+ query template:** Added a single annotated template that carries the fixed segment filters through all Level 2+ funnel queries — prevents the fixed segment from being silently dropped on custom cuts.
- **c013 — Geo/Non-Geo dimension:** Added browsing country as a pre-step dimension. CE country identified from `dim_experiences.country`; query returns top-5 countries always plus the CE's home country. Interpretation guide covers Geo-only drop (demand shift or regulatory), Non-Geo-only drop (paid search or content), and mixed drops. Cross-dimensional intersections added (Geo × device, Geo × channel).
- **c014 — Inventory query scope bug fix:** Corrected a CE-wide scope bug where the query fetched all `tour_id`s for the CE instead of filtering to the confirmed TGID. Fixed by filtering `dim_tours` to `experience_id = '<tgid>'` before joining `inventory_availability`.
- **c014 — Inventory sold-out overcounting fix:** `COUNTIF(total_remaining = 0)` operated at TID × date grain — a date where one TID was sold out but others had capacity was incorrectly counted as zero-inventory. Fixed by adding a `tgid_daily_inventory` CTE that sums remaining across all TIDs per date before bucketing. A date is only counted as sold out when the sum across all TIDs for that date is zero.
- **c015 — Inventory analysis complete rewrite:** Removed `count_days_available_30d` as the inventory signal; replaced with direct `inventory_availability` queries throughout. Restructured as a three-step path:
  - **Step 1 — Locus identification:** Compute `lost_checkouts_delta = users_select_post × (s2c_rate_pre − s2c_rate_post)` for each TGID from Q4 results. Three cases: Case A (single TGID ≥60% of total delta — that TGID is the locus), Case B (2–3 TGIDs each ≥10% — multiple loci, run Step 2 for each), Case C (no TGID ≥10% — uniform drop, see broad-drop path).
  - **Step 2 — TID summary table:** Snapshot from the latest `extracted_date`. One row per TID. Ticket counts (sum of `total_remaining`) bucketed into 0–2d, 3–7d, 8–13d, 14–30d windows. Computes `is_fully_unlimited_capacity` — TIDs with this TRUE must be excluded from supply scarcity analysis (unlimited-capacity slots represent `total_remaining = 1` as a system constant, not actual ticket count).
  - **Step 3 — Daily time-series:** Tracks `extracted_date` trend per TID per bucket. Path B (pre within 30-day window): pre and post series overlaid. Path A (pre outside 30-day window): post only with an explicit data-unavailability note.
  - **Path A vs Path B determination** added at the top of the section; determines whether pre/post comparison or snapshot-only is possible.
  - **Broad-drop inventory path (Case C):** When S2C drops uniformly across all experiences with no concentration, pick the top 3 TGIDs by `users_select` volume from Q4 and run Step 2 for each. Same bucket depleted across all three → CE-wide supply constraint. All full → supply is not the mechanism.
  - **Supply gate:** If Step 2 shows no depletion across limited-capacity TIDs, do not run Step 3; pivot to pricing or UX instead.
  - Removed `count_days_available_30d` from `product_rankings_features` schema table.

**`references/hypothesis.md`** — c016

- All references to `count_days_available_30d` as an availability signal replaced with `inventory_availability` TID summary table (Step 2 from context.md).
- **Gradual S2C decline:** Added `days_to_first_available_date` as a fast directional check before running inventory queries — an increasing trend confirms supply scarcity direction without a full TID query.
- **CE-wide S2C drop (no concentration):** Updated to point to the broad-drop inventory path (top 3 TGIDs by volume, Step 2 for each).
- **Vendor throttling pattern:** Signal updated from `count_days_available_30d` to `days_to_first_available_date` + 0–2d bucket ticket count from TID summary table.
- **Experience-specific availability collapse:** Updated to run `inventory_availability` TID summary table and daily time-series instead of `count_days_available_30d`.

**`references/actions.md`** — c017

- RC2 (Inventory/availability constraint) signal updated: removed `count_days_available_30d` reference; replaced with `inventory_availability` TID summary table (near-zero ticket counts in one or more lead-time buckets) as the primary signal.

**`references/report_structure.md`** — c018

- "What belongs in Section 3" table: replaced "Availability proxy table" and "Inventory lead-time bucket table" rows with "Inventory TID summary table" (Step 2, one row per TID) and "Inventory daily time-series charts" (Step 3, one chart per lead-time bucket).
- Section renamed from "Inventory lead-time bucket table format" to "Inventory section format".
- Verdict forms updated from "window-specific spike / counts_zero_inventory" to "window-specific drop / ticket counts near zero".
- Added supply gate outcome instruction: write a ruled-out callout and skip the table/charts entirely if Step 2 finds no depleted limited-capacity TIDs.
- Added Path B spec: one row per TID, Pre/Post column pairs per bucket, `Capacity type` column, `highlight-row` on TID rows where the affected bucket pair shows the material drop, unlimited-capacity TIDs excluded from table with subtext note.
- Added Path A spec: post-only columns, amber note above table stating pre-period unavailability.
- Added daily time-series chart spec: four charts (one per bucket), Path B overlays pre/post, Path A post only.
- Updated subtext guidance: state pattern, when it started, what supply team should verify. No mechanism assertions.
- HTML pattern replaced: old format (rows per bucket, aggregate columns) replaced with two separate patterns — Path B (rows per TID, Pre/Post bucket columns) and Path A (rows per TID, post-only columns). Each with correct `highlight-row` usage and capacity-type column.

**`references/q1_base.sql`** — c019

- Removed `MAX(CASE WHEN page_type IN (...) THEN 1 ELSE 0 END) AS visited_lp` from SELECT; condition moved to WHERE clause. Fixed `GROUP BY 1, 2, 3, 9` → `GROUP BY 1, 2, 3, 8` to reflect the column count change.

**`references/worked_example.md`** — c020

- Removed `count_days_available_30d` from the S2C locus identification section (Example 2).
- Added TID summary table query result to the transcript: shows `tickets_8_13d` and `tickets_14_30d` → 0 for all TIDs of TGID 8821, confirming the 8+ day window as the affected bucket.

**`references/hypothesis.md`** — c021 (mix routing exit)

- Mix routing exit path rewritten as a 3-level investigation: Level 1 (time the shift — when did the MB/HO mix change?), Level 2 (which sub-segment drove it — Paid/Organic/Channel?), Level 3 (URL impact — did the mix shift affect a specific landing page?). Each level has a Tier 1/2/3 structure with a declaration template.
- LP2S Tier 1: added `browsing_country` (Geo/Non-Geo) as a parallel first-pass cut with drill-down guidance.
- S2C Tier 1: added `browsing_country` (Geo/Non-Geo) as a parallel first-pass cut.
- C2O C2A: added optional Geo/Non-Geo cut for broad drops with no device/experience concentration.

**`references/report_structure.md`** — c022 (mix cascade block)

- Added Mix cascade analysis block spec: `.analysis-block` with three sub-tables (one per cascade level). Each sub-table has a verdict line, `mix_effect`/`conv_effect` columns, and `highlight-row` on the fixed segment row. Routing exit variant renders only up to the exit level — if routing exits at Level 1, only the Level 1 table is shown.

**`references/events.md`** — new file

- New reference file documenting all GTM/Mixpanel funnel events used in CVR analysis: LP events (15 + 4 supporting), S2C events (14 + 3 supporting), C2O events (15 + 8 supporting). Each event includes key properties, analytical purpose, excluded noise events, and session join key notes.

---

## [v1.5] — 2026-05-04 — Findings synthesis gate + Evaluator failure mode classification

**Summary:** Two interconnected upgrades. (1) `SKILL.md` gains Step 2b: before writing any HTML, Claude writes `findings.md` with a mandatory Evidence inventory table where every claim must name its data source — closing the main hallucination vector where approximate values replaced confirmed BQ query outputs. (2) `evaluator.md` is redesigned to diagnose *why* each gap occurred, not just *what* was missing: every gap now gets a failure mode tag backed by a grounded citation, and a new Section 4 table maps all gaps directly to actionable skill file edits.

### Changes by file

**`SKILL.md`** — c010 / c011

**Step 2b — Structured findings synthesis (c010)**
- Claude now writes `findings.md` before writing any HTML, with four required sections: Root cause (one sentence), Mechanism (causal chain), Timing (classification + evidence), Evidence inventory (table with Claim / Supporting data / Source / Confidence)
- Open items section forces explicit tracking of every Consistent with / Unverified claim — each must be resolved with a query or arithmetic, or explicitly accepted with appropriate language in the report
- Step 3 writes from `findings.md` as source of truth — not directly from raw query outputs
- Rationale: test runs showed Claude writing reports using impressions and approximations rather than confirmed numbers from the transcript. `findings.md` is the checkpoint that catches this before HTML is committed.

**Evidence inventory Source column (c011)**
- Every claim in the Evidence inventory must name its data origin: a specific `summary.json` field, a named BQ query result, or a specific table row that will appear in the report
- A number with no named source must be derived explicitly with written arithmetic or removed — it must not enter the report
- Rationale: hallucination risk was highest at the transcript → report transition. The Source column makes provenance explicit and checkable.

**Output paths**
- All output paths use `<run_dir>` shorthand (`<run_dir>/transcript.md`, `<run_dir>/findings.md`, `<run_dir>/report.html`, `<run_dir>/evaluation.md`) — consistent with auto-increment run folder naming introduced in c016.

**`evals/evaluator.md`** — e001

- **What to review** — Added skill reference files (SKILL.md, hypothesis.md, context.md, report_structure.md) as the first pre-read step, before the report and transcript. Reading the skill files first is required so the evaluator can verify whether an instruction existed before classifying a gap.
- **Scoring** — Added two new required fields per theme: `Gap` (if score ≤ 4) describing specifically what was missing or wrong; `Why` — a failure mode tag with a grounding citation.
- **Failure Mode Classification** (new section) — Defines four tags with meanings and grounding requirements: `[MISSING_INSTRUCTION]`, `[AMBIGUOUS_INSTRUCTION]`, `[EXEC_ERROR]`, `[DATA_LIMIT]`. Tag assignment without a citation is explicitly prohibited.
- **Output format** — Updated Section 2 to show inline `Gap` / `Why` blocks with a worked example. Added Section 4: Failure Mode Summary table mapping every gap to a specific file + fix description.
- **Self-honesty check** — Four grounding checks added (one per tag type): did you actually look in the skill files, quote the instruction, confirm an attempt in the transcript, verify data unavailability?

### Test runs

Two new runs added (`v1.5`):
- **ce189_2026-03-05_2026-05-03** (Vatican Museums) — 25/35. Dual-driver: S2C supply capacity pressure (spring demand exceeded fixed Vatican slot supply, confirmed via availability proxy and lead-time bucket query) + C2O iOS/Android device split (price shock + live inventory). First run evaluated against the evaluator v1.5 rubric.
- **ce6495_2026-03-05_2026-05-03** (Kualoa Ranch) — 24/35. S2C demand quality decline: spring break wind-down replaced high-intent vacationers with low-intent off-peak tourists. First run to conclusively establish seasonal demand quality as a mechanism (no supply, pricing, or UX change confirmed).

---

## [v1.7] — 2026-05-06 — Inventory analysis overhaul (TID-level queries, Path A/B, supply gate)

**Summary:** The S2C inventory analysis methodology was comprehensively rewritten. The old `count_days_available_30d` proxy from `product_rankings_features` is removed entirely; all inventory investigation now uses direct TID-level queries against `inventory_availability`. Two query bugs were fixed first (CE-wide TGID scope; sold-out overcounting via `tgid_daily_inventory` CTE). The rewrite introduces a structured 3-step path: locus identification via `lost_checkouts_delta` (Step 1), a TID snapshot table (Step 2), and a daily time-series (Step 3). A Path A / Path B determination gate handles the 30-day rolling window limitation. A supply gate prevents unnecessary deep-dives when inventory is not depleted. The investigation decision tree (part2.js) was updated to reflect all changes.

### Changes by file

**`references/context.md`** — c014 / c015

- **c014 — Inventory query bug fixes:** Fixed two bugs in the existing lead-time bucket query. (1) CE-wide scope bug: the query fetched all `tour_id`s for the CE instead of filtering to the confirmed TGID (`experience_id = '<tgid>'`). (2) Sold-out overcounting: `COUNTIF(total_remaining = 0)` operated at TID × date grain — a date where one TID was sold out but others held capacity was incorrectly counted as zero-inventory. Fixed by adding a `tgid_daily_inventory` CTE that sums `total_remaining` across all TIDs per date before bucketing; a date is only counted as zero-inventory when the sum across all TIDs is zero.
- **c015 — Inventory analysis complete rewrite:** Removed `count_days_available_30d` as the inventory signal across the entire section. Restructured as a **3-step path**:
  - **Step 1 — Locus identification:** Compute `lost_checkouts_delta = users_select_post × (s2c_rate_pre − s2c_rate_post)` per TGID from Q4 results. Three cases: Case A (top TGID ≥60% of total delta → single locus), Case B (2–3 TGIDs each ≥10% → multiple loci, run Step 2 for each), Case C (no TGID ≥10% → uniform drop → broad-drop path).
  - **Step 2 — TID snapshot:** Run against latest `extracted_date`. One row per TID. Ticket counts (sum of `total_remaining`) in four buckets: 0–2d, 3–7d, 8–13d, 14–30d. `is_fully_unlimited_capacity` flag — TIDs where this is TRUE must be excluded from scarcity analysis (`total_remaining = 1` is a system constant for unlimited-capacity slots, not an actual ticket count).
  - **Step 3 — Daily time-series:** `extracted_date` trend per bucket. Path B: pre+post series overlaid. Path A: post only. Scoped to single TID if that TID is the locus, or whole TGID if all TIDs depleted equally.
  - **Path A vs Path B:** Determined by whether `pre_start >= CURRENT_DATE - 30`. Path B = full pre/post comparison. Path A = pre-period outside 30-day window; post-only snapshot with an explicit data-limitation note in the report.
  - **Supply gate:** If Step 2 shows no depletion across limited-capacity TIDs, skip Step 3 and pivot to pricing or UX investigation instead.
  - **Broad-drop path (Case C):** Run Step 2 for top 3 TGIDs by `users_select`. Same bucket depleted across all three → CE-wide supply constraint. All full → supply is not the mechanism.

**`references/hypothesis.md`** — c016

- All references to `count_days_available_30d` as the availability signal replaced with `inventory_availability` TID summary table (Step 2 results).
- **Gradual S2C decline (Pattern 4):** Added `days_to_first_available_date` as a fast directional check before running inventory queries — an increasing trend confirms supply scarcity direction without a full TID query.
- **CE-wide S2C drop (no concentration):** Updated to point to the broad-drop inventory path (top 3 TGIDs by `users_select`, Step 2 for each).
- **Vendor throttling pattern:** Signal updated from `count_days_available_30d` to `days_to_first_available_date` increasing + 0–2d bucket near zero in TID snapshot.
- **S2C Tier 1 (experience concentrates):** Updated to reference `lost_checkouts_delta` locus computation → Case A/B/C → 3-step inventory path.
- **Experience-specific availability collapse (Pattern 3):** Updated to run `inventory_availability` TID summary table and daily time-series instead of `count_days_available_30d`.

**`references/actions.md`** — c017

- RC2 (Inventory/availability constraint): removed `count_days_available_30d` reference; replaced with `inventory_availability` TID summary table (near-zero ticket counts in one or more lead-time buckets) as the primary signal.

**`references/report_structure.md`** — c018

- Section renamed from "Inventory lead-time bucket table format" to "Inventory section format".
- "What belongs in Section 3" table updated: "Availability proxy table" and "Inventory lead-time bucket table" rows replaced with "Inventory TID summary table" (Step 2, one row per TID) and "Inventory daily time-series charts" (Step 3, one chart per lead-time bucket).
- **Supply gate outcome:** if Step 2 finds no depleted limited-capacity TIDs, write a ruled-out callout and skip the table/charts entirely.
- **Path B spec:** one row per TID, Pre/Post column pairs per bucket, `Capacity type` column, `highlight-row` on TID rows where the affected bucket pair shows the material drop; unlimited-capacity TIDs excluded with subtext note.
- **Path A spec:** post-only columns, amber note above table stating pre-period unavailability.
- **Daily time-series chart spec:** four charts (one per bucket); Path B overlays pre/post as separate series; Path A post only.
- HTML pattern replaced: old format (rows per bucket, aggregate columns) replaced with two separate patterns — Path B (rows per TID, Pre/Post bucket columns) and Path A (rows per TID, post-only columns).
- Updated subtext guidance: state pattern, when it started, what supply team should verify. No mechanism assertions.

**`references/q1_base.sql`** — c019

- Removed `MAX(CASE WHEN page_type IN (...) THEN 1 ELSE 0 END) AS visited_lp` from SELECT (condition already enforced in WHERE clause, making the column redundant). Fixed `GROUP BY 1, 2, 3, 9` → `GROUP BY 1, 2, 3, 8` to reflect the column count change.

**`references/worked_example.md`** — c020

- Removed `count_days_available_30d` from the S2C locus identification section (Example 2). Added TID summary table query result to the transcript showing `tickets_8_13d` and `tickets_14_30d` → 0 for all TIDs of TGID 8821, confirming the 8–30d window as the affected bucket.

### Test runs

Three new runs added (`v1.7`):
- **ce6495_2026-03-05_2026-05-03_run3** (Kualoa Ranch) — 31/35. Third run on the same CE/window. Methodological improvements over run2: Geo/Non-Geo first-pass S2C cut correctly executed; TGID-scoped TID snapshot with corrected COUNTIF (bug c014 fixed); Path A correctly applied (pre period >30 days ago). Supply definitively ruled out: TGID 37530 fully stocked across all lead-time buckets despite −9pp S2C drop. Confirms spring break demand quality decline as root cause.
- **ce234_2026-04-21_2026-05-04** (Empire State Building) — 27/35. Routing story: Google Ads traffic collapsed 58% (1,186→499 users), shifting paid/organic mix from 80/20 to 51/49. Product funnel intact — Google Ads CVR held stable at 5.6–5.8%. Gaps: organic LP2S drop (26%→10% within organic) not investigated or ruled out; URL traffic comparison omitted; Level 2 cascade used all-traffic `summary.json` data instead of the MB-filtered query from `context.md`.
- **ce144_2026-04-08_2026-05-05** (Alcatraz Tours) — 32/35. CVR improvement case (+3.78pp above prior year). April 15 launch of exp 36426 (Alcatraz with Ferry & Audio Guide, $47.95) displaced the $87.30 Self-Guided Tour App as the dominant listing. The 46% price reduction removed friction at variant selection (S2C +7.0pp) and checkout (C2A +9.9pp). International markets benefited most: Canada +25pp, Australia +22pp, UK +8pp S2C. Residual gap: A2O −2.24pp, likely reflecting higher payment friction from increased international visitor share.

---

*Each future entry in this changelog corresponds to one GitHub push. Format: `[vX.Y] — YYYY-MM-DD — Short title` followed by a summary of what changed and why.*
