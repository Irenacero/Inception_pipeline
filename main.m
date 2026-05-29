%% Inception MATLAB pipeline
clear; clc;

project_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(project_dir, 'config'));

cfg = get_config();
addpath(genpath(fullfile(cfg.project_dir, 'src')));

make_output_dirs(cfg);

outputs = run_inception_pipeline(cfg);

if cfg.plot.make_final_figure
    plot_recovery_ec_summary(outputs, cfg);
end
