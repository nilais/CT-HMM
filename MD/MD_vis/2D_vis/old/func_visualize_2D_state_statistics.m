function func_visualize_2D_state_statistics()

global state_list;
global data_setting;
global state_lookup_table;

figure,

%% draw all states and its coordinates
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure
        
            %s = state_lookup_table(i, j);
            s = func_query_state_idx([i j]);
            
            
            if (s == 0)
                continue;
            end
            
            num_data = state_list{s}.num_data;
            %dim1_range = state_list{s}.range(1, :);
            %dim2_range = state_list{s}.range(2, :);

            face_color = [0 1 0];
                        
            if (data_setting.draw_origin_lefttop == 1)
                draw_i = i;
                draw_j = -j;
            else
                draw_i = i;
                draw_j = j;
            end
            
            plot(draw_i,draw_j,'ro', 'MarkerEdgeColor','k',...
                        'MarkerFaceColor', face_color,...
                        'MarkerSize', 5);
                    
            %label = sprintf('(%d,%d)(%d,%d)#%d', dim1_range(1), dim2_range(1), i, j, num_data);
            label = sprintf('#%d', num_data);
            
            text(draw_i+0.1,draw_j+0.1,label, 'Color', [0 0 1], 'FontSize',6);
            hold on;            
    end
end
grid on;

global out_dir;
str = sprintf('%s\\2D_state_stat.png', out_dir);
saveas(gcf, str, 'png');

