function Q_mat_init = CTHMM_learn_init_Q_mat(init_ave_state_dwell_year, is_add_random_perturb, perturb_amount)

global Q_mat_struct;
num_state = size(Q_mat_struct, 1);
Q_mat_init = zeros(num_state, num_state);

num_para = sum(Q_mat_struct(:));
str = sprintf('num of para = %d\n', num_para);
CTHMM_print_log(str);

%% initialize Q
for r = 1:num_state
    
    num_target_states = sum(Q_mat_struct(r, :));
    
    if (num_target_states > 0)
    
        esti_qrs = 1.0 / init_ave_state_dwell_year / num_target_states;
        
        for s = 1:num_state
            if (Q_mat_struct(r, s) == 1)
                
                if (is_add_random_perturb == 1)
                    Q_mat_init(r, s) = esti_qrs + rand() * perturb_amount;
                else
                    Q_mat_init(r, s) = esti_qrs;
                end
                
            end        
        end        
        Q_mat_init(r, r) = - sum(Q_mat_init(r, :));    
    end    
end


[U,D]=eig(Q_mat_init);
disp('matrix info')
D_sorted = sort(diag(D));
D_diff = D_sorted(2:end)-D_sorted(1:end-1);
min(D_diff)
cond(U)
istril(Q_mat_init)
istriu(Q_mat_init)