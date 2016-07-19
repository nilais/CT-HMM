function CTHMM_learn_load_para(load_folder)

global Q_mat;
global Nij_mat;
global Ti_list;
global state_reach_mat;
global Q_mat_struct;
global state_list;
global state_reach_mat;

str = sprintf('%s/learn_variables', load_folder);    
load(str);        

