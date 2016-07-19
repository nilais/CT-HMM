function CTHMM_vis_2D_Q_mat(top_out_folder, is_vis_nij, vis_threshold, is_draw_text)

global state_list;
global Q_mat_struct;
global Q_mat;
global data_setting;
%global train_group_name;

global Nij_mat;

figure,

%% draw setting
fontsize = 5;

max_marker_size = 14;
min_marker_size = 2;
max_line_thick = 5;
min_line_thick = 0.25;

x_pos_scale = 2;
y_pos_scale = 1;
x_pos_offset = 1;
y_pos_offset = -1.5;

%% plot transition intensity (qrs) at each arrow
num_state = size(state_list, 1);

if (is_vis_nij == 1)
    vis_mat = Nij_mat;
else
    vis_mat = Q_mat;
end

temp_mat = vis_mat;
for s = 1:num_state
    temp_mat(s,s) = 0;
end
max_vis_ij = max(temp_mat(:));

%% plot nij or qij link
for m = 1:num_state
    
    sum_link = sum(Q_mat_struct(m, :));    
    if (sum_link == 0)
        continue;
    end
        
    vis_row = vis_mat(m, :);
    vis_row(1, m) = 0;    
    [C, temp] = max(vis_row); % max value in vis row
        
    for n = 1:num_state
        
        if (Q_mat_struct(m, n) == 1)
            
            if (is_vis_nij == 1 && vis_mat(m, n) < vis_threshold)
                continue;
            end
            
            % dimension index
            m_states = state_list{m}.dim_states;
            n_states = state_list{n}.dim_states;
            
            %% draw link position
            x = (m_states(1) + n_states(1))/2.0 * x_pos_scale + x_pos_offset;
            y = (m_states(2) + n_states(2))/2.0 * y_pos_scale + y_pos_offset;                
            
            infov = vis_mat(m, n);
            if (is_vis_nij == 1) % expected count
                draw_info = sprintf('#%.1f', infov);
            else % transition rate
                draw_info = sprintf('%.2f', infov);  
            end  
            
            %% draw links
            if (vis_mat(m, n) == C && C > 0)  % the strongest link
                line_color = [0 0 1]; % draw blue link
                line_pattern = 'b';
            else
                line_color = [0 0 0]; % draw black link
                line_pattern = '--k';
            end
            
            line_width = min_line_thick + double(infov) / double(max_vis_ij) * double(max_line_thick - min_line_thick);
            if (data_setting.draw_origin_lefttop == 1)
                plot([m_states(1) n_states(1)].* x_pos_scale + x_pos_offset, [-m_states(2) -n_states(2)].* y_pos_scale + y_pos_offset, line_pattern,  'LineWidth', line_width, 'color', line_color);
            else
                plot([m_states(1) n_states(1)].* x_pos_scale + x_pos_offset, [m_states(2) n_states(2)].* y_pos_scale + y_pos_offset, line_pattern,  'LineWidth', line_width, 'color', line_color);
            end            
            hold on;
                        
            %% draw info text                                  
%             if (data_setting.draw_origin_lefttop == 1)
%                 text(x+0.1, -y+0.15, draw_info, 'Color', [0 0.5 0], 'FontSize', fontsize);
%             else
%                 text(x+0.1, y+0.15, draw_info, 'Color', [0 0.5 0], 'FontSize', fontsize);
%             end
            hold on;
                        
        end % if
    end % n
end

%% draw all states
Ni_list = diag(Nij_mat);

min_Ni = min(Ni_list);
max_Ni = max(Ni_list);

for m = 1:num_state
        
    Ni = Ni_list(m);
    
    if (Ni < vis_threshold)
        continue;
    end
    
    % proportional based on data count        
    marker_size = min_marker_size + double(Ni - min_Ni) / double(max_Ni - min_Ni) * double(max_marker_size - min_marker_size);
    
    % plot dwelling time
    dwell_time = 1 / -Q_mat(m, m); % month
    dwell_time = dwell_time / 12.0; % month to year unit
    
    % draw state position
    if (data_setting.draw_origin_lefttop == 1)
        draw_i = state_list{m}.dim_states(1) * x_pos_scale + x_pos_offset;
        draw_j = -state_list{m}.dim_states(2) * y_pos_scale + y_pos_offset;
    else
        draw_i = state_list{m}.dim_states(1) * x_pos_scale + x_pos_offset;
        draw_j = state_list{m}.dim_states(2) * y_pos_scale + y_pos_offset;
    end
    
    %% plot dwelling time and state size
    if (dwell_time == inf || dwell_time == -inf)
        plot(draw_i, draw_j, 'ro', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [1.0 1.0 1.0], 'MarkerSize', marker_size);   
    else
        color = CTHMM_vis_compute_dwell_time_color(dwell_time);
        plot(draw_i, draw_j, 'ro','MarkerEdgeColor', 'k', 'MarkerFaceColor', color, 'MarkerSize', marker_size);
    end
    
    if (is_draw_text == 1)    
        %% write text: dwell time
        if (dwell_time > 100)
            str = sprintf('>100');
        else
            str = sprintf('%.2f', dwell_time);
        end
        
        % write dwell time
        text(draw_i+0.2,draw_j-0.1, str, 'FontSize', 5, 'Color', [0 0 0]);

        %% write text: number of expected visits E(Ni)
        label = sprintf('#%.1f', Ni);
        text(draw_i+0.1, draw_j+0.2, label, 'Color', [0 0 1], 'FontSize', 5);
        hold on;
    end
            
