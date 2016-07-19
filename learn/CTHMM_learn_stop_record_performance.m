function CTHMM_learn_stop_record_performance()

global learn_performance;

num_iter = learn_performance.num_iter;

learn_performance.RNORM2E_list = learn_performance.RNORM2E_list(1:num_iter);
learn_performance.WRNORM2E_list = learn_performance.WRNORM2E_list(1:num_iter);
learn_performance.MAE_list = learn_performance.MAE_list(1:num_iter);
learn_performance.RMSE_list = learn_performance.RMSE_list(1:num_iter);
learn_performance.Q_mat_list = learn_performance.Q_mat_list(1:num_iter);

learn_performance.time_precomp_list = learn_performance.time_precomp_list(1:num_iter);
learn_performance.time_outer_list = learn_performance.time_outer_list(1:num_iter);
learn_performance.time_inner_list = learn_performance.time_inner_list(1:num_iter);
learn_performance.time_list = learn_performance.time_list(1:num_iter);

if (learn_performance.is_outer_soft == 1)
    learn_performance.log_likelihood_list = learn_performance.log_likelihood_list(1:num_iter);
else
    learn_performance.log_likelihood_list = learn_performance.log_likelihood_list(1:num_iter);
end

