function [pred_obs] = func_LR_predict_obs(regress_para, target_time, data_range)

global data_setting;

num_dim = data_setting.dim;
pred_obs = zeros(num_dim, 1);

for d = 1:num_dim
    
    intercept = regress_para(d, 1);
    slope = regress_para(d, 2);
    pred_obs(d) = intercept + slope * target_time;
    
    if (pred_obs(d) < data_range(d, 1))
        pred_obs(d) = data_range(d, 1);
    elseif (pred_obs(d) > data_range(d, 2))
        pred_obs(d) = data_range(d, 2);
    end

end

    
    