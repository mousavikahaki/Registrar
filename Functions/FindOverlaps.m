function All_overlaps=FindOverlaps(handles,StackPositions_pixels,StackSizes_pixels,StackList)
% ============================== About ====================================
% -------------------------------------------------------------------------
% Purpose: Find the nearest stacks of all stack
% Input:
%   StackPositions      : N*3, (x,y,z), where N is the number of all stacks
%   StackSizes_mm       : N*3, (x,y,z)where N is the number of all stacks
%
%  Output:
%   All_overlaps        : N*N matrix of overlapes
% -------------------------------------------------------------------------
% Author: Seyed Mostafa Mousavi Kahaki, Armen Stepanyants
% Northeastern University, USA
% =========================================================================
% -------------------------------------------------------------------------
% load('../data/StackData.mat'); % StackPositions, StackSizes_mm, StackSizes_pixels
% Dataset = 'Mine';
% Dataset = 'DIADEM2';

N=size(StackPositions_pixels,1);
StackCenters=StackPositions_pixels+StackSizes_pixels(:,1:3)./2;
count=0;
ii=zeros(13*N,1);
jj=zeros(13*N,1);
vv=zeros(13*N,1);
for InputStackNumber=1:N
    StackCenters0=StackCenters(InputStackNumber,:);
    StackSizes_mm0=StackSizes_pixels(InputStackNumber,:);
    NeighInd = findStackNeighbors(InputStackNumber,StackSizes_pixels,StackPositions_pixels(:,1:3));
    
    for j=1:length(NeighInd)
        if NeighInd(j)>InputStackNumber
            count=count+1;
            StackCenters1=StackCenters(NeighInd(j),:);
            StackSizes_mm1=StackSizes_pixels(NeighInd(j),:);
            ii(count)=InputStackNumber;
            jj(count)=NeighInd(j);
            vv(count) = prod(((StackSizes_mm1+StackSizes_mm0)./2)-abs(StackCenters0-StackCenters1));
        end
    end
end
All_overlaps = sparse(ii(1:count),jj(1:count),vv(1:count),N,N);

% figure; plot3(StackPositions_pixels(:,1),StackPositions_pixels(:,2),StackPositions_pixels(:,3),'x');hold on;
% for i= 1:size(StackPositions_pixels,1)
%     [PathStr,StackName]=fileparts(StackList{i,1});
%     text(StackPositions_pixels(i,1),StackPositions_pixels(i,2),StackPositions_pixels(i,3),[num2str(i),'-',StackName],'FontSize',8);
%
% end
% f1 = figure;
if handles.checkbox16.Value
    try
    DatasetMap();
    DatasetMapHandle=findobj(0,'Name','Stack Map');
%     DatasetMapHandle.Position = [140.8          50.0769230769231                       112          32.3076923076923];
%     tb3 = DatasetMapHandle;%findobj(NCT_Registration,'Tag', 'axes2');
    if ~isempty(DatasetMapHandle)

%     end
    cla(DatasetMapHandle,'reset')
    axes(DatasetMapHandle);
    axis equal;
    view(3);
    
    DrawStackMap(StackPositions_pixels, StackSizes_pixels)
    
    for j=1:size(StackPositions_pixels,1)
        %plot3(StackPositions_pixels(j,1),StackPositions_pixels(j,2),StackPositions_pixels(j,3),'x','Parent',tb3),hold on
        
        try
            boxsize = [StackSizes_pixels(j,1),StackSizes_pixels(j,2),StackSizes_pixels(j,3)];
%             DrawCube([StackPositions_pixels(j,1),StackPositions_pixels(j,2),StackPositions_pixels(j,3)], boxsize);
            %     ind1=find(StackList{j,1}=='\',1,'last');
            %     ind2=find(StackList{j,1}=='.',1,'last');
            %     StackName=StackList{j,1}(ind1+1:ind2-1);
            if ~isempty(StackList)
                [PathStr,StackName]=fileparts(StackList{j,1});
            else
                StackName = '';
            end
            %FileName = regexp(StackList(j,1),'\\([^\\]*)$','tokens','once');
            %StackName = regexp(FileName{1},'.([^.]*)$','tokens','once');
            text(StackPositions_pixels(j,1)+boxsize(1)/2,StackPositions_pixels(j,2)+boxsize(2)/2,StackPositions_pixels(j,3)+boxsize(3)/2,[num2str(j),' ',StackName],'FontSize',6),hold on
            drawnow();
        catch
            t=0;
        end
    end

    end
    catch
    end
end
