function CTHMM_MD_create_state_list(train_idx_list, state_sigma)

global state_list;
global data_setting;
global num_state;
global is_add_state_straight_path;

%% observation sequence list
global obs_seq_list;

%% set up state number in each dimension 
dim = data_setting.dim; 
data_setting.dim_state_num_ls = zeros(1, dim);
for i = 1:dim
    data_setting.dim_state_num_ls(i) = size(data_setting.dim_value_range_ls{i}, 2) - 1;
end
%% begin create states: linearize the state list
max_num_of_state = 1;
for d = 1:dim
    max_num_of_state = max_num_of_state *  data_setting.dim_state_num_ls(d);
end
state_list = cell(max_num_of_state, 1);
num_state = 0;

num_train_seq = size(train_idx_list, 1);

for i = 1:num_train_seq
    
    s = train_idx_list(i);
    
    num_visit = obs_seq_list{s}.num_visit;
    
    if (num_visit == 1)    
        data1 = obs_seq_list{s}.visit_list{1}.data;
        dim_idx_list1 = CTHMM_MD_query_dim_index_list_from_data(data1);  
        if (dim_idx_list1(1) ~= 0)
            state_idx = CTHMM_MD_check_and_add_a_new_state(dim_idx_list1, state_sigma);
            state_list{state_idx}.raw_data_count = state_list{state_idx}.raw_data_count + 1;    
        end
        continue;
    end
    
    for v = 1:(num_visit-1)
   
        data1 = obs_seq_list{s}.visit_list{v}.data;
        data2 = obs_seq_list{s}.visit_list{v+1}.data;

        dim_idx_list1 = CTHMM_MD_query_dim_index_list_from_data(data1);  
        if (dim_idx_list1(1) ~= 0)
            state_idx = CTHMM_MD_check_and_add_a_new_state(dim_idx_list1, state_sigma);
            state_list{state_idx}.raw_data_count = state_list{state_idx}.raw_data_count + 1;    
        end
        
        dim_idx_list2 = CTHMM_MD_query_dim_index_list_from_data(data2);
        if (dim_idx_list2(1) ~= 0)        
            state_idx = CTHMM_MD_check_and_add_a_new_state(dim_idx_list2, state_sigma);        
            state_list{state_idx}.raw_data_count = state_list{state_idx}.raw_data_count + 1;    
        end        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% add states which are in the straight path in between the two states
        if (is_add_state_straight_path == 1)
            dim_diff = dim_idx_list2 - dim_idx_list1;
            max_step = max(abs(dim_diff(:)));
            move_step = double(dim_diff) ./ double(max_step);

            for step = 1:max_step
                mid_dim_state = dim_idx_list1 + round(move_step .* step);
                for d = 1:dim
                    if (move_step(d) > 0 && mid_dim_state(d) > dim_idx_list2(d))
                        mid_dim_state(d) = dim_idx_list2(d);
                    end
                    if (move_step(d) < 0 && mid_dim_state(d) < dim_idx_list2(d))
                        mid_dim_state(d) = dim_idx_list2(d);
                    end
                end            
                CTHMM_MD_check_and_add_a_new_state(mid_dim_state, state_sigma);
            end % step            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    end % v
end % s

state_list = state_list(1:num_state);

str = sprintf('Total number of states = %d\n', num_state);
CTHMM_print_log(str);
