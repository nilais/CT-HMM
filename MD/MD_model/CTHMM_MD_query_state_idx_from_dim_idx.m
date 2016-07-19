function state_idx = CTHMM_MD_query_state_idx_from_dim_idx(q_dim_state_idx)

global state_list;
global data_setting;
global num_state;

dim = data_setting.dim;
state_idx = 0;

for s = 1:num_state
    
    s_dim_state_idx = state_list{s}.dim_states;

    is_match = 1;
    for d = 1:dim       
        if (q_dim_state_idx(d) ~= s_dim_state_idx(d))       
            is_match = 0;
            break;
        end
    end
       
    if (is_match == 1)
        state_idx = s;
        break;
    end
    
end
