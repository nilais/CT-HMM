function func_visualize_2D_Q_mat_state_dwell_time_Autism_age(fig_id, draw_link_line, draw_link_probability, draw_link_intensity, draw_link_count, draw_strongest_link_only, draw_link_proportional, draw_age)

global state_list;
global Nrs_mat;
global Q_mat_struct;
global Q_mat;
global state_lookup_table;
global data_setting;
global Tr_list;
%global Cr_list;
global Sr_list;

global Ars_mean;
global Ar_list;
global subject_list;
global train_group_title;

total_subject = size(subject_list, 1);



figure(fig_id);
fontsize = 3;

if (draw_link_line == 0)
    max_marker_size = 16;
    min_marker_size = 2;
else
    max_marker_size = 12;
    min_marker_size = 1;
end


%% find out the max number of subject in a state
max_num_subject = 0;
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure
        s = state_lookup_table(i, j);
        if (s == 0)
            continue;
        end
        num_subject = size(Sr_list{s}, 2);
        if (num_subject > max_num_subject)
            max_num_subject = num_subject;
        end
    end
end
%% find out the max number of transition in a link
if (draw_link_line == 1 && draw_link_proportional == 1)
    if (draw_link_intensity == 1)
        temp = Q_mat;
    elseif (draw_link_count == 1)
        temp = Nrs_mat;
    elseif (draw_link_probability == 1)
        temp = Nrs_mat;
    end
    num_row = size(temp, 1);
    for r = 1:num_row
        temp(r, r) = 0;
    end
    max_link_info = max(temp(:));
end

hold on;


%% draw all states and its coordinates
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure               
            s = state_lookup_table(i, j);
            if (s == 0)
                continue;
            end
            num_subject = size(Sr_list{s}, 2);
            sum_tran_data = sum(Nrs_mat(s, :));            
            if (num_subject == 0 && sum_tran_data == 0)
                continue;
            end
            if (data_setting.draw_origin_lefttop == 1)
                draw_i = i;
                draw_j = -j;
            else
                draw_i = i;
                draw_j = j;
            end
            % proportional based on data count        
            marker_size = min_marker_size + double(num_subject) / double(max_num_subject) * double(max_marker_size-min_marker_size);
            %%%%%%%%%%%%%%%%%%%%%%%%%%        
            dwell_time = 1 / -Q_mat(s,s);
            row_Nrs = Nrs_mat(s, :);
            row_Nrs(s) = 0;
            sum_trans = sum(row_Nrs);            
            if (dwell_time == inf || dwell_time == -inf || Tr_list(s) == 0.0 || sum_trans == 0.0)
                plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',[0 0.5 0],'MarkerSize', marker_size);               
            else                
                color = utility_dwelling_time_color(dwell_time);    
                %plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',color,'MarkerSize',marker_size);
                plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',[0 0.5 0],'MarkerSize',marker_size);
                
                %str = sprintf('s%d (%.1f)', s, dwell_time);    
                %str = sprintf('%.1f', dwell_time * 12);  % in months for autism
                
                if (draw_age == 1)
                    str = sprintf('%.1f', mean(Ar_list{s}));  % in years
                else
                    str = sprintf('%.1fyr', dwell_time);  % in years
                end
                                
                %mean_age = mean(Ar_list{s});
                %str = sprintf('%.1f,%.1f', dwell_time, mean_age);  % in years
                
                text(draw_i+0.1,draw_j+0.1, str, 'FontSize', fontsize, 'Color', [0 0 0]);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %percent_subject = double(num_subject) / double(total_subject);
            %label = sprintf('#%d(%.2f)', num_subject, percent_subject);
            %label = sprintf('#%d', num_subject);
            %text(draw_i+0.1,draw_j+0.25,label, 'Color', [0 0 0], 'FontSize', fontsize);

            hold on;            
    end
end


%% plot transition intensity (qrs) at each arrow
num_state = size(state_list, 1);

