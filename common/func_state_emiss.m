function [emiss_prob] = func_state_emiss(state_idx, Y)

global state_list;

state = state_list{state_idx};

%Y = Y{1};

mu = state.mu;
var = state.var;
   
%    dim = size(Y, 2);
%    selected_Y = [];
%    selected_mu = [];
%    selected_sigma = [];
%    for d = 1:dim%        
%        if (isnan(Y(d)) == 0)       
%            selected_Y = [selected_Y Y(d)];
%            selected_mu = [selected_mu mu(d)];
%            selected_sigma = [selected_sigma sigma(d)];                     
%        end
%    end   
   %% normal distribution on the selected data which are not NaN
   %emiss_prob = mvnpdf(selected_Y, selected_mu, selected_sigma);
   
%gaussian distribution
emiss_prob = mvnpdf(Y,mu,var);
   
%% student t distribution
%     dim = size(Y, 2);    
%     C = eye(dim);
%     X = Y - mu;
%     df = 1;
%     emiss_prob = mvtpdf(X,C,df);
    
    
end