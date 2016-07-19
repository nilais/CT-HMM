function CTHMM_learn_Unif_accum_Nij_Ti_for_one_time_interval(cur_time_idx, k_list, l_list)

global R_unif_list;
global Pois_unif_list;
global distinct_time_Pt_list;
global distinct_time_list;

global Etij;

global Nij_mat;
global Ti_list;
global state_list;

global Q_mat_struct;
global state_reach_mat;

global max_qi;

global Q_mat;
global Q_mat_expm;
global B_mat_expm;

global unif_M_list;

T = distinct_time_list(cur_time_idx);
qt = max_qi * T;    
M = ceil(4 + 6 * sqrt(qt) + qt);

unif_M_list(cur_time_idx) = M;

%str = sprintf('t_idx = %d, M = %d, max_qi = %f, t = %f\n', cur_time_idx, M, max_qi, T);
%CTHMM_print_log(str);

num_sum_term = M;

num_state = size(state_list, 1);
size_k = size(k_list, 1);
size_l = size(l_list, 1);

%Pt_expm = expm(Q_mat*T);

Q_mat_expm = Q_mat;
B_mat_expm = zeros(num_state, num_state);
                

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

       %% compute duration for each state i given end state (k,l)
       for i = 1:num_state

            if (state_reach_mat(k, i) == 0)
                continue;
            end

            %% compute Ri (duration)            
            temp_sum = 0.0;
            for m = 0:1:num_sum_term
                temp_inner_sum = 0.0;
                for n = 0:1:m                    
                    temp_inner_sum = temp_inner_sum + R_unif_list{n+1}(k, i) * R_unif_list{m-n+1}(i,l);                                        
                end
                temp_inner_sum = temp_inner_sum * Pois_unif_list{cur_time_idx}.m_list(m+1) * T / (m+1);                
                temp_sum = temp_sum + temp_inner_sum;
            end %m
                          
            p_kl = distinct_time_Pt_list{cur_time_idx}(k, l);
            
            if (p_kl ~= 0.0)
                Ri = temp_sum / p_kl;
                if (Ri >= 0.0)
                    %% add duration
                    Ti_list(i) = Ti_list(i) + Ri * Etij(cur_time_idx, k, l);                    
                end
                %% compare Ri with expm result                               
                %B_mat_expm(i, i) = 1;
                %[result_mat] = CTHMM_compute_end_condition_expectation_by_expm(T);
                %B_mat_expm(i, i) = 0;                
                %compare_Ri = result_mat(k, l) / Pt_expm(k,l);                
                
                %% ni
                ni = Ri * (-Q_mat(i, i));
                Nij_mat(i, i) = Nij_mat(i, i) + ni;
                
            end

            %% compute Nij (soft transition count)
            for j = 1:num_state

                if (Q_mat_struct(i, j) == 1 && state_reach_mat(j, l) == 1)
                    
                    %% compute nij          
                    temp_sum = 0.0;                        
                    for m = 1:num_sum_term
                        temp_inner_sum = 0.0;
                        for n = 1:m
                            temp_inner_sum = temp_inner_sum + R_unif_list{m-n+1}(k, i) * R_unif_list{n}(j, l);
                        end
                        temp_inner_sum = temp_inner_sum * Pois_unif_list{cur_time_idx}.m_list(m+1);
                        temp_sum = temp_sum + temp_inner_sum;
                    end %m 

                    p_kl = distinct_time_Pt_list{cur_time_idx}(k, l);

                    if (p_kl ~= 0.0)

                        Rij = R_unif_list{2}(i,j);                    
                        Nij = temp_sum / p_kl * Rij;

                        Nij_mat(i,j) = Nij_mat(i,j) + Nij * Etij(cur_time_idx, k, l);

                        %% compare nij result with expm result
                        %B_mat_expm(i, j) = 1;
                        %[result_mat] = CTHMM_compute_end_condition_expectation_by_expm(T);
                        %B_mat_expm(i, j) = 0;                                    
                        %compare_Nij = result_mat(k, l) / Pt_expm(k,l) * Q_mat(i,j);

                    end                    
                end

                
            end %j
        end %i
    end %l
end %k
