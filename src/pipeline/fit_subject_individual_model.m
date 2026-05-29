function [model, fit, empirical] = fit_subject_individual_model(data, C0, freq, cfg, group_name, subject_idx, sigma_vec)
%FIT_SUBJECT_INDIVIDUAL_MODEL Fit one unperturbed subject model.

    if nargin < 7 || isempty(sigma_vec)
        sigma_vec = make_sigma_vector(cfg, [], []);
    end

    ts = get_subject_timeseries(data, group_name, subject_idx);
    signal_filt = preprocess_timeseries(ts, cfg);
    empirical = compute_empirical_observables(signal_filt, cfg);
    f_diff = get_frequency_vector(freq, cfg, group_name, subject_idx);

    [model, fit] = fit_hopf_ec(empirical.FC, empirical.COVtau, C0, f_diff, sigma_vec, cfg);
end
