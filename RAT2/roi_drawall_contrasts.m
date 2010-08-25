function varargout = roi_drawall_contrasts(varargin)

SCCSid = '2.42';
spm_defaults;           % setup some defaults we'll need for gui stuff

% Here defined inline, allow user specification of everything eventually
spmMatFile = [pwd filesep 'SPM.mat'];

%-Set the SPM working directory to the path of your SPM.mat file
swd    = spm_str_manip(spmMatFile,'H');

%-Load SPM.mat --- SHOULD ONLY NEED TO DO THIS ONCE for all contrasts!
load(fullfile(swd,'SPM.mat'));
SPM.swd = swd;

%-Condition arguments
%-----------------------------------------------------------------------
if nargin == 0, Action='setup'; else, Action=varargin{1}; end

%=======================================================================
switch lower(Action), 
 case 'setup'                      
  %-Set up results
  %=======================================================================
  
  spmParams = varargin(2);
  spmParams = [spmParams{1}];
  
  %-Initialise 
  %-----------------------------------------------------------------------
  SPMid      = spm('FnBanner',mfilename,SCCSid);
  [Finter,Fgraph,CmdLine] = spm('FnUIsetup','Stats: Results');
  FS         = spm('FontSizes');
  
  % clear satfig if it exists
  %-----------------------------------------------------------------------
  hSat       = findobj('tag','Satellite');
  spm_figure('clear',hSat);
  
  for cIndex=1:length(spmParams),
      
      %-Get thresholded xSPM data and parameters of design
      %=======================================================================
      [SPM,xSPM] = roi_drawall_setupSPM(SPM,spmParams(cIndex));
      M          = SPM.xVol.M;
      DIM        = SPM.xVol.DIM;
      
      % ensure pwd = swd so that relative filenames are valid
      %-----------------------------------------------------------------------
      cd(SPM.swd)
      
      %-Setup Results User Interface; Display MIP, design matrix & parameters
      %=======================================================================
      spm('FigName',['SPM{',xSPM.STAT,'}: Results'],Finter,CmdLine);
      
      
      %-Setup results GUI
      %-----------------------------------------------------------------------
      spm_figure('Clear',Finter)
      hReg      = spm_results_ui('SetupGUI',M,DIM,xSPM,Finter);
      
      %-Setup design interrogation menu
      %-----------------------------------------------------------------------
      %hDesRepUI = spm_DesRep('DesRepUI',SPM);
      %figure(Finter)
      
    
      %-Setup Maximium intensity projection (MIP) & register
      %-----------------------------------------------------------------------
      hMIPax = axes('Parent',Fgraph,'Position',[0.05 0.60 0.55 0.36],'Visible','off');
      hMIPax = spm_mip_ui(xSPM.Z,xSPM.XYZmm,M,DIM,hMIPax);
      spm_XYZreg('XReg',hReg,hMIPax,'spm_mip_ui');
      if xSPM.STAT == 'P'
	  str = xSPM.STATstr;
      else
        str = ['SPM\{',xSPM.STATstr,'\}'];
      end
      text(240,260,str,...
	   'Interpreter','TeX',...
	   'FontSize',FS(14),'Fontweight','Bold',...
	   'Parent',hMIPax)
      
      
      %-Print comparison title
      %-----------------------------------------------------------------------
      hTitAx = axes('Parent',Fgraph,...
		    'Position',[0.02 0.95 0.96 0.02],...
		    'Visible','off');
    
      text(0.5,0,xSPM.title,'Parent',hTitAx,...
	   'HorizontalAlignment','center',...
	   'VerticalAlignment','baseline',...
	   'FontWeight','Bold','FontSize',FS(14))
      
    
      %-Print SPMresults: Results directory & thresholding info
      %-----------------------------------------------------------------------
      hResAx = axes('Parent',Fgraph,...
		    'Position',[0.05 0.55 0.45 0.05],...
		    'DefaultTextVerticalAlignment','baseline',...
		    'DefaultTextFontSize',FS(9),...
		    'DefaultTextColor',[1,1,1]*.7,...
		    'Units','points',...
		    'Visible','off');
      AxPos = get(hResAx,'Position'); set(hResAx,'YLim',[0,AxPos(4)])
      h     = text(0,24,'SPMresults:','Parent',hResAx,...
        'FontWeight','Bold','FontSize',FS(14));
      text(get(h,'Extent')*[0;0;1;0],24,spm_str_manip(SPM.swd,'a30'),'Parent',hResAx)
      text(0,12,sprintf('Height threshold %c = %0.2f',xSPM.STAT,xSPM.u),'Parent',hResAx)
      text(0,00,sprintf('Extent threshold k = %0.0f voxels',xSPM.k), 'Parent',hResAx)
      
    
      %-Plot design matrix
      %-----------------------------------------------------------------------
      hDesMtx   = axes('Parent',Fgraph,'Position',[0.65 0.55 0.25 ...
		    0.25]);
      try
	  hDesMtxIm = image((SPM.xX.nKX + 1)*32);
	  xlabel('Design matrix')
	  set(hDesMtxIm,'ButtonDownFcn','spm_DesRep(''SurfDesMtx_CB'')',...
			'UserData',struct(...
			    'X',		SPM.xX.xKXs.X,...
			    'fnames',	{reshape({SPM.xY.VY.fname},size(SPM.xY.VY))},...
			    'Xnames',	{SPM.xX.name}))
      catch
	  disp('unable to draw design matrix');
      end
      
      %-Plot contrasts
      %-----------------------------------------------------------------------
      nPar   = size(SPM.xX.X,2);
      xx     = [repmat([0:nPar-1],2,1);repmat([1:nPar],2,1)];
      nCon   = length(xSPM.Ic);
      xCon   = SPM.xCon;
      if nCon
	  dy     = 0.15/max(nCon,2);
	  hConAx = axes('Position',[0.65 (0.80 + dy*.1) 0.25 dy*(nCon-.1)],...
			'Tag','ConGrphAx','Visible','off');
	  title('contrast(s)')
	  htxt   = get(hConAx,'title'); 
	  set(htxt,'Visible','on','HandleVisibility','on')
      end
      
      for ii = nCon:-1:1
	  axes('Position',[0.65 (0.80 + dy*(nCon - ii +.1)) 0.25 dy*.9])
	  if xCon(xSPM.Ic(ii)).STAT == 'T' & size(xCon(xSPM.Ic(ii)).c,2) == 1
	      
	      %-Single vector contrast for SPM{t} - bar
	      %---------------------------------------------------------------
	      yy = [zeros(1,nPar);repmat(xCon(xSPM.Ic(ii)).c',2,1);zeros(1,nPar)];
	      h  = patch(xx,yy,[1,1,1]*.5);
	      set(gca,'Tag','ConGrphAx',...
		      'Box','off','TickDir','out',...
		      'XTick',spm_DesRep('ScanTick',nPar,10) - 0.5,'XTickLabel','',...
		      'XLim',	[0,nPar],...
		      'YTick',[-1,0,+1],'YTickLabel','',...
		      'YLim',[min(xCon(xSPM.Ic(ii)).c),max(xCon(xSPM.Ic(ii)).c)] +...
		      [-1 +1] * max(abs(xCon(xSPM.Ic(ii)).c))/10	)
            
	  else
	      
	      %-F-contrast - image
	      %---------------------------------------------------------------
	      h = image((xCon(xSPM.Ic(ii)).c'/max(abs(xCon(xSPM.Ic(ii)).c(:)))+1)*32);
	      set(gca,'Tag','ConGrphAx',...
		      'Box','on','TickDir','out',...
		      'XTick',spm_DesRep('ScanTick',nPar,10),'XTickLabel','',...
		      'XLim',	[0,nPar]+0.5,...
		      'YTick',[0:size(SPM.xCon(xSPM.Ic(ii)).c,2)]+0.5,....
		      'YTickLabel','',...
		      'YLim',	[0,size(xCon(xSPM.Ic(ii)).c,2)]+0.5	)
	      
	  end
	  ylabel(num2str(xSPM.Ic(ii)))
	  set(h,'ButtonDownFcn','spm_DesRep(''SurfCon_CB'')',...
		'UserData',	struct(	'i',		xSPM.Ic(ii),...
					'h',		htxt,...
					'xCon',		xCon(xSPM.Ic(ii))))
      end
      
      
      %-Store handles of results section Graphics window objects
      %-----------------------------------------------------------------------
      H  = get(Fgraph,'Children');
      H  = findobj(H,'flat','HandleVisibility','on');
      H  = findobj(H);
      Hv = get(H,'Visible');
      set(hResAx,'Tag','PermRes','UserData',struct('H',H,'Hv',{Hv}))
      
      % Now render to the standard brain
      rendPath = fullfile(fileparts(which('spm')),'rend');
      
      switch spmParams(cIndex).template,
       case 'single'
	templateFile = fullfile(rendPath,filesep,'render_single_subj.mat');
       case 'smooth'
	templateFile = fullfile(rendPath,filesep,'render_smooth_average.mat');
       case 'spm96'
	templateFile = fullfile(rendPath,filesep,'render_spm96.mat');
       otherwise,
	templateFile = spmParams(cIndex).template;
      end;
      disp(templateFile);
     
      try
	  spm_render(struct('XYZ',xSPM.XYZ,'t',transpose(xSPM.Z),'mat',xSPM.M,'dim',xSPM.DIM),...
		     spmParams(cIndex).brighten, templateFile);
      catch
	  disp('Could not render');
      end
      
      % Now save the results window to a file
      spm_print;
      print(gcf,'-djpeg75',[spmParams(cIndex).filename '.jpg']);
      %print(gcf,'-depsc',[spmParams(cIndex).filename '.eps']); 
      if (spmParams(cIndex).tabulate),
	  spm_list('List',xSPM,hReg);
	  spm_print;
	  %print(gcf,'-djpeg75',[spmParams(cIndex).filename '-table.jpg']);
      end;

      try
	  gin_clusters_plabels('List',xSPM);
	  spm_print;
      catch
	  warning('Could not create/print cluster table');
      end

      %print unique table
      roi_contrast2table(xSPM,'Atlas_table.txt');

  end; %for each contrast
  

  %-Finished results setup
  %-----------------------------------------------------------------------
  varargout = {hReg,xSPM,SPM};
  spm('Pointer','Arrow')
      


  %=======================================================================
 case 'setupgui'                             
  %-Set up results section GUI
  %=======================================================================
  % hReg = roi_drawall_contrasts('SetupGUI',M,DIM,xSPM,Finter)
  if nargin < 5, Finter='Interactive'; else, Finter = varargin{5}; end
  if nargin < 4, error('Insufficient arguments'), end
  M      = varargin{2};
  DIM    = varargin{3};
  Finter = spm_figure('GetWin',Finter);
  WS     = spm('WinScale');
  FS     = spm('FontSizes');
  
  %-Create frame for Results GUI objects
  %-----------------------------------------------------------------------
  hReg    = uicontrol(Finter,'Style','Frame','Position',[001 001 400 190].*WS,...
		      'BackgroundColor',spm('Colour'));
  hFResUi = uicontrol(Finter,'Style','Frame','Position',[008 007 387 178].*WS);
  
  %-Initialise registry in hReg frame object
  %-----------------------------------------------------------------------
  [hReg,xyz] = spm_XYZreg('InitReg',hReg,M,DIM,[0;0;0]);
  
  %-Setup editable XYZ widgets & cross register with registry
  %-----------------------------------------------------------------------
  hFxyz      = roi_drawall_contrasts('DrawXYZgui',M,DIM,varargin{4},xyz,Finter);
  spm_XYZreg('XReg',hReg,hFxyz,'roi_drawall_contrasts');
  
  %-Set up buttons for results functions
  %-----------------------------------------------------------------------
  roi_drawall_contrasts('DrawButts',hReg,DIM,Finter,WS,FS);
  
  varargout  = {hReg};
  
  
  
%=======================================================================
 case 'drawbutts'    
  %-Draw results section buttons in Interactive window
  %=======================================================================
  % roi_drawall_contrasts('DrawButts',hReg,DIM,Finter,WS,FS)
  %                      
  if nargin<3, error('Insufficient arguments'), end
  hReg = varargin{2};
  DIM  = varargin{3};
  if nargin<4,  Finter = spm_figure('FindWin','Interactive');
  else, Finter = varargin{4}; end
  if nargin < 5, WS = spm('WinScale');	else,	WS = varargin{5}; end
  if nargin < 6, FS = spm('FontSizes');	else,	FS = varargin{6}; end
  PF   = spm_platform('fonts');
  
  %-p-values
  %-----------------------------------------------------------------------
  uicontrol(Finter,'Style','Frame','Position',[010 090 110 085].*WS)
  uicontrol(Finter,'Style','Text','String','p-values',...
	    'Position',[020 168 050 015].*WS,...
	    'FontName',PF.times,'FontWeight','Normal','FontAngle','Italic',...
	    'FontSize',FS(10),...
	    'HorizontalAlignment','Left',...
	    'ForegroundColor','w')
  uicontrol(Finter,'Style','PushButton','String','volume','FontSize',FS(10),...
	    'ToolTipString',...
	    'tabulate summary of local maxima, p-values & statistics',...
	    'Callback','spm_list(''List'',xSPM,hReg);',...
	    'Interruptible','on','Enable','on',...
	    'Position',[015 145 100 020].*WS)
  uicontrol(Finter,'Style','PushButton','String','cluster','FontSize',FS(10),...
	    'ToolTipString',...
	    'tabulate p-values & statistics for local maxima of nearest cluster',...
	    'Callback','spm_list(''ListCluster'',xSPM,hReg);',...
	    'Interruptible','on','Enable','on',...
	    'Position',[015 120 100 020].*WS)
  uicontrol(Finter,'Style','PushButton','String','S.V.C.','FontSize',FS(10),...
	    'ToolTipString',['Small Volume Correction - corrected p-values ',...
		    'for a small search region'],...
	    'Callback','spm_VOI(SPM,xSPM,hReg);',...
	    'Interruptible','on','Enable','on',...
	    'Position',[015 095 100 020].*WS)
  

  %-SPM area - used for Volume of Interest
  %-----------------------------------------------------------------------
  uicontrol(Finter,'Style','Frame','Position',[125 090 150 085].*WS)
  uicontrol(Finter,'Style','Text','String','Regional responses',...
	    'Position',[135 168 94 015].*WS,...
	    'FontName',PF.times,'FontWeight','Normal','FontAngle','Italic',...
	    'FontSize',FS(10),...
	    'HorizontalAlignment','Left',...
	    'ForegroundColor','w')
  uicontrol(Finter,'Style','PushButton','String','VOI',...
	    'Position',[130 100 140 060].*WS,...
	    'ToolTipString',...
	    'Responses in volume of interest',...
	    'Callback','[Y,xY] = spm_regions(xSPM,SPM,hReg)',...
	    'Interruptible','on','Enable','on',...
	    'FontName',PF.times,'FontWeight','Bold','FontAngle','Italic',...
	    'FontSize',FS(32),...
	    'HorizontalAlignment','Center',...
	    'ForegroundColor',[1,1,1]*.5)

  %-Hemodynamic modeling
  %-----------------------------------------------------------------------
  uicontrol(Finter,'Style','Frame','Position',[125 050 150 030].*WS)
  global defaults
  if strcmp(defaults.modality,'FMRI')
      uicontrol(Finter,'Style','PushButton','String','Hemodynamics',...
		'FontSize',FS(10),...
		'ToolTipString','Hemodynamic modeling of regional response',...
		'Callback','[Ep,Cp,K1,K2] = spm_hdm_ui(xSPM,SPM,hReg);',...
		'Interruptible','on','Enable','on',...
		'Position',[130 055 140 020].*WS,...
		'ForegroundColor','r');
  end

  %-Not currently used
  %-----------------------------------------------------------------------
  uicontrol(Finter,'Style','Frame','Position',[010 050 110 030].*WS)
  if strcmp(defaults.modality,'FMRI')
      uicontrol(Finter,'Style','PushButton','String',' ','FontSize',FS(10),...
		'ToolTipString',' ',...
		'Callback',' ',...
		'Interruptible','on','Enable','on',...
		'Position',[015 055 100 020].*WS)
  end

  %-Visualisation
  %-----------------------------------------------------------------------
  uicontrol(Finter,'Style','Frame','Position',[280 090 110 085].*WS)
  uicontrol(Finter,'Style','Text','String','visualisation',...
	    'Position',[290 168 065 015].*WS,...
	    'FontName',PF.times,'FontWeight','Normal','FontAngle','Italic',...
	    'FontSize',FS(10),...
	    'HorizontalAlignment','Left',...
	    'ForegroundColor','w')
  uicontrol(Finter,'Style','PushButton','String','plot','FontSize',FS(10),...
	    'ToolTipString','plot data & contrasts at current voxel',...
	    'Callback','[Y,y,beta,Bcov] = spm_graph(xSPM,SPM,hReg);',...
	    'Interruptible','on','Enable','on',...
	    'Position',[285 145 100 020].*WS)

  str  = { 'overlays...','slices','sections','render'};
  tstr = { 'overlay filtered SPM on another image: ',...
	   '3 slices / ','ortho sections / ','render'};
  tmp  = { 'spm_transverse(''set'',xSPM,hReg)',...
	   'spm_sections(xSPM,hReg)',...
	   ['spm_render(	struct(	''XYZ'',	xSPM.XYZ,',...
	    '''t'',		xSPM.Z'',',...
	    '''mat'',	xSPM.M,',...
	    '''dim'',	xSPM.DIM))']};
  if DIM(3) == 1, str(2 + 1) = []; tstr(2 + 1) = []; tmp(2) = []; end
  uicontrol(Finter,'Style','PopUp','String',str,'FontSize',FS(10),...
	    'ToolTipString',cat(2,tstr{:}),...
	    'Callback','spm(''PopUpCB'',gcbo)',...
	    'UserData',tmp,...
	    'Interruptible','on','Enable','on',...
	    'Position',[285 120 100 020].*WS)
  uicontrol(Finter,'Style','PushButton','String','save','FontSize',FS(10),...
	    'ToolTipString','save thresholded SPM as image',...
	    'Callback',['spm_write_filtered(xSPM.Z,xSPM.XYZ,xSPM.DIM,xSPM.M,',...
		    'sprintf(''SPM{%c}-filtered: u = %5.3f, k = %d'',',...
		    'xSPM.STAT,xSPM.u,xSPM.k));'],...
	    'Interruptible','on','Enable','on',...
	    'Position',[285 095 100 020].*WS)

  %-ResultsUI controls
  %-----------------------------------------------------------------------
  uicontrol(Finter,'Style','Frame','Position',[280 050 110 030].*WS)

  hClear = uicontrol(Finter,'Style','PushButton','String','clear',...
		     'ToolTipString','clears results subpane',...
		     'FontSize',FS(9),'ForegroundColor','b',...
		     'Callback',['roi_drawall_contrasts(''Clear''); ',...
		    'spm_input(''!DeleteInputObj''),',...
	            'spm_clf(''Satellite'')'],...
		     'Interruptible','on','Enable','on',...
		     'DeleteFcn','clc,spm_clf(''Graphics'')',...
		     'Position',[285 055 035 018].*WS);

  hExit  = uicontrol(Finter,'Style','PushButton','String','exit',...
		     'ToolTipString','exit the results section',...
		     'FontSize',FS(9),'ForegroundColor','r',...
		     'Callback',['spm_clf(''Interactive''), spm_clf(''Graphics''),'...
		    'close(spm_figure(''FindWin'',''Satellite'')),'...
		    'clear'],...
		     'Interruptible','on','Enable','on',...
		     'Position',[325 055 035 018].*WS);

  hHelp  = uicontrol(Finter,'Style','PushButton','String','?',...
		     'ToolTipString','results section help',...
		     'FontSize',FS(9),'ForegroundColor','g',...
		     'Callback','spm_help(''roi_drawall_contrasts'')',...
		     'Interruptible','on','Enable','on',...
		     'Position',[365 055 020 018].*WS);


  %=======================================================================
 case 'drawxyzgui'                                    %-Draw XYZ GUI area
						      %=======================================================================
						      % hFxyz = roi_drawall_contrasts('DrawXYZgui',M,DIM,xSPM,xyz,Finter)
						      if nargin<6,  Finter=spm_figure('FindWin','Interactive');
						      else, Finter=varargin{6}; end
						      if nargin < 5, xyz=[0;0;0]; else, xyz=varargin{5}; end
						      if nargin < 4, error('Insufficient arguments'), end
						      DIM     = varargin{3};
						      M       = varargin{2};
						      xyz     = spm_XYZreg('RoundCoords',xyz,M,DIM);

						      %-Locate windows etc...
						      %-----------------------------------------------------------------------
						      WS      = spm('WinScale');
						      FS      = spm('FontSizes');
						      PF      = spm_platform('fonts');

						      %-Create XYZ control objects
						      %-----------------------------------------------------------------------
						      hFxyz = uicontrol(Finter,'Style','Frame','Position',[010 010 265 030].*WS);
						      uicontrol(Finter,'Style','Text','String','co-ordinates',...
								'Position',[020 033 078 016].*WS,...
								'FontName',PF.times,'FontWeight','Normal','FontAngle','Italic',...
								'FontSize',FS(10),...
								'HorizontalAlignment','Left',...
								'ForegroundColor','w')

						      uicontrol(Finter,'Style','Text','String','x =',...
								'Position',[020 015 024 018].*WS,...
								'FontName',PF.times,'FontSize',FS(10),'FontAngle','Italic',...
								'HorizontalAlignment','Center');
						      hX   = uicontrol(Finter,'Style','Edit','String',sprintf('%.2f',xyz(1)),...
								       'ToolTipString','enter x-coordinate',...
								       'Position',[044 015 056 020].*WS,...
								       'FontSize',FS(10),'BackGroundColor',[.8,.8,1],...
								       'HorizontalAlignment','Right',...
								       'Tag','hX',...
								       'Callback','roi_drawall_contrasts(''EdWidCB'')');

						      uicontrol(Finter,'Style','Text','String','y =',...
								'Position',[105 015 024 018].*WS,...
								'FontName',PF.times,'FontSize',FS(10),'FontAngle','Italic',...
								'HorizontalAlignment','Center')
						      hY   = uicontrol(Finter,'Style','Edit','String',sprintf('%.2f',xyz(2)),...
								       'ToolTipString','enter y-coordinate',...
								       'Position',[129 015 056 020].*WS,...
								       'FontSize',FS(10),'BackGroundColor',[.8,.8,1],...
								       'HorizontalAlignment','Right',...
								       'Tag','hY',...
								       'Callback','roi_drawall_contrasts(''EdWidCB'')');

						      uicontrol(Finter,'Style','Text','String','z =',...
								'Position',[190 015 024 018].*WS,...
								'FontName',PF.times,'FontSize',FS(10),'FontAngle','Italic',...
								'HorizontalAlignment','Center')
						      hZ   = uicontrol(Finter,'Style','Edit','String',sprintf('%.2f',xyz(3)),...
								       'ToolTipString','enter z-coordinate',...
								       'Position',[214 015 056 020].*WS,...
								       'FontSize',FS(10),'BackGroundColor',[.8,.8,1],...
								       'HorizontalAlignment','Right',...
								       'Tag','hZ',...
								       'Callback','roi_drawall_contrasts(''EdWidCB'')');

						      %-Statistic value reporting pane
						      %-----------------------------------------------------------------------
						      hFconB = uicontrol(Finter,'Style','Frame','Position',[280 010 110 030].*WS);
						      uicontrol(Finter,'Style','Text','String','statistic value',...
								'Position',[285 035 085 016].*WS,...
								'FontName',PF.times,'FontWeight','Normal','FontAngle','Italic',...
								'FontSize',FS(10),...
								'HorizontalAlignment','Left',...
								'ForegroundColor','w')
						      hSPM = uicontrol(Finter,'Style','Text','String','',...
								       'Position',[285 012 100 020].*WS,...
								       'FontSize',FS(10),...
								       'HorizontalAlignment','Center');


						      %-Store data
						      %-----------------------------------------------------------------------
						      set(hFxyz,'Tag','hFxyz','UserData',struct(...
							  'hReg',	[],...
							  'M',	M,...
							  'DIM',	DIM,...
							  'XYZ',	varargin{4}.XYZmm,...
							  'Z',	varargin{4}.Z,...
							  'hX',	hX,...
							  'hY',	hY,...
							  'hZ',	hZ,...
							  'hSPM',	hSPM,...
							  'xyz',	xyz	));

						      set([hX,hY,hZ],'UserData',hFxyz)
						      varargout = {hFxyz};



						      %=======================================================================
 case 'edwidcb'                           %-Callback for editable widgets
					  %=======================================================================
					  % roi_drawall_contrasts('EdWidCB')

					  hC    = gcbo;
					  d     = find(strcmp(get(hC,'Tag'),{'hX','hY','hZ'}));
					  hFxyz = get(hC,'UserData');
					  UD    = get(hFxyz,'UserData');
					  xyz   = UD.xyz;
					  nxyz  = xyz;

					  o = evalin('base',['[',get(hC,'String'),']'],'sprintf(''error'')');
					  if ischar(o) | length(o)>1
					      warning(sprintf('%s: Error evaluating ordinate:\n\t%s',...
							      mfilename,lasterr))
					  else
					      nxyz(d) = o;
					      nxyz = spm_XYZreg('RoundCoords',nxyz,UD.M,UD.DIM);
					  end

					  if abs(xyz(d)-nxyz(d))>0
					      UD.xyz = nxyz; set(hFxyz,'UserData',UD)
					      if ~isempty(UD.hReg), spm_XYZreg('SetCoords',nxyz,UD.hReg,hFxyz); end
					      set(hC,'String',sprintf('%.3f',nxyz(d)))
					      roi_drawall_contrasts('UpdateSPMval',UD)
					  end

					  %=======================================================================
 case 'updatespmval'                            %-Update SPM value in GUI
						%=======================================================================
						% roi_drawall_contrasts('UpdateSPMval',hFxyz)
						% roi_drawall_contrasts('UpdateSPMval',UD)
						if nargin<2, error('insufficient arguments'), end
						if isstruct(varargin{2}), UD=varargin{2}; else, UD = get(varargin{2},'UserData'); end
						i  = spm_XYZreg('FindXYZ',UD.xyz,UD.XYZ);
						if isempty(i), str = ''; else, str = sprintf('%6.2f',UD.Z(i)); end
						set(UD.hSPM,'String',str);


						%=======================================================================
 case 'getcoords'              % Get current co-ordinates from XYZ widget
			       %=======================================================================
			       % xyz = roi_drawall_contrasts('GetCoords',hFxyz)
			       if nargin<2, hFxyz='Interactive'; else, hFxyz=varargin{2}; end
			       hFxyz     = roi_drawall_contrasts('FindXYZframe',hFxyz);
			       varargout = {getfield(get(hFxyz,'UserData'),'xyz')};



			       %=======================================================================
 case 'setcoords'                        % Set co-ordinates to XYZ widget
					 %=======================================================================
					 % [xyz,d] = roi_drawall_contrasts('SetCoords',xyz,hFxyz,hC)
					 if nargin<4, hC=0; else, hC=varargin{4}; end
					 if nargin<3, hFxyz=roi_drawall_contrasts('FindXYZframe'); else, hFxyz=varargin{3}; end
					 if nargin<2, error('Set co-ords to what!'), else, xyz=varargin{2}; end

					 %-If this is an internal call, then don't do anything
					 if hFxyz==hC, return, end

					 UD = get(hFxyz,'UserData');

					 %-Check validity of coords only when called without a caller handle
					 %-----------------------------------------------------------------------
					 if hC <= 0
					     [xyz,d] = spm_XYZreg('RoundCoords',xyz,UD.M,UD.DIM);
					     if d>0 & nargout<2, warning(sprintf(...
						 '%s: Co-ords rounded to neatest voxel center: Discrepancy %.2f',...
						 mfilename,d)), end
					     else
						 d = [];
					     end

					     %-Update xyz information & widget strings
					     %-----------------------------------------------------------------------
					     UD.xyz = xyz; set(hFxyz,'UserData',UD)
					     set(UD.hX,'String',sprintf('%.2f',xyz(1)))
					     set(UD.hY,'String',sprintf('%.2f',xyz(2)))
					     set(UD.hZ,'String',sprintf('%.2f',xyz(3)))
					     roi_drawall_contrasts('UpdateSPMval',UD)

					     %-Tell the registry, if we've not been called by the registry...
					     %-----------------------------------------------------------------------
					     if (~isempty(UD.hReg) & UD.hReg~=hC)
						 spm_XYZreg('SetCoords',xyz,UD.hReg,hFxyz);
					     end

					     %-Return arguments
					     %-----------------------------------------------------------------------
					     varargout = {xyz,d};



					     %=======================================================================
case 'findxyzframe'                                   % Find hFxyz frame
%=======================================================================
% hFxyz = roi_drawall_contrasts('FindXYZframe',h)
% Sorts out hFxyz handles
if nargin<2, h='Interactive'; else, h=varargin{2}; end
if isstr(h), h=spm_figure('FindWin',h); end
if ~ishandle(h), error('invalid handle'), end
if ~strcmp(get(h,'Tag'),'hFxyz'), h=findobj(h,'Tag','hFxyz'); end
if isempty(h), error('XYZ frame not found'), end
if length(h)>1, error('Multiple XYZ frames found'), end
varargout = {h};



%=======================================================================
case 'plotui'                                %-GUI for plot manipulation
%=======================================================================
% roi_drawall_contrasts('PlotUi',hAx)
if nargin<2, hAx=gca; else, hAx=varargin{2}; end

WS = spm('WinScale');
FS = spm('FontSizes');
Finter=spm_figure('FindWin','Interactive');
figure(Finter)

%-Check there aren't already controls!
%-----------------------------------------------------------------------
hGraphUI = findobj(Finter,'Tag','hGraphUI');
if ~isempty(hGraphUI)			%-Controls exist
	hBs = get(hGraphUI,'UserData');
	if hAx==get(hBs(1),'UserData')	%-Controls linked to these axes
		return
	else				%-Old controls remain
		delete(findobj(Finter,'Tag','hGraphUIbg'))
	end
end

%-Frames & text
%-----------------------------------------------------------------------
hGraphUIbg = uicontrol(Finter,'Style','Frame','Tag','hGraphUIbg',...
		'BackgroundColor',spm('Colour'),...
		'Position',[001 196 400 055].*WS);
hGraphUI   = uicontrol(Finter,'Style','Frame','Tag','hGraphUI',...
		'Position',[008 202 387 043].*WS);
hGraphUIButtsF = uicontrol(Finter,'Style','Frame',...
		'Position',[010 205 380 030].*WS);
hText = uicontrol(Finter,'Style','Text','String','plot controls',...
	'Position',[020 227 080 016].*WS,...
	'FontName',spm_platform('font','times'),'FontWeight','Normal',...
	'FontAngle','Italic','FontSize',FS(10),...
	'HorizontalAlignment','Left',...
	'ForegroundColor','w');

%-Controls
%-----------------------------------------------------------------------
h1 = uicontrol(Finter,'Style','CheckBox','String','hold',...
	'ToolTipString','toggle hold to overlay plots',...
	'FontSize',FS(10),...
	'Value',strcmp(get(hAx,'NextPlot'),'add'),...
	'Callback',[...
		'if get(gcbo,''Value''), ',...
		    'set(get(gcbo,''UserData''),''NextPlot'',''add''), ',...
		'else, ',...
		    'set(get(gcbo,''UserData''),''NextPlot'',''replace''), ',...
		'end'],...
	'Interruptible','on','Enable','on',...
	'Position',[015 210 070 020].*WS);
h2 = uicontrol(Finter,'Style','CheckBox','String','grid',...
	'ToolTipString','toggle axes grid',...
	'FontSize',FS(10),...
	'Value',strcmp(get(hAx,'XGrid'),'on'),...
	'Callback',[...
		'if get(gcbo,''Value''), ',...
			'set(get(gcbo,''UserData''),''XGrid'',''on'','...
		    		'''YGrid'',''on'',''ZGrid'',''on''), ',...
		'else, ',...
			'set(get(gcbo,''UserData''),''XGrid'',''off'','...
		    		'''YGrid'',''off'',''ZGrid'',''off''), ',...
		'end'],...
	'Interruptible','on','Enable','on',...
	'Position',[090 210 070 020].*WS);
h3 = uicontrol(Finter,'Style','CheckBox','String','Box',...
	'ToolTipString','toggle axes box',...
	'FontSize',FS(10),...
	'Value',strcmp(get(hAx,'Box'),'on'),...
	'Callback',[...
		'if get(gcbo,''Value''), ',...
		    'set(get(gcbo,''UserData''),''Box'',''on''), ',...
		'else, ',...
		    'set(get(gcbo,''UserData''),''Box'',''off''), ',...
		'end'],...
	'Interruptible','on','Enable','on',...
	'Position',[165 210 070 020].*WS);
h4 = uicontrol(Finter,'Style','PopUp',...
	'ToolTipString','edit axis text annotations',...
	'FontSize',FS(10),...
	'String','text|Title|Xlabel|Ylabel',...
	'Callback','roi_drawall_contrasts(''PlotUiCB'')',...
	'Interruptible','on','Enable','on',...
	'Position',[240 210 070 020].*WS);
h5 = uicontrol(Finter,'Style','PopUp',...
	'ToolTipString','change various axes attributes',...
	'FontSize',FS(10),...
	'String','attrib|LineWidth|XLim|YLim|handle',...
	'Callback','roi_drawall_contrasts(''PlotUiCB'')',...
	'Interruptible','off','Enable','on',...
	'Position',[315 210 070 020].*WS);

%-Handle storage for linking, and DeleteFcns for linked deletion
%-----------------------------------------------------------------------
set(hGraphUI,'UserData',[h1,h2,h3,h4,h5])
set([h1,h2,h3,h4,h5],'UserData',hAx)

set(hGraphUIbg,'UserData',...
	[hGraphUI,hGraphUIButtsF,hText,h1,h2,h3,h4,h5],...
	'DeleteFcn','roi_drawall_contrasts(''Delete'',get(gcbo,''UserData''))')
set(hAx,'UserData',hGraphUIbg,...
	'DeleteFcn','roi_drawall_contrasts(''Delete'',get(gcbo,''UserData''))')




%=======================================================================
case 'plotuicb'
%=======================================================================
% roi_drawall_contrasts('PlotUiCB')
hPM = gcbo;
v   = get(hPM,'Value');
if v==1, return, end
str = cellstr(get(hPM,'String'));
str = str{v};

hAx = get(hPM,'UserData');
switch str
case 'Title'
	h = get(hAx,'Title');
	set(h,'String',spm_input('Enter title:',-1,'s+',get(h,'String')))
case 'Xlabel'
	h = get(hAx,'Xlabel');
	set(h,'String',spm_input('Enter X axis label:',-1,'s+',get(h,'String')))
case 'Ylabel'
	h = get(hAx,'Ylabel');
	set(h,'String',spm_input('Enter Y axis label:',-1,'s+',get(h,'String')))
case 'LineWidth'
	lw = spm_input('Enter LineWidth',-1,'e',get(hAx,'LineWidth'),1);
	set(hAx,'LineWidth',lw)
case 'XLim'
	XLim = spm_input('Enter XLim',-1,'e',get(hAx,'XLim'),[1,2]);
	set(hAx,'XLim',XLim)
case 'YLim'
	YLim = spm_input('Enter YLim',-1,'e',get(hAx,'YLim'),[1,2]);
	set(hAx,'YLim',YLim)
case 'handle'
	varargout={hAx};
otherwise
	warning(['Unknown action: ',str])
end

set(hPM,'Value',1)


%=======================================================================
case {'clear','clearpane'}                       %-Clear results subpane
%=======================================================================
% Fgraph = roi_drawall_contrasts('Clear',F,mode)
% mode 1 [default] usual, mode 0 - clear & hide Res stuff, 2 - RNP
if strcmp(lower(Action),'clearpane')
	warning('''ClearPane'' action is grandfathered, use ''Clear'' instead')
end

if nargin<3, mode=1; else, mode=varargin{3}; end
if nargin<2, F='Graphics'; else, F=varargin{2}; end
F = spm_figure('FindWin',F);

%-Clear input objects from 'Interactive' window
%-----------------------------------------------------------------------
%spm_input('!DeleteInputObj')


%-Get handles of objects in Graphics window & note permanent results objects
%-----------------------------------------------------------------------
H = get(F,'Children');				%-Get contents of window
H = findobj(H,'flat','HandleVisibility','on');	%-Drop GUI components
h = findobj(H,'flat','Tag','PermRes');		%-Look for 'PermRes' object

if ~isempty(h)
	%-Found 'PermRes' object
	% This has handles of permanent results objects in it's UserData
	tmp  = get(h,'UserData');
	HR   = tmp.H;
	HRv  = tmp.Hv;
else
	%-No trace of permanent results objects
	HR   = [];
	HRv  = {};
end
H = setdiff(H,HR);				%-Drop permanent results obj


%-Delete stuff as appropriate
%-----------------------------------------------------------------------
if mode==2	%-Don't delete axes with NextPlot 'add'
	H = setdiff(H,findobj(H,'flat','Type','axes','NextPlot','add'));
end

delete(H)

if mode==0	%-Hide the permanent results section stuff
	set(HR,'Visible','off')
else
	set(HR,{'Visible'},HRv)
end


%=======================================================================
case 'launchmp'                             %-Launch multiplanar toolbox
%=======================================================================
% hMP = roi_drawall_contrasts('LaunchMP',M,DIM,hReg,hBmp)
if nargin<5, hBmp = gcbo; else, hBmp = varargin{5}; end
hReg = varargin{4};
DIM  = varargin{3};
M    = varargin{2};

%-Check for existing MultiPlanar toolbox
hMP  = get(hBmp,'UserData');
if ishandle(hMP)
	figure(spm_figure('ParentFig',hMP))
	varargout = {hMP};
	return
end

%-Initialise and cross-register MultiPlanar toolbox
hMP = spm_XYZreg_Ex2('Create',M,DIM);
spm_XYZreg('Xreg',hReg,hMP,'spm_XYZreg_Ex2');

%-Setup automatic deletion of MultiPlanar on deletion of results controls
set(hBmp,'Enable','on','UserData',hMP)
set(hBmp,'DeleteFcn','roi_drawall_contrasts(''delete'',get(gcbo,''UserData''))')

varargout = {hMP};



%=======================================================================
case 'delete'                            %-Delete HandleGraphics objects
%=======================================================================
% roi_drawall_contrasts('Delete',h)
h = varargin{2};
delete(h(ishandle(h)));


%=======================================================================
otherwise
%=======================================================================
error('Unknown action string')

%=======================================================================
end


