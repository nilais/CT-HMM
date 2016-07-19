function func_visualize_ND_dominent_pattern(fig_id, min_subject, is_draw_link, is_draw_truev_subject_num)

global data_setting;
global state_list;
global Nrs_mat;

dim = data_setting.dim;
figure(fig_id);


%% find out the max number of subject in a state
[all_state_num_subject_list] = func_get_all_state_subject_num_list();
max_num_subject = max(all_state_num_subject_list);

%% find out the max number of transition in a link
temp = Nrs_mat;
num_row = size(temp, 1);
for r = 1:num_row
    temp(r, r) = 0;
end
max_link_info = max(temp(:));

max_marker_size = 25;
min_marker_size = 5;
max_line_width = 3;
min_line_width = 1;

%% =======================================================================================
%% construct first level nodes
max_N = 0;
num_state = size(state_list, 1);

num_age_idx = size(data_setting.dim_value_range_ls{dim}, 2);

for age_idx = 1:num_age_idx
    s_list = [];   
    for s = 1:num_state
        if (state_list{s}.dim_states(dim) == age_idx) 
            [num_subject, num_subject_truev, num_subject_interpov] = func_get_num_subject_pass_a_state(s);
            if (num_subject >= min_subject)
               s_list = [s_list s];
            end
        end
    end    
    N = size(s_list, 2);
    if (N > max_N)
       max_N = N; 
    end    
    coords = zeros(2, N);        
    for i = 1:N
        coords(1, i) = (age_idx-1)*5 + rand() * 0.5; % add a ranomd position shift, such that when drawing links, there are not too many overlapped
    end
    coords(2, :) = [1:N] .* 5;    
    hold on;
    
    for i = 1:N
        idx = s_list(i);        
        draw_coord = coords(:, i);
        state_list{idx}.draw_coord = draw_coord;        
        
        [num_subject, num_subject_truev, num_subject_interpov] = func_get_num_subject_pass_a_state(idx);        
        dim_states = state_list{idx}.dim_states;
        
        %% draw this state
        state_mu_list = func_print_state_mu_list(idx);
        
        if (is_draw_truev_subject_num == 1)
            info_str = sprintf('%s,#%d(%d,%d)', state_mu_list, num_subject, num_subject_truev, num_subject_interpov);            
            fontsize = 4;
        else
            info_str = sprintf('%s,#%d', state_mu_list, num_subject);
            fontsize = 6;
        end

        marker_size = min_marker_size + double(num_subject) / double(max_num_subject) * double(max_marker_size - min_marker_size);        
        face_color = [0 1 0];
        
%         for d = 2:dim
%            if (dim_states(d) < dim_states(1)) % if there is some delay in skill respective to age, draw red color
%                face_color = [1 0 0];
%                break;
%            end
%         end

        plot(draw_coord(1), draw_coord(2),'ro', 'MarkerEdgeColor','k',...
                              'MarkerFaceColor', face_color,...
                              'MarkerSize', marker_size);                          
        text(draw_coord(1) + 0.2, draw_coord(2) + 1, info_str, 'Color', [0 0 0], 'FontSize', fontsize);
        hold on;
                
    end
end

%axis equal;

if (is_draw_link == 1)

%% draw link between states
for s = 1:num_state
    
    [num_subject, num_subject_truev, num_subject_interpov] = func_get_num_subject_pass_a_state(s);
    if (num_subject <  min_subject)
        continue;
    end       
    %%%%%%%%%%%%%%%5
    I  = find(Nrs_mat(s, :) > 0);
    num_link = size(I, 2);

    for t = 1:num_link                 % for each n                    
       n = I(t);                     
       
       link_count = Nrs_mat(s, n);       
       link_prob = double(link_count) / double(sum(Nrs_mat(s, :)) - Nrs_mat(s, s));
       
       [num_subject, num_subject_truev, num_subject_interpov] = func_get_num_subject_pass_a_state(n);        
       if (num_subject < min_subject)
          continue;
       end
       coord1 = state_list{s}.draw_coord;
       coord2 = state_list{n}.draw_coord;
       line_width = min_line_width + double(link_count) / double(max_link_info) * double(max_line_width-min_line_width);        

       is_regress_nb = func_check_is_regress_neighbor(state_list{s}.dim_states, state_list{n}.dim_states);
       line_color = [0 0 0];  % black
       
%        if (is_regress_nb == 1)
%             line_color = [1 0 0];  % regression link, red
%        else
%             line_color = [0 0 0];  % black
%        end       
       
       %plot([coord1(1) coord2(1)], [coord1(2) coord2(2)], '-r',  'LineWidth', line_width, 'color', line_color);       
       arrow(coord1, coord2, 12, 'LineStyle', '-', 'EdgeColor',line_color,'FaceColor',line_color, 'LineWidth', line_width, 'BaseAngle', 20, 'TipAngle', 10);
       arrow FIXLIMITS;
       hold on;
       
       x = (coord1(1) + coord2(1)) / 2.0 + 0.1;
       y = (coord1(2) + coord2(2)) / 2.0 + 0.5;
       
       if (is_draw_truev_subject_num == 1)
           [link_num_subject, link_num_subject_truev, link_num_subject_interpov] = func_get_num_subject_pass_a_link(s, n);
           label = sprintf('#%d(%d, %d)(%.2f)', link_num_subject, link_num_subject_truev, link_num_subject_interpov, link_prob);            
           fontsize = 4;
       else           
           label = sprintf('#%d(%.2f)', link_count, link_prob);            
           fontsize = 6;
       end
       
       text(x,y,label, 'Color', [0 0 1], 'FontSize', fontsize);
       hold on;       
    end
end % s
end % is_draw_link

dim_type_str = func_print_dim_name_list();
titlestr = sprintf('state minimum subjects = %d, %s', min_subject, dim_type_str);
title(titlestr);

xlim([-1 35]);
ylim([0 (max_N*5+1)]);
  
