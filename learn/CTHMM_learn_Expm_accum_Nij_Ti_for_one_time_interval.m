function CTHMM_learn_Expm_accum_Nij_Ti_for_one_time_interval(t_idx, T, k_list, l_list)

% str = sprintf('In CTHMM_Expm_accum_Nij_Ti_for_one_time_interval_on_original_space\n');
% str

global Etij;
global Pt_expm;
global Ti_list;
global Nij_mat;
global Q_mat;
global Q_mat_struct;

global Q_mat_expm;
global B_mat_expm;

Q_mat_expm = Q_mat;

global state_list;


num_state = size(state_list, 1);

B_mat_expm = zeros(num_state, num_state);

num_k_idx = size(k_list, 1);
num_l_idx = size(l_list, 1);

%% for each state, compute tau_i
for i = 1:num_state
    
%     if (mod(i, 10) == 0)
%         str = sprintf('%d...', i);
%         fprintf(str);
%     end
    
    %% compute expected duration
    B_mat_expm(i, i) = 1;
    [result_mat] = CTHMM_compute_end_condition_expectation_by_expm(T);
    B_mat_expm(i, i) = 0;

    Ri = 0.0;
    for k_idx = 1:num_k_idx
        k = k_list(k_idx);        
        for l_idx = 1:num_l_idx
            l = l_list(l_idx);            
            if (Pt_expm(k,l) ~= 0.0)            
                Ri = Ri + Etij(t_idx, k, l) * result_mat(k, l) / Pt_expm(k,l);
            end            
        end
    end  
    % Ti
    Ti_list(i) = Ti_list(i) + Ri;
    
    %% ni
    ni = Ri * (-Q_mat(i, i));
    Nij_mat(i, i) = Nij_mat(i, i) + ni;
    
end

% str = sprintf('\n');
% fprintf(str);


% for each link, compute n_ij
for i = 1:num_state
    for j = 1:num_state
        
%          if (mod(i, 10) == 0)
%             str = sprintf('%d...', i);
%             fprintf(str);
%          end
        
        %% compute expected transition counts
        if (Q_mat_struct(i, j) == 1)
            
            B_mat_expm(i, j) = 1;
            [result_mat] = CTHMM_compute_end_condition_expectation_by_expm(T);
            B_mat_expm(i, j) = 0;

            temp_sum = 0.0;
            for k_idx = 1:num_k_idx
                k = k_list(k_idx);        
                for l_idx = 1:num_l_idx
                    l = l_list(l_idx);                    
                    if (Pt_expm(k,l) ~= 0.0)                       
                        temp_sum = temp_sum + Etij(t_idx, k, l) * result_mat(k, l) / Pt_expm(k,l);
                    end                    
                end
            end
            
            nij = temp_sum * Q_mat(i, j);
                        
            %% accuomulate count to Nij matrix
            Nij_mat(i, j) = Nij_mat(i, j) + nij;
        end                    
    end
end