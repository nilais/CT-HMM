function [tau_list] = CTHMM_compute_expected_tau_for_a_path_Expm(state_seq, T)

global Q_mat;

n = size(state_seq, 1);
tau_list = zeros(n, 1);

%% first, extract qi from the original Q_mat    
path_Qmat = zeros(n+1, n+1);

%% second, construct path-based Q matrix using the state_seq
for i = 1:n
    path_Qmat(i, i) = Q_mat(state_seq(i), state_seq(i));
    path_Qmat(i, i+1) = -path_Qmat(i, i);
end

%% compute each tau
%% make up A matrix
A = zeros((n+1) * 2, (n+1) * 2);
A(1:(n+1), 1:(n+1)) = path_Qmat;
A((n+2):end, (n+2):end) = path_Qmat;

k = 1; % start state
l = n; % end state

pt = expm(path_Qmat * T);
p_kl = pt(k, l);

for i = 1:n

    %% set up A
    A(i, i + n+1) = 1;
    
    expm_A = expm(A * T);    
    tau_list(i) = expm_A(k, l + n+1) / p_kl;
    
    %% restore    
    A(i, i + n+1) = 0;

end

%M = expm(path_Qmat * T);
%result = M(1, n);