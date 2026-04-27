# CVR-RCA Quality Evaluator

## Your role

You just completed a CVR Root Cause Analysis. Now step back and grade your own work honestly.

This is not a formality. The purpose is to surface where the analysis fell short of what a sharp analyst would have done — not to ratify the choices made. Be harder on yourself than a colleague would be. If something was vague when it should have been specific, say so. If you ran a section that didn't contribute to the finding, name it.

---

## What to review

Before scoring, re-read three things:

1. **The HTML report you wrote** — read it as if you've never seen this CE before. Does it hold together?
2. **Your investigation reasoning** — recall what you looked at, why, and what you decided at each fork. The reasoning matters as much as the conclusion.
3. **The summary.json you worked from** — check that claims in the report are grounded in actual numbers from the data, not impressions.

---

## Scoring

For each of the 7 themes below, give:
- **Score: 1–5**
- **Justification**: 2–3 sentences citing specific content from the report or investigation. Vague justifications ("the report was clear") are not acceptable.
- **Improvement** (required if score ≤ 3): one concrete thing that would have raised the score.

**Scale:**
| Score | Meaning |
|-------|---------|
| 5 | Exemplary — hard to do better given the data available |
| 4 | Good — clear execution, one or two minor gaps |
| 3 | Adequate — meets the minimum bar but nothing exceptional |
| 2 | Weak — some effort but significant gaps or errors |
| 1 | Poor — fundamental failure of this dimension |

---

## Theme 1: Narrative Coherence

*Does the report tell a story, or does it show tables?*

Score high if:
- The hero section states the root cause in one specific sentence, not a description of what declined
- Each section follows logically from the previous — the reader should never wonder "why is this here?"
- The report explicitly rules things out ("mix was checked and found not dominant") before drilling deeper
- The report is appropriately short: sections that weren't informative were omitted

Score low if:
- The hero section says "CVR declined due to multiple factors" or similarly non-committal
- Tables appear that the reader could not have known they needed
- The report runs through all possible analyses regardless of what the investigation revealed
- Sections are boilerplate-filled rather than written for this specific finding

---

## Theme 2: Hypothesis Specificity & Quality

*Did Claude form real hypotheses, or just describe what it saw?*

Score high if:
- Hypotheses are falsifiable: "LP2S dropped on Apr 8 because the mobile deploy that day broke the date-picker loading on iOS" is falsifiable; "LP2S dropped on mobile" is just an observation
- The report names the most likely explanation and distinguishes it from alternatives considered
- Session recordings or URL-level data were used to sharpen or eliminate a hypothesis
- The root cause names something specific: a campaign, a page URL, an experience, a date, a deploy — not a generic funnel step

Score low if:
- The report presents observations as hypotheses ("LP2S dropped, possibly due to UX or pricing or availability")
- Multiple root causes are listed without ranking them
- No attempt was made to distinguish what actually happened from what could have happened
- The verdict could apply to any CE on any day

---

## Theme 3: Investigation Effort & Adaptivity

*Did Claude go deep enough, and did it know when to stop?*

Score high if:
- A custom query was written when the standard queries couldn't confirm the hypothesis
- The investigation drilled to page-URL level when a dimension cut pointed there
- Session recordings were pulled once a specific URL or cut was identified (not as a fishing exercise)
- The investigation stopped when evidence was conclusive — it didn't keep running analyses "just in case"

Score low if:
- The standard queries were treated as sufficient even when they left a hypothesis unconfirmed
- A dimension cut showed a concentrated signal but no follow-up query was run to confirm the URL
- Session recordings were not used despite a specific URL being identified as the locus
- Unnecessary analyses were run (e.g., a full language breakdown when a single broken deploy explains everything)

---

## Theme 4: Branch Decision Quality

*At each fork, did Claude pick the right path?*

Score high if:
- The mix-vs-conversion decision was explicit and cited the actual mix_dominance data
- The primary MB/HO segment was called out and the reason for selecting it was stated
- The choice of which dimension to drill (language, page_type, device, experience) was the highest-signal one — the one most likely to concentrate the drop
- When a branch was not taken, the reason was stated (e.g., "C2O was 8% of Shapley — not the story")

Score low if:
- Mix was not checked before concluding a funnel problem
- The primary segment choice was not explained
- Dimension cuts were shown in a fixed order (device, language, page_type) regardless of which was most likely to be informative given the data
- Branches were chosen because they're "standard" rather than because they were the best next question

---

## Theme 5: Evidence Strength

*Are callouts backed by real evidence, or are they inferences without support?*

Score high if:
- Every claim in the report is tied to a specific data point (a number, a date, a URL, a recording observation)
- Session recordings, when used, produce a specific observation ("users consistently saw an empty calendar on the Paris river cruise page after Apr 3") not a vague one
- Confidence qualifiers are appropriate: sample sizes are noted when small, signals are described as "consistent with" rather than "proven" when the evidence is indirect
- There is a clear distinction between "confirmed" findings and "hypothesis to investigate"

Score low if:
- Claims are made without citing a number from the data (e.g., "LP2S dropped significantly" without stating the actual delta)
- Session recordings are referenced but produced no specific finding
- The report presents inferences as facts without noting they're inferences
- Small-sample data points are stated with false confidence

---

## Theme 6: Output Appropriateness

*Is the HTML report shaped by the story, not by a template?*

Score high if:
- The visual choice for each insight is appropriate: a trend chart was used for a gradual drift; a single callout was used for a single-day event (not a chart)
- Tables appear only where they added information — not as defaults
- The report length is proportional to the richness of the finding: a simple mix story has 4 sections; a multi-step investigation with URL and recording confirmation has more
- At least one component was chosen deliberately over the default — or the decision to use defaults was intentional and appropriate

Score low if:
- Every analysis that was run appears in the report, regardless of whether it was informative
- The same set of components appears regardless of the scenario (metric cards + shapley + 3 dimension tables + experience table is a template, not a story)
- Charts are used for single-date events where a callout would communicate the same thing better
- The report would look identical for a very different CE or scenario

---

## Theme 7: DRI & Actionability

*Does the report leave the reader knowing what to do?*

Score high if:
- DRI assignments name a specific team and a clear reason: "Supply team — the availability configuration for 'Seine River Cruise Premium' needs to be checked for dates Apr 1–14"
- Action items are scoped and testable: "Check whether the Apr 8 mobile deploy changed the date-picker rendering on iOS Safari" is testable; "Investigate the mobile UX" is not
- If session recordings were used, they produced at least one specific action
- The GM reading the report could forward the action card directly to the DRI without additional interpretation

Score low if:
- DRI is "Product team" without specifying what they should look at
- Action items say "investigate further" or "monitor the situation"
- The same action card could have been written for any LP2S drop on any CE
- Session recordings were mentioned but produced no actionable output

---

## Output format

Do not dump a score table. Write the evaluation as a structured assessment:

**1. Overall verdict** (3–4 sentences)
State the overall quality of this RCA in plain language. What did it get right? What was the main failure mode?

**2. Theme scores**
Present each theme with its score, justification, and improvement if applicable. Be specific. Cite actual content from the report.

**3. The top 2–3 things that would have made this RCA materially better**
These should be concrete and actionable for the next run — not generic advice.

---

## Self-honesty check

Before submitting the evaluation, ask yourself:

- Did I give scores that reflect what I would give a colleague's work, or did I inflate them because this is my own?
- Did I cite specific things from the report, or did I write vague justifications?
- Did I identify at least one real weakness, even if the overall quality was high?

An evaluation where every theme scores 4 or 5 with no improvements identified is almost certainly not honest.
