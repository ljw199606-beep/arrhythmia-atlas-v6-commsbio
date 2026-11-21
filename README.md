# Human Cardiac Transcriptomic Remodeling in Atrial Fibrillation and After Myocardial Infarction — Reproducibility Repository (V6, *Communications Biology*)

This versioned reproducibility repository accompanies the *Communications Biology* submission:

> **Human cardiac transcriptomic remodeling in atrial fibrillation and after myocardial infarction**

It provides **two reproducible entry points**:

1. **Fast Reviewer Verification (`< 30 s`, lightweight Python environment)** — independently recomputes and asserts every reported donor-level external bulk classification metric (17 tasks, 11 zero-overlap LOCO/LOIO folds, 2,000× stratified bootstrap 95% CIs, AUPRC, Brier score, prevalence-specific `Brier_null = p(1-p)`, and Brier Skill Score `BSS`), verifies all single-cell/spatial/VirtualMyocyte research units and 3-chamber `.mmt` model checksums, and verifies via `PyMuPDF` that all 15 submission figure PDFs satisfy `8.0–12.0 pt` embedded TrueType Arial typography at `183 mm` double-column print width.
2. **Full Upstream Reconstruction (requires public GEO / Zenodo / CZ CELLxGENE inputs listed in `manifests/provenance_manifest_v6.tsv`)** — executes end-to-end bulk L1 retraining, the strict donor-grouped inner-CV sensitivity (`v6_sens_strict_donor_inner_cv`), VirtualMyocyte ODE endpoint-driven checks, and print-size publication figure rendering.

---

## Repository Layout

```text
.
├── README.md
├── LICENSE                       # MIT (code) + CC-BY-4.0 notice (audit/source data)
├── CITATION.cff                  # Machine-readable citation metadata
├── requirements-verify.txt       # Minimal reviewer verification dependencies
├── requirements-full.txt         # Full upstream reconstruction + plotting dependencies
├── environment.yml               # Conda environment specification (Python 3.10.20)
├── Dockerfile                    # Containerized reviewer verification image
├── scripts/
│   ├── run_reviewer_quickcheck.py              # Single-command fast reviewer verification
│   ├── recompute_bulk_from_predictions_v6.py   # 17/17 bulk AUROC/CI/AUPRC/Brier/BSS + 11/11 disjoint audit
│   ├── verify_all_v6_units_and_tables.py       # SC (93d/422,737), spatial (20d/26blk), VirtualMyocyte, CiPA 12/16
│   ├── audit_pdf_fonts.py                      # PyMuPDF native PDF font-size (8.0-12.0 pt) & width audit
│   ├── v6_01_literature_ssot_and_spatial_sc.py # Upstream SC/spatial harmonization & PubMed SSOT
│   ├── v6_02_bulk_retrain_and_verify.py        # Upstream archived V6 bulk L1 LOCO/LOIO + 100x null
│   ├── v6_02b_bulk_strict_donor_inner_cv_sensitivity.py # Strict donor-grouped inner-CV + symmetric C-tuning
│   ├── v6_03_vm_endpoint_driven_check.py       # Algorithmic pre-specified EP check (17/17 in-scope + HCN4 OOS)
│   ├── v6_04a_tables_and_audit_ledger_v6.py    # Publication tables & 46-sheet workbook assembly
│   ├── v6_pubfont_style.py                     # 8.0-12.0 pt Arial print typography & collision auditor
│   └── v6_04b_figures_v6_pubfont.py            # Re-renders all 7 Main + 8 Supplementary figures (183 mm width)
├── virtualmyocyte/               # VirtualMyocyte v3.0.0 package + ohara-2011 / courtemanche-1998 / stewart-2009 .mmt
├── data_audit/                   # Audited V6 CSV/JSON outputs + strict donor inner-CV sensitivity outputs
├── source_data/                  # Panel-by-panel plot source data CSVs (42 files) + figure_panel_source_map.tsv
├── figures/                      # All 7 Main + 8 Supplementary PDFs & PNGs (8.0-11.5 pt Arial, 183 mm width)
└── manifests/
    ├── provenance_manifest_v6.tsv              # 32-asset SHA-256 provenance registry (GEO/Zenodo/CELLxGENE/.mmt)
    ├── figure_font_and_layout_audit.csv        # PyMuPDF native font-size audit table (15/15 PASS)
    ├── historical_vs_v6_diff.md                # Exact diff vs legacy GitHub/Zenodo v1.0.0 releases
    ├── Author_Decision_Memo_Bulk_Sensitivity.md # Archived V6 vs strict donor-grouped inner-CV comparison
    ├── clean_checkout_test_log.txt             # Clean `git clone` verification transcript
    └── SHA256SUMS.txt                          # Complete repository SHA-256 manifest
```

---

## Entry Point 1: Fast Reviewer Verification (`< 30 s`)

```bash
pip install -r requirements-verify.txt
python scripts/run_reviewer_quickcheck.py
```

