# A connectome-calibrated test of a splice-isoform chemoaffinity code in mouse visual cortex

Code and derived data for the manuscript *"A connectome-calibrated test of a splice-isoform chemoaffinity code in mouse visual cortex"* ([AUTHORS], [YEAR]).

The pipeline integrates

* **MICrONS** minnie65 connectome (static materialization v1412): proofread axons, perisomatic cell-type labels and soma-to-soma synapse tables;
* **Allen Institute SMART-seq v4** VISp transcriptomes (Tasic *et al.* 2018; GEO GSE115746) and their per-cell STAR alignments on NeMO;
* **Allen Institute Patch-seq** VISp interneurons (Gouwens *et al.* 2020; NeMO),

to test whether isoform-gated compatibility of curated trans-synaptic adhesion molecules predicts geometry-corrected type-to-type connectivity.

A key component is `src/remote_bam.py`, which reads arbitrary loci from **coordinate-sorted BAM files that have no index and are packed in tar archives on an HTTP server**, by binary search over BGZF blocks with HTTP range requests. It reproduces pysam output exactly (`tests/test_remote_bam.py`) while transferring ~28 MB per cell instead of 100–250 MB.

## Quick start

```bash
conda env create -f environment.yml && conda activate splice-adhesion-code   # or: pip install -r requirements.txt
export DATA_DIR=$PWD/data RES=$PWD/results
bash run_all.sh            # full pipeline: downloads (~3.5 GB), remote extraction (~94 GB streamed, not stored), analyses, figures
```

Hardware: 2 CPU cores, 8 GB RAM, ~10 GB disk. Wall time ≈ 6 h, dominated by network transfer (remote junction extraction ≈ 2.5 h with 48 concurrent connections).

To reproduce all statistics and figures **without network access to NeMO**, use the derived per-cell junction tables deposited with this release (`data_derived/`, also on Zenodo):

```bash
mkdir -p data/splicing && gunzip -c data_derived/tasic_all.jsonl.gz > data/splicing/tasic_all.jsonl && gunzip -c data_derived/ps_all.jsonl.gz > data/splicing/ps_all.jsonl
# then run run_all.sh skipping the two lines marked [network] for 02_extract_splicing.py
```

## Repository layout

| Path | Content |
|---|---|
| `src/00_download_data.sh` | Downloads all public inputs (MICrONS v1412 tables, GEO GSE115746, NeMO metadata/counts and file listings, GENCODE vM25) |
| `src/00a_annotation.py` | Gene bodies, annotated cassette exons and clustered-Pcdh variable exons from GENCODE vM25 |
| `src/00_select_cells.py` | Random selection of SMART-seq cells (≤120 per subclass, seed 1) and Patch-seq files (1,800, seed 7) |
| `src/01_filter_microns_connectome.py` | Streams the 2.9 GB connection table; keeps neuron pairs with nuclei |
| `src/02_extract_splicing.py` | Remote, locus-restricted junction/read extraction (uses `remote_bam.py`, `chrom_map.py`) |
| `src/03_microns_specificity.py` | Geometric (Peters-rule) null, log2 O/E, double-centred interaction term, bootstrap, alternative nulls (Eqs. 1–4) |
| `src/04_expression_profiles.py` | Subclass mean log2(CPM+1) from SMART-seq and Patch-seq count matrices (two streaming passes) |
| `src/05a_cell_metadata.py`, `src/05_splicing_events.py` | De novo cassette/alternative-site events, pseudobulk Ψ, bootstrap CIs, permutation heterogeneity test (Eqs. 6–7) |
| `src/07_patchseq_identity.py` | Assigns NeMO Patch-seq alignment files to cells by read-count fingerprinting + sequencing-tube check |
| `src/08_label_key_events.py` | Identifies SS4, meA/meB and teneurin inserts by translating exon sequences (Ensembl REST, cached) |
| `src/06_adhesion_code.py` | Isoform-gated compatibility (Eqs. 8–10) and tests T1–T8 (Eqs. 11–12); environment variables `EXPR`, `MAP`, `OUTCOME`, `TAG`, `NPERM`, `NRAND`, `NPSI` |
| `run_sensitivity.sh` | Five sensitivity analyses |
| `src/09_tables.py`, `src/fig*.py`, `src/fig_style.py` | Tables 1–3 and Figures 1–4, S1 (PDF/SVG vector + 600-dpi PNG) |
| `data_ref/` | Curated interactions with isoform rules and references (`interactions.csv`), annotation JSON, gene lists, exon-sequence cache |
| `data_derived/` | Per-cell junction tables (JSON lines, gzipped) for 1,543 SMART-seq and 1,800 Patch-seq cells |
| `results/` | All numerical outputs (type-pair statistics, events, summaries of every test and sensitivity analysis) |
| `figures/` | Figures 1–4 and Supplementary Figure 1 |
| `manuscript/` | Manuscript source (`manuscript_source.md`), tables (`tables.json`), DOCX builder (`build_docx.js`), final DOCX |
| `manuscript_tools/` | Reference verification against Europe PMC (`verify_refs.py`, `refs_verified.json`) |
| `tests/` | `test_remote_bam.py`: remote vs pysam concordance |

## Main outputs

* `results/microns/type_pair_stats.csv` — O, E, log2 O/E, interaction term with bootstrap 95% CIs, alternative nulls, multisynaptic fraction and cleft size for 121 type pairs.
* `results/splicing/tasic_events.csv`, `patchseq_events.csv` — all events with Ψ, CIs, permutation *P* and FDR; `key_events.csv` — sequence-verified inserts.
* `results/code/summary.json` — tests T1–T8 (main analysis); `results/code_sens_*/summary.json` — sensitivity analyses; `results/robustness_table.csv`.

## Data sources (all public)

* MICrONS: `gs://mat_dbs/public/minnie65_phase3_v1/v1412` (HTTPS: `https://storage.googleapis.com/mat_dbs/public/minnie65_phase3_v1/v1412/`), BossDB `iarpa_microns`. MICrONS Consortium, *Nature* 640, 435–447 (2025).
* SMART-seq v4 VISp: GEO GSE115746; alignments `https://data.nemoarchive.org/biccn/grant/u19_zeng/zeng/transcriptome/scell/SSv4/mouse/processed/align/VISp/`. Tasic *et al.*, *Nature* 563, 72–78 (2018).
* Patch-seq: `https://data.nemoarchive.org/other/AIBS/AIBS_patchseq/transcriptome/scell/SMARTseq/processed/`. Gouwens *et al.*, *Cell* 183, 935–953 (2020).
* GENCODE vM25 (GRCm38): `https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/`.

## Reproducibility notes

* All random seeds are fixed (cell selection: 1 and 7; analyses: 20261022, 1, 3).
* Permutation *P* values are (1 + b)/(1 + B); their resolution is limited by B.
* Leave-one-pair-out ridge predictions are computed in closed form (Eq. 12) and were checked against explicit refits (max. difference 1.8 × 10⁻¹⁵).
* Ensembl sequence look-ups are cached in `data_ref/exon_sequences_cache.json`, so step 08 runs offline.

## Citation and licence

Please cite the article and the Zenodo archive ([ZENODO DOI]); see `CITATION.cff`. Code is released under the MIT licence (`LICENSE`). Third-party data remain under their original terms (MICrONS: CC BY 4.0; Allen Institute data: Allen Institute Terms of Use).
