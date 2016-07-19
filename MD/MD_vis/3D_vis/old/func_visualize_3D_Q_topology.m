function func_visualize_3D_Q_topology(fig_id)

global Q_mat_struct;
global state_list;
global data_info;

num_state = size(state_list, 1);
hold off;
if (fig_id ~= -1)
    figure(fig_id),
end

%% plot states
for s = 1:num_state                
    
    x = state_list{s}.dim_stages(1);
    y = state_list{s}.dim_stages(2);
    z = state_list{s}.dim_stages(3);
    
    if (z == 0)
        face_color = [0 1 0];
    elseif (z == 1)
        face_color = [0 0 1];
    elseif (z == 2)
        face_color = [0 1 1];
    elseif (z == 3)
        face_color = [1 1 0];
    elseif (z == 4)    
        face_color = [1 0 0];
    end
        
        
    plot3(x,y,z,'ro', 'MarkerEdgeColor','k',...
                       'MarkerFaceColor', face_color,...
                       'MarkerSize',5);
    %label = sprintf('(%d,%d,%d)', x, y, z);
    hold on;                
end

set(gca, 'FontSize', 12);
xlabel('biochemical');
ylabel('structural');
zlabel('function');

hold on;

%% plot arrows

