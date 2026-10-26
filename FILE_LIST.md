# File list for GitHub and Zenodo deposition (release v1.0.0)

## Root
- `README.md` — overview, quick start, layout, data sources, reproducibility notes
- `LICENSE` — MIT
- `CITATION.cff` — citation metadata (fill author names, repository URL, DOI)
- `.zenodo.json` — Zenodo deposition metadata
- `environment.yml`, `requirements.txt` — pinned software environment (Python 3.13)
- `run_all.sh` — full pipeline; `run_sensitivity.sh` — six sensitivity analyses
- `FILE_LIST.md` — this file
- `.gitignore` — excludes downloaded raw inputs (`data/`) and caches

## src/ (analysis code, run in numerical order by run_all.sh)
- `paths.py` — repository/data/results paths (env: `DATA_DIR`, `RES`)
- `00_download_data.sh` — public input download
- `00a_annotation.py` — GENCODE vM25 annotation of target genes, cassette exons, Pcdh variable exons
- `00_select_cells.py` — seeded cell/file selection
- `01_filter_microns_connectome.py` — soma-to-soma connection table
- `02_extract_splicing.py`, `remote_bam.py`, `chrom_map.py` — remote junction extraction from unindexed BAMs
- `03_microns_specificity.py` — geometric null, specificity, interaction term, bootstrap, reliability inputs
- `04_expression_profiles.py` — subclass expression profiles
- `05a_cell_metadata.py`, `05_splicing_events.py` — splicing events, Ψ, permutation tests
- `06_adhesion_code.py` — compatibility scores and tests T1–T8
- `07_patchseq_identity.py` — Patch-seq file-to-cell assignment
- `08_label_key_events.py` — sequence verification of SS4, meA/meB, teneurin inserts
- `09_tables.py`, `10_supp_tables.py` — main and supplementary tables
- `fig_style.py`, `fig1_microns.py`, `fig2_splicing.py`, `fig3_code_test.py`, `fig4_controls.py`, `figS1_patchseq.py` — figures

## tests/
- `test_remote_bam.py` — remote reader vs pysam concordance

## data_ref/ (curated inputs)
- `interactions.csv` — 33 curated interactions (32 analysed + clustered Pcdh), splice rules, reference keys
- `interactions_strict_rules.csv` — sensitivity variant (neuroligin-1 and dystroglycan without SS4 rule)
- `adhesion_annotation_vM25.json` — gene bodies, cassette exons, Pcdh variable exons
- `genes_cell_level.txt`, `splicing_regulators.txt` — gene lists
- `exon_sequences_cache.json` — Ensembl GRCm38 sequences used for insert verification (offline reproducibility)

## data_derived/ (Zenodo; also in GitHub release assets)
- `tasic_all.jsonl.gz` — per-cell gene reads, junction fragments and Pcdh variable-exon counts, 1,543 SMART-seq v4 VISp neurons
- `ps_all.jsonl.gz` — same for 1,800 Patch-seq alignment files
- `tasic_cells_selected.tsv`, `patchseq_files_selected.tsv` — selected cells/files with source URLs

## results/
- `microns/` — `type_pair_stats.csv`, `pre_neurons.csv`, `neurons.csv`, O/E arrays per null, bootstrap arrays, `proofread_connections.csv.gz`
- `expression/` — subclass mean log2(CPM+1) and detection (SMART-seq, Patch-seq), Patch-seq metadata used
- `splicing/` — event tables (SMART-seq, Patch-seq), key events, Patch-seq identity table, Pcdh tables, figure statistics
- `code/` — main analysis (`summary.json`, T1 table, CV predictions, null distributions); `code_sens_*/` — sensitivity analyses
- `Table1.csv`, `Table2.csv`, `Table3.csv`, `TableS2.csv`, `robustness_table.csv`

## figures/
- `Figure1–4` and `FigureS1` as `.pdf` and `.svg` (vector, editable text) and `.png` (600 dpi); `_web.png` (300 dpi) used for embedding

## manuscript/
- `manuscript.docx` — final manuscript (Word); `supplementary_information.docx`
- `manuscript_source.md`, `supplementary_source.md`, `tables.json`, `supp_tables.json`, `equations.tex`
- `build_docx.js` — DOCX builder (Node.js, docx library)

## manuscript_tools/
- `verify_refs.py`, `refs_verified.json`, `verify_log.txt` — reference metadata verified against Europe PMC (including erratum/retraction screening)
