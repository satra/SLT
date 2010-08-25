/*
  Inputs from matlab: 
  surf.vertices   = v;        
  surf.faces      = f;
  surf.edges      = e;        % edge pairs in mesh [#e x 2]
  surf.angles   
  surf.areas      = FVA;      % Area based on obtuse/non-obtuse triangle [#f x 3]
  surf.weights    = cotsum;   % sum of cot(angles opposite an edge) [#e x 1]
  surf.faceVertexID = fvid;   % vertex to face correspondence [2(#f) x 3]
  surf.normals    = normals;
    
  Outputs:
  MN[V] Mean Normal
  GC[V] Gaussian Curvature
  VN[V] Vertex Normal
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
  
  double *v, *th, *A, *w, *fn;
  unsigned int *f, *e, *fvid;

  /* ************** Outputs *******************/
  double *MN, *GC, *VN;
  
  /* ************** Others ******************* */
  unsigned int nV, nF, nE, nFV, n0, ne, nf;
  double Amixed, mag;
  
  /* Inputs */
  v = mxGetPr(prhs[0]);
  f = (unsigned int*)mxGetPr(prhs[1]);
  e = (unsigned int*)mxGetPr(prhs[2]);
  th= mxGetPr(prhs[3]);
  A = mxGetPr(prhs[4]);
  w = mxGetPr(prhs[5]);
  fvid = (unsigned int*)mxGetPr(prhs[6]);
  fn= mxGetPr(prhs[7]);

  nV = mxGetM(prhs[0]);
  nF = mxGetM(prhs[1]);
  nE = mxGetM(prhs[2]);
  nFV= mxGetM(prhs[6]);
  mexPrintf("Total V[%d],F[%d],E[%d],FV[%d]\n",nV,nF,nE,nFV);
  
  /* Outputs */
  plhs[0] = mxCreateDoubleMatrix(nV,3,mxREAL);
  plhs[1] = mxCreateDoubleMatrix(nV,1,mxREAL);
  plhs[2] = mxCreateDoubleMatrix(nV,3,mxREAL);
  MN = mxGetPr(plhs[0]);
  GC = mxGetPr(plhs[1]);
  VN = mxGetPr(plhs[2]);
  
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