max_line_width = 3.5;
min_line_width = 0.25;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
for m = 1:num_state    
    
    sum_link = sum(Q_mat_struct(m, :));   
    
    temp = Q_mat(m, :);
    temp(m) = 0;    
    sum_qrs_link = sum(temp);
    max_local_link = max(temp);
        
    %% ======================================================        
    if (sum_link > 0)       
        
        for n = 1:num_state

            if (Q_mat_struct(m, n) == 1 && Nrs_mat(m, n) > 0)            
                    
                m_states = state_list{m}.dim_states;
                n_states = state_list{n}.dim_states;                

                %% draw link count/intensity
                x = (m_states(1) + n_states(1))/2.0;
                y = (m_states(2) + n_states(2))/2.0;                                    

                if (draw_link_count == 1)                
                    link_info = Nrs_mat(m, n);
                    prob =  Q_mat(m, n) / sum_qrs_link;
                    label = sprintf('#%d(%.2f)', link_info, prob);
                    linkfontsize = fontsize;
                elseif (draw_link_intensity == 1)
                    link_info = Q_mat(m, n);
                    label = sprintf('%.3f', link_info);                        
                    linkfontsize = fontsize - 1;
                elseif (draw_link_probability == 1)
                    link_info = Q_mat(m, n) / sum_qrs_link;
                    label = sprintf('%.2f', link_info);                        
                    linkfontsize = fontsize - 1;    
                elseif (draw_age == 1)
                    link_info = Ars_mean(m, n);
                    label = sprintf('%.1f', link_info);                        
                    linkfontsize = fontsize-1;                        
                end
                
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (draw_link_line == 1)
                    
                    % draw  line                               
                     if (data_setting.draw_origin_lefttop == 1)
                        draw_point1 = [m_states(1) -m_states(2)];
                        draw_point2 = [n_states(1) -n_states(2)];
                     else
                        draw_point1 = [m_states(1) m_states(2)];
                        draw_point2 = [n_states(1) n_states(2)];  
                     end

                    %% draw links (black dotted link)
                    if (max_local_link == Q_mat(m, n)) %% strongest
                        line_color = [0 0 1];                                    
                        line_style = '-';
                    else %% black link                    
                        line_color = [0.5 0.5 0.5];                
                        %line_style = '--';
                        line_style = '-';
                    end              
                    draw_offset = [0 0];    
                    if (state_list{m}.neighbor_list(1) == n) 
                        draw_offset = [0 0];
                    elseif (state_list{m}.neighbor_list(2) == n)
                        draw_offset = [0.05 0];
                    elseif (state_list{m}.neighbor_list(3) == n)
                        draw_offset = [0 0];
                    elseif (state_list{m}.neighbor_list(4) == n)
                        draw_offset = [0 0];
                    elseif (state_list{m}.neighbor_list(5) == n)    
                        draw_offset = [-0.05 0];
                    end

                    draw_point1 = draw_point1 + draw_offset;
                    draw_point2 = draw_point2 + draw_offset;                

                    if (draw_link_proportional == 1)                    
                        if (draw_link_probability == 1)                    
                            line_width = min_line_width + double(link_info) / double(1) * double(max_line_width-min_line_width);
                        else
                            line_width = min_line_width + double(link_info) / double(max_link_info) * double(max_line_width-min_line_width);
                        end
                    else
                        line_width = 1;
                    end
                    if ((draw_strongest_link_only == 1 && max_local_link == Q_mat(m, n)) || ...
                         draw_strongest_link_only == 0)                    
                            %plot([m_states(1) n_states(1)], [-m_states(2) -n_states(2)], line_pattern,  'LineWidth', line_width, 'color', line_color);
                            %arrow(draw_point1, draw_point2, 'LineStyle', line_style, 'EdgeColor',line_color,'FaceColor',line_color, 'LineWidth', line_width);                    
                            arrow(draw_point1, draw_point2, 10, 'LineStyle', line_style, 'EdgeColor',line_color,'FaceColor',line_color, 'LineWidth', line_width);                    
                    end
                    hold on;                
                end
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
               
               
               %% draw text
               draw_offset = [0 0];
                if (state_list{m}.neighbor_list(1) == n) 
                    draw_offset = [0 0];
                elseif (state_list{m}.neighbor_list(2) == n)
                    draw_offset = [0 0.1];
                elseif (state_list{m}.neighbor_list(3) == n)
                    draw_offset = [0 0.1];
                elseif (state_list{m}.neighbor_list(4) == n)
                    draw_offset = [0 -0.1];
                elseif (state_list{m}.neighbor_list(5) == n)    
                    draw_offset = [0 -0.1];
                end
                
                                
               if (data_setting.draw_origin_lefttop == 1)
                    text(x+0.1+draw_offset(1), -(y+0.1+draw_offset(2)), label, 'Color', [0 0.3 0], 'FontSize',linkfontsize);
                else
                    text(x+0.1+draw_offset(1), y+0.1+draw_offset(2), label, 'Color', [0 0.3 0], 'FontSize',linkfontsize);
                end
                hold on;
                
            end % if Q           
        end % n       
    end % if (sum_link)   
    %% ======================================================    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%title('Q matrix value');

