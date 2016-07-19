function CTHMM_MD_create_Q_mat_struct()

%% if state r,s should be a neighbor,
%% assign 1 to the entry (r,s) of Q_mat_struct

global Q_mat_struct; % store 2D topology
global state_list;  % 1D state list
global data_setting;
global neighbor_link_setting; % 1: forward link only, 2: backward link only, 3: both directions, 4: fully-connected

dim = data_setting.dim;

%% design Q state topology and create Q matrix structure
num_state = size(state_list, 1);
Q_mat_struct = zeros(num_state, num_state);

%% construct neighbor links

for s = 1:num_state

    num_neighbor = 0;   
    
    if (neighbor_link_setting(1) == 4) % fully connected  %%xx
        max_num_neighbor = num_state;
    else
        max_num_neighbor = 3^dim; % forward, backward, and the same index for each of the dimension, so 3 here
    end

    state_list{s}.neighbor_list = zeros(max_num_neighbor, 1);    
    s_dim_states = state_list{s}.dim_states;
    
    for t = 1:num_state
    
        if (s == t)
            continue;
        end
            
        %% check whether t is a neighbor of s
        t_dim_states = state_list{t}.dim_states;
        
        is_neighbor = 1;        
        for d = 1:dim  % check each dimension  
            
            if (neighbor_link_setting(d) == 4)
            
            elseif (neighbor_link_setting(d) == 1) % forward link only
                %% forward links: t's dim should always be larger or equal to s's dim
                if ((t_dim_states(d) - s_dim_states(d)) == 0 || (t_dim_states(d) - s_dim_states(d)) == 1)                
                else
                    is_neighbor = 0;
                    break;
                end                    
            elseif (neighbor_link_setting(d) == 2) % backward link only
                if ((t_dim_states(d) - s_dim_states(d)) == 0 || (t_dim_states(d) - s_dim_states(d)) == -1)                               
                else
                    is_neighbor = 0;
                    break;
                end                
            elseif (neighbor_link_setting(d) == 3) % both forward and backward link are allowed
                if ((t_dim_states(d) - s_dim_states(d)) == 0 || abs(t_dim_states(d) - s_dim_states(d)) == 1)                          
                else
                    is_neighbor = 0;
                    break;
                end
            end            
        end % d

        if (is_neighbor == 1)
            Q_mat_struct(s, t) = 1;            
            num_neighbor = num_neighbor + 1;
            state_list{s}.neighbor_list(num_neighbor) = t;            
        end
    
    end  % t
    
    state_list{s}.neighbor_list = state_list{s}.neighbor_list(1:num_neighbor);           
end % s

