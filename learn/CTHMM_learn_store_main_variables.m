function CTHMM_learn_store_main_variables(top_out_folder)

global Q_mat;
global Q_mat_struct;
global state_list;
global state_reach_mat;
global state_init_prob_list;

global Nij_mat;
global Ti_list;

global learn_method;
global is_outer_soft;

global data_setting;
global neighbor_link_setting; % 1: forward link only, 2: backward link only, 3: both directions, 4: fully-connected

global cov_weight_list;
global base_Q_mat;

global is_use_individual_Q_mat;
global base_Q_mat;
global syn_base_Q_mat;
global syn_covariate_w_list;
global covariate_w_list;

%% store numerical values    

str = sprintf('%s/learn_variables.mat', top_out_folder);

save(str, 'Q_mat', 'Q_mat_struct', 'state_list', 'state_reach_mat', 'state_init_prob_list', ...
          'Nij_mat', 'Ti_list', ...
          'learn_method', 'is_outer_soft', 'data_setting', 'neighbor_link_setting', 'covariate_w_list', 'base_Q_mat', 'syn_covariate_w_list', 'syn_base_Q_mat');

