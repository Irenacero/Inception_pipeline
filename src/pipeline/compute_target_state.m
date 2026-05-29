function target = compute_target_state(control_models, control_group_name)
%COMPUTE_TARGET_STATE Average simulated control state.
%
% Target EC, FC and COV_tau are obtained by averaging the corresponding
% outputs of the individual control models.

    n_subjects = numel(control_models);

    EC_stack = [];
    FC_stack = [];
    COVtau_stack = [];

    for sub = 1:n_subjects
        model = control_models(sub).model;
        if isempty(model) || isempty(model.Ceff)
            warning('Skipping empty control model for subject %d.', sub);
            continue
        end

        EC_stack(:, :, end+1) = model.Ceff; %#ok<AGROW>
        FC_stack(:, :, end+1) = model.FCsim; %#ok<AGROW>
        COVtau_stack(:, :, end+1) = model.COVtausim; %#ok<AGROW>
    end

    if isempty(EC_stack)
        error('No valid control models available to compute target state.');
    end

    target = struct();
    target.group = control_group_name;
    target.EC = mean(EC_stack, 3);
    target.FC = mean(FC_stack, 3);
    target.COVtau = mean(COVtau_stack, 3);
    target.n_subjects = size(EC_stack, 3);
end
