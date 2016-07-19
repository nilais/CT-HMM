function [obs_value, next_state_idx, num_t1_search, num_t2_search] = func_CTHMM_predict_obs(subject_data, cur_visit_idx, future_t, search_t_stop_delta, max_search_t_r_bound, data_range)

global data_setting;
global state_list;
global Q_mat;
global Nij_mat;

cur_state_idx = subject_data.ori_state_seq(cur_visit_idx);
num_dim = data_setting.dim;

%% find the next state
Pt = expm(Q_mat * future_t);
temp = Pt(cur_state_idx, :);
[C, n] = max(temp);
next_state_idx = n; %% or I should find all states that have the highest probability
next_s_dims = state_list{next_state_idx}.dim_states;
next_s_dim_value_range = zeros(num_dim, 2);
for d = 1:num_dim
    idx = next_s_dims(d);
    next_s_dim_value_range(d, :) = [data_setting.dim_value_range_ls{d}(idx) data_setting.dim_value_range_ls{d}(idx+1)];   
end

% for each dimension, search time t1 and t2 when enters a state that has same low and high data bound as
% the next_state for each dim
obs_value = zeros(num_dim, 1);
for d = 1:num_dim   
    
    %% time already in a state with same data range
    time_already_in_same_range = 0;
    start_v = -1;    
    for v = (cur_visit_idx):(-1):1        
        s = subject_data.ori_state_seq(v);        
        test_dims = state_list{s}.dim_states;        
        if (test_dims(d) == next_s_dims(d))
            if (v ~= cur_visit_idx)
                dur = subject_data.visit_list{v+1}.time - subject_data.visit_list{v}.time;
            else
                dur = 0.0;
            end
            time_already_in_same_range = time_already_in_same_range + dur;          
            start_v = v;
        else
            break;
        end
    end
    
    %% search for t1, s1 (time enter) : binary search
    search_t_l_bound = 0;
    search_t_r_bound = future_t;
    s1 = next_state_idx;
    t1 = search_t_l_bound;
    search_t = search_t_l_bound;

    num_t1_search = 0;
    while (1)
        
        num_t1_search = num_t1_search + 1;
        
        Pt = expm(Q_mat * search_t);
        temp = Pt(cur_state_idx, :);
        [C, n] = max(temp);        
        test_dims = state_list{n}.dim_states;
        
        if (test_dims(d) >= next_s_dims(d))            
            %shorten the right bound
            search_t_r_bound = search_t;           
        elseif (test_dims(d) < next_s_dims(d))
            %extend the left bound
            search_t_l_bound = search_t;       
        end
        
        %% update search_t based on two bounds
        search_t = (search_t_l_bound + search_t_r_bound) * 0.5;        
        if (abs(search_t - search_t_l_bound) <= search_t_stop_delta)
            s1 = n;
            t1 = search_t;
            break;
        end
                
    end

    %% search for t2, s2 (time leave)
    search_t_l_bound = future_t + search_t_stop_delta;
    search_t_r_bound =  future_t + max_search_t_r_bound;  

    t2 = search_t_r_bound;
    search_t = search_t_l_bound;
    s2_is_endstate = 0;
    num_t2_search = 0;
    
    while (1)
        
        num_t2_search = num_t2_search + 1;
        
        Pt = expm(Q_mat * search_t);
        temp = Pt(cur_state_idx, :);
        [C, n] = max(temp);        
        test_dims = state_list{n}.dim_states;        
        if (test_dims(d) > next_s_dims(d)) %% leave
           % shorten the right bound
           search_t_r_bound = search_t;           
        elseif (test_dims(d) <= next_s_dims(d)) 
            %% find the number of outgoing neighbors
            nb = find(Nij_mat(n, :) > 0);
            num_nb = size(nb, 2); %%
            if (num_nb == 0) % enter an end state
                s2_is_endstate = 1;
                break;
            end            
            %% extend the left bound
            search_t_l_bound = search_t;       
        end        
        %% update search_t based on two bounds
        search_t = (search_t_l_bound + search_t_r_bound) * 0.5;
        
        if (abs(search_t - search_t_l_bound) <= search_t_stop_delta)
            s2 = n;
            t2 = search_t;
            break;
        end
        
    end
    
    
    %% compute slope
    if (start_v ~= -1)
        t1 = t1 - time_already_in_same_range;
    end

    %% begin interpolate the observation values given the estimated enter and leave time for the data range
    upper_bound = next_s_dim_value_range(d, 1); % state upperbound
    low_bound = next_s_dim_value_range(d, 2);
    
    if (s2_is_endstate == 1) % just take the median of the state range ?
        obs_value(d) = (upper_bound + low_bound) / 2.0;
    else % linear interpolation using t1, t2 and the data bound
        slope = (low_bound - upper_bound) / (t2 - t1);
        obs_value(d) = upper_bound + slope * (future_t - t1);
    end
    
    %% bound the obs value in the valid range
    if (obs_value(d) < data_range(d, 1))
        obs_value(d) = data_range(d, 1);
    elseif (obs_value(d) > data_range(d, 2))
        obs_value(d) = data_range(d, 2);
    end
    
end

str = sprintf('Num of t1 search = %d, num of t2 search = %d\n', num_t1_search, num_t2_search);
CTHMM_print_log(str);

        
        
