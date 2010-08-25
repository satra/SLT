/*
Inputs from matlab: 

Outputs:
*/

#include "mex.h"
#include <stdlib.h>
#include <math.h>

int compare(const void *a, const void *b)
{
	return ((*(double*)a) < (*(double*)b));
}
void mexFunction(int nlhs,       mxArray *plhs[],
				 int nrhs, const mxArray *prhs[])
{
	/* ************** Inputs *******************/

	double *IV;
	unsigned int *e, Niter;

	/* ************** Outputs *******************/
	double *VV;

	/* ************** Others ******************* */
	unsigned int nV, nE, n0, n1, niter, ne, nv;
	double vertvals[100], dotval;
	double *x, *y, *z;

	/* Inputs */
	e = (unsigned int*)mxGetPr(prhs[0]);
	IV = mxGetPr(prhs[1]);
	Niter = *mxGetPr(prhs[2]);
	
	//mexPrintf("I[%d]\n",Niter);
	
	nV = mxGetM(prhs[1]);
	nE = mxGetM(prhs[0]);

	/* Outputs */
	plhs[0] = mxCreateDoubleMatrix(nV,1,mxREAL);
	VV = mxGetPr(plhs[0]);

	/*temp */
	x = (double *)mxCalloc(nV,sizeof(double));

	for(n0=0;n0<nV;n0++)
	{
		VV[n0] = IV[n0];
		x[n0] = VV[n0];
	}

	for(niter=0;niter<Niter;niter++)
	{
	    ne = 0;
		for(n0=0;n0<nV;n0++)
		{
			nv = 0;
			if (!mxIsNaN(VV[n0]))
			{
				vertvals[nv++] = VV[n0];
			}
			for(;ne<nE & e[ne]==n0;ne++)
			{
				if (!mxIsNaN(VV[e[nE+ne]]))
				{
					vertvals[nv++] = VV[e[nE+ne]];
				}
			}
			if (nv>0) 
			{
				qsort(vertvals,nv,sizeof(double),compare);
				//for (n1=0;n1<nv;n1++)
				    //mexPrintf("%f ",vertvals[n1]);
				if (nv%2 == 0)
					x[n0] = (vertvals[nv/2]+vertvals[nv/2-1])/2.0;
				else
					x[n0] = vertvals[(int)floor((double)nv/2.0)];
				//mexPrintf(":Med[%f]\n",x[n0]);
				/*    
				for(n1=0;n1<nv;n1++)
				VV[n0] += vertvals[n1];
				VV[n0] /= nv;
				*/
			}
		}
		
		dotval = 0.0;
		for(n0=0;n0<nV;n0++)
		{
		    //dotval += (VV[n0]-x[n0])*(VV[n0]-x[n0]);
			VV[n0] = x[n0];
		}
		//mexPrintf("dotval[%f]\n",dotval);
	}
}
