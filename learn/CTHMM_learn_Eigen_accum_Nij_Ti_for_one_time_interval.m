function [is_success] = CTHMM_learn_Eigen_accum_Nij_Ti_for_one_time_interval(cur_time_idx, k_list, l_list)

global U_eigen;
global inv_U_eigen;
global X_eigen;
global Pt_eigen;

global Etij;

global Nij_mat;
global Ti_list;
global state_list;

global Q_mat;
global Q_mat_struct;
global state_reach_mat;

num_state = size(state_list, 1);

is_success = 1;
size_k = size(k_list, 1);
size_l = size(l_list, 1);

%L refers to the matrix of weights found from forward backward algorithm
%divided by elements of transition probability matrix for a time period
L=zeros(num_state,num_state);
for k_idx=1:size_k
    k = k_list(k_idx);
    for l_idx = 1:size_l
        l = l_list(l_idx);
        if (Pt_eigen(k, l) ~= 0)
            L(k,l) = Etij(cur_time_idx,k,l)/Pt_eigen(k, l);
        end
    end
end


% for i=1:num_state
%     tauI = U_eigen*((inv_U_eigen(:,i)*U_eigen(i,:)).*X_eigen)*inv_U_eigen;
%     for k=1:num_state
%         for l=1:num_state
%             Ti_list(i)=Ti_list(i)+tauI(k,l)*L(k,l);
%         end
%     end
% end
% 
% for i=1:num_state
%     for j = 1:num_state
%         if ((i ~= j) && (Q_mat_struct(i,j) == 0))
%             continue;
%         end
%         tauIJ = U_eigen*((inv_U_eigen(:,i)*U_eigen(j,:)).*X_eigen)*inv_U_eigen;
%         for k=1:num_state
%             for l=1:num_state
%                 Nij_mat(i,j)=Nij_mat(i,j)+Q_mat(i,j)*tauIJ(k,l)*L(k,l);
%             end
%         end
%     end
% end


%Calculate expected durations

B = transpose(U_eigen)*L*transpose(inv_U_eigen);
for i=1:num_state
    Ai=(inv_U_eigen(:,i)*U_eigen(i,:)).*X_eigen;
    temp = Ai.*B;
    %temp = Ai.*(transpose(U_eigen)*L*transpose(inv_U_eigen));
    Ti_list(i)=Ti_list(i)+sum(temp(:));
end


%Calculate expected transitions


for i=1:num_state
    for j=1:num_state
        if ((i ~= j) && (Q_mat_struct(i, j) == 0))
            continue;
        end
        Aij = (inv_U_eigen(:,i)*U_eigen(j,:)).*X_eigen;
        temp = Aij.*B;
        %temp = Aij.*(transpose(U_eigen)*L*transpose(inv_U_eigen));
        Nij=sum(temp(:));
        if (i~=j)
            Nij_mat(i,j)=Nij_mat(i,j)+Q_mat(i,j)*Nij;
        else
            Nij_mat(i,j)=Nij_mat(i,j)-Q_mat(i,j)*Nij;
        end
    end
end


