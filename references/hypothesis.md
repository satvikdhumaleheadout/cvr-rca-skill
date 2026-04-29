# CVR-RCA Hypothesis Reference

## How to use this file

This is the central branch reference for the entire investigation. It operates at two levels:

**Level 1 — L0 routing map and first-pass branch sets** (sections immediately below): these tell you *which branches to open* at L1 and L2. Read this before forming any hypothesis. The L0 routing map maps each signal combination to a default branch set. The first-pass branch sets tell you which dimension cuts to run first for each primary funnel driver.

**Level 2 — Historical patterns** (Pattern 1–10 at the bottom): these provide *specific mechanism hypotheses* once a first-pass branch confirms a direction. Use them to decide *why* something may have happened in a confirmed dimension — the "why" behind a confirmed signal.

Use Level 1 to decide where to look first. Use Level 2 to decide why it might have happened there.

**These patterns are starting points, not a menu.** Form your own hypotheses from what the data actually shows. If `summary.json` points to a mechanism not listed here, follow it — the data is always the authority. A good hypothesis names a specific mechanism, a segment it would affect, and a date or pattern you would expect to see if it were true — regardless of whether it appears in this file.

---

## L0 signal → first branches to open

The three L0 signals (mix_dominance, shapley, trend_context) each open a
specific set of L1 branches. Use this table as the default starting set —
then adapt based on what the data actually shows.

The L1 cascade always runs first and determines the path. Shapley and trend
signals from L0 apply only once the cascade confirms a conversion story.

| Signal | Value / pattern | What it opens |
|--------|----------------|---------------|
| **Cascade: mix exit at Level 1** | MB/HO share shifted | Why did HO traffic fall or MB grow? Campaign paused, budget cut, routing error? (Pattern 7) |
| **Cascade: mix exit at Level 2** | Paid/organic share shifted | Why did paid spend fall or organic grow? Campaign pause, SIS cap, budget reallocation? (Patterns 1, 7) |
| **Cascade: mix exit at Level 3** | Channel share shifted within paid | Why did budget or impression share move between channels? Bid strategy, budget reallocation, Performance Max expansion? |
| **Cascade: conversion at all levels → Shapley: LP2S dominates** | LP2S is the funnel story | First-pass branches for LP2S (see below) |
| **Cascade: conversion at all levels → Shapley: S2C dominates** | S2C is the funnel story | First-pass branches for S2C (see below) |
| **Cascade: conversion at all levels → Shapley: C2O dominates** | C2O is the funnel story | First-pass branches for C2O (see below) |
| **Trend: sharp break on date X** | Event on that date | Anchor all L2 branches to that date — which dimension shows the largest change starting that day? |
| **Trend: gradual erosion** | Compounding trend | Supply trend (availability over time), pricing trend, traffic quality trend |
| **Trend: seasonal** (`structural_delta_cvr` small) | Calibrate depth | Use `structural_delta_cvr` as the magnitude to explain — not `current_delta_cvr` |

Shapley and trend signals combine. If S2C dominates AND trend shows a sharp
break, L2 branches are "experience-level S2C anchored to break date" +
"availability proxy on that date." Trend context sharpens every branch — it
does not replace the cascade.

The table is the default starting set. It does not replace reading the actual
numbers — if a signal points in an unexpected direction, follow it.

---

## First-pass branch sets by primary driver

**These are starting points, not a complete list.** They cover the most common
angles for each funnel step. After running any batch of queries, ask yourself:
*does this result suggest a hypothesis that isn't on this list?* If yes, add it.
The cuts below tell you where to look first — they don't tell you what you'll
find or what to hypothesize next. What you find determines that.

The investigation is complete when you reach a leaf (a specific mechanism at a
specific segment, experience, URL, or date). It is not complete when the list
below is exhausted. If you've run all the tiers and have no leaf, that is a
signal to look more carefully at what the data already showed — a surprising
number, an unexplained gap, a dimension that partially concentrated — and form
a new hypothesis from it.

