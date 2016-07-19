function [overall_neg_log] = func_optimize_Bayes_linear_regress_para(beta_vec)

%% arguments: Y, X, beta, gm
global Y_data;  % data at y axis
global X_data;  % time at x axis
global data_setting;
global LR_sigma_vec;

global bayes_prior_model;
global bayes_mean_sigma;

num_dim = data_setting.dim;
beta_mat = zeros(num_dim, 2);
for d = 1:num_dim
    beta_mat(d, 1) = beta_vec((d-1)*2+1);
    beta_mat(d, 2) = beta_vec((d-1)*2+2);
end

num_data = size(Y_data, 2);
dim_log_likelihood_term = zeros(2, 1);
log_likelihood_term = 0.0;

for d = 1:num_dim
    
    residual_sum_square = 0;    
    for n = 1:num_data            
        error = Y_data(d, n) - (beta_mat(d, 1) + beta_mat(d, 2) * X_data(d, n));        
        residual_sum_square = residual_sum_square + error^2;        
    end    
    %sigma_square_vec(d) = residual_sum_square / double(num_data);    
    %dim_log_likelihood_term(d) = residual_sum_square * (- 1.0) / (2.0 * sigma_square_vec(d)) - num_data * log(sqrt(sigma_square_vec(d)));
    
    dim_log_likelihood_term(d) = residual_sum_square / (-2.0 * bayes_mean_sigma(d)) - num_data * log(sqrt(bayes_mean_sigma(d)));
    
    %if (LR_sigma_vec(d) == 0)
    %    LR_sigma_vec(d) = 0.01;
    %end    
    %dim_log_likelihood_term(d) = residual_sum_square / (-2.0 * LR_sigma_vec(d)) - num_data * log(sqrt(LR_sigma_vec(d)));    
    
    
    log_likelihood_term = log_likelihood_term + dim_log_likelihood_term(d);
    
end

log_prior_term = log(pdf(bayes_prior_model{1}, beta_vec(1:end)));
log_posterior_term = log_likelihood_term + log_prior_term;

overall_neg_log = - log_posterior_term;
