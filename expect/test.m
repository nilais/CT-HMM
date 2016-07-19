clc


addpath('../common');

global Q_mat;

% Q_mat(1,1) = -1;
% Q_mat(2,2) = -2;
% Q_mat(3,3) = -3;
% Q_mat(4,4) = -4;
% % a test case
% state_seq = [1 2 3 4]';
% %lambda = [1.0179 1.0194 1.0183 1.0050];

n = 10;

eigen_num_fail = 0;
closed_num_fail = 0;
eigen_total_time = 0.0;
closed_total_time = 0.0;
expm_total_time = 0.0;
unif_total_time = 0.0;

num_run = 10;

for run = 1:num_run
      
    Q_mat = zeros(n, n);

    sum_mean = 0.0;
    for i = 1:n
        
        %qi = 0.1 + rand() * 0.9;
        qi = 1 + rand() * 4;
        
        %qi = rand();
        Q_mat(i,i) = -qi;
        
        sum_mean = sum_mean + 1.0/qi;
    end

    %qi_list = diag(Q_mat);
    
    min_qi = min(-diag(Q_mat));
    T = sum_mean;
    T

    state_seq = [1:1:n]';
    
    
    tStart = tic;
    [tau_list, is_success] = CTHMM_compute_expected_tau_for_a_path_Eigen(state_seq, T);
    tau_list(1:5)'
    tEnd = toc(tStart);
    
    if (is_success == 0)
        eigen_num_fail = eigen_num_fail + 1;
    else
        eigen_total_time = eigen_total_time + tEnd;
    end
        
    tStart = tic;  
    [tau_list, is_success, a_table, b_table, c_table] = CTHMM_compute_expected_tau_for_a_path_closedform(state_seq, T);
    tau_list(1:5)'
    tEnd = toc(tStart);
    
    if (is_success == 0)
        closed_num_fail = closed_num_fail + 1;
    else
        closed_total_time = closed_total_time + tEnd;
    end
    
    
    tStart = tic;  
    [tau_list] = CTHMM_compute_expected_tau_for_a_path_Expm(state_seq, T);
    tau_list(1:5)'
    tEnd = toc(tStart);
    expm_total_time = expm_total_time + tEnd;

    tStart = tic;
    [tau_list] = CTHMM_compute_expected_tau_for_a_path_Unif(state_seq, T);
    tau_list(1:5)'
    tEnd = toc(tStart);
    unif_total_time = unif_total_time + tEnd;
   
end

eigen_num_fail
closed_num_fail

eigen_total_time = eigen_total_time / (num_run - eigen_num_fail);
closed_total_time = closed_total_time / num_run;
expm_total_time = expm_total_time / num_run;
unif_total_time = unif_total_time / num_run;

str = sprintf('\nEigen: %d minutes and %f seconds\n', floor(eigen_total_time/60),rem(eigen_total_time,60))
str = sprintf('\nClosed-Form: %d minutes and %f seconds\n', floor(closed_total_time/60),rem(closed_total_time,60))
str = sprintf('\nExpm: %d minutes and %f seconds\n', floor(expm_total_time/60),rem(expm_total_time,60))
str = sprintf('\nUnif: %d minutes and %f seconds\n', floor(unif_total_time/60),rem(unif_total_time,60))
