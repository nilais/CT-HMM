function CTHMM_learn_iter_reset_variables()

global Nij_mat;
global Ti_list;
global cur_all_subject_prob;
global state_list;

num_state = size(state_list, 1);

 %% reset Nij, Ti 
Nij_mat = zeros(num_state, num_state);
Ti_list = zeros(num_state, 1);

%% reset likelihood
cur_all_subject_prob = 0.0;

