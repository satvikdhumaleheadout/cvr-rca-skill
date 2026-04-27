#!/usr/bin/env bash
# run_analysis.sh — Runs all BQ queries and produces summary.json
#
# Usage:
#   ./run_analysis.sh <ce_id> <pre_start> <pre_end> <post_start> <post_end>
#
# Example:
#   ./run_analysis.sh 167 2024-04-01 2024-04-07 2024-04-08 2024-04-14
#
# Output:
#   /tmp/cvr_rca_<ce_id>/summary.json    ← Claude reads this
#   /tmp/cvr_rca_<ce_id>/stage*.json     ← raw BQ output (kept for debugging)
#
# Query execution order:
#   Q0 (serial)  → CE name + top page URL              → stage0.json
#   Q1 (serial)  → base funnel, determines PRIMARY_MBHO → stage1.json
#   Q3+Q7 (parallel) → daily trend (pre/post) + 90-day rolling trend + LY
#
# Demoted to reference-only (not auto-run — Claude queries these when needed):
#   Q2 → dimension cuts (device / language / page_type)
#   Q4 → experience-level breakdown
#   Q5 → price analysis
#   Q6 → URL-level funnel
# SQL templates remain in references/ for Claude to adapt during investigation.

set -euo pipefail

CE_ID="${1:?Usage: run_analysis.sh <ce_id> <pre_start> <pre_end> <post_start> <post_end>}"
PRE_START="${2:?Missing pre_start}"
PRE_END="${3:?Missing pre_end}"
POST_START="${4:?Missing post_start}"
POST_END="${5:?Missing post_end}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REFS_DIR="$SCRIPT_DIR/../references"
OUTPUT_DIR="/tmp/cvr_rca_${CE_ID}"
export OUTPUT_DIR

mkdir -p "$OUTPUT_DIR"

BQ="bq query --use_legacy_sql=false --format=json --quiet --max_rows=1000 --project_id=headout-analytics"

# ── Helper: substitute all placeholders in a SQL file ──────────────────────────
substitute_sql() {
  local sql_file="$1"
  local primary_mbho="${2:-ALL}"
  sed \
    -e "s/{{CE_ID}}/$CE_ID/g" \
    -e "s/{{PRE_START}}/$PRE_START/g" \
    -e "s/{{PRE_END}}/$PRE_END/g" \
    -e "s/{{POST_START}}/$POST_START/g" \
    -e "s/{{POST_END}}/$POST_END/g" \
    -e "s/{{PRIMARY_MBHO}}/$primary_mbho/g" \
    "$sql_file"
}

# ── Stage 0: CE metadata + top page URL (serial — populates report header) ────
echo "[0/4] Fetching CE metadata..."
substitute_sql "$REFS_DIR/q0_meta.sql" | $BQ > "$OUTPUT_DIR/stage0.json"
echo "      Done. $(python3 -c "import json; d=json.load(open('$OUTPUT_DIR/stage0.json')); print(d[0].get('combined_entity_name', '(unknown)') if d else '(no rows)')")"

# ── Stage 1: Base funnel (always runs next, determines primary segment) ────────
echo "[1/4] Running base funnel query..."
substitute_sql "$REFS_DIR/q1_base.sql" | $BQ > "$OUTPUT_DIR/stage1.json"
echo "      Done. $(python3 -c "import json; d=json.load(open('$OUTPUT_DIR/stage1.json')); print(len(d), 'rows')")"

# ── Determine primary MB/HO from Stage 1 results ──────────────────────────────
PRIMARY_MBHO=$(python3 - <<'PYEOF'
import json, sys, os
data = json.load(open(os.environ['OUTPUT_DIR'] + '/stage1.json'))
post = [r for r in data if r.get('mb_ho') not in ('ALL', None) and r.get('period') == 'post']
if not post:
    print('ALL')
    sys.exit()
agg = {}
for r in post:
    k = r['mb_ho']
    agg[k] = agg.get(k, 0) + int(r.get('users_lp') or 0)
print(max(agg, key=agg.get))
PYEOF
)
export OUTPUT_DIR PRIMARY_MBHO
echo "      Primary MB/HO: $PRIMARY_MBHO"

# ── Stage 3 + 7: Run in parallel ──────────────────────────────────────────────
echo "[2/4] Running daily trend and 90-day rolling trend + LY in parallel..."

substitute_sql "$REFS_DIR/q3_trend.sql" "$PRIMARY_MBHO" \
  | $BQ > "$OUTPUT_DIR/stage3.json" &
PID_Q3=$!

# Q7: 90-day rolling CVR trend + last-year equivalent (POST_END drives both windows)
substitute_sql "$REFS_DIR/q7_trend_and_ly.sql" \
  | $BQ > "$OUTPUT_DIR/stage7.json" &
PID_Q7=$!

wait $PID_Q3 && echo "      Daily trend done."
wait $PID_Q7 && echo "      90-day trend + LY done."

# ── Aggregate: raw JSON → summary.json ────────────────────────────────────────
echo "[3/4] Aggregating results..."
python3 "$SCRIPT_DIR/aggregate.py" \
  --stage0       "$OUTPUT_DIR/stage0.json" \
  --stage1       "$OUTPUT_DIR/stage1.json" \
  --stage3       "$OUTPUT_DIR/stage3.json" \
  --stage7       "$OUTPUT_DIR/stage7.json" \
  --ce_id        "$CE_ID" \
  --pre_start    "$PRE_START" \
  --pre_end      "$PRE_END" \
  --post_start   "$POST_START" \
  --post_end     "$POST_END" \
  --primary_mbho "$PRIMARY_MBHO" \
  --output       "$OUTPUT_DIR/summary.json"

echo ""
echo "Analysis complete."
echo "Summary  → $OUTPUT_DIR/summary.json"
echo "Raw data → $OUTPUT_DIR/stage{0,1,3,7}.json  (keep for debugging)"
