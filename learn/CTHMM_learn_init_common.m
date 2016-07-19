function CTHMM_learn_init_common()



%if (is_glaucoma_disease_model == 1)    
    %learn_converge_tol = 10^(-5);
%elseif (is_Alzheimer_disease_model == 1)
%    learn_converge_tol = 10^(-5);
%else
%    learn_converge_tol = 10^(-8);
%end

global max_iter;
max_iter = 1000;

% % %% init learning Q mat
% global Q_mat_init;
% init_ave_state_dwell = 1;        %% set as global parameter?
% is_add_random_perturb = 0;
% perturb_amount = 0;
% Q_mat_init = CTHMM_learn_init_Q_mat(init_ave_state_dwell, is_add_random_perturb, perturb_amount); % assign uniform probability to each link

