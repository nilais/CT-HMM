function [total_neg_log_L] = func_CTHMM_total_neg_log_L(target_qij)

global fp_log;
global Q_mat;

%% compute current Q_mat
global qij_i_idx;
global qij_j_idx;

Q_mat(qij_i_idx, qij_j_idx) = target_qij;
Q_mat(qij_i_idx, qij_i_idx) = 0.0;
row_sum = sum(Q_mat(qij_i_idx, :));
Q_mat(qij_i_idx, qij_i_idx) = -row_sum;

%% precompute Pij matrix
CTHMM_compute_distinct_time_Pt_list();
CTHMM_batch_compute_data_emission_prob(train_idx_list);

%% compute likelihood
[total_log_L] = CTHMM_compute_complete_log_likelihood_matrixexp();
total_neg_log_L = -total_log_L;

%% output log
str = sprintf(fp_log, 'eval # = %d, total_neg_log_L = %.10f, qij = %.10f\n', fminunc_eval_count, total_neg_log_L, target_qij);
CTHMM_print_log(str);
