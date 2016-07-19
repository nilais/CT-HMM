function func_visualize_3D_best_state_seq(subject_data, out_filename)

global state_list;
global subject_list;
global out_dir;
global data_setting;

figure(1),

%instant_state_seq = subject_data.instant_state_seq;
unique_state_seq = subject_data.unique_state_list;
unique_dur_list = subject_data.unique_dur_list;
unique_trvisit_list = subject_data.unique_trvisit_list;
ori_state_seq = subject_data.ori_state_seq;

num_unique_state = size(unique_state_seq, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%
num_visit = subject_data.num_visit;
visit_list = subject_data.visit_list;
%% set up T_ls
T_ls = zeros(num_visit, 1);
for v = 1:num_visit
    t = double(visit_list{v}.month) / 12.0;
    T_ls(v) = t;
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

%% plog diagnosis
diag = zeros(num_visit, 1);
for v = 1:num_visit
    diag(v) = subject_data.visit_list{v}.DXCURREN;    
end
subplot(4, 5, 20);
bar(T_ls, diag);

%%%%%%%%%%%%%%%%%%%%%%%%
subplot(4, 5, [1 2 3 4 6 7 8 9 11 12 13 14 16 17 18 19]);

titlestr = sprintf('ID=%d: ', subject_data.ID);

for u = 1:num_unique_state
        
    dur = unique_dur_list(u);
    m = unique_state_seq(u);
    m_states = state_list{m}.dim_states;
    
    %% plot state
    if (unique_trvisit_list(u) == 1) % true visit state, blue
        %plot3(m_states(1),m_states(2),m_states(3),'ko','MarkerEdgeColor','k', 'MarkerFaceColor','k', 'MarkerSize', 8);
    else % inner state
        plot3(m_states(1),m_states(2),m_states(3),'ks','MarkerEdgeColor','k', 'MarkerFaceColor','k', 'MarkerSize', 8);
    end

    %% plot link
    if (u < num_unique_state)  % draw line  
        n = unique_state_seq(u+1);
        n_states = state_list{n}.dim_states;
        line_color = [0 0 0];
        plot3([m_states(1) n_states(1)], [m_states(2) n_states(2)], [m_states(3) n_states(3)], '-k',  'LineWidth', 3, 'color', line_color);
        hold on;
    end    
        
    %% draw state coordinates and duration   
    i = state_list{m}.dim_states(1);
    j = state_list{m}.dim_states(2);
    k = state_list{m}.dim_states(3);    
    str = sprintf('(%d,%d,%d)(%.1f yr)', i, j, k, dur);     
    text(m_states(1)+0.5,m_states(2)+0.1,m_states(3)+0.1,str, 'Color', [0 0 1], 'FontSize',6);

    if (size(titlestr, 1) > 0)
        titlestr = sprintf('%s -> %s', titlestr, str);
    else
        titlestr = str;
    end
    
    hold on;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% draw text for true visit
v = 1;
start_v = 1;
num_visit = size(ori_state_seq, 1);
while (v <= num_visit)
    m = ori_state_seq(v);
    for t = v:num_visit    
        n = ori_state_seq(t);
        if (n ~= m)
            break;
        else
            end_v = t;
        end
    end    
    
    m_states = state_list{m}.dim_states;
    x = m_states(1);
    y = m_states(2);
    z = m_states(3);
    
    if (diag(v) == 1)
        plot3(m_states(1),m_states(2),m_states(3),'go','MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize', 8);
    elseif (diag(v) == 2)
        plot3(m_states(1),m_states(2),m_states(3),'bo','MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize', 8);
    elseif (diag(v) == 3)
        plot3(m_states(1),m_states(2),m_states(3),'ro','MarkerEdgeColor','k', 'MarkerFaceColor','r', 'MarkerSize', 8);
    end
    
%     if (end_v ~= num_visit)
%         dur = double(subject_data.visit_list{end_v+1}.month - subject_data.visit_list{start_v}.month) / 12.0;
%     else
%         dur = double(subject_data.visit_list{end_v}.month - subject_data.visit_list{start_v}.month) / 12.0;
%     end
%     if (start_v ~= end_v)
%         str = sprintf('(v%d-v%d)[%.1f])', start_v, end_v, dur);
%     else
%         str = sprintf('(v%d)[%.1f])', start_v, dur);
%     end
%     text(x+0.1, y+0.1, z-0.3, str, 'FontSize', 6, 'Color', [0.0 0.0 0.0]); % black string    
    hold on;        
    % update v
    start_v = end_v + 1;
    v = start_v;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

grid on;

xlabel(type_name_ls{1});
ylabel(type_name_ls{2});
zlabel(type_name_ls{3});
title(titlestr);

xlim([1 data_setting.dim_state_num_ls(1)]);
ylim([1 data_setting.dim_state_num_ls(2)]);
zlim([1 data_setting.dim_state_num_ls(3)]);


str = sprintf('%s\\%s', out_dir, out_filename);
saveas(gcf, str, 'png');

close(gcf);

%% plot fast progression link
% num_link = size(link_list, 1);
% %color_ls = {'r', 'm', 'c'};
% for n = 2:(num_link-1)
%     if (link_list{n}.fast_prog_status > 0)
%         r = link_list{n}.cur_s;
%         s = link_list{n}.next_s;        
%         [p1] = func_get_state_draw_position(r);
%         [p2] = func_get_state_draw_position(s);        
%         if (link_list{n}.fast_prog_status == 1)
%             color = [1.0 0.0 0.0]; % red    func fast, struct fast                
%         elseif (link_list{n}.fast_prog_status == 2)
%             color = [1.0 1.0 0.0]; % yellow struct fast
%         elseif (link_list{n}.fast_prog_status == 3)    
%             color = [0.0 1.0 1.0]; % purple func fast
%         end
%         thick = 2;    
%         vectarrow(p1, p2, color, thick);    
%         hold on;
%     end
% end

