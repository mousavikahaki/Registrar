function FeatureMatching1
StackList_csv_pth = 'C:\Users\Seyed\Documents\DatasetTests\registrar\Data\Neocortical.csv';
TransformationValue = 1;
paramsFMPad = 0;
paramsFMminReqFeatures = 15;
StackList = table2cell(readtable(StackList_csv_pth,'Delimiter',','));
[PathStr,FolderName]=fileparts(StackList_csv_pth);
DataFolder=[PathStr,'/Results-',FolderName];


% For Windows/Linux
% overlaps_csv = cell2mat(table2cell(readtable([DataFolder,'/overlaps.csv'],'Delimiter',',')));
% StackPositions_pixels_csv = cell2mat(table2cell(readtable([DataFolder,'/StackPositions_pixels.csv'],'Delimiter',',')));
% StackSizes_pixels_csv = cell2mat(table2cell(readtable([DataFolder,'/StackSizes_pixels.csv'],'Delimiter',',')));

% For Mac/Unix
All_overlaps = cell2mat(table2cell(readtable([DataFolder,'/overlaps.csv'],'Delimiter',',')));
StackPositions_pixels = cell2mat(table2cell(readtable([DataFolder,'/StackPositions_pixels.csv'],'Delimiter',',')));
StackSizes_pixels = cell2mat(table2cell(readtable([DataFolder,'/StackSizes_pixels.csv'],'Delimiter',',')));
All_overlaps=All_overlaps(:,2:end);
% Define parameters
matchedLocationFile_Translation = [DataFolder,'/MatchedPoints_Translation.mat'];
matchedLocationFile_Rigid = [DataFolder,'/MatchedPoints_Rigid.mat'];
matchedLocationFile_Affine = [DataFolder,'/MatchedPoints_Affine.mat'];
matchedLocationFile_Non_Rigid = [DataFolder,'/MatchedPoints_Non-Rigid.mat'];
Matched=cell(size(All_overlaps));
Matched_hung=cell(size(All_overlaps));

k = 1;
for i=1:size(All_overlaps,1)
    for j=1:size(All_overlaps,2)
        if All_overlaps(i,j)>0
            Overlaps(k,1) = i;
            Overlaps(k,2) = All_overlaps(i,j);
            k = k + 1;
        end
    end
end


for i=1:size(Overlaps,1)
       SourceID = Overlaps(i,1);
    Source_seed_r_seed = hdf5read([DataFolder,'/tmp/Feature_seeds',num2str(SourceID),'.h5'], '/dataset1');
    Source_seed_FeatureVector = hdf5read([DataFolder,'/tmp/Feature_vector',num2str(SourceID),'.h5'], '/dataset1');
    if ~isempty(Source_seed_r_seed)
        

            TargetID=Overlaps(i,2);
            
            Target_seed_r_seed = hdf5read([DataFolder,'/tmp/Feature_seeds',num2str(TargetID),'.h5'], '/dataset1');
            Target_seed_FeatureVector = hdf5read([DataFolder,'/tmp/Feature_vector',num2str(TargetID),'.h5'], '/dataset1');
            if ~isempty(Target_seed_r_seed)
                
                [SourceSubFeatures,SourceSubFeaturesVectors] = OverlapRegion1(SourceID,TargetID,Source_seed_r_seed,Source_seed_FeatureVector,StackPositions_pixels,StackSizes_pixels,paramsFMPad);
                [TargetSubFeatures,TargetSubFeaturesVectors] = OverlapRegion1(TargetID,SourceID,Target_seed_r_seed,Target_seed_FeatureVector,StackPositions_pixels,StackSizes_pixels,paramsFMPad);
                
                if size(SourceSubFeatures,1) >= paramsFMminReqFeatures && size(TargetSubFeatures,1)>= paramsFMminReqFeatures%params.FM.minReqFeatures
                    
                    Source_StackPositions = StackPositions_pixels(SourceID,:);
                    Target_StackPositions = StackPositions_pixels(TargetID,:);
                    [MatchLocations,MatchLocationsHang] = Stitching_3D_Func(SourceSubFeatures,SourceSubFeaturesVectors,TargetSubFeatures,TargetSubFeaturesVectors,Source_StackPositions,Target_StackPositions,TransformationValue);
                    
                    Matched(SourceID,TargetID) = {MatchLocations};
                    Matched_hung(SourceID,TargetID) = {MatchLocationsHang};
                    
                end
                
            end

    end
   
end


if TransformationValue ==1
    save(matchedLocationFile_Translation,'Matched','Matched_hung','-v7.3');
elseif TransformationValue ==2
    save(matchedLocationFile_Rigid,'Matched','Matched_hung','-v7.3');
elseif TransformationValue ==3
    save(matchedLocationFile_Affine,'Matched','Matched_hung','-v7.3');
elseif TransformationValue ==4
    save(matchedLocationFile_Non_Rigid,'Matched','Matched_hung','-v7.3');
end

disp(['Matched Locations saved as: ',DataFolder]);
end
