function registeration (varargin)
% ============================== About ====================================
% -------------------------------------------------------------------------
%
% Purpose: Main Registration function to call other functions
% Input:
%   k                  : 1*1, The folder address of stack
%   Mesh                    : 1*1, The file name of stack
%   StackList_csv_pth          : 1*1, The address to save the features
%   filterValue          : 1*1, The address to save the features
%   TransformationValue          : 1*1, The address to save the features
%   Seq_Par          : 1*1, The address to save the features
%   Par_workers          : 1*1, The address to save the features
%   blendingSID          : 1*1, The address to save the features
%
% -------------------------------------------------------------------------
% Author: Seyed Mostafa Mousavi Kahaki, Armen Stepanyants
% Northeastern University, USA
% kahaki@neu.edu, a.stepanyants.neu.edu
% =========================================================================
% -------------------------------------------------------------------------

% Load Parameters
parameters;

% Define Initial Variables
StackList_csv_pth = varargin{1};
TransformationValue = varargin{2};
Seq_Par = varargin{3};
Par_workers = varargin{4};
blendingSID = varargin{5};
handles = varargin{6};
LogHandle = varargin{7};
runFeatureExtraction = handles.checkbox3.Value;
runFeatureMatching = handles.checkbox4.Value;
runGlobalOpt = handles.checkbox5.Value;
runBlending = handles.checkbox6.Value;
TypeOfRegistration = handles.v.Value;
runRetilling = handles.chkretilling.Value;
outputType = handles.popupretilling.Value;
stop = 0;
if handles.chkdebug.Value
    Debug();
end
if handles.checkbox15.Value
    try
        LogHandle.Children(2).String{end+1} = 'Registration Started';
        LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
    catch
    end
