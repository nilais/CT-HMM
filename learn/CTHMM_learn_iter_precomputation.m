function CTHMM_learn_iter_precomputation()

tStartIter = tic;

global is_use_distinct_time_grouping;
global is_use_individual_Q_mat;

global state_list;
global learn_performance;
global model_iter_count;

global Q_mat;
global learn_method;
global distinct_time_list;

%% main variables for eigen method
global U_eigen;
global inv_U_eigen;
global D_eigen;
global eigen_num_singular;

%% uniformization method
global R_unif_list;
global max_qi;
global unif_M_list;

num_state = size(state_list, 1);

if (learn_method == 1) % expm
    if (is_use_distinct_time_grouping == 1)
        CTHMM_precompute_distinct_time_Pt_list();
    end

elseif (learn_method == 2) % uniformization    
    
    if (is_use_individual_Q_mat == 0)
    
        %% compute M
        max_distinct_time = max(distinct_time_list);
        str = sprintf('max distinct time = %f\n', max_distinct_time);
        CTHMM_print_log(str);

        D = -diag(Q_mat);
        max_qi = max(D);
        max_qt = max_qi * max_distinct_time;    
        M = ceil(4 + 6 * sqrt(max_qt) + max_qt);

        str = sprintf('max M = %d, max_qi = %f, max_t = %d, max qt = %f\n', M, max_qi, max_distinct_time, max_qt);
        CTHMM_print_log(str);

        %% compute R, R^2, ..., R^(M) 
        R_mat = Q_mat / max_qi + eye(num_state);
        R_unif_list = cell(M+1, 1);
        R_unif_list{1} = eye(num_state);
        R_unif_list{2} = R_mat;
        for r = 3:(M+1)
            R_unif_list{r} = R_mat * R_unif_list{r-1};
        end
    
    end
    
    %% compute Pt list
    if (is_use_distinct_time_grouping == 1)
        CTHMM_precompute_distinct_time_Pt_list();
        num_distinct_time = size(distinct_time_list, 1);
        unif_M_list = zeros(num_distinct_time, 1);
    end        
    
elseif (learn_method == 3) % eigen
    if (is_use_distinct_time_grouping == 1)
        CTHMM_precompute_distinct_time_Pt_list();
    end
    
    %% eigen decompose Q
    CTHMM_print_log('Do Eigen');
        
    [U_eigen, D_eigen,V] = eig(Q_mat);
    %, 'nobalance');
    n=size(Q_mat,1);
    v=diag(V'*U_eigen);
    inv_U_eigen = V'./repmat(v,1,n);

    %[U_eigen, D_eigen] = eig(Q_mat);
    
    %inv_U_eigen = inv(U_eigen);        
    %[msgStr,msgId] = lastwarn;        
        
    %if (strncmp(msgStr, 'Matrix is close to singular', 15) == 1)        
    %    lastwarn('');
    %    eigen_num_singular = eigen_num_singular + 1;
    %    
	%	CTHMM_print_log(msgStr);
		
		%% switch method to be expm for this run?
        %CTHMM_print_log('Set method to be expm for this run');        
        %learn_method = 1;		
    %end
    
elseif (learn_method == 4) % nest V    
    if (is_use_distinct_time_grouping == 1)
        D = -diag(Q_mat);
        max_qi = max(D);
        max_time = max(distinct_time_list);    
        max_inner_jump =  ceil(max_qi * 5 * max_time);
        max_inner_jump    
        CTHMM_precompute_inner_distinct_time_Pt_list(max_inner_jump); 
    end    
end

tEndTemp = toc(tStartIter);
str = sprintf('Iter precomputation -> %d minutes and %f seconds\n', floor(tEndTemp/60),rem(tEndTemp,60));
CTHMM_print_log(str);
learn_performance.time_precomp_list(model_iter_count) = tEndTemp;  
