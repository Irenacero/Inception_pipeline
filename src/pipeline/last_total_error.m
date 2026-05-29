function value = last_total_error(fit)
%LAST_TOTAL_ERROR Return final total fitting error from a fit structure.

    if isfield(fit, 'totalError') && ~isempty(fit.totalError)
        value = fit.totalError(end);
    else
        value = NaN;
    end
end
