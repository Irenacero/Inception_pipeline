# Pipeline overview

This file describes the computational workflow implemented in the Inception MATLAB pipeline.

The workflow contains:

1. a preprocessing step to estimate empirical node frequencies;
2. a baseline / Stage 0 model used to define the individual and target states;
3. the two-stage Inception framework:
   - Inception Stage 1: perturbed model;
   - Inception Stage 2: Inception model.

## Preprocessing: empirical frequencies

`compute_empirical_frequencies` estimates the dominant frequency of each node for each subject:

1. Detrend each regional time series.
2. Bandpass filter the signal.
3. Remove filter-edge samples.
4. Compute the power spectrum.
5. Smooth the spectrum using `gaussfilt`.
6. Select the frequency with maximum smoothed power.

These empirical frequencies are used by the Hopf model throughout the workflow.

## Baseline / Stage 0: individual model

Before running the Inception framework, the pipeline defines the baseline state of each subject.

For each subject:

1. Compute empirical FC from the preprocessed BOLD time series.
2. Compute empirical `COV_tau`.
3. Fit a linearized Hopf model to the empirical FC and empirical `COV_tau`.
4. Use the default sigma value for all nodes:

```matlab
cfg.hopf.sigma_default = 0.02;
```

No node is perturbed in this stage.

Output:

- individual EC;
- individual FC;
- individual `COV_tau`.

Here, individual EC refers to the fitted directed coupling matrix inferred by the model. Individual FC refers to the simulated functional connectivity of the fitted model, and individual `COV_tau` refers to the simulated lagged covariance structure.

This stage is used to characterize the baseline state of each subject and to build the healthy target state.

## Target state

The target state is computed from the target group, in this case `CNT24`.

First, a baseline / individual model is fitted for each selected control subject. Then, the target matrices are computed by averaging the simulated outputs across control subjects:

- target EC = mean control individual EC;
- target FC = mean control individual FC;
- target `COV_tau` = mean control individual `COV_tau`.

The target state is therefore a model-derived healthy-control reference state.

## Inception Stage 1: perturbed model

In the first stage of the Inception framework, each patient subject is modelled while applying an in silico perturbation.

For each patient subject, perturbed node, and sigma value:

1. Build a sigma vector where all nodes have the default sigma value.
2. Replace the sigma value of the perturbed node with the current perturbation value.
3. Fit EC to the subject’s empirical FC and empirical `COV_tau` using this node-wise sigma vector.
4. Compute the perturbed FC and perturbed `COV_tau`.
5. Store distances between the perturbed model and the target state.

Output:

- perturbed EC;
- perturbed FC;
- perturbed `COV_tau`.

The perturbed model represents the state of the system during the active perturbation.

## Inception Stage 2: Inception model

In the second stage of the Inception framework, a new unperturbed model is fitted to the outputs of the perturbed model.

For each perturbed model:

1. Use the perturbed FC and perturbed `COV_tau` as the fitting targets.
2. Fit a new unperturbed Hopf model, with all sigmas set to the default value.
3. Compute the Inception EC, Inception FC, and Inception `COV_tau`.
4. Store distances between the Inception model and the target state.

Output:

- Inception EC;
- Inception FC;
- Inception `COV_tau`.

The Inception model represents the estimated post-perturbation state that emerges after the perturbation.

## Perturbation search

The Inception framework is repeated systematically across:

- patient subjects;
- perturbed nodes;
- perturbation sigma values.

By default, the perturbation grid is:

```matlab
cfg.perturbation.nodes = 1:90;
cfg.perturbation.values = 0:0.05:0.5;
```

For each subject, the optimal perturbation is identified as the node and sigma value that minimize the distance between the Inception EC and the target EC.

## Main distance outputs

For each subject, node, and sigma value, the pipeline stores:

Distances from the perturbed model to the target:

- `perturbed_distance_EC`;
- `perturbed_distance_FC`;
- `perturbed_distance_COVtau`.

Distances from the Inception model to the target:

- `inception_distance_EC`;
- `inception_distance_FC`;
- `inception_distance_COVtau`.

The main output table is:

```text
Output/Results/inception_similarity_table.csv
Output/Results/inception_similarity_table.mat
```

Each row corresponds to one:

```text
group × subject × perturbed node × perturbation sigma
```

## Summary of terminology

| Term | Meaning |
|---|---|
| Empirical FC | FC computed directly from the preprocessed BOLD time series |
| Empirical `COV_tau` | Lagged covariance computed directly from the preprocessed BOLD time series |
| Individual EC | Baseline EC fitted by the unperturbed Hopf model |
| Individual FC | Simulated FC generated by the baseline model |
| Individual `COV_tau` | Simulated lagged covariance generated by the baseline model |
| Target EC | Average individual EC across selected control subjects |
| Target FC | Average individual FC across selected control subjects |
| Target `COV_tau` | Average individual `COV_tau` across selected control subjects |
| Perturbed EC | EC fitted during active node-wise perturbation |
| Perturbed FC | Simulated FC generated by the perturbed model |
| Perturbed `COV_tau` | Simulated lagged covariance generated by the perturbed model |
| Inception EC | EC fitted by the second unperturbed model using perturbed FC and perturbed `COV_tau` as inputs |
| Inception FC | Simulated FC generated by the Inception model |
| Inception `COV_tau` | Simulated lagged covariance generated by the Inception model |