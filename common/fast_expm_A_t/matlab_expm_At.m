function F = matlab_expm_At(t)

%EXPM   Matrix exponential.

%   EXPM(X) is the matrix exponential of X.  EXPM is computed using
%   a scaling and squaring algorithm with a Pade approximation.
%
%   Although it is not computed this way, if X has a full set
%   of eigenvectors V with corresponding eigenvalues D, then
%   [V,D] = EIG(X) and EXPM(X) = V*diag(exp(diag(D)))/V.
%
%   EXP(X) computes the exponential of X element-by-element.
%
%   See also LOGM, SQRTM, FUNM.

%   Reference:
%   N. J. Higham, The scaling and squaring method for the matrix
%   exponential revisited. SIAM J. Matrix Anal. Appl.,
%   26(4) (2005), pp. 1179-1193.
%
%   Nicholas J. Higham
%   Copyright 1984-2012 The MathWorks, Inc.
%   $Revision: 5.10.4.8 $  $Date: 2012/07/28 23:09:19 $

global A;

[m_vals, theta, classA] = expmchk; % Initialization
normA = norm(A,1);
normAt = normA * t;

global has_computed_A_series;

global A2;
global A4;
global A6;
global A8;

%has_computed_A_series

if (has_computed_A_series == 0) 
    
    %time1 = tic;

    A2 = A*A;
    A4 = A2*A2; 
    A6 = A2*A4;
    A8 = A2*A6;
    
    %time2 = toc(time1);
    %str = sprintf('Precompute A multi: total time: %d minutes and %f seconds\n\n', floor(time2/60),rem(time2,60))

    has_computed_A_series = 1;
end

%if normA <= theta(end)
if normAt <= theta(end)
    % no scaling and squaring is required.
    for i = 1:length(m_vals)
        if normAt <= theta(i)
            
            
            s = 0;
            m_vals(i);
            
            F = PadeApproximantOfDegree(s, t, m_vals(i)); % pade approximate of degree m
            
            break;
        end
    end
else

    [g, s] = log2(normAt/theta(end)); % use m = 13
    
    s = s - (g == 0.5); % adjust s if normA/theta(end) is a power of 2.
    
    %s
    
    %A = A/2^s;    % Scaling
    %B = A * (t/2^s);
    
    %m_vals(end)
    
    F = PadeApproximantOfDegree(s, t, m_vals(end));
    
    %time1 = tic;
    for i = 1:s
        F = F*F;  % Squaring
    end
    %time2 = toc(time1);
    %str = sprintf('Squaring phase: total time: %d minutes and %f seconds\n\n', floor(time2/60),rem(time2,60))
    
end
% End of expm

