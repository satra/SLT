function [SPM,xSPM] = roi_drawall_setupSPM(SPM,spmParams)

spmMatFile = [pwd filesep 'SPM.mat'];
%-Set the SPM working directory to the path of your SPM.mat file
swd    = spm_str_manip(spmMatFile,'H');

% Put in header comments here!
%-Get volumetric data from SPM structure
%-----------------------------------------------------------------------
try
	xX   = SPM.xX;				    %-Design definition structure
	XYZ  = SPM.xVol.XYZ;	        %-XYZ coordinates
	S    = SPM.xVol.S;			    %-search Volume {voxels}
	R    = SPM.xVol.R;			    %-search Volume {resels}
	M    = SPM.xVol.M(1:3,1:3);	    %-voxels to mm matrix
	VOX  = sqrt(diag(M'*M))';		%-voxel dimensions
catch
    fprintf('Error: The model has not been specified');
    return;
end

%-Contrast definitions
%=======================================================================
%-Load contrast definitions (if available)
%-----------------------------------------------------------------------
try
	xCon = SPM.xCon;
catch
	fprintf('Error: No contrasts are defined');
    return;
end

Im = [];
Ex = [];
pm = [];

Ic = spmParams.Ic;                  % set the index of this contrast

%-Enforce orthogonality of multiple contrasts for conjunction
% (Orthogonality within subspace spanned by contrasts)
%-----------------------------------------------------------------------
if length(Ic) > 1 & ~spm_FcUtil('|_?',xCon(Ic), xX.xKXs)
    
    %-Successively orthogonalise
    %-NB: This loop is peculiarly controlled to account for the
    %     possibility that Ic may shrink if some contrasts diasppear
    %     on orthogonalisation (i.e. if there are colinearities)
    %-------------------------------------------------------------------
    i = 1; 
    while(i < length(Ic)), i = i + 1;        
        %-Orthogonalise (subspace spanned by) contrast i wirit previous
        %---------------------------------------------------------------
        oxCon = spm_FcUtil('|_',xCon(Ic(i)), xX.xKXs, xCon(Ic(1:i-1)));            
        %-See if this orthogonalised contrast has already been entered
        % or is colinear with a previous one. Define a new contrast if
        % neither is the case.
        %---------------------------------------------------------------
        d     = spm_FcUtil('In',oxCon,xX.xKXs,xCon);
        if spm_FcUtil('0|[]',oxCon,xX.xKXs)
            %-Contrast was colinear with a previous one - drop it
            %-----------------------------------------------------------
            Ic(i) = [];
            i     = i - 1;
        elseif any(d)
            %-Contrast unchanged or already defined - note index
            %-----------------------------------------------------------
            Ic(i) = min(d);
        else
            %-Define orthogonalised contrast as new contrast
            %-----------------------------------------------------------
            oxCon.name = [xCon(Ic(i)).name,' (orth. w.r.t {',...
                    sprintf('%d,',Ic(1:i-2)), sprintf('%d})',Ic(i-1))];
            xCon  = [xCon, oxCon];
            Ic(i) = length(xCon); 
        end
    end % while...
end % if length(Ic)...

%-Create the title string from the contrast name
%-----------------------------------------------------------------------
if length(Ic) == 1
	str  = xCon(Ic).name;
else
	str  = [sprintf('contrasts {%d',Ic(1)),sprintf(',%d',Ic(2:end)),'}'];
end
titlestr     = str;

%-Bayesian or classical Inference? Ignore for now
%-----------------------------------------------------------------------
%if isfield(SPM,'PPM') & xCon(Ic(1)).STAT == 'T'
% % Not sure what to do here yet - we don't use Bayesian Inference,
% % but we might in the future, so don't worry about it for now
%     if length(Ic) == 1 & isempty(xCon(Ic).Vcon)
%         if spm_input('Inference',1,'b',{'Bayesian','classical'},[1 0]);
%             % set STAT to 'P'
%             %---------------------------------------------------------------
%             xCon(Ic).STAT = 'P';
%             
%             %-Get Bayesian threshold (Gamma) stored in xCon(Ic).eidf
%             % The default is one conditional s.d. of the contrast
%             %---------------------------------------------------------------
%             str           = 'threshold {default: prior s.d.}';
%             Gamma         = sqrt(xCon(Ic).c'*SPM.PPM.Cb*xCon(Ic).c);
%             xCon(Ic).eidf = spm_input(str,'+1','e',sprintf('%0.2f',Gamma));            
%         end
%     end
% end

%-Compute & store contrast parameters, contrast/ESS images, & SPM images
%=======================================================================
SPM.xCon = xCon;
SPM      = spm_contrasts(SPM,unique([Ic,Im]));
xCon     = SPM.xCon;
VspmSv   = cat(1,xCon(Ic).Vspm);
STAT     = xCon(Ic(1)).STAT;
n        = length(Ic);

%-Check conjunctions - Must be same STAT w/ same df
%-----------------------------------------------------------------------
if (n > 1) & (any(diff(double(cat(1,xCon(Ic).STAT)))) | ...
	      any(abs(diff(cat(1,xCon(Ic).eidf))) > 1))
	error('illegal conjunction: can only conjoin SPMs of same STAT & df')
end

%-Degrees of Freedom and STAT string describing marginal distribution
%-----------------------------------------------------------------------
df          = [xCon(Ic(1)).eidf xX.erdf];
if n > 1
	str = sprintf('^{%d}',n);
else
	str = '';
end

switch STAT
case 'T'
	STATstr = sprintf('%c%s_{%.0f}','T',str,df(2));
case 'F'
	STATstr = sprintf('%c%s_{%.0f,%.0f}','F',str,df(1),df(2));
case 'P'
	STATstr = sprintf('%s^{%0.2f}','PPM',df(1));
end

%-Compute conjunction as minimum of SPMs
%-----------------------------------------------------------------------
Z         = Inf;
for i     = Ic
	Z = min(Z,spm_get_data(xCon(i).Vspm,XYZ));
end

% P values for False Discovery FDR rate computation (all search voxels)
%=======================================================================
switch STAT
case 'T'
	Ps = (1 - spm_Tcdf(Z,df(2))).^n;
case 'P'
	Ps = (1 - Z).^n;
case 'F'
	Ps = (1 - spm_Fcdf(Z,df)).^n;
end

%=======================================================================
% - H E I G H T   &   E X T E N T   T H R E S H O L D S
%=======================================================================

%-Height threshold - classical inference
%-----------------------------------------------------------------------
u      = -Inf;
k      = 0;
if STAT ~= 'P'

    %-Get height threshold
    %-------------------------------------------------------------------
    u = spmParams.pThresh;         % specified above
    switch spmParams.pAdj        
        case 'FWE' % family-wise false positive rate
            u  = spm_uc(u,df,STAT,R,n,S);            
        case 'FDR' % False discovery rate
            u  = spm_uc_FDR(u,df,STAT,n,VspmSv,0);
        otherwise  %-NB: no adjustment
            if u <= 1; u = spm_u(u^(1/n),df,STAT); end;
    end;
end;

%-Height threshold - Bayesian inference
%-----------------------------------------------------------------------
% More Bayesian stuff I'm not going to worry about right now
% elseif STAT == 'P'
% 	u  = spm_input(['p value threshold for PPM'],'+0','r',.95,1);
% end % (if STAT)

%-Calculate height threshold filtering
%-------------------------------------------------------------------
Q      = find(Z > u);

%-Apply height threshold
%-------------------------------------------------------------------
Z      = Z(:,Q);
XYZ    = XYZ(:,Q);
if isempty(Q)
	warning(sprintf('No voxels survive height threshold u=%0.2g',u))
end

%-Extent threshold (disallowed for conjunctions)
%-----------------------------------------------------------------------
if ~isempty(XYZ) & length(Ic) == 1    
    %-Calculate extent threshold filtering
    %-------------------------------------------------------------------
    A     = spm_clusters(XYZ);
    Q     = [];
    for i = 1:max(A)
        j = find(A == i);
        if length(j) >= spmParams.xThresh; Q = [Q j]; end
    end
    
    % ...eliminate voxels
    %-------------------------------------------------------------------
    Z     = Z(:,Q);
    XYZ   = XYZ(:,Q);
    if isempty(Q)
        warning(sprintf('No voxels survive extent threshold k=%0.2g',spmParams.xThresh))
    end    
else
    spmParams.xThresh = 0;
end % (if ~isempty(XYZ))

%-Assemble output structures of unfiltered data
%=======================================================================
xSPM   = struct('swd',		swd,...
		'title',	titlestr,...
		'Z',		Z,...
		'n',		n,...
		'STAT',		STAT,...
		'df',		df,...
		'STATstr',	STATstr,...
		'Ic',		Ic,...
		'Im',		Im,...
		'pm',		pm,...
		'Ex',		Ex,...
		'u',		u,...
		'k',		spmParams.xThresh,...
		'XYZ',		XYZ,...
		'XYZmm',	SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))],...
		'S',		SPM.xVol.S,...
		'R',		SPM.xVol.R,...
		'FWHM',		SPM.xVol.FWHM,...
		'M',		SPM.xVol.M,...
		'iM',		SPM.xVol.iM,...
		'DIM',		SPM.xVol.DIM,...
		'VOX',		VOX,...
		'Vspm',		VspmSv,...
		'Ps',		Ps);

% RESELS per voxel (density) if it exists
%-----------------------------------------------------------------------
if isfield(SPM,'VRpv'), xSPM.VRpv = SPM.VRpv; end
