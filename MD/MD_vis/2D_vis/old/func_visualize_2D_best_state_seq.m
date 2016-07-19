function func_visualize_2D_best_state_seq(fig_id, subject_data)

global state_list;
global data_setting;


global is_draw_link_arrow;

fontsize = 3;

figure(fig_id),

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

    %t = double(visit_list{v}.month) / 12.0;
    
    t = double(visit_list{v}.day)  - double(visit_list{1}.day);
    
    T_ls(v) = t;
    
    
end    

%% set up data_ls
type_name_ls = data_setting.type_name_ls;
subplot_idx = [5 10];
data_slope = zeros(2, 3); % data types, 2 slopes (lin, robust)

for i = 1:2
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
    
    xlabel('Time');
    
    str = sprintf('%s [slope:%.2f]', type_name_ls{i}, bls(2));
    title(str);    
    
    data_slope(1, i) = bls(2);
end

%% plog diagnosis

%diag = zeros(num_visit, 1);
%for v = 1:num_visit
%    diag(v) = subject_data.visit_list{v}.DXCURREN;    
%end


%subplot(4, 5, 20);
%bar(T_ls, diag);

%%%%%%%%%%%%%%%%%%%%%%%%
subplot(4, 5, [1 2 3 4 6 7 8 9 11 12 13 14 16 17 18 19]);

%titlestr = sprintf('RID=%d: ', subject_data.RID);

for u = 1:num_unique_state
        
    dur = unique_dur_list(u);
    m = unique_state_seq(u);
    m_states = state_list{m}.dim_states;
    
    %% plot state
    if (unique_trvisit_list(u) == 1) % true visit state, blue
        state_mark = 'go';
    else
        state_mark = 'gs';
    end
     
    if (data_setting.draw_origin_lefttop == 1)
            plot(m_states(1), -m_states(2),state_mark,'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize', 8);
    else
            plot(m_states(1), m_states(2),state_mark,'MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize', 8);
    end
        
    
    %% plot link
    if (u < num_unique_state)  % draw line  
        n = unique_state_seq(u+1);
        n_states = state_list{n}.dim_states;
        line_color = [0 0 0];
        
        
        
        if (data_setting.draw_origin_lefttop == 1)
            draw_point1 = [m_states(1) -m_states(2)];
            draw_point2 = [n_states(1) -n_states(2)];
        else
            draw_point1 = [m_states(1) m_states(2)];
            draw_point2 = [n_states(1) n_states(2)];  
        end
        
        if (draw_point1(2) == draw_point2(2))
            if (draw_point1(1) > draw_point2(1))
                draw_point1(2) = draw_point1(2) + 0.1;
                draw_point2(2) = draw_point2(2) + 0.1;
            else
                draw_point1(2) = draw_point1(2) - 0.1;
                draw_point2(2) = draw_point2(2) - 0.1;
            end
        end

        if (draw_point1(1) == draw_point2(1))
            if (draw_point1(2) > draw_point2(2))
                draw_point1(1) = draw_point1(1) + 0.1;
                draw_point2(1) = draw_point2(1) + 0.1;
            else
                draw_point1(1) = draw_point1(1) - 0.1;
                draw_point2(1) = draw_point2(1) - 0.1;
            end
        end

        if (draw_point1(1) ~= draw_point2(1) && draw_point1(2) ~= draw_point2(2))
            if (draw_point1(1) > draw_point2(1))
                draw_point1(1) = draw_point1(1) + 0.1;
                draw_point2(1) = draw_point2(1) + 0.1;
            else
                draw_point1(1) = draw_point1(1) - 0.1;
                draw_point2(1) = draw_point2(1) - 0.1;
            end
        end

        
        if (data_setting.draw_origin_lefttop == 1)
            
             if (is_draw_link_arrow == 1)
                arrow(draw_point1, draw_point2, 7, 'LineStyle', '-', 'EdgeColor',line_color,'FaceColor',line_color, 'LineWidth', 2);                    
             else
                plot([m_states(1) n_states(1)], [-m_states(2) -n_states(2)], '-k',  'LineWidth', 2, 'color', line_color);
             end            
        else
        
            if (is_draw_link_arrow == 1)
                arrow(draw_point1, draw_point2, 7, 'LineStyle', '-', 'EdgeColor',line_color,'FaceColor',line_color, 'LineWidth', 2);                    
            else
                plot([m_states(1) n_states(1)], [m_states(2) n_states(2)], '-k',  'LineWidth', 2, 'color', line_color);
            end
                        
        end
        
        
        
        
        hold on;
    end    
        
    %% draw state coordinates and duration   
    i = state_list{m}.dim_states(1);
    j = state_list{m}.dim_states(2);
    
    %str = sprintf('(%d,%d)(%.1f yr)', i, j, dur);
    str = sprintf('%.1f', dur);
    
    if (data_setting.draw_origin_lefttop == 1)
        text(m_states(1)+0.2, -m_states(2)+0.2,str, 'Color', [0 0 1], 'FontSize',5);
    else
        text(m_states(1)+0.2, m_states(2)+0.2,str, 'Color', [0 0 1], 'FontSize',5);
    end

    %if (size(titlestr, 1) > 0)
    %    titlestr = sprintf('%s -> %s', titlestr, str);
    %else
    %    titlestr = str;
    %end
    
    hold on;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% draw text for true visit
v = 1;
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

    %if (data_setting.draw_origin_lefttop == 1)
    %    plot(m_states(1),-m_states(2),'bo','MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize', 8);
    %else
    %    plot(m_states(1),m_states(2),'bo','MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize', 8);
    %end
    
    
%% for Alzeheimer dataset    
%     if (diag(v) == 1)
%         plot(m_states(1),-m_states(2),'go','MarkerEdgeColor','k', 'MarkerFaceColor','g', 'MarkerSize', 8);
%     elseif (diag(v) == 2)
%         plot(m_states(1),-m_states(2),'bo','MarkerEdgeColor','k', 'MarkerFaceColor','b', 'MarkerSize', 8);
%     elseif (diag(v) == 3)
%         plot(m_states(1),-m_states(2),'ro','MarkerEdgeColor','k', 'MarkerFaceColor','r', 'MarkerSize', 8);
%     end
    
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

%titlestr = sprintf('ID = %d, class = %s',  subject_data.ID, subject_data.classname);
%titlestr = sprintf('ID = %d, eye = %s, base age = %.1f',  subject_data.ID, subject_data.eye{1}, subject_data.visit_list{1}.age);
titlestr = sprintf('RUID = %d, segment idx = %d',  subject_data.RUID, subject_data.segment_idx);
title(titlestr);

if (data_setting.draw_origin_lefttop == 1)
    %xlim([(0-2) (data_setting.dim_state_num_ls(1)+1)]);
    %ylim([(-data_setting.dim_state_num_ls(2)-1) (0+2)]);
    xlim([0 (data_setting.dim_state_num_ls(1)+1)]);
    ylim([(-data_setting.dim_state_num_ls(2)-1) 0]);    
else
    %xlim([(0-2) (data_setting.dim_state_num_ls(1)+1)]);
    %ylim([(0-2) (data_setting.dim_state_num_ls(2)+1)]);    
    xlim([0 (data_setting.dim_state_num_ls(1)+1)]);
    ylim([0 (data_setting.dim_state_num_ls(2)+1)]);    
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


axis equal;


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

