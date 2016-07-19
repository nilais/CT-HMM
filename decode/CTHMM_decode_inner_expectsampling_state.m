function [best_state_seq, best_prob] = CTHMM_decode_inner_expectsampling_state(start_s, end_s, T, num_sample)

addpath('../misc');
addpath('../simulation');
global Q_mat;
global Pt_expm;

num_state = size(Q_mat, 1);

%% start sampling
A_mat = zeros(num_state * 2, num_state * 2);
A_mat(1:num_state, 1:num_state) = Q_mat;
A_mat((num_state+1):end, (num_state+1):end) = Q_mat;

seq_list = cell(num_sample, 1);
max_seq_len = 1000;
seq_prob_list = zeros(num_sample, 1);


Pt_expm = expm(Q_mat * T);

%% compute E(end_s)

%% compute end-state conditioned expected state count E(end_s) 
A_mat(end_s, end_s + num_state) = 1; % set (end_s,end_s)
expm_A = expm(A_mat * T);    
n_ends = - expm_A(start_s, end_s + num_state) / Pt_expm(start_s, end_s) * Q_mat(end_s, end_s);
A_mat(end_s, end_s + num_state) = 0; % set (end_s,end_s)

n_ends

for sample_idx = 1:num_sample

    k = start_s;
    l = end_s;   
    state_seq = zeros(max_seq_len, 1);    
    cur_seq_len = 0;
    
    %% decide number of visiting of the last state
    rand_count = normrnd(n_ends, 0.25 * n_ends);
    sampled_n_ends = round(rand_count);
    if (sampled_n_ends == 0)
        sampled_n_ends = 1;
    end
    
    num_see_ends = 0;
    
    while (1)

        %% record the current state and duration
        cur_seq_len = cur_seq_len + 1;
        s = cur_seq_len;
        state_seq(s) = k;
        
        %% check whether to terminate
        if (k == end_s)
            %% check whether to go on or terminate
            num_see_ends = num_see_ends + 1;
            if (num_see_ends == sampled_n_ends)
                break;
            end
            if (Q_mat(end_s, end_s) == 0.0) % absorbing state
                break;
            end
        end
        
        %=======================
        %% sample the next state
        %% compute E(n_ki) for all ki edges
        temp_row = Q_mat(k, :);
        nb_idx_ls = find(temp_row > 0);
        num_nb = size(nb_idx_ls, 2);
        n_ki_list = zeros(num_nb, 1);    
        for n = 1:num_nb
            i = nb_idx_ls(n);        
            A_mat(k, i + num_state) = 1; % set (k,i)
            expm_A = expm(A_mat * T);    
            n_ki_list(n) = expm_A(k, l + num_state) / Pt_expm(k, l) * Q_mat(k, i);
            A_mat(k, i + num_state) = 0; % set (k,i)        
        end
        sum_count = sum(n_ki_list);
        prob_list = n_ki_list / sum_count;
        
        if (sample_idx == 1)
            [best_prob, best_idx] =  max(prob_list);
            next_s = nb_idx_ls(best_idx);
        else
            rand_idx = CTHMM_sim_rand_from_prob_mass(prob_list);
            next_s = nb_idx_ls(rand_idx);
        end
                
        %=======================        
        %% update k
        k = next_s;
    end

    state_seq = state_seq(1:cur_seq_len);
    
    %% compute path transition prob
    [tran_prob, log_prob] = CTHMM_eval_path_tran_prob(state_seq);
    %% compute path duration prob
    dur_prob = CTHMM_eval_path_dur_prob(state_seq, T);
           
    overall_prob = tran_prob * dur_prob;   
    seq_list{sample_idx}.seq = state_seq;    
    seq_list{sample_idx}.prob = overall_prob;
    seq_prob_list(sample_idx) = overall_prob;
   
end

for i = 1:num_sample    
    seq_list{i}.seq    
end



%% find the sequence of the largest prob
[M, I] = max(seq_prob_list);
best_state_seq = seq_list{I}.seq;
best_prob = seq_list{I}.prob;

