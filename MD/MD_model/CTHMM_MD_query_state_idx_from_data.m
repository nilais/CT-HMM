function state_idx = CTHMM_MD_query_state_idx_from_data(data_value)

% application dependent
dim_idx_list = CTHMM_MD_query_dim_index_list_from_data(data_value);
state_idx = CTHMM_MD_query_state_idx_from_dim_idx(dim_idx_list);