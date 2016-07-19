clc

%A = [1 2; 3 4];
A = rand(500, 500);

%A = sprand(500,500,0.1);

global has_computed_A_series;
has_computed_A_series = 0;

t_ls = [0.2 10 100 1000 10000];

run_expm_At = 1;
run_expm = 1;
 
num_t = size(t_ls, 2);

for i = 1:num_t

    t = t_ls(i)

    if (run_expm_At == 1)
        tStart = tic;
        F1 = matlab_expm_At(A, t);
        %F1
        tEnd = toc(tStart);
        str = sprintf('matlab_expm_At: total time: %d minutes and %f seconds\n\n', floor(tEnd/60),rem(tEnd,60))
    end

    if (run_expm == 1)
        tStart = tic;
        A_new = A*t;
        F2 = matlab_expm(A_new);
        %F2
        tEnd = toc(tStart);
        str = sprintf('matlab_expm: total time: %d minutes and %f seconds\n\n', floor(tEnd/60),rem(tEnd,60))
    end

    %F1(12, 15)
    %F2(12, 15)
end

