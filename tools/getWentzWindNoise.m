function [NL_dB,freq] = getWentzWindNoise(sea_state, freq)
% get the wentz curve from tabulated data

table_data = [
        0	0	1	3	6
        20	25	35	50	60
        50	33	45	59	67
        100	40	50	63	71
        200	44	55	67	73
        300	45	58	68	74
        500	47	57	67	73
        1000	44	53	63	69
        10000	27	36	46	52
        100000	9	18	28	34
        ];


freq_table = table_data(2:end,1);
NL_table = table_data(1,2:end)';
sea_state_table = table_data(2:end,2:end)';

NL_dB = interp1(NL_table, sea_state_table, sea_state)';

NL_dB = interp1(log10(freq_table), NL_dB, log10(freq), 'linear', 'extrap');

freq = freq(:);
