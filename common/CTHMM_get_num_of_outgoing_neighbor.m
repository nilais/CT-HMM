function num_nb = CTHMM_get_num_of_outgoing_neighbor(cur_Q_mat, cur_state)
% Fuxin Li 5/19, improved speed by using binary operations, also vectorized
% the code.
temp_row = cur_Q_mat(cur_state, :);
num_nb = sum(temp_row > 0,2);
% nb_idx_ls = find(temp_row > 0);
% num_nb = size(nb_idx_ls, 2);       

