function [c,n] = BOPlantTipTraceProfile2D(imth,xc,yc,d,lr)
dc = -1;
n = 1;
while dc<d
    n = n + 1;
    if lr
        c = bwtraceboundary(imth,[xc,yc],'N',8,n);
    else
        c = bwtraceboundary(imth,[xc,yc],'N',8,n,'counterclockwise');
    end
    dc = sum(sqrt(diff(c(:,1)).^2+diff(c(:,2)).^2));
end
end
