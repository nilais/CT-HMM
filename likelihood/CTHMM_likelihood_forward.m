function [log_overall_prob] = CTHMM_likelihood_forward(obs_seq)

global state_list;
global state_init_prob_list;

global is_use_distinct_time_grouping;

num_visit = obs_seq.num_visit;
visit_time_list = obs_seq.visit_time_list;
%visit_data_list = obs_seq.visit_data_list;
num_state = size(state_list, 1);

ALPHA = zeros(num_visit, num_state); % time, num_state
C = zeros(num_visit, 1); % rescaling factor

%% init alpha for time 1
for s = 1:num_state   
    %data = visit_data_list(1, :);    
    %[emiss_prob] = func_state_emiss(s, data);    
    
    ALPHA(1, s) = state_init_prob_list(s) * obs_seq.data_emiss_prob_list(1, s);
end
C(1) = 1.0 /  sum(ALPHA(1, :));
ALPHA(1, :) = ALPHA(1, :) .* C(1);

for v = 2:num_visit   
    
    %% compute Pt    
    t_delta = visit_time_list(v) - visit_time_list(v-1);   
    
    if (is_use_distinct_time_grouping == 1)        
       Pt = CTHMM_precompute_get_distinct_time_Pt(t_delta);
    else    
       Pt = expm(Q_mat * t_delta); 
    end
    
    %% data
    %data = visit_data_list(v, :); 
    
    for s = 1:num_state % current state           
        %emiss_prob = func_state_emiss(s, data);
        emiss_prob = obs_seq.data_emiss_prob_list(v, s);
        
        prob = 0.0;
        for k = 1:num_state % for each previous state                       
           prob = prob + ALPHA(v-1, k) * Pt(k, s);
        end                
        prob = prob * emiss_prob;
        ALPHA(v, s) = prob;               
    end % s
    
    C(v) = 1.0 / sum(ALPHA(v, :));
    ALPHA(v, :) = ALPHA(v, :) .* C(v);

end % v

log_overall_prob = 0;
for v = 1:num_visit
    log_overall_prob = log_overall_prob - log(C(v));
end
