function [Etij, log_prob, Pt_list] = CTHMM_decode_outer_forwbackw(obs_seq)

global Q_mat;
global state_list;
global state_init_prob_list;
global is_use_distinct_time_grouping;

%% compute alpha
num_visit = obs_seq.num_visit;
visit_time_list = obs_seq.visit_time_list;
%visit_data_list = obs_seq.visit_data_list;
num_state = size(state_list, 1);

if (obs_seq.has_compute_data_emiss_prob == 0)
    for v = 1:num_visit
        data = obs_seq.visit_list{v}.data;
        for m = 1:num_state            
            emiss_prob = mvnpdf(data, state_list{m}.mu, state_list{m}.sigma);
            obs_seq.data_emiss_prob_list(v,m) = emiss_prob; 
            %obs_seq.log_data_emiss_prob_list(v,m) = log(emiss_prob);
        end
    end
end

ALPHA = zeros(num_visit, num_state); % time, num_state
C = zeros(num_visit, 1); % rescaling factor

%% precomputing of Pt for every visit
Pt_list = cell(num_visit, 1);
for v = 1:(num_visit-1)
    %% transition matrix at each time point
    t_delta = visit_time_list(v+1) - visit_time_list(v);
    
    if (is_use_distinct_time_grouping == 1)        
        Pt_list{v} = CTHMM_precompute_get_distinct_time_Pt(t_delta);
    else
        Pt_list{v} = expm(Q_mat * t_delta);
    end
           
end

%% data emission probability
% data_emiss_prob_mat = zeros(num_visit, num_state);
% for v = 1:num_visit    
%     data = visit_data_list(v, :);
%     for s = 1:num_state
%         emiss_prob = mvnpdf(data, state_list{s}.mu, state_list{s}.sigma);        
%         %data_emiss_prob_mat(v, s) = func_state_emiss(s, data);
%         data_emiss_prob_mat(v, s) = emiss_prob;        
%     end
% end

%% init alpha for time 1
for s = 1:num_state
    ALPHA(1, s) = state_init_prob_list(s) * obs_seq.data_emiss_prob_list(1, s);
end
C(1) = 1.0 / sum(ALPHA(1, :));
ALPHA(1, :) = ALPHA(1, :) .* C(1);

for v = 2:num_visit
        
    for s = 1:num_state % current state
        prob = 0.0;
        for k = 1:num_state % for each previous state                       
           prob = prob + ALPHA(v-1, k) * Pt_list{v-1}(k, s);
        end                
        prob = prob * obs_seq.data_emiss_prob_list(v, s);
        ALPHA(v, s) = prob;               
    end % s
    % scaling
    C(v) = 1.0 / sum(ALPHA(v, :));
    ALPHA(v, :) = ALPHA(v, :) .* C(v);
end % v

%% compute beta
BETA = zeros(num_visit, num_state); % time, num_state

% init beta 
for s = 1:num_state       
    BETA(num_visit, s) = 1;
end
BETA(num_visit, :) = BETA(num_visit, :) .* C(num_visit);

for v = (num_visit-1):(-1):1

    for s = 1:num_state % current state        
        prob = 0.0;
        for k = 1:num_state % for each next state                       
           prob = prob + Pt_list{v}(s, k) * obs_seq.data_emiss_prob_list(v+1, k) * BETA(v+1, k);           
        end                
        BETA(v, s) = prob;               
    end % s    
    BETA(v, :) = BETA(v, :) .* C(v);
end

%% compute Etij
Etij = zeros(num_visit, num_state, num_state);

for v = 1:(num_visit-1)
    
    for i = 1:num_state        
        for j = 1:num_state
            Etij(v, i, j) = ALPHA(v, i) * Pt_list{v}(i, j) * obs_seq.data_emiss_prob_list(v+1, j) * BETA(v+1, j);
        end
    end
    sum_Etij = sum(Etij(v, :));
    Etij(v, :, :) = Etij(v, :, :) / sum_Etij;
end

%% check rabinar's paper
log_prob = 0;
for v = 1:num_visit
    log_prob = log_prob - log(C(v));
end
