function [regress_para, err_sigma_vec] = func_compute_linear_regress_para(subject_data, begin_visit_idx, end_visit_idx, time_origin_idx)

global data_setting;

num_visit = end_visit_idx - begin_visit_idx + 1;
T_ls = zeros(num_visit, 1);
data_ls = zeros(num_visit, 1);

dim = data_setting.dim;
regress_para = zeros(dim, 2);
err_sigma_vec = zeros(dim, 1);

for d = 1:dim

    for i = 1:num_visit
        v = begin_visit_idx + i -1;
        T_ls(i) = subject_data.visit_list{v}.time - subject_data.visit_list{time_origin_idx}.time;
        data_ls(i) = subject_data.visit_list{v}.data(d);
    end

    bls = regress(data_ls, [ones(num_visit, 1) T_ls]);

    regress_para(d, 1) = bls(1);  % intercept
    regress_para(d, 2) = bls(2);  % slope       
    
    % compute residual error    
    residual_sum_square = 0;    
    for i = 1:num_visit
        error = data_ls(i) - (bls(1) + bls(2) * T_ls(i));        
        residual_sum_square = residual_sum_square + error^2;        
    end    
    err_sigma_vec(d) = sqrt(residual_sum_square / double(num_visit));
    
end
