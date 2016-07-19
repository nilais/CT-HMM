function CTHMM_learn_Unif_accum_Nij_Ti_for_one_visit(cur_seq_idx, cur_visit_idx, T, k, l)

global visit_Pt_list;
global visit_R_unif_list;
global visit_Pois_unif_list;
global visit_ind_Q_mat_list;
global visit_ind_cov_effect_mat;

global Nij_mat;
global Ti_list;
global state_list;
global NijCov_mat;

global Q_mat_struct;
global state_reach_mat;
global obs_seq_list;

global is_use_individual_Q_mat;

ind_Q_mat = visit_ind_Q_mat_list{cur_visit_idx};

%% compute M
max_qi = max(-diag(ind_Q_mat));
qt = max_qi * T;
M = ceil(4 + 6 * sqrt(qt) + qt);

num_sum_term = M;
num_state = size(state_list, 1);

%% store the nij results for each visit
obs_seq_list{cur_seq_idx}.visit_Nij_mat{cur_visit_idx} = zeros(num_state, num_state);

%global Q_mat;
%global Q_mat_expm;
%global B_mat_expm;
%Pt_expm = expm(Q_mat*T);
%Q_mat_expm = Q_mat;
%B_mat_expm = zeros(num_state, num_state);
                
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
            temp_inner_sum = temp_inner_sum + visit_R_unif_list{cur_visit_idx}{n+1}(k, i) * visit_R_unif_list{cur_visit_idx}{m-n+1}(i,l);                                        
        end
        temp_inner_sum = temp_inner_sum * visit_Pois_unif_list{cur_visit_idx}.m_list(m+1) * T / (m+1);                
        temp_sum = temp_sum + temp_inner_sum;
    end %m

    p_kl = visit_Pt_list{cur_visit_idx}(k, l);

    if (p_kl ~= 0.0)
        Ri = temp_sum / p_kl;
        if (Ri >= 0.0)
            %% add duration
            Ti_list(i) = Ti_list(i) + Ri;                    
        end
        
        %% compare Ri with expm result
        %B_mat_expm(i, i) = 1;
        %[result_mat] = CTHMM_compute_end_condition_expectation_by_expm(T);
        %B_mat_expm(i, i) = 0;                
        %compare_Ri = result_mat(k, l) / Pt_expm(k,l);                

        %% ni
        ni = Ri * (-ind_Q_mat(i, i));
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
                    temp_inner_sum = temp_inner_sum + visit_R_unif_list{cur_visit_idx}{m-n+1}(k, i) * visit_R_unif_list{cur_visit_idx}{n}(j, l);
                end
                temp_inner_sum = temp_inner_sum * visit_Pois_unif_list{cur_visit_idx}.m_list(m+1);
                temp_sum = temp_sum + temp_inner_sum;
            end %m 

            p_kl = visit_Pt_list{cur_visit_idx}(k, l);

            if (p_kl ~= 0.0)

                Rij = visit_R_unif_list{cur_visit_idx}{2}(i,j);                    
                Nij = temp_sum / p_kl * Rij;

                Nij_mat(i,j) = Nij_mat(i,j) + Nij;

                %% NijCov_mat: for update base qij
                if (is_use_individual_Q_mat == 1)    
                    NijCov_mat(i, j) = NijCov_mat(i, j) + Nij * visit_ind_cov_effect_mat{cur_visit_idx}(i, j);                
                end
                
                %% store the nij result for this patient, and this visit
                obs_seq_list{cur_seq_idx}.visit_Nij_mat{cur_visit_idx}(i, j) = Nij;
                
                %% compare nij result with expm result
                %B_mat_expm(i, j) = 1;
                %[result_mat] = CTHMM_compute_end_condition_expectation_by_expm(T);
                %B_mat_expm(i, j) = 0;                                    
                %compare_Nij = result_mat(k, l) / Pt_expm(k,l) * Q_mat(i,j);

            end                    
        end

    end %j
end %i
