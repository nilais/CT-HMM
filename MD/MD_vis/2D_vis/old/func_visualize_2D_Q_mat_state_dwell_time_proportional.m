function func_visualize_2D_Q_mat_state_dwell_time_proportional(fig_id)

global state_list;
global Q_mat_struct;
global Q_mat;
global data_setting;
global Nij_mat;
global train_group_name;

figure(fig_id);

%% draw setting
max_marker_size = 14;
min_marker_size = 4;
max_line_thick = 5;
min_line_thick = 1;

%% plot transition intensity (qrs) at each arrow
num_state = size(state_list, 1);

temp_mat = Nij_mat;
for s = 1:num_state
    temp_mat(s,s) = 0;
end
max_Nij = max(temp_mat(:));

%% plot transition counts or qij rate
for m = 1:num_state
    Nij_row = Nij_mat(m, :);
    Nij_row(1, m) = 0;    
    [C, n] = max(Nij_row);
    sum_link = sum(Q_mat_struct(m, :));    
    if (sum_link == 0)
        continue;
    end       
    for n = 1:num_state
        if (Q_mat_struct(m, n) == 1 && Nij_mat(m, n) > 0)
            m_states = state_list{m}.dim_states;
            n_states = state_list{n}.dim_states;
            %% draw link count
            x = (m_states(1) + n_states(1))/2.0;
            y = (m_states(2) + n_states(2))/2.0;                
            count = Nij_mat(m, n);
            label = sprintf('#%d', count);                
            if (data_setting.draw_origin_lefttop == 1) % draw count text
                text(x+0.15,-y+0.1,label,'Color',[0 0.5 0],'FontSize',5);
            else
                text(x+0.15,y+0.1,label,'Color',[0 0.5 0],'FontSize',5);
            end                
            %% draw links
            if (Nij_mat(m, n) == C && C > 0)  % the strongest link
                line_color = [0 0 1]; % draw blue link
            else
                line_color = [0 0 0]; % draw black link
            end                
            line_width = min_line_thick + double(count) / double(max_Nij) * double(max_line_thick - min_line_thick);                
            if (data_setting.draw_origin_lefttop == 1)
                plot([m_states(1) n_states(1)], [-m_states(2) -n_states(2)], ':r',  'LineWidth', line_width, 'color', line_color);
            else
                plot([m_states(1) n_states(1)], [m_states(2) n_states(2)], ':r',  'LineWidth', line_width, 'color', line_color);
            end                
            hold on;                
        end % if
    end % n
end

%% draw all states
Ni_list = -diag(Nij_mat);
min_Ni = min(Ni_list);
max_Ni = max(Ni_list);

for m = 1:num_state
        
    Ni = Ni_list(m);
    if (Ni < 0.5)
        continue;
    end
    
    % proportional based on data count        
    marker_size = min_marker_size + double(Ni - min_Ni) / double(max_Ni - min_Ni) * double(max_marker_size - min_marker_size);
    % plot dwelling time
    dwell_time = 1 / -Q_mat(m, m);
    
    % draw state position
    if (data_setting.draw_origin_lefttop == 1)
        draw_i = state_list{m}.dim_states(1);
        draw_j = -state_list{m}.dim_states(2);
    else
        draw_i = state_list{m}.dim_states(1);
        draw_j = state_list{m}.dim_states(2);
    end
    
    %% plot dwelling time and state size
    if (dwell_time == inf || dwell_time == -inf)
        plot(draw_i, draw_j, 'ro', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [1.0 1.0 1.0], 'MarkerSize', marker_size);   
    else
        color = utility_dwelling_time_color(dwell_time);                                
        plot(draw_i, draw_j, 'ro','MarkerEdgeColor', 'k', 'MarkerFaceColor', color, 'MarkerSize', marker_size);
    end
    
    %% plot dwell time
    str = sprintf('%.2f', dwell_time);
    text(draw_i+0.2,draw_j-0.1, str, 'FontSize', 5, 'Color', [0 0 0]);
    
    %% plot number of expected visits E(Ni)
    label = sprintf('%d', Ni);
    text(draw_i+0.1, draw_j+0.2, label, 'Color', [0 0 1], 'FontSize', 5);
    hold on;
            
end

type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});
axis equal;
title(train_group_name);

if (data_setting.draw_origin_lefttop == 1)
    xlim([0 (data_setting.dim_state_num_ls(1)+1)]);
    ylim([(-data_setting.dim_state_num_ls(2)-1) 0]);
else
    xlim([0 (data_setting.dim_state_num_ls(1)+1)]);
    ylim([0 (data_setting.dim_state_num_ls(2)+1)]);    
end
