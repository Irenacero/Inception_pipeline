function signal_filt = preprocess_timeseries(ts, cfg)
%PREPROCESS_TIMESERIES Select nodes, detrend, bandpass filter and trim edges.

    ts = ts(cfg.indexN, :);
    [bfilt, afilt] = design_bandpass_filter(cfg);

    signal_filt = zeros(cfg.N, size(ts, 2));
    for node = 1:cfg.N
        x = ts(node, :);
        x = detrend(x - nanmean(x));
        signal_filt(node, :) = filtfilt(bfilt, afilt, x);
    end

    if cfg.edge_trim > 0
        signal_filt = signal_filt(:, (cfg.edge_trim + 1):(end - cfg.edge_trim));
    end
end
