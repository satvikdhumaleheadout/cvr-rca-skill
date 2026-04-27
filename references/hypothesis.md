# CVR-RCA Hypothesis Reference

## How to use this file

Read this after answering the three mandatory questions in Step 2. It provides historical patterns from 21 Headout RCAs to orient your hypothesis generation — not to constrain it.

**These patterns are starting points, not a menu.** Form your own hypotheses from what the data actually shows. If `summary.json` points to a mechanism not listed here, follow it — the data is always the authority. The patterns here are ranked by historical frequency; they exist to help you not overlook the common before pursuing the unusual.

**You are not required to match a pattern below.** If none of the patterns fit what you see, generate the hypotheses the data calls for. A good hypothesis names a specific mechanism, a segment it would affect, and a date or pattern you would expect to see if it were true — regardless of whether it appears in this file.

---

Use this file during Step 2 (Investigation). Once you have identified the **primary Shapley driver** and answered Q3 (sudden vs gradual), scan the relevant patterns below as one input into your hypothesis generation. Each pattern is drawn from historical Headout RCAs across 21 MMPs.

---

## URL concentration — a valid hypothesis for any primary driver

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
