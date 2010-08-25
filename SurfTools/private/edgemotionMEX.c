/*
Inputs from matlab: 

Outputs:
*/

#include "mex.h"

void mexFunction(int nlhs,       mxArray *plhs[],
				 int nrhs, const mxArray *prhs[])
{
	/* ************** Inputs *******************/

	double *v, alpha;
	unsigned int *e, niters;

	/* ************** Outputs *******************/
	double *V;

	/* ************** Others ******************* */
	unsigned int nV, nE, n0, n1, ne, nv;
	double *x, *y, *z;

	/* Inputs */
	v = mxGetPr(prhs[0]);
	e = (unsigned int*)mxGetPr(prhs[1]);
	niters = *mxGetPr(prhs[2]);
	alpha = *mxGetPr(prhs[3]);

	//mexPrintf("I[%d],a[%f]\n",niters,alpha);

	nV = mxGetM(prhs[0]);
	nE = mxGetM(prhs[1]);

	/* Outputs */
	plhs[0] = mxCreateDoubleMatrix(nV,3,mxREAL);
	V = mxGetPr(plhs[0]);

	/*temp */
	x = (double*)mxCalloc(nV,sizeof(double));
	y = (double*)mxCalloc(nV,sizeof(double));
	z = (double*)mxCalloc(nV,sizeof(double));

	for(n0=0;n0<nV;n0++)
	{
		V[n0] = v[n0];
		V[nV+n0] = v[nV+n0];
		V[2*nV+n0] = v[2*nV+n0];
	}

	/* Compute motion */
	for(n1=0;n1<niters;n1++)
	{
		ne = 0;
		for(n0=0;n0<nV;n0++)
		{
			x[n0] = 0;
			y[n0] = 0;
			z[n0] = 0;

			nv = 0;
			for(;ne<nE & e[ne]==n0;ne++)
			{
				x[n0] += V[e[nE+ne]]-V[n0];
				y[n0] += V[nV+e[nE+ne]]-V[nV+n0];
				z[n0] += V[2*nV+e[nE+ne]]-V[2*nV+n0];
				nv++;
			}
			if (nv>0) 
			{
				x[n0] /=nv;
				y[n0] /=nv;
				z[n0] /=nv;
			}
		}
		for(n0=0;n0<nV;n0++)
		{
			V[n0] += alpha*x[n0];
			V[nV+n0] += alpha*y[n0];
			V[2*nV+n0] += alpha*z[n0];
		}
	}
	mxFree(x);
	mxFree(y);
	mxFree(z);

}
