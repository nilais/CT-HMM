function func_visualize_2D_Q_mat_state_dwell_time_proportional(fig_id)

global state_list;
global Q_mat_struct;
global Q_mat;
global data_setting;

global Nrs_mat;
global Tr_list;
global Cr_list;
global Ar_list;
global Sr_list;

global train_group_name;
global state_lookup_table;

figure(fig_id);

%% find out the max number of data in a state
max_num_data = 0;
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure
        s = state_lookup_table(i, j);
        if (s == 0)
            continue;
        end
        num_data = state_list{s}.num_data;
        if (num_data > max_num_data)
            max_num_data = num_data;
        end
    end
end

min_num_data = 0;
%max_marker_size = 20;

max_marker_size = 14;
min_marker_size = 4;

%% plot transition intensity (qrs) at each arrow
num_state = size(state_list, 1);

CountRS = Nrs_mat;
for s = 1:num_state
    CountRS(s,s) = 0;
end
max_Nrs = max(CountRS(:));

max_line_thick = 5;
min_line_thick = 1;

for m = 1:num_state
    
    
    Nrs_row = Nrs_mat(m, :);
    Nrs_row(1, m) = 0;
    
    [C, n] = max(Nrs_row);
    sum_link = sum(Q_mat_struct(m, :));           
    
    %% ======================================================        
    if (sum_link > 0)
        
        for n = 1:num_state
            if (Q_mat_struct(m, n) == 1 && Nrs_mat(m, n) > 0)
                m_states = state_list{m}.dim_states;
                n_states = state_list{n}.dim_states;
                
                %% draw link count
                x = (m_states(1) + n_states(1))/2.0;
                y = (m_states(2) + n_states(2))/2.0;
                
                count = Nrs_mat(m, n);
                label = sprintf('#%d', count);
                
                if (data_setting.draw_origin_lefttop == 1)
                    text(x+0.15,-y+0.1,label, 'Color', [0 0.5 0], 'FontSize',5);
                else
                    text(x+0.15,y+0.1,label, 'Color', [0 0.5 0], 'FontSize',5);
                end
                
                %% draw links
                if (Nrs_mat(m, n) == C && C > 0)  % the strongest link
                    line_color = [0 0 1];
                else
                    line_color = [0 0 0]; 
                end
                
                %line_width = min_line_thick + double(count - 1) / double(max_Nrs - 1) * double(max_line_thick-min_line_thick);
                line_width = min_line_thick + double(count) / double(max_Nrs) * double(max_line_thick-min_line_thick);
                
                if (data_setting.draw_origin_lefttop == 1)
                    plot([m_states(1) n_states(1)], [-m_states(2) -n_states(2)], ':r',  'LineWidth', line_width, 'color', line_color);
                else
                    plot([m_states(1) n_states(1)], [m_states(2) n_states(2)], ':r',  'LineWidth', line_width, 'color', line_color);
                end
                
                hold on;                
            end
        end        
        
        
        
    end % if (sum_link)   
    %% ======================================================    
end

%% draw all states 
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure
        
            s = state_lookup_table(i, j);
            if (s == 0)
                continue;
            end
                        
            num_data = Sr_list(s);
            sum_tran_data = sum(Nrs_mat(s, :));
            
            if (num_data == 0 && sum_tran_data == 0)
                continue;
            end
            
            %dim1_range = state_list{s}.range(1, :);
            %dim2_range = state_list{s}.range(2, :);
            
            % proportional based on data count        
            marker_size = min_marker_size + double(num_data - min_num_data) / double(max_num_data - min_num_data) * double(max_marker_size-min_marker_size);

            %%%%%%%%%%%%%%%%%%%%%%%%%%        
            dwell_time = 1 / -Q_mat(s,s);
            row_Nrs = Nrs_mat(s, :);
            row_Nrs(s) = 0;
            sum_trans = sum(row_Nrs);
            
            if (data_setting.draw_origin_lefttop == 1)
                draw_i = i;
                draw_j = -j;
            else
                draw_i = i;
                draw_j = j;
            end
            
            if (dwell_time == inf || dwell_time == -inf || Tr_list(s) == 0.0 || sum_trans == 0.0)
                plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',[1.0 1.0 1.0],'MarkerSize', marker_size);               
            else
                
                color = utility_dwelling_time_color(dwell_time);                                
                plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',color,'MarkerSize',marker_size);
                
                ave_entry_age = mean(Ar_list{s});
                %str = sprintf('A:%.1f', ave_entry_age);  % in months for autism
                % plot entry age
                %text(draw_i+0.2,draw_j+0.1, str, 'FontSize', 6, 'Color', [0 0 0]);
                
                %str = sprintf('D:%.1f', dwell_time * 12);  % in months for autism
                str = sprintf('%.1f', dwell_time);  % in months for autism
                
                % plot entry age, dwelling time
                text(draw_i+0.2,draw_j-0.1, str, 'FontSize', 5, 'Color', [0 0 0]);
            end                                
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot num of visits in this state
            num_subject = Sr_list(s);
            label = sprintf('%d', num_subject);
            %label = sprintf('#v:%d,#s:%d', num_data, num_subject);
            text(draw_i+0.1,draw_j+0.2,label, 'Color', [0 0 1], 'FontSize',5);
            hold on;            
    end
end

%grid on;
hold on;

%title('Q matrix value');
type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});

axis equal;

title(train_group_name);

if (data_setting.draw_origin_lefttop == 1)
    xlim([ 0 (data_setting.dim_state_num_ls(1)+1)]);
    ylim([(-data_setting.dim_state_num_ls(2)-1) 0]);
else
    xlim([0 (data_setting.dim_state_num_ls(1)+1)]);
    ylim([0 (data_setting.dim_state_num_ls(2)+1)]);    
end