end
% Check if CSV file exist
if exist(StackList_csv_pth,'file') > 0
    StackList = table2cell(readtable(StackList_csv_pth,'Delimiter',','));
    
    [PathStr,FolderName]=fileparts(StackList_csv_pth);
    DataFolder=[PathStr,'/Results-',FolderName];
    
    % index to remove invalid files
    errIndxs = [];
    StackSizes_pixels = zeros(size(StackList,1),3);
    for i = 1:size(StackList,1)
        try
            [filepath,~,ext] = fileparts(char(StackList(i,1)));
            if size(ext,2)>1
                InfoImage=imfinfo(char(StackList(i,1)));
            else
                allfiles = dir(filepath);
                [~,~,ext] = fileparts(allfiles(1).name);
            end
        catch
            StackList{i} = [PathStr,'\',StackList{i}];
        end
        
        try
            [filepath,~,ext] = fileparts(char(StackList(i,1)));
            if size(ext,2)>1
                InfoImage=imfinfo(char(StackList(i,1)));
                StackSizes_pixels(i,1) = InfoImage.Height;
                StackSizes_pixels(i,2) = InfoImage.Width;
                StackSizes_pixels(i,3) = size(InfoImage,1);
            else
                allfiles = dir(filepath);
                NumFiles=length(allfiles);
                imgIdx = 0;
                for j = 1:NumFiles
                    [~,~,ext] = fileparts(allfiles(j).name);
                    if strcmpi(ext,'.tif') || strcmpi(ext,'.jp2') || strcmpi(ext,'.png') || strcmpi(ext,'.jpeg')
                        InfoImage=imfinfo(char([allfiles(j).folder,'\',allfiles(j).name]));
                        StackSizes_pixels(i,1) = InfoImage.Height;
                        StackSizes_pixels(i,2) = InfoImage.Width;
                        imgIdx = imgIdx +1;
                    end
                end
                StackSizes_pixels(i,3) = imgIdx;
            end
        catch
            disp(['Can not read the file: ',char(StackList(i,1))]);
            errIndxs = [errIndxs, i];
        end
    end
    StackList (errIndxs,:) = [];
    StackSizes_pixels (errIndxs,:) = [];
    % check this section???
    if size(StackList,2) == 7
        StackSizes_pixels = cell2mat(StackList(:,5:7));
    end
    
    % Get positions from the list
    StackPositions_pixels = cell2mat(StackList(:,2:4)); %xlsread(StackPositions_pixels_csv_pth);
    StackPositions_pixels = StackPositions_pixels(:,[2,1,3]);
    
    % Find stacks overlap
    All_overlaps = FindOverlaps(handles,StackPositions_pixels,StackSizes_pixels,StackList);
    
    if TypeOfRegistration == 2 || TypeOfRegistration == 3
        All_overlaps = zeros(size(All_overlaps));
        All_overlaps(2:size(All_overlaps,1)+1:end) = 1;
        All_overlaps = All_overlaps';
    end
    
    if runFeatureExtraction
        if(exist(DataFolder, 'dir')>0 )
            if(exist([DataFolder,'/features/'], 'dir')>0 )
                if ispc
                    dos_cmd = sprintf( 'rmdir /S /Q "%s"', [DataFolder,'/features/'] );
                    [ ~, ~ ] = system( dos_cmd );
                else
                    dos_cmd = sprintf( 'rmdir /S /Q "%s"', [DataFolder,'/features/'] );
                    [ ~, ~ ] = system( dos_cmd );
                end
            end
        else
            mkdir(DataFolder);
        end
        if handles.checkbox15.Value
            try
                LogHandle.Children(2).String{end+1} = "Feature Extraction Started";
                LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
            catch
            end
        end
        [stop]=FeatureExtraction(handles,LogHandle,StackList,DataFolder,Seq_Par,Par_workers,All_overlaps,StackPositions_pixels,StackSizes_pixels);
        
    end
    
    if runFeatureMatching && ~stop
        if exist([DataFolder,'/tmp'],'dir') > 0
            
            if handles.checkbox15.Value
                try
                    LogHandle.Children(2).String{end+1} = 'Feeature Matching Started';
                    LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
                catch
                end
            end
            [~,Matched,stop]=Generate_Reg_MatchedPoints(handles,LogHandle,All_overlaps,StackList,StackPositions_pixels,StackSizes_pixels,TransformationValue,DataFolder,Seq_Par,Par_workers,params.FM.mu);
        else
            warndlg('The Features Folder is not Exists! Please run Feature Extraction.','!! Warning !!');
        end
        
    end
    runGlobal = 0;
    if runGlobalOpt && ~stop
        if exist([DataFolder,'/tmp'],'dir') > 0
            
            if handles.checkbox15.Value
                try
                    LogHandle.Children(2).String{end+1} = 'Global Optimization Started';
                    LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
                catch
                end
            end
            
            
            switch TransformationValue
                case 1
                    if exist([DataFolder,params.FM.MatchedLocationsFile_Translation],'file')
                        load([DataFolder,params.FM.MatchedLocationsFile_Translation],'Matched');
                        runGlobal = 1;
                    else
                        warndlg('The matching file using Translation transform is not exists, please run feature matching using Translation.','!! Warning !!');
                    end
                case 2
                    
                    if exist([DataFolder,params.FM.MatchedLocationsFile_Rigid],'file')
                        load([DataFolder,params.FM.MatchedLocationsFile_Rigid],'Matched');
                        runGlobal = 1;
                    else
                        warndlg('The matching file using Rigid transform is not exists, please run feature matching using Rigid.','!! Warning !!');
                    end
                case 3
                    if exist([DataFolder,params.FM.MatchedLocationsFile_Affine],'file')
                        load([DataFolder,params.FM.MatchedLocationsFile_Affine],'Matched');
                        runGlobal = 1;
                    else
                        warndlg('The matching file using Affine transform is not exists, please run feature matching using Affine.','!! Warning !!');
                    end
                case 4
                    if exist([DataFolder,params.FM.MatchedLocationsFile_Non_Rigid],'file')
                        load([DataFolder,params.FM.MatchedLocationsFile_Non_Rigid],'Matched');
                        runGlobal = 1;
                    else
                        warndlg('The matching file using Non-Rigid transform is not exists, please run feature matching using Non-Rigid.','!! Warning !!');
                    end
                otherwise
                    if exist([DataFolder,params.FM.MatchedLocationsFile_Translation],'file')
                        load([DataFolder,params.FM.MatchedLocationsFile_Translation],'Matched');
                        runGlobal = 1;
                    else
                        warndlg('The matching file using Translation transform is not exists, please run feature matching using Translation.','!! Warning !!');
                    end
            end
            
            if runGlobal && ~stop
                if TypeOfRegistration == 3
                    StackPositions_pixels(:,3) = 0;
                end
                switch TransformationValue
                    case 1
                        Transform_Type = 'Translation';
                        %                       [SaveLocation,T]=Global_Optimal_Translation(StackPositions_pixels,Matched,DataFolder);
                        [SaveLocation,T]=Global_Linear_Transform(StackPositions_pixels,Matched,Transform_Type,DataFolder);
                    case 2
                        Transform_Type = 'Rigid';
                        %                         [SaveLocation,StackPositions_Registered]=Global_Optimal_Translation(StackPositions_pixels,Matched,DataFolder);
                        [SaveLocation,T]=Global_Linear_Transform(StackPositions_pixels,Matched,Transform_Type,DataFolder);
                    case 3
                        %                [SaveLocation,StackPositions_Registered]=Global_Optimal_Translation(StackPositions_pixels,Matched,DataFolder);
                        %                                                 [SaveLocation,StackPositions_Registered,L,b]=Global_Optimal_Affine(StackPositions_pixels,Matched,DataFolder);
                        %                                                 T.L = L;
                        %                                                 T.b = b;
                        %                                                 T.transform = 'Affine';
                        Transform_Type = 'Affine';
                        [SaveLocation,T]=Global_Linear_Transform(StackPositions_pixels,Matched,Transform_Type,DataFolder);
                    case 4
                        Transform_Type = 'Translation';
                        [SaveLocation,T]=Global_Linear_Transform(StackPositions_pixels,Matched,Transform_Type,DataFolder);
                        T.L = 0;
                end
                if handles.checkbox15.Value
                    try
                        LogHandle.Children(2).String{end+1} = ['Registered Positions Data saved as: ',SaveLocation];
                        LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
                    catch
                    end
                end
            else
                warndlg('Global Optimization can not be run.','!! Warning !!');
            end
        else
            warndlg('The Matched Points file is not Exist! Please run Feature Matching.','!! Warning !!');
        end
    else
        T = [];
    end
    
    if runBlending && ~stop
        if isempty(T)
            switch TransformationValue
                case 1
                    if exist([DataFolder,params.GT.Transformation],'file') > 0
                        load([DataFolder,params.GT.Transformation],'T');
                    else
                        T = [];
                    end
                case 2
                    if exist([DataFolder,params.GR.Transformation],'file') > 0
                        load([DataFolder,params.GT.Transformation],'T');
                    else
                        T = [];
                    end
                case 3
                    if exist([DataFolder,params.GA.Transformation],'file') > 0
                        load([DataFolder,params.GT.Transformation],'T');
                    else
                        T = [];
                    end
                case 4
                    if exist([DataFolder,params.GA.Transformation],'file') > 0
                        load([DataFolder,params.GT.Transformation],'T');
                    else
                        T = [];
                    end
            end
        end
        
        if handles.checkbox15.Value
            try
                LogHandle.Children(2).String{end+1} = 'Blending Stareted';
                LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
            catch
            end
        end
        
        
        if ~isempty(T)
            % 3 for Allignement of Stacks
            if TypeOfRegistration == 3
                [Tile3D_org,Tile3D] = blending_stackreg(StackPositions_pixels,StackSizes_pixels,StackList,blendingSID,T.L,T.b,DataFolder);
            else
                [Tile3D_org,Tile3D,stop] = blending(StackPositions_pixels,StackSizes_pixels,StackList,blendingSID,T.L,T.b,DataFolder);
                %                 [Tile3D_org,Tile3D,stop] = blending_mine(StackPositions_pixels,StackSizes_pixels,StackList,blendingSID,T.L,T.b,DataFolder);
            end
        else
            warndlg('The Transformation file is not Exist! Please run Global optimization.','!! Warning !!');
        end
        %         Tile3D(all(all(Tile3D == 0,3),2),:,:) = [];
        %         Tile3D(:,all(all(Tile3D == 0,3),1),:) = [];
        %         Tile3D_org(all(all(Tile3D_org == 0,3),2),:,:) = [];
        %         Tile3D_org(:,all(all(Tile3D_org == 0,3),1),:) = [];
        if handles.checkbox13.Value
            Visualization();
            VisualizationHandle=findobj(0,'Name','Visualization');
            VisualizationHandle.Visible = 'on';
            
            ButtonGroup1V = VisualizationHandle.Children(2);
            AfterButton = ButtonGroup1V.Children(1);
            set(ButtonGroup1V,'SelectedObject',AfterButton);
            Axes1V = VisualizationHandle.Children(3);
            imshow(max(Tile3D,[],3),[0 max(Tile3D(:))],'Parent',Axes1V);
        end
        
        if handles.checkbox15.Value
            try
                LogHandle.Children(2).String{end+1} = 'Blending Done!';
                LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
            catch
            end
        end
        
        if handles.checkbox10.Value
            volumeViewer(Tile3D);
        end
        assignin('base','Tile3D',Tile3D);
        assignin('base','Tile3D_org',Tile3D_org);
    end
    
    % if Retilling checkbox is checked
    if runRetilling && ~stop
        switch TransformationValue
            case 1
                load([DataFolder,params.GT.Transformation],'T');
            case 2
                load([DataFolder,params.GR.Transformation],'T');
            case 3
                load([DataFolder,params.GA.Transformation],'T');
            case 4
                load([DataFolder,params.GT.Transformation],'T');
        end
        if handles.checkbox15.Value
            try
                LogHandle.Children(2).String{end+1} = 'Retilling Started!';
                LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
            catch
            end
        end
        Retiling(handles,LogHandle,{StackList{:,1}},StackPositions_pixels,StackSizes_pixels,T,DataFolder,outputType,Seq_Par,Par_workers,DBAddress);
    end
    
    if runRetilling && ~stop && (outputType == 1 || outputType == 2)
        ZL = 2;
        NumTiles = inf;
        if handles.checkbox15.Value
            try
                LogHandle.Children(2).String{end+1} = 'Creating Zoom Levels Started!';
                LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
            catch
            end
        end
        
        while NumTiles > 1
            NumTiles = CreateZoomLevels(handles,LogHandle,ZL,DataFolder,outputType,DBAddress);
            ZL = ZL * 2;
        end
    end
    
    if ~stop
        if handles.checkbox15.Value
            try
                LogHandle.Children(2).String{end+1} = 'All Done!';
                LogHandle.Children(2).Value = size(LogHandle.Children(2).String,1);
            catch
            end
        end
    end
    tb9 = findobj(Registrar,'Tag', 'axes3');
    patch('XData',[0,0,100,100],'YData',[0,20,20,0],'FaceColor','green','Parent',tb9);
else
    warndlg('Please select a valid stack list file','!! Warning !!');
end
