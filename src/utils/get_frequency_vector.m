function f_diff = get_frequency_vector(freq, cfg, group_name, subject_idx)
%GET_FREQUENCY_VECTOR Return the frequency vector used by the Hopf model.

    switch lower(cfg.frequency.mode)
        case 'subject'
            f_diff = freq.sub.(group_name)(subject_idx, :);
        case 'group_mean'
            f_diff = freq.group_mean.(group_name);
        otherwise
            error('Unknown cfg.frequency.mode: %s', cfg.frequency.mode);
    end
end
