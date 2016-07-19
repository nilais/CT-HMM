function CTHMM_learn_update_Q_mat()

global Q_mat;
global Ti_list;
global Nij_mat;

global state_list;
global Q_mat_struct;
global is_use_individual_Q_mat;
global model_iter_count;

global base_Q_mat;
global NijCov_mat;
global covariate_w_list;

global syn_covariate_w_list;
global syn_base_Q_mat;

num_state = size(state_list, 1);
Q_mat_old = Q_mat;
Q_mat = zeros(num_state, num_state);

%Ti_list(Ti_list<0)=0
%Nij_mat(Nij_mat<0)=0

%Q_mat = Nij_mat.*spfun(@(x) 1./x,Ti_list);
%Q_mat(Q_mat_struct(i,j)~=1)=0;
%row_sum = sum(Q_mat,2);

for i = 1:num_state
    for j = 1:num_state
         if (Q_mat_struct(i, j) == 1)
             if (Ti_list(i) > 0.0 && Nij_mat(i, j) > 0.0)
                Q_mat(i, j) = Nij_mat(i, j) / Ti_list(i);
             else
                %Q_mat(i, j) = 0.00001 + rand() * 0.00001; %%xx give a very small rate for the path
                Q_mat(i, j) = 0.0;
             end
         else
             Q_mat(i, j) = 0.0;
         end
    end
    temp = sum(Q_mat(i, :));
    Q_mat(i, i) = -temp;
end
% 
% argmaxQ = Q_mat;
% 
%[U,D]=eig(Q_mat);
%disp('matrix info')
%cond(U)
%istriu(Q_mat)
%istril(Q_mat)
%isdiag(Q_mat)

% eta=1;
% counter = 0;
% n= num_state;
% if rcond(U)<1e-10
%     sigma=1e-10
%     Q_mat(1,n)=Q_mat(1,n)+sigma;
%     Q_mat(n,1)=Q_mat(n,1)+sigma;
% end

% while rcond(U)<1e-10 && eta > 0.3
%     eta = 0.8*eta;
%     Q_mat = Q_mat_old+eta*(argmaxQ-Q_mat_old);
%     [U,D]=eig(Q_mat);
%     disp('ill-conditioned U matrix')
% end



%% output some statistics
D = diag(Q_mat);
min_qii = min(D);
temp_Q = Q_mat;
for i = 1:num_state
    temp_Q(i,i) = 0;
end
max_qij = max(temp_Q(:));

str = sprintf('max_qij = %f, min_qii = %f\n', max_qij, min_qii);
CTHMM_print_log(str);


%% update covariate weights or update base qij

if (is_use_individual_Q_mat == 1)

    if (mod(model_iter_count, 2) == 1) % update base_Q_mat       
        for i = 1:num_state   
            for j = 1:num_state
                if (Q_mat_struct(i, j) == 1)
                    base_Q_mat(i, j) =  Q_mat(i, j) * Nij_mat(i,j) / NijCov_mat(i,j);
                end
            end                 
        end
        
        syn_base_Q_mat
        base_Q_mat
        
    else % update weight vector
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        num_para = size(covariate_w_list, 1);
        lb = zeros(num_para, 1);
        ub = ones(num_para, 1)*inf;
        
        options.optTol = 1e-7;
        options.maxIter = 200;
        options.method = 'lbfgs';
        options.numDiff = 1;
        %[best_Q_para_list,fval,exitflag,output,lambda,grad,hessian] 

        %% measure the time
        tStart = tic;
        cur_covariate_w_list = covariate_w_list;
        [new_covariate_w_list, fval] = minConf_TMP(@CTHMM_learn_optimize_cov_weight, cur_covariate_w_list, lb, ub, options);
        tEnd = toc(tStart);
        covariate_w_list = new_covariate_w_list;
       
        syn_covariate_w_list
        covariate_w_list

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s
    end
   
end
