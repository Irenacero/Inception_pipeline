function ts = get_subject_timeseries(data, group_name, subject_idx)
%GET_SUBJECT_TIMESERIES Return raw timeseries for one subject.

    group_ts = data.ts.(group_name);

    if iscell(group_ts)
        ts = group_ts{1, subject_idx};
    else
        ts = group_ts(:, :, subject_idx);
    end
end