end

%% draw link texts
if (is_draw_text == 1)  
    
%% plot nij or qij link
for m = 1:num_state
    
    sum_link = sum(Q_mat_struct(m, :));    
    if (sum_link == 0)
        continue;
    end
        
    vis_row = vis_mat(m, :);
    vis_row(1, m) = 0;    
    [C, temp] = max(vis_row); % max value in vis row
        
    for n = 1:num_state
        
        if (Q_mat_struct(m, n) == 1)
            
            if (is_vis_nij == 1 && vis_mat(m, n) < vis_threshold)
                continue;
            end
            
            % dimension index
            m_states = state_list{m}.dim_states;
            n_states = state_list{n}.dim_states;
            
            %% draw link position
            x = (m_states(1) + n_states(1))/2.0 * x_pos_scale + x_pos_offset;
                        
            infov = vis_mat(m, n);
            if (is_vis_nij == 1) % expected count
                draw_info = sprintf('#%.1f', infov);
            else % transition rate
                draw_info = sprintf('%.2f', infov);  
            end  
                        
            %% draw info text                                  
            if (data_setting.draw_origin_lefttop == 1)
                y = (-m_states(2) -n_states(2))/2.0 * y_pos_scale + y_pos_offset;                
            else
                y = (m_states(2) + n_states(2))/2.0 * y_pos_scale + y_pos_offset;                
            end
            text(x+0.1, y+0.15, draw_info, 'Color', [0 0.5 0], 'FontSize', fontsize);
            
            hold on;
                        
        end % if
    end % n
end
end

%% draw axis label
type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});
axis equal;
%title(train_group_name);

if (data_setting.draw_origin_lefttop == 1)
    xlim([0 (data_setting.dim_state_num_ls(1) * x_pos_scale + 1 + x_pos_offset * 2)]);
    ylim([(-data_setting.dim_state_num_ls(2) * y_pos_scale - 1 + y_pos_offset * 2) 0]);
else
    xlim([0 (data_setting.dim_state_num_ls(1) * x_pos_scale + 1 + x_pos_offset * 2)]);
    ylim([0 (data_setting.dim_state_num_ls(2) * y_pos_scale + 1 + y_pos_offset * 2)]);    
end

%% draw state definition
color = [0.0 0.0 0.0];
for i = 1:data_setting.dim_state_num_ls(1) % dim1:x
    if ((data_setting.dim_value_range_ls{1}(i) - floor(data_setting.dim_value_range_ls{1}(i))) > 0)
        label = sprintf('[%.1f-%.1f]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        if (i == 1)
            text(i * x_pos_scale + x_pos_offset - 0.35, -0.8 ,label, 'Color', color, 'FontSize',fontsize);
        else
            text(i * x_pos_scale + x_pos_offset, -0.8 ,label, 'Color', color, 'FontSize',fontsize);
        end
    else
        label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i * x_pos_scale + x_pos_offset, -0.8, label, 'Color', color, 'FontSize',fontsize);
    end
end
for i = 1:data_setting.dim_state_num_ls(2) % dim2:y
    
    label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{2}(i), data_setting.dim_value_range_ls{2}(i+1));
    %label = sprintf('[%.2f-%.2f]', data_setting.dim_value_range_ls{2}(i), data_setting.dim_value_range_ls{2}(i+1));    
    if (data_setting.draw_origin_lefttop == 1)
        text(0.65, -i * y_pos_scale + y_pos_offset, label, 'Color', color, 'FontSize', fontsize);    
    else
        text(0.65, i * y_pos_scale + y_pos_offset, label, 'Color', color, 'FontSize', fontsize);   
    end
end


%% save files
if (is_vis_nij == 1)
    filename = sprintf('%s/vis_Nij_mat', top_out_folder);
else
    filename = sprintf('%s/vis_Q_mat', top_out_folder);
end

saveas(gcf, filename, 'png');
%saveas(gcf, filename, 'epsc');

close(gcf);

