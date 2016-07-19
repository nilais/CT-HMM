%% write simulation tests
addpath('baseline_SSA');

run_idx = 1;
sd = run_idx * 400;
rng(sd);
    
%% 10-state complete digraph
global Q_mat;

%% generate Q mat random values
num_state = 5;
Q_mat = zeros(num_state, num_state);
lambda_list = zeros(num_state, 1);
Vij_mat = zeros(num_state, num_state);

%% generate holding time parameter first
for i = 1:num_state % row
    qi = (rand() * 4) + 1; % let qi in range [1 5]    
    Q_mat(i, i) = -qi;
    lambda_list(i) = qi;
end

for i = 1:num_state % row    
    sum_temp = 0.0;
    for j = 1:num_state   % column   
        %if (Q_mat_struct(i, j) == 1)
        if (i ~= j)
            temp = rand();            
            Q_mat(i, j) = temp;
            sum_temp = sum_temp + temp;
        end
    end
    if (sum_temp > 0.0)
        qi = -Q_mat(i, i);
        row = Q_mat(i, :);
        row(i) = 0.0;
        q_row = row * qi / sum_temp;  
        Q_mat(i, :) = q_row;
        Q_mat(i, i) = -sum(q_row);        
        Vij_mat(i, :) = row / sum_temp;
    else
        Q_mat(i, i) = 0.0; % absorb state
    end
end

%% start testing for the two methods

%% test one pair of (k, l) and t
rng(sd);

k =  ceil(rand() * num_state);
l = ceil(rand() * num_state);
min_dwell_time = 1.0 / 5.0;
T = max(rand() * 10, min_dwell_time);

str = sprintf('k = %d, l = %d, T = %f\n', k, l, T)

%% test my new expect state sampler
tic;
num_sample = 200;

%[best_state_seq, best_prob] = CTHMM_decode_inner_expectsampling_state(k, l, T, num_sample);
%[best_state_seq, best_prob] = CTHMM_decode_inner_expectsampling(k, l, T, num_sample);
[best_state_seq, best_prob] = CTHMM_decode_inner_randomsampling(k, l, T, num_sample);

tEnd = toc;

best_state_seq'
best_prob
str = sprintf('Expect-Sampling: %d min, %f sec\n', floor(tEnd/60),rem(tEnd,60))

% ===================================
%% test baseline method    
% STATE SEQUENCE ANALYSIS

run_SSA = 0;

if (run_SSA == 1)
SSAProb.L = lambda_list; % lambda list
SSAProb.T = Vij_mat;  % transition prob: vij
SSAProb.Starts = k;
SSAProb.Time = T;
SSAProb.MaxDom = 0;

% Solve the optimization problem
tic;
SSARes = StateSequenceAnalyze(SSAProb);
SSATime = toc;    

StartStatesOrWeights = k;
EndStatesOrWeights = l;
TimesToDo = T;
MMostProbable = 1;
[MaxSeqsByTime,SeqList] = ExtractMaxSeqs(SSARes,TimesToDo,StartStatesOrWeights,EndStatesOrWeights,MMostProbable);    
best_seq_idx = SeqList(1, 3); % first row, the 3rd component is the best sequence index

best_state_seq_SSA = SSARes.Seqs{k,l}{best_seq_idx}.seq
best_prob_SSA = SSARes.Seqs{k,l}{best_seq_idx}.p(end)
tEnd = toc;
str = sprintf('SSA: %d min, %f sec\n', floor(tEnd/60),rem(tEnd,60))

end

%% compare the two state sequence and compute relative probability difference
% len_best_state_seq_SSA = length(best_state_seq_SSA);
% len_best_state_seq_ES = length(best_state_seq_ES);
% 
% is_best_state_seq_same = 0;
% if (len_best_state_seq_SSA == len_best_state_seq_ES)
%     diff_vec = best_state_seq_SSA - best_state_seq_ES;
%     diff_vec_sum = sum(abs(diff_vec));
%     if (diff_vec_sum == 0.0)
%         is_best_state_seq_same = 1;
%     end
% end
% 
% is_best_state_seq_same
% 
% if (best_prob_SSA - best_prob_ES ~= 0)
%     relative_prob_diff = abs(best_prob_SSA - best_prob_ES) / best_prob_SSA;
% else
%     relative_prob_diff = 0.0;
% end
% 
% relative_prob_diff
% 
