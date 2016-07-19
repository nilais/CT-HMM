function func_visualize_3D_Q_mat_Autism(fig_id)

global state_list;
global Nrs_mat;
global Q_mat_struct;
global Q_mat;
global state_lookup_table;
global data_setting;
global Sr_list;

figure(fig_id);

%total_subject = size(subject_list, 1);

%% find out the max number of subject in a state
max_num_subject = 0;
for i = 1:data_setting.dim_state_num_ls(1)
    for j = 1:data_setting.dim_state_num_ls(2)
        for k = 1:data_setting.dim_state_num_ls(3)
            s = state_lookup_table(i, j, k);
            if (s == 0)
                continue;
            end
            num_subject = size(Sr_list{s}, 2);
            if (num_subject > max_num_subject)
                max_num_subject = num_subject;
            end
        end        
    end
end

%% find out the max number of transition in a link
draw_link_line = 1;
draw_link_proportional = 1;

if (draw_link_line == 1 && draw_link_proportional == 1)
    %if (draw_link_intensity == 1)
    %    temp = Q_mat;
    %elseif (draw_link_count == 1)
        temp = Nrs_mat;
    %elseif (draw_link_probability == 1)
    %    temp = Nrs_mat;
    %end
    num_row = size(temp, 1);
    for r = 1:num_row
        temp(r, r) = 0;
    end
    max_link_info = max(temp(:));
end
max_line_width = 4;
min_line_width = 0.5;

%% draw all states and its coordinates
max_marker_size = 16;
min_marker_size = 4;
    
for i = 1:data_setting.dim_state_num_ls(1) % tau
    for j = 1:data_setting.dim_state_num_ls(2) % left hippo
        for k = 1:data_setting.dim_state_num_ls(3) % cog
            
            s = state_lookup_table(i, j, k);
            if (s == 0)
                continue;
            end
            
            num_subject = size(Sr_list{s}, 2);
            
            if (num_subject > 0)
                marker_size = min_marker_size + double(num_subject) / double(max_num_subject) * double(max_marker_size-min_marker_size);

                if (j < i || k < i)
                    face_color = [1 0 0];
                else
                    face_color = [1 1 1];
                end

                plot3(i,j,k,'ro', 'MarkerEdgeColor','k',...
                            'MarkerFaceColor', face_color,...
                            'MarkerSize',marker_size);

                %label = sprintf('(%d,%d,%d)#%d', i, j, k, num_data);  
                %label = sprintf('(%d,%d,%d)#%d', i, j, k, num_data);
                %text(i+0.1,j+0.1,k+0.1,label, 'Color', [0 0 1], 'FontSize',4);
            end
            
            hold on;
        end
    end
end
grid on;

hold on;

%% plot transition intensity (qrs) at each arrow
num_state = size(state_list, 1);

for m = 1:num_state
    sum_link = sum(Q_mat_struct(m, :));           
    %% ======================================================    
    %if (sum_link > 0 && Tr_list(m) > 0.0)    
    if (sum_link > 0)                        
        [C, n] = max(Q_mat(m, :));
        
        if (C ~= 0 && Nrs_mat(m, n) > 0) % if count > 0
            I = find(Q_mat(m, :) == C);
            num_strong_link = size(I, 2);
        
            link_info = Nrs_mat(m, n);
            line_width = min_line_width + double(link_info) / double(max_link_info) * double(max_line_width-min_line_width);
            
            for i = 1:num_strong_link
                
                n = I(i);                
                m_states = state_list{m}.dim_states;
                n_states = state_list{n}.dim_states;
                
                if (n == state_list{m}.neighbor_list(1)) % 1
                    line_color = [1 0 0];  % red                
                elseif (n == state_list{m}.neighbor_list(2)) % 2
                    line_color = [0 1 0];  % green                
                elseif (n == state_list{m}.neighbor_list(3)) % 3
                    line_color = [1 1 0];  % yellow                    
                elseif (n == state_list{m}.neighbor_list(4)) % 1,2                                        
                    line_color = [0 1 0];  % green                    
                elseif (n == state_list{m}.neighbor_list(5)) % 1,3
                    line_color = [1 1 0]; % yellow                
                elseif (n == state_list{m}.neighbor_list(6)) % 2,3                        
                    line_color = [0 0 1]; % blue                
                elseif (n == state_list{m}.neighbor_list(7)) % 1,2,3
                    line_color = [0 0 1]; % blue
                end                              
                                
                
                plot3([m_states(1) n_states(1)], [m_states(2) n_states(2)], [m_states(3) n_states(3)], '-r',  'LineWidth', line_width, 'color', line_color);
                hold on;
                
            end                        
        end
    end % if (sum_link)   
    %% ======================================================
end

axis equal;
title('Transition Trend');

type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});
zlabel(type_name_ls{3});

xlim([0 data_setting.dim_state_num_ls(1)]);
ylim([0 data_setting.dim_state_num_ls(2)]);
zlim([0 data_setting.dim_state_num_ls(3)]);


