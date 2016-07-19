function CTHMM_learn_para_EM_with_covariate(ori_method, max_iter, ori_is_outer_soft, Q_mat_init, train_idx_list)

%% start timer
tStart = tic;

global obs_seq_list;
global learn_method;
global is_outer_soft;
learn_method = ori_method;
is_outer_soft = ori_is_outer_soft;

global out_dir;
global state_list;
global Q_mat;
global num_covariate;

%% iteration count
global model_iter_count;
global cur_all_subject_prob;
global learn_performance;

CTHMM_learn_init_common();

%% to decide whether to draw 2D fig
num_state = size(state_list, 1);

%% initialize Q
Q_mat = Q_mat_init;
global pre_Q_mat;
pre_Q_mat = Q_mat_init;

%% iteration
pre_all_subject_prob = -inf;
model_iter_count = 0;

%% init learn performance
CTHMM_learn_init_performance(ori_method, is_outer_soft, max_iter);


global base_Q_mat;
global covariate_w_list;
global NijCov_mat;

%base_Q_mat = Q_mat;
%covariate_w_list = zeros(num_covariate, 1);


%% one time precompution before iteration
CTHMM_learn_onetime_precomputation(train_idx_list);

while (model_iter_count < max_iter)
    
    tStartIter = tic;    
    learn_method = ori_method;
    
    %% add counter
    model_iter_count = model_iter_count + 1;    
        
    %% create dir for current folder
    top_out_folder = sprintf('%s\\Iter_%d', out_dir, model_iter_count);
    if (~exist(top_out_folder, 'dir'))
        mkdir(top_out_folder);
    end    
    str = sprintf('*** Iter = %d:\n', model_iter_count);
    CTHMM_print_log(str);
    
    %% reset main global parameters
    CTHMM_learn_iter_reset_variables();
        
    %% do precomputation for each method
    CTHMM_learn_iter_precomputation();
            
    num_train_seq = size(train_idx_list, 1);
    
    NijCov_mat = zeros(num_state, num_state);
    
    %% decode for each patient  
    for g = 1:num_train_seq
        
        tStartTemp = tic;
        
        %% get the subject index
        subject_idx = train_idx_list(g);
        num_visit = obs_seq_list{subject_idx}.num_visit;
        %% subject data
        if (num_visit <= 1)
            continue;
        end

        %% compute forward backward algorithm, remember Et(i,j) parameter: prob at the end-states at time t            
        %[subject_log_prob] = CTHMM_learn_batch_outer_decoding_Etij_for_subjects(is_outer_soft, subject_idx);
        [outer_state_seq, outer_dur_seq, subject_log_prob, Pt_list] = CTHMM_decode_outer_viterbi(obs_seq_list{subject_idx});

        %% accumulate log probability            
        cur_all_subject_prob = cur_all_subject_prob + subject_log_prob; % subject log prob

        %% compute aux matrix X for every time segment
        obs_seq_list{subject_idx}.visit_Nij_mat = cell(num_visit, 1);
        
        for v = 1:(num_visit - 1)            
            T = obs_seq_list{subject_idx}.visit_time_list(v+1) - obs_seq_list{subject_idx}.visit_time_list(v);            
            k = outer_state_seq(v);
            l = outer_state_seq(v+1);                        
            CTHMM_learn_Unif_accum_Nij_Ti_for_one_visit(subject_idx, v, T, k, l);            
        end %v
        
        tEndTemp = toc(tStartTemp);
        %str = sprintf('\nComputing time for one subject: %d minutes and %f seconds\n', floor(tEndTemp/60),rem(tEndTemp,60));
        %CTHMM_print_log(str);
        
    end % g, subject idx

    %% compute current learning performance
    CTHMM_learn_record_performance();
    
    %% draw learning figures
    CTHMM_learn_vis_Q_mat(top_out_folder);
    
    %% Update Q_mat: qij = Nij/Ti
    pre_Q_mat = Q_mat;
    CTHMM_learn_update_Q_mat();
    
    %% ===========================
    tEndIter = toc(tStartIter);
    str = sprintf('Iter %d: %d minutes and %f seconds\n', model_iter_count, floor(tEndIter/60),rem(tEndIter,60));
    CTHMM_print_log(str);
    learn_performance.time_list(model_iter_count) = tEndIter;        
    %% ===========================
    
    %% Store main variables in top_out_folder
    CTHMM_learn_store_main_variables(top_out_folder);
    
    %% output the time for one iteration   
    tEnd = toc(tStart);
    str = sprintf('Total elapse time: %d minutes and %f seconds\n', floor(tEnd/60),rem(tEnd,60));
    CTHMM_print_log(str);
    
    %% check if reached a fixed point
%     [is_termindate] = CTHMM_learn_decide_termination(cur_all_subject_prob, pre_all_subject_prob);    
%     
%     if (is_termindate == 1)
%         str = sprintf('%s\\num_iter.txt', out_dir);
%         fp = fopen(str, 'wt');
%         fprintf(fp, '%d\n', model_iter_count);
%         fclose(fp);
%         if (cur_all_subject_prob < pre_all_subject_prob)
%             Q_mat = pre_Q_mat;
%         end
%         
%         %% compute hessian for covariate weight vector
%         [std_vec, CI_mat] = CTHMM_learn_compute_hess_covariate_weight(covariate_w_list);        
%         break;
%     end
%     
    %% store current all subject prob
    pre_all_subject_prob = cur_all_subject_prob;
    
end % ite

%% record performance
CTHMM_learn_stop_record_performance(); 

tEnd = toc(tStart);
str = sprintf('Total elapse time: %d minutes and %f seconds\n', floor(tEnd/60),rem(tEnd,60));
CTHMM_print_log(str);
learn_performance.total_time = tEnd;


