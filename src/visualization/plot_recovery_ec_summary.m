function plot_recovery_ec_summary(outputs, cfg)
%PLOT_RECOVERY_EC_SUMMARY
% Creates one summary figure similar to the paper:
% top panel = MCS
% bottom panel = UWS
% groups shown = HC, patient baseline, recovery (R)
% metric = normalized Frobenius distance to target EC

    fig = figure('Color','w','Position',[100 100 520 760]);
    tl = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

    hc_color  = [0.91 0.84 0.40];
    mcs_color = [0.67 0.84 0.93];
    uws_color = [0.94 0.72 0.64];
    rec_color = [0.34 0.72 0.38];

    % Distances for HC subjects
    hc_dist = get_individual_ec_distances(outputs.individual_models.(cfg.groups.control), ...
                                          outputs.target, cfg);

    patient_groups = cfg.groups.patients;

    for g = 1:numel(patient_groups)
        group_name = patient_groups{g};

        % Baseline patient distances
        patient_dist = get_individual_ec_distances(outputs.individual_models.(group_name), ...
                                                   outputs.target, cfg);

        % Recovery distances = best Inception EC distance per subject
        recovery_dist = get_best_recovery_distances(outputs.inception_table, group_name);

        nexttile;
        hold on;

        if strcmp(group_name, 'MCS24')
            patient_color = mcs_color;
            patient_label = 'MCS';
        else
            patient_color = uws_color;
            patient_label = 'UWS';
        end

        plot_violin_with_points(1, hc_dist, hc_color);
        plot_violin_with_points(2, patient_dist, patient_color);
        plot_violin_with_points(3, recovery_dist, rec_color);

        xlim([0.4 3.6]);
        xticks([1 2 3]);
        xticklabels({'HC', patient_label, 'R'});

        ylabel(patient_label, 'FontWeight', 'bold');
        box off;
        set(gca, 'FontSize', 11, 'LineWidth', 1);

        if g == 1
            title({'Frobenius norm', 'with target EC'}, ...
                  'FontWeight', 'bold', 'FontSize', 14);
        end

        % y-limits with some headroom for significance bars
        y_all = [hc_dist(:); patient_dist(:); recovery_dist(:)];
        y_all = y_all(~isnan(y_all));

        if isempty(y_all)
            ylim([0 1]);
        else
            y_min = min(y_all);
            y_max = max(y_all);
            if y_min == y_max
                y_max = y_max + 0.01;
            end
            pad = 0.22 * (y_max - y_min);
            ylim([max(0, y_min - 0.05*(y_max-y_min)), y_max + pad]);
        end

        % Statistics (optional but similar to your example)
        % HC vs patient: independent
        p12 = ranksum(hc_dist, patient_dist);

        % HC vs recovery: independent
        p13 = ranksum(hc_dist, recovery_dist);

        % patient vs recovery: paired, same subjects
        if numel(patient_dist) == numel(recovery_dist)
            p23 = signrank(patient_dist, recovery_dist);
        else
            p23 = ranksum(patient_dist, recovery_dist);
        end

        y_top = ylim;
        yr = y_top(2) - y_top(1);
        base_y = y_top(2) - 0.16*yr;
        step_y = 0.08*yr;

        add_sig_bar(1, 2, base_y,           p12);
        add_sig_bar(2, 3, base_y,           p23);
        add_sig_bar(1, 3, base_y + step_y,  p13);

        hold off;
    end

    % Save
    if cfg.plot.save_png
        saveas(fig, fullfile(cfg.results_dir, [cfg.plot.filename '.png']));
    end
    if cfg.plot.save_fig
        savefig(fig, fullfile(cfg.results_dir, [cfg.plot.filename '.fig']));
    end
end


function d = get_individual_ec_distances(group_models, target, cfg)
    n = numel(group_models);
    d = nan(n,1);
    for i = 1:n
        if isempty(group_models(i).model) || isempty(group_models(i).model.Ceff)
            continue
        end
        d(i) = matrix_distance(group_models(i).model.Ceff, target.EC, cfg);
    end
end


function d = get_best_recovery_distances(tbl, group_name)
    if isempty(tbl)
        d = [];
        return
    end

    rows = strcmp(tbl.group, group_name);
    T = tbl(rows,:);

    subs = unique(T.subject);
    d = nan(numel(subs),1);

    for i = 1:numel(subs)
        s = subs(i);
        idx = T.subject == s;
        vals = T.inception_distance_EC(idx);
        d(i) = min(vals, [], 'omitnan');
    end
end


function plot_violin_with_points(xpos, y, face_color)
    y = y(~isnan(y));

    if isempty(y)
        return
    end

    % Violin
    [f, yi] = ksdensity(y, 'NumPoints', 120);
    if max(f) > 0
        f = f ./ max(f);
    end
    width = 0.22 * f;

    patch([xpos + width, fliplr(xpos - width)], ...
          [yi,           fliplr(yi)], ...
          face_color, ...
          'FaceAlpha', 0.35, ...
          'EdgeColor', face_color, ...
          'LineWidth', 1.2);

    % Points
    jitter = (rand(size(y)) - 0.5) * 0.16;
    scatter(xpos + jitter, y, 18, ...
        'MarkerFaceColor', face_color, ...
        'MarkerEdgeColor', 'none');

    % Median + IQR
    med = median(y);
    q1 = prctile(y,25);
    q3 = prctile(y,75);

    plot([xpos xpos], [q1 q3], 'Color', [0.35 0.35 0.35], 'LineWidth', 2);
    plot(xpos, med, 'o', ...
        'MarkerFaceColor', 'w', ...
        'MarkerEdgeColor', [0.35 0.35 0.35], ...
        'MarkerSize', 4);
end


function add_sig_bar(x1, x2, y, p)
    h = 0.003;
    plot([x1 x1 x2 x2], [y-h y y y-h], 'k', 'LineWidth', 1);
    text(mean([x1 x2]), y + h*0.8, p_to_stars(p), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 10);
end


function txt = p_to_stars(p)
    if isnan(p)
        txt = 'n.a.';
    elseif p < 0.001
        txt = '***';
    elseif p < 0.01
        txt = '**';
    elseif p < 0.05
        txt = '*';
    else
        txt = 'n.s.';
    end
end
