function Q_para_list = CTHMM_learn_derive_Q_para_list_from_Q_mat(Q_mat)

global ori_Q_mat;
global Q_mat_struct;
global state_list;

global target_qij_Qpara_idx;

num_state = size(Q_mat_struct, 1);
Q_para_list = zeros(num_state * num_state, 1);

cur_para_idx = 0;

for r = 1:num_state
    for c = 1:num_state
        
        %if (Q_mat_struct(r, c) == 1 && ori_Q_mat(r, c) > 0.00001)
        if (Q_mat_struct(r, c) == 1 && ori_Q_mat(r, c) > 0.005)
            
            %if (state_list{r}.mu(1) > 98 && state_list{r}.mu(2) < 105 && state_list{r}.mu(2) > 90)
            
            %if (state_list{r}.mu(1) >= 100 && state_list{r}.mu(2) < 100 && state_list{r}.mu(2) > 95)
                
                cur_para_idx = cur_para_idx + 1;
                Q_para_list(cur_para_idx) = Q_mat(r, c);

                if (r == 8 && c == 28)
                    target_qij_Qpara_idx = cur_para_idx;
                end

                
            %end
            
            
        end
        
    end
end

Q_para_list = Q_para_list(1:cur_para_idx);