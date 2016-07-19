function [obs_seq_list] = CTHMM_sim_gen_syn_obs_seq_fix_total_visit_count(total_visit_count, time_intv_list, obs_dur)                                             
                                                       
disp('In CTHMM_gen_syn_obs_seq_fix_total_visit_count()...');        

global syn_Q_mat;
global state_list;
global data_setting;
global Q_mat_struct;
global sample_chain_Q_mat;
global is_use_individual_Q_mat;

dim = data_setting.dim;
sample_chain_Q_mat = syn_Q_mat;

%% estimate num of observation sequences
num_time_intv = size(time_intv_list, 1);

min_intv = min(time_intv_list);
max_intv = max(time_intv_list);
max_visit_per_seq = floor(obs_dur / min_intv);
min_visit_per_seq = floor(obs_dur / max_intv);
preallocate_num_seq = ceil(total_visit_count / min_visit_per_seq) * 100;

str = sprintf('Fix total_visit_count = %d, max_visit_per_seq = %d, min_visit_per_seq = %d, num_time_intv = %d\n', total_visit_count, max_visit_per_seq, min_visit_per_seq, num_time_intv);
CTHMM_print_log(str);

%% allocate obs seq list
obs_seq_list = cell(preallocate_num_seq, 1);
cur_visit_count = 0;

seq = 0;

while (cur_visit_count < total_visit_count)

    %% add one sequence
    seq = seq + 1;
    
    if (mod(seq, 100) == 0)                
        str = sprintf('%d...', seq);
        fprintf(str);
    end
        
    %% sample a state chain        
    if (is_use_individual_Q_mat == 0)
        state_chain = CTHMM_sim_sample_a_chain(obs_dur);
    else
        state_chain = CTHMM_sim_sample_an_individual_chain_with_covariate(obs_dur);
    end
    
    %% generate obs sequence from the state chain
    obs_seq_list{seq}.ori_state_chain = state_chain;
    
    obs_seq_list{seq}.num_visit = max_visit_per_seq;
    obs_seq_list{seq}.visit_time_list = zeros(max_visit_per_seq, 1);
    obs_seq_list{seq}.visit_data_list = zeros(max_visit_per_seq, dim);
    obs_seq_list{seq}.visit_true_state_list = zeros(max_visit_per_seq, 1);
    
    test_begin_term_idx = 1;
    
    for v = 1:max_visit_per_seq
        
        %% get the current time interval
        cur_time_intv_idx = mod(cur_visit_count, num_time_intv);
        if (cur_time_intv_idx == 0)
            cur_time_intv_idx = num_time_intv;
        end
        
        if (v == 1)
            visit_time = 0.0;
        else            
            visit_time = obs_seq_list{seq}.visit_time_list(v-1) + time_intv_list(cur_time_intv_idx);
        end
        
        if (visit_time > obs_dur) % terminate this sequence
            obs_seq_list{seq}.num_visit = v-1;
            obs_seq_list{seq}.visit_time_list = obs_seq_list{seq}.visit_time_list(1:(v-1));
            obs_seq_list{seq}.visit_data_list = obs_seq_list{seq}.visit_data_list(1:(v-1), :);
            obs_seq_list{seq}.visit_true_state_list = obs_seq_list{seq}.visit_true_state_list(1:(v-1)); 
            break;
        else            
            %% set up visit time
            obs_seq_list{seq}.visit_time_list(v) = visit_time;
            
            %% find the mapped state index for this visit
            [term_idx, state_idx] = CTHMM_sim_find_time_mapped_state_chain_index(visit_time, state_chain, test_begin_term_idx);
            if (term_idx == -1)
                disp('Err in func_find_time_mapped_state_chain_index()\n');
            end
            test_begin_term_idx = term_idx;

            % obs_seq_list{seq}.visit_data_list(v, :) = state_list{state_idx}.mu;        
            %% gaussian observation model
            mu = state_list{state_idx}.mu;
            var = state_list{state_idx}.var;
            obs_seq_list{seq}.visit_data_list(v, :) = mvnrnd(mu,var);        
            obs_seq_list{seq}.visit_true_state_list(v) = state_idx;
            
            if (is_use_individual_Q_mat == 1) %% record covariate
                obs_seq_list{seq}.visit_covariate_ls{v} = state_chain.state_cov_list{term_idx};
            end
            
            %% add visit count
            cur_visit_count = cur_visit_count + 1;
            
            %% check if state_idx is an end-state 
            num_outgoing_link = sum(Q_mat_struct(state_idx, :));        

            if (num_outgoing_link == 0 || cur_visit_count >= total_visit_count) % termindate this sequence
                obs_seq_list{seq}.num_visit = v;
                obs_seq_list{seq}.visit_time_list = obs_seq_list{seq}.visit_time_list(1:v);
                obs_seq_list{seq}.visit_data_list = obs_seq_list{seq}.visit_data_list(1:v, :);
                obs_seq_list{seq}.visit_true_state_list = obs_seq_list{seq}.visit_true_state_list(1:v);            
                break;
            end        
        end % if (visit_time > )
    end % v
    
    if (cur_visit_count >= total_visit_count)
        obs_seq_list = obs_seq_list(1:seq);
        break;
    end
    
end % while

%seq
%cur_visit_count

disp('End of func_gen_syn_obs_seq()...');
