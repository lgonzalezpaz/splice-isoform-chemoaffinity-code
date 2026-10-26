#!/usr/bin/env bash
# Sensitivity analyses (reduced permutation counts); run after the main analysis.
set -e
cd "$(dirname "$0")"
export NRAND=300 NPSI=300 NPERM=2000
MAP=alt_NGC_Sncg TAG=_sens_mapNGC python3 src/06_adhesion_code.py > results/run_sens_mapNGC.log 2>&1
MAP=alt_6CT_L6b TAG=_sens_map6CT python3 src/06_adhesion_code.py > results/run_sens_map6CT.log 2>&1
OUTCOME=interaction_reldepth TAG=_sens_reldepth python3 src/06_adhesion_code.py > results/run_sens_reldepth.log 2>&1
OUTCOME=interaction_binary TAG=_sens_binary python3 src/06_adhesion_code.py > results/run_sens_binary.log 2>&1
INTER=data_ref/interactions_strict_rules.csv TAG=_sens_strictrules python3 src/06_adhesion_code.py > results/run_sens_strictrules.log 2>&1
