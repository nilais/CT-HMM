function [cur_all_subject_prob] = CTHMM_learn_batch_outer_decoding_Etij_for_subjects(is_outer_soft, train_idx_list)

disp('CTHMM_batch_outer_decoding_Etij_for_subjects');
tStartTemp = tic;
       
global Etij;
global obs_seq_list;
global distinct_time_list;
global state_list;
global time_diff_tol;
global model_iter_count;
global learn_performance;

cur_all_subject_prob = 0.0;
num_distinct_time = size(distinct_time_list, 1);
num_state = size(state_list, 1);

Etij = zeros(num_distinct_time, num_state, num_state);

num_train_subject = size(train_idx_list, 1);

%model_iter_count

for g = 1:num_train_subject
    
    %if (mod(g, 100) == 0)            
    if (mod(g, 10) == 0)
        str = sprintf('%d...', g);
        fprintf(str);
    end

    %% get the subject index
    subject_idx = train_idx_list(g);
    num_visit = obs_seq_list{subject_idx}.num_visit;
    % subject data
    if (num_visit == 0)
        continue;
    end

    %% compute forward backward algorithm, remember Et(i,j) parameter: prob at the end-states at time t    
    if (is_outer_soft == 1)    
        [Evij, subject_log_prob, Pt_list] = CTHMM_decode_outer_forwbackw(obs_seq_list{subject_idx});
    else
        [outer_state_seq, outer_dur_seq, subject_log_prob, Pt_list] = CTHMM_decode_outer_viterbi(obs_seq_list{subject_idx});        
    end
                  
    if (subject_log_prob == inf)
        str = sprintf('subject_log_prob = inf for subject = %d\n', g);
        CTHMM_print_log(str);
    end
    
    %% accum all prob
    cur_all_subject_prob = cur_all_subject_prob + subject_log_prob; % soft prob

    %% group Evij to be Etij
    num_distinct_time = size(distinct_time_list, 1);
    
    for v = 1:(num_visit-1)        
        T = obs_seq_list{subject_idx}.visit_time_list(v+1) - obs_seq_list{subject_idx}.visit_time_list(v);                                
        
        %% find T in t_list                
        %temp = find(abs(distinct_time_list-T) < time_diff_tol);
        %t_idx = temp(1);
        
        find = 0;
        for d = 1:num_distinct_time
            if (abs(T - distinct_time_list(d)) < time_diff_tol)            
                find = 1;
                t_idx = d;
                break;
            end
        end
        
        if (find == 0)
            disp('this is an error!');
        end
    
        
        if (is_outer_soft == 1)        
            for i = 1:num_state
                for  j = 1:num_state
                    Etij(t_idx, i, j) = Etij(t_idx, i, j) + Evij(v, i, j);
                end
            end        
        else
            i = outer_state_seq(v);
            j = outer_state_seq(v+1);
            Etij(t_idx, i, j) = Etij(t_idx, i, j) + 1;
        end
    end  
    
end % g (subject index)
        
fprintf('\n');

tEndTemp = toc(tStartTemp);
str = sprintf('Compute Etij(is_soft=%d): total elapse time: %d minutes and %f seconds\n', is_outer_soft, floor(tEndTemp/60),rem(tEndTemp,60));
CTHMM_print_log(str);

learn_performance.time_outer_list(model_iter_count) = tEndTemp;

    
