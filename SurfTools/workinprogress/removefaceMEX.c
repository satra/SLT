/*
  Inputs from matlab: 
  surf.vertices   = v;        
  surf.faces      = f;
  surf.normals    = normals;
    
  Outputs:
  [faces,vertices] % faces and vertices after reduction
*/

#include "mex.h"
#include <math.h>

#ifndef M_PI
#define M_PI 3.1415
#endif

void mexFunction(int nlhs,       mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  /* ************** Inputs *******************/
  
  double *v, *fn, tol;
  unsigned int *f, *e, *fvid;

  /* ************** Outputs *******************/
  double *vnew;
  unsigned int *fnew;
  
  /* ************** Others ******************* */
  double *flag;
  unsigned int nV, nF, nE, nFV, n0, ne, nf;
  double Amixed, mag;
  
  /* Inputs */
  v = mxGetPr(prhs[0]);
  f = mxGetPr(prhs[1]);
  fn= mxGetPr(prhs[2]);
  tol= *mxGetPr(prhs[3]);

  nV = mxGetM(prhs[0]);
  nF = mxGetM(prhs[1]);
  mexPrintf("Total V[%d],F[%d],E[%d],FV[%d]\n",nV,nF,nE,nFV);
  
  /* Outputs */
  plhs[0] = mxCreateDoubleMatrix(nV,3,mxREAL);
  plhs[1] = mxCreateDoubleMatrix(nF,3,mxREAL);
  plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);
  plhs[3] = mxCreateDoubleMatrix(1,1,mxREAL);

  MN = mxGetPr(plhs[0]);
  GC = mxGetPr(plhs[1]);
  VN = mxGetPr(plhs[2]);
  
  flag = mxCalloc(nF,sizeof(double));
  for(n0=0;n0<nF;n0++)
	  flag[n0] = 1;

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

  /* Compute curvature */
  ne = 0;
  nf = 0;
  
  for(n0=0;n0<nV;n0++)
  {
    Amixed = 0.0f;
    // find the edges
    MN[n0] = 0;
    MN[nV+n0] = 0;
    MN[2*nV+n0] = 0;
    VN[n0] = 0;
    VN[nV+n0] = 0;
    VN[2*nV+n0] = 0;
    
    //mexPrintf("Starting edge calculation\n");
    
    for(;ne<nE && e[ne]==n0;ne++)
    {
        //mexPrintf("E[%d]:Vj[%d]-->Vi[%d]\n",ne,e[nE+ne]+1,e[ne]+1);
        MN[n0] += w[ne]*(v[e[nE+ne]]-v[n0]);
        MN[nV+n0] += w[ne]*(v[nV+e[nE+ne]]-v[nV+n0]);
        MN[2*nV+n0] += w[ne]*(v[2*nV+e[nE+ne]]-v[2*nV+n0]);
    }
    
//    mexPrintf("Starting face calculation\n");
//    mexPrintf("%d:%d\n",nf+1,fvid[nf]+1);
    for(;nf<nFV && fvid[nf]==n0;nf++)
    {
        //mexPrintf("V[%d]:F[%d]-->Vi[%d]\n",n0+1,fvid[nFV+nf]+1,fvid[2*nFV+nf]+1);
        Amixed += A[(fvid[2*nFV+nf])*nF+fvid[nFV+nf]];
        GC[n0] += th[(fvid[2*nFV+nf])*nF+fvid[nFV+nf]];
        
        VN[n0] += fn[fvid[nFV+nf]];
        VN[nV+n0] += fn[nF+fvid[nFV+nf]];
        VN[2*nV+n0] += fn[2*nF+fvid[nFV+nf]];
    }
    
    mag = sqrt( (VN[n0]*VN[n0]) + (VN[nV+n0]*VN[nV+n0]) + (VN[2*nV+n0]*VN[2*nV+n0]));

    VN[n0] /= mag;
    VN[nV+n0] /= mag;
    VN[2*nV+n0] /= mag;
    
    //mexPrintf("%f\n",Amixed);
    MN[n0] /= 2*Amixed;
    MN[nV+n0] /= 2*Amixed;
    MN[2*nV+n0] /= 2*Amixed;
    GC[n0] = (2*M_PI-GC[n0])/Amixed;
  }
}

// Compute face normals
v31 = v(f(:,3),:)-v(f(:,1),:);v31n = sqrt(sum(v31.*v31,2));
v21 = v(f(:,2),:)-v(f(:,1),:);v21n = sqrt(sum(v21.*v21,2));

% computer normals
normals = cross(v21,v31,2);
FN = normals./repmat((sqrt(sum(normals.*normals,2))),1,3);
