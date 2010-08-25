function [MC,GC,K1,K2,MN,VN] = st_curvature( surf )
% ST_CURVATURE Calculates various different types of curvatures and
% normals for a surface. Given a preprocessed surface, this function
% computes the following quantities: 
%       MC: Mean curvature
%       GC: Gaussian curvature
%       K1,K2: Principal curvatures
%       MN: Mean Curvature normal operator
%       VN: Vertex normals
%   The requirement from a preprocessed surface are the following:
%       faces,vertices, edges, angles at each vertex of each face,
%       areas for each vertex of each face, cotangent weights, face
%       vertex correspondence and face normals
%       The preprocess function computes all of these quantities.
%   The iterative part of the routine is implemented as a mex function.
%
%   For further detail refer to Meyer et al. (multires lab at Caltech)
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

[MN,GC,VN] = curvatureMEX(surf.vertices,uint32(surf.faces-1),uint32(surf.edges-1),...
    surf.angles,surf.areas,surf.weights,uint32(surf.faceVertexID-1),...
    surf.normals);

msc = sign(sum(MN.*VN,2));
KH = (0.5*sqrt(sum(MN.*MN,2)));
MC = msc.*KH;

if nargout>2,
    DX = max(MC.^2-GC,0);
    
    % Calculate principal curvatures
    K1 = KH+sqrt(DX);
    K2 = KH-sqrt(DX);
end;
