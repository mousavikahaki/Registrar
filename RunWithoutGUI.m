close all;
clear all;
clc
addpath('Functions');
% Input CSV file
%StackList_csv_pth = '../../MicroscopeFiles\Neocortical2_StackList.csv';
%  StackList_csv_pth = '/home/kahaki/Matlab/FinalRegistration/MicroscopeFiles/Neocortical2_StackList.csv';
StackList_csv_pth = '/home/wang.shihl/codes/RegistrationEvaluation/TimeLapse_Holtmaat_StackList.csv';
% Transformation Type, 1: Translation, 2: Rigid, 3: Affine, 4:Non-Rigid
TransformationValue = 4;
% Run in 1: Sequential or 2: Parallel
Seq_Par = 1;
% Number of Workes 

TyoeOfRegistration = 7;
mu = 0;
registeration (StackList_csv_pth,TransformationValue,Seq_Par,TyoeOfRegistration,mu);