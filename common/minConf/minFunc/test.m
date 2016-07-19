function [obj,grad] = test(w,ePerEx,RFInput, lambda, lambda2, A)
    reg_w = w(1:(length(w)-1));
    y = 1 ./ (1 + exp(RFInput * w));
    y2 = 1 + exp(2 * A * w);
    obj = y' * ePerEx + lambda / 2 * (reg_w'*reg_w) + lambda2 * sum(log(y2)) / 2;
    disp(['Part 1: ' num2str(y' * ePerEx) '; Part 2: ' num2str(lambda / 2 * (reg_w'*reg_w)) '; Part 3: ' num2str(lambda2 * sum(log(y2)) / 2) '.']);
    grad = lambda * [reg_w;0] + (repmat(y .* (y-1), 1, size(RFInput,2)) .* RFInput)' * ePerEx ...
           + lambda2 * sum(repmat((1 - 1 ./ y2),1,size(RFInput,2)) .* A)';
end
