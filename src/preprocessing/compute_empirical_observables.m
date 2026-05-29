function emp = compute_empirical_observables(signal_filt, cfg)
%COMPUTE_EMPIRICAL_OBSERVABLES Compute empirical FC, COV and COV_tau.

    emp = struct();
    emp.FC     = corrcoef(signal_filt');
    emp.COV    = cov(signal_filt');
    emp.COVtau = compute_empirical_covtau(signal_filt, emp.COV, cfg);
end
