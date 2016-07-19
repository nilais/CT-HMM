function func_visualize_2D_state_dwell_time(fig_id)

global Tr_list;
%global state_list;
global Nrs_mat;
global Q_mat;
global state_lookup_table;
global data_setting;

figure(fig_id);

font_size = 8;
marker_size = 10;

%% draw all states and its coordinates
for i = 1:data_setting.dim_stage_num_ls(1) % function 
    for j = 1:data_setting.dim_stage_num_ls(2) % structure
            s = state_lookup_table(i, j);
            if (s == 0)
                continue;
            end                        
            
            dwell_time = 1 / -Q_mat(s,s);
            row_Nrs = Nrs_mat(s, :);
            row_Nrs(s) = 0;
            sum_trans = sum(row_Nrs);
            
            if (dwell_time == inf || dwell_time == -inf || Tr_list(s) == 0.0 || sum_trans == 0.0)
                plot(i,-j,'ro','MarkerEdgeColor','k','MarkerFaceColor',[1.0 1.0 1.0],'MarkerSize', marker_size);               
            else
                
                %range_list = [0 2 4 6 15]; in year                
                range_list = [0 6 12 18 24] / 12.0; %in year
                                
                %dark blue -> green -> yellow -> orange -> red
                %color_list = [255 0 0; 255 128 0; 255 255 0; 0 255 0; 0 0 128];
                %color_list = [255 0 0; 255 128 0; 255 255 0; 0 255 0; 0 0 128];
                color_list = [0 0 128; 0 255 0; 255 255 0; 255 128 0; 255 0 0];
                
                                
                t = dwell_time;
                for r = 1:4            
                    if (t >= range_list(r) && t <= range_list(r+1))                
                        g = (t - range_list(r)) / (range_list(r+1) - range_list(r)); 
                        c1 = color_list(r, :);
                        c2 = color_list(r+1, :);
                        color = c1 * (1-g) + c2 * g;                
                    else
                        continue;
                    end
                end
                if (t > range_list(end))
                    color = color_list(5, :);
                end
                color = color ./ 255.0;
                for k = 1:3
                    if (color(k) > 1.0)
                        color(k) = 1.0;
                    end
                end
                plot(i,-j,'ro','MarkerEdgeColor','k','MarkerFaceColor',color,'MarkerSize',marker_size);
                %str = sprintf('s%d (%.1f)', s, dwell_time);    
                str = sprintf('%.1f', dwell_time);    
                
                text(i+0.15,-j, str, 'FontSize', font_size, 'Color', [0.0 0.0 0.0]);
            end
                        

            hold on;            
    end
end

grid on;
hold on;

set(gca, 'FontSize', 12);
title('State Sojourn Time (in Years)');

%%%%%%%%%%%%%%%%%%%%%%   
% 0.0  -> [0 0 128]    (dark blue)
% 0.25 -> [0 255 0]    (green)
% 0.5  -> [255 255 0]  (yellow)
% 0.75 -> [255 128 0]  (orange)
% 1.0  -> [255 0 0]    (red)

% [255 0 0]    (red)
% [255 128 0]  (orange)
% [255 255 0]  (yellow)
% [0 255 0]    (green)
% [0 0 128]    (dark blue)



