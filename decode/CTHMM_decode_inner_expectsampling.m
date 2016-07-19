function [best_state_seq, best_prob] = CTHMM_decode_inner_expectsampling(start_s, end_s, T, num_sample)

%Q_mat = [-1 1; 0.5 -0.5];
%Q_mat_struct = [0 1; 1 0];
%Q_mat = [-1 1; 0 0];
%Q_mat_struct = [0 1; 0 0];
%Q_mat = [-1 1 0; 0 -0.5 0.5; 0 0 0];
%Q_mat_struct = [0 1 0; 0 0 1; 0 0 0];
%start_s = 1;
%end_s = 2;
%T =  9;
%num_sample = 1;

addpath('../misc');
addpath('../simulation');

global Q_mat;
global Q_mat_struct;
global Pt_expm;
global W_mat;
global W_vec;

num_state = size(Q_mat, 1);
Q_mat_struct = ones(num_state, num_state);
for i = 1:num_state
    Q_mat_struct(i,i) = 0;
end    

%% weight matrix -log(vij)
W_mat = Q_mat;
for i = 1:num_state
    W_mat(i, :) = -log(W_mat(i, :) / (-W_mat(i, i))); % -log (vij)
    W_mat(i, i) = 0;    
end

%% make weight vector (column-wise)
num_para = sum(Q_mat_struct(:));
W_vec = zeros(num_para, 1);
cur_para = 0;
for c = 1:num_state
    for r = 1:num_state        
        if (Q_mat_struct(r, c) == 1)
            cur_para = cur_para + 1;
            W_vec(cur_para) = W_mat(r, c);
        end
    end
end

%=====================================================
%% start sampling
seq_list = cell(num_sample, 1);
max_seq_len = 1000;
seq_prob_list = zeros(num_sample, 1);

A_mat = zeros(num_state * 2, num_state * 2);
A_mat(1:num_state, 1:num_state) = Q_mat;
A_mat((num_state+1):end, (num_state+1):end) = Q_mat;

PT = expm(Q_mat * T);

%%%%%%%%%%%%%%%

%% compute end-state conditioned expected state count E(end_s) 
A_mat(end_s, end_s + num_state) = 1; % set (end_s,end_s)
expm_A = expm(A_mat * T);    
n_ends = - expm_A(start_s, end_s + num_state) / Pt_expm(start_s, end_s) * Q_mat(end_s, end_s);
A_mat(end_s, end_s + num_state) = 0; % set (end_s,end_s)

n_ends

%%%%%%%%%%%%%%%%

for sample_idx = 1:num_sample

    k = start_s;
    l = end_s;
    remain_T = T;
    
    Pt_expm = PT;

    state_seq = zeros(max_seq_len, 1);
    dur_seq = zeros(max_seq_len, 1);
    cur_seq_len = 0;
        
    while (remain_T > 0)
        
        %% compute end-state conditioned expected count E(n_k) 
        A_mat(k, k + num_state) = 1; % set (k,k)
        expm_A = expm(A_mat * remain_T);    
        n_k = - expm_A(k, l + num_state) / Pt_expm(k, l) * Q_mat(k, k);
        A_mat(k, k + num_state) = 0; % set (k,k)
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %% check whether to terminate
        if (k == end_s)            
            %% is in absorbing state
            if (Q_mat(end_s, end_s) == 0.0) 
                break;
            end            
            %% compute end-state conditioned expected state count E(end_s)             
            rand_count = normrnd(n_k, 0.25 * n_k);
            sampled_n_k = round(rand_count);            
            if (sampled_n_k <= 1.0)
               cur_seq_len = cur_seq_len + 1;               
               state_seq(cur_seq_len) = k;
               dur_seq(cur_seq_len) = remain_T;               
               break; 
            end
        end                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %% compute E(D(k)) mean    
        all_tau_k = expm_A(k, l + num_state) / Pt_expm(k, l);

        %% compute mean duration of a single stay
        if (n_k > 0)
            tau_k = all_tau_k / n_k;
        else
            tau_k = remain_T;
        end
        
        %% sample a duration for tau_k
        rand_tau_k = normrnd(tau_k, 0.25 * tau_k);
                
        if (rand_tau_k > remain_T)
            rand_tau_k = remain_T;            
        elseif (rand_tau_k < 0.0)
            rand_tau_k = 0.0;
        end
        if (rand_tau_k > 0.0)
            remain_T = remain_T - rand_tau_k; 
            Pt_expm = expm(Q_mat * remain_T);
        end

        %% record the current state and duration
        cur_seq_len = cur_seq_len + 1;        
        state_seq(cur_seq_len) = k;
        dur_seq(cur_seq_len) = rand_tau_k;
                
        %% check whether to terminate again
        if (remain_T == 0 && k == end_s)
            break;
        end
        
        %=========================================
        if (remain_T <= 0.0 && k ~= end_s)
            %% go directly to the end-state using shorest-path algorithm
            [dist, shortest_path, predecessor] = graphshortestpath(sparse(Q_mat_struct), k, end_s, 'Weights', W_vec);
            len_shortest_path = size(shortest_path, 2);
            idx1 = cur_seq_len;
            idx2 = cur_seq_len + len_shortest_path - 1;
            state_seq(idx1:idx2) = shortest_path;
            cur_seq_len = idx2;
            break;
        end
        %=========================================

        
        %% sample the next state
        %% compute E(n_ki) for all ki edges
        temp_row = Q_mat(k, :);
        nb_idx_ls = find(temp_row > 0.0);
        num_nb = size(nb_idx_ls, 2);
        n_ki_list = zeros(num_nb, 1);    
        for n = 1:num_nb
            i = nb_idx_ls(n);        
            A_mat(k, i + num_state) = 1; % set (k,i)
            expm_A = expm(A_mat * remain_T);    
            n_ki_list(n) = expm_A(k, l + num_state) / Pt_expm(k, l) * Q_mat(k, i);
            A_mat(k, i + num_state) = 0; % set (k,i)        
        end
        
        % sample the current state from previous state               
        % normalize prob
        sum_count = sum(n_ki_list);
        prob_list = n_ki_list / sum_count;
        % sample the edge
        rand_idx = CTHMM_sim_rand_from_prob_mass(prob_list);
        next_s = nb_idx_ls(rand_idx);
       
        %=======================
        %% update k
        k = next_s;
        %=======================        
    end

    state_seq = state_seq(1:cur_seq_len);
    dur_seq = dur_seq(1:cur_seq_len);

    %% compute path transition prob
    [tran_prob, log_prob] = CTHMM_eval_path_tran_prob(state_seq);
    %% compute path duration prob
    dur_prob = CTHMM_eval_path_dur_prob(state_seq, T);
    overall_prob = tran_prob * dur_prob;
    state_seq'
   
    seq_list{sample_idx}.seq = state_seq;
    seq_list{sample_idx}.dur = dur_seq;
    seq_list{sample_idx}.prob = overall_prob;
    seq_prob_list(sample_idx) = overall_prob;
   
end

%% find the sequence of the largest prob
[best_prob, best_idx] = max(seq_prob_list);
best_state_seq = seq_list{best_idx}.seq;

%if (sample_idx == 1)
%    [best_prob, best_idx] =  max(prob_list);
%    next_s = nb_idx_ls(best_idx);
%else
