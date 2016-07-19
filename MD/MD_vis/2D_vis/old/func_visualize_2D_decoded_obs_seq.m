function [subject_data] = func_visualize_2D_decoded_obs_seq(subject_data, out_filename)

figure,

type_name_ls = {'VFI', 'RNFL'};

num_visit = subject_data.num_visit;
visit_list = subject_data.visit_list;

%% set up T_ls
T_ls = zeros(num_visit, 1);
t0 = double(visit_list{1}.month) / 12.0;
for v = 1:num_visit
    t = double(visit_list{v}.month) / 12.0; % in year
    T_ls(v) = t - t0;
end    

%% set up data_ls
first5v_regress = zeros(2, 2);
allv_regress = zeros(2, 2);
set(gca, 'FontSize', 10);

for i = 1:2
    
    data_ls = zeros(num_visit, 1);    
    for v = 1:num_visit        
        data = visit_list{v}.data(i);
        data_ls(v) = data;
    end    
    %% set the subplot location
    subplot(2, 1, i);
    
    %% draw all data points
    scatter(T_ls, data_ls, 90, 'filled', 'MarkerFaceColor', 'm');
    hold on;   
        
    %% draw regress line for the first 5 visits
    if (num_visit < 5)
        first_k = num_visit;
    else
        first_k = 5;
    end    
    x = T_ls(1:first_k);
    y = data_ls(1:first_k);
    bls = regress(y, [ones(first_k, 1) x]);
    first5v_regress(i, 1) = bls(1);  % intercept
    first5v_regress(i, 2) = bls(2);  % slope
    plot(x, bls(1)+bls(2) * x, 'm', 'LineWidth', 2);    
    hold on;
    
    subject_data.first5v_regress = first5v_regress;
    
    
%     if (num_visit > 3)
%     brob = robustfit(x,y);
%     plot(x, brob(1)+brob(2) * x, 'g', 'LineWidth', 2);
%     hold on;
%     end
    
    %% draw regress line for all data
    x = T_ls;
    y = data_ls;
    bls = regress(y, [ones(num_visit, 1) x]);
    allv_regress(i, 1) = bls(1);
    allv_regress(i, 2) = bls(2);    
    plot(x, bls(1)+bls(2) * x, 'r', 'LineWidth', 2);
    
    subject_data.allv_regress = allv_regress;
    
    hold on;
%     
%     if (num_visit > 3)
%     brob = robustfit(x,y);
%     plot(x, brob(1)+brob(2) * x, 'c', 'LineWidth', 2);
%     end
    
    hold on;
    
    %% compute OLS prediction error
    sum_abs_error = 0;
    sum_squared_error = 0;
    ave_abs_error = 0;
    num_test_pred = 0;
    
    if (num_visit > 5)     
        
        
        for v = 6:num_visit
            x = T_ls(v);
            
            bls(1) = first5v_regress(i, 1);
            bls(2) = first5v_regress(i, 2);             
            pred_y = bls(1) + bls(2) * x;
            
            true_y = data_ls(v);
            abs_error = abs(pred_y - true_y);            
            squared_error = (pred_y - true_y)^2;
            
            sum_abs_error = sum_abs_error + abs_error;
            sum_squared_error = sum_squared_error + squared_error;
            
        end  
        
        num_test_pred = num_visit - 6 + 1;
        ave_abs_error = double(sum_abs_error) / double(num_test_pred);        
    end
    
    %% draw axis label and title
        
    xlabel('Year');
    ylabel(type_name_ls{i});
    
    if (num_visit > 5) 
        str = sprintf('%s,%s, age=%.1f [slope:%.2f(5v), %.2f(allv)][pred err = %.2f]', ...
            subject_data.visit_list{1}.Dx{1}, subject_data.visit_list{end}.Dx{1}, subject_data.visit_list{1}.age, first5v_regress(i, 2), allv_regress(i, 2), ave_abs_error);    
            %subject_data.visit_list{1}.Dx, subject_data.visit_list{end}.Dx, subject_data.visit_list{1}.age, first5v_regress(i, 2), allv_regress(i, 2), ave_abs_error);
            
    else
        str = sprintf('[slope:%.2f(5v), %.2f(allv)]',first5v_regress(i, 2), allv_regress(i, 2));
    end
    title(str);    
        
end

%% draw the decoded observation list
num_instant_visit = size(subject_data.instant_state_seq, 2);

for d = 1:2

    obs_ls = zeros(num_instant_visit, 1);    
    T_ls = zeros(num_instant_visit, 1);
    
    for v = 1:num_instant_visit
        obs = subject_data.decoded_instant_obs_seq(d, v);
        obs_ls(v) = obs;
        if (v >= 2)
            T_ls(v) = sum(subject_data.instant_dur_seq(1:v-1));
        end
    end    
    %% set the subplot location
    subplot(2, 1, d);
    
    %% draw all data points
    scatter(T_ls, obs_ls, 90, 'd', 'MarkerEdgeColor', 'b', 'LineWidth', 2);
    hold on;   
    
    %% draw regress line
    x = T_ls;
    y = obs_ls;
    bls = regress(y, [ones(num_instant_visit, 1) x]);
    allv_regress(i, 1) = bls(1);
    allv_regress(i, 2) = bls(2);    
    
    plot(x, bls(1)+bls(2) * x, 'b', 'LineWidth', 2);
    
    %plot(x(1:5), bls(1)+bls(2) * x(1:5), 'b', 'LineWidth', 2);        
    %plot(x(5:end), bls(1)+bls(2) * x(5:end), '--', 'LineWidth', 2);        
    

end

hold off;

saveas(gcf, out_filename, 'png');
close(gcf);