Common reasons the list runs out before a leaf is found:
- The real locus is a cross-cut (e.g., French × iOS) not tested individually
- The mechanism is at a finer grain (specific URL, specific experience × date)
  not yet drilled into
- The cause is outside the funnel table entirely (pricing, availability, a
  campaign event) and needs a separate query against a different table

### Mix — first-pass branches

Write a query: `COUNT(DISTINCT user_id)` by `page_url` pre vs post for the
affected segment (MB or the channel that shifted). Which URLs gained or lost
volume? If a paid campaign was serving specific collection pages in the pre
period and stopped, those pages will show a sharp traffic drop. That is the
finding. Marketing owns it.

### LP2S — first-pass branches

LP2S is about whether users landing on the listing page click through to the
select page. Work through three tiers in order — don't skip ahead.

**Tier 1 — Run dimension cuts in parallel (first batch):**
- `device_type` × LP2S rate pre/post — mobile-concentrated drops point to a
  UI or performance change
- `language` × LP2S rate — a single language dropping points to geo-specific
  pricing or a localised UX issue
- `page_type` × LP2S rate — a drop in Collection but not Experience pages points
  to browse-level friction
- `experience_id` × LP2S rate — a drop in a few specific experiences points to
  listing quality, price, or availability visible on the listing

**If a dimension concentrates:** run the intersection (e.g., French × mobile), then drill to `page_url` within that segment. The page URL is the target output — it is what the stakeholder needs to act on. A finding is not complete until you can say "these specific URLs are where LP2S dropped, here are the user counts."

**Tier 2 — If no dimension concentrates (drop is CE-wide and flat across cuts):**
Run pricing analysis — `final_price_usd` from `product_rankings_features` pre vs post for top experiences. Did prices increase, and does the timing align with the LP2S drop? A CE-wide price uplift will depress LP2S broadly with no dimension cut showing concentration.

**Tier 3 — If pricing is also flat:**
The drop is broad, no pricing explanation, no concentrated locus. Session recordings are the next tool — look for a UX pattern that affects all users equally (e.g., slow page load, broken image carousel, changed CTA placement). Note in the transcript that no quantitative locus was found; session recordings are the primary evidence. (Event-level analysis is a future addition for this tier.)

### S2C — first-pass branches

S2C is about whether users on the select/date-picker page proceed to checkout.
Work through two tiers in order.

**Tier 1 — Run dimension cuts in parallel (first batch):**
- `language` × S2C rate pre/post — a drop in one language points to a localised
  select-page issue (broken date-picker for that locale, geo-specific pricing
  shock at variant selection)
- `device_type` × S2C rate pre/post — a mobile-concentrated drop points to a
  select-page UX or rendering issue specific to small screens
- `experience_id` × S2C rate pre/post — a drop in specific experiences points
  to a supply or pricing issue for those products. When you find this, also pull
  `count_days_available_30d` from `product_rankings_features` for those
  experiences to confirm availability is the mechanism.

**If language or device concentrates:** drill to the intersection (language × device if both signal), then to `page_url` within that segment. The URL is the actionable endpoint — give the stakeholder the specific select-page URLs and user counts.

**If experience concentrates:**
- Confirm with `count_days_available_30d` — a drop in available days corroborates supply
- Run the `inventory_availability` lead-time bucket query to identify *which
  window* went empty (this converts "availability dropped" into a specific
  mechanism and a specific DRI)
- Cross-check with `lead_time_days` distribution from the funnel table — if users
  shifted toward longer lead times AND that same window is empty in
  `inventory_availability`, the shift is supply-caused, not behavioural

**Tier 2 — If no dimension concentrates (drop is broad):**
A CE-wide S2C drop with no language/device/experience concentration is unusual.
Check two things: (1) was there a change in the checkout flow or variant
selection UI? (2) did availability drop uniformly across all experiences? A
platform-wide availability configuration change (e.g., cut-off window extended
globally) would produce a CE-wide S2C drop with no concentration.

