function C0 = load_structural_connectivity(cfg)
%LOAD_STRUCTURAL_CONNECTIVITY Load and normalize structural connectivity.
%
% Preferred variable name inside SC.mat: C. If C is not present, the first
% square numeric matrix is used.

    if ~exist(cfg.files.sc, 'file')
        error('SC file not found: %s', cfg.files.sc);
    end

    S = load(cfg.files.sc);

    if isfield(S, 'C')
        C = S.C;
    else
        C = [];
        names = fieldnames(S);
        for i = 1:numel(names)
            candidate = S.(names{i});
            if isnumeric(candidate) && ismatrix(candidate) && ...
                    size(candidate, 1) == size(candidate, 2)
                C = candidate;
                warning('Variable C not found. Using %s as structural connectivity.', names{i});
                break;
            end
        end

        if isempty(C)
            error('No square numeric connectivity matrix found in %s.', cfg.files.sc);
        end
    end

    C0 = C(cfg.indexN, cfg.indexN);
    C0 = normalize_connectivity(C0, cfg.hopf.maxC);
end
