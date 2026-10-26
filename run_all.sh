#!/usr/bin/env bash
# Full pipeline. Inputs are downloaded to $DATA_DIR (default ./data); results go to $RES (default ./results).
# Steps marked [network] stream data from public archives; all others run offline on a 2-core / 8 GB machine.
set -euo pipefail
cd "$(dirname "$0")"
export DATA_DIR=${DATA_DIR:-$PWD/data}; export RES=${RES:-$PWD/results}
mkdir -p "$RES"/{microns,expression,splicing}
bash src/00_download_data.sh                                                    # [network] ~3.5 GB
python3 src/00a_annotation.py "$DATA_DIR/ref/gencode.vM25.annotation.gtf.gz" data_ref/adhesion_annotation_vM25.json
python3 src/00_select_cells.py 120                                              # SMART-seq cell sample (seed 1)
python3 src/01_filter_microns_connectome.py                                     # soma-to-soma table
python3 src/03_microns_specificity.py                                           # geometric null, specificity
python3 src/04_expression_profiles.py tasic
python3 src/04_expression_profiles.py patchseq
python3 src/02_extract_splicing.py "$DATA_DIR/tasic/cells_selected.tsv" "$DATA_DIR/splicing/tasic_all.jsonl" 48     # [network]
python3 src/02_extract_splicing.py "$DATA_DIR/patchseq/ps_cells_selected.tsv" "$DATA_DIR/splicing/ps_all.jsonl" 48  # [network]
python3 src/05a_cell_metadata.py
python3 src/05_splicing_events.py "$DATA_DIR/splicing/tasic_all.jsonl" "$RES/splicing/tasic_cells_meta.csv" "$RES/splicing/tasic_events.csv"
python3 src/07_patchseq_identity.py "$DATA_DIR/splicing/ps_all.jsonl" "$RES/splicing/patchseq_bam_identity.csv"
python3 src/05_splicing_events.py "$DATA_DIR/splicing/ps_all.jsonl" "$RES/splicing/patchseq_cells_meta.csv" "$RES/splicing/patchseq_events.csv"
python3 src/08_label_key_events.py "$RES/splicing/tasic_events.csv" "$RES/splicing/key_events.csv"   # [network: Ensembl REST, cached in data_ref]
python3 src/06_adhesion_code.py                                                 # main tests T1-T8
bash run_sensitivity.sh                                                         # five sensitivity analyses
python3 src/09_tables.py
for f in fig1_microns fig2_splicing fig3_code_test fig4_controls figS1_patchseq; do python3 src/$f.py; done
python3 -m pytest -q tests || true
