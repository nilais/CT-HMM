function func_epilepsy_predict_cross_validation(seq_list, pred_output_dir, pretrained_CTHMM_dir, num_cv)

num_min_hist_visit = 4;

%% experiments for Glaucoma future measurements prediciton
global obs_seq_list;
obs_seq_list = seq_list;

%% create output dir
global out_dir;
out_dir = pred_output_dir;
mkdir(out_dir);
str = sprintf('%s/log_10run.txt', out_dir);

%pretrained_CTHMM_dir = sprintf('predict_result\\glaucoma_Boston_2015_6_22_h4_v5_expmsoft_1p4_coarse2');
%pretrained_CTHMM_dir = sprintf('predict_result\\glaucoma_Boston_2015_6_25_h4_v5_unifhard_1p4_coarse2');

global fp_log;
fp_log = fopen(str, 'wt');
pred_fig_dir = sprintf('%s/pred_fig_result_10run', out_dir);
mkdir(pred_fig_dir);

addpath('../');
addpath('../../prediction');
addpath('../../decode');
addpath('../../learn');
addpath('../../common');
addpath('../../MD/MD_model');
addpath('../../MD/MD_vis/2D_vis');
addpath('Glaucoma_Boston_parse');

global data_setting;
global is_use_distinct_time_grouping;
is_use_distinct_time_grouping = 0;

%% for bayes LR method
global bayes_prior_model;
global bayes_mean_sigma;

max_num_test = 10000;
data_dim = data_setting.dim;
data_range = [0 100; 0 200];

%% reassign data in obs_seq_list to be compatible to my old codes for computing regression
num_seq = size(obs_seq_list, 1);
for s = 1:num_seq  
    num_visit = obs_seq_list{s}.num_visit;
    obs_seq_list{s}.ori_obs_time_seq = zeros(num_visit, 1);
    obs_seq_list{s}.ori_obs_seq = zeros(data_dim, num_visit);    
    for v = 1:num_visit
        obs_seq_list{s}.ori_obs_time_seq(v) = obs_seq_list{s}.visit_list{v}.time;
        obs_seq_list{s}.ori_obs_seq(:, v) = obs_seq_list{s}.visit_list{v}.data';  %%xx
    end
end

%% compute global linear regression parameters for all seqs (on all visits)
for s = 1:num_seq  
    %% compute regression on all visits
    begin_visit_idx = 1;
    end_visit_idx = obs_seq_list{s}.num_visit;
    time_origin_idx = 1;
    [global_LR_regress, global_LR_err_sigma_vec] = func_compute_linear_regress_para(obs_seq_list{s}, begin_visit_idx, end_visit_idx, time_origin_idx);    
    obs_seq_list{s}.global_LR_regress = global_LR_regress;
    obs_seq_list{s}.global_LR_err_sigma_vec = global_LR_err_sigma_vec;
end

%% train Bayes models
[cross_valid_set, seq_cv_map] = func_gen_cross_validation_set(obs_seq_list, num_cv);    

is_train_Bayes_model = 1;
if (is_train_Bayes_model == 1)    
    
    %% train 10 Bayesian prior models for 10 cross validation set
    ori_out_dir = out_dir;    
    for cv = 1:num_cv                 
        out_dir = sprintf('%s/CV_%d', ori_out_dir, cv);
        mkdir(out_dir);        
        train_idx_list = cross_valid_set{cv}.train_idx_list;        
        %% train bayesian prior model using trainning set
        is_bayes_joint_inference = 1;
        [bayes_prior_model, mean_sigma, std_sigma] = func_train_Bayes_prior_model(train_idx_list, is_bayes_joint_inference);
        cross_valid_set{cv}.bayes_prior_model = bayes_prior_model;
        cross_valid_set{cv}.bayes_mean_sigma = mean_sigma;
        cross_valid_set{cv}.bayes_std_sigma = std_sigma;        
    end    
    out_dir = ori_out_dir;
    str = sprintf('%s/cross_valid_set', out_dir);
    save(str, 'cross_valid_set');    
    str = sprintf('%s/seq_cv_map', out_dir);
    save(str, 'seq_cv_map');    
end

%% =====================
%% begin prediction test
global test_seq_idx_list;
run_testing = 1;

if (run_testing == 1)
    
num_seq = size(obs_seq_list, 1);
fprintf(fp_log, 'num of seqs = %d\n', num_seq);

test_seq_idx_list = [1:1:num_seq];
num_test_seq = size(test_seq_idx_list, 2);

