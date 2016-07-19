function log_Pt = CTHMM_precompute_get_distinct_time_log_Pt(t_delta)

global distinct_time_list;
global distinct_time_log_Pt_list;
global time_diff_tol;
global Q_mat;

num_distinct_time = size(distinct_time_log_Pt_list, 1);
find = 0;

for i = 1:num_distinct_time
    if (abs(distinct_time_list(i) - t_delta) < time_diff_tol)
        log_Pt = distinct_time_log_Pt_list{i};
        find = 1;
        break;
    end
end

if (find == 0)
    log_Pt = log(expm(Q_mat * t_delta));
end        


