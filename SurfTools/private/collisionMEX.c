/*
Inputs from matlab: 

Outputs:
*/

#include "mex.h"
#include <math.h>
#include <stdio.h>
#define EPS 1E-6

int tri_tri_intersect(float V0[3],float V1[3],float V2[3],float U0[3],float U1[3],float U2[3]);
int NoDivTriTriIsect(float V0[3],float V1[3],float V2[3],float U0[3],float U1[3],float U2[3]);

#define dist(v0,v1) (sqrt((v0[0]-v1[0])*(v0[0]-v1[0])+(v0[1]-v1[1])*(v0[1]-v1[1])+(v0[2]-v1[2])*(v0[2]-v1[2])))

float centroiddist(float V0[3],float V1[3],float V2[3],float U0[3],float U1[3],float U2[3])
{
	float C1[3],C2[3];
	C1[0] = (V0[0]+V1[0]+V2[0])/3;
	C1[1] = (V0[1]+V1[1]+V2[1])/3;
	C1[2] = (V0[2]+V1[2]+V2[2])/3;
	C2[0] = (U0[0]+U1[0]+U2[0])/3;
	C2[1] = (U0[1]+U1[1]+U2[1])/3;
	C2[2] = (U0[2]+U1[2]+U2[2])/3;

	return dist(C1,C2);
}

int commonpoint(float V0[3],float V1[3],float V2[3],float U0[3],float U1[3],float U2[3])
{
	if (dist(V0,U0)<EPS || dist(V0,U1)<EPS || dist(V0,U2)<EPS ||
		dist(V1,U0)<EPS || dist(V1,U1)<EPS || dist(V1,U2)<EPS ||
		dist(V2,U0)<EPS || dist(V2,U1)<EPS || dist(V2,U2)<EPS)
		return 1;
	else
		return 0;
}
void mexFunction(int nlhs,       mxArray *plhs[],
				 int nrhs, const mxArray *prhs[])
{
	/* ************** Inputs *******************/

	double *v;
	unsigned int *f;

	/* ************** Outputs *******************/
	double *Vint;

	/* ************** Others ******************* */
	unsigned int nV, nF, n0, n1;
	float v0[3], v1[3], v2[3],y0[3],y1[3],y2[3];

	/* Inputs */
	v = mxGetPr(prhs[0]);
	f = (unsigned int*)mxGetPr(prhs[1]);

	//mexPrintf("I[%d],a[%f]\n",niters,alpha);

	nV = mxGetM(prhs[0]);
	nF = mxGetM(prhs[1]);

	/* Outputs */
	plhs[0] = mxCreateDoubleMatrix(nV,1,mxREAL);
	Vint = mxGetPr(plhs[0]);

	/*temp */

	for(n0=0;n0<nV;n0++)
		Vint[n0] = 0;

	for(n0=0;n0<(nF-1);n0++)
	{
		v0[0] = v[f[n0]];
		v0[1] = v[nV+f[n0]];
		v0[2] = v[2*nV+f[n0]];
		v1[0] = v[f[nF+n0]];
		v1[1] = v[nV+f[nF+n0]];
		v1[2] = v[2*nV+f[nF+n0]];
		v2[0] = v[f[2*nF+n0]];
		v2[1] = v[nV+f[2*nF+n0]];
		v2[2] = v[2*nV+f[2*nF+n0]];

		for(n1=(n0+1);n1<nF;n1++)
		{
			y0[0] = v[f[n1]];
			y0[1] = v[nV+f[n1]];
			y0[2] = v[2*nV+f[n1]];
			y1[0] = v[f[nF+n1]];
			y1[1] = v[nV+f[nF+n1]];
			y1[2] = v[2*nV+f[nF+n1]];
			y2[0] = v[f[2*nF+n1]];
			y2[1] = v[nV+f[2*nF+n1]];
			y2[2] = v[2*nV+f[2*nF+n1]];

/*			if (centroiddist(v0,v1,v2,y0,y1,y2)<2)
				if (!commonpoint(v0,v1,v2,y0,y1,y2))
					if (NoDivTriTriIsect(v0,v1,v2,y0,y1,y2))
					{
						Vint[f[n0]] = 1;
						Vint[f[nF+n0]] = 1;
						Vint[f[2*nF+n0]] = 1;
						Vint[f[n1]] = 1;
						Vint[f[nF+n1]] = 1;
						Vint[f[2*nF+n1]] = 1;
					}
					*/
		}
		
	}
}
