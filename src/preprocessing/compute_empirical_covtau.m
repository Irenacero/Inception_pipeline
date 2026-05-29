function COVtau = compute_empirical_covtau(signal_filt, COV0, cfg)
%COMPUTE_EMPIRICAL_COVTAU Empirical lagged covariance normalized by zero-lag covariance.

    N = cfg.N;
    tst = signal_filt';
    COVtau = zeros(N);
    sigratio = compute_sigma_ratio(COV0);

    for i = 1:N
        for j = 1:N
            [clag, lags] = xcov(tst(:, i), tst(:, j), cfg.Tau);
            idx = find(lags == cfg.Tau, 1);
            COVtau(i, j) = clag(idx) / size(tst, 1);
        end
    end

    COVtau = COVtau .* sigratio;
end
