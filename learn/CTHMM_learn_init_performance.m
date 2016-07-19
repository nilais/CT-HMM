function CTHMM_learn_init_performance(learn_method, is_outer_soft, max_iter)

global learn_performance;
%global learn_method;
%global is_outer_soft;


learn_performance.method = learn_method;
learn_performance.is_outer_soft = is_outer_soft;

learn_performance.RNORM2E_list = zeros(max_iter, 1);
learn_performance.WRNORM2E_list = zeros(max_iter, 1);
learn_performance.MAE_list = zeros(max_iter, 1);
learn_performance.RMSE_list = zeros(max_iter, 1);

learn_performance.Q_mat_list = cell(max_iter, 1);

learn_performance.num_iter = 0;
learn_performance.log_likelihood_list = zeros(max_iter, 1);

learn_performance.time_precomp_list = zeros(max_iter, 1);
learn_performance.time_outer_list = zeros(max_iter, 1);
learn_performance.time_inner_list = zeros(max_iter, 1);
learn_performance.time_list = zeros(max_iter, 1);
learn_performance.total_time = 0;




