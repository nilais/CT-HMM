function chain = CTHMM_sim_sample_a_chain(sampling_dur)

global sample_chain_Q_mat;

global state_init_prob_list;

%% sample a (state,duration) chain, such that the total duration is >= (obs_total_dur + (t1 - t0))
num_state = size(sample_chain_Q_mat, 1);
chain.state_idx_list = zeros(1, num_state);
chain.state_dur_list = zeros(1, num_state);
chain.accum_state_dur_list = zeros(1, num_state);
accum_state_dur = 0.0;
num_sampled_state = 0;

while (accum_state_dur < sampling_dur)
                  
    %% sample the current state
    if (num_sampled_state == 0) 
        %% sample the initial state
        rand_idx = CTHMM_sim_rand_from_prob_mass(state_init_prob_list);        
        cur_state = rand_idx;        
    else        
        %% sample the current state from previous state
        prev_state = chain.state_idx_list(num_sampled_state);
        temp_row = sample_chain_Q_mat(prev_state, :);
        nb_idx_ls = find(temp_row > 0);
        
        %% sample the state
        q_list = temp_row(nb_idx_ls); 
        prob_list = q_list ./ (-sample_chain_Q_mat(prev_state, prev_state));
        rand_idx = CTHMM_sim_rand_from_prob_mass(prob_list);
        cur_state = nb_idx_ls(rand_idx);
    end % if is first state
        
    %% sample a duration for current state
    
    if (CTHMM_get_num_of_outgoing_neighbor(sample_chain_Q_mat, cur_state) == 0) % if cur state is an absorption state                        
        dur = 100000; % set an arbitrary large duration is fine        
        %dur = sampling_dur - accum_state_dur + 1.0;
    else % sample a duration for current state        
        qi = sample_chain_Q_mat(cur_state, cur_state);
        dur = random('exp', -1.0/qi);
    end
    
    num_sampled_state = num_sampled_state + 1;
    i = num_sampled_state;
    
    chain.state_idx_list(i) = cur_state;
    chain.state_dur_list(i) = dur;
    accum_state_dur = accum_state_dur + dur;
    chain.accum_state_dur_list(i) = accum_state_dur;
end % i

if (num_sampled_state == 0)
    disp('error: num_sampled_state=0');
end

chain.num_state = num_sampled_state;
chain.state_idx_list = chain.state_idx_list(1:num_sampled_state);
chain.state_dur_list = chain.state_dur_list(1:num_sampled_state);
chain.accum_state_dur_list = chain.accum_state_dur_list(1:num_sampled_state);


%% test whether the duration sampling is correct
%         dur_list = [];
%         for k = 1:100
%             dur = random('exp', -1.0/qi);
%             dur_list = [dur_list dur];
%         end
%         mean_dur = mean(dur_list)


