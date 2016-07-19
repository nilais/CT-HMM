function CTHMM_learn_onetime_precomputation(train_idx_list)

global is_use_distinct_time_grouping;
global distinct_time_list;
global learn_performance;

%% precomputation of state emission prob of observations
tStartTemp= tic;
%% find out distinct time from the dataset
if (is_use_distinct_time_grouping == 1)
    [distinct_time_list] = CTHMM_precompute_distinct_time_intv(train_idx_list);
end
%% comute all data emission probability
CTHMM_precompute_batch_data_emission_prob(train_idx_list);
tEndTemp = toc(tStartTemp);

%% time in precomputation
str = sprintf('\nPrecomputation of data emission-> time: %d minutes and %f seconds\n', floor(tEndTemp/60),rem(tEndTemp,60));
CTHMM_print_log(str);

learn_performance.time_precomp_data = tEndTemp;  
