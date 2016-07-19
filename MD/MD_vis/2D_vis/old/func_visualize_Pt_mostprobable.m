function func_visualize_Pt_mostprobable(t, fig_id)

global state_list;
global Nrs_mat;
global Q_mat;
global state_lookup_table;
global data_setting;
%global train_group_name;
global Sr_list;
global Cr_list;

figure(fig_id);
fontsize = 3;

%% compute Pt
Pt = expm(t * Q_mat);

%% draw all states first
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure
               
            m = state_lookup_table(i, j);
            if (m == 0)
                continue;
            end
            
            num_subject = Sr_list(m); %%XX
            sum_tran_data = sum(Nrs_mat(m, :));            
            if (num_subject == 0 && sum_tran_data == 0)
                continue;
            end                        
            m_state = state_list{m}.dim_states;                                       
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot the most probable destination state
            temp = Pt(m, :);            
            [C, n] = max(temp);                        
            if (n == m)
                marker_color = 'y';
            else
                marker_color = 'm';
            end            
            if (data_setting.draw_origin_lefttop == 1)
                plot(m_state(1),-m_state(2),'yo','MarkerEdgeColor','k','MarkerFaceColor',marker_color,'MarkerSize',6);
            else
                plot(m_state(1),m_state(2),'yo','MarkerEdgeColor','k','MarkerFaceColor',marker_color,'MarkerSize',6);
            end
            hold on;                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

%% draw all links

for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure
               
            m = state_lookup_table(i, j);
            if (m == 0)
                continue;
            end
            
            num_subject = Sr_list(m); %%XX
            sum_tran_data = sum(Nrs_mat(m, :));            
            if (num_subject == 0 && sum_tran_data == 0)
                continue;
            end
                        
            m_state = state_list{m}.dim_states;                                       
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot the most probable destination state
            temp = Pt(m, :);            
            [C, n] = max(temp);
                            
            if (n~= m && C ~= 0)
                I = find(temp == C);
                num_strong_link = size(I, 2);
                for k = 1:num_strong_link
                    n = I(k);
                    n_state = state_list{n}.dim_states;                                       
                    line_color = [0.0 0.0 1.0]; % blue
                    line_thick = 1;
                    if (data_setting.draw_origin_lefttop == 1)                        
                        p0 = [m_state(1) -m_state(2)];
                        p1 = [n_state(1) -n_state(2)];
                        vectarrow(p0,p1,line_color,line_thick);
                        %plot([m_states(1) n_states(1)], [-m_states(2) -n_states(2)], '-r',  'LineWidth', 1, 'color', line_color);
                    else
                        p0 = [m_state(1) m_state(2)];
                        p1 = [n_state(1) n_state(2)];
                        vectarrow(p0,p1,line_color,line_thick);
                        %plot([m_states(1) n_states(1)], [m_states(2) n_states(2)], '-r',  'LineWidth', 1, 'color', line_color);
                    end                    
                    hold on;
                end
            end            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

%title('Q matrix value');
type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});

%title(train_group_name);
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
        text(i,0+0.5,label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize+1);
    else
        label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i,0+0.5,label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize+1);
    end
end
for i = 1:data_setting.dim_state_num_ls(2) % dim2:y
    label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{2}(i), data_setting.dim_value_range_ls{2}(i+1));
    if (data_setting.draw_origin_lefttop == 1)
        text(-1, -i, label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize+1);    
    else
        text(-1, i, label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize+1);    
    end
end

grid off;
