function make_output_dirs(cfg)
%MAKE_OUTPUT_DIRS Create output folders if they do not exist.

    folders = {cfg.output_dir, cfg.results_dir, fullfile(cfg.output_dir, 'Figures')};
    for i = 1:numel(folders)
        if ~exist(folders{i}, 'dir')
            mkdir(folders{i});
        end
    end
end
