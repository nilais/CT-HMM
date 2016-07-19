function [tau_list, is_success] = CTHMM_compute_expected_tau_for_a_path_Eigen(state_seq, T)

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


%% eigen decompose Q

[U_eigen, D_eigen, V] = eig(path_Qmat, 'nobalance');
v=diag(V'*U_eigen);
inv_U_eigen = V'./repmat(v,1,n);
%inv(U_eigen);
%[msgStr,msgId] = lastwarn;        
%if (strncmp(msgStr, 'Matrix is close to singular', 15) == 1)        
%    lastwarn('');            
%    disp('Eigen failed: Matrix is close to singular');
%    is_success = 0;
%    return;
%end

%% compute X
X_eigen = zeros(n+1, n+1);                        
for p = 1:(n+1)
    for q = 1:(n+1)
        if (D_eigen(p,p) == D_eigen(q,q))
            X_eigen(p, q)  = T * exp(D_eigen(p,p) * T);
        else
            X_eigen(p, q)  = (exp(D_eigen(p,p) * T) - exp(D_eigen(q,q) * T)) / (D_eigen(p,p) - D_eigen(q,q));
        end
    end %q
end %p

%% compute Ri (duration)
k = 1; % start state
l = n; % end state

pt = expm(path_Qmat * T);
p_kl = pt(k, l);

for i = 1:n

temp_sum = 0.0;                        
for p = 1:(n+1)                            

    if (U_eigen(k, p) == 0)
        continue;
    end

    temp = 0.0;
    for q = 1:(n+1)
        temp = temp + U_eigen(i, q) * inv_U_eigen(q, l) * X_eigen(p, q);
    end %q

    temp = temp * U_eigen(k, p) * inv_U_eigen(p, i);
    temp_sum = temp_sum + temp;

end %p          


tau_list(i) = temp_sum / p_kl;

            
end

is_success = 1;

