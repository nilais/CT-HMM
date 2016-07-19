function func_visualize_2D_prediction_result()

global state_list;
global state_lookup_table;
global Pr_result;
global data_setting;

figure,

fontsize = 3;

%% find out the max number of test subject in a state
num_state = size(Pr_result, 1);
max_test_subject = 0;
for i = 1:num_state
    num_test_subject = size(Pr_result{i}.dwell_dur_diff, 2);
    if (num_test_subject > max_test_subject)
        max_test_subject = num_test_subject;
    end
end

max_marker_size = 4;
min_marker_size = 4;

%% draw all states and its coordinates
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure               
           
            s  = state_lookup_table(i, j);
            if (s == 0)
                continue;
            end
            
            num_test_dwell = size(Pr_result{s}.dwell_dur_diff, 2);
            num_test_next_move = size(Pr_result{s}.next_s_correct_prob, 2);
            
            if (num_test_dwell == 0 && num_test_next_move == 0)
                continue;
            end
                        
            if (data_setting.draw_origin_lefttop == 1)
                draw_i = i;
                draw_j = -j;
            else
                draw_i = i;
                draw_j = j;
            end
            
            
            
            
            
            if (num_test_next_move > 0)
                
                
                prob = round(mean(Pr_result{s}.next_s_correct_prob)*100);
                str = sprintf('#%d,%d%%', num_test_next_move, prob);
                text(draw_i+0.14,draw_j+0.1, str, 'Color', [0 0 1], 'FontSize', fontsize-1);
                
                
                if (prob >= 60)
                    marker_color = [0 0 1];
                elseif (prob > 33)
                    marker_color = [0 1 0];    
                else                    
                    %marker_color = [1 0 0]; 
                    marker_color = [1 1 1]; 
                end
                
                %range_list = [0.0 100];
                %color_list = [1 0 0; 0 0 1];
                %cur_value = prob;
                %marker_color = utility_find_gradient_color(range_list, color_list, cur_value);
                
                
                marker_size = min_marker_size + double(num_test_subject) / double(max_test_subject) * double(max_marker_size-min_marker_size);
                plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',marker_color,'MarkerSize',marker_size);            
            
                
                prob = round(mean(Pr_result{s}.next_s_correct_prob)*100);
                str = sprintf('#%d,%d%%', num_test_next_move, prob);
                text(draw_i+0.14,draw_j+0.1, str, 'Color', [0 0 1], 'FontSize', fontsize-1);
           
            end
            
                
            % draw prediction information            
            %color = utility_dwelling_time_color(dwell_time);                            
            if (num_test_dwell > 0)
                
                %Pr_result{s}.dwell_dur_diff                
                
                %str = sprintf('#%d,%.1f+-%.1f', num_test_dwell, mean(Pr_result{s}.dwell_dur_diff), std(Pr_result{s}.dwell_dur_diff));
                str = sprintf('#%d,%.1f yr', num_test_dwell, mean(Pr_result{s}.dwell_dur_diff));
                text(draw_i+0.14,draw_j+0.25, str, 'FontSize', fontsize-1, 'Color', [0 0 0]);            
            end
            
            
            hold on;            
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis equal;

if (data_setting.draw_origin_lefttop == 1)
    xlim([(0-2) (data_setting.dim_state_num_ls(1)+1)]);
    ylim([(-data_setting.dim_state_num_ls(2)-1) (0+2)]);
else
    xlim([(0-2) (data_setting.dim_state_num_ls(1)+1)]);
    ylim([(0-2) (data_setting.dim_state_num_ls(2)+1)]);    
end

%% draw state definition
for i = 1:data_setting.dim_state_num_ls(1) % dim1:x
    if ((data_setting.dim_value_range_ls{1}(i) - floor(data_setting.dim_value_range_ls{1}(i))) > 0)
        label = sprintf('[%.1f-%.1f]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i,0+0.5,label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize-1);
    else
        label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i,0+0.5,label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize);
    end
end
for i = 1:data_setting.dim_state_num_ls(2) % dim2:y
    label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{2}(i), data_setting.dim_value_range_ls{2}(i+1));
    if (data_setting.draw_origin_lefttop == 1)
        text(-1, -i, label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize);    
    else
        text(-1, i, label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize);    
    end
end

