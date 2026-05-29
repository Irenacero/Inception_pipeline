function [FC, COV, COVtotal, A] = hopf_linear(C, f_diff, sigma_vec, cfg)
%HOPF_LINEAR Linearized Stuart-Landau/Hopf whole-brain model.
%
% This generalizes the original hopf_int.m function. The original function
% used one scalar sigma for all nodes. Here, sigma_vec is node-wise, which
% implements individual_sigma perturbations without a separate perturbation
% function.

    N = size(C, 1);

    if isscalar(sigma_vec)
        sigma_vec = sigma_vec * ones(N, 1);
    else
        sigma_vec = sigma_vec(:);
    end

    if numel(sigma_vec) ~= N
        error('sigma_vec must be scalar or have one value per node.');
    end

    a_vec = cfg.hopf.a * ones(N, 1);
    omega = f_diff(:) * (2 * pi);

    s = sum(C, 2);
    B = diag(s);

    Axx = diag(a_vec) - B + C;
    Ayy = Axx;
    Axy = -diag(omega);
    Ayx =  diag(omega);

    A = [Axx, Axy; Ayx, Ayy];

    % Noise covariance for x and y components. For node-wise sigma, the
    % covariance is diagonal but not necessarily proportional to identity.
    Qn = diag([sigma_vec.^2; sigma_vec.^2]);

    % Check stability of the origin.
    eigenvalues = eig(A);
    if max(real(eigenvalues)) >= 0
        warning('The origin is not stable. Returning empty model outputs.');
        FC = []; COV = []; COVtotal = []; A = [];
        return
    end

    COVtotal = lyap(A, Qn);
    FCtotal = corrcov(COVtotal);

    FC  = FCtotal(1:N, 1:N);
    COV = COVtotal(1:N, 1:N);
end
