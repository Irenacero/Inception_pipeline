function data = load_inception_data(cfg)
%LOAD_INCEPTION_DATA Load timeseries organized by group.
%
% Expected variable names in the .mat file are configured in
% cfg.timeseries.variable_template, by default:
%   timeseries_<GROUP>_symm

    if ~exist(cfg.files.timeseries, 'file')
        error('Timeseries file not found: %s', cfg.files.timeseries);
    end

    S = load(cfg.files.timeseries);
    data = struct();
    data.ts = struct();

    for g = 1:numel(cfg.groups.names)
        group_name = cfg.groups.names{g};
        varname = sprintf(cfg.timeseries.variable_template, group_name);

        if ~isfield(S, varname)
            error('Variable %s not found in %s.', varname, cfg.files.timeseries);
        end

        data.ts.(group_name) = S.(varname);
    end
end
