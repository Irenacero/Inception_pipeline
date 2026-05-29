%% Check Inception MATLAB project setup without running the full pipeline.

clear; clc;

project_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(project_dir, 'config'));
cfg = get_config();
addpath(genpath(fullfile(cfg.project_dir, 'src')));

fprintf('Project directory: %s\n', cfg.project_dir);
fprintf('Data directory:    %s\n', cfg.data_dir);
fprintf('Results directory: %s\n', cfg.results_dir);

make_output_dirs(cfg);

required_files = {cfg.files.sc, cfg.files.timeseries};
for i = 1:numel(required_files)
    if exist(required_files{i}, 'file')
        fprintf('[OK] Found %s\n', required_files{i});
    else
        fprintf('[MISSING] %s\n', required_files{i});
    end
end

fprintf('Checking required functions...\n');
required_functions = {'load_inception_data', 'load_structural_connectivity', ...
    'compute_empirical_frequencies', 'fit_hopf_ec', 'run_inception_pipeline'};
for i = 1:numel(required_functions)
    f = required_functions{i};
    if exist(f, 'file') == 2
        fprintf('[OK] %s\n', f);
    else
        fprintf('[MISSING] %s\n', f);
    end
end
