# Inception MATLAB Pipeline

This repository implements the modelling workflow used to define baseline brain states and run the two-stage Inception framework described in Acero-Pousa et al. (2025), *Inception: Simulating Personalized Long-Term Recovery in Disorders of Consciousness using Whole-Brain Computational Perturbations*.

The workflow is organized as follows:

0. **Baseline / individual model**  
   Fit a subject-specific whole-brain Hopf model to the empirical FC and empirical lagged covariance (`COV_tau`) of each participant. No node is perturbed; all nodes use the default sigma. This stage generates the **individual EC**, **individual FC**, and **individual COV_tau** matrices, which characterize the baseline state of each subject.

1. **Inception Stage 1: perturbed model**  
   Fit a subject-specific Hopf model to the empirical FC and empirical `COV_tau` while perturbing one node at a time by changing its sigma value. This stage generates the **perturbed EC**, **perturbed FC**, and **perturbed COV_tau** matrices, representing the state of the system during the active perturbation.

2. **Inception Stage 2: Inception model**  
   Fit a second unperturbed Hopf model using the **perturbed FC** and **perturbed COV_tau** from Stage 1 as inputs. This stage generates the **Inception EC**, **Inception FC**, and **Inception COV_tau** matrices, representing the post-perturbation state estimated by the Inception framework.

By default, the pipeline saves a table of similarity values to the target state instead of saving every full matrix for every node and perturbation intensity.
The input data and generated results are not included in this repository due to data privacy, licensing, and file-size constraints; users should place their own data in the `Data/` and `Output/` folders before running the pipeline.

## Folder structure

```text
inception_code/
├── main.m
├── config/
│   └── get_config.m
├── src/
│   ├── io/
│   ├── preprocessing/
│   ├── model/
│   ├── pipeline/
│   ├── visualization/
│   └── utils/
├── scripts/
│   └── check_project_setup.m
├── Data/
│   ├── SC.mat
│   └── ts_coma_24_AAL_symm.mat
└── Output/
    └── Results/
```

## Required input files

Place these files inside `Data/`:

- `SC.mat`: structural connectivity matrix. The preferred variable name is `C`.
- `ts_coma_24_AAL_symm.mat`: timeseries file containing variables named:
  - `timeseries_CNT24_symm`
  - `timeseries_MCS24_symm`
  - `timeseries_UWS24_symm`

You can change file names, paths, groups and parameters in `config/get_config.m`.

## How to run

From MATLAB, open the repository folder and run:

```matlab
main
```

Before running the full pipeline, you can check paths and required files with:

```matlab
run('scripts/check_project_setup.m')
```

## Main configuration

All parameters are centralized in:

```matlab
config/get_config.m
```

Important defaults:

```matlab
cfg.hopf.sigma_default = 0.02;
cfg.perturbation.type = 'individual_sigma';
cfg.perturbation.values = 0:0.05:0.5;
cfg.fit.max_iter = 5000;
cfg.storage.save_all_matrices = false;
cfg.storage.save_best_matrices = true;
```

## Outputs

All outputs are saved in:

```text
Output/Results/
```

The exact number of files depends on the groups, subjects, perturbation grid, and storage options defined in `config/get_config.m`.

### 1. Empirical frequency outputs

```text
Output/Results/empirical_frequencies_all_groups.mat
```

Contains the dominant empirical frequency estimates used by the Hopf model. These frequencies are computed from the preprocessed BOLD time series and are reused across the baseline, perturbed, and Inception model stages.

Main variable:

- `freq`: structure containing:
  - `freq.sub.<GROUP>`: subject-level frequency vectors.
  - `freq.group_mean.<GROUP>`: group-average frequency vector.

Example group fields:

```matlab
freq.sub.CNT24
freq.sub.MCS24
freq.sub.UWS24
freq.group_mean.CNT24
freq.group_mean.MCS24
freq.group_mean.UWS24
```

The pipeline also saves one compatibility file per group:

```text
Output/Results/empirical_CNT24.mat
Output/Results/empirical_MCS24.mat
Output/Results/empirical_UWS24.mat
```

