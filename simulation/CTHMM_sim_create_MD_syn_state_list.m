function  CTHMM_sim_create_MD_syn_state_list(dim, num_of_state_per_dim, state_sigma)

%% assign the state definition
global data_setting;
global state_list;
%global all_mus all_sigmas

NS = num_of_state_per_dim;
data_setting.dim = dim;
data_setting.dim_state_num_ls(1:dim) = NS;
data_setting.type_name_ls = cell(dim, 1);
data_setting.draw_origin_lefttop = 1;

for d = 1:dim
    data_setting.dim_value_range_ls{d} = [0:1:NS];
    str = sprintf('dim%d', d);
    data_setting.type_name_ls{d} = str;
end

%% start creating the state list (each state has a predefined mean and standard deviation)
num_state = 0;
state_list = cell(NS^dim, 1);

if (dim == 1)
    for i = 1:NS        
        num_state = num_state + 1;
        state.idx = num_state;
        state.dim_states = i;      
        state_list{num_state} = state;  
    end
elseif (dim == 2)
    for i = 1:NS
        for j = 1:NS
            num_state = num_state + 1;
            state.idx = num_state;
            state.dim_states = [i j];       
            state_list{num_state} = state;  
        end
    end
elseif (dim == 3)
    for i = 1:NS
        for j = 1:NS
            for k = 1:NS
                num_state = num_state + 1;
                state.idx = num_state;
                state.dim_states = [i j k];   
                state_list{num_state} = state;  
            end
        end
    end
end
    
%% fill out more info for each state
for i = 1:num_state
    state_list{i}.mu = zeros(1, dim);
    state_list{i}.var = zeros(1, dim);
    dim_range_list = zeros(dim, 2);
    for d = 1:dim
        idx = state_list{i}.dim_states(d);
        dim_range_list(d, 1) = data_setting.dim_value_range_ls{d}(idx);
        dim_range_list(d, 2) = data_setting.dim_value_range_ls{d}(idx+1);
        state_list{i}.mu(d) = (dim_range_list(d, 1) + dim_range_list(d, 2)) / 2.0;  % mean        
        state_list{i}.var(d) = (abs(dim_range_list(d, 1) - dim_range_list(d, 2)) * state_sigma)^2; % state_sigma = standard deviation (e.g. set as 0.25 of the state's value range)
    end    
end

%% set up initial state probability distribution
global state_init_prob_list;
num_state = size(state_list, 1);
state_init_prob_list = zeros(num_state, 1);
%% a uniform initial probability
state_init_prob_list(:) = 1.0 / num_state;

%Get all mu and sigma for easy processing later
%all_mus = cell2mat(cellfun(@(x) x.mu, state_list,'UniformOutput',false));
%all_sigmas = cell2mat(cellfun(@(x) x.sigma, state_list,'UniformOutput',false));
