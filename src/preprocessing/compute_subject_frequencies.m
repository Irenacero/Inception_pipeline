function f_diff = compute_subject_frequencies(signal_filt, cfg)
%COMPUTE_SUBJECT_FREQUENCIES Estimate peak frequency for each node.

    [~, T] = size(signal_filt);
    Ts = T * cfg.TR;
    frequency_axis = (0:T/2-1) / Ts;

    f_diff = zeros(1, cfg.N);
    for node = 1:cfg.N
        pw = abs(fft(zscore(signal_filt(node, :))));
        power_spectrum = pw(1:floor(T/2)).^2 / (T / cfg.TR);
        power_spectrum_smooth = gaussfilt(frequency_axis, power_spectrum, cfg.freq_smoothing_sigma);
        [~, idx] = max(power_spectrum_smooth);
        f_diff(node) = frequency_axis(idx);
    end
end
