function [bfilt, afilt] = design_bandpass_filter(cfg)
%DESIGN_BANDPASS_FILTER Construct Butterworth bandpass filter.

    fnq = 1 / (2 * cfg.TR);
    Wn = [cfg.freq_low / fnq, cfg.freq_high / fnq];
    [bfilt, afilt] = butter(cfg.filter_order, Wn);
end
