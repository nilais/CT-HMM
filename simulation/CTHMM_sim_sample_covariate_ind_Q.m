function [rand_cov_list, ind_Q_mat] = CTHMM_sim_sample_covariate_ind_Q(num_cov)

global syn_base_Q_mat;
global Q_mat_struct;
global syn_covariate_w_list;
global Q_mat_cov_struct;


rand_cov_list = zeros(num_cov, 1);

for c = 1:num_cov    
    rand_cov_list(c) = round(rand());% binary
end

num_state = size(syn_base_Q_mat, 1);
ind_Q_mat = zeros(num_state, num_state);

for i = 1:num_state
    
    sum_qij_new = 0.0;
    for j = 1:num_state
        
        if (Q_mat_struct(i, j) == 1)            
            
            covariate_on_ls = Q_mat_cov_struct{i,j};
            
            sum_cov_weight = 0.0;
            for c = 1:num_cov
               if (covariate_on_ls(c) == 1)
                   sum_cov_weight = sum_cov_weight + rand_cov_list(c) * syn_covariate_w_list(c);
               end
            end
            
            qij_cov_effect = exp(sum_cov_weight);            
            qij_new = syn_base_Q_mat(i, j) * qij_cov_effect;
            
            ind_Q_mat(i, j) = qij_new;
            sum_qij_new = sum_qij_new + qij_new;
        end
        
    end
    %% set up ind_Q(i,i)
    ind_Q_mat(i, i) = -sum_qij_new;    
end