%%%%Nested Functions%%%%
    function [m_vals, theta, classA] = expmchk
        %EXPMCHK Check the class of input A and
        %    initialize M_VALS and THETA accordingly.
        classA = class(A);
        switch classA
            case 'double'
                m_vals = [3 5 7 9 13];
                % theta_m for m=1:13.
                theta = [%3.650024139523051e-008
                         %5.317232856892575e-004
                          1.495585217958292e-002  % m_vals = 3
                         %8.536352760102745e-002
                          2.539398330063230e-001  % m_vals = 5
                         %5.414660951208968e-001
                          9.504178996162932e-001  % m_vals = 7
                         %1.473163964234804e+000
                          2.097847961257068e+000  % m_vals = 9
                         %2.811644121620263e+000
                         %3.602330066265032e+000
                         %4.458935413036850e+000
                          5.371920351148152e+000];% m_vals = 13
            case 'single'
                m_vals = [3 5 7];
                % theta_m for m=1:7.
                theta = [%8.457278879935396e-004
                         %8.093024012430565e-002
                          4.258730016922831e-001  % m_vals = 3
                         %1.049003250386875e+000
                          1.880152677804762e+000  % m_vals = 5
                         %2.854332750593825e+000
                          3.925724783138660e+000];% m_vals = 7
            otherwise
                error(message('MATLAB:expm:inputType'))
        end
    end

    function F = PadeApproximantOfDegree(s, t, m)
        
        %PADEAPPROXIMANTOFDEGREE  Pade approximant to exponential.
        %   F = PADEAPPROXIMANTOFDEGREE(M) is the degree M diagonal
        %   Pade approximant to EXP(A), where M = 3, 5, 7, 9 or 13.
        %   Series are evaluated in decreasing order of powers, which is
        %   in approx. increasing order of maximum norms of the terms.

        n = length(A);
        c = getPadeCoefficients;

        % Evaluate Pade approximant.
        switch m

            case {3, 5, 7, 9}

                scaling_factor = t;
                
                B = A * scaling_factor;
                B2 = A2 * scaling_factor^2;
                B4 = A4 * scaling_factor^4;
                B6 = A6 * scaling_factor^6;
                B8 = A8 * scaling_factor^8;
                
                Bpowers = cell(ceil((m+1)/2),1);
                Bpowers{1} = eye(n,classA);
                Bpowers{2} = B2;
                Bpowers{3} = B4;
                Bpowers{4} = B6;
                Bpowers{5} = B8;
                
                %for j = 3:ceil((m+1)/2)
                %    Apowers{j} = Apowers{j-1}*Apowers{2};
                %end
                
                U = zeros(n,classA); 
                V = zeros(n,classA);

                for j = m+1:-2:2
                    U = U + c(j) * Bpowers{j/2};
                end
                U = B*U;
                
                for j = m:-2:1
                    V = V + c(j) * Bpowers{(j+1)/2};
                end
                F = (-U+V)\(U+V);

            case 13

                % For optimal evaluation need different formula for m >= 12.
                scaling_factor = (t/2^s);
                %B = scaling_factor * A;
                %B2 = scaling_factor^2 * A2;
                %B4 = scaling_factor^4 * A4;
                %B6 = scaling_factor^6 * A6;
                scaling_factor_p6 = scaling_factor^6;
                scaling_factor_p4 = scaling_factor^4;
                scaling_factor_p2 = scaling_factor^2;
                
                %U = B * (B6*(c(14)*B6 + c(12)*B4 + c(10)*B2) ...
                %    + c(8)*B6 + c(6)*B4 + c(4)*B2 + c(2)*eye(n,classA) );
                
                %time1 = tic;
                
                d = c;
                
                d(14) = (scaling_factor * scaling_factor_p6 * c(14) * scaling_factor_p6);
                d(12) = (scaling_factor * scaling_factor_p6 * c(12) * scaling_factor_p4);
                d(10) = (scaling_factor * scaling_factor_p6 * c(10) * scaling_factor_p2);
                d(8) = (scaling_factor * c(8) * scaling_factor_p6);
                d(6) = (scaling_factor * c(6) * scaling_factor_p4);
                d(4) = (scaling_factor * c(4) * scaling_factor_p2);
                d(2) = (scaling_factor * c(2));
                
                
                U = A * (A6  * (d(14) * A6 + d(12) * A4  + d(10) * A2) ...
                    + d(8) * A6 + d(6) * A4 + d(4) * A2 + d(2) * eye(n,classA)  );                 %speye(n,n)
                
                
                d(13) = (scaling_factor_p6 * c(13) * scaling_factor_p6);
                d(11) = (scaling_factor_p6 * c(11) * scaling_factor_p4);
                d(9) = (scaling_factor_p6 * c(9) * scaling_factor_p2);
                d(7) = (c(7) * scaling_factor_p6);
                d(5) = (c(5) * scaling_factor_p4);
                d(3) = (c(3) * scaling_factor_p2);
                d(1) = c(1);
                
                V = A6 * (d(13) * A6 + d(11) * A4 + d(9) * A2) ...
                    + d(7) * A6 + d(5) * A4 + d(3) * A2 + d(1) * eye(n,classA);

                
                %time2 = toc(time1);
                %str = sprintf('Compute U, V: total time: %d minutes and %f seconds\n\n', floor(time2/60),rem(time2,60))

                
                %time1 = tic;               
                F = (-U+V)\(U+V);                
                %time2 = toc(time1);
                
                %str = sprintf('Solve F: total time: %d minutes and %f seconds\n\n', floor(time2/60),rem(time2,60))

        end

        function c = getPadeCoefficients
            % GETPADECOEFFICIENTS Coefficients of numerator P of Pade approximant
            %    C = GETPADECOEFFICIENTS returns coefficients of numerator
            %    of [M/M] Pade approximant, where M = 3,5,7,9,13.
            switch m
                case 3
                    c = [120, 60, 12, 1];
                case 5
                    c = [30240, 15120, 3360, 420, 30, 1];
                case 7
                    c = [17297280, 8648640, 1995840, 277200, 25200, 1512, 56, 1];
                case 9
                    c = [17643225600, 8821612800, 2075673600, 302702400, 30270240, ...
                         2162160, 110880, 3960, 90, 1];
                case 13
                    c = [64764752532480000, 32382376266240000, 7771770303897600, ...
                         1187353796428800,  129060195264000,   10559470521600, ...
                         670442572800,      33522128640,       1323241920,...
                         40840800,          960960,            16380,  182,  1];
            end
        end
    end
%%%%Nested Functions%%%%
end
