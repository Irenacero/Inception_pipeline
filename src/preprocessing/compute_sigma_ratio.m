function sigratio = compute_sigma_ratio(COV0)
%COMPUTE_SIGMA_RATIO Scaling factor used for lagged covariance normalization.

    diag_cov = diag(COV0);
    inv_std = 1 ./ sqrt(diag_cov(:));
    sigratio = inv_std * inv_std';
end
