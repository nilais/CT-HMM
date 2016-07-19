function [tau_list] = CTHMM_compute_expected_tau_for_a_path_Unif(state_seq, T)

global Q_mat;

num_path_state = size(state_seq, 1);
tau_list = zeros(num_path_state, 1);

%% first, extract qi from the original Q_mat    
path_Qmat = zeros(num_path_state+1, num_path_state+1);

%% second, construct path-based Q matrix using the state_seq
for i = 1:num_path_state
    path_Qmat(i, i) = Q_mat(state_seq(i), state_seq(i));
    path_Qmat(i, i+1) = -path_Qmat(i, i);
end

%% compute each tau

%% compute Pt;
[Pt_mat, M, R_unif_list, Pois_unif_list] = CTHMM_compute_Pt_by_unif(path_Qmat, T);

num_sum_term = M;
                
%% compute duration for each state i given end state (k,l)
k = 1; % start state
l = num_path_state; % end state

for i = 1:num_path_state

    %% compute Ri (duration)            
    temp_sum = 0.0;
    for m = 0:1:num_sum_term
        temp_inner_sum = 0.0;
        for n = 0:1:m                    
            temp_inner_sum = temp_inner_sum + R_unif_list{n+1}(k, i) * R_unif_list{m-n+1}(i,l);                                        
        end
        temp_inner_sum = temp_inner_sum * Pois_unif_list.m_list(m+1) * T / (m+1);                
        temp_sum = temp_sum + temp_inner_sum;
    end %m

    p_kl = Pt_mat(k, l);

    if (p_kl ~= 0.0)
        tau_list(i) = temp_sum / p_kl;       
    end
   
end %i

