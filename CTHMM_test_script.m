%% 5-state experiments

%% set up simulation
out_directory = '../simulation_5state_syn1_m135';
syn_qi_range = [1 5]; % set qi to be in range [1 5], except the absorbing state
run_list = [2]%[1:1:5]'; % 5 random runs
%run_list = [2]'; % 1 random runs
syn_data_config_list = [1]'; % 10^5 visits, sampling rate: smallest holding time * 0.5; write the config in CTHMM_sim_set_syn_data_config(syn_config_idx)
test_method_list = [5]'; %test 1:soft(expm), 3:soft(unif), 5:soft(Eigen),  2:hard(expm), 4:hard(unif), 6:hard(Eigen)
%% set up state space
num_dim = 1;
num_state_per_dim = 5; % a 5-state model
neighbor_setting =[4]; % fully-connected model  (neighbor_link_setting = [1 1 1]; % 1: forward link only, 2: backward link only, 3: both directions, 4: fully-connected)

%% run
CTHMM_simulation(out_directory, syn_qi_range, test_method_list, syn_data_config_list, run_list, num_dim, num_state_per_dim, neighbor_setting);
