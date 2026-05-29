function update_mask = make_update_mask(C0, cfg)
%MAKE_UPDATE_MASK Matrix entries allowed to be updated during EC fitting.
%
% The original scripts updated entries where C(i,j)>0 or j == N-i+1.
% This function keeps that rule explicit and configurable.

    update_mask = C0 > 0;

    if isfield(cfg.fit, 'allow_antidiagonal_updates') && cfg.fit.allow_antidiagonal_updates
        N = size(C0, 1);
        anti_diag = false(N);
        for i = 1:N
            anti_diag(i, N - i + 1) = true;
        end
        update_mask = update_mask | anti_diag;
    end
end
