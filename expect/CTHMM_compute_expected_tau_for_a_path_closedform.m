function [tau_list, is_success, a_table, b_table, c_table] = CTHMM_compute_expected_tau_for_a_path_closedform(state_seq, total_dur)

% a test case
%state_seq = [1 3];
%total_dur = 0.10;
%lambda = [1.0179 1.0194 1.0183 1.0050];
%T = 0.10;
%n = 2;


global Q_mat;

a_table = [];
b_table = [];
c_table = [];

num_path_state = size(state_seq, 1);
tau_list = zeros(num_path_state, 1);

if (num_path_state == 1)
    tau_list = total_dur;
    return ;
end

% last_s = state_seq(end);
% if (Q_mat(last_s, last_s) == 0.0) % if last state is an absorb state
%     state_seq = state_seq(1:end-1);
%     num_path_state = num_path_state - 1;
% end

%% extract lambda list for the state_seq

lambda = -diag(Q_mat);

%lambda = size(num_path_state, 1);
%for i = 1:num_path_state    
%    lambda(i) = -Q_mat(state_seq(i), state_seq(i));    
%end

%% begin computing all expected tau for each state
T = total_dur;
n = num_path_state;

%% compute exp_lamda_T 
exp_lamda_T = zeros(n, 1);
for i = 1:n
    exp_lamda_T(i) = exp(-lambda(i) * T);
end

%% compute denumerator
% compute c table
c_table = zeros(n, 1);

%denumerator = 0.0;
for i = 1:n
    temp = 1;
    for j = 1:n        
        if (j ~= i)            
            if (lambda(j) == lambda(i))
                disp('equal lambda!! divide by 0');                
            else
                temp = temp * lambda(j) / (lambda(j) - lambda(i));
            end            
        end        
    end
    temp = temp * lambda(i) / lambda(n);
    c_table(i) = temp;
    %denumerator = denumerator + c_table(i) * exp_lamda_T(i);
end

max_c = max(c_table);

c_table = c_table ./ max_c;

denumerator = 0.0;
for i = 1:n
    denumerator = denumerator + c_table(i) * exp_lamda_T(i);
end

%% compute coefficients efficienlty by filling the table
a_table = zeros(n, n);
b_table = zeros(n, n);

%% compute a table
for k = 1:n
    a_table(k,k) = 1.0;    
    for m = 1:k
        if (m ~= k)            
            if (lambda(m) ~= lambda(k))
                a_table(k,k) = a_table(k,k) * lambda(m) / (lambda(m) - lambda(k));
            else                
                disp('equal lambda!! divide by 0');
            end            
        end
    end
end

%for i = 1:(n-1)
%    for k = (i+1):n
        
for k = 1:n
    for i = 1:k
        if (k ~= i)
            if (lambda(k) ~= lambda(i))
                a_table(k, i) = a_table(k-1, i) * lambda(k-1) / (lambda(k) - lambda(i));
            else                
                disp('equal lambda!! divide by 0');
            end            
        end        
    end
end


a_table = a_table ./ max_c;

%% compute b table
for k = 1:n
    b_table(k, k) = lambda(k) / lambda(n);
    for m = k:n
        if (m ~= k)            
            if (lambda(m) ~= lambda(k))                
                b_table(k,k) = b_table(k,k) * lambda(m) / (lambda(m) - lambda(k));
            else
                disp('equal lambda!! divide by 0');
            end            
        end
    end    
end

%for j = 2:n
%    for k = (j-1):(-1):1

for k = (n-1):(-1):1
    for j = k:n    
        if (k ~= j)
            if (lambda(k) ~= lambda(j))
                b_table(k, j) = b_table(k+1, j) * lambda(k) / (lambda(k) - lambda(j));
            else
                disp('equal lambda!! divide by 0');
            end
        end
        
    end
end

%%===========================================================================================

for k = 1:n    
    
    % compute numerator
    term1 = 0.0;    
    for i = 1:k
        for j = k:n    
            % compute numerator
            if (i == j) %=k                
                term2 = a_table(k, k) * b_table(k, k) * T * exp_lamda_T(k);                
            else
                if (lambda(i) ~= lambda(j))
                    temp = a_table(k, i) * b_table(k, j) / (-lambda(i) + lambda(j)) * (exp_lamda_T(i) - exp_lamda_T(j));
                else
                    disp('equal lambda!! divide by 0');
                end                
                term1 = term1 + temp;                                
            end            
        end
    end

    numerator = term1 + term2;    
    %% store intermediate results for repetitive use
   
    %% expect tau
    tau = numerator / denumerator;
    tau_list(k) = tau;    
end

%tau_list
%sum_tau = sum(tau_list)
%total_dur

% if (size(find(tau_list < 0), 1) >= 1)    
%     str = 'tau < 0';
%     fprintf(str);    
%     tau_list(1:n) = total_dur / num_path_state;   
%     
%     is_success = 0;
% else
    is_success = 1;
% end



% last_s = state_seq(end);
% if (Q_mat(last_s, last_s) == 0.0) % if last state is an absorb state
%     tau_list = [tau_list' 0]';
% end
