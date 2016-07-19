function log_Pt = CTHMM_precompute_get_inner_distinct_time_log_Pt(t_delta)

global inner_distinct_time_list;
global inner_distinct_time_log_Pt_list;
global time_diff_tol;

num_distinct_time = size(inner_distinct_time_log_Pt_list, 1);
find = 0;

for i = 1:num_distinct_time
    if (abs(inner_distinct_time_list(i) - t_delta) < time_diff_tol)
        log_Pt = inner_distinct_time_log_Pt_list{i};
        find = 1;
        break;
    end
end

global Q_mat;

if (find == 0)
    log_Pt = log(expm(Q_mat * t_delta));
end        
