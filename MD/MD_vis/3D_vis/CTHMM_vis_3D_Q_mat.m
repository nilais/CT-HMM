function CTHMM_vis_3D_Q_mat(top_out_folder, is_vis_nij, vis_threshold)

global state_list;
global Nij_mat;
global Q_mat_struct;
global Q_mat;
global data_setting;

fontsize = 5;

max_marker_size = 14;
min_marker_size = 2;
max_line_thick = 5;
%min_line_thick = 0.25;
min_line_thick = 1;

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

figure,


%% draw all states and its coordinates
Ni_list = diag(Nij_mat);

min_Ni = min(Ni_list);
max_Ni = max(Ni_list);

for i = 1:data_setting.dim_state_num_ls(1) % tau
    for j = 1:data_setting.dim_state_num_ls(2) % left hippo
        for k = 1:data_setting.dim_state_num_ls(3) % cog
            
            dim_state_idx_list = [i j k];
            s = CTHMM_MD_query_state_idx_from_dim_idx(dim_state_idx_list);
            
            if (s == 0)
                continue;
            end
            
            %% decide state size
            Ni = Ni_list(s);
            if (Ni < vis_threshold)
                continue;
            end

            % proportional based on data count
            marker_size = min_marker_size + double(Ni - min_Ni) / double(max_Ni - min_Ni) * double(max_marker_size - min_marker_size);
            
            % plot dwelling time
            dwell_time = 1 / -Q_mat(s, s);
            
            %dwell_time = dwell_time / 12.0; % year
            
            %face_color = [1 1 1]; 
            
            %% plot dwelling time and state size
            if (dwell_time == inf || dwell_time == -inf)
                plot3(i,j,k, 'ro', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0.0 1.0 0.0], 'MarkerSize', marker_size);   
            else
                color = CTHMM_vis_compute_dwell_time_color(dwell_time);
                plot3(i,j,k, 'ro','MarkerEdgeColor', 'k', 'MarkerFaceColor', color, 'MarkerSize', marker_size);
            end

            %label = sprintf('(%d,%d,%d)#%d', i, j, k, num_data);  
            %label = sprintf('(%d,%d,%d)#%d', i, j, k, num_data);
            %text(i+0.1,j+0.1,k+0.1,label, 'Color', [0 0 1], 'FontSize',4);
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
        
        [C, n] = max(vis_mat(m, :));
        
        if (C ~= 0.0) % if count > 0
            
            if (Nij_mat(m, n) < vis_threshold)
                continue;
            end
            
            I = find(vis_mat(m, :) == C);
            num_strong_link = size(I, 2);
        
            for i = 1:num_strong_link
                
                n = I(i); 
                
                infov = vis_mat(m, n);
                line_width = min_line_thick + double(infov) / double(max_vis_ij) * double(max_line_thick - min_line_thick);
                
                m_states = state_list{m}.dim_states;
                n_states = state_list{n}.dim_states;
                
                dim_diff = n_states - m_states;
                                
                line_color = [0 0 0];
                
                
                cog_line_color = 'm';
                
                dim1_color = [0 0 1];
                dim2_color = [0 1 0];
                dim3_color = [1 0 0];
                                
                if (dim_diff(1) == 1 && dim_diff(2) == 0 && dim_diff(3) == 0) % [1 0 0], 1
                    line_color = dim1_color;
                elseif (dim_diff(1) == 0 && dim_diff(2) == 1 && dim_diff(3) == 0) % [0 1 0], 2
                    line_color = dim2_color;
                elseif (dim_diff(1) == 0 && dim_diff(2) == 0 && dim_diff(3) == 1) % [0 0 1], 3
                    line_color = dim3_color;
                elseif (dim_diff(1) == 1 && dim_diff(2) == 1 && dim_diff(3) == 0) % [1 1 0], 1,2
                    %line_color = [138/255.0 43/255.0 226/255.0]; % purple
                    line_color = (dim1_color + dim2_color);% * 0.5;
                elseif (dim_diff(1) == 0 && dim_diff(2) == 1 && dim_diff(3) == 1) % [0 1 1], 2,3
                    %line_color = cog_line_color;
                    line_color = (dim2_color + dim3_color);% * 0.5;
                elseif (dim_diff(1) == 1 && dim_diff(2) == 0 && dim_diff(3) == 1) % [1 0 1] 1,3    
                    %line_color = cog_line_color;
                    line_color = (dim1_color + dim3_color);% * 0.5;
                elseif (dim_diff(1) == 1 && dim_diff(2) == 1 && dim_diff(3) == 1) % [1 1 1] 1,2,3
                    %line_color = cog_line_color;
                    %line_color = (dim1_color + dim2_color + dim3_color) / 3.0;
                    line_color = [ 0 0 0];
                    
                end
                                
                plot3([m_states(1) n_states(1)], [m_states(2) n_states(2)], [m_states(3) n_states(3)], '-r',  'LineWidth', line_width, 'color', line_color);
                hold on;                
            end                        
        end
    end % if (sum_link)   
    %% ======================================================
end

axis equal;
title('State Transition Trend');

type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});
zlabel(type_name_ls{3});

%% save files
if (is_vis_nij == 1)
    filename = sprintf('%s\\vis_Nij_mat', top_out_folder);
else
    filename = sprintf('%s\\vis_Q_mat', top_out_folder);
end

saveas(gcf, filename, 'png');
%saveas(gcf, filename, 'epsc');

close(gcf);

