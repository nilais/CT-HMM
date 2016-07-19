function [norm2_rela_Q_err, w_norm2_rela_Q_err, mean_Q_abs_err, root_mean_squared_err] = CTHMM_learn_compute_Qmat_learn_accuracy(learned_Q_mat, syn_Q_mat)

global Q_mat_struct;
global syn_Nrs_mat;

num_para = sum(Q_mat_struct(:));

%% compute accuracy for Q_mat
num_state = size(learned_Q_mat, 1);
Q_diff_mat = abs(learned_Q_mat - syn_Q_mat);

%% compute weight mat
weight_mat = syn_Nrs_mat;
for i = 1:num_state
    Q_diff_mat(i, i) = 0;    
end

%% compute weighted Q abs error
D = diag(weight_mat);
state_weight = D / sum(D);

%% compute 2-norm error
learned_q_vec = zeros(num_para, 1);
syn_q_vec = zeros(num_para, 1);

w_learned_q_vec = zeros(num_para, 1);
w_syn_q_vec = zeros(num_para, 1);

cur_para = 0;
for i = 1:num_state
    for j = 1:num_state
        if (Q_mat_struct(i,j) == 1)
            
            cur_para = cur_para + 1;
            learned_q_vec(cur_para) = learned_Q_mat(i,j);
            syn_q_vec(cur_para) = syn_Q_mat(i,j);
            
            w_learned_q_vec(cur_para) = learned_Q_mat(i,j) * state_weight(i);
            w_syn_q_vec(cur_para) = syn_Q_mat(i,j) * state_weight(i);            
        end
    end
end

norm2_rela_Q_err = norm(learned_q_vec - syn_q_vec) / norm(syn_q_vec);
w_norm2_rela_Q_err = norm(w_learned_q_vec - w_syn_q_vec) / norm(w_syn_q_vec);

%% compute average Q abs error
sum_abs_diff = sum(Q_diff_mat(:));
mean_Q_abs_err = sum_abs_diff / double(num_para);

%% compute mean squared err
sum_squared_err = 0.0;
for i = 1:num_state
    for j = 1:num_state
        sum_squared_err = sum_squared_err + Q_diff_mat(i,j)^2;
    end
end
root_mean_squared_err = sqrt(sum_squared_err / num_para);

