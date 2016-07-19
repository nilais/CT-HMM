function CTHMM_learn_para_EM(ori_method, max_iter, ori_is_outer_soft, Q_mat_init, train_idx_list)

%% start timer
tStart = tic;

global learn_method;
global is_outer_soft;
learn_method = ori_method;
is_outer_soft = ori_is_outer_soft;

global out_dir;
global state_list;
global Q_mat;
global Pt_eigen;

%% option whether to do distinct time grouping framework
global distinct_time_list;
global distinct_time_Pt_list;

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

%% one time precompution before iteration
CTHMM_learn_onetime_precomputation(train_idx_list);

%% init eigen fail counter
global eigen_num_singular;
eigen_num_singular = 0;

while (model_iter_count < max_iter)
    
    tStartIter = tic;    
    learn_method = ori_method;
    
    %% add counter
    model_iter_count = model_iter_count + 1;    
        
    %% create dir for current folder
    top_out_folder = sprintf('%s/Iter_%d', out_dir, model_iter_count);
    if (~exist(top_out_folder, 'dir'))
        mkdir(top_out_folder);
    end    
    str = sprintf('*** Iter = %d:\n', model_iter_count);
    CTHMM_print_log(str);
    
    %% reset main global parameters
    CTHMM_learn_iter_reset_variables();
        
    %% do precomputation for each method
    CTHMM_learn_iter_precomputation(); 
    num_distinct_time = size(distinct_time_list, 1);
        
    %% batch outer soft/hard decoding
    [cur_all_subject_prob] = CTHMM_learn_batch_outer_decoding_Etij_for_subjects(is_outer_soft, train_idx_list);    
    
    %% now we can start learning for every distinct time
    tStartTemp = tic;
    str = sprintf('For each distinct time interval, compute inner expectations...\n');
    fprintf(str);
    if (learn_method == 1) % expm           
        k_list = [1:num_state]';
        l_list = [1:num_state]';        
        CTHMM_learn_Expm_accum_Nij_Ti_for_all_time_intervals(k_list, l_list);  
    else
        %% for all other learn methods, do for each distinct time interval in the outer loop
        for t_idx = 1:num_distinct_time
            
            T = distinct_time_list(t_idx);
            %XtStartTemp = tic;            
            str = sprintf('%d...', t_idx);
            fprintf(str);
            k_list = [1:num_state]';
            l_list = [1:num_state]';
            %% assign Pt                          
            if (learn_method == 2)  % uniformization                
                CTHMM_learn_Unif_accum_Nij_Ti_for_one_time_interval(t_idx, k_list, l_list);                                
            elseif (learn_method == 3) %% eigen
                Pt_eigen = distinct_time_Pt_list{t_idx};    
                %% compute Xpq matrix              
                CTHMM_learn_Eigen_compute_X_mat(T);
                CTHMM_learn_Eigen_accum_Nij_Ti_for_one_time_interval(t_idx, k_list, l_list);
                
                %eigen_is_success = CTHMM_learn_Eigen_accum_Nij_Ti_for_one_time_interval(t_idx, k_list, l_list);
                
                %if (eigen_is_success == 0)
                   %% then use uniform method instead?                   
                   %str = sprintf('Exit computing expectations using Eigen due to instable results\n');
                   %CTHMM_print_log(str);
                   %break;
                %end
                
            elseif (learn_method == 4) %% nested viterbi
                CTHMM_learn_NestViterbi_accum_Nij_Ti_for_one_interval(t_idx, T, k_list, l_list);
            end
            %XtEndTemp = toc(XtStartTemp);
            %str = sprintf('\nCompute one interval: %d minutes and %f seconds\n', floor(XtEndTemp/60),rem(XtEndTemp,60));
            %CTHMM_print_log(str);
        end % distinct time
    end
    tEndTemp = toc(tStartTemp);
    str = sprintf('\nCompute all inner counts: %d minutes and %f seconds\n', floor(tEndTemp/60),rem(tEndTemp,60));
    CTHMM_print_log(str);    
    learn_performance.time_inner_list(model_iter_count) = tEndTemp;    
    %% ===========================
    tEndIter = toc(tStartIter);
    str = sprintf('Iter %d: %d minutes and %f seconds\n', model_iter_count, floor(tEndIter/60),rem(tEndIter,60));
    CTHMM_print_log(str);
    learn_performance.time_list(model_iter_count) = tEndIter;        
    %% ===========================
    
%     if (learn_method == 3 && eigen_is_success == 0)
%         break;
%     end
    
    %% compute current learning performance
    CTHMM_learn_record_performance();
    
    %% draw learning figures
    %CTHMM_learn_vis_Q_mat(top_out_folder);
    
    %% Update Q_mat: qij = Nij/Ti
    pre_Q_mat = Q_mat;
    CTHMM_learn_update_Q_mat();
    Q_mat
    
    %% Store main variables in top_out_folder
    CTHMM_learn_store_main_variables(top_out_folder);
    
    %% output the time for one iteration   
    tEnd = toc(tStart);
    str = sprintf('Total elapse time: %d minutes and %f seconds\n', floor(tEnd/60),rem(tEnd,60));
    CTHMM_print_log(str);
    
    %% check if reached a fixed point
    [is_termindate] = CTHMM_learn_decide_termination(cur_all_subject_prob, pre_all_subject_prob);    
    if (is_termindate == 1)
        str = sprintf('%s/num_iter.txt', out_dir);
        fp = fopen(str, 'wt');
        fprintf(fp, '%d\n', model_iter_count);
        fclose(fp);
        if (cur_all_subject_prob < pre_all_subject_prob)
            Q_mat = pre_Q_mat;
        end
        break;
    end
    
    %% store current all subject prob
    pre_all_subject_prob = cur_all_subject_prob;
    
end % ite

%% record performance
CTHMM_learn_stop_record_performance(); 

tEnd = toc(tStart);
str = sprintf('Total elapse time: %d minutes and %f seconds\n', floor(tEnd/60),rem(tEnd,60));
CTHMM_print_log(str);
learn_performance.total_time = tEnd;
sprintf('Q matrix below');
Q_mat

if (ori_method == 3) % eigen method
    str = sprintf('Eigen method: number of time detecting singular inv(U) matrix = %d\n', eigen_num_singular);
    CTHMM_print_log(str);
end
