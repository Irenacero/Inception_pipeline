function sigma_vec = make_sigma_vector(cfg, perturbed_node, perturbed_sigma)
%MAKE_SIGMA_VECTOR Build node-wise sigma vector.
%
% If perturbed_node is empty, all nodes use cfg.hopf.sigma_default.
% If perturbed_node is provided, only that node uses perturbed_sigma.

    sigma_vec = cfg.hopf.sigma_default * ones(cfg.N, 1);

    if nargin >= 2 && ~isempty(perturbed_node)
        sigma_vec(perturbed_node) = perturbed_sigma;
    end
end
