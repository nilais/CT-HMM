function CTHMM_precompute_state_reach_mat()

%https://en.wikipedia.org/wiki/Reachability
%% compute whether a state i can reach any state j by using all-pairs shortest path algorithm

global Q_mat_struct;
global state_reach_mat;

SparseG = sparse(Q_mat_struct);
[dist] = graphallshortestpaths(SparseG);

num_state = size(Q_mat_struct, 1);
state_reach_mat = zeros(num_state, num_state);

for i = 1:num_state
    for j = 1:num_state
        
        if (i == j)
            state_reach_mat(i, i) = 1;
        elseif (dist(i,j) ~= inf)
            state_reach_mat(i, j) = 1;
        end
        
    end
end

