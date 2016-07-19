function [total_neg_log_L] = CTHMM_likelihood_complete_neg_log_Qparalist(Q_para_list)

global obs_seq_list;
global fmincon_eval_count;
global fp_log;
global Q_mat;

tStart = tic;
Q_mat = CTHMM_learn_derive_Q_mat_from_Q_para_list(Q_para_list);

fmincon_eval_count

num_obs_seq = size(obs_seq_list, 1);

total_neg_log_L = 0;
for seq = 1:num_obs_seq
    
    %% viterbi decoding for this subject
    [log_prob] = CTHMM_likelihood_forward(obs_seq_list{seq});
    
    total_neg_log_L = total_neg_log_L - log_prob;    
    %fprintf('seq:%d, log_prob = %f\n', seq, log_prob);
    
end
fmincon_eval_count = fmincon_eval_count + 1;

fprintf(fp_log, 'eval # = %d, total_neg_log_L = %.10f\n', fmincon_eval_count, total_neg_log_L);
fprintf(fp_log, '\n');

total_neg_log_L

tEnd = toc(tStart);
str = sprintf('Elapse time: %d minutes and %f seconds\n\n', floor(tEnd/60),rem(tEnd,60));
fprintf(str);
fprintf(fp_log, str);

