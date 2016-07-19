function result = CTHMM_compute_path_dur_prob(state_seq, total_dur)
%function result = CTHMM_compute_Q_1n(state_seq, total_dur)

global Q_mat;

num_path_state = size(state_seq, 1);
T = total_dur;
n = num_path_state;

%% first, extract qi from the original Q_mat    
path_Qmat = zeros(num_path_state+1, num_path_state+1);

%% second, construct path-based Q matrix using the state_seq
for i = 1:num_path_state
    path_Qmat(i, i) = Q_mat(state_seq(i), state_seq(i));
    path_Qmat(i, i+1) = -path_Qmat(i, i);
end

M = expm(path_Qmat * T);
result = M(1, n);

%path_Qmat
%last_s = state_seq(end);

% if (Q_mat(last_s, last_s) == 0.0)  % last state is an absorb state
% 
%     %% for verify only
%     M = expm(path_Qmat * T);
%     result = M(1, n);
% 
% else % use the derived closed form to compute exp(path_Qmat*T)_(1, n)
%     
%     result = 0.0;
%     for i = 1:n
%         temp = 1;
%         for j = 1:n        
%             if (j ~= i)                
%                 if (path_Qmat(i,i) ~= path_Qmat(j,j))
%                     temp = temp * (-path_Qmat(j,j)) / (path_Qmat(i,i) - path_Qmat(j,j));
%                 else
%                     disp('path_Qmat(i,i) == path_Qmat(j,j), divide by 0');
%                 end                
%             end        
%         end
%         temp = temp * path_Qmat(i,i) / path_Qmat(n,n) * exp(path_Qmat(i,i) * T);
%         result = result + temp;
%     end
%     
% end
