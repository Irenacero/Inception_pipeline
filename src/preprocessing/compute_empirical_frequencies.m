function freq = compute_empirical_frequencies(data, cfg)
%COMPUTE_EMPIRICAL_FREQUENCIES Estimate dominant frequency per node and subject.
%
% This replaces the original script empirical_freq.m with a reusable
% function. It also saves empirical_<GROUP>.mat files for compatibility.

    freq_file = fullfile(cfg.results_dir, 'empirical_frequencies_all_groups.mat');
    if ~cfg.frequency.recompute && exist(freq_file, 'file')
        loaded = load(freq_file, 'freq');
        freq = loaded.freq;
        return
    end

    freq = struct();
    freq.sub = struct();
    freq.group_mean = struct();

    for g = 1:numel(cfg.groups.names)
        group_name = cfg.groups.names{g};
        n_subjects = get_n_subjects(data, cfg, group_name);
        f_diff_sub = zeros(n_subjects, cfg.N);

        fprintf('Computing empirical frequencies: %s\n', group_name);

        for sub = 1:n_subjects
            fprintf('  Subject %d/%d\n', sub, n_subjects);
            ts = get_subject_timeseries(data, group_name, sub);
            signal_filt = preprocess_timeseries(ts, cfg);
            f_diff_sub(sub, :) = compute_subject_frequencies(signal_filt, cfg);
        end

        freq.sub.(group_name) = f_diff_sub;
        freq.group_mean.(group_name) = mean(f_diff_sub, 1);

        f_diff = freq.group_mean.(group_name); %#ok<NASGU>
        save(fullfile(cfg.results_dir, sprintf('empirical_%s.mat', group_name)), ...
             'f_diff', 'f_diff_sub');
    end

    save(freq_file, 'freq', cfg.storage.save_version);
end
