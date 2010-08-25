function [surf,psurf] = surfDecimate(surf,vn,fn,tol)
tol = cos(pi/4);

flag = ones(length(surf.faces),1);
ct = 0;
while ~isempty(find(flag)),
    idx = find(flag);
    if mod(ct,10)==0,
        fprintf('%06d\n',length(idx));
    end;
    idx = idx(1);
    if flag(idx),
        faceverts = surf.faces(idx,:)';        
        [f,i] = extractFaces(surf,surf.faces(idx,:),1);    
        i = setdiff(i,idx);
        nd = sum(fn(i,:).*repmat(fn(idx,:),length(i),1),2);
        if all(nd>tol),
            % collapse face and reassign indices
            nv = mean(surf.vertices(faceverts,:));
            numverts = length(surf.vertices);
            surf.vertices = [surf.vertices;nv];
            f = surf.faces(i,:);
            f(find((f(:)==faceverts(1))|(f(:)==faceverts(2))|(f(:)==faceverts(3)))) = numverts+1;
            surf.faces(i,:) = f;
            surf.faces(idx,:) = [];
            flag(i) = 0;
            flag(idx) = [];
        else,
            flag(idx) = 0;
        end;
    end;
    ct = ct+1;
end;