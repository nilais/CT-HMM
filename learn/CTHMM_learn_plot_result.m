function CTHMM_learn_plot_result(run_idx, syn_config_idx, test_method_idx_list)

global all_result;
global method_name_list;
global out_dir;

%marker_list = {'-bo', '-r*', '-ms', '-gd', '-y^'};
%marker_list = {'-bo', '-m*', '--bs', '--md', '-y^', '-gd'};
marker_list = {'-bo', '--bs', '-m*', '--md', '-g<', '--g>'};

fontsize = 20;

%% plot relative 2-norm error
figure,
set(gca,'FontSize',fontsize);

num_test_method = size(test_method_idx_list, 2);
test_method_names = cell(num_test_method+1, 1);
num_iter_list = zeros(num_test_method, 1);

for m = 1:num_test_method
    method = test_method_idx_list(m);
    
    num_iter = all_result{run_idx, syn_config_idx, method}.num_iter;
    num_iter_list(m) = num_iter;
    
    RNORM2E_list = all_result{run_idx, syn_config_idx, method}.RNORM2E_list;
    
    method_name = method_name_list{method};
    test_method_names{m} = method_name;
    plot([1:num_iter], RNORM2E_list, marker_list{m}, 'MarkerSize', 10, 'LineWidth', 2.5);    
    hold on;
end

str = sprintf('Run %d', run_idx);
title(str);

xlabel('Iteration Count');
ylabel('Relative 2-Norm Error');
max_iter = max(num_iter_list);
%set(gca,'XTick', [1:1:max_iter]);
legend(test_method_names(1:num_test_method)); %, 'FontSize', 20

filename = sprintf('%s\\run_%d_compare_rnorm2err_result', out_dir, run_idx);
saveas(gcf, filename, 'png');
%saveas(gcf, filename, 'epsc');

%% plot data likelihood figure

figure,
set(gca,'FontSize',fontsize);

num_iter_list = zeros(2, 1);
for m = 1:num_test_method
%for m = 1:2   
    method = test_method_idx_list(m);
    num_iter = all_result{run_idx, syn_config_idx, method}.num_iter;
    num_iter_list(m) = num_iter;
    complete_log_likelihood_list = all_result{run_idx, syn_config_idx, method}.log_likelihood_list;
    plot([1:num_iter], complete_log_likelihood_list, marker_list{m}, 'MarkerSize', 10, 'LineWidth', 2.5);    
    hold on;
end

%max_iter = max(num_iter_list);
%plot([1:max_iter], ones(max_iter, 1)*groundtruth_total_log_L, '--k', 'MarkerSize', 10, 'LineWidth', 2.5);    
%test_method_names{num_test_method+1} = 'Ground Truth';

legend(test_method_names(1:num_test_method), 'Location','southeast');

%legend(test_method_names(1:num_test_method+1), 'Location','southeast');
%legend(test_method_names([1,2,5]), 'Location','southeast');

str = sprintf('Run %d', run_idx);
title(str);

xlabel('Iteration Count');
ylabel('Log Data-Likelihood');
%set(gca,'XTick', [1:1:max_iter]);

filename = sprintf('%s\\run_%d_compare_likelihood_result', out_dir, run_idx);
saveas(gcf, filename, 'png');
%saveas(gcf, filename, 'epsc');

%% plot time per iteration
run = 0;

if (run == 1)

figure,
set(gca,'FontSize',fontsize);

total_time_list = zeros(num_test_method, 1);
time_per_iter_list = zeros(num_test_method, 1);
for m = 1:num_test_method
    method = test_method_idx_list(m);
    num_iter = all_result{run_idx, syn_config_idx, method}.num_iter;    
    total_time = all_result{run_idx, syn_config_idx, method}.total_time;
    total_time_list(m) = total_time;
    time_per_iter_list(m) = total_time / num_iter;    
end

%% plot total time to convergence
%bar(total_time_list);
bar(1, total_time_list(1), 'b'); hold on;
bar(2, total_time_list(2), 'm'); hold on;
bar(3, total_time_list(3), 'b'); hold on;
bar(4, total_time_list(4), 'm');hold on;

set(gca,'XTick', [1:1:4]);
set(gca,'XTickLabel', method_name_list(1:4), 'FontSize', fontsize);
set(gca,'XTickLabel', method_name_list(1:4));
xlabel('Method');
ylabel('Total Running Time (secs)');
%legend(test_method_names(1:num_test_method));
filename = sprintf('%s\\run%d_compare_totaltime_result', out_dir, run_idx);
saveas(gcf, filename, 'png');
%saveas(gcf, filename, 'epsc');

%% plot time per iteration
figure,
set(gca,'FontSize',fontsize);

%bar_group(1,1) = time_per_iter_list(1);
%bar_group(1,2) = time_per_iter_list(2);
%bar_group(2,1) = time_per_iter_list(3);
%bar_group(2,2) = time_per_iter_list(4);
% bar(time_per_iter_list');
% bar(bar_group);
%set(b(2), 'FaceColor', 'red');
%set(b(4), 'FaceColor', 'red');

bar(1, time_per_iter_list(1), 'b'); hold on;
bar(2, time_per_iter_list(2), 'm'); hold on;
bar(3, time_per_iter_list(3), 'b'); hold on;
bar(4, time_per_iter_list(4), 'm');hold on;

set(gca,'XTick', [1:1:4]);
set(gca,'XTickLabel', method_name_list(1:4), 'FontSize', fontsize);
%set(gca,'XTickLabel', {'Soft-Soft(Expm) vs Soft-Soft(Eigen)', 'Hard-Soft(Expm) vs Hard-Soft(Eigen)'}, 'FontSize', 10);

xlabel('Method');
ylabel('Time Per Iteration (secs)');
%legend(test_method_names(1:num_test_method));
filename = sprintf('%s\\run%d_compare_time_periter_result', out_dir, run_idx);
saveas(gcf, filename, 'png');

%saveas(gcf, filename, 'epsc');
end
