function [cr,cl,nr,nl,xce,yce,imthe] = BOPlantTipProfile2D(imth,imtht,c,cm,d,s)
%% Erode
se = strel('disk',s);
imthe = imerode(imth,se);
imthte = imerode(imtht,se);
imlabel = bwlabel(imthte);
for i=1:max(imlabel(:))
    a(i) = sum(sum(imlabel==i));
end
imthte = imlabel==find(a==max(a));
imthe = imreconstruct(imthte,imthe);
%% Shortest distance
imt = zeros(size(imtht))==1;
imt(c(cm,1),c(cm,2)) = 1;
imdist = bwdist(imt);

[x,y] = find(imthe,1);
ce = bwtraceboundary(imthe,[x,y],'N',8);
idxI = sub2ind(size(imth),ce(:,1),ce(:,2));
dt = imdist(idxI);
idxd = find(dt==min(dt),1);
[xce,yce] = ind2sub(size(imth),idxI(idxd));
[cr,nr] = BOPlantTipTraceProfile2D(imthe,xce,yce,d,1);
[cl,nl] = BOPlantTipTraceProfile2D(imthe,xce,yce,d,0);

% for dist fun
% se = strel('disk',s+1);
% imthe = imerode(imth,se);
imthe = imreconstruct(imthe,imth);

% %% Erode
% se = strel('disk',s);
% imthte = imerode(imtht,se);
% imlabel = bwlabel(imthte);
% for i=1:max(imlabel(:))
%     a(i) = sum(sum(imlabel==i));
% end
% imthte = imlabel==find(a==max(a));
% %% Shortest distance
% imt = zeros(size(imtht))==1;
% imt(c(cm,1),c(cm,2)) = 1;
% imdist = bwdist(imt);
% 
% [x,y] = find(imthte,1);
% ce = bwtraceboundary(imthte,[x,y],'N',8);
% idxI = sub2ind(size(imtht),ce(:,1),ce(:,2));
% dt = imdist(idxI);
% idxd = find(dt==min(dt),1);
% [xce,yce] = ind2sub(size(imtht),idxI(idxd));
% [cr,nr] = BOPlantTipTraceProfile2D(imthte,xce,yce,d,1);
% [cl,nl] = BOPlantTipTraceProfile2D(imthte,xce,yce,d,0);
end
