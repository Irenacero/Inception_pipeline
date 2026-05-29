function n_subjects = get_n_subjects(data, cfg, group_name)
%GET_N_SUBJECTS Infer or read the number of subjects for a group.

    if isfield(cfg.groups, 'n_subjects') && isfield(cfg.groups.n_subjects, group_name)
        n_subjects = cfg.groups.n_subjects.(group_name);
        return
    end

    group_ts = data.ts.(group_name);
    if iscell(group_ts)
        n_subjects = size(group_ts, 2);
    else
        n_subjects = size(group_ts, 3);
    end
end
