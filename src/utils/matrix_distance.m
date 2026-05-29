function d = matrix_distance(A, B, cfg)
%MATRIX_DISTANCE Distance between two matrices.
%
% Default: normalized Frobenius distance, norm(A-B,'fro') / norm(B,'fro').

    if isempty(A) || isempty(B)
        d = NaN;
        return
    end

    switch lower(cfg.storage.distance_metric)
        case 'frobenius_normalized'
            denom = norm(B, 'fro');
            if denom == 0
                d = NaN;
            else
                d = norm(A - B, 'fro') / denom;
            end
        case 'frobenius'
            d = norm(A - B, 'fro');
        otherwise
            error('Unknown distance metric: %s', cfg.storage.distance_metric);
    end
end