Each file contains:

- `f_diff`: group-average dominant frequency vector.
- `f_diff_sub`: subject-level dominant frequency vectors.

### 2. Baseline / individual model outputs

For each group, the unperturbed baseline models are saved as:

```text
Output/Results/CNT24_individual_models.mat
Output/Results/MCS24_individual_models.mat
Output/Results/UWS24_individual_models.mat
```

Each file contains:

- `group_models`: structure array with one entry per subject.

Each subject entry contains:

- `group`: group name.
- `subject`: subject index.
- `model`: fitted baseline / individual Hopf model.
- `fit`: fitting diagnostics.
- `empirical`: empirical FC and empirical `COV_tau` used as fitting targets.

Inside `model`, the most relevant fields are:

- `model.Ceff`: individual EC matrix.
- `model.FCsim`: individual simulated FC matrix.
- `model.COVsim`: individual simulated zero-lag covariance.
- `model.COVtausim`: individual simulated lagged covariance at the selected time lag.
- `model.COVsimtotal`: full covariance matrix of the linearized Hopf system.
- `model.A`: Jacobian matrix of the fitted baseline model.
- `model.sigma_vec`: sigma vector used by the model. For baseline / individual models, all nodes use the default sigma.

Inside `fit`, the most relevant fields are:

- `fit.iterations`: number of fitting iterations.
- `fit.stopping_reason`: reason why fitting stopped.
- `fit.errorFC`: FC fitting error across iterations.
- `fit.errorCOVtau`: `COV_tau` fitting error across iterations.
- `fit.total_error`: combined fitting error across iterations.

### 3. Target state output

```text
Output/Results/target_state.mat
```

Contains the target brain state used to evaluate recovery. The target is computed from the target group, usually `CNT24`.

Main variable:

- `target`: structure containing:
  - `target.group`: name of the control group used to build the target.
  - `target.EC`: average individual EC across selected control subjects.
  - `target.FC`: average simulated FC across selected control subjects.
  - `target.COVtau`: average simulated `COV_tau` across selected control subjects.
  - `target.n_subjects`: number of control subjects included in the target.

The target is therefore a model-derived healthy-control state.

The baseline / individual matrices and the target matrices are used to characterize the initial and reference states, and to compute subsequent comparisons.

### 4. Subject-level Inception search outputs

For each patient subject, the pipeline saves one subject-level result file:

```text
Output/Results/MCS24_subject_001_inception_search.mat
Output/Results/MCS24_subject_002_inception_search.mat
...
Output/Results/UWS24_subject_001_inception_search.mat
Output/Results/UWS24_subject_002_inception_search.mat
...
```

The exact files depend on the groups and subjects selected in `config/get_config.m`.

Each file contains:

- `result`: structure containing the complete Inception perturbation search summary for that subject.

Inside `result`, the main fields are:

- `result.table`: table with one row per node and perturbation sigma.
- `result.summary`: best node and sigma summary for that subject.
- `result.best`: best perturbation according to the Inception EC distance.
- `result.empirical`: empirical FC and `COV_tau` of the subject.

The `result.table` contains one row per combination of:

```text
subject × perturbed node × perturbation sigma
```

Main columns:

- `group`: group name.
- `subject`: subject index.
- `node`: perturbed node.
- `sigma`: sigma value assigned to the perturbed node.

Distances from the **perturbed model** to the target:

- `perturbed_distance_EC`
- `perturbed_distance_FC`
- `perturbed_distance_COVtau`

Distances from the **Inception model** to the target:

- `inception_distance_EC`
- `inception_distance_FC`
- `inception_distance_COVtau`

Fitting diagnostics:

- `perturbed_iterations`: number of fitting iterations for the perturbed model.
- `inception_iterations`: number of fitting iterations for the Inception model.
- `perturbed_final_error`: final fitting error of the perturbed model.
- `inception_final_error`: final fitting error of the Inception model.
- `perturbed_stop`: stopping reason for the perturbed model.
- `inception_stop`: stopping reason for the Inception model.

