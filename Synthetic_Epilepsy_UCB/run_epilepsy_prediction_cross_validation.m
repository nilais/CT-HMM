%clear all; close all; clc

%% setup output directory
top_out_dir = '../../../output_epilepsy_models_cv10';
mkdir(top_out_dir);

%% load eye data from the datasheet
num_min_hist_visit = 4; % 4 history visits
min_num_visit = num_min_hist_visit + 1; % at least one future visit
is_parse_glaucoma_data = 1;

%% parse epilepsy UCB dataset
[seq_list] = parseSubjects('hmm copy.csv');

%% data setting
global data_setting;
data_setting = struct;
%data_setting = 0; % for reset
data_setting.dim = 1;
%data_setting.type_name_ls = {'emission'};
%data_setting.dim_value_range_ls{1} = [100.5 99.5 98 96 93 90 85 80:(-10):20]; % dim1
%data_setting.dim_value_range_ls{2} = [130:(-5):80 70:(-10):30]; % dim2
%data_setting.dim_value_range_ls{1} = [8 5 4 3 2 -2.5];
%data_setting.draw_origin_lefttop = 1;

%% cross validation setting
%num_cv = 10;
%cv_idx_list = [1:1:10];

%num_cv = 1;
%cv_idx_list = [1:1:1];

num_cv = 2;
cv_idx_list = [1:1:1];

%% start training CT-HMMs: 10 fold cross validation
learn_method = 3; % 1: expm 2: unif 3: eigen
is_outer_soft = 1; % 1: soft, 2: hard
func_epilepsy_train_cross_validation(top_out_dir, seq_list, learn_method, is_outer_soft, num_cv, cv_idx_list);

%% prediction test using the pretrained CT-HMM models
%pred_out_dir = top_out_dir;
%pretrain_CTHMM_dir = top_out_dir;
%func_epilepsy_predict_cross_validation(seq_list, pred_out_dir, pretrain_CTHMM_dir, num_cv);
