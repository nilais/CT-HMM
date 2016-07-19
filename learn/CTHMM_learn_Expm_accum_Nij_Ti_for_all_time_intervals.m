function CTHMM_learn_Expm_accum_Nij_Ti_for_all_time_intervals(k_list, l_list)

disp('CTHMM_Expm_accum_Nij_Ti_for_all_time_intervals');

global Q_mat;
global Q_mat_struct;
global state_list;
num_state = size(state_list, 1);
num_k_idx = size(k_list, 1);
num_l_idx = size(l_list, 1);

global Etij;
global Ti_list;
global Nij_mat;

global distinct_time_list;
global distinct_time_Pt_list;
num_distinct_time = size(distinct_time_list, 1);

global is_use_fast_expm_At;
is_use_fast_expm_At = 1;

global A; % matrix used in fast expm
global has_computed_A_series;
has_computed_A_series = 0;

%% construct A matrix
A = zeros(num_state * 2, num_state * 2);
A(1:num_state, 1:num_state) = Q_mat;
A((num_state+1):end, (num_state+1):end) = Q_mat;

%% for each state, compute tau_i
tStartTemp = tic;

for i = 1:num_state

    str = sprintf('%d...', i);
    fprintf(str);
    
    %% reset A matrix
    has_computed_A_series = 0;    
    
    %% set up A
    A(i, i + num_state) = 1;
    
    for t_idx = 1:num_distinct_time

        %Pt_expm = distinct_time_Pt_list{t_idx};
        T = distinct_time_list(t_idx);
        
        if (is_use_fast_expm_At == 1)
            expm_A = matlab_expm_At(T);
        else
            expm_A = expm(A * T);
        end
        %result_mat = expm_A(1:num_row, (num_col+1):end);
                
        Ri = 0.0;
        for k_idx = 1:num_k_idx
            k = k_list(k_idx);        
            for l_idx = 1:num_l_idx
                l = l_list(l_idx);

                if (distinct_time_Pt_list{t_idx}(k,l) ~= 0)
                    Ri = Ri + Etij(t_idx, k, l) * expm_A(k, l + num_state) / distinct_time_Pt_list{t_idx}(k,l);
                end            
            end
        end
        
        % Ti
        Ti_list(i) = Ti_list(i) + Ri;

        %% ni
        ni = Ri * (-Q_mat(i, i));
        Nij_mat(i, i) = Nij_mat(i, i) + ni;
    
    end
    
    %% restore    
    A(i, i + num_state) = 0;
    
end

tEndTemp = toc(tStartTemp);
str = sprintf('\nCompute all tau_i: time: %d minutes and %f seconds\n', floor(tEndTemp/60),rem(tEndTemp,60));
CTHMM_print_log(str);

% str = sprintf('\n');
% fprintf(str);

tStartTemp = tic;

% for each link, compute n_ij
for i = 1:num_state
    
    str = sprintf('%d...', i);    
    fprintf(str);
            
    for j = 1:num_state
        
        %% reset A matrix
        has_computed_A_series = 0;
        
        %% compute expected transition counts
        if (Q_mat_struct(i, j) == 1)
            
            %str = sprintf('(%d,%d)', i, j);
            %fprintf(str);
                        
            %% set up A
            A(i, j + num_state) = 1;
            
            for t_idx = 1:num_distinct_time
                
                T = distinct_time_list(t_idx);

                if (is_use_fast_expm_At == 1)
                    expm_A = matlab_expm_At(T);
                else
                    expm_A = expm(A * T);
                end
                                
                temp_sum = 0.0;
                for k_idx = 1:num_k_idx
                    k = k_list(k_idx);        
                    for l_idx = 1:num_l_idx
                        l = l_list(l_idx);            
                        
                        if (distinct_time_Pt_list{t_idx}(k,l) ~= 0)                        
                            temp_sum = temp_sum + Etij(t_idx, k, l) * expm_A(k, l + num_state) / distinct_time_Pt_list{t_idx}(k,l) ;
                        end 
                        
                    end
                end

                nij = temp_sum * Q_mat(i, j);

                %% accuomulate count to Nij matrix
                Nij_mat(i, j) = Nij_mat(i, j) + nij;
            end
            
            %% restore    
            A(i, j + num_state) = 0;
            
        end
    end
    
    %str = sprintf('\n');
    %fprintf(str);    
end

tEndTemp = toc(tStartTemp);
str = sprintf('\nCompute all n_ij: time: %d minutes and %f seconds\n', floor(tEndTemp/60),rem(tEndTemp,60));
CTHMM_print_log(str);
