function Q_mat_new = CTHMM_learn_derive_Q_mat_from_Q_para_list(Q_para_list)

global Q_mat_struct;
global state_list;
global Q_mat;
global ori_Q_mat;

Q_mat_new = Q_mat;

num_state = size(Q_mat_struct, 1);

%Q_mat = zeros(num_state, num_state);

cur_para_idx = 0;

for r = 1:num_state
    for c = 1:num_state
        
        %if (Q_mat_struct(r, c) == 1 && ori_Q_mat(r, c) > 0.00001)
        if (Q_mat_struct(r, c) == 1 && ori_Q_mat(r, c) > 0.005)
            
            %if (state_list{r}.mu(1) > 98 && state_list{r}.mu(2) < 105 && state_list{r}.mu(2) > 90)
            %if (state_list{r}.mu(1) >= 100 && state_list{r}.mu(2) < 100 && state_list{r}.mu(2) > 95)
                
                cur_para_idx = cur_para_idx + 1;
                Q_mat_new(r, c) = Q_para_list(cur_para_idx);
                
            %end
            
        end
        
    end
end

for r = 1:num_state
    
    Q_mat_new(r, r) = 0.0;
    Q_mat_new(r, r) = -sum(Q_mat_new(r, :));
    
end



