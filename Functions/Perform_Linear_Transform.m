% This function performs linear transformation (X -> X')
% X can be a Nx3 array of positions, in which case StackPosition must be []
% If X is an image (2d array), or an image stack (3d array), StackPosition must be non-empty
% X_prime has the same format as X.
% L and b define the linear transformation (translation, rigid, or affine)
% For translation, use L=[]

function [X_prime,StackPosition_prime]=Perform_Linear_Transform(X,StackPosition,L,b)

L=L';
b=b';

X_prime=[];
StackPosition_prime=[];
sizeX=size(X);

if length(sizeX)==2
    sizeX(3)=1;
end

if isempty(StackPosition)  % X is a 3xN array of positions
    if isempty(L)
        X_prime=ones(sizeX(1),1)*b;
    else
        X_prime=X*L+ones(sizeX(1),1)*b;
    end
    del_X2=sum((X_prime-X).^2,2);
    disp([mean(del_X2)^0.5, max(del_X2)^0.5])
elseif length(sizeX)==3 % X is a 2d image or a 3d image stack      
    if isempty(L)
        X_prime=X;
        StackPosition_prime=StackPosition+b;
    else
        invL=inv(L);
        Verts=[1,1,1;1,1,sizeX(3);1,sizeX(2),1;sizeX(1),1,1;1,sizeX(2),sizeX(3);sizeX(1),1,sizeX(3);sizeX(1),sizeX(2),1;sizeX(1),sizeX(2),sizeX(3)];
        Verts_prime=Verts*L+ones(8,1)*b;
        Min=round(min(Verts_prime,[],1));
        Max=round(max(Verts_prime,[],1));
        X_prime=zeros(Max(1)-Min(1)+1,Max(2)-Min(2)+1,Max(3)-Min(3)+1,class(X));
        [xx,yy,zz]=ndgrid(Min(1)-b(1):Max(1)-b(1),Min(2)-b(2):Max(2)-b(2),Min(3)-b(3):Max(3)-b(3));

        xxx=round(xx(:).*invL(1,1)+yy(:).*invL(2,1)+zz(:).*invL(3,1));
        yyy=round(xx(:).*invL(1,2)+yy(:).*invL(2,2)+zz(:).*invL(3,2));
        zzz=round(xx(:).*invL(1,3)+yy(:).*invL(2,3)+zz(:).*invL(3,3));
        clear xx yy zz
        
        ind=(xxx>=1 & xxx<=sizeX(1) & yyy>=1 & yyy<=sizeX(2) & zzz>=1 & zzz<=sizeX(3));
        ind2=xxx(ind)+(yyy(ind)-1).*sizeX(1)+(zzz(ind)-1).*(sizeX(1)*sizeX(2));
        X_prime(ind)=X(ind2);
        
        Verts_global_prime=(Verts+ones(8,1)*StackPosition-1)*L+ones(8,1)*b;
        StackPosition_prime=min(Verts_global_prime,[],1);
    end
    
%     figure
%     imshow(max(X,[],3),[0 max(X(:))])
%     figure
%     imshow(max(X_prime,[],3),[0 max(X(:))])
else
    disp('Format of X is incorrect.')
end




