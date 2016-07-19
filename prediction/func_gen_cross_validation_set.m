function [cross_valid_set, subject_cv_map] = func_gen_cross_validation_set(subject_list, num_cv)

num_subject = size(subject_list, 1);
num_subject_per_fold = round(num_subject / num_cv);
cross_valid_set = cell(num_cv, 1);
subject_cv_map = zeros(num_subject, 1);

for c = 1:num_cv
    cross_valid_set{c}.test_idx_list = [];
    cross_valid_set{c}.train_idx_list = [];
    cross_valid_set{c}.accum_subject = 0;
end

for s = 1:num_subject
    subject_cv_map(s) = -1;
end

c = 1;
for s = 1:num_subject
    
    if (subject_cv_map(s) ~= -1)
        continue;
    end
        
    if (cross_valid_set{c}.accum_subject >= num_subject_per_fold)
        c = c + 1;
    end
    
    if (s < num_subject && (subject_list{s}.ID == subject_list{s+1}.ID))        
        cross_valid_set{c}.test_idx_list = [cross_valid_set{c}.test_idx_list s s+1];
        subject_cv_map(s) = c;
        subject_cv_map(s+1) = c;
        cross_valid_set{c}.accum_subject = cross_valid_set{c}.accum_subject + 2;       
    else
        
        cross_valid_set{c}.test_idx_list = [cross_valid_set{c}.test_idx_list s];
        subject_cv_map(s) = c;
        cross_valid_set{c}.accum_subject = cross_valid_set{c}.accum_subject + 1;

    end
    
end

for c = 1:num_cv
    
   %% generate training set index
   begin_test_idx = cross_valid_set{c}.test_idx_list(1);
   end_test_idx = cross_valid_set{c}.test_idx_list(end);
   cross_valid_set{c}.train_idx_list = [1:1:(begin_test_idx-1) (end_test_idx+1):1:num_subject]';
       
end