%% record the error
overall_CTHMM_abs_err = zeros(data_dim, max_num_test);
overall_LR_abs_err = zeros(data_dim, max_num_test);
overall_global_LR_abs_err = zeros(data_dim, max_num_test);
overall_bayes_LR_abs_err = zeros(data_dim, max_num_test);
overall_num_test = 0;
num_valid_seq = 0;

for s = 1:num_test_seq
    
    %% record obs seq
    s    
    s_idx = test_seq_idx_list(s);    
    seq_data = obs_seq_list{s_idx};    
    seq_data.num_hist_visit = num_min_hist_visit;    
    num_visit = seq_data.num_visit;
    num_pred_visit = num_visit - num_min_hist_visit;    
    if (num_pred_visit <= 0)
        continue;
    else
        num_valid_seq = num_valid_seq + 1;
    end       
    fprintf(fp_log, 'test idx: %d\n', s_idx);    
    
    %% load CTHMM model
    cv_idx = seq_cv_map(s_idx);    
    str = sprintf('%s/CV_%d/num_iter.txt', out_dir, cv_idx);    
    fp = fopen(str, 'rt');
    num_iter = fscanf(fp, '%d');
    
    CTHMM_model_dir = sprintf('%s/CV_%d/Iter_%d', pretrained_CTHMM_dir, cv_idx, num_iter);    
    CTHMM_learn_load_para(CTHMM_model_dir);
    
    %% viterbi decoding for this seq
    hist_seq_data = seq_data;
    hist_seq_data.visit_list = hist_seq_data.visit_list(1:num_min_hist_visit);
    hist_seq_data.num_visit = num_min_hist_visit;    
    
    %% CT-HMM decoding of the history visits
    is_use_distinct_time_grouping = 0;
    hist_seq_data.has_compute_data_emiss_prob = 0;
    [best_state_seq, dur_seq, best_log_prob, log_Pt_list] = CTHMM_decode_outer_viterbi(hist_seq_data);
    hist_seq_data.ori_state_seq = best_state_seq;
        
    %% compute linear regression slope for the past visits
    begin_visit_idx = 1;
    end_visit_idx = num_min_hist_visit;
    time_origin_idx = 1;
    [hist_LR_regress, hist_LR_err_sigma_vec] = func_compute_linear_regress_para(seq_data, begin_visit_idx, end_visit_idx, time_origin_idx);    
    seq_data.hist_LR_regress = hist_LR_regress;
    seq_data.hist_LR_err_sigma_vec = hist_LR_err_sigma_vec;
    
    %% compute bayes regression parameters using history visits
    %% load bayes model
    bayes_prior_model = cross_valid_set{cv_idx}.bayes_prior_model;    
    bayes_mean_sigma = cross_valid_set{cv_idx}.bayes_mean_sigma;
    begin_visit_idx = 1;
    end_visit_idx = num_min_hist_visit;
    time_origin_idx = 1;
    [hist_bayes_regress] = func_compute_Bayes_linear_regress_para(seq_data, begin_visit_idx, end_visit_idx, time_origin_idx);
    seq_data.hist_bayes_regress = hist_bayes_regress;
    
    %% record obs seq
    num_visit = seq_data.num_visit;
    num_pred_visit = num_visit - num_min_hist_visit;    
    pred_time_seq = zeros(1, num_pred_visit);
    
    CTHMM_pred_obs_seq = zeros(data_dim, num_pred_visit);    
    LR_pred_obs_seq = zeros(data_dim, num_pred_visit);
    global_LR_pred_obs_seq = zeros(data_dim, num_pred_visit);
    bayes_LR_pred_obs_seq = zeros(data_dim, num_pred_visit);
    sum_CTHMM_abs_err = zeros(data_dim, 1);
    sum_LR_abs_err = zeros(data_dim, 1);
    sum_global_LR_abs_err = zeros(data_dim, 1);
    sum_bayes_LR_abs_err = zeros(data_dim, 1);
    
    %% do prediction
    for i = 1:num_pred_visit        
        v = num_min_hist_visit + i;        
        overall_num_test = overall_num_test + 1;        
        true_obs = seq_data.visit_list{v}.data';
       
        pred_time = seq_data.visit_list{v}.time - seq_data.visit_list{1}.time;
        pred_time_seq(i) = pred_time;
        
        %% prediction using CT-HMM
        search_t_interval = 3; % in month
        pred_t_interval = seq_data.visit_list{v}.time - seq_data.visit_list{num_min_hist_visit}.time;               
        cur_visit_idx = num_min_hist_visit;       
        search_t_stop_delta = 0.5; % month
        max_search_t_r_bound = 100 * 12; % 100 year
        [CTHMM_pred_obs, pred_state_idx, num_t1_search, num_t2_search] = func_CTHMM_predict_obs(hist_seq_data, cur_visit_idx, pred_t_interval, search_t_stop_delta, max_search_t_r_bound, data_range);
        CTHMM_pred_obs_seq(:, i) = CTHMM_pred_obs;
        CTHMM_abs_err = abs(true_obs - CTHMM_pred_obs);
        sum_CTHMM_abs_err = sum_CTHMM_abs_err + CTHMM_abs_err;
        overall_CTHMM_abs_err(:, overall_num_test) = CTHMM_abs_err;
        
        %% prediction using linear regression (LR)        
        [LR_pred_obs] = func_LR_predict_obs(hist_LR_regress, pred_time, data_range);
        LR_pred_obs_seq(:, i) = LR_pred_obs;
        LR_abs_err = abs(true_obs - LR_pred_obs);    
        sum_LR_abs_err = sum_LR_abs_err + LR_abs_err;
        overall_LR_abs_err(:, overall_num_test) = LR_abs_err;
        
        %% prediction based on Bayes linear regression          
        [bayes_LR_pred_obs] = func_LR_predict_obs(hist_bayes_regress, pred_time, data_range);        
        bayes_LR_pred_obs_seq(:, i) = bayes_LR_pred_obs;
        bayes_LR_abs_err = abs(true_obs - bayes_LR_pred_obs);    
        sum_bayes_LR_abs_err = sum_bayes_LR_abs_err + bayes_LR_abs_err;
        overall_bayes_LR_abs_err(:, overall_num_test) = bayes_LR_abs_err;
        
        %% prediction based on global (used as an error low bound)
        global_LR_regress = seq_data.global_LR_regress;     
        [global_LR_pred_obs] = func_LR_predict_obs(global_LR_regress, pred_time, data_range);        
        global_LR_pred_obs_seq(:, i) = global_LR_pred_obs;
        global_LR_abs_err = abs(true_obs - global_LR_pred_obs);
        sum_global_LR_abs_err = sum_global_LR_abs_err + global_LR_abs_err;        
        overall_global_LR_abs_err(:, overall_num_test) = global_LR_abs_err;
        
    end %v    
    seq_data.num_pred_visit = num_pred_visit;
    seq_data.pred_time_seq = pred_time_seq;
    seq_data.CTHMM_pred_obs_seq = CTHMM_pred_obs_seq;    
    seq_data.ave_CTHMM_pred_err = sum_CTHMM_abs_err ./ num_pred_visit;
    seq_data.ave_LR_pred_err = sum_LR_abs_err ./ num_pred_visit;
    seq_data.ave_global_pred_err = sum_global_LR_abs_err ./ num_pred_visit;
    seq_data.ave_bayes_pred_err = sum_bayes_LR_abs_err ./ num_pred_visit;
    
    %% plot prediction result
    out_filename = sprintf('%s/%03d_pred.png', pred_fig_dir, s_idx);
    
    %% result visualization    
    %func_vis_pred_result_glaucoma(seq_data, hist_seq_data.ori_state_seq, out_filename);    
    %fprintf(fp_log, '\n');
    
