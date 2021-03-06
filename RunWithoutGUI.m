close all;
clear all;
clc
addpath('Functions');
% Input CSV file
%StackList_csv_pth = '../../MicroscopeFiles\Neocortical2_StackList.csv';
%  StackList_csv_pth = '/home/kahaki/Matlab/FinalRegistration/MicroscopeFiles/Neocortical2_StackList.csv';
% StackList_csv_pth = '/home/wang.shihl/codes/RegistrationEvaluation/TimeLapse_Holtmaat_StackList.csv';
% StackList_csv_pth = '../../MicroscopeFiles/TimeLapse_Holtmaat_StackList.csv';
StackList_csv_pth = '../../MicroscopeFiles/Neocortical2_StackList.csv';
% Transformation Type, 1: Translation, 2: Rigid, 3: Affine, 4:Non-Rigid
TransformationValue = 1;
% Run in 1: Sequential or 2: Parallel
Seq_Par = 1;
% Number of Workes 

TyoeOfRegistration = 3;
% mu = [0,2^2,2^3,2^4,2^5,2^7,2^9,2^10];
mu = [2^-1,2^-2,2^-3,2^-4,2^-5,2^-6,2^-7,2^-8,2^-9,2^-10,0,2^1,2^2,2^3,2^4,2^5,2^6,2^7,2^8,2^9,2^10];

FE=0;
FM = 0;
GO=1;
RET=1;
outputType=1;
DBAdd = 'E:/TilesCreation/NCTracerWeb/New/NCtracerWeb-master/NCtracerWeb-master/NCT-Web/data/nctracer.db';

% for i=1:21
 %   mu(i)
%  registeration (StackList_csv_pth,TransformationValue,Seq_Par,TyoeOfRegistration,1020);
registeration (StackList_csv_pth,TransformationValue,Seq_Par,TyoeOfRegistration,1020,...
    FE,FM,GO,RET,outputType,DBAdd);
% end