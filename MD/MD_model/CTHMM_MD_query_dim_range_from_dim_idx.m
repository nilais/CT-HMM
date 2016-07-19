function dim_range_list = CTHMM_MD_query_dim_range_from_dim_idx(dim_idx_list)

global data_setting;

num_dim = size(dim_idx_list, 2);
dim_range_list = zeros(num_dim, 2);

for d = 1:num_dim

    idx = dim_idx_list(d);
    
    if (data_setting.dim_value_range_ls{d}(idx+1) > data_setting.dim_value_range_ls{d}(idx))
        dim_range_list(d, :) = [data_setting.dim_value_range_ls{d}(idx) data_setting.dim_value_range_ls{d}(idx+1)];
    else        
        dim_range_list(d, :) = [data_setting.dim_value_range_ls{d}(idx+1) data_setting.dim_value_range_ls{d}(idx)];
    end    

end
    
    


