function CTHMM_precompute_inner_distinct_time_Pt_list(max_jump)

global inner_distinct_time_list;
global inner_distinct_time_Pt_list;
global Q_mat;
global distinct_time_list;
global inner_distinct_time_log_Pt_list;
%global is_outer_soft;

num_time = size(distinct_time_list, 1);

inner_distinct_time_Pt_list = cell(num_time * max_jump, 1);
inner_distinct_time_list = zeros(num_time * max_jump, 1);
inner_distinct_time_log_Pt_list = cell(num_time * max_jump, 1);

idx = 0;
for i = 1:num_time
    
    for j = 1:max_jump
        idx = idx + 1;
        t_delta = distinct_time_list(i) / j;
        inner_distinct_time_list(idx) = t_delta;
        inner_distinct_time_Pt_list{idx} = expm(Q_mat * t_delta);        
        inner_distinct_time_log_Pt_list{idx} = log(inner_distinct_time_Pt_list{idx});        
    end
    
end

