function func_visualize_2D_Q_mat(fig_id)

global state_list;
global Nrs_mat;
global Q_mat_struct;
global Q_mat;
global state_lookup_table;
global data_setting;

figure(fig_id);

%% find out the max number of data in a state
max_num_data = 0;
for i = 1:data_setting.dim_stage_num_ls(1) % function 
    for j = 1:data_setting.dim_stage_num_ls(2) % structure
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

min_num_data = 1;

%% draw all states and its coordinates
for i = 1:data_setting.dim_stage_num_ls(1) % function 
    for j = 1:data_setting.dim_stage_num_ls(2) % structure
            s = state_lookup_table(i, j);
            if (s == 0)
                continue;
            end
            num_data = state_list{s}.num_data;
            %dim1_range = state_list{s}.range(1, :);
            %dim2_range = state_list{s}.range(2, :);

            face_color = [0 1 0];
            plot(i,-j,'ro', 'MarkerEdgeColor','k',...
                        'MarkerFaceColor', face_color,...
                        'MarkerSize', marker_size);
                    
            % proportional based on data count        
            marker_size = 1 + double(num_data - min_num_data) / double(max_num_data - min_num_data) * (6.0-1.0);

                    
            %label = sprintf('(%d,%d)(%d,%d)#%d', dim1_range(1), dim2_range(1), i, j, num_data);
            label = sprintf('#%d', num_data);
            text(i+0.2,-j+0.2,label, 'Color', [0 0 1], 'FontSize',6);
            hold on;            
    end
end
grid on;
hold on;

%% plot transition intensity (qrs) at each arrow
num_state = size(state_list, 1);

for m = 1:num_state
    
    sum_link = sum(Q_mat_struct(m, :));           
    %% ======================================================        
    if (sum_link > 0)
        
        [C, n] = max(Q_mat(m, :));
        
        if (C ~= 0 && Nrs_mat(m, n) > 0) % if count > 0
            I = find(Q_mat(m, :) == C);
            num_strong_link = size(I, 2);        
            for i = 1:num_strong_link
                n = I(i);
                m_stages = state_list{m}.dim_stages;
                n_stages = state_list{n}.dim_stages;
                %% draw strong links
                line_color = [0 0 1];
                plot([m_stages(1) n_stages(1)], [-m_stages(2) -n_stages(2)], '-r',  'LineWidth', 3, 'color', line_color);
                hold on;
            end                        
        end
        
        for n = 1:num_state
            if (Q_mat_struct(m, n) == 1 && Nrs_mat(m, n) > 0)
                m_stages = state_list{m}.dim_stages;
                n_stages = state_list{n}.dim_stages;
                %% draw link count
                x = (m_stages(1) + n_stages(1))/2.0;
                y = -(m_stages(2) + n_stages(2))/2.0;
                label = sprintf('#%d', Nrs_mat(m, n));
                text(x+0.1,y,label, 'Color', [0 0.5 0], 'FontSize',5);
            end
        end
        
    end % if (sum_link)   
    %% ======================================================
    
end

title('Q matrix value');

type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});





