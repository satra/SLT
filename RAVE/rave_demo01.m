%function [ output_args ] = rave_demo01( input_args )
%RAVE_DEMO01 Summary of this function goes here
%  Detailed explanation goes here

rave_command('init');
basedir = fileparts(which(mfilename));
rave_input('surf_file',fullfile(basedir,'data','surfdata.mat'));
rave_input('surf_id',2);
rave_input('show_curvature',1);
rave_input('show_act',0);
rave_input('show_roiborders',1);
rave_input('roi_displayid',-1);

rave_command('display');
