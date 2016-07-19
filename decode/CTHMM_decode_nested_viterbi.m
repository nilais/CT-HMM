function [outer_state_seq, outer_dur_seq, outer_log_prob, all_state_seq, all_dur_seq] = CTHMM_decode_nested_viterbi(subject_data)

global Q_mat_struct;

outer_state_seq = [];
outer_dur_seq = [];
outer_log_prob = -inf;
all_state_seq = [];
all_dur_seq = [];

num_visit = subject_data.num_visit;
if (num_visit == 0)
    return;
end

%% Viterbi decoding of the outer state sequence       
[outer_state_seq, outer_dur_seq, outer_log_prob, is_invalid] = CTHMM_decode_outer_viterbi(subject_data);

if (is_invalid == 1)
    return ;
end

max_state_seq_len = 1000;
all_state_seq = zeros(max_state_seq_len, 1);
all_dur_seq = zeros(max_state_seq_len, 1);
all_state_len = 0;

%% for each visit segment, sample the inner paths
for v = 1:(num_visit - 1)

    total_dur = outer_dur_seq(v);
    
    begin_s_idx = outer_state_seq(v);
    end_s_idx = outer_state_seq(v+1);

    if (begin_s_idx == end_s_idx)        
        best_inner_path = begin_s_idx; % we assume the simplest case    
        inner_dur_list = total_dur;
    elseif (Q_mat_struct(begin_s_idx, end_s_idx) == 1) % adjacent states
        best_inner_path = [begin_s_idx end_s_idx]'; % we assume the simplest case
        inner_dur_list = [total_dur 0];
    else %% find the most probable inner path               
        [best_inner_path, inner_log_prob] = CTHMM_decode_inner_viterbi_uniformdur(begin_s_idx, end_s_idx, total_dur);       
    end
    
    
     num_inner_state = size(best_inner_path, 1);   
     
    if (num_inner_state > 1)
        uniform_dur = total_dur / (num_inner_state-1);
        inner_dur_list = zeros(num_inner_state, 1);
        inner_dur_list(1:num_inner_state-1) = uniform_dur;
    else
        inner_dur_list = total_dur;  
    end
    
    %% append the state path    
    if (all_state_len == 0)        
        all_state_seq(1:num_inner_state) = best_inner_path;
        all_dur_seq(1:num_inner_state) = inner_dur_list;
        all_state_len = num_inner_state;
    else        
        idx_beg = all_state_len;
        idx_end = idx_beg + num_inner_state - 1;
        all_state_seq(idx_beg:idx_end) = best_inner_path;         
        all_dur_seq(idx_beg) = all_dur_seq(idx_beg) + inner_dur_list(1); %% accumulate duration for the first state
        all_dur_seq((idx_beg+1):idx_end) = inner_dur_list(2:end);
        all_state_len = all_state_len + num_inner_state - 1;
    end
    
end % v

all_state_seq = all_state_seq(1:all_state_len);
all_dur_seq = all_dur_seq(1:all_state_len);
     