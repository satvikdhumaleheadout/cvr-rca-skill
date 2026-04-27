# CVR-RCA Worked Examples

Two end-to-end walkthroughs showing how the investigation tree unfolds in
practice. These are not templates — they show how L0 orientation opens specific
L1 branches, how parallel queries within a level work, and how the transcript
mirrors the tree structure.

---

## Example 1 — Mix-dominant story

**Starting point:** `summary.json` loaded. CVR dropped for a CE.

---

### Investigation transcript

```markdown
# Investigation Transcript — CE [id] · City Sightseeing Tours
Pre: 2026-03-01–2026-03-30 | Post: 2026-03-31–2026-04-29

## L0 — Orient
**mix_dominance:** is_dominant = TRUE. MB share grew from 43% to 52% post.
  Mix effect explains 58% of total ΔCVR. No individual funnel step exceeds 2pp.
**shapley:** LP2S −0.8pp · S2C −1.1pp · C2O −0.4pp — no dominant step.
  All steps small; mix_dominance flags this as a routing story.
**trend_context:** Gradual erosion over 6 weeks. pre_period_healthy = true.
  structural_delta_cvr = −2.3pp (LY showed −0.1pp at same calendar position).
Branches opening at L1:
  (a) Which MB URLs lost volume? (b) Which HO channels gained share?

## L1 — Traffic composition shift
### MB URL volume · HO channel split — parallel

**MB URL volume**
Query: COUNT(DISTINCT user_id) by page_url WHERE is_microbrand_page = TRUE,
  pre vs post, top 20 URLs by total volume.
Result: Two collection-page URLs dropped 40% in the post period
  (tickets-amsterdam.com/tours, tickets-amsterdam.com/day-trips).
  All other MB URLs held within ±5%. Combined pre volume on those two: 8,400 users.
→ Concentration confirmed. Opens L2: what changed on those two URLs?
  Closes: device/language/page_type hypotheses (not needed — routing story).

**HO channel split**
Query: COUNT(DISTINCT user_id) by channel_name, pre vs post, HO only.
Result: HO volume flat. No channel shift within HO.
→ Ruled out — HO is not driving the mix shift. Issue is MB-side volume loss.

## L2 — Source of MB URL volume loss
### Campaign traffic hypothesis — targeted follow-up
Query: COUNT(DISTINCT user_id) by previous_page_url WHERE page_url IN
  (two Amsterdam collection URLs), pre vs post.
Result: Google Ads referrer accounted for 6,200 of 8,400 pre-period users on
  those URLs; drops to 800 in post. Organic referrer (direct/SEO) stable.
→ Leaf confirmed. A Google Ads campaign stopped serving those two MB
  collection pages in the post period. CVR drop is fully explained by the
  removal of that high-intent paid traffic from MB, increasing MB's organic
  share (lower CVR) and depressing overall CE CVR.

## Root cause confirmed
A Google Ads campaign that was driving 6,200 users per period to two MB
collection pages (tickets-amsterdam.com/tours, /day-trips) stopped running at
the start of the post period. With that paid traffic removed, MB's remaining
sessions are predominantly organic/SEO (lower purchase intent), shifting MB's
share of total CE traffic from 43% to 52%. Neither MB nor HO per-segment CVR
changed. The entire ΔCVR is a traffic composition artefact. DRI: Marketing.
```

---

### What the report covers

CVR change card, mix table with routing finding called out, URL traffic
comparison for those two pages (pre vs post user counts), session recordings
not pulled (routing story — no funnel step broke). One action card: Marketing
to investigate the campaign pause and confirm whether it was intentional.

