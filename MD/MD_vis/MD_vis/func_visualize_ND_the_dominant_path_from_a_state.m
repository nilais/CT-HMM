function func_visualize_ND_the_dominant_path_from_a_state_Autism_age(fig_id, dim_state_idx_list, is_draw_truev_subject_num)

global state_list;
global Q_mat_struct;
global Q_mat;
global Nrs_mat;
global data_setting;
global Sr_list;

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

max_marker_size = 20;
min_marker_size = 4;
max_line_width = 5;
min_line_width = 0.5;

%% draw all states and its coordinates
num_node = 0;
max_num_node = 1000;
node_list = cell(max_num_node, 1);
for n = 1:max_num_node
    node_list{n}.parent_node_idx = -1;
    node_list{n}.num_child = 0;    
    node_list{n}.num_subject = 0;
end

%% =======================================================================================
step = 1;

state_idx = func_query_state_idx(dim_state_idx_list);
m_list = [state_idx];
num_m_state = size(m_list, 2);
n_list = [];
m_node_idx_list = [1];
n_node_idx_list = [];

while (num_m_state > 0)
    
    for s = 1:num_m_state
    
        m = m_list(s);        
        [num_subject, num_subject_truev, num_subject_interpov] = func_get_num_subject_pass_a_state(m);                    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        if (step == 1)            
            state_mu_list = func_print_state_mu_list(m);
            
            if (is_draw_truev_subject_num == 1)
                info_str = sprintf('%s#%d(%d, %d)', state_mu_list, num_subject, num_subject_truev, num_subject_interpov);
            else
                info_str = sprintf('%s#%d', state_mu_list, num_subject);
            end
            
            num_node = num_node + 1;
            node_list{num_node}.parent_node_idx = 0;
            node_list{num_node}.num_subject = num_subject;
            node_list{num_node}.state_idx = m; 
            node_list{num_node}.info = info_str;                        
        end
        parent_node_idx = m_node_idx_list(s);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        %% plot the most probable link
        sum_link = sum(Q_mat_struct(m, :));
        
        if (sum_link > 0)
            
            [C, n] = max(Q_mat(m, :));            
            if (C ~= 0 && Nrs_mat(m, n) > 0) % if count > 0
        
                I = find(Q_mat(m, :) == C);                
                %I  = find(Q_mat(m, :) > 0);
                                
                num_strong_link = size(I, 2);
                
                node_list{parent_node_idx}.num_child = num_strong_link;
                node_list{parent_node_idx}.child_list = cell(num_strong_link, 1);
                
                for t = 1:num_strong_link                 % for each n
                    
                    n = I(t);                                                        
                    
                    link_count = Nrs_mat(m, n);
                    link_prob = double(link_count) / double(sum(Nrs_mat(m, :)) - Nrs_mat(m, m));
                    
                    n_list = [n_list n]; 

                    subject_id_list = Sr_list{n}.subject_id_list;
                    num_subject = size(subject_id_list, 2);                    
                    state_mu_list = func_print_state_mu_list(n);
                    info_str = sprintf('%s#%d', state_mu_list, num_subject);                    

                    num_node = num_node + 1;                    
                    n_node_idx_list = [n_node_idx_list num_node];
                    
                    node_list{num_node}.parent_node_idx = parent_node_idx;
                    node_list{num_node}.num_subject = num_subject;
                    node_list{num_node}.state_idx = n;
                    node_list{num_node}.info = info_str;                  
           
                    node_list{parent_node_idx}.child_list{t}.node_idx = num_node;
                    
                    [link_num_subject, link_num_subject_truev, link_num_subject_interpov] = func_get_num_subject_pass_a_link(m, n);
                    node_list{parent_node_idx}.child_list{t}.link_subject_count = [link_num_subject, link_num_subject_truev, link_num_subject_interpov];
                    node_list{parent_node_idx}.child_list{t}.link_prob = link_prob;                    
                    node_list{parent_node_idx}.child_list{t}.state_idx = n;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                        
                end % t                
            end % c
        end % sum_link
        
    end % s
    
    m_list = n_list;
    n_list = [];
    
    num_m_state = size(m_list, 2);
    m_node_idx_list = n_node_idx_list;
    n_node_idx_list = [];
    
    step = step + 1;    
    
