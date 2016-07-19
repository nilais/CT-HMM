function [is_success] = CTHMM_learn_Eigen_accum_Nij_Ti_for_one_time_interval(cur_time_idx, k_list, l_list)

global U_eigen;
global inv_U_eigen;
global X_eigen;
global Pt_eigen;

global Etij;

global Nij_mat;
global Ti_list;
global state_list;

global Q_mat;
global Q_mat_struct;
global state_reach_mat;

num_state = size(state_list, 1);

is_success = 1;
size_k = size(k_list, 1);
size_l = size(l_list, 1);


       
for k_idx = 1:size_k
    
    k = k_list(k_idx);
    
    for l_idx = 1:size_l
                   
       l = l_list(l_idx);
              
       if (Etij(cur_time_idx, k, l) == 0) 
            continue;            
       end
               
       if (state_reach_mat(k, l) == 0)
          continue;
       end

        %% compute soft transition count and duration for state pair (i,j)
        %[IDX_i] = find(state_reach_mat(k, :) == 1);                    
        %num_i = size(IDX_i, 2);

        for i = 1:num_state
        %for f = 1:num_i                        
            %i = IDX(f);

            if (state_reach_mat(k, i) == 0)
                continue;
            end

            %% compute Ri (duration)
            temp_sum = 0.0;                        
            for p = 1:num_state                            
                                
                if (U_eigen(k, p) == 0)
                    continue;
                end
                
                temp = 0.0;
                for q = 1:num_state
                    temp = temp + U_eigen(i, q) * inv_U_eigen(q, l) * X_eigen(p, q);
                end %q
                
                temp = temp * U_eigen(k, p) * inv_U_eigen(p, i);
                temp_sum = temp_sum + temp;
                
            end %p          

            %% now check whether temp_sum is positive or zero, if negative, then the eigen method is instable
%             if (temp_sum < 0.0) % negative
%                 str = sprintf('Detect negative duration %f for state (%d) with endpoint (%d, %d)\n', temp_sum, i, k, l);
%                 CTHMM_print_log(str);
%                 is_success = 0;
%                 return;
%             end
            
            %if (Pt_list{v}(k, l) ~= 0.0 && Etij(v, k, l) ~= 0.0)    
            if (Pt_eigen(k, l) ~= 0.0)

                Ri = temp_sum / Pt_eigen(k, l);

                if (Ri >= 0.0)
                    %% add duration
                    Ti_list(i) = Ti_list(i) + Ri * Etij(cur_time_idx, k, l);                    
                end

            end

            %% compute Nij (soft transition count)
            for j = 1:num_state

                if ((i ~= j) && (Q_mat_struct(i, j) == 0))
                    continue;
                end

                if (state_reach_mat(j, l) == 0)
                    continue;
                end

                temp_sum = 0.0;
                for p = 1:num_state
                    
                    if (U_eigen(k, p) == 0)
                        continue;
                    end
                    
                    temp = 0.0;
                    for q = 1:num_state
                        temp = temp + U_eigen(j, q) * inv_U_eigen(q, l) * X_eigen(p, q);
                    end %q       
                    temp = temp * U_eigen(k, p) * inv_U_eigen(p, i);
                    temp_sum = temp_sum + temp;
                    
                end %p

                
%                 if (temp_sum < 0.0) % negative
%                     str = sprintf('Detect negative transition count %f for state pair (%d, %d) with endpoint (%d, %d)\n', temp_sum, i, j, k, l);
%                     CTHMM_print_log(str);
%                     is_success = 0;
%                     return;
%                 end
                
                
                if (Pt_eigen(k, l) ~= 0.0)

                    Nij = temp_sum / Pt_eigen(k, l) * Q_mat(i, j);                                
                    
                    if (i ~= j)
                        Nij_mat(i,j) = Nij_mat(i,j) + Nij * Etij(cur_time_idx, k, l);
                    else
                        Nij_mat(i,j) = Nij_mat(i,j) + (-Nij) * Etij(cur_time_idx, k, l);
                    end
                    
                end

            end %j
        end %i
    end %l
end %k


