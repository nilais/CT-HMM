function CTHMM_sim_report_learn_result(all_result, test_method_list, syn_data_config_list, run_list)


str = sprintf('\n===== Report average learning result =====\n');
CTHMM_print_log(str);
        
global method_name_list;

num_test_method = size(test_method_list, 1);
num_syn_config = size(syn_data_config_list, 1);
num_run = size(run_list, 1);

%% compute average result from all random runs
for m = 1:num_test_method   
    method = test_method_list(m);    
    if (method == 0) % ground truth
        continue;
    end    
    method_name = method_name_list{method};        
    str = sprintf('===== Method %d: %s =====\n', method, method_name);
    CTHMM_print_log(str);
    
    for s = 1:num_syn_config              
        syn_config_idx = syn_data_config_list(s);        
        str = sprintf('=== syn config = %d, num_run = %d ===\n', syn_config_idx, num_run);
        CTHMM_print_log(str);

        %% compute the relative error
        norm2_err_list = zeros(num_run, 1);
        w_norm2_err_list = zeros(num_run, 1);        
        for r = 1:num_run
            run_idx = run_list(r);        
            norm2_err_list(r) = all_result{run_idx, syn_config_idx, method}.RNORM2E_list(end); %% retrieve the result at the last iteration
            w_norm2_err_list(r) = all_result{run_idx, syn_config_idx, method}.WRNORM2E_list(end);
        end
        str = sprintf('ave_norm2_err = %f, std_norm2_err = %f\n', mean(norm2_err_list), std(norm2_err_list));
        CTHMM_print_log(str);   
        str = sprintf('ave_w_norm2_err = %f, std_w_norm2_err = %f\n', mean(w_norm2_err_list), std(w_norm2_err_list));
        CTHMM_print_log(str); 
        
        %% output the results of average timing/per iteration
        %fix run index = 1;
        run_idx = run_list(1);
        str = sprintf('Report running time for run index = %d\n', run_idx);
        CTHMM_print_log(str);
        
        cur_result = all_result{run_idx, syn_config_idx, method};       
        ave_time_precomp = mean(cur_result.time_precomp_list(:));
        ave_time_outer = mean(cur_result.time_outer_list(:));
        ave_time_inner = mean(cur_result.time_inner_list(:));
        ave_iter_time = mean(cur_result.time_list(:));        
        str = sprintf('ave time in precmp = %f, in outer = %f, in inner = %f, itertime = %f\n', ave_time_precomp, ave_time_outer, ave_time_inner, ave_iter_time);        
        CTHMM_print_log(str);
        str = sprintf('num iter = %d, total learn time = %f\n', cur_result.num_iter, cur_result.total_time);        
        CTHMM_print_log(str);

    end
end