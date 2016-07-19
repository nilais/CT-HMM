function [ind_Q_mat, ind_cov_effect_mat]  = CTHMM_compute_individual_Q_mat(obs_seq, v)

global base_Q_mat;
global Q_mat_struct;
global covariate_w_list;
global Q_mat_cov_struct;

num_state = size(base_Q_mat, 1);
ind_Q_mat = zeros(num_state, num_state);
ind_cov_effect_mat = zeros(num_state, num_state);

covariate_ls = obs_seq.visit_covariate_ls{v};
num_cov = size(covariate_ls, 1);

for i = 1:num_state
    
    sum_qij_new = 0.0;
    for j = 1:num_state
        
        if (Q_mat_struct(i, j) == 1)            
            
            covariate_on_ls = Q_mat_cov_struct{i,j};
            
            sum_cov_weight = 0.0;
            for c = 1:num_cov
               if (covariate_on_ls(c) == 1)
                   sum_cov_weight = sum_cov_weight + covariate_ls(c) * covariate_w_list(c);
               end
            end
            
            qij_cov_effect = exp(sum_cov_weight);            
            ind_cov_effect_mat(i, j) = qij_cov_effect;
            
            qij_new = base_Q_mat(i, j) * qij_cov_effect;
            ind_Q_mat(i, j) = qij_new;
            sum_qij_new = sum_qij_new + qij_new;
        end
        
    end
    %% set up ind_Q(i,i)
    ind_Q_mat(i, i) = -sum_qij_new;    
end


