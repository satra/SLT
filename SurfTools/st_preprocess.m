function [surf] = st_preprocess( surf )
% ST_PREPROCESS Preprocesses a surface to generate information for
% calculating qualities such as curvature.
%   The function returns the following fields in the structure surf
%   .vertices   : original list of vertices provided
%   .faces      : original list of faces
%   .normals    : face normals
%   .angles     : angles at each vertex of each face
%   .edges      : edges represented by vertex ID
%   .faceVertexID: correspondence between faces and vertices
%   .cotidx     : index to angles subtending an edge
%   .weights    : sum of the cotangent of the angles subtending an edge

% These quantities are all calculated using vectorized
% operations. Converting some of them to C might speed up the
% process, but it does not take too long to compute the
% quantities. 

% TODO:
% 1.better way to get at edges/cotidx and to treat special cases
% where the edge belongs to one face only
% 2.check for orientation/manifold problems
% 3.speed up parts of the code
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Id: st_preprocess.m 120 2005-11-24 05:34:36Z satra $

% $NoKeywords: $

v = surf.vertices;
f = surf.faces;
% surf = vtkReorient(v,int32(f),0,0,0);
v = surf.vertices;
f = surf.faces;

clear surf;

% remove lone verts
a = [1:length(v)]';
idx = unique(f(:));
a(idx) = [1:length(idx)];
idx = setdiff([1:length(v)]',idx);
f = a(f);
lonevertidx = idx;
loneverts = v(idx,:);
v(idx,:) = [];

%Remove duplicate triangles
idx = st_removeduplicates(f);
if ~isempty(idx),
    f(idx,:) = [];
end

% Calculate normals, angles and areas
% this function can also be made to return 'd' the norm of each edge if needed
[normals,th,FVA] = st_calcNAA(v,f);

% calculate edge info with angle indices
% create an array of all existing edges
e = [f(:,[1,2]);f(:,[2,3]);f(:,[3,1])];
%val = cot([th(:,3);th(:,1);th(:,2)]);

% give each angle in each face an id
idx1 = reshape(1:(3*length(th)),length(th),3);
% make the angle correspond to the edge
% edge v1-v2 subtends th3 and so on
idx1 = idx1(:,[3 1 2]);

% THe following code fragment calculates the sum of cotangents of
% the angles subtending a vertex.
s1 = tril(sparse(e(:,1),e(:,2),idx1(:)));
s2 = tril(sparse(e(:,2),e(:,1),idx1(:)));

%[sg] sometimes these matrices can get so large that matlab refuses
%to linearize them

try
  pnidx = find(abs((s2>0)-(s1>0))>0);
catch
  %fprintf('%s\n',lasterror);
  fprintf('Continuing with ij-form\n');
  [il,jl] = find(abs((s2>0)-(s1>0))>0);
  pnidx = sub2ind(size(s1),il,jl);
end


if ~isempty(pnidx),
    s3 = s2;
    s3(:) = 0;
    try
      s3(pnidx) = s1(pnidx)+s2(pnidx);
      s1(pnidx) = 0;
      s2(pnidx) = 0;
    catch
      %fprintf('%s\n',lasterror);
      fprintf('Continuing with ij-form\n');
      for n0=1:length(il),
        s3(il(n0),jl(n0)) = s1(il(n0),jl(n0)) + s2(il(n0),jl(n0)); 
        s1(il(n0),jl(n0)) = 0;
        s2(il(n0),jl(n0)) = 0;
      end
    end
    [i3,j3,cotidx3] = find(s3);
    ne3 = length(pnidx);
else;
    i3 = [];
    j3 = [];
    cotidx3 = [];
    ne3 = 0;
end;

[i1,j1,cotidx1] = find(s1);
[i2,j2,cotidx2] = find(s2);
ne1 = length(i1);

e = sortrows([i1,j1,cotidx1,cotidx2;[j1,i1,cotidx1,cotidx2];[i3,j3,cotidx3,cotidx3]]);
cotidx = e(:,[3,4]);
e = e(:,[1,2]);
nidx(:,1) = find(e(:,1)-[0;e(1:(end-1),1)]);
nidx(:,2) = find([e(2:end,1);e(end,1)+1]-e(:,1));
nedges = ne1+ne3;

clear val idx1 s1 s2 i1 i2 j1 j2 cotidx1 cotidx2

% s = tril(sparse([e(:,1);e(:,2)],[e(:,2);e(:,1)],ones(2*length(e),1)));
% s3 = tril(sparse([e(:,1);e(:,2)],[e(:,2);e(:,1)],[val;val]));
% clear val;
% if any(s)>2,
%     error('non-manifold surface');
% end;
% [i,j] = find(s); 
% [i3,j3,cotsum] = find(s3);
% if length(cotsum)~=length(i),
%     error('strange angles');
% end
% e = [i,j];
% e = sortrows([[e,cotsum];[e(:,[2,1]),cotsum]]);
% cotsum = e(:,3);
% e = e(:,[1,2]);
% clear s s3 i2 j2 i j e1 e2 sid cs;

% Face vertex correspondence
fid = repmat([1:size(f,1)]',[1,3]);
vid = repmat([1 2 3],size(f,1),1);
%[f,sid] = sort(f(:));
%fvid = [f,fid(sid),vid(sid)];

% After sorting [vertex index , face index, position in face]
fvid = sortrows([f(:) fid(:) vid(:)]);
clear fid vid sid;

% create structure
surf.vertices   = v;        
surf.faces      = f;
surf.areas      = FVA;      % Area based on obtuse/non-obtuse triangle [#f x 3]
surf.edges      = e;        % edge pairs in mesh [2(#e) x 2]
surf.Nidx       = nidx;
surf.cotidx     = cotidx;
surf.faceVertexID = fvid;   % vertex to face correspondence [2(#f) x 3]
surf.angles     = th;       % angles in face [#f x 3]
surf.weights    = sum(cot(th(cotidx)),2);   % sum of cot(angles opposite an edge) [2(#e) x 1]
surf.normals    = normals;
surf.nedges     = nedges;
surf.lonevertidx= lonevertidx;

clear v f A e d VA fvid th cotsum obtuse FVA normals;
