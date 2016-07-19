function [gm_list, mean_sigma, std_sigma] = func_train_Bayes_prior_model(train_idx_list, is_joint_inference)

global data_setting;
global obs_seq_list;
global fp_log;

num_gaussian_mix = 1;
num_dim = data_setting.dim;
gm_list = cell(num_dim, 1);

%% gather the global regression parameters from training eyes
num_train_idx = size(train_idx_list, 1);
X = zeros(num_train_idx, num_dim * 2);
sigma_list = zeros(num_dim, num_train_idx);

for s = 1:num_train_idx
   train_idx = train_idx_list(s);       
   subject_data = obs_seq_list{train_idx};      
   
   for d = 1:num_dim
        X(s,(d-1)*2+1) = subject_data.global_LR_regress(d, 1); % dim d, intercept
        X(s,(d-1)*2+2) = subject_data.global_LR_regress(d, 2); % dim d, slope
   end
   sigma_list(:, s) = subject_data.global_LR_err_sigma_vec;
end

%% compute sigma from the training set
mean_sigma = zeros(num_dim, 1);
std_sigma = zeros(num_dim, 1);
for d = 1:num_dim
    mean_sigma(d) = mean(sigma_list(d, :));    
    std_sigma(d) = std(sigma_list(d, :));
    fprintf(fp_log, 'dim = %d, mean sigma = %.4f +- %.4f\n', d, mean_sigma(d), std_sigma(d));        
end

%% compute the prior model parameter  
if (is_joint_inference == 1)
    gm_list{1} = gmdistribution.fit(X, num_gaussian_mix);    
else
    for d = 1:num_dim
        idx1 = (d-1)*2+1;
        idx2 = (d-1)*2+2;        
        gm_list{d} = gmdistribution.fit(X(:, idx1:idx2) , num_gaussian_mix);
    end
end
