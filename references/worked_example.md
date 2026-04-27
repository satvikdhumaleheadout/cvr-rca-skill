# CVR-RCA Worked Examples

Two end-to-end walkthroughs of what good analytical reasoning looks like in
practice. These are not templates — they show how the process plays out when
the evidence is clear and the investigator follows the data.

---

## Example 1 — Mix-dominant story

**The situation:** CVR for a CE dropped. Baseline queries run, `summary.json`
read.

**Q1: Routing or conversion?**

`mix_dominance` shows MB traffic share grew from 43% to 52% in the post period.
MB CVR is stable. HO CVR is stable. Mix effect explains 58% of total ΔCVR. No
funnel step shows a change larger than 2pp.

*This is a routing story, not a funnel story.* The investigation does not open
a Shapley deep-dive. The question becomes: why did MB traffic share grow?

Write a custom query: `COUNT(DISTINCT user_id)` by `page_url` for MB sessions,
pre vs post. Two collection-page URLs show a 40% traffic drop. Everything else
held.

Those two URLs were receiving paid search traffic in the pre period. In the post
period they were not. The CVR drop is an artefact of a paid campaign that stopped
sending HO-quality traffic to these MB pages, increasing MB's share of organic
(lower-CVR) sessions.

**What the report covers:** CVR change card, mix table with routing finding
called out, URL traffic comparison for those two pages, action card to Marketing
to investigate the campaign change. Four sections total. No dimension cuts. No
experience breakdown. No Shapley bar — Shapley would be misleading here because
the steps themselves did not break.

---

## Example 2 — Conversion-dominant, concentrated locus

**The situation:** Same starting point. `mix_dominance.is_dominant` is false.
Shapley shows S2C carries 68% of ΔCVR. LP2S and C2O are small. S2C is the story.

**Q3: Sudden, gradual, or seasonal?**

Daily trend: S2C was stable through the pre period, dropped sharply on Apr 8,
and stayed low through the post period. Single-day onset. LY overlay shows no
similar drop at this calendar position — structural, not seasonal.

*Something changed on Apr 8 affecting S2C.* Query device and language cuts for
S2C. Device: iOS Mweb shows −4.1pp, Android −2.1pp, Desktop −0.3pp. Mobile is
disproportionately affected. Language: French shows −6pp, English −1.5pp,
Spanish −0.8pp. French is the outlier.

*Two concentrated signals: mobile and French.* Write a custom query: S2C rate
by `page_url` filtered to `language = 'French'` and `device_type LIKE '%Mweb%'`.
One experience's select page shows S2C falling from 19% to 4% in that cut.

Pull Mixpanel session recordings for that URL × French × post period. Users
consistently see an empty date picker — no available dates are loading for the
French locale on that experience.

**What the report covers:** CVR verdict (availability/localization issue on one
experience's date-picker for French mobile users), mix ruled out, Shapley bar,
S2C daily trend, S2C device + language cuts, URL-level finding for that
experience, session recordings table, action cards for Supply (check availability
configuration) and Product (check French locale date-picker rendering).

The LP2S and C2O sections do not appear. They were not the story.

---

## Changelog

| # | Date | Changes |
|---|------|---------|
| c001 | 2026-04-27 | Created — moved from SKILL.md as part of process/domain separation |
