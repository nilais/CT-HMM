function CTHMM_sim_create_syn_state_list(dim, num_state_per_dim, neighbor_setting)

global neighbor_link_setting;

neighbor_link_setting = neighbor_setting;

%% create 3D state list, assign global variable state_list
if (dim == 1) % test a complete digraph    
    CTHMM_sim_create_1D_syn_state_list(num_state_per_dim);  % a simple 2D state structure, with progression link only
    %neighbor_link_setting = 4; % 1: forward link only, 2: backward link only, 3: both directions 4: fully-connected
elseif (dim == 2)    
    CTHMM_sim_create_2D_syn_state_list(num_state_per_dim);  % a simple 2D state structure, with progression link only
    %neighbor_link_setting = [1 1]; % 1: forward link only, 2: backward link only, 3: both directions
elseif (dim == 3)
    CTHMM_sim_create_3D_syn_state_list(num_state_per_dim);  % a simple 2D state structure, with progression link only
    %neighbor_link_setting = [1 1 1]; % 1: forward link only, 2: backward link only, 3: both directions
end

