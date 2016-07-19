function CTHMM_learn_NestViterbi_accum_Nij_Ti_for_one_interval(t_idx, T, k_list, l_list)

global state_reach_mat;
global Nij_mat;
global Ti_list;
global Etij;
global Q_mat;
global state_list;
global data_setting;
global Q_mat_struct;

size_k = size(k_list, 1);
size_l = size(l_list, 1);
       
for k_idx = 1:size_k
    
    k = k_list(k_idx);
    
    for l_idx = 1:size_l
                   
       l = l_list(l_idx);
              
       if (Etij(t_idx, k, l) == 0) 
            continue;            
       end
       
       if (state_reach_mat(k, l) == 0)
           continue;
       end

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       if (k == l)
           best_state_seq = [k l]';
       elseif (Q_mat_struct(k,l) == 1)
           best_state_seq = [k l]';
       else
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
           max_num_jump = 1;
           for d = 1:data_setting.dim
                diff = abs(state_list{k}.dim_states(d) - state_list{l}.dim_states(d));
                max_num_jump = max_num_jump + diff;
           end
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
           %qi_list = -diag(Q_mat);
           %max_num_jump = ceil(max(qi_list) * T * 20);
           best_log_prob = -inf;
           for j = 1:max_num_jump        
               num_jump = j;
               unidur = T / double(num_jump);
               [temp_best_state_seq, temp_best_log_prob] = CTHMM_learn_NestViterbi_inner_decoding_unidur_fixpathlen(k, l, num_jump, unidur);
                if (temp_best_log_prob > best_log_prob)
                    best_log_prob = temp_best_log_prob;
                    best_state_seq = temp_best_state_seq;
                end
           end
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
       end
       
    
       %% assign nij and ti        
       num_path_state = size(best_state_seq, 1);   
       if (num_path_state <= 0)
           disp('Err in NestViterbi: num of path state <=0');
       end
       
       unidur = T / (num_path_state-1);

       %% accumulate Nrs, Tr
       num_path_state = size(best_state_seq, 1);  
   
       for u = 1:(num_path_state-1)
           s1 = best_state_seq(u);                           
           s2 = best_state_seq(u+1);
           Ti_list(s1) = Ti_list(s1) + unidur * Etij(t_idx, k, l);           
           Nij_mat(s1, s2) = Nij_mat(s1, s2) + Etij(t_idx, k, l); 
           %% 2015/06/02
           Nij_mat(s1, s1) = Nij_mat(s1, s1) + Etij(t_idx, k, l);
       end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
    end %l
end %k