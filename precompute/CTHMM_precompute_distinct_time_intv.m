function [distinct_time_list] = CTHMM_precompute_distinct_time_intv(train_idx_list)

global obs_seq_list;
global max_visit_count;
global time_diff_tol;

time_diff_tol = 0.0000001;

%global sample_intv_list;
%distinct_time_list = sample_intv_list;
%return;

%=======================================================================================================================

%% check how many distinct times in the dataset
num_train_subject = size(train_idx_list, 1);

time_list = zeros(max_visit_count, 1);
cur_time_idx = 0;

for g = 1:num_train_subject               

    % get the subject index
    subject_idx = train_idx_list(g);
    num_visit = obs_seq_list{subject_idx}.num_visit;        
    
    % subject data
    if (num_visit == 0)
        continue;
    end

    visit_time_list = obs_seq_list{subject_idx}.visit_time_list; 
    delta_time_list = zeros(num_visit-1, 1);
    for v = 1:(num_visit-1)
       delta_time_list(v) = visit_time_list(v+1) - visit_time_list(v);           
    end

    time_list((cur_time_idx+1):(cur_time_idx+num_visit-1)) = delta_time_list;
    cur_time_idx = cur_time_idx + num_visit - 1;

    %Pt = expm(Q_mat * t_delta);
    %Pt_list{v} = Pt;

end % g

num_distinct_time = 0;
distinct_time_list = zeros(cur_time_idx, 1);

for i = 1:cur_time_idx

    t = time_list(i);
    find = 0;
    for d = 1:num_distinct_time
        if (abs(t - distinct_time_list(d)) < time_diff_tol)            
            find = 1;
            break;
        end
    end
    
    if (find == 0)
        num_distinct_time = num_distinct_time + 1;
        distinct_time_list(num_distinct_time) = t;
    end
end
distinct_time_list = distinct_time_list(1:num_distinct_time);

str = sprintf('num_distinct_time = %d\n', num_distinct_time);
CTHMM_print_log(str);

%temp = uniquetol(time_list);
%distinct_time_list = temp';
    