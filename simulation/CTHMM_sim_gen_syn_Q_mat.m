function CTHMM_sim_gen_syn_Q_mat(syn_qi_range, neighbor_setting)

global syn_Q_mat;
global Q_mat_struct;
global neighbor_link_setting;

neighbor_link_setting = neighbor_setting;

%% assign global variable Q_mat_struct, create Q mat structure with desired progression topology (neighbor setting)
CTHMM_MD_create_Q_mat_struct();

%num_para = sum(Q_mat_struct(:));
%str = sprintf('num of para = %d\n', num_para);
%CTHMM_print_log(str);

%% generate random Q_mat value
num_state = size(Q_mat_struct, 1);
syn_Q_mat = zeros(num_state, num_state);

%% generate holding time parameter first
range = syn_qi_range(2) - syn_qi_range(1);

for i = 1:num_state % row
    qi = (rand() * range) + syn_qi_range(1);        
    syn_Q_mat(i, i) = -qi;   
end

for i = 1:num_state % row    
    sum_temp = 0.0;
    for j = 1:num_state   % column   
        if (Q_mat_struct(i, j) == 1)            
            temp = rand();
            syn_Q_mat(i, j) = temp;
            sum_temp = sum_temp + temp;
        end
    end    
    if (sum_temp > 0.0)
        qi = -syn_Q_mat(i, i);
        row = syn_Q_mat(i, :);
        row(i) = 0.0;
        row = row * qi / sum_temp;  
        syn_Q_mat(i, :) = row;
        syn_Q_mat(i, i) = -sum(row);
    else
        syn_Q_mat(i, i) = 0.0; % absorb state
    end
end
syn_Q_mat

end
%filename = sprintf('%s/syn_Q_mat', out_dir);
%save(filename, 'syn_Q_mat');
%syn_Q_mat = [-6 2 2 1 1; 1 -4 0 1 2; 1 0 -4 2 1; 2 1 0 -3 0; 1 1 1 1 -4];

% global syn_base_Q_mat; 
% global Q_mat_cov_struct;
% global is_use_individual_Q_mat;
% global syn_covariate_w_list;
% global num_covariate;

% num_state = size(syn_Q_mat, 1);
% if (is_use_individual_Q_mat == 1)
%     syn_base_Q_mat = syn_Q_mat;
%     num_covariate = 2;
%     
%     %% set up ground truth covariate weight
%     syn_covariate_w_list = zeros(num_covariate, 1);
%     %for i = 1:num_covariate
%         %syn_covariate_w_list(i) = rand();
%     %end
%     syn_covariate_w_list(1) = 0.3;
%     syn_covariate_w_list(2) = 0.1;
%     
%     %% set up cov struct for each qij link
%     Q_mat_cov_struct = cell(num_state, num_state);
%     for i = 1:num_state
%         for j = 1:num_state
%             Q_mat_cov_struct{i,j} = ones(num_covariate, 1);
%         end
%     end
% end

