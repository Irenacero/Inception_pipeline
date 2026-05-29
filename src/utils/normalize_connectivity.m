function Cnorm = normalize_connectivity(C, maxC)
%NORMALIZE_CONNECTIVITY Scale connectivity matrix to maximum value maxC.

    Cnorm = C;
    Cnorm(Cnorm < 0) = 0;

    max_value = max(Cnorm(:));
    if max_value > 0
        Cnorm = Cnorm ./ max_value .* maxC;
    end
end
