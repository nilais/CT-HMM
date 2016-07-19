addpath('simulation');
addpath('prediction');
addpath('learn');
addpath('decode');
addpath('precompute');
addpath('likelihood');
addpath('common');
addpath('common/fast_expm_A_t');
addpath('MD/MD_model/');
addpath('MD/MD_vis/2D_vis');
addpath('MD/MD_vis');

for r = 1:num_run
        
    %% specify the seed for random number
    run_idx = run_list(r);
    sd = run_idx * 100;
    rng(sd);
    
    str = sprintf('===== Run Idx %d: (seed = %d) ======\n', run_idx, sd);
    CTHMM_print_log(str);
    
    %% create state list
    state_sigma = 0.25; %state sigma is set to be 0.25 of the state's data range
    CTHMM_sim_create_MD_syn_state_list(num_dim, num_state_per_dim, state_sigma);
     
    %% create synthetic Q mat and init learning Q mat
    %e.g. for a 2D model, neighbor_link_setting = [1 1]; % 1: forward link
    %only, 2: backward link only, 3: both directions, 4: fully connected
    CTHMM_sim_gen_syn_Q_mat(syn_qi_range, neighbor_setting);
    
    %% create state reachability mat
    CTHMM_precompute_state_reach_mat();
                 
    %% for each synthetic data config
    for s = 1:num_syn_config
        
        syn_config_idx = syn_data_config_list(s);        
        str = sprintf('===== Syn Config Idx %d: =====\n', syn_config_idx);
        CTHMM_print_log(str);
        
        %% create output dir for this setting
        str = sprintf('%s/r%d_syn%d', out_directory, run_idx, syn_config_idx);
        out_dir = str;
        mkdir(out_dir);
        
        %% set up synthetic config
        CTHMM_sim_set_syn_data_config(syn_config_idx);
        
        %% generate observation sequences
        CTHMM_sim_batch_gen_syn_obs_seq(syn_data_settings);
        num_obs_seq = size(obs_seq_list, 1);            
        train_idx_list = [1:num_obs_seq]';
    end
end
            