end % each test seq

fprintf(fp_log, 'num of valid seq = %d\n', num_valid_seq);

%% results and statistical test for each dimension
overall_CTHMM_abs_err = overall_CTHMM_abs_err(:, 1:overall_num_test);
overall_LR_abs_err = overall_LR_abs_err(:, 1:overall_num_test);
overall_global_LR_abs_err = overall_global_LR_abs_err(:, 1:overall_num_test);
overall_bayes_LR_abs_err = overall_bayes_LR_abs_err(:, 1:overall_num_test);
out_file = sprintf('%s/overall_CTHMM_abs_err', out_dir);
save(out_file, 'overall_CTHMM_abs_err');
out_file = sprintf('%s/overall_LR_abs_err', out_dir);
save(out_file, 'overall_LR_abs_err');
out_file = sprintf('%s/overall_global_LR_abs_err', out_dir);
save(out_file, 'overall_global_LR_abs_err');
out_file = sprintf('%s/overall_bayes_ind_sigma_LR_abs_err', out_dir);
save(out_file, 'overall_bayes_LR_abs_err');
func_pred_result_statistic_test(overall_CTHMM_abs_err, overall_LR_abs_err, overall_global_LR_abs_err, overall_bayes_LR_abs_err);

end % testing

fclose(fp_log);
