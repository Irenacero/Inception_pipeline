function outputs = run_inception_pipeline(cfg)
%RUN_INCEPTION_PIPELINE Run the full cleaned Inception workflow.
%
% The workflow is:
%   1. Load data and SC.
%   2. Compute empirical dominant frequencies.
%   3. Fit individual unperturbed models for all groups.
%   4. Build the target state from the control group.
%   5. For each patient subject, search node x sigma perturbations.
%   6. Save lightweight distance tables and optional best matrices.

    rng(cfg.random_seed);
    make_output_dirs(cfg);

    fprintf('\n=== Loading data ===\n');
    data = load_inception_data(cfg);
    C0 = load_structural_connectivity(cfg);

    fprintf('\n=== Computing empirical frequencies ===\n');
    freq = compute_empirical_frequencies(data, cfg);

    fprintf('\n=== Stage 1: fitting individual unperturbed models ===\n');
    individual_models = struct();
    for g = 1:numel(cfg.groups.names)
        group_name = cfg.groups.names{g};
        individual_models.(group_name) = fit_group_individual_models(data, C0, freq, cfg, group_name);
    end

    fprintf('\n=== Building target state from control group: %s ===\n', cfg.groups.control);
    target = compute_target_state(individual_models.(cfg.groups.control), cfg.groups.control);
    save(fullfile(cfg.results_dir, 'target_state.mat'), 'target', cfg.storage.save_version);

    fprintf('\n=== Stages 2-3: perturbation search and Inception final model ===\n');
    patient_results = struct();
    all_tables = {};

    for g = 1:numel(cfg.groups.patients)
        group_name = cfg.groups.patients{g};
        n_subjects = get_n_subjects(data, cfg, group_name);
        patient_results.(group_name) = cell(1, n_subjects);

        for sub = 1:n_subjects
            fprintf('\n--- %s subject %d/%d ---\n', group_name, sub, n_subjects);
            result = run_subject_inception_search(data, C0, freq, target, cfg, group_name, sub);
            patient_results.(group_name){sub} = result.summary;
            all_tables{end+1} = result.table; %#ok<AGROW>

            if cfg.storage.save_subject_tables
                subject_file = sprintf('%s_subject_%03d_inception_search.mat', group_name, sub);
                save(fullfile(cfg.results_dir, subject_file), 'result', cfg.storage.save_version);
            end
        end
    end

    if ~isempty(all_tables)
        inception_table = vertcat(all_tables{:});
        save(fullfile(cfg.results_dir, 'inception_similarity_table.mat'), ...
             'inception_table', 'patient_results', cfg.storage.save_version);
        try
            writetable(inception_table, fullfile(cfg.results_dir, 'inception_similarity_table.csv'));
        catch ME
            warning('Could not write CSV table: %s', ME.message);
        end
    else
        inception_table = table();
    end

    outputs = struct();
    outputs.individual_models = individual_models;
    outputs.target = target;
    outputs.patient_results = patient_results;
    outputs.inception_table = inception_table;

    save(fullfile(cfg.results_dir, 'inception_pipeline_outputs.mat'), ...
         'outputs', cfg.storage.save_version);

    fprintf('\nPipeline finished. Results saved in:\n%s\n', cfg.results_dir);
end
