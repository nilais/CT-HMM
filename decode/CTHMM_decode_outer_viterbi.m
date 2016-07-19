function [best_state_seq, dur_seq, best_log_prob, log_Pt_list] = CTHMM_decode_outer_viterbi(obs_seq)

global state_list;
global Q_mat;
global state_init_prob_list;

%global state_reach_mat;
global is_use_distinct_time_grouping;
global is_use_individual_Q_mat;

num_state = size(state_list, 1);
%visit_list = obs_seq.visit_list;
num_visit = obs_seq.num_visit;
best_state_seq = zeros(num_visit, 1);
dur_seq = zeros(num_visit, 1);

if (obs_seq.has_compute_data_emiss_prob ~= 1)
    for v = 1:num_visit
        data = obs_seq.visit_list{v}.data;
        for m = 1:num_state            
            emiss_prob = mvnpdf(data, state_list{m}.mu, state_list{m}.var);
            obs_seq.data_emiss_prob_list(v,m) = emiss_prob; 
            obs_seq.log_data_emiss_prob_list(v,m) = log(emiss_prob);
        end
    end
end

%% uniformization method
global visit_Pt_list;
global visit_R_unif_list;
global visit_Pois_unif_list;
global visit_ind_Q_mat_list;
global visit_ind_cov_effect_mat;

if (is_use_individual_Q_mat == 1)
    visit_Pt_list = cell(num_visit, 1);
    visit_R_unif_list = cell(num_visit, 1);
    visit_Pois_unif_list = cell(num_visit, 1);
    visit_ind_Q_mat_list = cell(num_visit, 1);
    visit_ind_cov_effect_mat = cell(num_visit, 1);
end

%% create two matrix T1, T2 to store decoding results
T1 = -inf * ones(num_state, num_visit); % best prob so far
T2 = zeros(num_state, num_visit); % backtracking pointer

%% precomputing of Pt for every visit
log_Pt_list = cell(num_visit, 1);

for v = 1:(num_visit-1)
    %% transition matrix at each time point
    t_delta = obs_seq.visit_time_list(v+1) - obs_seq.visit_time_list(v);  
    
    if (is_use_distinct_time_grouping == 1)
        log_Pt = CTHMM_precompute_get_distinct_time_log_Pt(t_delta);
    else
        if (is_use_individual_Q_mat == 1)
            [ind_Q_mat, ind_cov_effect_mat] = CTHMM_compute_individual_Q_mat(obs_seq, v);            
            visit_ind_Q_mat_list{v} = ind_Q_mat;
            visit_ind_cov_effect_mat{v} = ind_cov_effect_mat;
            
            [Pt_mat, M, R_unif_list, Pois_unif_list] = CTHMM_compute_Pt_by_unif(ind_Q_mat, t_delta);                       
            visit_Pt_list{v} = Pt_mat;
            visit_R_unif_list{v} = R_unif_list;
            visit_Pois_unif_list{v} = Pois_unif_list;

            log_Pt = log(Pt_mat);
        else
            log_Pt = log(expm(Q_mat * t_delta));
        end        
    end
    
    log_Pt_list{v} = log_Pt;    
    dur_seq(v) = t_delta;
end

%% init T1 and T2 at visit 1
max_log_prob = -inf;
for s = 1:num_state           
    
    %state = state_list{s};
    %Y = obs_seq.visit_data_list(1, :);    
    %[emiss_prob] = func_state_emiss(s, Y);
    %emiss_prob = mvnpdf(Y, state_list{s}.mu, state_list{s}.sigma);
    
    log_emiss_prob = obs_seq.log_data_emiss_prob_list(1, s);    
    log_prob = log(state_init_prob_list(s)) + log_emiss_prob;
    
    T1(s, 1) = log_prob;
    T2(s, 1) = 0;
    
    if (log_prob >= max_log_prob)
        max_log_prob = log_prob;       
    end
end

%% for visit 2 to the last visit

for v = 2:num_visit   
    
    %% compute Pt
    
    %t_cur = obs_seq.visit_time_list(v);
    %t_pre = obs_seq.visit_time_list(v-1);
    %t_delta = t_cur - t_pre;    
    %dur_seq(v-1) = t_delta;        
    %if (is_use_individual_Q_mat == 1)
    %    individual_Q_mat = func_compute_individual_Q_mat(visit_list{v-1}.age);
    %    Pt = expm(t_delta * individual_Q_mat);
    %else    
    %Pt = expm(t_delta * Q_mat);         
    %Pt = matlab_expm_At(Q_mat, t_delta);        
    %end
        
    %% Y   
    
    %Y = obs_seq.visit_data_list(v, :);
    
    for s = 1:num_state % current state
        
        %% T1(s, v) = max_k (T1(k, v-1) * Pks(t(v) - t(v-)) * state_emiss(s, yv);
        %% T2(s, v) = arg max_k (T1(k, v-1) * Pks(t(v) - t(v-)) * state_emiss(s, yv);
        
        %state = state_list{s};
        %emiss_prob = func_state_emiss(s, Y);
        %log_emiss_prob = log(mvnpdf(Y, state_list{s}.mu, state_list{s}.sigma));
        
        log_emiss_prob = obs_seq.log_data_emiss_prob_list(v, s);
        
        %% find best previous state
        best_k = 0;
        best_log_prob = -inf;
        
        for k = 1:num_state % previous state
            
%            if (state_reach_mat(k, s) == 0)
%                 continue;
%            end

           %log_prob = T1(k, v-1) + log(Pt(k, s)) + log(emiss_prob);
           
           
           log_prob = T1(k, v-1) + log_Pt_list{v-1}(k, s) + log_emiss_prob;
           
           if (log_prob == inf)
           
               disp('log_prob = inf');
               
           end
           
            if (log_prob > best_log_prob)
                best_k = k;
                best_log_prob = log_prob;
            end            
        end        
        
        T1(s, v) = best_log_prob;
        T2(s, v) = best_k;        
    end % s
end % v

dur_seq(end) = 0;


%% start backtracking of state sequence

%% find best last state
best_last_s = 0;
best_log_prob = -inf;
for s = 1:num_state
    if (T1(s, num_visit) >= best_log_prob)
        best_last_s = s;
        best_log_prob = T1(s, num_visit);
    end
end
best_state_seq(num_visit) = best_last_s;

if (best_last_s == 0)
   disp('beat last s = 0');
    
end

%% start backgracking from the last state
for v = (num_visit-1) : -1 : 1
    best_state_seq(v) = T2(best_last_s, v+1);
    best_last_s = best_state_seq(v);
end

end % func
