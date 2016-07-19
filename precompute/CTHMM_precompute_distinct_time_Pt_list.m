function CTHMM_precompute_distinct_time_Pt_list()

global distinct_time_list;
global distinct_time_Pt_list;
global distinct_time_log_Pt_list;
global Q_mat;
global state_list;

global learn_method;
global is_outer_soft;

global is_use_fast_expm_At;
is_use_fast_expm_At = 1;

global has_computed_A_series;
has_computed_A_series = 0;

global A;
if (is_use_fast_expm_At == 1)
    A = Q_mat;
end

%% for uniformization method
global R_unif_list;
global Pois_unif_list;

num_state = size(state_list, 1);
num_time = size(distinct_time_list, 1);
distinct_time_Pt_list = cell(num_time, 1);

if (is_outer_soft == 0)
    distinct_time_log_Pt_list = cell(num_time, 1);
end

if (learn_method == 2) % uniformization method
    D = -diag(Q_mat);
    max_qi = max(D);
    Pois_unif_list = cell(num_time, 1);
end

% for each distinct time
for i = 1:num_time
    
    t_delta = distinct_time_list(i);
    
    if (learn_method == 2) % use uniformization method to compute expm and record the intermediate matrices
        
        qt = max_qi * t_delta;
        M = ceil(4 + 6 * sqrt(qt) + qt);
        Pois_unif_list{i}.m_list = zeros(M+1, 1);
        
        % begin constructing expm result
        result_mat = zeros(num_state, num_state);        
        for m = 0:1:M
            Pois_unif_list{i}.m_list(m+1) = poisspdf(m, qt); 
            result_mat = result_mat + R_unif_list{m+1} * Pois_unif_list{i}.m_list(m+1);            
        end

        distinct_time_Pt_list{i} = result_mat;        
        %test = expm(Q_mat * t_delta);
        
    else
        
        if (is_use_fast_expm_At == 1)        
            distinct_time_Pt_list{i} = matlab_expm_At(t_delta);
        else
            distinct_time_Pt_list{i} = expm(Q_mat * t_delta);
        end
        
    end
        
    if (is_outer_soft == 0)
        distinct_time_log_Pt_list{i} = log(distinct_time_Pt_list{i});
    end
    
end
