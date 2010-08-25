/*
  Inputs from matlab: 
    
  Outputs:
*/

#include "mex.h"

void mexFunction(int nlhs,       mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  /* ************** Inputs *******************/
  
  double *IV;
  unsigned int *e;

  /* ************** Outputs *******************/
  double *VV;
  
  /* ************** Others ******************* */
  unsigned int nV, nE, n0, ne, nv;
  double Amixed, mag;
  
  /* Inputs */
  e = (unsigned int*)mxGetPr(prhs[0]);
  IV = mxGetPr(prhs[1]);

  nV = mxGetM(prhs[1]);
  nE = mxGetM(prhs[0]);
  
  /* Outputs */
  plhs[0] = mxCreateDoubleMatrix(nV,1,mxREAL);
  VV = mxGetPr(plhs[0]);
  
  /* Compute curvature */
  ne = 0;
  
  for(n0=0;n0<nV;n0++)
  {
    VV[n0] = 0;
    
    nv = 0;
    if (!mxIsNaN(IV[n0]))
    {
        VV[n0] += IV[n0];
        nv++;
    }
    for(;ne<nE & e[ne]==n0;ne++)
    {
        if (!mxIsNaN(IV[e[nE+ne]]))
        {
            VV[n0] += IV[e[nE+ne]];
            nv++;
        }
    }
    if (nv>0) VV[n0] /= nv;
  }
}
