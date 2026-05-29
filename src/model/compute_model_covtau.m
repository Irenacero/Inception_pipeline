function COVtau = compute_model_covtau(A, COVtotal, COV0, cfg)
%COMPUTE_MODEL_COVTAU Lagged covariance from linearized Hopf model.

    N = cfg.N;
    COVtau_total = expm((cfg.Tau * cfg.TR) * A) * COVtotal;
    COVtau = COVtau_total(1:N, 1:N);
    COVtau = COVtau .* compute_sigma_ratio(COV0);
end
