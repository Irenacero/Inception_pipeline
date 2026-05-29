function model = simulate_hopf_observables(Ceff, f_diff, sigma_vec, cfg)
%SIMULATE_HOPF_OBSERVABLES Simulate FC, COV and COV_tau from EC.

    [FCsim, COVsim, COVsimtotal, A] = hopf_linear(Ceff, f_diff, sigma_vec, cfg);

    if isempty(FCsim)
        model = struct('Ceff', Ceff, 'FCsim', [], 'COVsim', [], ...
                       'COVsimtotal', [], 'COVtausim', [], 'A', []);
        return
    end

    COVtausim = compute_model_covtau(A, COVsimtotal, COVsim, cfg);

    model = struct();
    model.Ceff = Ceff;
    model.FCsim = FCsim;
    model.COVsim = COVsim;
    model.COVsimtotal = COVsimtotal;
    model.COVtausim = COVtausim;
    model.A = A;
end
