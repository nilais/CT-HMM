function CTHMM_sim_set_syn_data_config(syn_config_idx)

global syn_Q_mat;
global syn_data_settings;

%% find max qi
D = -diag(syn_Q_mat);
max_qi = max(D(:));
smallest_hold_time = 1.0 / max_qi;
% find min qi
min_qi = min(D(1:end-1));
largest_hold_time = 1.0 / min_qi;
str = sprintf('max_qi = %f, min_qi = %f, small_hold_t = %f, longest_hold_t = %f\n', max_qi, min_qi, smallest_hold_time, largest_hold_time);
CTHMM_print_log(str);

%% for each config, one can have several kinds of data settings to have greater flexibility in generating the synthetic dataset
%% but we use just one setting for each config in the basic experiments
num_setting = 1;
total_visit_list = zeros(num_setting, 1);
dur_list = zeros(num_setting, 1);
time_intv_list = cell(num_setting, 1);

%==================================================
if (syn_config_idx == 1) % for 5-state simulation   
    total_visit_list(1) = [10^5];
    time_intv_list{1} = smallest_hold_time * 0.5; % half of the smallest holding time as the data sampling rate
    dur_list(1) = largest_hold_time * 100;
elseif (syn_config_idx == 10) % for 100-state simulation
    total_visit_list(1) = [500000];
    %% 50 distinct time intervals around similar value
    num_intv = 50;    
    time_intv_list{1} = zeros(num_intv, 1);    
    for t = 1:num_intv
        step = t / double(num_intv);
        time_intv_list{1}(t) = smallest_hold_time * 0.5 - (smallest_hold_time* 0.5 * 0.1) * step; % generate sampling intervals all around (smallest_hold_time * 0.5)
    end        
    dur_list(1) = largest_hold_time * 10;    
end
%==================================================

syn_data_settings = set_syn_config(total_visit_list, time_intv_list, dur_list);

end

function [syn_data_settings] = set_syn_config(total_visit_list, time_intv_list, dur_list)
    num_config = size(total_visit_list, 1);
    syn_data_settings = cell(num_config, 1);    
    for c = 1:num_config        
        syn_data_settings{c}.num_total_visit = total_visit_list(c);
        syn_data_settings{c}.time_intv_list = time_intv_list{c};
        syn_data_settings{c}.obs_dur = dur_list(c);        
    end
end
