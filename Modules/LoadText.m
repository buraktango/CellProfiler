function handles = LoadText(handles)

% Help for the Load Text module:
% Category: File Processing
%
% Use this tool if you would like text information.  The information could
% be referring to each image set, each object, or anything else the user
% would like.
% The text information must be specified in a separate text file
% with the following syntax:
%
% DESCRIPTION <description>
% <Text info>
% <Text info>
% <Text info>
%              .
%              .
%
% <description> is a description of the text information stored in the
% file. It can contain spaces or unusual characters.
%
% For example:
%
% DESCRIPTION Gene names
% Gene X
% Gene Y
% Gene Z
%
%
% See also ADDDATA.
%
% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Authors:
%   Anne Carpenter <carpenter@wi.mit.edu>
%   Thouis Jones   <thouis@csail.mit.edu>
%   In Han Kang    <inthek@mit.edu>
%   Ola Friman     <friman@bwh.harvard.edu>
%   Steve Lowe     <stevelowe@alum.mit.edu>
%   Joo Han Chang  <joohan.chang@gmail.com>
%   Colin Clarke   <colinc@mit.edu>
%   Mike Lamprecht <mrl@wi.mit.edu>
%   Susan Ma       <xuefang_ma@wi.mit.edu>
%
% $Revision$

%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%
drawnow

%%% Reads the current module number, because this is needed to find
%%% the variable values that the user entered.
CurrentModule = handles.Current.CurrentModuleNumber;
CurrentModuleNum = str2double(CurrentModule);
ModuleName = char(handles.Settings.ModuleNames(CurrentModuleNum));

%filenametextVAR01 = What is the file containing the text that you want to load?
TextFileName = char(handles.Settings.VariableValues{CurrentModuleNum,1});

%textVAR02 = What would you like to call the loaded text?
%defaultVAR02 = names
%infotypeVAR02 = datagroup indep
FieldName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%%%VariableRevisionNumber = 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY ERROR CHECKING & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

if handles.Current.SetBeingAnalyzed == 1
    %%% Parse text file %%%
    fid = fopen(TextFileName,'r');
    if fid == -1
        fid = fopen(fullfile(handles.Current.DefaultImageDirectory,TextFileName),'r');
        if fid == -1
            fid = fopen(fullfile(handles.Current.DefaultOutputDirectory,TextFileName),'r');
            if fid == -1
                error('Could not open file.  It might not exist or you might not have given its valid path.');
            end
        end
    end

    % Get description
    s = fgets(fid,11);
    if ~strcmp(s,'DESCRIPTION')
        error('The first line in the text information file must start with DESCRIPTION')
    end
    Description = fgetl(fid);
    Description = Description(2:end);       % Remove space

    % Read following lines into a cell array
    Text = [];
    while 1
        s = fgetl(fid);
        if ~ischar(s), break, end
        if ~isempty(s)
            Text{end+1} = s;
        end
    end
    fclose(fid);

    %%% Add the data
    %%% If the entered field doesn't exist  (This is the convenient way of doing it. Takes time for large ouput files??)
    if ~isfield(handles.Measurements,FieldName)
        handles.Measurements.([FieldName,'Text']) = {Description};
        handles.Measurements.(FieldName) = Text;
        %%% If the entered field already exists we have to append to this field
    else
        handles.Measurements.([FieldName,'Text']) = cat(2,handles.Measurements.([FieldName,'Text']),{Description});
        handles.Measurements.(FieldName) = cat(2,handles.Measurements.(FieldName),Text);
    end

    %%%%%%%%%%%%%%%%%%%%%%
    %%% DISPLAY RESULTS %%%
    %%%%%%%%%%%%%%%%%%%%%%
    drawnow

    fieldname = ['FigureNumberForModule',CurrentModule];
    ThisModuleFigureNumber = handles.Current.(fieldname);
    if any(findobj == ThisModuleFigureNumber) == 1
        CPfigure(handles,ThisModuleFigureNumber);
        uicontrol('style','text','units','normalized','HorizontalAlignment','left','string',['Description: ',Description],'position',[.05 .55 .8 .4],'BackgroundColor',[.7 .7 .9])
        uicontrol('style','text','units','normalized','HorizontalAlignment','left','string',['Text: ',Text],'position',[.05 .1 1 .7],'BackgroundColor',[.7 .7 .9])
    end
end