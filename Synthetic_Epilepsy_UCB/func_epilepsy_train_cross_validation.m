function [cross_valid_set, subject_cv_map] = func_epilepsy_train_cross_validation(top_out_dir, seq_list, learn_method, is_outer_soft, num_cv, cv_idx_list)

%% experiments for individualized prediciton
addpath('Glaucoma_Boston_parse');

addpath('../../learn');
addpath('../../decode');
addpath('../../precompute');
addpath('../../common');
addpath('../../common/fast_expm_A_t');
addpath('../../prediction');
addpath('../../MD/MD_model/');
addpath('../../MD/MD_vis/2D_vis');
addpath('../../MD/MD_vis');

%% setup output
global out_dir;
out_dir = top_out_dir;
mkdir(out_dir);

global fp_log;

global obs_seq_list;
obs_seq_list = seq_list;

global Q_mat_init;
global state_init_prob_list;
global state_list;
global neighbor_link_setting;
neighbor_link_setting = [4 4]; % forward link only
global learn_is_know_ground_truth_Q_mat;
learn_is_know_ground_truth_Q_mat = 0;
global is_use_individual_Q_mat;
is_use_individual_Q_mat = 0;
global is_use_distinct_time_grouping;
is_use_distinct_time_grouping = 1;

global learn_converge_tol;
learn_converge_tol = 10^(-5);

global model_iter_count;
global is_draw_learn_Q_mat;
is_draw_learn_Q_mat = 1;
global is_add_state_straight_path;
is_add_state_straight_path = 0;

%% state dwelling drawing color
global dwelling_time_draw_range_list;
global dwelling_time_draw_color_list;
dwelling_time_draw_range_list = [0 2 5 100];
dwelling_time_draw_color_list = [255 0 0 ; 255 0 0; 0 255 0; 0 255 0];



%===========================================
%% generate cross-validation set

if (num_cv > 1)
    [cross_valid_set, subject_cv_map] = func_gen_cross_validation_set(obs_seq_list, num_cv);
else
    num_subject = size(obs_seq_list, 1);
    cross_valid_set{1}.train_idx_list = [1:1:num_subject]';    
end

%% e.g. train 10 HMMs for 10-fold cross validation test
ori_out_dir = out_dir;
num_run_cv = size(cv_idx_list, 2);

for i = 1:num_run_cv

    cv = cv_idx_list(i);
    
    %% create output dir for this run
    out_dir = sprintf('%s/CV_%d', ori_out_dir, cv);
    mkdir(out_dir);    
    str = sprintf('%s/log.txt', out_dir);
    fp_log = fopen(str, 'wt');
    train_idx_list = cross_valid_set{cv}.train_idx_list;
        
    %% create state list
    state_sigma = 1;
    %CTHMM_MD_create_state_list(train_idx_list, state_sigma);
    state_list = cell(5,1);
    for i=1:5
        state.idx = i;
        state.dim_states = 1;
        state.mu = i-0.5;
        state.var = 0.0625;
        state_list{i}=state;
    end
    state_list
    %% set up initial state probability distribution    
    num_state = size(state_list, 1);
    state_init_prob_list = zeros(num_state, 1);
    state_init_prob_list(:) = 1.0 / num_state;    	

    %% create state reachibility matrix    
    CTHMM_precompute_state_reach_mat();

    %% create Q structure
    CTHMM_MD_create_Q_mat_struct();
    
    %% init learning Q mat
    init_ave_state_dwell = 24.0; % 24 months
    is_add_random_perturb = 1;
    perturb_amount = 0.05;    
    Q_mat_init = CTHMM_learn_init_Q_mat(init_ave_state_dwell, is_add_random_perturb, perturb_amount); % assign uniform probability to each link
    
    %% start learning Q mat
    learn_is_know_ground_truth_Q_mat = 0;   
    max_iter = 100;       
    CTHMM_learn_para_EM(learn_method, max_iter, is_outer_soft, Q_mat_init, train_idx_list);

    %% store the number of iteration in a file
    str = sprintf('%s/num_iter.txt', out_dir);
    fp = fopen(str, 'wt');
    fprintf(fp, '%d\n', model_iter_count);    
    fclose(fp_log);
    
end    

out_dir = ori_out_dir;
str = sprintf('%s/cross_valid_set', out_dir);
save(str, 'cross_valid_set');    
str = sprintf('%s/subject_cv_map', out_dir);
save(str, 'subject_cv_map');

%% 2015/5/26: test visualizatoin
%data_setting.dim_value_range_ls{1} = [100.5 99.5 98.5 96 94 92 90 85 80 75:(-5):50 40:(-10):20]; % dim1
%data_setting.dim_value_range_ls{2} = [130:(-5):30]; % dim2

%% 2015/6/22: for prediction tasks
%data_setting.dim_value_range_ls{1} = [100.5 99.5 98 96 93 90 85 80:(-10):20]; % dim1
%data_setting.dim_value_range_ls{2} = [130:(-5):80 70:(-10):30]; % dim2

%% 2015/6/28: test visualization for different age groups
%data_setting.dim_value_range_ls{1} = [100.5 99.5 98 96 93 90 85 80:(-10):20]; % dim1   % the best for VFI
%data_setting.dim_value_range_ls{2} = [130:(-5):50 40 30]; % dim2
