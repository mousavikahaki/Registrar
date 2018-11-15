function [Match_Indexes,RandomSamples] = RANSAC_3D_Non_Rigid(SourceLocations,TargetLocations)
% ============================== About ====================================
% -------------------------------------------------------------------------
% Purpose: 3D Ransac
% Input: 
%   SourceLocations    : N*3,  The locations of the source features
%   TargetLocations    : N*3,  The locations of the target features
%
%  Output:
%   H                  : 3*3, Transformation Matrix
%   Match_Indexes      : N*2, Matched indexes   
% -------------------------------------------------------------------------
% Author: Seyed Mostafa Mousavi Kahaki, Armen Stepanyants  
% Northeastern University, USA
% =========================================================================
% -------------------------------------------------------------------------
NumRandPoints = 5;%20
MaxErrorDistance = 3;
InlierRatio = 0.50;
% CorrectHungarianRatio = 0.15;


NumAllMatches = size(TargetLocations,2);
NumCorrectNeeded = round(InlierRatio*NumAllMatches);% 8;%
% NumCorrectHungarian = round(CorrectHungarianRatio*NumAllMatches);
% try
% FailLimit = 100*nchoosek(NumAllMatches,NumRandPoints)/nchoosek(NumCorrectHungarian,NumRandPoints);%10000;%
% catch
%     FailLimit = 10^6;
% end
% if FailLimit > 10^6
%     disp('The Probability of Success in Ransac is to Low');
%     FailLimit = 10^6;
% end
FailLimit = 10^4;

CorrectNumbers = [];
i = 1;
Match_Indexes = [];
N_L = 5;

while  length(CorrectNumbers) < NumCorrectNeeded && i < FailLimit
    RandomSamples = randi([1 NumAllMatches],1,NumRandPoints);
    RandTargetLocations = TargetLocations(:,RandomSamples);
    RandSourceLocations = SourceLocations(:,RandomSamples);
    
    Min=min([min(RandSourceLocations,[],2),min(TargetLocations,[],2)],[],2);
    Max=max([max(RandSourceLocations,[],2),max(TargetLocations,[],2)],[],2);
    [~,XYZlmn,N_L,Min,Max]=Optimal_Nonrigid_Transform(RandSourceLocations,RandTargetLocations,N_L,Min,Max);
    SourceLocations_nonRigid=Perform_Nonrigid_Transform(SourceLocations,XYZlmn,N_L,Min,Max);
    
    AllDistances = sum((SourceLocations_nonRigid-TargetLocations).^2,1).^0.5;

    
    
    CorrectNumbers = find(AllDistances < MaxErrorDistance);
    i = i+1;
    if length(CorrectNumbers) > length(Match_Indexes)
        Match_Indexes = CorrectNumbers;
    end
       
end

end




