function  [best_state_seq, best_log_prob] = CTHMM_decode_inner_viterbi_uniformdur(s1, s2, dur)

global state_list;
global data_setting;

max_path_len = 1;
for d = 1:data_setting.dim
    diff = abs(state_list{s2}.dim_states(d) - state_list{s1}.dim_states(d));
    max_path_len = max_path_len + diff;
end

best_log_prob = -inf;

for l = 2:max_path_len   
    
    len = l;
    
    
    step = len - 1;
    uniform_dur = double(dur) / double(step);
    
    
    [temp_best_state_seq, temp_best_log_prob] = CTHMM_inner_decoding_viterbi_uniformdur_fixpathlen(s1, s2, step, uniform_dur);
    
    if (temp_best_log_prob > best_log_prob)
        best_log_prob = temp_best_log_prob;
        best_state_seq = temp_best_state_seq;
    end
    
end    


