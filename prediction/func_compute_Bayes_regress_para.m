function [bayes_regress] = func_compute_Bayes_linear_regress_para(subject_data, begin_visit_idx, end_visit_idx, time_origin_idx)

global Y_data;
global X_data;

num_hist_visit = end_visit_idx - begin_visit_idx + 1;

Y_data = zeros(num_dim, num_hist_visit);
X_data = zeros(num_dim, num_hist_visit);
for d = 1:num_dim
    for h = 1:num_hist_visit
        v = begin_visit_idx + h - 1; 
        Y_data(d, v) = subject_data.ori_obs_seq(d, v);
        X_data(d, v) = subject_data.ori_obs_time_seq(v);
    end
end

[regress_para] = func_compute_linear_regress_para(subject_data, begin_visit_idx, end_visit_idx, time_origin_idx);
beta_vec_init = zeros(num_dim, 1);
 for d = 1:num_dim
    beta_vec_init((d-1)*2+1) = regress_para(d, 1);
    beta_vec_init((d-1)*2+2) = regress_para(d, 2);           
 end
 
bayes_beta_vec = fminunc(@func_optimize_Bayes_regress_para, beta_vec_init);

bayes_regress = zeros(num_dim, 2);
for d = 1:num_dim
    bayes_regress(d, 1) = bayes_beta_vec((d-1)*2+1);
    bayes_regress(d, 2) = bayes_beta_vec((d-1)*2+2);
end    

