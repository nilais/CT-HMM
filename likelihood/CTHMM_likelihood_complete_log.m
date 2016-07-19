function [total_log_L] = CTHMM_likelihood_complete_log()

global obs_seq_list;
%global fp_log;
global Q_mat;

num_obs_seq = size(obs_seq_list, 1);

tStart = tic;
total_log_L = 0;

for seq = 1:num_obs_seq
    %% total data likelihood    
    if (mod(seq, 100) == 0)                    
        str = sprintf('%d...', seq);
        fprintf(str);
    end    
    [log_prob] = CTHMM_likelihood_forward(obs_seq_list{seq});
    total_log_L = total_log_L + log_prob;   
end
if (num_obs_seq > 100)
    fprintf('\n');
end

tEnd = toc(tStart);

%str = sprintf('Total complete log L = %.10f\n', total_log_L);
%fprintf(fp_log, str);
%fprintf(str);

str = sprintf('Elapse time: %d minutes and %f seconds\n', floor(tEnd/60),rem(tEnd,60));
CTHMM_print_log(str);
%fprintf(fp_log, str);
%fprintf(str);
