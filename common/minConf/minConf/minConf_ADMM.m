function [x,f] = minConf_ADMM(funObj,x,funProj,options)
    [verbose,numDiff,optTol,progTol,maxIter,maxProject,suffDec,corrections,adjustStep,bbInit,...
    SPGoptTol,SPGprogTol,SPGiters,SPGtestOpt, rho] = ...
    myProcessOptions(...
    options,'verbose',2,'numDiff',0,'optTol',1e-5,'progTol',1e-9,'maxIter',500,'maxProject',100000,'suffDec',1e-4,...
    'corrections',10,'adjustStep',0,'bbInit',0,'SPGoptTol',1e-6,'SPGprogTol',1e-10,'SPGiters',10,'SPGtestOpt',0, 'rho', 1);
    u1 = zeros(size(x));
    uz = zeros(size(x));
    z1 = zeros(size(x));
    for i=1:maxIter
        [x,f] = minFunc(@(x) ADMM_funObj(funObj,x, uz, rho), x, options);
        z0 = z1;
        z1 = funProj(x + u1);
        u1 = x - z1 + u1;
        uz = z1 - u1;
        primal_residual = x - z1;
        dual_residual = - rho * (z1 - z0);
        norm_prim = norm(primal_residual);
        norm_dual = norm(dual_residual);
        if norm_prim > norm_dual * 10
            rho = rho * 2;
        elseif norm_dual > norm_prim * 10
            rho = rho / 2;
        end
    end
    x = z1;
end

function [f,g] = ADMM_funObj(funObj, x, uz, rho)
    [f,g] = funObj(x);
    f = f + 0.5 * rho * sum((x - uz).^2);
    g = g + rho * (x - uz);
end