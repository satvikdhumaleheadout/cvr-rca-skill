# CVR-RCA Worked Examples

Two end-to-end walkthroughs showing how the investigation tree unfolds in
practice. These are not templates — they show how L0 orientation opens specific
L1 branches, how parallel queries within a level work, and how the tree map
and detail sections work together.

---

## Example 1 — Mix-dominant story

**Starting point:** `summary.json` loaded. CVR dropped for a CE.

---

### Investigation transcript

```markdown
# Investigation Transcript — CE [id] · City Sightseeing Tours
Pre: 2026-03-01–2026-03-30 | Post: 2026-03-31–2026-04-29

## Tree map
L0: mix_dominant (58% ΔCVR) · gradual erosion · structural −2.3pp
├─ L1a: MB URL volume loss          →  CONFIRMED (2 URLs down 40%, 8,400 pre-users)
│   └─ L2a: Campaign traffic source →  CONFIRMED (Google Ads referrer −5,400)
│       └─ LEAF: Google Ads campaign stopped serving 2 MB collection pages
└─ L1b: HO channel split            →  RULED OUT (HO volume flat)

---

## L0 — Orient
**mix_dominance:** is_dominant = TRUE. MB share grew from 43% to 52% post.
  Mix effect explains 58% of total ΔCVR. No individual funnel step exceeds 2pp.
**shapley:** LP2S −0.8pp · S2C −1.1pp · C2O −0.4pp — no dominant step.
  All steps small; mix_dominance flags this as a routing story.
**trend_context:** Gradual erosion over 6 weeks. pre_period_healthy = true.
  structural_delta_cvr = −2.3pp (LY showed −0.1pp at same calendar position).

## L1 — Traffic composition shift
### MB URL volume · HO channel split — parallel

**MB URL volume**
Query: COUNT(DISTINCT user_id) by page_url WHERE is_microbrand_page = TRUE,
  pre vs post, top 20 URLs by total volume.
Result: Two collection-page URLs dropped 40% in the post period
  (tickets-amsterdam.com/tours, tickets-amsterdam.com/day-trips).
  All other MB URLs held within ±5%. Combined pre volume on those two: 8,400 users.
→ CONFIRMED — opens L2a: what drove the volume loss on those two URLs?
  Closes: device/language/page_type hypotheses (routing story, funnel steps fine).

**HO channel split**
Query: COUNT(DISTINCT user_id) by channel_name, pre vs post, HO only.
Result: HO volume flat. No channel shift within HO.
→ RULED OUT — HO is not driving the mix shift. Issue is MB-side volume loss.

## L2 — Source of MB URL volume loss
### Campaign traffic source — targeted follow-up

**Google Ads referrer on affected URLs**
Query: COUNT(DISTINCT user_id) by previous_page_url WHERE page_url IN
  (tickets-amsterdam.com/tours, /day-trips), pre vs post.
Result: Google Ads referrer: 6,200 pre → 800 post (−5,400). Organic stable.
→ CONFIRMED — LEAF reached. Campaign stopped; paid traffic removed from MB.

## Root cause confirmed
A Google Ads campaign driving 6,200 users per period to two MB collection pages
(tickets-amsterdam.com/tours, /day-trips) stopped at the start of the post
period. MB's remaining sessions shifted to predominantly organic/SEO (lower
intent), lifting MB's CE share from 43% to 52%. Neither MB nor HO per-segment
CVR changed — the entire ΔCVR is a traffic composition artefact. DRI: Marketing.
```

---

### What the report covers