Or run each independent audit individually:

```bash
# 1. Bulk donor-disjoint predictions (17/17 tasks, 11/11 zero-overlap folds, 2,000x boot CI, Brier/BSS)
python scripts/recompute_bulk_from_predictions_v6.py data_audit

# 2. Research units (93 SC donors, 422,737 GEM-well / 364,073 excl. HCA v1; 20 Visium donors / 26 blocks;
#    964 bulk donors / 1,054 specimens; VirtualMyocyte .mmt SHA-256, 13-plotted vs 18-total S5.3, CiPA 12/16)
python scripts/verify_all_v6_units_and_tables.py data_audit virtualmyocyte

# 3. Native PDF typography audit (15/15 figures strictly 8.0-12.0 pt Arial at 183.0 mm double-column width)
python scripts/audit_pdf_fonts.py figures
```

### Containerized Execution (Docker)

```bash
docker build -t arrhythmia-atlas-v6 .
docker run --rm arrhythmia-atlas-v6
```

---

## Entry Point 2: Full Upstream Reconstruction

Download the raw public GEO / Zenodo / CZ CELLxGENE datasets listed with exact accession numbers, download URLs, and SHA-256 checksums in `manifests/provenance_manifest_v6.tsv` into `<ATLAS_ROOT>/02_data/`, install full dependencies (`conda env create -f environment.yml` or `pip install -r requirements-full.txt`), and execute:

```bash
export ATLAS_ROOT=/path/to/workspace_with_02_data

# Archived V6 donor-disjoint bulk L1 pipeline (reproduces data_audit/bulk_*_v6.csv)
python scripts/v6_02_bulk_retrain_and_verify.py

# Strict donor-grouped inner-CV + inner-fold scaling + symmetric 100x random-null sensitivity
python scripts/v6_02b_bulk_strict_donor_inner_cv_sensitivity.py --root "$ATLAS_ROOT"

# Algorithmic pre-specified VirtualMyocyte endpoint check
python scripts/v6_03_vm_endpoint_driven_check.py

# Re-render all 15 publication-size (8.0-12.0 pt Arial, 183 mm width) Main & Supplementary figures
python scripts/v6_04b_figures_v6_pubfont.py --root "$ATLAS_ROOT" --out ./figures_rebuilt
```

---

## Key Methodological Notes & Audit Transparency

- **Bulk Strict Donor-Grouped Inner-CV Sensitivity (`data_audit/v6_sens_strict_donor_inner_cv/`)**: Preserves the archived V6 primary results intact while providing a version-tagged strict sensitivity using `StratifiedGroupKFold` grouped by `global_donor_id`, inner-fold `StandardScaler`, and identical 10-point inner-CV `C`-tuning on both the 69-gene candidate panel and all 100 random 69-gene panels. Across all 11 external folds, AUROC shifts are minimal (`-0.0180` to `+0.0275`) and the exact same `5/11` external folds have negative Brier Skill Score (`BSS < 0`). In `GSE69890` (`n = 180`), symmetric inner-CV `C`-tuning shifts the 100-permutation background comparison from `0.9037 vs 0.8426 ± 0.0522` (`p = 0.1188`) to `0.9231 vs 0.8169 ± 0.0619` (`z = 1.717`, `p = 0.0396`); see `manifests/Author_Decision_Memo_Bulk_Sensitivity.md`.
- **VirtualMyocyte Endpoint Alignment (`Fig 5D` / `S5.3`)**: Uses Myokit `1.39.2` CVODE with unmodified `ohara-2011.mmt`, `courtemanche-1998.mmt`, and `stewart-2009.mmt` (`80` beats at `1 Hz`). `Fig 5D` plots `13` representative scenarios across two endpoint-aligned tracks (`10` primary repolarization + `3` depolarization/Ca²⁺ handling) while noting `CH18 (HCN4)` as out-of-scope (no SAN pacemaker model); all `18` scenarios are reported in full in `S5.3`. The `PLN` Ca²⁺-handling primary endpoint (`-65.27%` Ca²⁺ transient amplitude vs `-0.71%` APD90) is transparently documented as a post-hoc endpoint correction from legacy APD90-only reporting.
- **Historical Version Provenance**: Supersedes legacy GitHub commit `1686b984d8` and legacy Zenodo v1.0.0 deposits (`10.5281/zenodo.20695145`, `10.5281/zenodo.20695147`; Concept DOIs `10.5281/zenodo.20695144`, `10.5281/zenodo.20695146`). See `manifests/historical_vs_v6_diff.md` for full reconciliation.

---

## License

- Source code (`scripts/`, `virtualmyocyte/`): **MIT License** (see `LICENSE`).
- Curated audit tables, panel source data, and figure files (`data_audit/`, `source_data/`, `figures/`, `manifests/`): **CC-BY-4.0**. Raw public single-cell, spatial, and bulk datasets remain governed by their original GEO / Zenodo / CZ CELLxGENE licenses.
