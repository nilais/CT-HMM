function color = CTHMM_vis_compute_dwell_time_color(dwell_time)

global dwelling_time_draw_range_list;
global dwelling_time_draw_color_list;

%range_list = [0 6 12 18 24] / 12.0; %in year
%color_list = [0 0 128; 0 255 0; 255 0 0; 255 0 0; 255 0 0];

range_list = dwelling_time_draw_range_list;
color_list = dwelling_time_draw_color_list;

num_range = size(range_list, 2);

t = dwell_time;
for r = 1:(num_range-1)
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
    color = color_list(end, :);
end
color = color ./ 255.0;
for k = 1:3
    if (color(k) > 1.0)
        color(k) = 1.0;
    end
end
                
end