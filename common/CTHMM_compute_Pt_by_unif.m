function [Pt_mat, M, R_unif_list, Pois_unif_list] = CTHMM_compute_Pt_by_unif(ind_Q_mat, T)

%% use uniformization method to compute Pt

%% compute M
D = -diag(ind_Q_mat);
max_qi = max(D);
max_qt = max_qi * T;    
M = ceil(4 + 6 * sqrt(max_qt) + max_qt);

%str = sprintf('max M = %d, max_qi = %f, T = %f, max qt = %f\n', M, max_qi, T, max_qt);
%CTHMM_print_log(str);

%% compute R, R^2, ..., R^(M) 
num_state = size(ind_Q_mat, 1);
R_mat = ind_Q_mat / max_qi + eye(num_state);
R_unif_list = cell(M+1, 1);
R_unif_list{1} = eye(num_state);
R_unif_list{2} = R_mat;
for r = 3:(M+1)
    R_unif_list{r} = R_mat * R_unif_list{r-1};
end

%% compute Pt for current visit
Pois_unif_list.m_list = zeros(M+1, 1);

% begin constructing expm result
Pt_mat = zeros(num_state, num_state);        
for m = 0:1:M
    Pois_unif_list.m_list(m+1) = poisspdf(m, max_qt); 
    Pt_mat = Pt_mat + R_unif_list{m+1} * Pois_unif_list.m_list(m+1);
end

