function rand_idx = CTHMM_sim_rand_from_prob_mass(prob_list, n)

% Fuxin: 5/19/14 Improved speed and functionality of this function. Added a parameter n,
%        which is the number of desired samples

if ~exist('n','var') || isempty(n)
    n = 1;
end
% Need a row vector
if size(prob_list,1) > size(prob_list,2) && size(prob_list,2)==1
    prob_list = prob_list';
end
cum_prob_list = cumsum(prob_list,2);
rand_prob = rand(n,1);
% Find the first non-zero element of each row
if size(cum_prob_list,1) > 1
    rand_idx = arrayfun(@(x) find(rand_prob(x) <= cum_prob_list(x,:), 1,'first'), (1:n)');
else
    rand_idx = arrayfun(@(x) find(x <= cum_prob_list, 1,'first'), rand_prob);
end

%% prob_list should sum to 1

%num_instance = size(prob_list, 2);

%% compute accumulated prob mass

%% sample the state
%cum_prob_list = zeros(num_instance, 1);
% for i = 1:num_instance
%     if (i == 1)
%         cum_prob_list(i) = prob_list(1);
%     else
%         cum_prob_list(i) = cum_prob_list(i-1) + prob_list(i);
%     end
% end

% for i = 1:num_instance           
%     if (rand_prob <= cum_prob_list(i))
%         rand_idx = i;
%         break;           
%     end            
% end


