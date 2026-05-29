function [model, fit] = fit_hopf_ec(targetFC, targetCOVtau, C0, f_diff, sigma_vec, cfg)
%FIT_HOPF_EC Fit effective connectivity to target FC and target COV_tau.
%
% This function is the core repeated block from the original scripts.
% It is used for:
%   1. individual models fitted to empirical FC/COV_tau
%   2. perturbed models fitted to empirical FC/COV_tau with node-wise sigma
%   3. Inception models fitted to perturbed FC/COV_tau without perturbation

    Cnew = C0;
    update_mask = make_update_mask(C0, cfg);
    olderror = Inf;

    fit = struct();
    fit.errorFC = nan(1, cfg.fit.max_iter);
    fit.errorCOVtau = nan(1, cfg.fit.max_iter);
    fit.totalError = nan(1, cfg.fit.max_iter);
    fit.iterations = cfg.fit.max_iter;
    fit.stopping_reason = 'max_iter';

    for iter = 1:cfg.fit.max_iter
        model_iter = simulate_hopf_observables(Cnew, f_diff, sigma_vec, cfg);

        if isempty(model_iter.FCsim)
            fit.iterations = iter;
            fit.stopping_reason = 'unstable_origin';
            fit.errorFC = fit.errorFC(1:iter);
            fit.errorCOVtau = fit.errorCOVtau(1:iter);
            fit.totalError = fit.totalError(1:iter);
            model = model_iter;
            return
        end

        errorFC = mean((targetFC(:) - model_iter.FCsim(:)).^2);
        errorCOVtau = mean((targetCOVtau(:) - model_iter.COVtausim(:)).^2);
        errornow = errorFC + errorCOVtau;

        fit.errorFC(iter) = errorFC;
        fit.errorCOVtau(iter) = errorCOVtau;
        fit.totalError(iter) = errornow;

        if mod(iter, cfg.fit.check_every) == 0
            relative_improvement = (olderror - errornow) / errornow;

            if relative_improvement < cfg.fit.relative_improvement_tol
                fit.iterations = iter;
                fit.stopping_reason = 'small_relative_improvement';
                break
            end

            if cfg.fit.stop_if_error_increases && olderror < errornow
                fit.iterations = iter;
                fit.stopping_reason = 'error_increased';
                break
            end

            olderror = errornow;
        end

        delta = cfg.fit.epsFC * (targetFC - model_iter.FCsim) + ...
                cfg.fit.epsCOVtau * (targetCOVtau - model_iter.COVtausim);

        Cnew(update_mask) = Cnew(update_mask) + delta(update_mask);
        Cnew(Cnew < 0) = 0;
        Cnew = normalize_connectivity(Cnew, cfg.hopf.maxC);
    end

    fit.errorFC = fit.errorFC(1:fit.iterations);
    fit.errorCOVtau = fit.errorCOVtau(1:fit.iterations);
    fit.totalError = fit.totalError(1:fit.iterations);

    model = simulate_hopf_observables(Cnew, f_diff, sigma_vec, cfg);
end
