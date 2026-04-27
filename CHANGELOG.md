# CVR-RCA Skill — Changelog

This file tracks every meaningful change pushed to this repository. Each entry corresponds to a GitHub push and is written for stakeholder consumption — what changed, why it matters, and what improved.

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

*Each future entry in this changelog corresponds to one GitHub push. Format: `[vX.Y] — YYYY-MM-DD — Short title` followed by a summary of what changed and why.*
