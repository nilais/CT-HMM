function CTHMM_sim_batch_gen_syn_obs_seq(syn_data_settings)

disp('In CTHMM_sim_batch_gen_syn_obs_seq()...');

global obs_seq_list;
global state_list;
global out_dir;
global syn_Nrs_mat;

num_state = size(state_list, 1);

%% generate syn observation sequences
max_num_obs_seq = 1000000;
num_setting = size(syn_data_settings, 1);

obs_seq_list = cell(max_num_obs_seq, 1);
all_setting_num_obs_seq = 0;
all_setting_num_visit = 0;

%% for each setting
for i = 1:num_setting

    num_total_visit = syn_data_settings{i}.num_total_visit;    
    %num_obs_seq = syn_data_settings{i}.num_obs_seq;    
    time_intv_list = syn_data_settings{i}.time_intv_list;
    obs_dur = syn_data_settings{i}.obs_dur;
    
    str = sprintf('Synthetic data setting %d: num_total_visit = %d, sampling_time_interval(1) = %.5f, obs_dur = %f\n', i, num_total_visit, time_intv_list(1), obs_dur);  
    CTHMM_print_log(str);
       
    %% use syn_Q_mat to generate data
    [temp_list] = CTHMM_sim_gen_syn_obs_seq_fix_total_visit_count(num_total_visit, time_intv_list, obs_dur);
    num_obs_seq = size(temp_list, 1);
    
    %% store obs sequences
    begin_idx = all_setting_num_obs_seq + 1;
    end_idx = begin_idx + num_obs_seq - 1;    
    obs_seq_list(begin_idx : end_idx) = temp_list;
    
    all_setting_num_visit = all_setting_num_visit + num_total_visit;
    all_setting_num_obs_seq = all_setting_num_obs_seq + num_obs_seq;
    
end
obs_seq_list = obs_seq_list(1:all_setting_num_obs_seq);
str = sprintf('all setting total_num_seq = %d\n', all_setting_num_obs_seq);
CTHMM_print_log(str);
str = sprintf('all setting total_num_visit = %d\n', all_setting_num_visit);
CTHMM_print_log(str);

%% count as each link from synthetic data
%fprintf(fp_log, 'the synthetic Q mat:\n');
%func_print_matrix_in_file(syn_Q_mat, fp_log);
syn_Nrs_mat = zeros(num_state, num_state);

for s = 1:all_setting_num_obs_seq    
    ori_state_chain = obs_seq_list{s}.ori_state_chain.state_idx_list';
    num_path_state = size(ori_state_chain, 1);    
    for i = 1:(num_path_state-1)
        s1 = ori_state_chain(i);
        s2 = ori_state_chain(i+1);
        syn_Nrs_mat(s1, s2) = syn_Nrs_mat(s1, s2) + 1;
        syn_Nrs_mat(s1, s1) = syn_Nrs_mat(s1, s1) + 1;
    end    
    s1 = ori_state_chain(num_path_state);
    syn_Nrs_mat(s1, s1) = syn_Nrs_mat(s1, s1) + 1;    
end
file = sprintf('%s/syn_Nrs_mat', out_dir);
save(file, 'syn_Nrs_mat');