end % num_cur_state > 0

%% draw the tree structure
parent_node_idx_list = zeros(num_node, 1);
for n = 1:num_node    
    parent_node_idx_list(n) = node_list{n}.parent_node_idx;
end
[X, Y] = treelayout(parent_node_idx_list);

for n = 1:num_node

    x_pos = X(n);
    y_pos = Y(n);
       
    %% draw current state
    s = node_list{n}.state_idx;    
    num_subject = node_list{n}.num_subject;    
    marker_size = min_marker_size + double(num_subject) / double(max_num_subject) * double(max_marker_size - min_marker_size);
    dim_states = state_list{s}.dim_states;
    
    face_color = [0 1 0];
    for d = 2:dim
       if (dim_states(d) < dim_states(1)) % if there is some skill delay
           face_color = [1 0 0];
           break;
       end
    end
    
    plot(x_pos, y_pos,'ro', 'MarkerEdgeColor','k',...
                          'MarkerFaceColor', face_color,...
                          'MarkerSize', marker_size);
    label = node_list{n}.info;        
    if (is_draw_truev_subject_num == 1)
        fontsize = 6;
    else
        fontsize = 8;
    end
    text(x_pos + 0.01, y_pos + 0.01, label, 'Color', [0 0 0], 'FontSize', fontsize);
    hold on;
    
end    
    
for n = 1:num_node

    %% draw current state
    s = node_list{n}.state_idx;    

    %% draw link lines
    num_child = node_list{n}.num_child;   
    for c = 1:num_child
        
        child_node_idx = node_list{n}.child_list{c}.node_idx;
        child_link_count = node_list{n}.child_list{c}.link_subject_count;
        child_link_prob = node_list{n}.child_list{c}.link_prob;
        child_state_idx = node_list{n}.child_list{c}.state_idx;        
        line_width = min_line_width + double(child_link_count(1)) / double(max_link_info) * double(max_line_width-min_line_width);        

        is_regress_nb = func_check_is_regress_neighbor(state_list{s}.dim_states, state_list{child_state_idx}.dim_states);
        if (is_regress_nb == 1)
            line_color = [1 0 0];  % regression link, red
        else
            line_color = [0 0 0];  % black
        end      
        
        %plot([X(n) X(child_node_idx)], [Y(n) Y(child_node_idx)], '-r',  'LineWidth', line_width, 'color', line_color);
        arrow([X(n) Y(n)], [X(child_node_idx) Y(child_node_idx)], 10, 'LineStyle', '-', 'EdgeColor',line_color,'FaceColor',line_color, 'LineWidth', line_width, 'BaseAngle', 20, 'TipAngle', 10);
        arrow FIXLIMITS;
        hold on;

        x = (X(n) + X(child_node_idx)) / 2.0 + 0.015;
        y = (Y(n) + Y(child_node_idx)) / 2.0 + 0.015;
        
        if (is_draw_truev_subject_num == 1)
           label = sprintf('#%d(%d,%d)(%.2f)', child_link_count(1), child_link_count(2), child_link_count(3), child_link_prob);
           fontsize = 6;
        else           
           label = sprintf('#%d(%.2f)', child_link_count(1), child_link_prob);             
           fontsize = 8;
        end
        
        text(x,y,label, 'Color', [0 0 1], 'FontSize', fontsize);
        hold on;        
    end
    
end

%treeplot(treeVec);
xlim([(min(X)-0.1) (max(X)+0.1)]);
ylim([(min(Y)-0.1) (max(Y)+0.1)]);

dim_type_str = func_print_dim_name_list();
title(dim_type_str);