Sections not present: Shapley bar (misleading when the steps didn't break),
dimension cuts, experience breakdown.

---

## Example 2 — S2C concentrated locus, sudden break

**Starting point:** `summary.json` loaded. CVR dropped for a CE.

---

### Investigation transcript

```markdown
# Investigation Transcript — CE [id] · Paris River Cruises
Pre: 2026-03-15–2026-04-13 | Post: 2026-04-14–2026-05-13

## L0 — Orient
**mix_dominance:** is_dominant = FALSE. MB/HO 38%/62% → 36%/64% post.
  Mix effect explains 9% of ΔCVR. Not a routing story.
**shapley:** LP2S −0.4pp · S2C −3.8pp · C2O −0.3pp — S2C carries 83% of ΔCVR.
  Primary step: S2C.
**trend_context:** Sharp break. S2C stable through pre period, drops on Apr 14,
  stays low. pre_period_healthy = true. structural_delta_cvr = −4.1pp
  (LY showed +0.3pp at same calendar position — fully structural).
Branches opening at L1:
  (a) Experience-level S2C + availability proxy (S2C dominates, sharp break)
  (b) MB vs HO S2C split (is it concentrated in one segment?)

## L1 — S2C driver identification
### Experience-level S2C · MB/HO S2C split — parallel

**Experience-level S2C with availability proxy**
Query: COUNT(DISTINCT user_id), S2C rate by experience_id pre vs post.
  Join product_rankings_features on experience_id + event_date for
  count_days_available_30d.
Result:
  TGID 8821 (Seine Dinner Cruise): S2C 24% → 9%. count_days_available_30d
    38 → 11. 1,840 select users post. −15pp rate, −276 checkouts lost.
  TGID 8834 (Seine Sightseeing 1hr): S2C 19% → 16%. count_days_available_30d
    42 → 38. 2,100 users. −3pp rate, −63 checkouts lost. Noise level.
  All other TGIDs: <5pp rate change.
→ TGID 8821 confirmed as the locus. Opens L2: why did availability drop for
  8821 specifically on Apr 14?
  Closes: broad platform/UX hypothesis (would show uniform S2C drop, not
  concentrated in one experience).

**MB vs HO S2C split**
Query: S2C rate by is_microbrand_page, pre vs post.
Result: HO S2C 28% → 14%. MB S2C 18% → 16%.
→ HO carries the drop. Narrows the locus: HO users on 8821 select page.
  Does not change the TGID finding — reinforces it (HO users are higher-intent,
  more likely to have planned trip dates).

## L2 — Availability mechanism for TGID 8821
### Lead time distribution — targeted follow-up
Query: COUNT(DISTINCT user_id) by lead_time_days bucket (0–7, 8–14, 15–21,
  22+) for experience_id = '8821', has_checkout_started = TRUE, pre vs post.
Result:
  0–7 days: 210 → 198 (−6%). Near-term bookings stable.
  8–14 days: 380 → 94 (−75%).
  15+ days: 510 → 88 (−83%).
→ Far-out bookings collapsed after Apr 14. Supply partner appears to have
  closed inventory for all dates beyond ~7 days. Users reaching the select page
  for 8821 find no dates available beyond the current week and abandon.

## Root cause confirmed
On or around Apr 14, the supply partner for TGID 8821 (Seine Dinner Cruise)
closed inventory for all dates beyond approximately 7 days ahead. HO users with
planned trip dates (8+ days out) reach the select page and find no available
dates, causing S2C to fall from 24% to 9% on 1,840 users — a loss of ~276
checkouts and the primary driver of CE CVR falling −4.1pp. The availability
proxy (count_days_available_30d: 38 → 11) and the lead time distribution
collapse (8+ day bookings down 75–83%) both corroborate the mechanism. Session
recordings confirmed: users consistently encounter an empty date picker beyond
the current week on the 8821 select page.
```

---

### Session recordings (pulled at L2 leaf)

Pulled `Get-User-Replays-Data` for CE id, TGID 8821, HO, post period. Result:
users consistently saw an empty date-picker beyond 7 days. Finding upgraded
from "consistent with" to "directly observed."

---

### What the report covers

CVR verdict (availability closure for TGID 8821 by supply partner), mix ruled
out in one line, Shapley bar, S2C daily trend (break on Apr 14), experience-
level S2C table (TGID 8821 highlighted), lead time distribution chart (pre vs
post), session recordings table. Action cards: Supply/Ops (urgently reopen
inventory for 8821 beyond 7 days), Growth/BDM (alert users with upcoming trips
booked with this vendor).

Sections not present: LP2S deep-dive, C2O section (each carried <10% of ΔCVR).

---

## Changelog

| # | Date | Changes |
|---|------|---------|
| c001 | 2026-04-27 | Created — moved from SKILL.md as part of process/domain separation |
| c002 | 2026-04-27 | Rewritten to show investigation tree traversal: L0 orient → L1 parallel batches → L2 targeted follow-up → leaf. Transcripts mirror tree structure. Both examples updated to include parallel query batches explicit in transcript. |
