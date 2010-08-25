function sap_writeexpert(filename)
% SAP_WRITEEXPERT Creates the expert system m-file based on PUs and Nodes

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/routines.1/sap_writeexpert.m 3     10/08/02 2:37p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE
fullfilename = which('ASAPP.m');
[AWD,name,xt] = fileparts(fullfilename);
if nargin==0,
    filename = 'sap_expert1.m';
else,
    [pth,nm,xt] = fileparts(filename);
    filename = [nm,'.m'];
end;
expertname = [AWD filesep 'routines.1' filesep filename];

fid = fopen(expertname,'wt');
fprintf(fid,'function regions = sap_expert1(nodevalid)\n');
fprintf(fid,'%%  SAP_EXPERT1 Auto generated file\n');
fprintf(fid,'%% Satrajit Ghosh, SpeechLab, Boston University. (c)2001\n');
fprintf(fid,'%% $Header: /ASAP/routines.1/sap_expert.m 4     9/27/01 11:11a Satra $\n');
fprintf(fid,'\n');
fprintf(fid,'%% $NoKeywords: $\n\n');

fprintf(fid,'%% PU labels\n');
[PU,id] = sap_PUlist;
for i=1:length(PU),
    fprintf(fid,'%s=%d;',PU{i},id(i));
    if mod(i,7)==0;
        fprintf(fid,'\n');
    end;
end
fprintf(fid,'\n\n\n');

fprintf(fid,'%% Node labels\n');
nodes = sap_nodelist;

ct = 0;
for i=1:length(nodes),
    namecount = 0;  % to avoid confusion between indexing of names given by sap_nodelist
    for j=nodes(i).id(:)',
        namecount = namecount+1;
        nodename{i,j} = sprintf('%s_%s',strip(nodes(i).sername),strip(nodes(i).names{namecount}));
        fprintf(fid,'%s=%d;',nodename{i,j},100*nodes(i).sid+nodes(i).id(namecount));
        ct = ct+1;
        if mod(ct,3)==0;
            fprintf(fid,'\n');
        end;
    end;
end;
fprintf(fid,'\n\n\n');

for i=1:length(nodes),
    for j=nodes(i).id(:)',
        fprintf(fid,'%%%s\n',nodename{i,j});
        fprintf(fid,'Node{%s}.Start = [];\n',nodename{i,j});
        fprintf(fid,'Node{%s}.Stop = [];\n\n',nodename{i,j});
    end;
end;

fprintf(fid,'regions = [];\n');
fprintf(fid,'for i=nodevalid,\n');
fprintf(fid,'   regions = union(regions,Node{i}.Start);\n');
fprintf(fid,'end;\n');
fprintf(fid,'for i=nodevalid,\n');
fprintf(fid,'   regions = setdiff(regions,Node{i}.Stop);\n');
fprintf(fid,'end;\n');

fclose(fid);

function str = strip(str)
str = str(find(str ~= ' '));