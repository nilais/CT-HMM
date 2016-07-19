function [mapped_term_idx, mapped_state_idx] = CTHMM_sim_find_time_mapped_state_chain_index(visit_time, state_chain, test_begin_index)

num_chain_state = state_chain.num_state;

mapped_term_idx = -1;
mapped_state_idx = -1;

for s = test_begin_index:num_chain_state

    if (state_chain.accum_state_dur_list(s) > visit_time)
        mapped_state_idx = state_chain.state_idx_list(s);
        mapped_term_idx = s;
        break;
    end

end
    
    
