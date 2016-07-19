function [ subject_list ] = parseSubjects( filename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
M = csvToMatrix(filename);
rows = size(M,1);

C = unique(M(:,1));
num_subjects = size(C,1);

dict = containers.Map('KeyType','uint32','ValueType','uint32');

for i=1:size(C,1)
    dict(C(i))=i;
end

subject_list = cell(num_subjects, 1);
for p=1:num_subjects
    subject_list{p}.num_visit = 0;
end

for i=1:rows
    id = M(i,1);
    p = dict(id);
    %subject_list{p}.ID = id;
    subject_list{p}.ID=p;
    k = subject_list{p}.num_visit+1;
    subject_list{p}.num_visit = k;
end

for p=1:num_subjects
    subject_list{p}.visit_time_list = zeros(subject_list{p}.num_visit, 1);
    subject_list{p}.visit_data_list = zeros(subject_list{p}.num_visit, 1);
    subject_list{p}.visit_index = 0;
end

for i=1:rows
    id = M(i,1);
    p=dict(id);
    %subject_list{p}.ID = id;
    subject_list{p}.ID=p;
    k = subject_list{p}.visit_index+1;
    subject_list{p}.visit_index = k;
    subject_list{p}.visit_time_list(k) = M(i,2);
    subject_list{p}.visit_list{k}.time = M(i,2);
    subject_list{p}.visit_data_list(k) = M(i,3);
    subject_list{p}.visit_list{k}.data = [M(i,3)];
end

for p=1:num_subjects
    visits = [subject_list{p}.visit_time_list, subject_list{p}.visit_data_list];
    visits = sortrows(visits);
    subject_list{p}.visit_time_list=visits(:,1);
    subject_list{p}.visit_data_list=visits(:,2);
end

for p=1:num_subjects
    for k=1:subject_list{p}.num_visit
        subject_list{p}.visit_list{k}.time = subject_list{p}.visit_time_list(k);
        subject_list{p}.visit_list{k}.data = [subject_list{p}.visit_data_list(k)];
    end
end


end

