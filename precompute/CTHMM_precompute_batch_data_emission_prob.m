function CTHMM_precompute_batch_data_emission_prob(train_idx_list)

disp('In CTHMM_precompute_batch_data_emission_prob()...');

global obs_seq_list;
global state_list;

%% data emission probability

num_train_subject = size(train_idx_list, 1);
num_state = size(state_list, 1);

for g = 1:num_train_subject

    %if (mod(g, 100) == 0)            
    if (mod(g, 10) == 0)
        str = sprintf('%d...', g);
        fprintf(str);
    end

    %% get the subject index
    subject_idx = train_idx_list(g);
    num_visit = obs_seq_list{subject_idx}.num_visit;
    % subject data
    if (num_visit == 0)
        continue;
    end
    obs_seq_list{subject_idx}.has_compute_data_emiss_prob = 1;
    
    obs_seq_list{subject_idx}.data_emiss_prob_list = zeros(num_visit, num_state);
    obs_seq_list{subject_idx}.log_data_emiss_prob_list = zeros(num_visit, num_state);

    %% compute forward backward algorithm, remember Et(i,j) parameter: prob at the end-states at time t
    for v = 1:num_visit    
        data = obs_seq_list{subject_idx}.visit_data_list(v, :);

        for s = 1:num_state
            emiss_prob = mvnpdf(data, state_list{s}.mu, state_list{s}.var);
            %data_emiss_prob_mat(v, s) = func_state_emiss(s, data);
            obs_seq_list{subject_idx}.data_emiss_prob_list(v,s) = emiss_prob;
            obs_seq_list{subject_idx}.log_data_emiss_prob_list(v,s) = log(emiss_prob);
        end
    end
        
end

fprintf('\n');