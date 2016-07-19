function CTHMM_vis_3D_state_statistics()


global state_list;
global data_setting;

figure,
zero_count = 0;

%% draw all states and its coordinates
for i = 1:data_setting.dim_state_num_ls(1) % tau
    for j = 1:data_setting.dim_state_num_ls(2) % left hippo
        for k = 1:data_setting.dim_state_num_ls(3) % cog
                        
            dim_state_idx_list = [i j k];
            s = CTHMM_MD_query_state_idx_from_dim_idx(dim_state_idx_list);
                                                               
            if (s == 0)
                continue;
            end
            
            num_data = state_list{s}.raw_data_count;
            
            if (num_data == 0)
                zero_count = zero_count + 1;
            end
            
            face_color = [0 1 0];
            
            plot3(i,j,k,'ro', 'MarkerEdgeColor','k',...
                        'MarkerFaceColor', face_color,...
                        'MarkerSize', 5);
                    
            label = sprintf('(%d,%d,%d)#%d', i, j, k, num_data);  
            text(i+0.1,j+0.1,k+0.1,label, 'Color', [0 0 1], 'FontSize',8);
            hold on;
        end
    end
end
grid on;

zero_count

%plot3([0 1], [0 1], [0 1], '-b',  'LineWidth', 3);
%plot3([0 1], [0 0], [0 0], '-b',  'LineWidth', 3);
%plot3([1 2], [0 0], [0 0], '-b',  'LineWidth', 3);
%plot3([0 1], [0 1], [0 0], '-b',  'LineWidth', 3);
%plot3([1 1], [1 1], [0 2], '-b',  'LineWidth', 3);
