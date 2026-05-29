function group_models = fit_group_individual_models(data, C0, freq, cfg, group_name)
%FIT_GROUP_INDIVIDUAL_MODELS Fit unperturbed individual models for one group.

    n_subjects = get_n_subjects(data, cfg, group_name);
    group_models = repmat(struct('group', group_name, 'subject', [], ...
        'model', [], 'fit', [], 'empirical', []), 1, n_subjects);

    sigma_vec = make_sigma_vector(cfg, [], []);

    for sub = 1:n_subjects
        fprintf('Fitting individual model: %s subject %d/%d\n', group_name, sub, n_subjects);
        [model, fit, empirical] = fit_subject_individual_model(data, C0, freq, cfg, group_name, sub, sigma_vec);

        group_models(sub).group = group_name;
        group_models(sub).subject = sub;
        group_models(sub).model = model;
        group_models(sub).fit = fit;
        group_models(sub).empirical = empirical;
    end

    if cfg.storage.save_individual_models
        filename = sprintf('%s_individual_models.mat', group_name);
        save(fullfile(cfg.results_dir, filename), 'group_models', cfg.storage.save_version);
    end
end
