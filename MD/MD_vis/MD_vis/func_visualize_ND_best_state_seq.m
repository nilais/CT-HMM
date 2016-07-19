function func_visualize_ND_best_state_seq_Autism_age(fig_id, subject_data)

global data_setting;
global state_list;
dim = data_setting.dim;

if (dim == 2)                    

    func_visualize_2D_best_state_seq(fig_id, subject_data);        

elseif (dim == 3)
    
    func_visualize_3D_best_state_seq_Autism_age(fig_id, subject_data);    
    
else
    
    figure(fig_id),
    
    marker_size = 10;
    line_width = 2;
    
    instant_state_seq = subject_data.instant_state_seq;
    instant_trvisit_seq = subject_data.instant_trvisit_seq;
    num_instant_state = size(instant_state_seq, 2);

    %% setup subsplot for path drawing    
    idx_list = [];
    for d = 1:dim        
        begin_idx = (d-1)*dim + 1;
        end_idx = begin_idx + dim - 2;
        idx_list = [idx_list begin_idx:end_idx];
    end    
    subplot(dim, dim, idx_list);
    
    for s = 1:num_instant_state
   
        m = instant_state_seq(s);
        dim_states = state_list{m}.dim_states;
        
        %% if there is any skill delay, show red state, otherwise, show green state
        age_dim_idx = dim_states(1);
        face_color = [0 1 0];
        for d = 2:dim
            if (dim_states(d) < age_dim_idx) 
                face_color = [1 0 0];
                break;
            end
        end
        
        %% true visit, draw circle, interpolated visit, draw square
        if (instant_trvisit_seq(s) == 1) % if this visit is from the true visit data
            marker_shape = 'o';
        else % if this visit is a virtual visit inserted by the model            
            marker_shape = 's';            
        end
        marker_size = 20;
        plot(1, -s, marker_shape, 'MarkerEdgeColor','k', ...
                                 'MarkerFaceColor', face_color,...
                                 'MarkerSize', marker_size);        
    
        %% draw state text
        state_mu_list = func_print_state_mu_list(m);                                
        text(1+0.2, -s, state_mu_list, 'Color', [0 0 0], 'FontSize', 10);        
        hold on;       
    end % s
    
    %% then draw all arrows
    for s = 1:num_instant_state
   
        m = instant_state_seq(s);
        if (s == num_instant_state)
            break;
        end
    
        %% draw link to the next state
        n = instant_state_seq(s+1);
        m_states = state_list{m}.dim_states;
        n_states = state_list{n}.dim_states;                        
        is_regress_nb = func_check_is_regress_neighbor(m_states, n_states);
        if (is_regress_nb == 1)
            line_color = [1 0 0];  % regression link, red
        else
            line_color = [0 0 0];  % black
        end       
        
        %plot([1 1], [-s -(s+1)], '-',  'LineWidth', line_width, 'color', line_color);        
        %arrow([1 -s], [1 -(s+1)], 16, 'LineStyle', '-', 'EdgeColor', line_color,'FaceColor', line_color, 'LineWidth', line_width); %, 'BaseAngle', 20, 'TipAngle', 10);
        arrow([1 -s], [1 -(s+1)], 14, 'LineStyle', '-', 'EdgeColor', line_color,'FaceColor', line_color, 'LineWidth', line_width, 'BaseAngle', 20, 'TipAngle', 10);
        arrow FIXLIMITS;
        hold on;
        
    end % s
    
    xlim([0 2]);
    ylim([-(num_instant_state+1) 0]);

    %% draw title string
    dim_type_str = func_print_dim_name_list();
    titlestr = sprintf('Subject ID = %d, %s', subject_data.ID, dim_type_str);
    title(titlestr);
    hold on;

    %% draw raw data and linear slope
    num_visit = subject_data.num_visit;
    visit_list = subject_data.visit_list;
    
    %% set up time list T_ls
    T_ls = zeros(num_visit, 1);
    for v = 1:num_visit
        t = double(visit_list{v}.time); % in year
        T_ls(v) = t * 12; % show in month for autism
    end    

    %% set up data_ls
    type_name_ls = data_setting.type_name_ls;
        
    %% for each dimension, gather data, and compute slope    
    for i = 2:dim    
        
        %% set up sub plot position
        subplot(dim, dim, (i-1)*dim);
        axis equal;
        
        %% gather visit data
        data_ls = zeros(num_visit, 1);    
        for v = 1:num_visit            
            data_ls(v) = visit_list{v}.data(i);
        end

        %% plot scatter data point
        scatter(T_ls, data_ls, 'filled');
        hold on;
        xlabel('month');        
        
        %% compute linear and robust regression
        if (num_visit > 1)
        
            x = T_ls;
            y = data_ls;        
            bls = regress(y, [ones(num_visit, 1) x]);
            set(gca, 'FontSize', 5);

            %% plot linear regression line
            plot(x,bls(1)+bls(2)*x,'m','LineWidth',2);
            set(gca, 'FontSize', 10);
            titlestr = sprintf('%s [slope:%.2f]', type_name_ls{i}, bls(2));
            
        else
            titlestr = sprintf('%s', type_name_ls{i});
        end
        title(titlestr);
        
    end
   
end % if dim > 3
