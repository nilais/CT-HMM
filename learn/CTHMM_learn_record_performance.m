function CTHMM_learn_record_performance()

global Q_mat;
global syn_Q_mat;
global model_iter_count;
global learn_performance;
global cur_all_subject_prob;
global learn_is_know_ground_truth_Q_mat;
global out_dir;
global learn_method;
global is_use_individual_Q_mat;
global base_Q_mat;
global syn_base_Q_mat;
global syn_covariate_w_list;
global covariate_w_list;

i = model_iter_count;

if (learn_is_know_ground_truth_Q_mat == 1)
    
    if (is_use_individual_Q_mat == 0)
        [norm2_rela_err, w_norm2_rela_err, mean_Q_abs_err, root_mean_squared_err] = CTHMM_learn_compute_Qmat_learn_accuracy(Q_mat, syn_Q_mat);
        learn_performance.Q_mat_list{i} = Q_mat;
    else
        [norm2_rela_err, w_norm2_rela_err, mean_Q_abs_err, root_mean_squared_err] = CTHMM_learn_compute_Qmat_learn_accuracy(base_Q_mat, syn_base_Q_mat);
        learn_performance.Q_mat_list{i} = base_Q_mat;
    end
    str = sprintf('norm2_rela_err = %.4f, w_norm2_rela_err = %.4f, mean_Q_abs_err = %.4f, root_mean_squared_err = %.4f\n', norm2_rela_err, w_norm2_rela_err, mean_Q_abs_err, root_mean_squared_err);
    CTHMM_print_log(str);    
    learn_performance.RNORM2E_list(i) = norm2_rela_err;
    learn_performance.WRNORM2E_list(i) = w_norm2_rela_err;
    learn_performance.MAE_list(i) = mean_Q_abs_err;
    learn_performance.RMSE_list(i) = root_mean_squared_err;
    
    if (is_use_individual_Q_mat == 1)
        cov_weight_norm2_rela_err = norm(covariate_w_list - syn_covariate_w_list) / norm(syn_covariate_w_list);
        learn_performance.COV_W_RNORM2E_list(i) = cov_weight_norm2_rela_err;
        str = sprintf('covariate weight norm2_rela_err = %.4f\n', cov_weight_norm2_rela_err);
        CTHMM_print_log(str); 
    end
    
end


learn_performance.num_iter = i;
learn_performance.log_likelihood_list(i) = cur_all_subject_prob;
str = sprintf('cur_all_subject_prob = %f\n', cur_all_subject_prob);
CTHMM_print_log(str);

%% plot data likelihood figure
figure,
fontsize = 20;
set(gca,'FontSize',fontsize);
plot([1:i], learn_performance.log_likelihood_list(1:i), '-bo', 'MarkerSize', 10, 'LineWidth', 2.5);
xlabel('Iteration Count');
ylabel('Log Data-Likelihood');
filename = sprintf('%s/iter_%d_likelihood_result', out_dir, i);
saveas(gcf, filename, 'png');
close(gcf);

global unif_M_list;
global distinct_time_list;
num_distinct_time = size(distinct_time_list, 1);

%% if is unif method, output information about M
if (learn_method == 2) % unif
    if (num_distinct_time > 1)
        str = sprintf('\nUnif M = %.2f +- %.2f\n', mean(unif_M_list), std(unif_M_list));
        CTHMM_print_log(str);
    end
end    
