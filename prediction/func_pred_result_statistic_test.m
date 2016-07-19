function func_pred_result_statistic_test(overall_HMM_abs_err, overall_LR_abs_err, overall_global_LR_abs_err, overall_bayes_LR_abs_err)

global data_setting;

num_dim = data_setting.dim;
overall_num_test = size(overall_HMM_abs_err, 2);
str = sprintf('overall_num_test = %d\n', overall_num_test);
CTHMM_print_log(str);
    
for d = 1:num_dim   
    
    str = sprintf('================================================\n');
    CTHMM_print_log(str);
    
    str = sprintf('DIM = %d\n', d);
    CTHMM_print_log(str);
    
    %% report average error    
    ave_HMM_abs_err = sum(overall_HMM_abs_err(d, :)) / double(overall_num_test);
    std_HMM_abs_err = std(overall_HMM_abs_err(d, :));
    
    ave_LR_abs_err = sum(overall_LR_abs_err(d, :)) / double(overall_num_test);    
    std_LR_abs_err = std(overall_LR_abs_err(d, :));    
    
    ave_global_LR_abs_err = sum(overall_global_LR_abs_err(d, :)) / double(overall_num_test);    
    std_global_LR_abs_err = std(overall_global_LR_abs_err(d, :));
    
    ave_bayes_LR_abs_err = sum(overall_bayes_LR_abs_err(d, :)) / double(overall_num_test);    
    std_bayes_LR_abs_err = std(overall_bayes_LR_abs_err(d, :));
            
    str = sprintf('HMM abs error: %.4f +- %.4f\n', ave_HMM_abs_err, std_HMM_abs_err);
    CTHMM_print_log(str);
    
    str = sprintf('LR abs error: %.4f +- %.4f\n', ave_LR_abs_err, std_LR_abs_err);
    CTHMM_print_log(str);
    
    str = sprintf('Global LR abs error: %.4f +- %.4f\n', ave_global_LR_abs_err, std_global_LR_abs_err);
    CTHMM_print_log(str);
    
    str = sprintf('Bayes LR abs error: %.4f +- %.4f\n\n', ave_bayes_LR_abs_err, std_bayes_LR_abs_err);
    CTHMM_print_log(str);
        
    %% do ttest
    [h,p,ci,stats] = ttest(overall_HMM_abs_err(d, :) - overall_LR_abs_err(d, :))
    str = sprintf('CTHMM vs LR: h = %f, p = %f, ci = %f, %f\n', h, p, ci(1), ci(2));
    CTHMM_print_log(str);
    
    [h,p,ci,stats] = ttest(overall_HMM_abs_err(d, :) - overall_bayes_LR_abs_err(d, :))
    str = sprintf('CTHMM vs bayes LR: h = %f, p = %f, ci = %f, %f\n\n', h, p, ci(1), ci(2));
    CTHMM_print_log(str);
    
end


%% output the overall prediction results
% str = sprintf('%s\\overall_HMM_abs_err', out_dir);
% save(str, 'overall_HMM_abs_err');
% str = sprintf('%s\\overall_LR_abs_err', out_dir);
% save(str, 'overall_LR_abs_err');
% str = sprintf('%s\\overall_oracle_LR_abs_err', out_dir);
% save(str, 'overall_oracle_LR_abs_err');
