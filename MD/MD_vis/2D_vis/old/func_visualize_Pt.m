function func_visualize_Pt(Pt, t, fig_id)

global state_list;
global main_struc_range_list;
global Q_mat_struct;

global Tr_list;
global Nrs_mat;
global Q_mat;

func_visualize_Q_topology(fig_id);
hold on;
font_size = 5;

%% plot state Tr
num_state = size(state_list, 1);


% for s = 1:num_state                
%     
%     [pt] = func_get_state_draw_position(s);
%     x = pt(1); y = pt(2);
%     
%     %pss = Pt(s,s);    
%     %str = sprintf('%.2f', pss);
%     %text(x+0.1,y+1, str, 'FontSize', font_size, 'Color', [0.0 0.0 0.5]);
% end

%% plot transition prob at each arrow
%% plot arrows
num_struc_range = size(main_struc_range_list, 2) - 1;

for m = 1:num_state
    for n = m:(m+num_struc_range+10)
        if (n > num_state)
            break;
        end        
        
        
        if (Q_mat_struct(m, n) == 1)            
            [p1] = func_get_state_draw_position(m);
            [p2] = func_get_state_draw_position(n);    
            x1 = p1(1); y1 = p1(2);
            x2 = p2(1); y2 = p2(2);
                                           
            %% transition intensity                          
            if (n == state_list{m}.f_degen_link)                
                x = (x1+x2)/2 + 0.2;
                y = (y1+y2)/2 + 1;                
            elseif (n == state_list{m}.sf_degen_link)
                x = (x1+x2)/2 + 0.07;
                y = (y1+y2)/2 + 0.5;
            else % s link
                x = (x1+x2)/2 + 0.1;
                y = (y1+y2)/2 + 0.05;
            end
            
            prs = Pt(m,n);
            %str = sprintf('%.2f', prs);
            %text(x,y, str, 'FontSize', font_size, 'Color', [0.0 0.0 0.0]);
            hold on;
        end % if
    end % n
    
    
    dwell_time = 1 / -Q_mat(m,m);
        
    row_Nrs = Nrs_mat(m, :);
    row_Nrs(m) = 0;
    sum_trans = sum(row_Nrs);
    
    if (dwell_time == inf || dwell_time == -inf || Tr_list(m) == 0.0 || sum_trans == 0.0)
        
        [p1] = func_get_state_draw_position(m);
        x = p1(1); y = p1(2);
        %plot(x,y,'ko','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10);
        plot(x,y,'yo','MarkerEdgeColor','k','MarkerFaceColor','y','MarkerSize',10);
        
    else
    
        sum_link = sum(Q_mat_struct(m, :));
    
        if (sum_link > 0)    
            % plot the strongest link
            temp = Pt(m, :);

            %temp(m) = 0;

            [C, n] = max(temp);

            if (n == m)

                [p1] = func_get_state_draw_position(n);
                x = p1(1); y = p1(2);   
                plot(x,y,'yo','MarkerEdgeColor','k','MarkerFaceColor','y','MarkerSize',10);

            elseif (C ~= 0)

                I = find(temp == C);
                num_strong_link = size(I, 2);

                for i = 1:num_strong_link

                    n = I(i);
                    [p0] = func_get_state_draw_position(m);
                    [p1] = func_get_state_draw_position(n);  
                    color = [0.0 0.0 1.0]; % blue
                    thick = 4;
                    vectarrow(p0,p1,color,thick);
                    hold on;
                end
            end

        end %if (sum_link > 0) 
        
    end
    
end % m

set(gca, 'FontSize', 12);
str = sprintf('P(%d years)', t);
title(str);
    


