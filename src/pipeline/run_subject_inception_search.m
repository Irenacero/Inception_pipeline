function result = run_subject_inception_search(data, C0, freq, target, cfg, group_name, subject_idx)
%RUN_SUBJECT_INCEPTION_SEARCH Run node x sigma search for one subject.
%
% For each node and perturbation sigma:
%   A. Fit perturbed Hopf model to empirical FC/COV_tau using node-wise sigma.
%   B. Fit final/Inception unperturbed Hopf model to the perturbed FC/COV_tau.
%   C. Save only distances to the target state by default.

    ts = get_subject_timeseries(data, group_name, subject_idx);
    signal_filt = preprocess_timeseries(ts, cfg);
    empirical = compute_empirical_observables(signal_filt, cfg);
    f_diff = get_frequency_vector(freq, cfg, group_name, subject_idx);

    base_sigma_vec = make_sigma_vector(cfg, [], []);
    nodes = cfg.perturbation.nodes;
    sigma_values = cfg.perturbation.values;

    n_rows = numel(nodes) * numel(sigma_values);
    row = 0;

    group_col = cell(n_rows, 1);
    subject_col = nan(n_rows, 1);
    node_col = nan(n_rows, 1);
    sigma_col = nan(n_rows, 1);

    pert_EC = nan(n_rows, 1);
    pert_FC = nan(n_rows, 1);
    pert_COVtau = nan(n_rows, 1);
    inc_EC = nan(n_rows, 1);
    inc_FC = nan(n_rows, 1);
    inc_COVtau = nan(n_rows, 1);

    pert_iter = nan(n_rows, 1);
    inc_iter = nan(n_rows, 1);
    pert_final_error = nan(n_rows, 1);
    inc_final_error = nan(n_rows, 1);
    pert_stop = cell(n_rows, 1);
    inc_stop = cell(n_rows, 1);

    best = struct();
    best.distance_EC = Inf;
    best.node = NaN;
    best.sigma = NaN;
    best.perturbed_model = [];
    best.inception_model = [];

    all_matrices = cell(numel(sigma_values), numel(nodes));

    for p_idx = 1:numel(sigma_values)
        sigma_value = sigma_values(p_idx);

        for n_idx = 1:numel(nodes)
            node = nodes(n_idx);
            row = row + 1;

            if cfg.fit.verbose
                fprintf('  Node %d, sigma %.4f (%d/%d)\n', node, sigma_value, row, n_rows);
            end

            group_col{row} = group_name;
            subject_col(row) = subject_idx;
            node_col(row) = node;
            sigma_col(row) = sigma_value;

            pert_sigma_vec = make_sigma_vector(cfg, node, sigma_value);
            [perturbed_model, perturbed_fit] = fit_hopf_ec(empirical.FC, empirical.COVtau, ...
                C0, f_diff, pert_sigma_vec, cfg);

            pert_iter(row) = perturbed_fit.iterations;
            pert_stop{row} = perturbed_fit.stopping_reason;
            pert_final_error(row) = last_total_error(perturbed_fit);

            if isempty(perturbed_model.FCsim)
                inc_stop{row} = 'not_run_perturbed_model_empty';
                continue
            end

            pert_distances = compute_matrix_distances(perturbed_model, target, cfg);
            pert_EC(row) = pert_distances.EC;
            pert_FC(row) = pert_distances.FC;
            pert_COVtau(row) = pert_distances.COVtau;

            [inception_model, inception_fit] = fit_hopf_ec(perturbed_model.FCsim, ...
                perturbed_model.COVtausim, C0, f_diff, base_sigma_vec, cfg);

            inc_iter(row) = inception_fit.iterations;
            inc_stop{row} = inception_fit.stopping_reason;
            inc_final_error(row) = last_total_error(inception_fit);

            if isempty(inception_model.FCsim)
                continue
            end

            inc_distances = compute_matrix_distances(inception_model, target, cfg);
            inc_EC(row) = inc_distances.EC;
            inc_FC(row) = inc_distances.FC;
            inc_COVtau(row) = inc_distances.COVtau;

            if cfg.storage.save_all_matrices
                all_matrices{p_idx, n_idx} = struct('perturbed', perturbed_model, ...
                    'inception', inception_model, 'node', node, 'sigma', sigma_value);
            end

            if inc_distances.EC < best.distance_EC
                best.distance_EC = inc_distances.EC;
                best.node = node;
                best.sigma = sigma_value;
                if cfg.storage.save_best_matrices
                    best.perturbed_model = perturbed_model;
                    best.inception_model = inception_model;
                end
            end
        end
    end

    result_table = table(group_col, subject_col, node_col, sigma_col, ...
        pert_EC, pert_FC, pert_COVtau, inc_EC, inc_FC, inc_COVtau, ...
        pert_iter, inc_iter, pert_final_error, inc_final_error, pert_stop, inc_stop, ...
        'VariableNames', {'group', 'subject', 'node', 'sigma', ...
        'perturbed_distance_EC', 'perturbed_distance_FC', 'perturbed_distance_COVtau', ...
        'inception_distance_EC', 'inception_distance_FC', 'inception_distance_COVtau', ...
        'perturbed_iterations', 'inception_iterations', ...
        'perturbed_final_error', 'inception_final_error', ...
        'perturbed_stop', 'inception_stop'});

    summary = struct();
    summary.group = group_name;
    summary.subject = subject_idx;
    summary.best_node_by_inception_EC = best.node;
    summary.best_sigma_by_inception_EC = best.sigma;
    summary.best_distance_inception_EC = best.distance_EC;

    result = struct();
    result.table = result_table;
    result.summary = summary;
    result.best = best;
    result.empirical = empirical;

    if cfg.storage.save_all_matrices
        result.all_matrices = all_matrices;
    end
end
