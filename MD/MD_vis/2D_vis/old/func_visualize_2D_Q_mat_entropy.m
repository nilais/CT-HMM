function func_visualize_2D_Q_mat_entropy()

global state_list;
global state_lookup_table;
global data_setting;
global Q_mat;

figure,

%% compute Q_mat_entropy
num_state = size(state_list, 1);
global state_entropy_list;

state_entropy_list = ones(num_state, 1) * -1;

for s = 1:num_state
    
    row = Q_mat(s, :);
    I = find(row > 0);
    
    dwell_time = -1.0 / Q_mat(s, s);
    num_link = size(I, 2);
    
    if (num_link > 0 && dwell_time < 100)
        prob_link_list = zeros(num_link, 1);
        for i = 1:num_link
            idx = I(i);
            prob_link_list(i) = row(idx) / -row(s);
        end

        entropy = 0;
        for i = 1:num_link        
            entropy = entropy -  prob_link_list(i) * log2(prob_link_list(i));
        end

        state_entropy_list(s) = entropy;
    end
        
end

fontsize = 3;

%% draw all states and its coordinates
for i = 1:data_setting.dim_state_num_ls(1) % function 
    for j = 1:data_setting.dim_state_num_ls(2) % structure               
           
            s  = state_lookup_table(i, j);
            if (s == 0)
                continue;
            end
            
            entropy = state_entropy_list(s);
            if (entropy == -1)
                continue;
            end
                        
            if (data_setting.draw_origin_lefttop == 1)
                draw_i = i;
                draw_j = -j;
            else
                draw_i = i;
                draw_j = j;
            end
            
            range_list = [0.0 1.6];
            color_list = [0 0 1; 1 0 0];
            cur_value = entropy;
            marker_color = utility_find_gradient_color(range_list, color_list, cur_value);
            
            plot(draw_i,draw_j,'ro','MarkerEdgeColor','k','MarkerFaceColor',marker_color,'MarkerSize',5);            
                       
            str = sprintf('%.1f', entropy);
            text(draw_i+0.1,draw_j+0.1, str, 'Color', [0 0 0], 'FontSize', 4);
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            row = Q_mat(s, :);
            I = find(row > 0);
    
            dwell_time = -1.0 / Q_mat(s, s);
            num_link = size(I, 2);
    
            if (num_link > 0 && dwell_time < 100)
                prob_link_list = zeros(num_link, 1);
                for m = 1:num_link
                    idx = I(m);
                    prob_link_list(m) = row(idx) / -row(s);
                                        
                    str = sprintf('%.3f',  prob_link_list(m));
                    text(draw_i+0.1,draw_j-0.15*m, str, 'Color', [0 0 1], 'FontSize', 2);
                
                end
                
                
            
            end
        

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            
            hold on;            
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis equal;

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
        text(i,0+0.5,label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize-1);
    else
        label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{1}(i), data_setting.dim_value_range_ls{1}(i+1));
        text(i,0+0.5,label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize);
    end
end
for i = 1:data_setting.dim_state_num_ls(2) % dim2:y
    label = sprintf('[%d-%d]', data_setting.dim_value_range_ls{2}(i), data_setting.dim_value_range_ls{2}(i+1));
    if (data_setting.draw_origin_lefttop == 1)
        text(-1, -i, label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize);    
    else
        text(-1, i, label, 'Color', [0.0 0.6 0.0], 'FontSize',fontsize);    
    end
end