%% draw all states and its coordinates
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure               
            s = state_lookup_table(i, j);
            if (s == 0)
                continue;
            end
            num_subject = size(Sr_list{s}, 2);
            sum_tran_data = sum(Nrs_mat(s, :));            
            if (num_subject == 0 && sum_tran_data == 0)
                continue;
            end
            if (data_setting.draw_origin_lefttop == 1)
                draw_i = i;
                draw_j = -j;
            else
                draw_i = i;
                draw_j = j;
            end
            % proportional based on data count        
            marker_size = min_marker_size + double(num_subject) / double(max_num_subject) * double(max_marker_size-min_marker_size);
            %%%%%%%%%%%%%%%%%%%%%%%%%%        
            dwell_time = 1 / -Q_mat(s,s);
            row_Nrs = Nrs_mat(s, :);
            row_Nrs(s) = 0;
            sum_trans = sum(row_Nrs);            
            if (dwell_time == inf || dwell_time == -inf || Tr_list(s) == 0.0 || sum_trans == 0.0)
               % plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',[1.0 1.0 1.0],'MarkerSize', marker_size);               
            else                
                color = utility_dwelling_time_color(dwell_time);    
                %plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',color,'MarkerSize',marker_size);
              %  plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',[1.0 1.0 1.0],'MarkerSize',marker_size);
                
                %str = sprintf('s%d (%.1f)', s, dwell_time);    
                %str = sprintf('%.1f', dwell_time * 12);  % in months for autism
                
                if (draw_age == 1)
                    str = sprintf('%.1f', mean(Ar_list{s}));  % in years
                else
                    str = sprintf('%.1fyr', dwell_time);  % in years
                end
                                
                %mean_age = mean(Ar_list{s});
                %str = sprintf('%.1f,%.1f', dwell_time, mean_age);  % in years
                
                text(draw_i+0.1,draw_j+0.1, str, 'FontSize', fontsize, 'Color', [0 0 0]);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %percent_subject = double(num_subject) / double(total_subject);
            %label = sprintf('#%d(%.2f)', num_subject, percent_subject);
            
            label = sprintf('#%d', num_subject);
            
            text(draw_i+0.1,draw_j+0.25,label, 'Color', [0 0 0], 'FontSize', fontsize);

            hold on;            
    end
end



type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});

axis equal;
title(train_group_title);

if (data_setting.draw_origin_lefttop == 1)
    %xlim([(0-2) (data_setting.dim_state_num_ls(1)+1)]);
    %ylim([(-data_setting.dim_state_num_ls(2)-1) (0+2)]);
    xlim([0 (data_setting.dim_state_num_ls(1)+1)]);
    ylim([(-data_setting.dim_state_num_ls(2)-1) 0]);
else
    %xlim([(0-2) (data_setting.dim_state_num_ls(1)+1)]);
    %ylim([(0-2) (data_setting.dim_state_num_ls(2)+1)]);    
    xlim([0 (data_setting.dim_state_num_ls(1)+1)]);
    ylim([0 (data_setting.dim_state_num_ls(2)+1)]);    
end

%% draw state definition
for i = 1:data_setting.dim_state_num_ls(1) % dim1:x
    if ((data_setting.dim_value_range_ls{1}(i) - floor(data_setting.dim_value_range_ls{1}(i))) > 0)
        label = sprintf('[%.1f-%.1f]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i,0+0.5,label, 'Color', [0.0 0.3 0.0], 'FontSize',fontsize-1);
    else
        label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i,0+0.5,label, 'Color', [0.0 0.3 0.0], 'FontSize',fontsize+1);
    end
end
for i = 1:data_setting.dim_state_num_ls(2) % dim2:y
    label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{2}(i), data_setting.dim_value_range_ls{2}(i+1));
    if (data_setting.draw_origin_lefttop == 1)
        text(0.5, -i, label, 'Color', [0.0 0.3 0.0], 'FontSize',fontsize+1);    
    else
        text(0.5, i, label, 'Color', [0.0 0.3 0.0], 'FontSize',fontsize+1);    
    end
end


