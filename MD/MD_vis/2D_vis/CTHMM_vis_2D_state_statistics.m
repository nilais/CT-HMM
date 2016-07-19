function CTHMM_vis_2D_state_statistics(top_out_folder)

global state_list;
global data_setting;

num_state = size(state_list, 1);

figure,
face_color = [0 1 0];
fontsize = 5;
max_marker_size = 14;
min_marker_size = 2;
x_pos_scale = 2;
y_pos_scale = 1;

Ni_list = zeros(num_state, 1);
for s = 1:num_state
    Ni = state_list{s}.raw_data_count;
    Ni_list(s) = Ni;
end
max_Ni = max(Ni_list);
max_Ni


for s = 1:num_state
    
    Ni = state_list{s}.raw_data_count;
    
    % proportional based on data count        
    marker_size = min_marker_size + double(Ni) / double(max_Ni) * double(max_marker_size - min_marker_size);
      
    % draw state position
    if (data_setting.draw_origin_lefttop == 1)
        draw_i = state_list{s}.dim_states(1) * x_pos_scale;
        draw_j = -state_list{s}.dim_states(2) * y_pos_scale;
    else
        draw_i = state_list{s}.dim_states(1) * x_pos_scale;
        draw_j = state_list{s}.dim_states(2) * y_pos_scale;
    end
    
    %% plot size
    plot(draw_i, draw_j, 'ro','MarkerEdgeColor', 'k', 'MarkerFaceColor', face_color, 'MarkerSize', marker_size);
        
    %% write text: number of raw data set
    label = sprintf('#%d', Ni);
    text(draw_i+0.1, draw_j+0.2, label, 'Color', [0 0 1], 'FontSize', 5);
    hold on;            
end

%% draw axis label
type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});
axis equal;
%title(train_group_name);

if (data_setting.draw_origin_lefttop == 1)
    xlim([0 (data_setting.dim_state_num_ls(1) * x_pos_scale + 1)]);
    ylim([(-data_setting.dim_state_num_ls(2) * y_pos_scale - 1) 0]);
else
    xlim([0 (data_setting.dim_state_num_ls(1) * x_pos_scale + 1)]);
    ylim([0 (data_setting.dim_state_num_ls(2) * y_pos_scale + 1)]);    
end

%% draw state definition
color = [0.0 0.0 0.8];
for i = 1:data_setting.dim_state_num_ls(1) % dim1:x
    if ((data_setting.dim_value_range_ls{1}(i) - floor(data_setting.dim_value_range_ls{1}(i))) > 0)
        label = sprintf('[%.1f-%.1f]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i * x_pos_scale, 0 + 0.5 ,label, 'Color', color, 'FontSize',fontsize);
    else
        label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i * x_pos_scale, 0 + 0.5, label, 'Color', color, 'FontSize',fontsize);
    end
end
for i = 1:data_setting.dim_state_num_ls(2) % dim2:y
    
    label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{2}(i), data_setting.dim_value_range_ls{2}(i+1));
    %label = sprintf('[%.2f-%.2f]', data_setting.dim_value_range_ls{2}(i), data_setting.dim_value_range_ls{2}(i+1));    
    if (data_setting.draw_origin_lefttop == 1)
        text(0.20, -i * y_pos_scale, label, 'Color', color, 'FontSize', fontsize);    
    else
        text(0.20, i * y_pos_scale, label, 'Color', color, 'FontSize', fontsize);   
    end
end


%% save files
global out_dir;

filename = sprintf('%s\\vis_state_raw_data_count', out_dir);
saveas(gcf, filename, 'png');
close(gcf);
    