function func_visualize_3D_best_state_seq_Autism_age(fig_id, subject_data)

global state_list;
global data_setting;

figure(fig_id),

marker_size = 8;
line_width = 4;

instant_state_seq = subject_data.instant_state_seq;
instant_trvisit_seq = subject_data.instant_trvisit_seq;

num_instant_state = size(instant_state_seq, 2);

subplot(4, 5, [1 2 3 4 6 7 8 9 11 12 13 14 16 17 18 19]);
titlestr = sprintf('Subject ID = %d', subject_data.ID);

for s = 1:num_instant_state

    %%%%%%%%%%%%%%%    
    m = instant_state_seq(s);
    
    dim_states = state_list{m}.dim_states;
    i = dim_states(1);
    j = dim_states(2);
    k = dim_states(3);
    if (j < i || k < i) % i: age, means that the development is slower than the age-eq performance
        face_color = [1 0 0];
    else
        face_color = [1 1 1];
    end    
    
    if (instant_trvisit_seq(s) == 1) % if this visit is from the true visit data
        plot3(i,j,k,'o', 'MarkerEdgeColor','k',...
                      'MarkerFaceColor', face_color,...
                      'MarkerSize', marker_size);
    
    else % if this visit is a virtual visit inserted by the model
        plot3(i,j,k,'s', 'MarkerEdgeColor','k',...
                      'MarkerFaceColor', face_color,...
                      'MarkerSize', marker_size);    
    end
    
                  
    label = sprintf('(%d,%d,%d)', i, j, k);        
    text(i,j,k,label, 'Color', [0 0 0], 'FontSize',5);
    hold on;
       
    if (s == num_instant_state)
        break;
    end
    
    n = instant_state_seq(s+1);
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
  
    %%%%%%%%%%%%%%%

end % s

grid on;
hold on;

axis equal;

type_name_ls = data_setting.type_name_ls;
xlabel(type_name_ls{1});
ylabel(type_name_ls{2});
zlabel(type_name_ls{3});
title(titlestr);

xlim([0 data_setting.dim_state_num_ls(1)]);
ylim([0 data_setting.dim_state_num_ls(2)]);
zlim([0 data_setting.dim_state_num_ls(3)]);

%%%%%%%%%%%%%%%%%%%%%%%%%
num_visit = subject_data.num_visit;
visit_list = subject_data.visit_list;
%% set up T_ls
T_ls = zeros(num_visit, 1);
for v = 1:num_visit    
    T_ls(v) = visit_list{v}.time;
end    

%% set up data_ls
type_name_ls = data_setting.type_name_ls;
subplot_idx = [5 10 15];
data_slope = zeros(2, 3); % data types, 2 slopes (lin, robust)

for i = 1:3    
    data_ls = zeros(num_visit, 1);    
    for v = 1:num_visit        
        data = visit_list{v}.data(i);
        data_ls(v) = data;
    end
    
    % set up sub plot position
    subplot(4, 5, subplot_idx(i));
    %% compute linear and robust regression
    x = T_ls;
    y = data_ls;
    bls = regress(y, [ones(num_visit, 1) x]);
    set(gca, 'FontSize', 5);
    scatter(T_ls, data_ls, 'filled');
    hold on;    
    plot(x,bls(1)+bls(2)*x,'m','LineWidth',2);
    set(gca, 'FontSize', 10);
    xlabel('Year');    
    str = sprintf('%s [slope:%.2f]', type_name_ls{i}, bls(2));
    title(str);    
    
    data_slope(1, i) = bls(2);
end


