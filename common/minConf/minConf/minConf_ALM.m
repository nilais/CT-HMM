function [x,f] = minConf_ALM(funObj,x,A,b,lb,ub,options)
% Use the augmented Lagrangian method to solve a constrained optimization
% problem, use minConf_TMP as the subroutine for the bound-constrained
% problem
% Only adopts a linear constraint of Ax <= b and box constraints x >= lb,
% x <= ub, for simplicity for now

    [verbose,numDiff,optTol,progTol,maxIter,maxProject,suffDec,corrections,adjustStep,bbInit,...
    SPGoptTol,SPGprogTol,SPGiters,SPGtestOpt, rho] = ...
    myProcessOptions(...
    options,'verbose',2,'numDiff',0,'optTol',1e-5,'progTol',1e-9,'maxIter',500,'maxProject',100000,'suffDec',1e-4,...
    'corrections',10,'adjustStep',0,'bbInit',0,'SPGoptTol',1e-6,'SPGprogTol',1e-10,'SPGiters',10,'SPGtestOpt',0, 'rho', 1);
% Augment x and the bounds with the constraints
    x_aug = [x;b - A * x];
    lb_aug = [lb;zeros(size(b))];
    ub_aug = [ub;Inf(size(b))];
    lambda = zeros(size(b));
    mu = 10;
    omega = 0.1;
    eta = 0.794;
    options2 = options;
    all_iter = 0;
    for i=1:maxIter
        options2.optTol = omega;
        options2.progTol = omega^2 * 10;
        % At least 100 iterations
        options2.maxIter = max(maxIter - all_iter,100);
        if all_iter > maxIter
            x = x_aug(1:numel(x));
            return;
        end
        [x_aug,f, num_iter] = minConf_TMP(@(x) ALM_funObj(funObj,x, A,b, lambda, mu), x_aug, lb_aug, ub_aug, options2);
        violation = A * x_aug(1:numel(x)) - b + x_aug(numel(x)+1:end);
        disp(['Number of iterations: ' num2str(num_iter)]);
        disp(['Norm violation: ' num2str(norm(violation))]);
        if norm(violation) <= eta
            if norm(violation) <= options.optTol
                x = x_aug(1:numel(x));
                return;
            end
            % Use multipliers to tighten tolerances
            lambda = lambda - mu * violation;
            eta = eta / mu^0.9;
            omega = omega / mu;
        else
            mu = 10 * mu;
            eta = 1 / mu^0.1;
            % When increasing mu, no need to increase omega by so much..
            omega = 1 / mu;
        end
        all_iter = all_iter + num_iter;
    end
    x = z1;
end

function [f,g] = ALM_funObj(funObj, x_aug, A,b, lambda, mu)
    real_x_end = numel(x_aug) - numel(b);
    real_x = x_aug(1:real_x_end);
    [f,g] = funObj(real_x);
    constr = A * real_x-b + x_aug(real_x_end+1:end);
    f = f - lambda' * constr + 0.5 * mu * sum(constr.^2);
    g = g - A' * lambda + mu * A' * constr;
    % gradient for the augmented part
    g = [g; - lambda + mu * constr];
end