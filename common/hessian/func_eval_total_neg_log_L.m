function [total_neg_log_L] = func_eval_total_neg_log_L(cur_age_effect_vec)

global subject_list;
global age_effect_vec;
global fminunc_eval_count;
global Q_mat_base;


age_effect_vec = cur_age_effect_vec;

% update Q_mat_base based on current weight vector
func_compute_Q_mat_base(age_effect_vec);

fminunc_eval_count
age_effect_vec

num_subject = size(subject_list, 1);

total_neg_log_L = 0;

for s = 1:num_subject

    %% viterbi decoding for this subject
    [best_state_seq, dur_seq, best_log_prob, is_invalid_sequence] = func_viterbi(subject_list{s});
    
    if (is_invalid_sequence == 0)
        total_neg_log_L = total_neg_log_L - best_log_prob;        
    else
        total_neg_log_L = total_neg_log_L - log(0);
        str = sprintf('subject %d has is_invalid_sequence\n', s);
        str
    end
    
    
end

fminunc_eval_count = fminunc_eval_count + 1;

global fp_log;
fprintf(fp_log, 'eval # = %d, total_neg_log_L = %.10f\n', fminunc_eval_count, total_neg_log_L);
fprintf(fp_log, 'age_effect_vec:\n');

%for i = 1:3
for i = 1:(3*age_config)
    fprintf(fp_log, '%.10f, ', age_effect_vec(i));
end
fprintf(fp_log, '\n');

total_neg_log_L