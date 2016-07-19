function [sum_dist] = CTHMM_learn_optimize_cov_weight(cur_cov_weight_list)

global base_Q_mat;
global Q_mat_cov_struct;
global Nij_mat;
global Q_mat_struct;
global Q_mat;
global obs_seq_list;
global train_idx_list;
global num_covariate;

num_state = size(Nij_mat, 1);

%sum_nij = 0.0;
sum_dist = 0.0;
num_train_seq = size(train_idx_list, 1);

for i = 1:num_state
    for j = 1:num_state
        
        if (Q_mat_struct(i, j) == 1)
                        
            ave_qij = Q_mat(i, j);
            covariate_on_ls = Q_mat_cov_struct{i,j}; 
            sum_nij_cov = 0.0;
            
            for p = 1:num_train_seq    
                
                train_id = train_idx_list(p);
                num_visit = obs_seq_list{train_id}.num_visit;      
                
                for v = 1:(num_visit-1)
                    
                    %% get nij for this patient, this visit
                    pv_nij = obs_seq_list{train_id}.visit_Nij_mat{v}(i, j);
                    
                    if (pv_nij > 0.0)
                        covariate_ls = obs_seq_list{train_id}.visit_covariate_ls{v};

                        %% compute covariate effect using current weight
                        sum_cov_weight = 0.0;
                        for c = 1:num_covariate
                           if (covariate_on_ls(c) == 1)
                               sum_cov_weight = sum_cov_weight + covariate_ls(c) * cur_cov_weight_list(c);
                           end
                        end            
                        pv_qij_cov_effect = exp(sum_cov_weight);
                        sum_nij_cov = sum_nij_cov + pv_nij * pv_qij_cov_effect; 
                    end
                    
                end % v                
            end % p
            
            approx_qij = sum_nij_cov * base_Q_mat(i, j) / Nij_mat(i, j);
                        
            dist = abs(approx_qij - ave_qij);
            
            sum_dist = sum_dist + dist;
            
            %sum_dist = sum_dist + dist * Nij_mat(i, j);
            %sum_nij = sum_nij + Nij_mat(i, j);
        end
        
    end
end

%sum_dist = sum_dist / sum_nij;
