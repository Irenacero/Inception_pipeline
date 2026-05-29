function cfg = get_config()
%GET_CONFIG Central configuration for the Inception MATLAB pipeline.
%

    % -------------------------
    % Project paths
    % -------------------------
    cfg.project_dir = fileparts(fileparts(mfilename('fullpath')));
    cfg.data_dir    = fullfile(cfg.project_dir, 'Data');
    cfg.output_dir  = fullfile(cfg.project_dir, 'Output');
    cfg.results_dir = fullfile(cfg.output_dir, 'Results');

    cfg.files.sc         = fullfile(cfg.data_dir, 'SC.mat');
    cfg.files.timeseries = fullfile(cfg.data_dir, 'ts_coma24_AAL_symm.mat');

    % -------------------------
    % Dataset/group information
    % -------------------------
    cfg.groups.names    = {'CNT24', 'MCS24', 'UWS24'};
    cfg.groups.control  = 'CNT24';
    cfg.groups.patients = {'MCS24', 'UWS24'};

    % Optional. If a group is missing here, its subject count is inferred
    % from the timeseries file.
    cfg.groups.n_subjects = struct();
    cfg.groups.n_subjects.CNT24 = 13;
    cfg.groups.n_subjects.MCS24 = 11;
    cfg.groups.n_subjects.UWS24 = 10;

    % Expected variable name in the timeseries .mat file:
    %   timeseries_<GROUP>_symm
    cfg.timeseries.variable_template = 'timeseries_%s_symm';

    % -------------------------
    % Data/preprocessing parameters
    % -------------------------
    cfg.N      = 90;
    cfg.indexN = 1:cfg.N;

    cfg.TR           = 2.4;
    cfg.Tau          = 1;
    cfg.freq_low     = 0.008;
    cfg.freq_high    = 0.08;
    cfg.filter_order = 2;
    cfg.edge_trim    = 10;
    cfg.freq_smoothing_sigma = 0.005;

    % Use each subject's dominant frequency vector in all three stages.
    cfg.frequency.mode = 'subject';  % options: 'subject', 'group_mean'
    cfg.frequency.recompute = true;

    % -------------------------
    % Hopf model parameters
    % -------------------------
    cfg.hopf.a             = -0.02;
    cfg.hopf.sigma_default = 0.02;
    cfg.hopf.maxC          = 0.2;

    % -------------------------
    % Perturbation parameters
    % -------------------------
    cfg.perturbation.type   = 'individual_sigma';
    cfg.perturbation.values = 0:0.05:0.5;
    cfg.perturbation.nodes  = cfg.indexN;

    % -------------------------
    % EC fitting parameters
    % -------------------------
    cfg.fit.max_iter     = 5000;
    cfg.fit.epsFC        = 0.0004;
    cfg.fit.epsCOVtau    = 0.0001;
    cfg.fit.check_every  = 100;
    cfg.fit.relative_improvement_tol = 1e-4;
    cfg.fit.stop_if_error_increases  = true;
    cfg.fit.verbose = true;

    % Preserves the original update rule: update existing SC edges and the
    % anti-diagonal entries j == N-i+1.
    cfg.fit.allow_antidiagonal_updates = true;

    % -------------------------
    % Storage/output options
    % -------------------------
    cfg.storage.distance_metric        = 'frobenius_normalized';
    cfg.storage.save_individual_models = true;
    cfg.storage.save_subject_tables    = true;
    cfg.storage.save_all_matrices      = false;
    cfg.storage.save_best_matrices     = true;
    cfg.storage.save_version           = '-v7.3';
    
    % -------------------------
    % Plotting
    % -------------------------
    cfg.plot.make_final_figure = true;
    cfg.plot.filename = 'Figure_recovery_EC_summary';
    cfg.plot.save_png = true;
    cfg.plot.save_fig = true;

    cfg.random_seed = 1;
end