The `result.summary` field contains:

- `summary.group`: group name.
- `summary.subject`: subject index.
- `summary.best_node_by_inception_EC`: node with the lowest Inception EC distance to the target.
- `summary.best_sigma_by_inception_EC`: sigma value associated with the best node.
- `summary.best_distance_inception_EC`: minimum Inception EC distance to the target.

The `result.best` field contains:

- `best.distance_EC`: best Inception EC distance.
- `best.node`: best perturbed node.
- `best.sigma`: best perturbation sigma.
- `best.perturbed_model`: best perturbed model, if `cfg.storage.save_best_matrices = true`.
- `best.inception_model`: best Inception model, if `cfg.storage.save_best_matrices = true`.

When `cfg.storage.save_best_matrices = true`, the best perturbed and Inception models are stored inside the subject-level result file. They are not saved as separate files.

When `cfg.storage.save_all_matrices = true`, the file may also contain:

- `result.all_matrices`: all perturbed and Inception models for every node and sigma.

This option can generate very large files and is disabled by default.

### 5. Global similarity table

The most important summary output is saved in both MATLAB and CSV format:

```text
Output/Results/inception_similarity_table.mat
Output/Results/inception_similarity_table.csv
```

These files combine the subject-level Inception search tables across all selected patient groups and subjects.

The `.mat` file contains:

- `inception_table`: full table of similarity values.
- `patient_results`: summary structure for all patient subjects.

The `.csv` file contains the same `inception_table` in a format that can be opened in external software.

Each row corresponds to one:

```text
group × subject × perturbed node × perturbation sigma
```

Main columns:

- `group`: group name.
- `subject`: subject index.
- `node`: perturbed node.
- `sigma`: perturbation sigma.

Perturbed model distances to the target:

- `perturbed_distance_EC`
- `perturbed_distance_FC`
- `perturbed_distance_COVtau`

Inception model distances to the target:

- `inception_distance_EC`
- `inception_distance_FC`
- `inception_distance_COVtau`

Fitting diagnostics:

- `perturbed_iterations`
- `inception_iterations`
- `perturbed_final_error`
- `inception_final_error`
- `perturbed_stop`
- `inception_stop`

This table is the main output for identifying the optimal perturbation node and sigma for each subject.

For example, the optimal node according to Inception EC can be obtained by finding, for each subject, the row with the minimum:

```matlab
inception_distance_EC
```

### 6. Full pipeline output file

```text
Output/Results/inception_pipeline_outputs.mat
```

Contains the main outputs of the full pipeline in a single structure.

Main variable:

- `outputs`: structure containing:
  - `outputs.individual_models`: all fitted baseline / individual models.
  - `outputs.target`: target state.
  - `outputs.patient_results`: best-node summaries for patient subjects.
  - `outputs.inception_table`: full node × sigma similarity table.

This file is useful if you want to reload the complete pipeline output in MATLAB without reading several separate files.

### 7. Final summary figure

If figure generation is enabled in `main.m` and `config/get_config.m`, the pipeline saves:

```text
Output/Results/Figure_recovery_EC_summary.png
Output/Results/Figure_recovery_EC_summary.fig
```

The figure summarizes the EC distance to the target state.

It compares:

- `HC`: individual control EC distances to the target EC.
- `MCS` or `UWS`: baseline patient EC distances to the target EC.
- `R`: recovery/Inception EC distance to the target EC, using each subject’s best perturbation.

The `.png` file is useful for quick visualization and sharing.

The `.fig` file is the editable MATLAB figure.

## Requirements

This code was developed and tested in MATLAB R2025b.

Required MATLAB toolboxes:

- Signal Processing Toolbox  
  Used for filtering and time-series operations such as `butter`, `filtfilt`, and `xcov`.

- Control System Toolbox  
  Used for solving the continuous Lyapunov equation with `lyap`.

- Statistics and Machine Learning Toolbox  
  Used for functions such as `ksdensity`, `ranksum`, `signrank`, and possibly other statistical utilities used in the plotting/statistical summary.
