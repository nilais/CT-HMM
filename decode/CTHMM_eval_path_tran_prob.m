function [prob, log_prob] = CTHMM_eval_path_tran_prob(state_seq)

global Q_mat;

num_state = size(state_seq, 1);

prob = 1.0;
log_prob = 0.0;

for s = 1:(num_state-1)
    
   s1 = state_seq(s);
   s2 = state_seq(s+1);
   
   vij = -Q_mat(s1, s2) / Q_mat(s1, s1);
   
   prob = prob * vij;
    
   log_prob = log_prob + log(vij);
    
end

