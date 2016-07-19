function [total_log_L] = CTHMM_compute_state_optimized_log_likelihood_matrixexp()

global obs_seq_list;
global fp_log;

num_obs_seq = size(obs_seq_list, 1);

tStart = tic;
total_log_L = 0;
for seq = 1:num_obs_seq
    
    %% total data likelihood    
    %[log_prob] = CTHMM_forward_algorithm(obs_seq_list{seq}, Q_mat);   
    [best_state_seq, dur_seq, best_log_prob, Pt_list, is_invalid_sequence] = CTHMM_outer_decoding_viterbi(obs_seq_list{seq}); 
    
    total_log_L = total_log_L + best_log_prob;
    
end
tEnd = toc(tStart);

str = sprintf('Total state-optimized (viterbi) log L = %.10f\n', total_log_L);
fprintf(fp_log, str);
fprintf(str);

%str = sprintf('Elapse time: %d minutes and %f seconds\n', floor(tEnd/60),rem(tEnd,60));
%fprintf(fp_log, str);
%fprintf(str);


