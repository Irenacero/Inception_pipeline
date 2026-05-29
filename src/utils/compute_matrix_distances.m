function distances = compute_matrix_distances(model, target, cfg)
%COMPUTE_MATRIX_DISTANCES Compare model outputs against target state.

    distances = struct();
    distances.EC     = matrix_distance(model.Ceff,      target.EC,     cfg);
    distances.FC     = matrix_distance(model.FCsim,     target.FC,     cfg);
    distances.COVtau = matrix_distance(model.COVtausim, target.COVtau, cfg);
end