CVR change card, mix table with routing finding, URL traffic comparison for the
two affected pages. No Shapley bar (misleading when steps didn't break), no
dimension cuts, no experience breakdown. One action card: Marketing to confirm
whether the campaign pause was intentional.

---

## Example 2 — S2C concentrated locus, sudden break

**Starting point:** `summary.json` loaded. CVR dropped for a CE.

---

### Investigation transcript

```markdown
# Investigation Transcript — CE [id] · Paris River Cruises
Pre: 2026-03-15–2026-04-13 | Post: 2026-04-14–2026-05-13

## Tree map
L0: S2C (83% Δ) · sharp break Apr 14 · structural −4.1pp
├─ L1a: Experience-level S2C + availability  →  CONFIRMED (TGID 8821: −15pp, avail 38→11d)
│   └─ L2a: Lead time distribution for 8821  →  CONFIRMED (8+ day bookings down 75–83%)
│       └─ LEAF: Supply partner closed 8821 inventory beyond ~7 days on Apr 14
└─ L1b: MB vs HO S2C split                  →  CONFIRMED (HO carries drop; narrows locus)

---

## L0 — Orient
**mix_dominance:** is_dominant = FALSE. MB/HO 38%/62% → 36%/64% post.
  Mix effect explains 9% of ΔCVR. Not a routing story.
**shapley:** LP2S −0.4pp · S2C −3.8pp · C2O −0.3pp — S2C carries 83% of ΔCVR.
  Primary step: S2C.
**trend_context:** Sharp break. S2C stable through pre, drops on Apr 14, stays low.
  pre_period_healthy = true. structural_delta_cvr = −4.1pp
  (LY showed +0.3pp at same calendar position — fully structural).

## L1 — S2C driver identification
### Experience-level S2C + availability · MB vs HO S2C split — parallel

**Experience-level S2C with availability proxy**
Query: COUNT(DISTINCT user_id), S2C rate by experience_id pre vs post.
  Join product_rankings_features on experience_id + event_date for
  count_days_available_30d.
Result:
  TGID 8821 (Seine Dinner Cruise): S2C 24% → 9%. count_days_available_30d 38 → 11.
    1,840 select users post. Rate −15pp, checkouts lost ≈276.
  TGID 8834 (Seine Sightseeing 1hr): S2C 19% → 16%. Avail 42 → 38. Noise level.
  All other TGIDs: <5pp rate change.
→ CONFIRMED — TGID 8821 is the locus. Opens L2a: why did availability drop Apr 14?
  Closes: broad platform/UX hypothesis (would show uniform drop, not one TGID).

**MB vs HO S2C split**
Query: S2C rate by is_microbrand_page, pre vs post.
Result: HO S2C 28% → 14%. MB S2C 18% → 16%.
→ CONFIRMED — HO carries the drop. Narrows locus: HO users on 8821 select page.
  Does not change TGID finding — reinforces it.

## L2 — Availability mechanism for TGID 8821
### Lead time distribution

**Lead time buckets for TGID 8821 checkouts**
Query: COUNT(DISTINCT user_id) by lead_time_days bucket (0–7, 8–14, 15–21, 22+)
  WHERE experience_id = '8821' AND has_checkout_started = TRUE, pre vs post.
Result:
  0–7 days:  210 → 198 (−6%). Near-term bookings stable.
  8–14 days: 380 →  94 (−75%).
  15+ days:  510 →  88 (−83%).
→ CONFIRMED — LEAF reached. Far-out bookings collapsed Apr 14+. Supply partner
  closed inventory for all dates beyond ~7 days.

## Root cause confirmed
On or around Apr 14, the supply partner for TGID 8821 (Seine Dinner Cruise)
closed inventory for all dates beyond ~7 days. HO users with planned trip dates
reach the select page and find no available dates, driving S2C from 24% to 9%
on 1,840 users — a loss of ~276 checkouts and 83% of the ΔCVR. Availability
proxy (count_days_available_30d: 38 → 11) and lead time collapse (8+ day
bookings down 75–83%) both confirm the mechanism. Session recordings: users
consistently see an empty date picker beyond the current week on the 8821 page.
```

---

### Session recordings

Pulled `Get-User-Replays-Data` for CE id, TGID 8821, HO, post period after the
L2 leaf was confirmed. Users consistently encountered an empty date picker beyond
7 days. Finding upgraded from "consistent with" to "directly observed."

---

### What the report covers

CVR verdict (availability closure for TGID 8821), mix ruled out in one line,
Shapley bar, S2C daily trend (break on Apr 14), experience-level S2C table
(TGID 8821 highlighted), lead time distribution chart (pre vs post), session
recordings table. Action cards: Supply/Ops (reopen 8821 inventory), Growth/BDM
(alert affected users).

Sections not present: LP2S deep-dive, C2O section (each <10% of ΔCVR).

---

## Changelog

| # | Date | Changes |
|---|------|---------|
| c001 | 2026-04-27 | Created — moved from SKILL.md as part of process/domain separation |
| c002 | 2026-04-27 | Rewritten to show investigation tree traversal with parallel query batches |
| c003 | 2026-04-27 | Added tree map block to both transcripts — shows full branch structure with CONFIRMED/RULED OUT/LEAF outcomes before detail sections |
