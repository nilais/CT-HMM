function [is_termindate] = CTHMM_learn_decide_termination(cur_all_subject_prob, pre_all_subject_prob)

global learn_converge_tol;


if (pre_all_subject_prob == -inf) % current iteration is the first
    is_termindate = 0;
    return;
end

relative_diff = abs(cur_all_subject_prob - pre_all_subject_prob) / abs(pre_all_subject_prob);

str = sprintf('Likelihood relative difference = %f\n', relative_diff);
CTHMM_print_log(str);

if (cur_all_subject_prob < pre_all_subject_prob) 
    str = sprintf('Find cur_all_subject_prob < pre_all_subject_prob, terminate EM learning\n');
    CTHMM_print_log(str);
    is_termindate = 1;
elseif (relative_diff < learn_converge_tol)
    str = sprintf('Find relative_diff < learn_converge_tol, terminate EM learning\n');
    CTHMM_print_log(str);
    is_termindate = 1;
else
    is_termindate = 0;
end 
    