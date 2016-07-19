function CTHMM_learn_Eigen_compute_X_mat(T)

global D_eigen;
global X_eigen;
global state_list;

num_state = size(state_list, 1);



X_eigen = zeros(num_state, num_state);                        
for p = 1:num_state
    for q = 1:num_state
        
		if (D_eigen(p,p) == D_eigen(q,q))
		%if (abs(D_eigen(p,p) - D_eigen(q,q)) <= eps(D_eigen(p,p)) * 1)
        %if (abs(D_eigen(p,p) - D_eigen(q,q)) <= eps(D_eigen(p,p)) * 2)  % or change 2 to larger tolerance
            X_eigen(p, q)  = T * exp(D_eigen(p,p) * T);
        else
            X_eigen(p, q)  = (exp(D_eigen(p,p) * T) - exp(D_eigen(q,q) * T)) / (D_eigen(p,p) - D_eigen(q,q));
        end
        
    end %q
end %p