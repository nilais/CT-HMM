function [state_idx] = CTHMM_MD_check_and_add_a_new_state(dim_idx_list, state_sigma)
     
global data_setting;
global state_list;
global num_state;

dim = data_setting.dim;

state_idx = CTHMM_MD_query_state_idx_from_dim_idx(dim_idx_list);     
if (state_idx ~= 0) % we already have this state    
    return;
end

%% add a new state
[dim_range_list] = CTHMM_MD_query_dim_range_from_dim_idx(dim_idx_list);

state.mu = zeros(1, dim);
state.var = zeros(1, dim);

for d = 1:dim   
    state.mu(d) = (dim_range_list(d, 1) + dim_range_list(d, 2)) / 2.0;       
    state.var(d) = (abs(dim_range_list(d, 1) - dim_range_list(d, 2)) * state_sigma)^2;
end

num_state = num_state + 1;

state.idx = num_state;
state.dim_states = dim_idx_list;
state.range = dim_range_list;
state.raw_data_count = 0;

state_list{num_state} = state;
state_idx = state.idx;
