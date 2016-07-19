function [dim_idx_list] = CTHMM_MD_query_dim_index_list_from_data(data_value)

global data_setting;

dim = size(data_value, 2);
dim_idx_list = zeros(1, dim);

for d = 1:dim
    
    num_range = size(data_setting.dim_value_range_ls{d}, 2);
    
    for r = 1:(num_range-1)
    
        r1 = data_setting.dim_value_range_ls{d}(r);
        r2 = data_setting.dim_value_range_ls{d}(r+1);

        if (r1 < r2)            
            if ((data_value(d) >= r1 && data_value(d) < r2) || ((r+1) == num_range && data_value(d) == r2))
                dim_idx_list(d) = r;
                break;
            end           
        else
            if ((data_value(d) <= r1 && data_value(d) > r2) || ((r+1) == num_range && data_value(d) == r2))
                dim_idx_list(d) = r;
                break;
            end            
        end
        
    end % r
    
    if (dim_idx_list(d) == 0)
       str = sprintf('value %f is not in the defined data range\n', data_value(d))
       dim_idx_list = 0;
       return;
    end
    
end % d 