function CTHMM_simulation(out_directory, syn_qi_range, test_method_list, syn_data_config_list, run_list, num_dim, num_state_per_dim, neighbor_setting)

%% add paths
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

%% output
global out_dir;

mkdir(out_directory);
global fp_log;
str = sprintf('%s/log.txt', out_directory);
fp_log = fopen(str, 'wt');

%% set up synthetic data configuration
global syn_config_idx;
global syn_data_settings;

%% Q mat
%global syn_Q_mat;
%global Q_mat;

global max_iter;
global Q_mat_init;

%% observation sequences 
global obs_seq_list; % contain the generated synthetic data

%% set up method soft/hard expm/unif/eigen
global learn_method;
global is_outer_soft;

%% record learning performance
global learn_performance;
global all_result;

%% method list
global method_name_list;
method_name_list = {'Soft-Soft(expm)', 'Hard-Soft(expm)', 'Soft-Soft(Unif)', 'Hard-Soft(Unif)', 'Soft-Soft(eigen)', 'Hard-Soft(eigen)', 'Hard-Hard(nest-viterbi)'};

%% some global variables
global learn_is_know_ground_truth_Q_mat; % we know ground truth as this is simulation test
global is_use_distinct_time_grouping; % group visits by time to save computation 
global is_use_individual_Q_mat; % set off, as we now didn't model covariates
global is_draw_learn_Q_mat; % we draw Q mat for glaucoma and alzhimer's disease to see the state transition trends

learn_is_know_ground_truth_Q_mat = 1;
is_use_distinct_time_grouping = 1;
is_use_individual_Q_mat = 0;
is_draw_learn_Q_mat = 0; 

global learn_converge_tol;
learn_converge_tol = 10^(-8);

%% record all results
max_run = 5;
max_syn_config = 20;
max_method = 7;
all_result = cell(max_run, max_syn_config, max_method);
num_run = size(run_list, 1);
num_syn_config = size(syn_data_config_list, 1);
num_test_method = size(test_method_list, 1);

%% whether to compute log likelihood using ground truth Q matrix (as a reference)
%is_compute_ground_truth_Q_log_likelihood = 1;

%% for each random run
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
        visits = size(obs_seq_list{1}.visit_time_list,1);
        M = [];
        for p = 1:num_obs_seq
            visits = size(obs_seq_list{p}.visit_time_list,1);
            for v=1:visits
                M = [M; p obs_seq_list{p}.visit_time_list(v) obs_seq_list{p}.visit_data_list(v)];
            end
        end
        csvwrite('hmm.csv',M);
        train_idx_list = [1:num_obs_seq]';
            
        %% compute likelihood using ground truth Q matrix? (just for reference)
        %% uncomment the following code if you woule like to compute log likelihood value when use ground truth Q matrix
%         if (is_compute_ground_truth_Q_log_likelihood == 1) 
%             Q_mat = syn_Q_mat;
%             if (is_use_distinct_time_grouping == 1)
%                 CTHMM_precompute_distinct_time_Pt_list();
%             end               
%             CTHMM_precompute_batch_data_emission_prob(train_idx_list);
%             str = sprintf('GROUND TRUTH: complete log data likelihood:\n');
%             CTHMM_print_log(str);
%             [gt_total_log_L] = CTHMM_likelihood_complete_log();
%             str = sprintf('log L using ground truth Q = %f\n', gt_total_log_L);
%             CTHMM_print_log(str);
%         end
        
        %% for each testing method
        for m = 1:num_test_method
            
            method = test_method_list(m);
            method_name = method_name_list{method};        
            str = sprintf('===== Method %d: %s =====\n', method, method_name);
            CTHMM_print_log(str);
            
            %% create output dir for this setting
            str = sprintf('%s/r%d_syn%d/m%d', out_directory, run_idx, syn_config_idx, method);            
            out_dir = str;
            mkdir(out_dir);
            
            %% init common settings
            CTHMM_learn_init_common();
    
            %==============================
            if (method == 1) % soft(expm)
                learn_method = 1;is_outer_soft = 1;                
            elseif (method == 2) %hard(expm)
                learn_method = 1;is_outer_soft = 0;                    
            elseif (method == 3) %soft(unif) 
                learn_method = 2;is_outer_soft = 1;                    
            elseif (method == 4) %hard(unif)
                learn_method = 2;is_outer_soft = 0;                    
            elseif (method == 5) %soft(eigen)
                learn_method = 3;is_outer_soft = 1;                    
            elseif (method == 6) %hard(eigen)    
                learn_method = 3;is_outer_soft = 0;                
            elseif (method == 7) %nest(viterbi)
                learn_method = 4; is_outer_soft = 0;                
            else
                disp('unknown method code');
                break;
            end
                        
            init_ave_state_dwell = 1;        %% set as global parameter?
            is_add_random_perturb = 1;
            perturb_amount = 0.1;
            Q_mat_init = CTHMM_learn_init_Q_mat(init_ave_state_dwell, is_add_random_perturb, perturb_amount); % assign uniform probability to each link

            CTHMM_learn_para_EM(learn_method, max_iter, is_outer_soft, Q_mat_init, train_idx_list);        
            %==============================
            
            %% record results
            all_result{run_idx, syn_config_idx, method} = learn_performance;
            
            %% save intermediate learning result
            str = sprintf('%s/all_result', out_dir);   
            save(str, 'all_result');

        end % method
                
    end % syn_config
end % run





%% save learning result
str = sprintf('%s/all_result', out_dir);   
save(str, 'all_result');

%% calculate average results and print to log
CTHMM_sim_report_learn_result(all_result, test_method_list, syn_data_config_list, run_list);
