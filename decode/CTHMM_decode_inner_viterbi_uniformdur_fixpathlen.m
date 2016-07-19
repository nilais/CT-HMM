function [best_state_seq, best_log_prob] = CTHMM_decode_inner_viterbi_uniformdur_fixpathlen(s1, s2, step, uniform_dur)

global state_list;
global Q_mat;
global Q_mat_struct;


num_state = size(state_list, 1);

%% num visit
num_visit = step+1;

%% create two matrix T1, T2 to store decoding results
T1 = -inf * ones(num_state, num_visit); % best prob so far
T2 = zeros(num_state, num_visit); % backtracking pointer

%% init T1 and T2 at visit 1
T1(s1, 1) = log(1);
    
%% for visit 2 to the last visit
%% compute Pt    
t_delta = uniform_dur;


Pt = expm(t_delta * Q_mat);        
%Pt = matlab_expm_At(Q_mat, t_delta);

    
for v = 2:num_visit
    for s = 1:num_state % current state
                
        %% T1(s, v) = max_k (T1(k, v-1) * Pks(t(v) - t(v-)) * state_emiss(s, yv);
        %% T2(s, v) = arg max_k (T1(k, v-1) * Pks(t(v) - t(v-)) * state_emiss(s, yv);
                        
        %% find best previous state
        best_k = 0;
        best_log_prob = -inf;
        
        for k = 1:num_state % previous state            
           
            if (Q_mat_struct(k, s) == 1) % has a link, which means k, s are different state
               log_prob = T1(k, v-1) + log(Pt(k, s));
               if (log_prob > best_log_prob)
                    best_k = k;
                    best_log_prob = log_prob;
               end
            end
           
        end
        
        
        
        T1(s, v) = best_log_prob;
        T2(s, v) = best_k;        
    end % s
end % v

%% start backtracking of state sequence
best_state_seq = zeros(num_visit, 1);

%% find best last state
best_last_s = s2;
best_log_prob = T1(s2, num_visit);
best_state_seq(num_visit) = best_last_s;

no_valid_path = 0;

%% start backgracking from the last state
for v = (num_visit-1) : -1 : 1
    
    if (best_last_s == 0)
        no_valid_path = 1;        
        break;
    end
    
    best_state_seq(v) = T2(best_last_s, v+1);
    best_last_s = best_state_seq(v);
end

if (no_valid_path == 1)
    best_state_seq = [];
    best_log_prob = -inf;
end