### C2O — first-pass branches

Check `c2o_sub` from `summary.json` first. C2O = C2A × A2O and they point to
completely different causes. Always decompose first — do not run C2O queries
before knowing which sub-metric moved.

**If C2A dropped** (users reached checkout but didn't submit payment):

Four hypotheses to run in parallel:
1. **Pax availability at checkout** — users selected a pax configuration (e.g.,
   3 adults + 2 children) but no pack style exists for that combination. They hit
   a "not available" state on the checkout page and abandon. Look at whether
   certain experience × pax combinations are unavailable in the post period. This
   is a supply/ops issue, not a UX issue — DRI is Ops/BDM.
2. **Price display friction** — total price (including booking fees, taxes,
   service charges) visible at checkout differs significantly from listing price.
   Check if any fee or pricing component changed between pre and post.
3. **Checkout UX change** — a form field change, CTA relabelling, coupon code
   breakage, or trust signal removal. Concentrate investigation on device ×
   C2A — mobile users are most sensitive to checkout form friction.
4. **Session recordings** — once any of the above narrows to a locus (device,
   language, or experience), pull recordings on the checkout page to confirm the
   pattern.

**If A2O dropped** (users submitted payment but order failed):

Three hypotheses to run in parallel:
1. **Payment gateway failure** — elevated decline rate from a specific gateway
   or card network. Check if `payment_gateway` or `failure_reason` in
   `order_attempted_events_v2` shows a spike for a specific payment method.
2. **Fraud rule tightening** — a rule change or new fraud model version is
   blocking more legitimate transactions. `fraud_evaluation_result_origin` would
   show a change in classification rate.
3. **Live inventory failure** — the experience slot was available when the user
   reached checkout but sold out between checkout start and payment confirmation
   (another user completed a booking first). Check for a spike in
   `failure_reason` values indicating inventory unavailability at the moment of
   order attempt.

DRI for A2O: Payments team (gateway/fraud) or Engineering/Ops (live inventory
sync failures).

---

## URL concentration — a cross-cutting check

Before reading the step-specific patterns below, check the URL breakdown in
`summary.json` for the affected metric. URL concentration is a legitimate
hypothesis regardless of which funnel step is primary — it shapes both the
mechanism and the DRI.

A drop concentrated in 2–3 high-traffic URLs points to something specific
about those pages (a template change, a specific experience listed, an
audience those URLs attract). A drop spread uniformly across all high-traffic
URLs points to a CE-wide mechanism (availability, pricing, platform change).
These two findings call for different root causes and different action owners.

Apply this check for each primary driver type:

- **Mix shift:** Which high-traffic URLs gained or lost volume between periods?
  URL traffic shifts reveal where the routing changed — a specific campaign
  landing page, a microsite, or a paid channel's destination.

- **LP2S drop:** Which high-traffic landing URLs show disproportionate LP2S
  drops? A drop concentrated on specific collection or theme pages points to
  something about those page templates or the experiences they surface.

- **S2C drop:** Which high-traffic URLs (including select/booking pages) show
  disproportionate S2C drops? A broad drop across all URLs suggests a CE-wide
  supply or pricing constraint; a concentrated one suggests a specific
  experience or page-type issue.

- **C2O drop:** Which high-traffic booking flows show disproportionate C2O
  drops? Concentration on specific booking pages can reveal checkout
  configuration or experience-specific fulfilment issues.

**Volume filter applies.** Only URLs that account for a meaningful share of
CE traffic on the affected metric qualify as evidence. Long-tail URLs (those
representing a small fraction of total CE traffic) produce high-variance rate
estimates — treat their signals as directional at best, not as primary
evidence. See the majority-contributor principle in `SKILL.md`.

---

## Historical patterns — mechanism detail by scenario

Use these once a first-pass branch confirms. They provide the specific mechanism hypotheses for each confirmed scenario — the "why" behind a confirmed dimension signal.

---

## Pattern 1: LP2S is the primary driver — sudden onset

A sharp drop in LP2S that began on a specific date means something *changed* that day. Work backwards from the date.

**Hypotheses (ranked by frequency across MMPs):**

1. **Pricing increase on listing page** — Were prices updated on or around the drop date? SP rate change, discount removed, or helipad/facility fees now included in display price. Check `price_analysis` for median price delta pre vs post. A price increase coinciding with the onset date is a strong corroborating signal.

2. **Listing page UX / MB format change** — Was a new listing page format or MB template deployed? Historical case: Vienna concerts' new Live Entertainment MB format introduced an extra decision step (venue selection before date selection), cutting LP2S roughly in half. Users reaching the select page dropped from ~40%+ to ~20% overnight. Always check if the onset date aligns with a product deploy.

3. **Campaign routing to wrong LP** — Are paid campaigns pointing to an incorrect or outdated landing page? Historical case: NY Helicopter had language-specific campaigns still routing to the old San Francisco LP. Only the affected language shows a drop; other languages hold.

4. **Product ranking change at top slot** — Did the top-ranked product change on or around the drop date? A new top product with lower inherent CVR, higher price, or worse availability depresses overall LP2S even if the rest of the CE is unchanged.

5. **Competitor pricing action** — Did GYG, Viator, or a direct competitor drop prices sharply, making HO's listed prices look expensive relative to alternatives the user sees? This typically shows up as a gradual effect but can be sudden if a competitor ran a flash promotion.

---

## Pattern 2: LP2S is the primary driver — gradual decline

A slow erosion of LP2S over weeks points to structural changes, not a single deploy event.

**Hypotheses (ranked by frequency across MMPs):**

1. **Supply thinning / availability horizon shrinking** — Is `days_to_first_available_date` increasing over the post period? Users landing on a listing page and seeing the nearest available date is weeks away are less likely to click through. Historical pattern: Blue Mountains next-day inventory progressively locked by API cut-off period settings.

2. **SIS cap reached, paid traffic quality declining** — As a CE scales, Share of Impression Share hits a ceiling. Incremental clicks are lower-intent. The CE appears to hold clicks but LP2S drifts down because the marginal user is less interested.

3. **Competitive pressure eroding click-through** — GYG/Viator strengthened their listing quality, ratings, or price positioning gradually. HO listings receive the same or more traffic but convert less.

4. **Content / media degradation** — Product images removed or replaced with lower-quality alternatives, descriptions not updated for seasonal relevance, review count stagnating relative to competitors.

5. **Assortment drift** — Products were added to the CE that are tangentially relevant but lower-CVR, diluting the listing quality for users browsing the full assortment.

---

## Pattern 3: S2C is the primary driver — sudden onset

A sharp S2C drop on a specific date almost always points to either a supply configuration change or a select page deploy.

**Hypotheses (ranked by frequency across MMPs):**

1. **Availability configuration tightened** — API cut-off period shortened, release window changed, or lead-time minimum increased by the SP. Users who reach the date picker see no bookable dates for their trip window. Historical pattern: Blue Mountains SP API cut-off periods preventing next-day and same-week bookings; USJ release settings limiting near-term inventory.

2. **Select page / date-picker UX regression** — A deploy broke or degraded the date-picker experience. Likely concentrated in mobile (iOS Mweb most sensitive). Check device breakdown for S2C — if iOS Mweb carries disproportionate drop, this is the hypothesis to pursue first.

3. **Price shock at variant level** — The select page shows a higher price than the listing page anchor (e.g., listing shows base ticket price, select page shows full price including mandatory fees). Users who clicked expecting $X now see $Y and abandon. Historical case: NY Helicopter helipad fees not included in LP display price.

4. **Specific experience availability collapse** — One key experience within the CE lost inventory entirely (vendor cancelled availability for a block of dates). Check experience-level S2C — if one experience carries most of the drop while others hold, this is a vendor-specific issue, not a CE-wide one.

5. **TGID misconfiguration** — A product variant configuration change caused the wrong experience or wrong date-picker to load. Most likely to surface as a sudden drop concentrated on one experience.

---

## Pattern 4: S2C is the primary driver — gradual decline

Slow S2C erosion points to structural supply or complexity issues that worsen over time.

**Hypotheses (ranked by frequency across MMPs):**

1. **Inventory thinning over time** — SP progressively reducing available slots or shortening the booking window. Lead times growing, last-minute availability disappearing. Historical case: NY HeliNY last-minute gaps requiring advance booking; Blue Mountains vendors limiting same-week availability.

2. **Variant complexity increasing / decision paralysis** — More SKUs or variants added without clear differentiation. Users are overwhelmed and abandon before committing. Historical case: Vienna concerts — multiple venue × composer × price × duration combinations with no clear "best" option created decision paralysis. S2C improved after assortment was simplified.

3. **Vendor throttling inventory under fulfilment strain** — A SP with rising cancellation rates often quietly reduces available slots or tightens release windows to avoid over-booking. This directly reduces 0-2D availability visible at the date picker, causing S2C to drop. The signal: `count_days_available_30d` and `days_to_first_available_date` both worsen for the specific experience(s) served by that vendor, while peers hold. Note: the vendor's CR% itself is a fulfilment/A2O metric — it does not directly move S2C. The connection is through availability, not fulfillment rate.

4. **Seasonal availability pattern** — Certain months have structural low-availability periods for the experience type (e.g., peak demand for a limited-capacity venue, off-season closures). Compare to prior-year data to distinguish seasonal from structural.

---

## Pattern 5: C2O is primary — C2A sub-metric is down (users abandoning before submitting payment)

Users reached checkout but did not submit payment. The problem is in the checkout experience itself.

**Hypotheses (ranked by frequency across MMPs):**

1. **Hidden fees revealed at checkout** — Total price in checkout is materially higher than what was shown during selection (helipad fees, booking fees, taxes). Users feel deceived and abandon. Historical case: NY Helicopter helipad fees not surfaced until checkout, causing C2A abandonment.

2. **Checkout UX friction — new step or broken flow** — A form field was added, autofill broke, a payment option was removed, or the checkout flow gained a step. Most sensitive on mobile mweb (iOS Safari, Android Chrome).

3. **Booking fee or mandatory add-on revealed only at checkout** — The checkout total is materially higher than the select-page price because a mandatory fee (booking fee, facility surcharge, per-person add-on) was not surfaced earlier. This is distinct from the LP price shock (Pattern 3.3) — the user cleared the select page but then sees the true cost in the checkout form and abandons. Check whether a booking fee was added or a fee structure changed around the onset date. Note: Wrong TGID in customer communications (NY Helicopter case) causes post-booking cancellations but does not directly move the C2A funnel metric — that is an operational issue handled in actions.md RC8, not a funnel hypothesis.

4. **Coupon or promo code breakage** — An active promotional code stopped working, causing users relying on it to abandon at payment.

5. **Trust signals missing** — Review score, cancellation policy, security badge, or payment method logos removed from the checkout page.

---

## Pattern 6: C2O is primary — A2O sub-metric is down (payment submitted but order failed)

Users attempted payment but it did not complete. The problem is downstream of the checkout form.

**Hypotheses:**

1. **Payment gateway degradation** — Gateway timeout, error rate increase, or outage for a specific payment method. Check engineering/gateway logs for the onset date.

2. **Fraud rule tightening** — Updated fraud filters increasing card decline rate for certain card types or geographies.

3. **Currency / FX display error** — Price shown in wrong currency or with wrong conversion rate at the payment step, causing card authorisation to fail.

4. **New payment method rollout regression** — Adding a new payment option sometimes introduces a flow breakage for existing methods on certain devices.

---

## Pattern 7: MB/HO mix shift is the dominant explanation

Before diagnosing any funnel step: if mix is dominant, the story is about traffic, not conversion.

**Hypotheses for why traffic shifted toward lower-CVR MB:**

1. **Paid campaign paused, scaled down, or budget reallocated** — HO paid traffic (high-intent) dropped, increasing MB's organic share. Historical case: NY Helicopter saw 75% drop in English campaign clicks in Jan 2026, collapsing overall CVR via mix even though per-segment rates held.

2. **LP routing error in paid campaigns** — Some language or geo campaigns now send traffic to an MB page instead of headout.com, shifting apparent MB share up. Historical case: NY Helicopter language campaigns routing to old SF landing page.

3. **Seasonal organic MB spike** — A seasonal event drove outsized organic MB traffic without a corresponding paid HO increase, diluting the mix.

4. **Budget reallocation to another CE** — Marketing shifted paid spend away from this CE, reducing HO's share of total CE sessions.

---

## Pattern 8: Drop concentrated in a specific device

**Hypotheses:**

1. **Mobile UI deploy with regression** — A front-end change broke or degraded the mobile web experience. iOS Mweb (Safari) is especially sensitive to CSS changes and font-rendering issues.

2. **Mobile page performance degradation** — Page load time increase on mobile (e.g., uncompressed images, new JS bundle) causing higher bounce rate.

3. **Mobile-specific feature breakage** — Date picker, image carousel, CTA button, or checkout form non-functional on a specific mobile browser.

---

## Pattern 9: Drop concentrated in a specific language

**Hypotheses:**

1. **Geo-specific campaign change** — That language's paid campaign was modified, paused, or re-routed. Traffic volume in that language may have held (organic SEO) but intent composition changed.

2. **Localisation issue** — Translation missing for a new product or feature, broken layout for a non-Latin character set, or locale-specific content showing incorrect dates/prices.

3. **Geo-specific availability or pricing change** — A SP adjusted pricing or availability for a specific market, affecting only the language segment that targets that geography.

4. **New lower-intent source for that language** — An affiliate partner, SEO ranking improvement, or social campaign for a specific market brought in a new audience that converts at a lower rate.

---

## Pattern 10: Drop concentrated in specific experiences at S2C

**Hypotheses:**

1. **Experience-specific availability collapse** — This product's SP closed inventory for the post period or tightened cut-off settings. Check `count_days_available_30d` for that experience_id in pre vs post.

2. **Vendor-specific operational issue** — SP had cancellations, moved to manual fulfillment mode, or had an API outage affecting only their products. Historical case: NY Helicopter Charm Aviation required manual FF mode; completions dropped disproportionately on Charm-serviced TGIDs.

3. **Experience-specific pricing change** — This product's price was raised while peer products held, making it uncompetitive within the CE's own select page.

4. **TGID misconfiguration** — Wrong variants linked, duplicate TGIDs created, or experience merged/split incorrectly, confusing the date-picker for that specific product.

---

## Changelog

| # | Date | Changes |
|---|------|---------|
| c001 | 2026-04-24 | Initial version — 10 patterns drawn from 21 historical Headout MMPs |
| c002 | 2026-04-24 | Added "How to use this file" preamble clarifying these are historical priors, not a constraint; Claude generates its own hypotheses from data and is not limited to patterns listed here |
| c003 | 2026-04-24 | Added "URL concentration" preamble section before Pattern 1 — URL-level concentration is now a first-class hypothesis for all four primary driver types (mix, LP2S, S2C, C2O), with volume filter requirement and pointer to majority-contributor principle in SKILL.md |
| c004 | 2026-04-29 | Restructured as two-level reference: Level 1 (L0 routing map + first-pass branch sets by funnel step) moved from context.md; Level 2 (historical patterns) retained. "How to use this file" updated to reflect full role as the central branch reference for all investigation levels. |
| c005 | 2026-04-29 | L0 routing table rewritten: first rows now show cascade exit conditions (mix exit at Level 1/2/3) before the Shapley rows, reflecting that the cascade runs first and Shapley rows apply only after a conversion-path cascade completes. mix_dominance.is_dominant = true row removed — mix determination happens through cascade levels, not as a pre-gate. |
