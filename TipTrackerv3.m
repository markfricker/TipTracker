function varargout = TipTrackerv3(varargin)
% TIPTRACKERV3 MATLAB code for TipTrackerv3.fig
%      TIPTRACKERV3, by itself, creates a new TIPTRACKERV3 or raises the existing
%      singleton*.
%
%      H = TIPTRACKERV3 returns the handle to a new TIPTRACKERV3 or the handle to
%      the existing singleton*.
%
%      TIPTRACKERV3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIPTRACKERV3.M with the given input arguments.
%
%      TIPTRACKERV3('Property','Value',...) creates a new TIPTRACKERV3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TipTrackerv3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TipTrackerv3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TipTrackerv3

% Last Modified by GUIDE v2.5 08-Mar-2021 20:25:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TipTrackerv3_OpeningFcn, ...
    'gui_OutputFcn',  @TipTrackerv3_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TipTrackerv3 is made visible.
function TipTrackerv3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TipTrackerv3 (see VARARGIN)

% Choose default command line output for TipTrackerv3
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% set up the GUI
handles = fnc_initialise_GUI(handles);
handles = fnc_initialise_bioformats(handles);
% Update handles structure
guidata(hObject, handles);
% load in the reference table
if isdeployed
    if ispc
        handles.reference_table  = readtable('C:\Program Files\MDF\Tip_Tracker_v3\application\ReferenceTableTipTracker.xlsx','FileType','spreadsheet','ReadVariableNames',1);
    elseif ismac
        handles.reference_table  = readtable('C:/Applications/MDF/Tip_Tracker_v3/application/ReferenceTableTipTracker.xlsx','FileType','spreadsheet','ReadVariableNames',1);
    elseif isunix
        handles.reference_table  = readtable('/usr/MDF/Tip_Tracker_v3/application/ReferenceTableTipTracker','FileType','spreadsheet','ReadVariableNames',1);
    end
else
    handles.reference_table = readtable('ReferenceTableTipTracker.xlsx','FileType','spreadsheet','ReadVariableNames',1);
end
% set up non-default colormaps
% rainbow
R = [linspace(0,0,128) linspace(0,1,54) linspace(1,1,54) linspace(1,0.625,20)];
G = [linspace(0,0,20) linspace(0,1,54) linspace(1,1,108) linspace(1,0,54) linspace(0,0,20)];
B = [linspace(0,1,20) linspace(1,1,54) linspace(1,0,54) linspace(0,0,128)];
handles.Cmap_rainbow = [R' G' B'];

% handles.controls    handles to the control buttons for each step
handles.controls = [handles.btn_import_images handles.btn_filter handles.btn_back_measure handles.btn_back_sub handles.btn_auto_corr];

handles.channel_controls = ...
    [handles.pop_ch1, handles.pop_ch2, handles.pop_ch3, handles.pop_ch4];

handles.filter_controls = get(handles.uip_filter, 'Children');

handles.back_sub_controls =  ...
    [handles.txt_ch1_back, handles.txt_ch2_back, handles.txt_ch3_back, handles.txt_ch4_back; ...
    handles.chk_ch1_back, handles.chk_ch2_back, handles.chk_ch3_back, handles.chk_ch4_back; ...
    handles.txt_ch1_std, handles.txt_ch2_std, handles.txt_ch3_std, handles.txt_ch4_std];

handles.back_controls = ...
    [handles.pop_back_method, handles.chk_auto_corr, handles.pop_auto_corr_channel, handles.txt_auto_corr];

handles.autoflr_controls = ...
    [handles.pop_auto_corr_target, handles.pop_auto_corr_channel, handles.txt_auto_corr];

handles.tip_trace_controls = get(handles.uip_tip_trace, 'Children');
handles.tip_profile_controls = get(handles.uip_tip_profile, 'Children');
% inverse
handles.Cmap_inverse = 1-gray(256);
% jet with black at zero
handles.jetb = jet(256);
handles.jetb(1,:) = 0;
handles.jetbw = handles.jetb;
handles.jetbw(256,:) = 1;
% set up a blank image
handles.blank = zeros(512,512, 'uint8');
% sets all the default parameters for the sliders and text boxes
set(handles.sld_white_level, 'Min', 1, 'Max', 255, 'Value', 255, 'sliderstep', [1/255 16/255]);
set(handles.txt_white_level, 'String', get(handles.sld_white_level, 'value'));
set(handles.sld_black_level, 'Min', 0, 'Max', 254, 'Value', 0, 'sliderstep', [1/255 16/255]);
set(handles.txt_black_level, 'String', get(handles.sld_black_level, 'value'));
% set zoom controls
set(handles.sld_zoom, 'Min', 0.1, 'Max', 16, 'SliderStep', [1/(159) 1/(15.9)], 'Value', 1);
set(handles.txt_zoom, 'String', 1);
%
set(handles.txt_T, 'String', 1);
set(handles.txt_Z, 'String', 1);
handles.T_inc = 1;
handles.Z_inc = 1;
% load in files from the current directory
handles.dir_in = cd;
% handles = fnc_load_dir(handles);
% set up first scroll panel
handles.ax_image = axes('parent',handles.uip_Im1,'Units','normalized','position',[0 0 1 1],'clipping','on');
hIm1 = imshow(handles.blank,'parent',handles.ax_image);
handles.hSp1 = imscrollpanel(handles.uip_Im1,hIm1);
set(handles.ax_image, 'Units','pixels')
% % % % Add a Magnification box
% % % hMagBox = immagbox(handles.uip_display_controls,hIm1);
% % % set(hMagBox,'Position',[595.5 85.5 41 19]);
% add an overview panel
handles.ax_overview = imoverviewpanel(handles.uip_Im2,hIm1);
% turn off re-direction to an output figure
handles.save_full_size_flag = 0;
% set up the colorbars
axes(handles.ax_colorbar)
axis off
set(handles.ax_colorbar, 'Color','w')
handles.h_colorbar = colorbar(handles.ax_colorbar,'location','east','TickDirection','out','TickLength',0.02,'FontSize',8);
handles.h_colorbar.Label.String = 'intensity';
handles.h_colorbar.Label.Interpreter = 'none';
% set the control strings
handles = fnc_controls_options(handles);
% start with default parameters
handles.expt = fnc_experiment_default;
handles = fnc_parameters_default(handles);
% update all the control strings
handles = fnc_controls_update(handles);
set(handles.chk_display_R, 'Value',1)
set(handles.chk_display_G, 'Value',1)
set(handles.chk_display_B, 'Value',1)
% set all of the controls off to begin with until the image has been loaded
set(handles.segment_controls, 'enable','off')
set(handles.filter_controls, 'enable','off');
set(handles.tip_trace_controls,'enable','off');
set(handles.tip_profile_controls,'enable','off');
% set the properties of the data cursor
handles.dcm_obj = datacursormode(hObject);
set(handles.dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','on','Enable','off')
guidata(hObject, handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TipTrackerv3 wait for user response (see UIRESUME)
% uiwait(handles.Tip_Tracker);


% --- Outputs from this function are returned to the command line.
function varargout = TipTrackerv3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -------------------------------------------------------------------------
% INITIALISE THE GUI
% -------------------------------------------------------------------------
function chk_full_screen_Callback(hObject, eventdata, handles)
handles = fnc_initialise_GUI(handles);
% Update handles structure
guidata(hObject, handles);

function handles = fnc_initialise_GUI(handles)
% set up the GUI size and position
GUI_width = 1580;
GUI_height = 850;
% sets the look and feel interface on each platform
if isdeployed && usejava('swing')
    [major, minor] = mcrversion;
    if major == 9 && minor == 0
        if ispc
            javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
        elseif isunix
            javax.swing.UIManager.setLookAndFeel('com.jgoodies.looks.plastic.Plastic3DLookAndFeel');
        elseif ismac
            javax.swing.UIManager.setLookAndFeel('com.apple.laf.AquaLookAndFeel');
        end
    end
end
% resizes controls for mac look and feel interface, otherwise the text does
% not fit within the controls
if ismac
    h = findobj(gcf,'style','popupmenu');
    for iP = 1:numel(h)
        pos = get(h(iP),'Position');
        set(h(iP),'units','pixels','Position',[pos(1)-5 pos(2) pos(3)+5 23])
    end
    h = findobj(gcf,'style','button');
    for iP = 1:numel(h)
        pos = get(h(iP),'Position');
        set(h(iP),'units','pixels','Position',[pos(1) pos(2) pos(3) 21])
    end
end
% get the screen size
set(0,'Units','pixels');
screen = get(0,'ScreenSize');
% allow 25 pixels for the menu bar and 25 pixels at the base of the screen
% for the windows menu bar
if screen(3) < GUI_width || screen(4) < GUI_height+50 || get(handles.chk_full_screen, 'Value')
    %switch all controls to be resizable and position GUI to almost fill
    % screen, leaving enough space for the menu bar
    set(0,'Units','normalized');
    set(gcf,'Units','normalized');
    h = findobj(gcf,'Units','pixels');
    %h = findobj(gcf,'-not','type','image','-not','type','scatter','-not','type','errorbar','-not','type','line');
    set(h,'units','normalized');
    h = findobj(gcf,'Type','UIControl','-or','Type','UIpanel');
    set(h,'FontName','Helvetica','FontUnits','normalized');
    set(gcf,'resize','on');
    yoffset = 25/screen(4);
    figpos = [0 yoffset 1 1-(yoffset*2)];
    set(gcf, 'Position', figpos);
else
    set(0,'Units','pixels');
    screen = get(0,'ScreenSize');
    h = findobj(gcf,'units','normalised');
    set(h,'units','pixels')
    % sets the default font size for all the controls
    h = findobj(gcf,'Type','UIControl','-or','Type','UIpanel');
    if ispc
        set(h,'FontName','Helvetica','FontUnits','pixels','FontSize',11);
    elseif ismac
        set(h,'FontName','Helvetica','FontUnits','pixels','FontSize',9);
    end
    % centre the GUI
    figpos = [round((screen(3)-GUI_width)/2) round((screen(4)-GUI_height-1)/2) GUI_width GUI_height];
    set(gcf, 'Position', figpos);
end

function handles = fnc_initialise_bioformats(handles)
if isdeployed
    if ispc
        handles.bioformats_dir = 'C:\Program Files\MDF\TipTracker\application\bioformats_package.jar';
    elseif ismac
        handles.bioformats_dir = 'C:/Applications/MDF/TipTracker/application/bioformats_package.jar';
    elseif isunix
        handles.bioformats_dir = '/usr/MDF/TipTracker/application/bioformats_package.jar';
    end
    % find the location of the bio formats package
    if exist(handles.bioformats_dir, 'file')
        javaaddpath(handles.bioformats_dir);
    else
        handles.bioformats_dir = [];
    end
else
    % check if there is a path to the bioformats  package
    handles.bioformats_dir = which('bioformats_package.jar');
    javaaddpath(handles.bioformats_dir);
end

% -------------------------------------------------------------------------
% IMAGE LOADING ROUTINES
% -------------------------------------------------------------------------

function btn_load_image_Callback(hObject, eventdata, handles)
handles = fnc_initialise(handles);
handles = fnc_image_load(handles);
handles = fnc_update_parameters(handles);
handles = fnc_initial_settings(handles);
guidata(gcbo,handles)
% update the thumbnails
handles.thumbnails.raw = fnc_thumbnail_make(handles.images.raw(:,:,:,1,round(handles.nT/2)), 'raw',handles);
handles = fnc_thumbnail_display('raw',handles);
% display the loaded images
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'raw')));
handles = fnc_display_image(handles);
fnc_image_fit(handles);
guidata(gcbo, handles);

function handles = fnc_image_load(handles)
% update the parameters
% handles = fnc_update_parameters(handles);
% open a dialog
[handles.fname,handles.dir_in, filterindex] = uigetfile( ...
    {  '*.png;*.jpg;*.tif;*.bmp','Images (*.png;*.jpg;*.tif;*.bmp)'; ...
    '*.czi','Zeiss confocal'; ...
    '*.mat','MAT-files (*.mat)'; ...
    '*.lif','Leica confocal'; ...
    '*.nd2','Nikon confocal'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', ...
    'MultiSelect', 'off');
% get the filename of the image to load
set(handles.stt_status, 'String', ['Loading image(s) for :' handles.fname '. Please wait...']);drawnow;
cd(handles.dir_in);
[filename, path, ext] = fileparts(handles.fname);
set(handles.stt_status, 'String','Loading the raw image. Please wait...')
switch ext
    case {'.jpg';'.JPG';'.png';'.PNG';'.bmp';'.BMP'}
        % read in the image using the matlab filters
        handles.images.raw(:,:,:,1,1) = imread(handles.fname);
    case '.mat'
        temp = load(handles.fname);
        handles.images.raw = temp.output;
    case '.lif'
        if exist(handles.bioformats_dir, 'file')
            % use the bioformats package to open the lif database
            [info, handles.images.raw, db_fnames] = Network_Load_Bioformats(handles.fname);
            param.class = class(handles.images.raw);
            param.bit_depth = info.bit_depth;
            param.fname = info.fname;
            param.size_in = info.size;
            param.pixel_size_in = info.pixel_size_in;
            param.pixel_size = param.pixel_size_in;
            param.file_ext = info.file_ext;
            param.TimeStamps_in = info.TimeStamps_in;
        else
            msgbox('no bioformats package available','Bioformats error')
        end
    otherwise
        % read in the image using bioformats
        if exist(handles.bioformats_dir, 'file')
            org.apache.log4j.BasicConfigurator.configure;
            org.apache.log4j.Logger.getRootLogger.setLevel(org.apache.log4j.Level.INFO);
            % --- set up the bio formats reader
            r = loci.formats.ChannelFiller();
            r = loci.formats.ChannelSeparator(r);
            % --- construct Metadata container
            omemd = loci.formats.ome.OMEXMLMetadataImpl;
            omemd = loci.formats.MetadataTools.createOMEXMLMetadata();
            r.setMetadataStore(omemd);
            r.setMetadataFiltered(false);
            r.setId(handles.fname);
            r.setSeries(0);%series starts from zero
            DimOrder = char(r.getDimensionOrder);
            nX = r.getSizeX();
            nY = r.getSizeY();
            nC = r.getSizeC();
            nZ = r.getSizeZ();
            nT = r.getSizeT();
            %a = r.getPhysicalSizeX()
            %b = r.getDeltaT()
            numImages = r.getImageCount();
            pixelType = r.getPixelType();
            bpp = loci.formats.FormatTools.getBytesPerPixel(pixelType);
            info.bit_depth = bpp.*8;
            bit_depth = 2^info.bit_depth;
            fp = loci.formats.FormatTools.isFloatingPoint(pixelType);
            if fp == 0
                handles.images.raw = repmat(eval(['uint' num2str(info.bit_depth) '(0)']),[nY nX nC nZ nT]);
            else
                handles.images.raw = zeros([nY nX nC nZ nT], 'single');
            end
            switch DimOrder
                case {'XYCZT','XYCTZ'}
                    for iT = 1:nT
                        set(handles.stt_status,'String',['Loading frame ' num2str(iT) '. Please wait...']);drawnow;
                        for iZ = 1:nZ
                            for iC = 1:nC
                                iPlane = iC + (iZ-1).*nC + (iT-1).*nZ.*nC;
                                handles.images.raw(1:nY,1:nX,iC,iZ,iT) = bfGetPlane(r, iPlane);
                            end
                        end
                    end
                otherwise
            end
            r.close()
        else
            msgbox('no bioformats package available','Bioformats error')
        end
end
if get(handles.chk_Z_to_T, 'Value')
    handles.images.raw = permute(handles.images.raw, [1 2 3 5 4]);
end
% adjust each channel to fill the full bit-depth from the first image
% limits = stretchlim(handles.images.raw(:,:,:,1,1),[0.00001 0.99999]);
limits = stretchlim(handles.images.raw(:,:,:,1,1),[0 1]);
for iT = 1:nT
    for iZ = 1:nZ
        for iC = 1:nC
            handles.images.raw(:,:,iC,iZ,iT) = imadjust(handles.images.raw(:,:,iC,iZ,iT),limits(:,iC));
        end
    end
end
% initially set the rotated image to the raw input image
handles.images.rotated = handles.images.raw;

%-------------------------------------------------------------------------
% IMPORT USING LOAD_5D
%-------------------------------------------------------------------------

function btn_import_images_Callback(hObject, eventdata, handles)
handles = fnc_initialise(handles);
handles = fnc_import(handles);
handles = fnc_initial_settings(handles);
guidata(gcbo, handles);
% update the thumbnails
handles.thumbnails.raw = fnc_thumbnail_make(handles.images.raw(:,:,:,1,round(handles.nT/2)), 'raw',handles);
handles = fnc_thumbnail_display('raw',handles);
% display the loaded images
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'raw')));
handles = fnc_display_image(handles);
guidata(gcbo, handles);

function handles = fnc_import(handles)
% use the standard load interface
[handles.in_info, handles.images.raw, handles.images.bf] = Load_5D;
handles.dpath = handles.in_info(1).dpath;
handles.fname = handles.in_info(1).fname;
handles.file_ext = handles.in_info(1).file_ext{1};
set(handles.stt_fname,'string',handles.fname{1});
handles.param.pixel_size = handles.in_info(1).pixel_size;
handles.param.TimeStamps = handles.in_info.TimeStamps;

%-------------------------------------------------------------------------
% INITIALISE FUNCTIONS
%-------------------------------------------------------------------------

function handles = fnc_initialise(handles)
% set all of the controls off to begin with until the image has been loaded
set(handles.channel_controls, 'enable', 'off');
set(handles.filter_controls, 'enable','off')
set(handles.back_controls, 'enable', 'off');
set(handles.back_sub_controls, 'enable', 'off');
set(handles.autoflr_controls, 'enable', 'off');
% Reset all the image arrays
handles.images = struct( ...
    'raw', [], ...
    'rotated', [], ...
    'initial', [], ...
    'filtered', [], ...
    'subtracted', [], ...
    'selected', [], ...
    'separator', [], ...
    'segmented', [], ...
    'midline', [], ...
    'tip', [], ...
    'boundary', [], ...
    'boundary_Din', [], ...
    'boundary_Dout', [], ...
    'boundary_FMin', [], ...
    'boundary_FMout', [], ...
    'axial', [], ...
    'radial', [], ...
    'mask', [], ...
    'test', [], ...
    'white', [], ...
    'black', []);
% set up the structure arrays for all the thumbnails
handles.thumbnails = struct( ...
    'raw', [], ...
    'initial', [], ...
    'filtered',[], ...
    'subtracted', [], ...
    'segmented',[], ...
    'selected',[], ...
    'midline',[], ...
    'tip',[], ...
    'blank9',[], ...
    'blank10',[], ...
    'blank11',[]);
% reset the image selectors
set(handles.pop_display_image, 'value',1);
set(handles.pop_display_merge, 'value',1);
% reset the display options
set(handles.pop_display_image_channel, 'value',1);
set(handles.pop_display_merge_channel, 'value',1);
% reset the thumbnails
handles = fnc_thumbnail_display('clear',handles);

%-------------------------------------------------------------------------
% LOADING FUNCTIONS
%-------------------------------------------------------------------------

function handles = fnc_initial_settings(handles)
% get the size of the raw image
[handles.nY, handles.nX, handles.nC, handles.nZ, handles.nT] = size(handles.images.raw);
% find the maximum intensity (in terms of bit-depth)
if max(handles.images.raw(:)) <= 2^8
    handles.bitspersample = 8;
    handles.normalise = (2^8)-1;
elseif max(handles.images.raw(:)) <= 2^12
    handles.bitspersample = 16;
    handles.normalise = (2^12)-1;
elseif max(handles.images.raw(:)) <= 2^16
    handles.bitspersample = 16;
    handles.normalise = (2^16)-1;
end
% update the channel drop-down menus
for iC = 1:handles.nC
    set(handles.(['pop_ch' num2str(iC)]), 'String',{1:handles.nC},'Value',iC, 'enable','on');
    handles.param.(['ch' num2str(iC)]) = iC;
end
set(handles.pop_display_image_channel, 'String',{1:handles.nC}, 'enable','on');
set(handles.pop_display_merge_channel, 'String',{1:handles.nC}, 'enable','on');
handles = fnc_update_slider_limits(handles);
% set default pixel size and spacing
handles.param.pixel_size = [1 1 1];
handles.param.TimeStamps = 0:handles.nT-1;
% updating control values to reflect the raw image size and details
set(handles.txt_xy_sz, 'string',num2str(handles.param.pixel_size(1), '%4.2f'));
set(handles.txt_z_sz, 'string',num2str(handles.param.pixel_size(3), '%4.2f'));

function handles = fnc_update_slider_limits(handles)
% update the Z limits
if handles.nZ > 1
    set(handles.sld_Z, 'Min', 1, 'Max', handles.nZ, 'Value', 1, 'SliderStep', [1/(handles.nZ-1) 10/(handles.nZ-1)],'enable','on');
    set(handles.txt_Z_last, 'String', handles.nZ, 'enable','on');
    handles.expt.Z_last = handles.nZ;
else
    set(handles.sld_Z, 'Min', 1, 'Max',10, 'Value', 1,'enable','off');
    set(handles.txt_Z, 'string',1,'enable','off')
    set(handles.sld_z_ave, 'Min', 1, 'Max',10, 'Value', 1,'enable','off');
    set(handles.txt_z_ave, 'string',1,'enable','off')
end
% update the T limits
if handles.nT > 1
    set(handles.sld_T, 'Min', 1, 'Max', handles.nT, 'Value', 1, 'SliderStep', [1/(handles.nT-1) 10/(handles.nT-1)],'enable','on');
    set(handles.txt_T_last, 'String',handles.nT,'enable','on');
    handles.expt.T_last = handles.nT;
else
    set(handles.sld_T, 'Min', 1, 'Max',10, 'Value', 1,'enable','off');
    set(handles.txt_T, 'string',1,'enable','off')
    set(handles.sld_t_ave, 'Min', 1, 'Max',10, 'Value', 1,'enable','off');
    set(handles.txt_t_ave, 'string',1,'enable','off')
end
% Increments along each dimension are initially set to 1
handles.xyinc = 1;
handles.zinc = 1;
handles.tinc = 1;

function chk_Z_to_T_Callback(hObject, eventdata, handles)

function btn_update_Callback(hObject, eventdata, handles)
handles = fnc_update(handles);
guidata(gcbo, handles);
% update the thumbnails
handles.thumbnails.initial = fnc_thumbnail_make(handles.images.initial(:,:,:,1,round(handles.nT/2)), 'initial',handles);
handles = fnc_thumbnail_display('initial',handles);
% display the loaded images
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'initial')));
handles = fnc_display_image(handles);

function handles = fnc_update(handles)
% crop the raw image
handles = fnc_crop(handles);
[handles.nY,handles.nX,handles.nC,handles.nZ,handles.nT] = size(handles.images.initial);
handles = fnc_update_slider_limits(handles);
% % % % normalise the image by channel
% % % if get(handles.chk_normalise, 'Value')
% % %     for iC = 1:handles.nC
% % %         temp = handles.images.initial(1:handles.nY,1:handles.nX,iC,1:handles.nZ,1:handles.nT);
% % %         limits = stretchlim(temp(:,:,1,1,1),[0.00001 0.99999]);
% % %         handles.images.initial(1:handles.nY,1:handles.nX,iC,1:handles.nZ,1:handles.nT) = (temp-limits(1))./(limits(2)-limits(1));
% % %     end
% % % end
%check the channel order
Cidx = [handles.param.ch1 min(handles.nC,handles.param.ch2) min(handles.nC,handles.param.ch3) min(handles.nC,handles.param.ch4) min(handles.nC,handles.param.ch5)];
Cidx = Cidx(1:handles.nC);
handles.images.initial = handles.images.initial(:,:,Cidx,:,:);
% Find the number of channels, update the display pop-up menus and enable/disable the appropriate controls
handles.minnC = min(handles.nC,5);
% set(handles.pop_calib_ch, 'string',['all'; channels(1:handles.nC)])
set(handles.txt_Z, 'String', 1);
set(handles.txt_T, 'String', 1);
handles.T_inc = 1;
handles.Z_inc = 1;
set(handles.txt_T_inc,'String',handles.T_inc)
set(handles.txt_Z_inc,'String',handles.Z_inc)
set(handles.sld_white_level, 'Min', 1, 'Max', 255, 'Value', 255, 'SliderStep', [1/(255-1) 16/(255-1)]);
set(handles.txt_white_level, 'String', get(handles.sld_white_level, 'Value'));
set(handles.sld_black_level, 'Min', 0, 'Max', 255-1, 'Value', 0, 'SliderStep', [1/(255-1) 16/(255-1)]);
set(handles.txt_black_level, 'String', 0);
% Enable the controls for the next step of processing
set(handles.channel_controls(:,1:handles.minnC), 'enable','on')
set(handles.filter_controls, 'enable','on')
handles.thumbnails(1).('initial') = fnc_thumbnail_make(squeeze(handles.images.initial(:,:,1:min(3,handles.nC),1,1)), 'initial',handles);
% update the thumbnail display
handles = fnc_thumbnail_display('initial',handles);
set(handles.stt_status, 'String','Image loaded')
set(handles.stt_status,'string', 'Finished Loading Image');drawnow;

%-------------------------------------------------------------------------
% ROTATION FUNCTIONS
%-------------------------------------------------------------------------

function txt_rotation_angle_Callback(hObject, eventdata, handles)
handles.expt.rotation_angle = round(str2double(get(handles.txt_rotation_angle, 'String')));
set(handles.txt_rotation_angle, 'String',handles.expt.rotation_angle)
guidata(gcbo,handles)
fnc_param_save(handles)

function btn_rotate_Callback(hObject, eventdata, handles)
set(handles.stt_status, 'String','Image rotation'); drawnow
% display the original mage
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'raw')));
set(handles.chk_T_max,'Value',1)
handles = fnc_display_image(handles);
fnc_image_fit(handles);
% set up the rotation region
handles.rotate_ROI = fnc_setup_rotate(handles);
handles = fnc_rotate(handles);
guidata(gcbo,handles)
handles.thumbnails.initial = fnc_thumbnail_make(handles.images.rotated(:,:,:,1,round(handles.nT/2)), 'initial',handles);
handles = fnc_thumbnail_display('initial',handles);
% display the loaded images
fnc_clear_overlays(handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'rotated')));
handles = fnc_display_image(handles);

function pos = fnc_setup_rotate(handles)
% gets the rectangular ROI to crop the image
set(handles.stt_status, 'string', 'Please draw a line to represent the new vertical axis');drawnow;
axes(handles.ax_image)
hROI = drawline;
pos = customWait(hROI);
delete(hROI);
% Set up the co-ordinates to plot the region
hold on
plot(pos(:,1),pos(:,2),'y');
set(handles.stt_status, 'string', 'Alignment vector saved');drawnow;
set(gcf,'Pointer','arrow');

function handles = fnc_rotate(handles)
% get the previously set crop co-ordinates
rotate_ROI = handles.rotate_ROI;
handles.expt.rotation_angle = rad2deg(atan2(diff(rotate_ROI(:,2)),diff(rotate_ROI(:,1))))-180;
set(handles.txt_rotation_angle,'String',handles.expt.rotation_angle);
handles.images.rotated  = imrotate(handles.images.raw,handles.expt.rotation_angle, 'bilinear','loose');

function pos = customWait(hROI)
% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@clickCallback);
% Block program execution
uiwait;
% Remove listener
delete(l);
% Return the current position
pos = hROI.Position;

function clickCallback(~,evt)
if strcmp(evt.SelectionType,'double')
    uiresume;
end

%-------------------------------------------------------------------------
% CROP FUNCTIONS
%-------------------------------------------------------------------------

function txt_T_first_Callback(hObject, eventdata, handles)
handles.expt.T_first = round(str2double(get(hObject, 'String')));
guidata(hObject, handles);
fnc_param_save(handles)

function txt_Z_first_Callback(hObject, eventdata, handles)
handles.expt.Z_first = round(str2double(get(hObject, 'String')));
guidata(hObject, handles);
fnc_param_save(handles)

function txt_T_last_Callback(hObject, eventdata, handles)
handles.expt.T_last = round(str2double(get(hObject, 'String')));
guidata(hObject, handles);
fnc_param_save(handles)

function txt_Z_last_Callback(hObject, eventdata, handles)
handles.expt.Z_last = round(str2double(get(hObject, 'String')));
guidata(hObject, handles);
fnc_param_save(handles)

function chk_crop_use_Callback(hObject, eventdata, handles)
handles.expt.crop_use = get(hObject, 'Value');
guidata(hObject, handles);
fnc_param_save(handles)

function btn_crop_Callback(hObject, eventdata, handles)

handles.expt.crop_use = 1;
set(handles.chk_crop_use, 'Value',handles.expt.crop_use)
% display the raw or rotated image
set(handles.chk_display_merge, 'Value',0);
if handles.expt.rotation_angle ~= 0
    set(handles.stt_status, 'String','Calculating the rotated image. Please wait...'); drawnow
    handles.images.rotated = imrotate(handles.images.raw,handles.expt.rotation_angle,'bilinear','loose');
    set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'rotated')));
else
    set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'raw')));
end
handles = fnc_display_image(handles);
fnc_image_fit(handles);
% get the crop region
handles.expt.crop = fnc_setup_crop(handles);
set(handles.stt_status, 'string', 'Image crop co-ordinates saved');drawnow;
% save the updated parameter file
fnc_param_save(handles);
% remove the crop rectangle
fnc_clear_overlays(handles)
% crop the raw image
handles = fnc_crop(handles);
% update the handles structure
guidata(gcbo,handles)
% display the result
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'initial')));
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function pos = fnc_setup_crop(handles)
% gets the rectangular ROI to crop the image
set(handles.stt_status, 'string', 'Please define the region to be cropped');drawnow;
axes(handles.ax_image)
% if get(handles.chk_crop_square,'Value')
%     hROI = images.roi.Rectangle('AspectRatio',1,'FixedAspectRatio',true);
% else
hROI = images.roi.Rectangle('FixedAspectRatio',false);
% end
draw(hROI);
pos = customWait(hROI);
delete(hROI);
% pos = round(wait(hr));
% Set up the co-ordinates to plot the region
x = [pos(1) pos(1)+pos(3) pos(1)+pos(3) pos(1) pos(1)];
y = [pos(2) pos(2) pos(2)+pos(4) pos(2)+pos(4) pos(2)];
hold on
plot(x,y,'y');
set(gcf,'Pointer','arrow');

function handles = fnc_crop(handles)
fnc_clear_overlays(handles)
% handles = fnc_process_set_scale(handles);
% save the updated parameter file
fnc_param_save(handles);
% clears all the thumbnails except the first one
handles = fnc_thumbnail_display('setup',handles);
Z_first = handles.expt.Z_first;
Z_last = handles.expt.Z_last;
T_first = handles.expt.T_first;
T_last = handles.expt.T_last;
nC = size(handles.images.raw,3);
handles.images.initial = [];
if handles.expt.crop_use == 1
    %     if handles.expt.rotation_angle ~= 0
    %         temp = imrotate(handles.images.raw,handles.expt.rotation_angle,'bilinear','loose');
    %     else
    %         temp = handles.images.raw;
    %     end
    
    % get the previously set crop co-ordinates
    crop = handles.expt.crop;
    [~, ~, nC, ~, ~] = size(handles.images.rotated);
    handles.images.initial  = handles.images.rotated(crop(2):crop(2)+crop(4), crop(1):crop(1)+crop(3),1:nC,Z_first:Z_last,T_first:T_last);
    % update the initial thumbnail to reflect the cropped image
    handles.thumbnails.initial = fnc_thumbnail_make(handles.images.initial(:,:,:,1,1), 'initial',handles);
    handles = fnc_thumbnail_display('initial',handles);
else
    % no crop needed, just update the images
    if handles.expt.rotation_angle ~= 0
        handles.images.initial = handles.images.rotated;
    else
        handles.images.initial = handles.images.raw(:,:,1:nC,Z_first:Z_last,T_first:T_last);
    end
end
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'initial')));
handles = fnc_display_image(handles);
fnc_image_fit(handles)
class(handles.images.initial)

% -------------------------------------------------------------------------
% CONTROL SETTINGS
% -------------------------------------------------------------------------

function handles = fnc_controls_options(handles)
set(handles.stt_ch1,'String','tip')
set(handles.stt_ch2,'String','host')
set(handles.stt_ch3,'String','ch3')
set(handles.stt_ch4,'String','ch4')

handles.options.ch_colour_merge = {'green-magenta';'yellow-blue';'red-cyan';'green-red';'red-green';'RGB';'GRB';'grey'};
set(handles.pop_ch_colour_merge,'String',handles.options.ch_colour_merge)

handles.options.back_method = {'single';'frame';'field'};
set(handles.pop_back_method,'String',handles.options.back_method)

% set up the default values for variables that are not saved in the
% handles.param structure as they are data dependent
set([handles.txt_ch1_back handles.txt_ch2_back handles.txt_ch3_back handles.txt_ch4_back],'String',0);
set([handles.txt_ch1_std handles.txt_ch2_std handles.txt_ch3_std handles.txt_ch4_std],'String',0);

% set the defaults for the tip table
set(handles.uit_tip,'ColumnName',({'ID','first','last','use'}))
set(handles.uit_tip,'ColumnFormat',({'numeric','numeric','numeric','logical'}));
set(handles.uit_tip,'ColumnEditable',[false,true,true,true])
set(handles.uit_tip,'ColumnWidth',{41,61,61,41})
set(handles.uit_tip,'data',{0,0,0,false})
% filter controls
handles.options.filter_method = {'average';'median';'anisotropic';'guided'};
set(handles.pop_filter_method,'String',handles.options.filter_method)

% segment controls
handles.segment_controls = ...
    [handles.stt_segment_method, handles.pop_segment_method, ...
    handles.stt_segment_local_radius, handles.txt_segment_local_radius, ...
    handles.stt_segment_local_offset, handles.txt_segment_local_offset, ...
    handles.sld_segment_threshold, handles.txt_segment_threshold, ...
    handles.btn_segment_threshold, handles.chk_segment_threshold_auto, ...
    handles.btn_segment];
handles.options.segment_method = {'global';'adaptive';'local mean';'local median';'midgrey';'Niblack';'Bernsen';'Sauvola'};
set(handles.pop_segment_method,'String',handles.options.segment_method)
%
set(handles.pop_tip_trace_channel,'String', {0:5}, 'Value',1)
set(handles.pop_tip_spk_channel,'String', {0:5}, 'Value',1)

handles.options.spk_method = {'threshold';'template'};
set(handles.pop_spk_method,'String',handles.options.spk_method)
% image display controls
handles.options.image_names = { ...
    'raw'; ...
    'initial'; ...
    'filtered'; ...
    'resampled'; ...
    'subtracted'; ...
    'mask'; ...
    'selected'; ...
    'separator'; ...
    'segmented'; ...
    'midline'; ...
    'tip'; ...
    'boundary'; ...
    'boundary_Din'; ...
    'boundary_Dout'; ...
    'boundary_FMin'; ...
    'boundary_FMout'; ...
    'axial'; ...
    'radial'; ...
    'rotated'; ...
    'test'; ...
    'white'; ...
    'black'};
handles.options.thumbnail_names = { ...
    'raw'; ...
    'initial'; ...
    'filtered'; ...
    'subtracted'; ...
    'segmented'; ...
    'selected'; ...
    'midline'; ...
    'tip'; ...
    'blank9'; ...
    'blank10'; ...
    'blank11'};

set(handles.pop_display_image, 'String',handles.options.image_names);
set(handles.pop_display_merge, 'String',['none'; handles.options.image_names]);
set(handles.pop_display_merge_method, 'String',{'falsecolor'; 'blend'; 'diff'; 'montage'});

set(handles.pop_image_colormap, 'String',{'parula';'jet';'hsv';'cool'; ...
    'spring';'summer';'autumn';'winter';'gray';'bone';'copper';'pink'; ...
    'lines';'colorcube';'prism';'flag';'white';'L1';'L3';'L7';'L8';'L9';'D2';'D3';'D7';'R2'});
% set up the table
set(handles.tab_data,'ColumnName',{'<html><font size=3>time','<html><font size=3>amplitude', ...
    '<html><font size=3>peak offset','<html><font size=3>spread','<html><font size=3>base'})
set(handles.tab_data,'ColumnWidth',{40, 65, 65, 65, 65});
data(1:3,1) = {'  1','  2','  3'};
set(handles.tab_data,'data',data, 'visible','on')

% set the plot options
set(handles.pop_plot_x_channel,'String', {1;2;3}, 'Value',1)
set(handles.pop_plot_y_channel,'String', {1;2;3}, 'Value',1)
set(handles.pop_plot_x_T_offset,'String', {-5;-4;-3;-2;-1;0;1;2;3;4;5}, 'Value',6)
set(handles.pop_plot_y_T_offset,'String', {-5;-4;-3;-2;-1;0;1;2;3;4;5}, 'Value',6)
handles.options.plot_array = {'tip_table'};
set(handles.pop_plot_array, 'String',handles.options.plot_array);
handles.options.plot_target = {'tips'};
set(handles.pop_plot_target, 'String',handles.options.plot_target);
handles.options.plot_type = {'scatter';'1D hist';'scatter all';'1D hist all';'2D hist';'2D hist all';'time'};
set(handles.pop_plot_type, 'String',handles.options.plot_type);

handles.options.plot_units = {'pixels';'microns';'mm'};
set(handles.pop_plot_units, 'String',handles.options.plot_units);

function handles = fnc_controls_update(handles)
% channel options
set(handles.pop_ch1, 'Value',handles.param.ch1);
set(handles.pop_ch2, 'Value',handles.param.ch2);
set(handles.pop_ch3, 'Value',handles.param.ch3);
set(handles.pop_ch4, 'Value',handles.param.ch4);
% normalise and rotation
% set(handles.chk_normalise, 'Value',handles.expt.normalise);
set(handles.txt_rotation_angle, 'String',handles.expt.rotation_angle)
% image format
% set(handles.chk_crop_use, 'Value',handles.expt.crop_use);
% image dimensions
set(handles.txt_Z_first,'String',handles.expt.Z_first);
set(handles.txt_Z_last,'String',handles.expt.Z_last);
set(handles.txt_T_first,'String',handles.expt.T_first);
set(handles.txt_T_last,'String',handles.expt.T_last);
% profile options
set(handles.txt_profile_FWHM_min1,'String',handles.expt.FWHM_min1);
set(handles.txt_profile_FWHM_max1,'String',handles.expt.FWHM_max1);
set(handles.txt_profile_FWHM_min2,'String',handles.expt.FWHM_min2);
set(handles.txt_profile_FWHM_max2,'String',handles.expt.FWHM_max2);
% filter options
set(handles.pop_filter_method, 'Value', find(strcmp(get(handles.pop_filter_method, 'String'),handles.param.filter)));
set(handles.sld_xy_ave, 'Min', 1, 'Max', 15, 'value', handles.param.xy_ave, 'sliderstep', [1/7 1/7]);
set(handles.txt_xy_ave, 'String', round(get(handles.sld_xy_ave, 'Value')));
set(handles.sld_z_ave, 'Min', 1, 'Max', 15, 'value', handles.param.z_ave, 'sliderstep', [1/7 1/7]);
set(handles.txt_z_ave, 'String', round(get(handles.sld_z_ave, 'Value')));
set(handles.sld_t_ave, 'Min', 1, 'Max', 15, 'value', handles.param.t_ave, 'sliderstep', [1/7 1/7]);
set(handles.txt_t_ave, 'String', round(get(handles.sld_t_ave, 'Value')));
set(handles.sld_zoom, 'Min', 0.1, 'Max', 16, 'SliderStep', [1/(159) 1/(15.9)], 'Value', 1);
set(handles.txt_zoom, 'String', 1);
set(handles.sld_Z, 'Min', 1, 'Max', 10, 'Value', 1, 'SliderStep', [1/9 1/9]);
set(handles.txt_Z, 'String', 1);
set(handles.chk_subsample, 'Value', handles.param.subsample);

% update the tip channel parameters
set(handles.pop_tip_trace_channel, 'Value',find(strcmp(get(handles.pop_tip_trace_channel,'String'),num2str(handles.param.trace_channel))))
set(handles.pop_tip_spk_channel, 'Value',find(strcmp(get(handles.pop_tip_spk_channel,'String'),num2str(handles.param.spk_channel))))
% set(handles.txt_time_interval, 'String',handles.expt.time_interval)

% update the segmentation parameters
set(handles.chk_segment_threshold_auto, 'Value',handles.param.segment_threshold_auto);
set(handles.pop_segment_method, 'Value',find(strcmp(handles.options.segment_method,handles.param.segment_method)))
set(handles.chk_segment_auto_filter,'Value',handles.param.segment_auto_filter);
handles = fnc_segment_parameters_set(handles);

% update the filter parameters
set(handles.txt_tip_filter_noise, 'string',handles.param.filter_noise );
set(handles.txt_tip_filter_median, 'string',handles.param.filter_median);

% update the autofluorescence parameters
set(handles.pop_auto_corr_target, 'value',handles.param.auto_corr_target);
set(handles.pop_auto_corr_channel, 'value',handles.param.auto_corr_channel);

% update the trace parameters
set(handles.txt_tip_trace_distance, 'string',handles.param.tip_trace_distance);

% update the profile parameters
set(handles.txt_tip_profile_average, 'string',handles.param.tip_profile_average);

set(handles.pop_spk_method, 'Value',find(strcmp(handles.options.spk_method,handles.param.spk_method)))
set(handles.sld_spk_threshold, 'Min', 0, 'Max', 1, 'SliderStep', [1/100 1/10], 'Value', handles.param.spk_threshold);
set(handles.txt_spk_threshold, 'String',handles.param.spk_threshold);
set(handles.chk_spk_threshold_auto, 'Value',handles.param.spk_threshold_auto);
set(handles.txt_spk_size, 'string',handles.param.spk_size);

% This updates all the controls in the GUI with the values stored in the
% parameter settings or the experiment settings setup options

function handles = fnc_update_parameters(handles)
try
    [flag,message,messid] = mkdir(fullfile(handles.dir_in,'processed data'));
    [flag,message,messid] = mkdir(fullfile(handles.dir_in,'processed data','parameters'));
    [flag,message,messid] = mkdir(fullfile(handles.dir_in,'processed data','images'));
    [flag,message,messid] = mkdir(fullfile(handles.dir_in,'processed data','results'));
    [flag,message,messid] = mkdir(fullfile(handles.dir_in,'processed data','arrays'));
    handles.dir_out_parameters = fullfile(handles.dir_in,'processed data','parameters');
    handles.dir_out_images = fullfile(handles.dir_in, 'processed data','images');
    handles.dir_out_results = fullfile(handles.dir_in, 'processed data','results');
    handles.dir_out_arrays = fullfile(handles.dir_in, 'processed data','arrays');
    set(handles.stt_status, 'String', 'Directory for processed files created')
catch
    % display the error message
    set(handles.stt_status, 'String',message);
end

set(handles.stt_fname, 'String', handles.fname);
[~, name, ~] = fileparts(handles.fname);

set(handles.stt_status,'string', 'Checking for saved settings. Please wait...');drawnow;
if exist([handles.dir_out_parameters filesep name '_param.mat'], 'file')
    % start with a complete default set of parameters
    handles = fnc_parameters_default(handles);
    names_current = fieldnames(handles.param);
    % load in the saved parameter file
    fin = load([handles.dir_out_parameters filesep name '_param.mat']);
    names_saved = fieldnames(fin.parameters);
    % update any parameters that have been previously saved
    for iN = 1:numel(names_saved)
        handles.param.(names_saved{iN}) = fin.parameters.(names_saved{iN});
    end
    % remove legacy fields
    legacy = setdiff(names_saved,names_current);
    for iL = 1:numel(legacy)
        if isfield(handles.param, legacy(iL))
            handles.param = rmfield(handles.param,  legacy(iL));
        end
    end
    % reorder the fields alphabetically
    handles.param = orderfields(handles.param);
    % the parameter set is now updated
    %
    % use the complete set of default experimental values to initialise the expt array
    handles.expt = fnc_experiment_default;
    names_current = fieldnames(handles.expt);
    names_saved = fieldnames(fin.experiment);
    for iN = 1:numel(names_saved)
        handles.expt.(names_saved{iN}) = fin.experiment.(names_saved{iN});
    end
    % remove legacy fields
    legacy = setdiff(names_saved,names_current);
    for iL = 1:numel(legacy)
        if isfield(handles.expt, legacy(iL))
            handles.expt = rmfield(handles.expt,  legacy(iL));
        end
    end
    % reorder the fields alphabetically
    handles.expt = orderfields(handles.expt);
    set(handles.stt_status,'string', 'Settings file loaded');drawnow;
else
    set(handles.stt_status, 'String', 'No saved settings file....using defaults');drawnow
    handles.expt = fnc_experiment_default;
    handles = fnc_parameters_default(handles);
end
% update all the controls on the GUI to reflect the saved settings
handles = fnc_controls_update(handles);
% save the settings if a file has been selected
if isfield(handles,'fname')
    fnc_param_save(handles);
end

%--------------------------------------------------------------------------
% SETUP AND MODIFY PARAMETERS
%--------------------------------------------------------------------------

function btn_parameters_load_Callback(hObject, eventdata, handles)
[filein,path] = uigetfile('*.mat','Load saved parameters');
%[~,name,~] = fileparts(filein);
% start with the default parameters
handles = fnc_parameters_default(handles);
names_current = fieldnames(handles.param);
% load in the saved parameter file
fin = load(fullfile(path,filein), 'parameters');
names_saved = fieldnames(fin.parameters);
% update any parameters that have been previously saved
for iN = 1:numel(names_saved)
    handles.param.(names_saved{iN}) = fin.parameters.(names_saved{iN});
end
% remove legacy fields
legacy = setdiff(names_saved,names_current);
for iL = 1:numel(legacy)
    if isfield(handles.param, legacy(iL))
        handles.param = rmfield(handles.param,  legacy(iL));
    end
end
% reorder the fields alphabetically
handles.param = orderfields(handles.param);
handles = fnc_process_set_scale(handles);
guidata(gcbo,handles)
handles = fnc_controls_update(handles);
fnc_param_save(handles)

function btn_parameters_save_Callback(hObject, eventdata, handles)
[fileout,~] = uiputfile('*.mat','Save current parameters');
[~,name,~] = fileparts(fileout);
parameters = handles.param;
% save the parameters
save([name '_param.mat'], 'parameters');

function btn_parameters_edit_Callback(hObject, eventdata, handles)
handles.param = network_parameters_edit(handles.defaults, handles.param, handles.options);
guidata(gcbo,handles)
handles = fnc_controls_update(handles);
fnc_param_save(handles)

function btn_parameters_reset_Callback(hObject, eventdata, handles)
% resets all parameters to their default values
handles = fnc_parameters_default(handles);
handles = fnc_controls_update(handles);
guidata(gcbo,handles)

function handles = fnc_parameters_default(handles)
% make sure there is a complete set of default parameters

handles.param.ch1 = 1;
handles.param.ch2 = 1;
handles.param.ch3 = 1;
handles.param.ch4 = 1;
handles.param.ch5 = 1;

% filtering
handles.param.filter = 'median';
handles.param.xy_ave = 3;
handles.param.t_ave = 1;
handles.param.z_ave = 1;
handles.param.subsample = 0;
handles.param.filter_tophat_use = 1;
% background subtraction
handles.param.back_method = 'frame';
handles.param.chk_back1 = 1;
handles.param.chk_back2 = 1;
handles.param.chk_back3 = 1;
handles.param.chk_back4 = 1;
handles.param.chk_back5 = 1;
% autofluorescence correction
handles.param.chk_auto_corr = 1;
handles.param.auto_corr = 0.12;
handles.param.auto_corr_target = 1;
handles.param.auto_corr_channel = 2;
% tip channel
handles.param.trace_channel = 1;
handles.param.spk_channel = 1;
% tip segmentation
handles.param.segment_method = 'Niblack';
handles.param.segment_threshold_auto = 1;
handles.param.global_threshold = 0.25;
handles.param.local_radius_mean = 20;
handles.param.local_offset_mean = 0;
handles.param.local_radius_median = 20;
handles.param.local_offset_median = 0;
handles.param.local_radius_midgrey = 20;
handles.param.local_offset_midgrey = 0;
handles.param.local_radius_Niblack = 25;
handles.param.local_offset_Niblack = 0;
handles.param.local_radius_Bernsen = 20;
handles.param.local_offset_Bernsen = 0;
handles.param.local_radius_Sauvola = 20;
handles.param.local_offset_Sauvola = 0.5;
handles.param.segment_auto_filter = 1;
% tip smoothing
handles.param.filter_noise = 7;
handles.param.filter_median = 5;
% tip trace
handles.param.tip_trace_distance = 30;
% tip profile
handles.param.tip_profile_method = 'normals';
handles.param.tip_profile_average = 2;
% spitzenkorper detection
handles.param.spk_method = 'template';
handles.param.spk_threshold = 0.25;
handles.param.spk_threshold_auto = 1;
handles.param.spk_size = 9;
% set up default parameter list from the above
handles.defaults = handles.param;
guidata(gcf, handles);

function fnc_param_save(handles)
% if isfield(handles,'fname')
%     % set the output directory and filename
%     [pathstr, name, ext] = fileparts(handles.fname{1});
%     directory = handles.dir_out_parameters;
%     filename = handles.fname{1};
%     % collect the parameters and experimental variables
%     parameters = handles.param;
% %     experiment = handles.expt;
% %     % check for binary images
% %     if isfield(handles,'images')
% %         images.mask_edited = handles.images.mask_edited;
% %         images.cisterna_edited = handles.images.cisterna_edited;
% %         images.skeleton_edited = handles.images.skeleton_edited;
% %     else
% %         images = [];
% %     end
%     % save all the parameters and settings
%     save([handles.dir_out_parameters filesep name '_param.mat'], 'directory','filename','parameters','experiment','images');
%     set(handles.stt_status, 'String', 'Parameter file saved...');
% end

% -------------------------------------------------------------------------
% EXPERIMENT DEFAULTS
% -------------------------------------------------------------------------

function expt = fnc_experiment_default
% This sets all the variables that are unique to an individual experiment
% rather than a set of processing parameters.
% expt.normalise = 1;
expt.rotation_angle = 0;

expt.Z_first = 1;
expt.Z_last = 1;
expt.T_first = 1;
expt.T_last = 1;

expt.crop_use = 0;

expt.time = 1;
expt.global_threshold = 0;

expt.FWHM_min1 = 5;
expt.FWHM_max1 = 25;
expt.FWHM_min2 = 5;
expt.FWHM_max2 = 35;

%--------------------------------------------------------------------------
% DEFINE THE CHANNELS
% As the data is not collected with the channels in a particular order,
% the channel identity has to be defined to match the parameter measured
%--------------------------------------------------------------------------

function pop_ch1_Callback(hObject, eventdata, handles)
handles.param.ch1 = get(handles.pop_ch1, 'Value');
guidata(gcbo, handles);
fnc_display_image(handles);

function pop_ch2_Callback(hObject, eventdata, handles)
handles.param.ch2 = get(handles.pop_ch2, 'Value');
guidata(gcbo, handles);
fnc_display_image(handles);

function pop_ch3_Callback(hObject, eventdata, handles)
handles.param.ch3 = get(handles.pop_ch3, 'Value');
guidata(gcbo, handles);
fnc_display_image(handles);

function pop_ch4_Callback(hObject, eventdata, handles)
handles.param.ch4 = get(handles.pop_ch4, 'Value');
guidata(gcbo, handles);
fnc_display_image(handles);

function pop_ch_colour_merge_Callback(hObject, eventdata, handles)
options = get(hObject, 'String');
options_idx = get(hObject,'Value');
handles.param.ch_colour_merge = options{options_idx};
guidata(gcbo, handles);
fnc_display_image(handles);

% -------------------------------------------------------------------------
% LINE PROFILE
% -------------------------------------------------------------------------

function txt_profile_FWHM_R_Callback(hObject, eventdata, handles)
function txt_profile_FWHM_G_Callback(hObject, eventdata, handles)
function txt_profile_FWHM_B_Callback(hObject, eventdata, handles)
function txt_profile_FWHM_peak_R_Callback(hObject, eventdata, handles)
function txt_profile_FWHM_peak_G_Callback(hObject, eventdata, handles)
function txt_profile_FWHM_peak_B_Callback(hObject, eventdata, handles)

function pop_profile_units_Callback(hObject, eventdata, handles)
options = get(handles.pop_profile_units, 'string');
options_idx = get(handles.pop_profile_units, 'value');
units = options{options_idx};
channels = ['R';'G';'B'];
for iC = 1:length(handles.expt.FWHM)
    switch units
        case 'pixels'
            set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(handles.expt.FWHM(iC), '%4.2f'))
        case 'nm'
            set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(round(1000.*handles.expt.FWHM(iC).*handles.param.resample.*handles.expt.micron_per_pixel,3,'significant')))
        case 'microns'
            set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(round(handles.expt.FWHM(iC).*handles.param.resample.*handles.expt.micron_per_pixel,3,'significant')))
        case 'mm'
            set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(round(handles.expt.FWHM(iC).*handles.param.resample.*handles.expt.micron_per_pixel./1000,3,'significant')))
    end
end

function txt_time_Callback(hObject, eventdata, handles)
handles.expt.time = str2double(get(hObject,'String'));
guidata(hObject, handles);
fnc_param_save(handles)

function txt_micron_per_pix_Callback(hObject, eventdata, handles)
handles.expt.micron_per_pixel = str2double(get(hObject,'String'));
guidata(hObject, handles);
fnc_param_save(handles)

function btn_calibration_Callback(hObject, eventdata, handles)
set(handles.pop_profile_units,'Enable','on')
handles = fnc_calibration(handles);
guidata(gcbo, handles);

function handles = fnc_calibration(handles)
% prompts for two input points and the distance in mm between them
set(handles.stt_status, 'string','Please select a calibration distance');
hl = imline(handles.ax_image);
pos = wait(hl);
resume(hl)
dist = inputdlg('calibration length (mm)');
delete(hl);
handles.expt.micron_per_pixel = 1000.*str2double(dist{1})/sqrt((pos(1,1)-pos(2,1))^2 + (pos(1,2)-pos(2,2))^2);
set(handles.stt_status, 'string',['The calibration is ' num2str(handles.expt.micron_per_pixel, '%4.2f') ' µm per pixel']);
set(handles.txt_micron_per_pix, 'string', num2str(handles.expt.micron_per_pixel, '%4.2f'));

function txt_profile_FWHM_min1_Callback(hObject, eventdata, handles)
handles = fnc_process_set_scale(handles);
guidata(hObject, handles);
fnc_param_save(handles)

function txt_profile_FWHM_max1_Callback(hObject, eventdata, handles)
handles = fnc_process_set_scale(handles);
guidata(hObject, handles);
fnc_param_save(handles)

function txt_profile_FWHM_min2_Callback(hObject, eventdata, handles)
handles = fnc_process_set_scale(handles);
guidata(hObject, handles);
fnc_param_save(handles)

function txt_profile_FWHM_max2_Callback(hObject, eventdata, handles)
handles = fnc_process_set_scale(handles);
guidata(hObject, handles);
fnc_param_save(handles)

function btn_profile_Callback(hObject, eventdata, handles)
handles = fnc_profile(handles);
guidata(hObject, handles);

function handles = fnc_profile(handles)
options = get(handles.pop_profile_units, 'string');
options_idx = get(handles.pop_profile_units, 'value');
units = options{options_idx};
scaling = get(handles.sld_white_level, 'Value');
% ---
set(handles.stt_status,'String','Please draw a profile over a feature of interest');
fnc_clear_overlays(handles)
% clear the text boxes
channels = ['R','G','B'];
for iC = 1:3
    set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(0, '%4.2f'));
    set(eval(['handles.txt_profile_FWHM_peak_' channels(iC) ]), 'string', num2str(0, '%4.2f'));
end
% get the profile
axes(handles.ax_image)
[~, ~, lv] = improfile;
% compress the values to a n x 1-3 array
lv = squeeze(lv).*scaling;
nC = size(lv,2);
% find the approximate size from the approximate 50% threshold
slv = double(sort(lv,1,'ascend'));% sort the intensity values
% use the top and bottom values and take the 50% threshold
low = slv(1,:);
high = slv(end,:);
th = (high-low)./2 + low;
% construct an interpolated curve
x = double(1:length(slv))';
xi = double(1:0.1:length(slv))';
y = interp1(x,lv,xi,'pchip');
% now plot the result
axes(handles.axes_profile_plot)
gcolors = ['m','g','b'];
cla
hold off
handles.expt.FWHM = zeros(1,nC);
for iC = 1:nC
    plot(x,lv(:,iC), 'color',gcolors(iC),'marker','.')
    % find when the curve passes the 50% threshold
    hold on
    idx1 = find(y(:,iC)>th(iC),1,'first');
    idx2 = find(y(:,iC)>th(iC),1,'last');
    if idx1 ~= idx2
        line([xi(idx1) xi(idx1)],ylim, 'linestyle',':','color',gcolors(iC))
        line([xi(idx2) xi(idx2)],ylim, 'linestyle',':','color',gcolors(iC))
        handles.expt.FWHM(iC) = xi(idx2)-xi(idx1);
    else
        handles.expt.FWHM(iC) = 0;
    end
    switch units
        case 'pixels'
            set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(handles.expt.FWHM(iC), '%4.2f'))
        case 'nm'
            set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(round(1000.*handles.expt.FWHM(iC).*handles.param.resample.*handles.expt.micron_per_pixel,3,'significant')))
        case 'microns'
            set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(round(handles.expt.FWHM(iC).*handles.param.resample.*handles.expt.micron_per_pixel,3,'significant')))
        case 'mm'
            set(eval(['handles.txt_profile_FWHM_' channels(iC)]), 'string', num2str(round(handles.expt.FWHM(iC).*handles.param.resample.*handles.expt.micron_per_pixel./1000,3,'significant')))
    end
    set(eval(['handles.txt_profile_FWHM_peak_' channels(iC)]), 'string', num2str(round(slv(end,iC),3,'significant')))
end
set(handles.stt_status,'String','Displaying profile plot');drawnow;

%-------------------------------------------------------------------------
% SET SCALE BASED ON FWHM
%-------------------------------------------------------------------------

function handles = fnc_process_set_scale(handles)
handles.expt.FWHM_min1 = str2double(get(handles.txt_profile_FWHM_min1, 'String'));
handles.expt.FWHM_max1 = str2double(get(handles.txt_profile_FWHM_max1, 'String'));
handles.expt.FWHM_min2 = str2double(get(handles.txt_profile_FWHM_min2, 'String'));
handles.expt.FWHM_max2 = str2double(get(handles.txt_profile_FWHM_max2, 'String'));
% update the scale-dependent parameters

% --------------------------------------------------------------------------
% XY AVERAGE
% --------------------------------------------------------------------------

function txt_xy_sz_Callback(hObject, eventdata, handles)

function txt_z_sz_Callback(hObject, eventdata, handles)

function sld_xy_ave_Callback(hObject, eventdata, handles)
handles.param.xy_ave = round(get(hObject, 'Value'));
set(handles.txt_xy_ave, 'String', handles.param.xy_ave);
set(handles.sld_xy_ave, 'Value', handles.param.xy_ave);
guidata(gcbo, handles);

function txt_xy_ave_Callback(hObject, eventdata, handles)
handles.param.xy.ave = round(str2double(get(hObject, 'String')));
set(handles.txt_xy_ave, 'Value', handles.param.xy_ave);
set(handles.sld_xy_ave, 'Value', handles.param.xy.ave);
guidata(gcbo, handles);

function sld_z_ave_Callback(hObject, eventdata, handles)
handles.param.z_ave = round(get(hObject, 'Value'));
set(handles.txt_z_ave, 'String', handles.param.z_ave);
set(handles.sld_z_ave, 'Value', handles.param.z_ave);
guidata(gcbo, handles);

function txt_z_ave_Callback(hObject, eventdata, handles)
handles.param.z_ave = round(str2double(get(hObject, 'String')));
set(handles.txt_z_ave, 'Value', handles.param.z_ave);
set(handles.sld_z_ave, 'Value', handles.param.z_ave);
guidata(gcbo, handles);

function sld_t_ave_Callback(hObject, eventdata, handles)
handles.param.t_ave = round(get(hObject, 'Value'));
set(handles.txt_t_ave, 'String', handles.param.t_ave);
set(handles.sld_t_ave, 'Value', handles.param.t_ave);
guidata(gcbo, handles);

function txt_t_ave_Callback(hObject, eventdata, handles)
handles.param.t_ave = round(str2double(get(hObject, 'String')));
set(handles.txt_t_ave, 'Value', handles.param.t_ave);
set(handles.sld_t_ave, 'Value', handles.param.t_ave);
guidata(gcbo, handles);

function chk_subsample_Callback(hObject, eventdata, handles)
handles.param.subsample = get(hObject, 'value');
guidata(hObject, handles);

function pop_filter_method_Callback(hObject, eventdata, handles)
options = get(handles.pop_filter_method, 'string');
options_idx = get(handles.pop_filter_method, 'value');
handles.param.filter = options{options_idx};
guidata(hObject, handles);

function chk_filter_tophat_Callback(hObject, eventdata, handles)
handles.param.filter_tophat_use = get(hObject, 'value');
guidata(hObject, handles);

function btn_filter_Callback(hObject, eventdata, handles)
% Clear subsequent images
handles.images.filtered = [];
handles.images.subtracted = [];
% Get the type of filter
options = get(handles.pop_filter_method, 'String');
pop_index = get(handles.pop_filter_method, 'Value');
handles.param.filter = options{pop_index};
% Check to see if sub-sampling is required and adjust the size of the image
% dimensions accordingly
if handles.param.subsample == 1
    handles.xyinc = 1+floor(handles.param.xy_ave/2);
    handles.zinc  = 1+floor(handles.param.z_ave/2);
    handles.tinc  = 1+floor(handles.param.t_ave/2);
    if handles.xyinc > 1
        handles.newnX = round(handles.nX/handles.xyinc);
        handles.newnY = round(handles.nY/handles.xyinc);
    else
        handles.newnX = handles.nX;
        handles.newnY = handles.nY;
    end
    if handles.zinc > 1
        handles.newnZ = round(handles.nZ/handles.zinc);
    else
        handles.newnZ = handles.nZ;
    end
    handles.newnT = round(handles.nT/handles.tinc);
    handles.param.xy_cal = handles.param.pixel_size(1).*handles.xyinc;
    handles.param.z_cal = handles.param.pixel_size(3).*handles.zinc;
    set(handles.txt_xy_sz, 'string',num2str(handles.param.xy_cal, '%4.2f'));
    set(handles.txt_z_sz, 'string',num2str(handles.param.z_cal, '%4.2f'));
    %    handles.param.t_cal = handles.param.TimeStamps(1:handles.tinc:handles.newnT);
else
    handles.xyinc = 1;
    handles.zinc = 1;
    handles.tinc = 1;
    handles.newnX = handles.nX;
    handles.newnY = handles.nY;
    handles.newnZ = handles.nZ;
    handles.newnT = handles.nT;
    handles.param.xy_cal = handles.param.pixel_size(1);
    %    handles.param.z_cal = handles.param.pixel_size(3);
    set(handles.txt_xy_sz, 'string',num2str(handles.param.xy_cal, '%4.2f'));
    %    set(handles.txt_z_sz, 'string',num2str(handles.param.z_cal, '%4.2f'));
    handles.param.t_cal = handles.param.TimeStamps;
end
% Set up the size for the filtered image depending on sub-sampling
handles.images.filtered = zeros(handles.newnY, handles.newnX, handles.nC, handles.newnZ, handles.newnT, 'like',handles.images.initial);
guidata(gcbo, handles);
% Update the sliders to reflect the new size in Z and T.
fnc_set_slider_limits(handles.sld_Z, 1, handles.newnZ, 1, handles.txt_Z);
fnc_set_slider_limits(handles.sld_T, 1, handles.newnT, 1, handles.txt_T);
% Apply the selected filter
xyk = handles.param.xy_ave;% xy kernel size
zk  = handles.param.z_ave; % z kernel size
tk  = handles.param.t_ave; % t kernel size
ss  = handles.param.subsample; % subsampling toggle
% apply a mean or median filter
switch handles.param.filter
    case {'average';'anisotropic';'guided';'Wiener'}
        handles.images.filtered = fnc_nD_average(handles.images.initial,xyk,zk,tk,ss,handles);
    case 'median'
        handles.images.filtered = fnc_nD_median(handles.images.initial,xyk,zk,tk,ss,handles);
end
% if handles.param.filter_tophat_use
%     for iC = 1:2
%         r = round(handles.expt.(['FWHM_max' num2str(iC)])/2);
%         handles.images.filtered(:,:,iC,:,:) = imtophat(handles.images.filtered(:,:,iC,:,:),strel('disk',r));
%     end
% end
% set up the initial totals output array
handles.totals = repmat(single(0),[handles.newnT handles.minnC handles.newnZ 7 1]);
tempinitial = mean(mean(handles.images.initial(:,:,:,1:handles.zinc:handles.nZ,1:handles.tinc:handles.nT), 1),2);
tempfilt = mean(mean(handles.images.filtered(:,:,1:handles.minnC,:,:), 1),2);
handles.totals(1:handles.newnT,1:handles.minnC,1:handles.newnZ,1,1) = reshape(permute(tempinitial,[5 4 3 2 1]), handles.newnT, handles.minnC, handles.newnZ) ;
handles.totals(1:handles.newnT,1:handles.minnC,1:handles.newnZ,2,1) = reshape(permute(tempfilt,[5 4 3 2 1]), handles.newnT, handles.minnC, handles.newnZ);
guidata(gcbo, handles);

% update the thumbnails
handles.thumbnails.filtered = fnc_thumbnail_make(handles.images.filtered(:,:,:,1,round(handles.nT/2)), 'filtered',handles);
handles = fnc_thumbnail_display('filtered',handles);
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'filtered')));
handles = fnc_display_image(handles);
set(handles.stt_status,'string', 'Filtering complete');drawnow;
set(handles.controls(3), 'enable','on');
set(handles.controls(4:5), 'enable','off');
if handles.nC == 5
    set(handles.autoflr_controls, 'enable', 'on');
end
set(handles.back_controls, 'enable','on')
set(handles.back_sub_controls(:,1:handles.minnC), 'enable','on')

function filtered = fnc_nD_median(im,xyksz,zksz,tksz,ss,handles)
%
% xyk    xy kernel size, odd numbered only
% zk     z kernel size
% tk     time kernel size
% ss     0 or 1, include subsample
%
% % % % Median filtering can stay in interger format
% % % switch class(im)
% % %     case 'uint8'
% % %         filtered = repmat(uint8(0),[handles.newnY handles.newnX handles.nC handles.newnZ handles.newnT]);
% % %     case 'uint16'
% % %         filtered = repmat(uint16(0),[handles.newnY handles.newnX handles.nC handles.newnZ handles.newnT]);
% % % end
if zksz == 1 && tksz == 1 % only 2D median required, so can use medfilt2 with only an x y intermediate image
    temp = zeros(handles.newnY, handles.newnX,'like',im);
    xykoff = xyksz;
    zkoff = zksz;
    tkoff = tksz;
else
    % kernel sizes are now used as minus to plus offsets around
    % the chosen pixel. i.e. a kernel size of 3 become ±1.
    xykoff = round((xyksz-1)./2);
    zkoff = round((zksz-1)./2);
    tkoff = round((tksz-1)./2);
    % need a full array to sample in xyz and t and to pad the array bigger to allow calculation of the median
    % for the edge pixels
    temp = padarray(im,[xykoff xykoff 0 zkoff tkoff],'both','replicate');
end
for iC = 1:handles.nC %operate on each channel separately
    % reset the index along each dimension
    Tidx = 0;
    for iT = 1:handles.tinc:handles.nT % only perform the calculation on the centre pixels in each kernel that will be retained
        set(handles.stt_status,'string', ['Calculating filtered images for frame : ' num2str(iT) '. Please wait.....']);drawnow;
        Tm = iT+tkoff;% offset start point to skip padded boundary
        Tidx = Tidx+1;% time index for sub-sampled image, skipping the sub-sampling interval
        Zidx = 0;% reset the z-index
        for iZ = 1:handles.zinc:handles.nZ
            Zidx = Zidx+1;% z index for sub-sampled image
            if zksz == 1 && tksz == 1 % 2D image so can use medfilt2
                if xyksz == 1
                    % just re-order the channels
                    temp = im(:,:,iC,iZ,iT);
                else
                    % 2D median filter and re-order the channels
                    temp = medfilt2(im(:,:,iC,iZ,iT), [xyksz xyksz]);
                end
                if ss % need to subsample
                    filtered(1:handles.newnY,1:handles.newnX,iC,Zidx,Tidx) = imresize(temp,[handles.newnY handles.newnX]);
                else
                    filtered(1:handles.newnY,1:handles.newnX,iC,Zidx,Tidx) = temp;
                end
            else
                % this will be slow as the region around every pixel has to
                % be extracted and processed separately
                %
                Zm = iZ+zkoff;% offset start point to skip padded boundary
                Xidx = 0; % reset the X index
                for iX = 1:handles.xyinc:handles.nX% only perform the calculation on the centre pixels in each kernel that will be retained
                    Xidx = Xidx+1;% x index for sub-sampled image
                    Xm = iX+xykoff;% offset start point to skip padded boundary
                    Yidx = 0; %reset the Y index
                    for iY = 1:handles.xyinc:handles.nY
                        Ym = iY+xykoff;% offset start point to skip padded boundary
                        ROI = temp(Ym-xykoff:Ym+xykoff, Xm-xykoff:Xm+xykoff, Ch, Zm-zkoff:Zm+zkoff, Tm-tkoff:Tm+tkoff);% get the region around the pixel of interest
                        V = median(ROI(:));%linearise and get the median
                        if ss
                            Yidx = Yidx+1;% y index for sub-sampled image
                            filtered(Yidx,Xidx,iC,Zidx,Tidx) = V;%subsample the median image
                        else
                            filtered(iY,iX,iC,iZ,iT) = V;
                        end
                    end
                end
            end
        end
    end
end

function filtered = fnc_nD_average(im,xyksz,zksz,tksz,ss,handles)
% mean filter for nD image
% process separately in x,y,z and time to reduce the space needed for the intermediate images
%
% xyksz    xy kernel size
% zksz     z kernel size
% tksz     t kernel size
% ss       sub-sampling on or off
%
method = handles.param.filter;
% construct separate filters for imfilter in xy, z and t.
xyk = ones([xyksz xyksz])./(xyksz.*xyksz);
zk = ones([1 1 1 zksz])./(zksz);
tk = ones([1 1 1 1 tksz])./(tksz);
% filter images separately in x,y,z and time to reduce the space needed for the intermediate images
temp1 = zeros(handles.nY, handles.nX, handles.nC,'like',im);
temp2 = zeros(handles.newnY, handles.newnX, handles.nC, handles.nZ, handles.nT, 'like',im);
for iT = 1:handles.nT % loop through each time point
    set(handles.stt_status,'string', ['Calculating xy filtered images for frame : ' num2str(iT) ' . Please wait.....']);drawnow;
    for iZ = 1:handles.nZ % loop through each z plane
        for iC = 1:handles.nC % loop through each channel
            if xyksz > 1
                switch method
                    case 'average'
                        temp1(1:handles.nY,1:handles.nX,iC) = imfilter(im(:,:,iC,iZ,iT),xyk, 'replicate');
                    case 'Wiener'
                        temp1(1:handles.nY,1:handles.nX,iC) = wiener2(im(:,:,iC,iZ,iT),[xyksz xyksz]);
                    case 'anisotropic'
                        [gradientThreshold,numberOfIterations] = imdiffuseest(im(:,:,iC,iZ,iT));
                        temp1(1:handles.nY,1:handles.nX,iC) = imdiffusefilt(im(:,:,iC,iZ,iT),'gradientThreshold',gradientThreshold,'numberOfIterations',numberOfIterations);
                    case 'guided'
                        temp1(1:handles.nY,1:handles.nX,iC) = imguidedfilter(im(:,:,iC,iZ,iT),im(:,:,iC,iZ,iT),'NeighborhoodSize',[xyksz xyksz]);
                end
            else
                temp1(1:handles.nY,1:handles.nX,iC) = im(:,:,iC,iZ,iT);
            end
        end
        if ss % use imresize to sub-sample the image in x and y
            temp2(1:handles.newnY,1:handles.newnX,1:handles.nC,iZ,iT) = imresize(temp1(:,:,:),[handles.newnY, handles.newnX]);
        else
            temp2(1:handles.newnY,1:handles.newnX,1:handles.nC,iZ,iT) = temp1;
        end
    end
end
if zksz > 1 % need to average in z
    set(handles.stt_status,'string', 'Calculating z filtered images. Please wait.....');drawnow;
    temp2 = imfilter(temp2,zk,'replicate');
    if ss
        % sample the filtered planes at intervals
        temp2(1:handles.newnY,1:handles.newnX,1:handles.nC,1:handles.newnZ,1:handles.newnT) = temp2(1:handles.newnY,1:handles.newnX,1:handles.nC,1:handles.zinc:handles.nZ,1:handles.newnT);
        % delete the excess planes
        temp2(:,:,:,handles.newnZ+1:handles.nZ,:) = [];
    end
end
if tksz > 1 % need to average in time
    set(handles.stt_status,'string', 'Calculating time filtered images. Please wait.....');drawnow;
    temp2 = imfilter(temp2,tk,'replicate');
    if ss
        % sample the filtered stacks at intervals
        temp2(1:handles.newnY,1:handles.newnX,1:handles.nC,1:handles.newnZ,1:handles.newnT) = temp2(1:handles.newnY,1:handles.newnX,1:handles.nC,1:handles.newnZ,1:handles.tinc:handles.nT);
        % delete the excess stacks
        temp2(:,:,:,:,handles.newnT+1:handles.nT) = [];
    end
end
filtered = temp2;

%--------------------------------------------------------------------------
% MEASURE THE AVERAGE BACKGROUND INTENSITY
%--------------------------------------------------------------------------

function btn_back_measure_Callback(hObject, eventdata, handles)
set(handles.stt_status, 'string', 'Please define the region for background estimation');drawnow;
iT = get(handles.sld_T, 'value');
iZ = get(handles.sld_Z, 'value');
set(gcf,'Pointer','crosshair');
axes(handles.ax_image)
h = findobj(gca,'type','line');
delete(h);
hr = imrect;
pos = round(wait(hr));
% Set up the co-ordinates to plot the region
point1 = [pos(1) pos(2)];
point2 = [pos(1)+pos(3) pos(2)+pos(4)];
resume(hr);
delete(hr);
set(gcf,'Pointer','arrow')
handles.p1 = uint16(min(point1,point2));             % calculate locations
handles.offset = uint16(abs(point1-point2));         % and dimensions
x = [handles.p1(1) handles.p1(1)+handles.offset(1) handles.p1(1)+handles.offset(1) handles.p1(1) handles.p1(1)];
y = [handles.p1(2) handles.p1(2) handles.p1(2)+handles.offset(2) handles.p1(2)+handles.offset(2) handles.p1(2)];
axes(handles.ax_image)
hold on
axis manual
plot(x,y,'y');
for iC = 1:handles.nC
    handles.param.back(iC) = mean2(handles.images.filtered(handles.p1(2):handles.p1(2)+handles.offset(2), handles.p1(1):handles.p1(1)+handles.offset(1),iC,iZ,iT));
    handles.param.back_std(iC) = std2(handles.images.filtered(handles.p1(2):handles.p1(2)+handles.offset(2), handles.p1(1):handles.p1(1)+handles.offset(1),iC,iZ,iT));
    set(handles.(['txt_ch' num2str(iC) '_back']), 'String',num2str(handles.param.back(iC), '%4.2f'));
    set(handles.(['txt_ch' num2str(iC) '_std']), 'String',num2str(handles.param.back_std(iC), '%4.2f'));
end
set(gcf,'Pointer','arrow')
guidata(gcbo, handles);

set(handles.btn_auto_corr, 'visible','on')
set(handles.controls(4:5), 'enable','on');

function txt_ch1_back_Callback(hObject, eventdata, handles)
handles.param.back(1) = str2double(get(handles.txt_ch1_back, 'string'));
guidata(gcbo, handles);

function txt_ch2_back_Callback(hObject, eventdata, handles)
handles.param.back(2) = str2double(get(handles.txt_ch2_back, 'string'));
guidata(gcbo, handles);

function txt_ch3_back_Callback(hObject, eventdata, handles)
handles.param.back(3) = str2double(get(handles.txt_ch3_back, 'string'));
guidata(gcbo, handles);

function txt_ch4_back_Callback(hObject, eventdata, handles)
handles.param.back(4) = str2double(get(handles.txt_ch4_back, 'string'));
guidata(gcbo, handles);

function txt_ch5_back_Callback(hObject, eventdata, handles)
handles.param.back(5) = str2double(get(handles.txt_ch5_back, 'string'));
guidata(gcbo, handles);

function txt_ch1_std_Callback(hObject, eventdata, handles)
handles.param.back_std(1) = str2double(get(handles.txt_ch1_std, 'string'));
handles.param.back_n_std(1) = fnc_sd(1, handles);
guidata(gcbo, handles);

function txt_ch2_std_Callback(hObject, eventdata, handles)
handles.param.back_std(2) = str2double(get(handles.txt_ch2_std, 'string'));
handles.param.back_n_std(2) = fnc_sd(2, handles);
guidata(gcbo, handles);

function txt_ch3_std_Callback(hObject, eventdata, handles)
handles.param.back_std(3) = str2double(get(handles.txt_ch3_std, 'string'));
handles.param.back_n_std(3) = fnc_sd(3, handles);
guidata(gcbo, handles);

function txt_ch4_std_Callback(hObject, eventdata, handles)
handles.param.back_std(4) = str2double(get(handles.txt_ch4_std, 'string'));
handles.param.back_n_std(4) = fnc_sd(4, handles);
guidata(gcbo, handles);

function txt_ch5_std_Callback(hObject, eventdata, handles)
handles.param.back_std(5) = str2double(get(handles.txt_ch5_std, 'string'));
handles.param.back_n_std(5) = fnc_sd(5, handles);
guidata(gcbo, handles);

function pop_ch1_std_thresh_Callback(hObject, eventdata, handles)
handles.param.back_n_std(1) = fnc_sd(1, handles);
guidata(gcbo, handles);

function pop_ch2_std_thresh_Callback(hObject, eventdata, handles)
handles.param.back_n_std(2) = fnc_sd(2, handles);
guidata(gcbo, handles);

function pop_ch3_std_thresh_Callback(hObject, eventdata, handles)
handles.param.back_n_std(3) = fnc_sd(3, handles);
guidata(gcbo, handles);

function pop_ch4_std_thresh_Callback(hObject, eventdata, handles)
handles.param.back_n_std(4) = fnc_sd(4, handles);
guidata(gcbo, handles);

function chk_ch1_back_Callback(hObject, eventdata, handles)
handles.param.chk_back(1) = get(hObject, 'Value');
guidata(gcbo, handles);

function chk_ch2_back_Callback(hObject, eventdata, handles)
handles.param.chk_back(2) = get(hObject, 'Value');
guidata(gcbo, handles);

function chk_ch3_back_Callback(hObject, eventdata, handles)
handles.param.chk_back(3) = get(hObject, 'Value');
guidata(gcbo, handles);

function chk_ch4_back_Callback(hObject, eventdata, handles)
handles.param.chk_back(4) = get(hObject, 'Value');
guidata(gcbo, handles);

function chk_ch5_back_Callback(hObject, eventdata, handles)
handles.param.chk_back(5) = get(hObject, 'Value');
guidata(gcbo, handles);

function pop_back_method_Callback(hObject, eventdata, handles)
options = get(handles.pop_back_method, 'String');
pop_index = get(handles.pop_back_method, 'Value');
handles.param.back_method = options{pop_index};
guidata(gcbo, handles);

function btn_back_sub_Callback(hObject, eventdata, handles)
handles = fnc_background_subtract(handles);
guidata(hObject, handles);
% update the thumbnails
handles.thumbnails.subtracted = fnc_thumbnail_make(handles.images.subtracted(:,:,:,1,round(handles.nT/2)), 'subtracted',handles);
handles = fnc_thumbnail_display('subtracted',handles);
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'subtracted')));
handles = fnc_display_image(handles);
set(handles.segment_controls, 'enable','on')
handles = fnc_segment_method(handles);
guidata(gcbo, handles);
% clear the axes
h = findobj(gcf, 'Type','line','color','k','linestyle',':');
delete(h)

function handles = fnc_background_subtract(handles)
% pre-allocate the background subtracted array
handles.images.subtracted = zeros(handles.newnY, handles.newnX, handles.nC, handles.newnZ, handles.newnT,'like',handles.images.filtered);
% get the parameters
options = get(handles.pop_back_method, 'String');
pop_index = get(handles.pop_back_method, 'Value');
handles.back_method = options{pop_index};
iZ = get(handles.sld_Z, 'value');
options = get(handles.pop_auto_corr_target, 'String');
pop_index = get(handles.pop_auto_corr_target, 'Value');
handles.auto_ch = str2double(options{pop_index});
handles.frame_back = [];
% calculate the background subtracted images
% % % % the vectorised version
% % % set(handles.stt_status, 'string', 'calculating the background subtraction. Please wait...');drawnow;
% % % back_idx = logical(handles.param.chk_back(1:handles.nC));
% % % % offset_idx = logical(handles.param.chk_offset(1:handles.nC));
% % % switch handles.back_method
% % %     case 'single' %subtract a single measured value
% % %         handles.backT = zeros(1,1,handles.nC,1,1);
% % %         handles.backT(1,1,back_idx,1,1) =  handles.param.back(back_idx);
% % % %         handles.backT(1,1,offset_idx,1,1) =  handles.param.offset(offset_idx);
% % %         handles.stdT(1,1,back_idx,1,1) =  handles.param.back_std(back_idx);
% % %     case 'frame' % subtract a measured value from each frame
% % %         handles.backT = zeros(1, 1, handles.nC, 1, handles.nT);
% % %         handles.stdT = zeros(1, 1, handles.nC, 1, handles.nT);
% % %         ROI = handles.images.filtered(handles.p1(2):handles.p1(2)+handles.offset(2), handles.p1(1):handles.p1(1)+handles.offset(1),1:handles.nC,iZ,1:handles.newnT);
% % %         ROI = reshape(ROI,[(handles.offset(1)+1).*(handles.offset(2)+1),1,handles.nC,1,handles.newnT]);
% % %         handles.backT(1,1,1:handles.nC,1,1:handles.newnT) = mean(ROI,1);
% % %         handles.stdT(1,1,1:handles.nC,1,1:handles.newnT) = std(ROI,1);
% % % %         handles.backT(1,1,offset_idx,1,1:handles.newnT) = repmat(handles.param.offset(offset_idx), [1 1 1 1 handles.newnT]);
% % %     case 'field' % calculate the background across the field by image opening
% % %         radius = str2double(get(handles.txt_back_field_radius,'String'));
% % %         handles.back_image = imopen(handles.images.filtered, strel('disk',radius));
% % % end
% % % % handles.vectorised = handles.images.subtracted;
% the loop version

for iC = 1:handles.nC
    set(handles.stt_status, 'string', ['calculating the background subtraction for channel ' num2str(iC) '. Please wait...']);drawnow;
    if eval(['handles.param.chk_back' num2str(iC)]) == 1
        switch handles.back_method
            case 'single' %subtract a single measured value
                handles.images.subtracted(1:handles.newnY,1:handles.newnX,iC,1:handles.newnZ,1:handles.newnT) = handles.images.filtered(:,:,iC,:,:)-handles.param.back(iC);
            case 'frame' % subtract a measured value from each frame
                for iT = 1:handles.newnT
                    handles.frame_back(iT,iC) = squeeze(mean(mean(handles.images.filtered(handles.p1(2):handles.p1(2)+handles.offset(2), handles.p1(1):handles.p1(1)+handles.offset(1),iC,iZ,iT),1),2));
                    handles.images.subtracted(1:handles.newnY,1:handles.newnX,iC,1:handles.newnZ,iT) = handles.images.filtered(:,:,iC,:,iT)-handles.frame_back(iT,iC);
                end
            case 'field'
                for iT = 1:handles.newnT
                    for iZ = 1:handles.newnZ
                        handles.images.subtracted(:,:,iC,iZ,iT) = imflatfield(handles.images.filtered(:,:,iC,iZ,iT),101);
                    end
                end
        end
    else %don't subtract anything
        handles.images.subtracted(1:handles.newnY,1:handles.newnX,iC,1:handles.newnZ,1:handles.newnT) = handles.images.filtered(1:handles.newnY,1:handles.newnX,iC,1:handles.newnZ,1:handles.newnT);
    end
end

if get(handles.chk_auto_corr, 'value') == 1
    % subtract a scaled version of the autofluorescence channel (after
    % background subtraction) from channel 1
    set(handles.stt_status, 'string', 'Calculating fluorescence bleed through correction. Please wait...');drawnow;
    % calculate a scaled version of the autofluorescence image
    auto = (handles.images.subtracted(1:handles.newnY,1:handles.newnX,handles.auto_ch,1:handles.newnZ,1:handles.newnT).*handles.param.auto_corr);
    % set negative values to zero
    auto = max(auto,0);
    % subtract from the defined image
    handles.images.subtracted(1:handles.newnY,1:handles.newnX,1,1:handles.newnZ,1:handles.newnT) = handles.images.subtracted(1:handles.newnY,1:handles.newnX,1,1:handles.newnZ,1:handles.newnT)-auto;
end
set(handles.stt_status, 'string', 'Setting negative values to zero. Please wait...');drawnow;
handles.images.subtracted(handles.images.subtracted < 0) = 0;
% set up a mask image
handles.images.mask = false(handles.newnY,handles.newnX,handles.nC,handles.newnZ,handles.newnT);
for iC = 1:handles.nC
    set(handles.stt_status, 'string', ['calculating the mask subtraction for channel ' num2str(iC) '. Please wait...']);drawnow;
    thresh = multithresh(handles.images.subtracted(:,:,iC,:,:),3);
    %     handles.images.mask(:,:,iC,:,:) = handles.images.subtracted(1:handles.newnY,1:handles.newnX,iC,1:handles.newnZ,1:handles.newnT)>handles.param.back_std(iC).*2;
    handles.images.mask(:,:,iC,:,:) = handles.images.subtracted(1:handles.newnY,1:handles.newnX,iC,1:handles.newnZ,1:handles.newnT)>thresh(1);
    
    %     if handles.param.filter_tophat_use
    %         r = round(handles.expt.(['FWHM_max' num2str(iC)])./2);
    %         temp = imtophat(handles.images.filtered(:,:,iC,:,:),strel('disk',r));
    %         handles.images.mask(:,:,iC,:,:) = temp;
    %     end
end
set(handles.stt_status, 'string', 'Finished background subtraction');drawnow;

%--------------------------------------------------------------------------
% BLEED-THROUGH CORRECTION FOR AUTOFLUORESCENCE
%--------------------------------------------------------------------------

function pop_auto_corr_channel_Callback(hObject, eventdata, handles)
options = get(handles.pop_auto_corr_channel, 'String');
pop_index = get(handles.pop_auto_corr_channel, 'Value');
handles.param.auto_corr_channel = str2double(options{pop_index});
guidata(hObject, handles);
fnc_param_save(handles)

function pop_auto_corr_target_Callback(hObject, eventdata, handles)
options = get(handles.pop_auto_corr_target, 'String');
pop_index = get(handles.pop_auto_corr_target, 'Value');
handles.param.auto_corr_target = str2double(options{pop_index});
guidata(hObject, handles);
fnc_param_save(handles)

function txt_auto_corr_Callback(hObject, eventdata, handles)
handles.param.auto_corr = str2double(get(handles.txt_auto_corr, 'string'));
guidata(hObject, handles);
fnc_param_save(handles)

function chk_auto_corr_Callback(hObject, eventdata, handles)
handles.param.chk_auto_corr = get(hObject,'value');
if get(hObject,'value')
    set(handles.autoflr_controls,'Enable','on')
else
    set(handles.autoflr_controls,'Enable','off')
end
guidata(hObject, handles);
fnc_param_save(handles)

function btn_auto_corr_Callback(hObject, eventdata, handles)
set(handles.stt_status, 'string', 'Please define the region for autofluorescence bleed-through estimation');drawnow;
frame = get(handles.sld_T, 'value');
sect = get(handles.sld_Z, 'value');
options = get(handles.pop_auto_corr_channel, 'String');
pop_index = get(handles.pop_auto_corr_channel, 'Value');
handles.param.auto_corr_channel = str2double(options{pop_index});
set(gcf,'Pointer','crosshair');
h = findobj(gca,'type','line');
delete(h);
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
rb = rbbox;
% return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = uint16(min(point1,point2));             % calculate locations
offset = uint16(abs(point1-point2));         % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
hold on
axis manual
plot(x,y,'y');
for channel = 1:handles.nC
    auto_corr(channel) = squeeze((mean2(handles.images.filtered(p1(2):p1(2)+offset(2), p1(1):p1(1)+offset(1),channel,sect,frame)))-handles.param.back(channel));
end
handles.param.auto_corr = auto_corr(handles.param.auto_corr_target)./auto_corr(handles.param.auto_corr_channel);
set(gcf,'Pointer','arrow')
set(handles.stt_status, 'string', ['bleedthrough correction factor: ' num2str(handles.param.auto_corr, '%4.2f')]);drawnow;
set(handles.txt_auto_corr, 'String',num2str(handles.param.auto_corr, '%4.2f'));
guidata(gcbo, handles);

% --------------------------------------------------------------------------
% TIP INITIALISE
% --------------------------------------------------------------------------
function pop_tip_trace_channel_Callback(hObject, eventdata, handles)
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
handles.param.trace_channel = str2double(options{options_idx});
guidata(hObject, handles);
fnc_param_save(handles)

function pop_tip_spk_channel_Callback(hObject, eventdata, handles)
options = get(handles.pop_tip_spk_channel, 'string');
options_idx = get(handles.pop_tip_spk_channel, 'value');
handles.param.spk_channel = str2double(options{options_idx});
guidata(hObject, handles);
fnc_param_save(handles)

% --------------------------------------------------------------------------
% TIP SEGMENTATION USING THRESHOLDING
% --------------------------------------------------------------------------

function pop_segment_method_Callback(hObject, eventdata, handles)
options = get(handles.pop_segment_method, 'string');
options_idx = get(handles.pop_segment_method, 'value');
handles.param.segment_method = options{options_idx};
handles = fnc_segment_method(handles);
guidata(hObject, handles);
fnc_param_save(handles)

function handles = fnc_segment_method(handles)
handles = fnc_segment_parameters_set(handles);
switch handles.param.segment_method
    case 'global'
        set(handles.segment_controls([1:2,7:10]), 'enable','on')
        set(handles.segment_controls(3:6), 'enable','off')
    case 'adaptive'
        set(handles.segment_controls(3:10), 'enable','off')
    otherwise
        set(handles.segment_controls(1:6), 'enable','on')
        set(handles.segment_controls(7:10), 'enable','off')
end

function handles = fnc_segment_parameters_set(handles)
switch handles.param.segment_method
    case {'global';'adaptive'}
        handles.param.local_radius = 0;
        handles.param.local_offset = 0;
    case 'local mean'
        handles.param.local_radius = handles.param.local_radius_mean;
        handles.param.local_offset = handles.param.local_offset_mean;
    case 'local median'
        handles.param.local_radius = handles.param.local_radius_median;
        handles.param.local_offset = handles.param.local_offset_median;
    case 'midgrey'
        handles.param.local_radius = handles.param.local_radius_midgrey;
        handles.param.local_offset = handles.param.local_offset_midgrey;
    case 'Niblack'
        handles.param.local_radius = handles.param.local_radius_Niblack;
        handles.param.local_offset = handles.param.local_offset_Niblack;
    case 'Bernsen'
        handles.param.local_radius = handles.param.local_radius_Bernsen;
        handles.param.local_offset = handles.param.local_offset_Bernsen;
    case 'Sauvola'
        handles.param.local_radius = handles.param.local_radius_Sauvola;
        handles.param.local_offset = handles.param.local_offset_Sauvola;
end
set(handles.txt_segment_local_radius,'String',handles.param.local_radius)
set(handles.txt_segment_local_offset,'String',handles.param.local_offset)

function handles = fnc_segment_parameters_update(handles)
radius = str2double(get(handles.txt_segment_local_radius,'String'));
offset = str2double(get(handles.txt_segment_local_offset,'String'));
switch handles.param.segment_method
    case 'global'
    case 'local mean'
        handles.param.local_radius_mean = radius;
        handles.param.local_offset_mean = offset;
    case 'local median'
        handles.param.local_radius_median  = radius;
        handles.param.local_offset_median = offset;
    case 'midgrey'
        handles.param.local_radius_midgrey  = radius;
        handles.param.local_offset_midgrey = offset;
    case 'Niblack'
        handles.param.local_radius_Niblack  = radius;
        handles.param.local_offset_Niblack = offset;
    case 'Bernsen'
        handles.param.local_radius_Bernsen  = radius;
        handles.param.local_offset_Bernsen = offset;
    case 'Sauvola'
        handles.param.local_radius_Sauvola  = radius;
        handles.param.local_offset_Sauvola = offset;
end

function txt_segment_local_radius_Callback(hObject, eventdata, handles)
handles.param.local_radius = str2double(get(hObject,'String'));
handles = fnc_segment_parameters_update(handles);
guidata(gcbo, handles);
fnc_param_save(handles)

function txt_segment_local_offset_Callback(hObject, eventdata, handles)
handles.param.local_offset = str2double(get(hObject,'String'));
handles = fnc_segment_parameters_update(handles);
guidata(gcbo, handles);
fnc_param_save(handles)

function chk_segment_threshold_auto_Callback(hObject, eventdata, handles)
handles.param.threshold_auto = str2double(get(hObject,'String'));
guidata(gcbo, handles);
fnc_param_save(handles)

function sld_segment_threshold_Callback(hObject, eventdata, handles)
handles.param.global_threshold = get(hObject, 'Value');
set(handles.txt_segment_threshold, 'String',handles.param.global_threshold);
guidata(gcbo, handles);
fnc_param_save(handles)

function txt_segment_threshold_Callback(hObject, eventdata, handles)
handles.param.global_threshold = str2double(get(hObject, 'String'));
set(handles.sld_segment_threshold, 'Value', handles.param.global_threshold);
guidata(gcbo, handles);

function btn_segment_threshold_Callback(hObject, eventdata, handles)
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
iT = get(handles.sld_T, 'Value');
iZ = get(handles.sld_Z, 'Value');
im = double(handles.images.subtracted(:,:,iC,iZ,iT));
im = mat2gray(im);
level = graythresh(im);
set(handles.sld_segment_threshold, 'Value',level)
set(handles.txt_segment_threshold, 'String',level)

function txt_tip_filter_noise_Callback(hObject, eventdata, handles)
handles.param.filter_noise = str2double(get(hObject, 'String'));
guidata(gcbo, handles);
fnc_param_save(handles)

function txt_tip_filter_median_Callback(hObject, eventdata, handles)
handles.param.filter_median = str2double(get(hObject, 'String'));
guidata(gcbo, handles);
fnc_param_save(handles)

function chk_segment_auto_filter_Callback(hObject, eventdata, handles)
handles.param.tip_auto_select = str2double(get(hObject, 'String'));
guidata(gcbo, handles);
fnc_param_save(handles)

function btn_segment_Callback(hObject, eventdata, handles)
set(handles.stt_status,'string', 'Segmenting images. Please wait...');drawnow;
handles.tip_table = [];
handles = fnc_segment(handles);
guidata(gcbo, handles);
% update the thumbnails
handles.thumbnails.segmented = fnc_thumbnail_make(handles.images.segmented(:,:,:,1,round(handles.nT/2)), 'segmented',handles);
handles = fnc_thumbnail_display('segmented',handles);
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'segmented')));
handles = fnc_display_image(handles);
set(handles.tip_trace_controls,'enable','on');
set(handles.stt_status,'string', 'Segmentation complete');drawnow;

function handles = fnc_segment(handles)
% options = get(handles.pop_tip_trace_channel, 'string');
% options_idx = get(handles.pop_tip_trace_channel, 'value');
% iC = str2double(options{options_idx});
iC = 1;
iZ = get(handles.sld_Z, 'Value');
% get the filtering parameters
noise_radius = str2double(get(handles.txt_tip_filter_noise, 'String'));
median_size = str2double(get(handles.txt_tip_filter_median, 'String'));
noise_se = strel('disk',noise_radius,0);
% dimension the segmented image and the separator image
[nY,nX,nC,nZ,nT] = size(handles.images.subtracted);
handles.images.segmented = false(nY,nX,1,1,nT);
handles.images.separator = false(nY,nX,1,1,nT);
for iT = 1:handles.nT
    set(handles.stt_status,'string', ['Segmenting image '  num2str(iT) ' of ' num2str(handles.nT) '. Please wait...']);drawnow;
    % normalise the image and convert to single precision
    im = double(handles.images.subtracted(:,:,iC,iZ,iT))./handles.normalise;
    switch handles.param.segment_method
        case 'global'
            if get(handles.chk_segment_threshold_auto, 'Value')
                thresh = multithresh(im,2);
                handles.expt.global_threshold(iT) = thresh(1);
                set(handles.sld_segment_threshold, 'Value',handles.expt.global_threshold(iT))
                set(handles.txt_segment_threshold, 'String',handles.expt.global_threshold(iT))
                bw = imbinarize(im,handles.expt.global_threshold(iT));
            else
                handles.param.global_threshold = get(handles.sld_segment_threshold, 'Value');
                bw = imbinarize(im,handles.param.global_threshold);
            end
        case 'adaptive'
            bw = imbinarize(im, 'adaptive', 'Sensitivity', 0.5, 'ForegroundPolarity', 'bright');
        case 'local mean'
            se = strel('disk',handles.param.local_radius,0);
            h = double(getnhood(se));
            m  = imfilter(im,h,'symmetric') / sum(h(:));
            level = m - handles.param.local_offset;
            bw = im > level;
        case 'local median'
            se = strel('disk',handles.param.local_radius,0);
            h = double(getnhood(se));
            m  = ordfilt2(im,median(1:sum(h(:))),h,'symmetric');
            level = m - handles.param.local_offset;
            bw = im > level;
        case 'midgrey'
            lmin = imerode(im,strel('disk',handles.param.local_radius,0));
            lmax = imdilate(im,strel('disk',handles.param.local_radius,0));
            mg = (lmin + lmax)/2;
            level =  mg - handles.param.local_offset;
            bw = im > level;
        case 'Niblack'
            m = imfilter(im,fspecial('disk',handles.param.local_radius)); % local mean
            s = stdfilt(im,getnhood(strel('disk',handles.param.local_radius,0))); % local std
            level = m - handles.param.local_offset * s;
            bw  = im > level;
        case 'Bernsen'
            lmin = imerode(im,strel('disk',handles.param.local_radius,0));
            lmax = imdilate(im,strel('disk',handles.param.local_radius,0));
            lc = lmax - lmin; % local contrast
            mg = (lmin + lmax)/2; % mid grey
            ix1 = lc < handles.param.local_offset; % weight = contrast threshold in Bernsen algorithm
            ix2 = lc >= handles.param.local_offset;
            temp = false(size(im));
            temp(ix1) = mg(ix1) >= 0.5;
            temp(ix2) = im(ix2) >= mg(ix2);
            bw = temp;
        case 'Sauvola'
            m = imfilter(im,fspecial('disk',handles.param.local_radius)); % local mean
            s = stdfilt(im,getnhood(strel('disk',handles.param.local_radius,0))); % local std
            R = max(s(:));
            level = m .* (1.0 + handles.param.local_offset * (s / R - 1.0));
            bw = im > level;
    end
    % only include values above background
    bw = bw & handles.images.mask(:,:,iC,iZ,iT);
    % filter the image to remove small objects
    if get(handles.chk_segment_auto_filter,'Value')
        % remove noise below the radius of se1
        filt = imopen(bw,noise_se);
        % reconstruct the original image without the noise
        bw = imreconstruct(filt,bw);
    end
    % apply a strong median filter to tidy up the boundary
    bw = medfilt2(bw,[median_size median_size]);
    % remove single pixel dents or bumps
    bw =  bwmorph(bw,'majority') | ~bwmorph(~bw,'majority');
    %     bw = imfill(bw,'holes');
    if iT > 1
        % apply the separator skeleton from previous time-points. This
        % helps to ensure the watershed will be able to separate tips that
        % are growing next to each other
        bw = bw  & ~handles.images.separator(:,:,iC,iZ,iT-1);
    end
    % separate any touching tips using a watershed algorithm on the EDM after
    % suppressing any areas less than 30% of the maximum
    D = bwdist(~bw);
    D = max(D(:))-D;
    H = imhmin(D./max(D(:)),0.3);
    WS = watershed(H,8);
    % get the watershed lines (if any) that separate any objects
    sk = WS == 0;
    % make them 4-connected
    sk = bwmorph(sk,'diag');
    % keep the bit of the skeleton that overlaps with the objects
    sk = sk & imdilate(bw, ones(3));
    % add in the previous separator
    if iT >1
        sk = sk | handles.images.separator(:,:,iC,iZ,iT-1);
    end
    % update the separator image
    handles.images.separator(:,:,iC,iZ,iT) = sk;
    % mask the binary image with the separator
    bw(sk) = 0;
    handles.images.segmented(:,:,iC,iZ,iT) = bw;
end

% --------------------------------------------------------------------------
% TIP SELECTION
% --------------------------------------------------------------------------

function btn_select_Callback(hObject, eventdata, handles)
set(handles.stt_status,'string', 'Selection of hyphal tips for analysis');drawnow;
% reset the tip table
set(handles.uit_tip,'data',{0,0,0,false})
% clear the results array
handles.tip_table = [];
handles = fnc_select(handles);
guidata(gcbo, handles);

function handles = fnc_select(handles)
set(handles.sld_T,'Value',1);
set(handles.chk_T_max,'Value',0);
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
iZ = get(handles.sld_Z, 'Value');
iT = get(handles.sld_T, 'Value');
% get the current time point
%im = handles.images.segmented(:,:,iC,iZ,iT);
% smooth with a median to tidy up the outline
% im = medfilt2(im,[7 7]);
% display the image
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'segmented')));
handles = fnc_display_image(handles);
set(handles.stt_status,'string', ['Please select the hyphal tips for analysis.... Right click to finish']);drawnow;
but = 1;
n = 0;
while but == 1
    n = n+1;
    [xp,yp, but] = myginput(1, 'crosshair');
    if but == 3
        break
    end
    x(n,1) = xp;
    y(n,1) = yp;
    hold on
    plot(x(n,1),y(n,1),'m*')
end
handles.tip_selected_points = round([x,y]);
set(gcf,'pointer','arrow')
set(handles.stt_status,'string', 'Selection complete');drawnow;

% --------------------------------------------------------------------------
% TIP EXTRACTION
% --------------------------------------------------------------------------

function txt_tip_trace_distance_Callback(hObject, eventdata, handles)
handles.param.tip_trace_distance = str2double(get(hObject, 'String'));
guidata(gcbo, handles);
fnc_param_save(handles)

function btn_tip_reset_Callback(hObject, eventdata, handles)
handles.tip_results = [];
handles.tip_trace = [];
guidata(gcbo, handles);

function btn_tip_extract_Callback(hObject, eventdata, handles)
set(handles.stt_status,'string', 'Finding tips. Please wait...');drawnow;
handles = fnc_tip_extract(handles);
guidata(gcbo, handles);
%update the thumbnails
handles.thumbnails.selected = fnc_thumbnail_make(handles.images.selected, 'selected',handles);
handles = fnc_thumbnail_display('selected',handles);
handles.thumbnails.midline = fnc_thumbnail_make(imdilate(handles.images.midline(:,:,1,1,round(handles.nT/2)),strel('disk',7)), 'midline',handles);
handles = fnc_thumbnail_display('midline',handles);
handles.thumbnails.tip = fnc_thumbnail_make(handles.images.tip(:,:,1,1,round(handles.nT/2)), 'tip',handles);
handles = fnc_thumbnail_display('tip',handles);
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'midline')));
set(handles.pop_display_merge, 'Value', find(strcmpi(get(handles.pop_display_merge, 'String'), 'subtracted')));
set(handles.chk_display_merge, 'Value',1)
handles = fnc_display_image(handles);
set(handles.stt_status,'string', 'Tip extraction complete');drawnow;
set(handles.tip_profile_controls,'enable','on');

function handles = fnc_tip_extract(handles)
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
iZ = get(handles.sld_Z, 'Value');
handles.images.tip = zeros(size(handles.images.segmented)); % tip region of segmented hypha
handles.images.tip_ID = zeros(size(handles.images.segmented)); % tip region of segmented hypha
handles.images.boundary = zeros(size(handles.images.segmented)); % single pixel wide boundary
handles.images.midline = false(size(handles.images.segmented)); % midline of segmented hypha
handles.images.boundary_Din = zeros(size(handles.images.segmented)); % internal distance from boundary
handles.images.boundary_FMin = zeros(size(handles.images.segmented)); % feature map internal from boundary
handles.images.boundary_Dout = zeros(size(handles.images.segmented)); % external distance from boundary
handles.images.boundary_FMout = zeros(size(handles.images.segmented)); % feature map external from boundary
% get the circumferential trace distance
handles.param.trace_distance = str2double(get(handles.txt_tip_trace_distance, 'String'));
% display the first image
set(handles.txt_T, 'String', 1);
set(handles.sld_T, 'value', 1);
axes(handles.ax_image);
set(handles.chk_T_max,'Value',0)
set(handles.chk_Z_max,'Value',0)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'subtracted')));
handles = fnc_display_image(handles);
fnc_clear_overlays(handles);
% find the number of hyphae that have been selected
nH = size(handles.tip_selected_points,1);
% get the distance that the trace will be run over
distance = handles.param.trace_distance;
% keep a log of whether a tip has been identified for each hypha in
% each time point
tip_log = false(handles.nT,nH);
% set up the results table
% T = table({'filename'},0,0,0,0,0,[0,0],{[0 0]},0,'VariableNames',{'filename','T','Z','C','ID','active','endpoint','boundary','rmax'})
handles.tip_table = [];
% start with the tip co-ordinates that have been manually selected
x = handles.tip_selected_points(:,1);
y = handles.tip_selected_points(:,2);
% loop through each image
for iT = 1:handles.nT
    set(handles.stt_status,'string', ['Extracting the tips for image ' num2str(iT) '. Please wait...']);drawnow;
    % set up an accumulator image for the boundaries
    boundary_im = zeros(size(handles.images.segmented,1),size(handles.images.segmented,2));
    % increment the sliders and display the new image
    set(handles.sld_T,'Value',iT)
    set(handles.txt_T,'String',iT)
    handles = fnc_display_image(handles);
    % get a bw image of all the hyphae at this time point, ensuring the
    % boundaries prevent 8 connectivity
    hypha_all = handles.images.segmented(:,:,iC,iZ,iT);
    % calculate the geodesic distance transform from the selected points
    % effectively along the hypha
    DGeo = bwdistgeodesic(hypha_all,x,y,'quasi-euclidean');
    % set up the tip region to be slightly greater than the trace
    % distance
    tip_all = (DGeo<distance.*1.5);
    if iT ==1
        % label the first image to give tips a unique ID
        tip_ID = bwlabel(tip_all);
    else
        % get the previous tip ID image
        previous = handles.images.tip_ID(:,:,iC,iZ,iT-1);
        % get the previous as the input to select the new tip regions
        for iH = 1:max(previous(:))
            [r,c] = find(previous==iH);
            temp = bwselect(tip_all,c,r);
            % set the new tip to the existing ID
            temp = temp.*iH;
            % add the new tip into the tip_ID image
            tip_ID = max(tip_ID,temp);
        end
    end
    % calculate the distance transform
    [D,FM] = bwdist(~hypha_all, 'Euclidean'); % D is the euclidean distance, FM is the feature map
    if iT == 1
        % get the maximum radius present from the distance transform of just the
        % tip regions to ensure no other objects dominate the estimate
        rmax = double(round(max(D(tip_all))));
    end
    % Shrink the binary image by 30% of the maximum to calculate the midline and smooth the binary image to ensure there are no spurs
    bw = medfilt2(D>0.3*rmax,round([rmax/2 rmax/2]));
    % thin to a single pixel skeleton at the midline of the hypha
    bw_midline = bwskel(bw,'MinBranchLength',round(rmax/2));%bwmorph(bw,'thin',inf);
    % find any branch-point and split the skeleton at these
    bp = bwmorph(bw_midline,'branchpoints');
    bw_midline = bw_midline &~imdilate(bp,ones(3));
    % get the image of the endpoints
    ep = bwmorph(bw_midline,'endpoints');
    % get the co-ordinates and tip_ID of the endpoints
    p = tip_ID;
    p(~ep) = 0;
    [y,x,v] = find(p);
    % find the distance of the new points from the points initially selected
    d = DGeo(sub2ind(size(DGeo),y,x));
    % set up a matrix to sort by d, then find the unique entries (which
    % corresponds to the first occurrence of each tip_ID. This should be at the minimum d as they have been sorted;
    m = [x,y,v,d];
    m = sortrows(m,4,'ascend');
    [~,ia] = unique(m(:,3));
    x = m(ia,1);
    y = m(ia,2);
    v = m(ia,3);
    % keep only the section of the midline image connected to the hyphal
    % tips
    bw_midline = bwselect(bw_midline,x,y);
    % set up an extended colormap to label each hypha
    cols = repmat({'r','g','b','c','m','y','w'},1,10);
    % loop through each hyphae
    tip_labelled = zeros(size(tip_ID));
    tip_midline = zeros(size(tip_ID));
    for iH = 1:length(v)
        % display the selected points
        plot(handles.ax_image,x(iH),y(iH),'Marker','o','MarkerFaceColor',cols{iH},'MarkerEdgeColor','k','MarkerSize',3)
        % get the specific hypha
        tip = bwselect(tip_all,x(iH),y(iH));
        % check that there is tip present (should be unnecessary?)
        if any(tip(:))
            % update the tip log
            tip_log(iT,v(iH)) = 1;
            % select just the region within the trace distance from the
            % new skeleton endpoints that have just been extracted
            DGeo = bwdistgeodesic(tip,x(iH),y(iH),'quasi-euclidean');
            tip = DGeo<distance;
            % get the maximum radius for the hypha in the tip region
            rmax = double(round(max(D(tip))));
            % get the complete hyphae that includes this tip
            hypha = bwselect(hypha_all,x(iH),y(iH));
            % find the boundary points on the surface of the hypha as the
            % intersection between the tip boundary and the hyphal boundary
            % to exclude the points truncating the tip region
            tip_boundary = bwboundaries(tip);
            hypha_boundary = bwboundaries(hypha);
            boundary = intersect(tip_boundary{1}(:,1:2),hypha_boundary{1}(:,1:2),'rows','stable');
            % close the boundary
            boundary = [boundary;boundary(1,:)];
            % the start and end points of the trace boundary will be the maximum
            % difference in a circularised set of pixel co-ordinates
            [~,idx] = max(abs(hypot(diff(boundary(:,1)),diff(boundary(:,2)))));
            % shift the boundary co-ordinates to start at index 1
            boundary = circshift(boundary(1:end-1,:),-idx,1);
            % create a boundary image with the tip ID
            B_idx = sub2ind(size(tip),round(boundary(:,1)),round(boundary(:,2)));
            boundary_im(B_idx) = iH;
            % get the midline for the hypha as an image
            midline_im = bw_midline & hypha;
            midline = bwtraceboundary(midline_im,double([y(iH),x(iH)]),'N');
            % we only need the first half of the midline data as it wraps
            % back on itself
            midline(round(length(midline)/2):end,:) = [];
            % get the 
            % set the new tip image to the label value of the current hypha
            tip_ID(tip) = iH;
            tip_labelled(tip) = iH;
            tip_midline(midline_im) = iH;
            h = plot(handles.ax_image,boundary(:,2), boundary(:,1), 'c:', 'LineWidth', 0.75);
            set(h, 'Tag','tip_boundary')
            h = plot(handles.ax_image,midline(:,2), midline(:,1), 'y-', 'LineWidth', 0.75);
            set(h, 'Tag','tip_midline')
            % update the results
            T = table({handles.fname},iT,iZ,iC,iH,1,[y(iH),x(iH)],{boundary},{B_idx},{midline},rmax,'VariableNames',{'filename','T','Z','C','ID','active','endpoint','boundary','B_idx','midline','rmax'});
            handles.tip_table = [handles.tip_table; T];
        else
            'no tip'
        end
    end
    % update the images
    handles.images.midline(:,:,iC,iZ,iT) = tip_midline;
    handles.images.tip(:,:,iC,iZ,iT) = tip_labelled;
    handles.images.tip_ID(:,:,iC,iZ,iT) = tip_ID;
    handles.images.boundary(:,:,iC,iZ,iT) = boundary_im;
    % calculate the internal distance transform and feature map for all tips, with
    % masking by the tip image
    mask = double(tip_ID>0) ;
    boundary_all = bwperim(hypha_all);
    [DB,FMB] = bwdist(boundary_all,'Euclidean');
    handles.images.boundary_Din(:,:,iC,iZ,iT) = DB.*mask;
    handles.images.boundary_FMin(:,:,iC,iZ,iT)  = double(FMB).*mask;
    handles.images.boundary_Dout(:,:,iC,iZ,iT) = DB.*~hypha_all;
    handles.images.boundary_FMout(:,:,iC,iZ,iT)  = double(FMB).*~hypha_all;
end
% set the active status of points that are less than the trace distance away from
% the boundary of the image to zero
handles.tip_table.active = handles.tip_table.endpoint(:,1)>rmax & handles.tip_table.endpoint(:,2)>rmax & handles.tip_table.endpoint(:,1)<size(tip_ID,1)-rmax | handles.tip_table.endpoint(:,1)>size(tip_ID,2)-rmax;
handles.images.selected = max(handles.images.tip, [], 5);
% update the tip table
ID = 1:nH;
[~,first] = max(tip_log,[],1);
last = sum(tip_log,1)+first-1;
use = true(nH,1);
set(handles.uit_tip, 'data',[num2cell([ID',first',last']),num2cell(use)])
handles.TipIdx = true(nH,1);

function uit_tip_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uit_tip (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(eventdata.Indices)
    data = get(handles.uit_tip,'data');
    handles.TipIdx = cell2mat(data(:,4));
    guidata(hObject, handles);
end

% --------------------------------------------------------------------------
% TIP BOUNDARY PROFILE
% --------------------------------------------------------------------------

function txt_tip_profile_average_Callback(hObject, eventdata, handles)
handles.param.tip_profile_average = str2double(get(hObject, 'String'));
guidata(gcbo, handles);
fnc_param_save(handles)

function btn_tip_profile_Callback(hObject, eventdata, handles)
handles = fnc_boundary_profile(handles);
guidata(gcbo, handles);
set(handles.stt_status,'string', ['Profiles complete']);drawnow;
fnc_tip_plot_profile(handles.ax_image,handles);

function handles = fnc_boundary_profile(handles)
p_average = str2double(get(handles.txt_tip_profile_average, 'String'));
% loop through each time-point
for iT = 1:max(handles.tip_table.T)
        set(handles.stt_status,'string', ['Calculating boundary profiles for frame : ' num2str(iT) '. Please wait...']);drawnow;

    % get the subtracted image for each time point
    im = mat2gray(handles.images.subtracted(:,:,1,1,iT));
    % loop through each hypha
    for iH = 1:max(handles.tip_table.ID)
        % get the index into the tip_table array
        iD = find(handles.tip_table.T == iT & handles.tip_table.ID == iH);
        % get a smoothed boundary for the tip
        SB = smoothdata(handles.tip_table.boundary{iD},'sgolay',15);
        % measure the euclidean length along the boundary
        SB_length = [0; cumsum(hypot(diff(SB(:,1)),diff(SB(:,2))))];
        % resample at unit points
        x = interp1(SB_length,SB(:,2),0:round(max(SB_length)))';
        y = interp1(SB_length,SB(:,1),0:round(max(SB_length)))';
        SB_length_interp = (0:round(max(SB_length)))';
        % calculate the gradient
        dx = gradient(x);
        dy = gradient(y);
        % calculate the end-point co-ordinates for normals at each boundary
        % point
        xep1 = x+(dy.*p_average);
        xep2 = x+(-dy.*p_average);
        yep1 = y+(-dx.*p_average);
        yep2 = y+(dx.*p_average);
        % remove any nans fo all the endpoint arrays
        idxnan = isnan(xep1) | isnan(xep2) | isnan(yep1) | isnan(yep2);
        xep1(idxnan) = [];
        xep2(idxnan) = [];
        yep1(idxnan) = [];
        yep2(idxnan) = [];
        % update the tip_table with the sets of profile co-ordinates
        handles.tip_table.P{iD} = [y(~idxnan),x(~idxnan)];
        handles.tip_table.P_length{iD} = SB_length_interp(~idxnan);
        handles.tip_table.P_outer{iD} = [yep1 xep1];
        handles.tip_table.P_inner{iD} = [yep2 xep2];       
        % calculate the profile along each pair of endpoint co-ordinates,
        % smooth the data and extract the average and max value
        P_mean = zeros(length(xep1),1);
        P_max = zeros(length(xep1),1);
        for iP = 1:length(xep1)
            P = improfile(im,[xep1(iP) xep2(iP)],[yep1(iP) yep2(iP)],2*p_average+1);
            P = smoothdata(P,'sgolay',5);
            P_mean(iP,1) = mean(P);
            P_max(iP,1) = max(P);
        end
        % update the tip_table
        handles.tip_table.P_mean{iD} = P_mean;
        handles.tip_table.P_max{iD} = P_max;
%         axes(handles.ax_image)
%         hold on
%         plot(x,y,'b.')
%         plot(xep1,yep1,'r.')
%         plot(xep2,yep2,'g.')
    end
end

% --------------------------------------------------------------------------
% TIP BOUNDARY PROFILE ANALYSIS
% --------------------------------------------------------------------------

function btn_tip_profile_analyse_Callback(hObject, eventdata, handles)
handles = fnc_tip_profile_analyse(handles);
guidata(gcbo, handles);
set(handles.stt_status,'string', ['Profile analysis complete']);drawnow;
fnc_tip_plot_profile(handles.ax_image,handles);

function handles = fnc_tip_profile_analyse(handles)
peak_reset = contains(handles.tip_table.Properties.VariableNames,'peak');
assignin('base','tip_table',handles.tip_table)
handles.tip_table(:,peak_reset) = [];
[handles.tip_table.peak_height, ...
    handles.tip_table.peak_displacement, ...
    handles.tip_table.peak_width, ...
    ~, ...
    handles.tip_table.peak_width_pos,~,~] = cellfun(@(x,y) ...
    findpeaksandborders(smoothdata(y,'sgolay',15),x, ...
    'WidthReference','halfheight', ...
    'MinPeakWidth',3, ...
    'MinPeakProminence',0.03, ...
    'NPeaks', 2), ...
    handles.tip_table.P_distance, ...
    handles.tip_table.P_mean, ...
    'UniformOutput',false);
handles.tip_table.peak_number = cellfun(@(x) numel(x), handles.tip_table.peak_height,'UniformOutput',true);
[~,handles.tip_table.peak_main] = cellfun(@(x) max(x), handles.tip_table.peak_height,'UniformOutput',false); % keep as a cell array to use in cellfun later
[~,Pidx] = cellfun(@(x,y,z) intersect(x,y), handles.tip_table.P_distance,handles.tip_table.peak_displacement, 'UniformOutput',false);
handles.tip_table.peak_coordinates = cellfun(@(x,y) x(y,:), handles.tip_table.P, Pidx, 'UniformOutput',false);
guidata(gcbo, handles);
set(handles.stt_status,'string', ['Profile analysis complete']);drawnow;

% --------------------------------------------------------------------------
% TIP APEX DETECTION USING AN OSCULATING CIRCLE
% --------------------------------------------------------------------------

function btn_tip_apex_Callback(hObject, eventdata, handles)
set(handles.stt_status,'string', 'Detecting apex. Please wait...');drawnow;
handles = fnc_tip_apex(handles);
guidata(gcbo, handles);
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'subtracted')));
set(handles.pop_display_merge, 'Value', find(strcmpi(get(handles.pop_display_merge, 'String'), 'subtracted')));
set(handles.chk_display_merge, 'Value',0)
handles = fnc_display_image(handles);
set(handles.stt_status,'string', 'Apex detection complete');drawnow;
set(handles.tip_profile_controls,'enable','on');

function handles = fnc_tip_apex(handles)
% only trace active tips
idxA = find(handles.tip_table.active);
% loop through each hypha for all time-points where it is active
for iH = 1:length(idxA)
    set(handles.stt_status,'string', ['Tracing tip ' num2str(iH) '. Please wait...']);drawnow;
    % pull out the indexes
    iT = handles.tip_table.T(idxA(iH));
    iZ = handles.tip_table.Z(idxA(iH));
    iC = handles.tip_table.C(idxA(iH));
    ID = handles.tip_table.ID(idxA(iH));
    % get the maxiumum radius of the hypha
    rmax = handles.tip_table.rmax(idxA(iH));
    % get the co-ordinates of the smoothed boundary in the tip region
    boundary = handles.tip_table.P{idxA(iH)};
    h = plot(handles.ax_image,boundary(:,2), boundary(:,1), 'r-', 'LineWidth', 0.75);
    % use an approximate 60 degree separation for the test points of the osculating circle
    dc = round(rmax);
    % set up the output arrays
    R = ones(size(boundary,1),1)*inf; % radius
    K = zeros(size(boundary,1),1); % curvature
    C = ones(size(boundary,1),2)*inf; % center
    nc = length(boundary);
    % loop through pixels on the contour, starting and finishing two chord
    % length away from the center
    for i = round(nc/2)-(2*dc) : round(nc/2)+(2*dc)
        idx_c = i; % the target pixel index
        idx_l = idx_c - dc; % the lefthand marker index
        idx_r = idx_c + dc; % the righthand marker index
        pix_i  = boundary(idx_c,:); % the target pixel co-ordinates
        pix_l = boundary(idx_l,:); % the lefthand pixel co-ordinates
        pix_r = boundary(idx_r,:); % the righthand pixel co-ordinates
        % calculation of coefficients for the implicit equation of a line normal to the tangent between the midpoint and the left and right markers
        [a1,b1,c1] = points_bisect_line_imp_2d(pix_i,pix_l);
        [a2,b2,c2] = points_bisect_line_imp_2d(pix_i,pix_r);
        % calculation of the intersection point between the two normals
        [ival,center] = lines_imp_int_2d(a1,b1,c1,a2,b2,c2);
        % ival reports whether a unique intersection point is found
        if ival==1
            vector = pix_i-center;
            radius = norm(vector);
            R(i) = radius;
            K(i) = 1/radius;
            C(i,:) = center;
        end
    end
    % select the tip region
    tip = handles.images.tip(:,:,iC,iZ,iT)==ID;
    % find OC centers within the tip
    [r,c] = find(tip);
    idxInside = ismember(round(C),[r,c],'rows');
    if any(idxInside)
        % find the smallest radius and center for circles within the tip region
        Rmin = min(R(idxInside));
        % if there is more than one with the same radius, pick
        % the first one
        idx = find(R==Rmin,1);
        radius = R(idx);
        center = C(idx,:);
        % update the osculating circle markers for the circle with the
        % smallest radius
        cs = length(boundary);
        idx_c = idx;
        idx_l = idx_c - dc;
        idx_r = idx_c + dc;
        if idx_l<1;  idx_l = cs - abs(idx_l); end
        if idx_r>cs; idx_r = idx_r - cs;      end
        % adjust the length to run positive and negative from the apex
        handles.tip_table.P_distance{idxA(iH)} = handles.tip_table.P_length{idxA(iH)} - handles.tip_table.P_length{idxA(iH)}(idx_c);
        %  update the results table
        handles.tip_table.OC_center(idxA(iH),1:2) = center;
        handles.tip_table.OC_radius(idxA(iH)) = radius;
        handles.tip_table.OC_apex(idxA(iH),1:2) = boundary(idx_c,:);
        handles.tip_table.OC_r(idxA(iH),1:2) = boundary(idx_r,:);
        handles.tip_table.OC_l(idxA(iH),1:2) = boundary(idx_l,:);
    end
end
% calculate vectors
for iH = 1:max(handles.tip_table.ID)
    idx = handles.tip_table.ID == iH;
    pos = diff(handles.tip_table.OC_apex(idx,:));
    growth = hypot(pos(:,1),pos(:,2));
    handles.tip_table.growth(idx) = [nan; growth];
end
set(handles.stt_status,'string', 'Tip tracing finished');drawnow;

% --------------------------------------------------------------------------
% TIP CO-ORDINATE SYSTEMS
% --------------------------------------------------------------------------

handles = fnc_tip_coordinate_system(handles);
guidata(gcbo, handles);

% --------------------------------------------------------------------------
% AXIAL PROFILE
% --------------------------------------------------------------------------

function btn_tip_axial_profile_Callback(hObject, eventdata, handles)
handles = fnc_axial_profile(handles);
guidata(gcbo, handles);
set(handles.stt_status,'string', ['Axial profiles complete']);drawnow;
fnc_tip_plot_profile(handles.ax_image,handles);

function handles = fnc_axial_profile(handles)
rmax120 = round(1.2*max(handles.tip_table.rmax(:)));
width = round(2*rmax120+1);
nH = max(handles.tip_table.ID);
nT = max(handles.tip_table.T);
handles.images.axial = zeros(100,round(rmax120*nH),1,1,nT);
% loop through each time-point
for iT = 1;%:nT
    set(handles.stt_status,'string', ['Calculating axial profiles for frame : ' num2str(iT) '. Please wait...']);drawnow;
    % get the subtracted image for each time point
    im = mat2gray(handles.images.subtracted(:,:,1,1,iT));
    % loop through each hypha
    for iH = 1:nH
        % get the index into the tip_table array
        iD = find(handles.tip_table.T == iT & handles.tip_table.ID == iH);
        % get a smoothed midline (SM) profile
        SM = smoothdata(handles.tip_table.midline{iD},'sgolay',15)
        % add in the tip apex and outer marker
        SM = [handles.tip_table.OC_apex(iD,:); SM];
        % measure the euclidean length along the boundary
        SM_length = [0; cumsum(hypot(diff(SM(:,1)),diff(SM(:,2))))];
        % resample at unit points
        x = interp1(SM_length,SM(:,2),0:round(max(SM_length)))';
        y = interp1(SM_length,SM(:,1),0:round(max(SM_length)))';
%         SM_length_interp = (0:round(max(SM_length)))';
        % calculate the gradient
        dx = gradient(x);
        dy = gradient(y);
        % calculate the end-point co-ordinates for normals at each boundary
        % point
        xep1 = x+(dy.*rmax120);
        xep2 = x+(-dy.*rmax120);
        yep1 = y+(-dx.*rmax120);
        yep2 = y+(dx.*rmax120);
        % remove any nans fo all the endpoint arrays
        idxnan = isnan(xep1) | isnan(xep2) | isnan(yep1) | isnan(yep2);
        xep1(idxnan) = [];
        xep2(idxnan) = [];
        yep1(idxnan) = [];
        yep2(idxnan) = [];
%         % update the tip_table with the sets of profile co-ordinates
%         handles.tip_table.P{iD} = [y(~idxnan),x(~idxnan)];
%         handles.tip_table.P_length{iD} = SB_length_interp(~idxnan);
%         handles.tip_table.P_outer{iD} = [yep1 xep1];
%         handles.tip_table.P_inner{iD} = [yep2 xep2];  
axes(handles.ax_image)
hold on
plot(x,y,'b.')
plot(xep1,yep1,'r.')
plot(xep2,yep2,'g.')
        % calculate the profile along each pair of endpoint co-ordinates,
        for iP = 1:length(min(50,xep1))
            P = improfile(im,[xep1(iP) xep2(iP)],[yep1(iP) yep2(iP)],width);
            handles.images.axial(iP,(1:width)+((iH-1)*width),1,1,iT) = P';
        end
    end
end
handles.images.test = handles.images.axial;


function handles = fnc_tip_coordinate_system(handles)
handles.images.axial = zeros(size(handles.images.subtracted));
handles.images.radial = zeros(size(handles.images.subtracted));
for iT = 1:handles.nT
    set(handles.stt_status, 'String',['Calculating co-ordinate system for image ' num2str(iT) '.Please wait...'])
    % create a geodesic distance transform image from each apex,
    % constrained by the hyphal boundary, to get the axial co-ordinates
    temp = false(size(handles.images.subtracted,1),size(handles.images.subtracted,2));
    apex = handles.tip_table.OC_apex(handles.tip_table.T == iT,:);
    % check whether tips are active
    active = handles.tip_table.active(handles.tip_table.T == iT,:);
    idx = sub2ind(size(temp),round(apex(active,1)),round(apex(active,2)));
    temp(idx) = 1;
    handles.images.axial(:,:,1,1,iT) = bwdistgeodesic(handles.images.segmented(:,:,1,1,iT),temp,'quasi-euclidean');
    % create a complete midline to the apex
    midline = handles.images.midline(:,:,1,1,iT);
    endpoints = handles.tip_table.endpoint(handles.tip_table.T == iT,:);
    for iB = 1:size(apex,1)
        if active(iB)
            [r,c] = bresenham(apex(iB,1),apex(iB,2),endpoints(iB,1),endpoints(iB,2));
            idx = sub2ind(size(midline),r,c);
            midline(idx) = 1;
        end
    end
    % Create the geodesic distance transform from the extended midline, constrained by the hyphal boundary, to
    % get the radial co-ordinates
    handles.images.radial(:,:,1,1,iT) = bwdistgeodesic(handles.images.segmented(:,:,1,1,iT),midline,'quasi-euclidean');
end
set(handles.stt_status, 'String','Co-ordinate system complete')

% -------------------------------------------------------------------------
% SPITZENKORPER DETECTOR
% -------------------------------------------------------------------------

function sld_spk_threshold_Callback(hObject, eventdata, handles)
function txt_spk_threshold_Callback(hObject, eventdata, handles)
function chk_spk_threshold_auto_Callback(hObject, eventdata, handles)
function txt_spk_size_Callback(hObject, eventdata, handles)
function pop_spk_method_Callback(hObject, eventdata, handles)

function btn_spk_threshold_Callback(hObject, eventdata, handles)
options = get(handles.pop_tip_spk_channel, 'string');
options_idx = get(handles.pop_tip_spk_channel, 'value');
iC = str2double(options{options_idx});
iT = round(get(handles.sld_T, 'Value'));
iZ = round(get(handles.sld_Z, 'Value'));
im = double(squeeze(handles.images.subtracted(:,:,iC,iZ,iT)));
im = (im-min(im(:)))/(max(im(:))-min(im(:)));
level = multithresh(im,2);
set(handles.sld_spk_threshold, 'Value',level(2))
set(handles.txt_spk_threshold, 'String',level(2))

function btn_tip_spk_Callback(hObject, eventdata, handles)
handles = fnc_tip_spk_detect(handles);
guidata(gcbo, handles);

function handles = fnc_tip_spk_detect(handles)
options = get(handles.pop_tip_spk_channel, 'string');
options_idx = get(handles.pop_tip_spk_channel, 'value');
iC = str2double(options{options_idx});
iZ = get(handles.sld_Z, 'Value');
nH = max(handles.images.tip(:));
options = get(handles.pop_spk_method, 'string');
options_idx = get(handles.pop_spk_method, 'value');
method = options{options_idx};
axes(handles.ax_image)
switch method
    case 'template'
        % set up mexican hat filter
        scale = round(str2double(get(handles.txt_spk_size, 'String'))./handles.param.pixel_size(1));
        ksize = scale.*3 ;%kernel needs to be 3 times bigger than the object to get the full mexican hat filter
        pkernel = del2(-fspecial('gaussian',[ksize ksize],ksize./6.67));%sets up a mexican hat filter
        for iH = 1:nH
            for iT = 1:handles.nT
                im = double(squeeze(handles.images.subtracted(:,:,iC,iZ,iT)));
                im = mat2gray(im);
                % get the row index into the main results table
                r = handles.tip_table.T == iT & handles.tip_table.ID == iH;
                if ~isempty(r) && handles.tip_table.active(r) == 1 && ~isempty(handles.tip_table.OC_apex(r))
                    %                 if handles.TipIdx(iH) && size(handles.tip_results,2) >=iT && ~isempty(handles.tip_results{iH,iT}) && isfield(handles.tip_results{iH,iT}, 'cm')
                    
                    %     % only use the region within the osculating circle
                    %     center = handles.tip_results{iH,iT}.center;
                    %     radius = handles.tip_results{iH,iT}.radius;
                    %     % calculate the osculating circle
                    %     theta = linspace(0,2*pi,60);
                    %     rho = ones(1,60)*radius;
                    %     [xr,yr] = pol2cart(theta,rho);
                    %     xr = xr + center(2);
                    %     yr = yr + center(1);
                    %     mask = poly2mask(xr,yr,size(im,1),size(im,2));
                    %
                    % only use the region in the selected tip
                    % find centers within the tip
                    tip = handles.images.tip(:,:,1,1,iT)==iH;
                    im(~tip) = 0;%immultiply(im,tip);
                    % calculate the distance transform from the tip
                    dist = zeros(size(im));
                    boundary = handles.tip_table.P{r};
                    dist(round(handles.tip_table.OC_apex(r,1)),round(handles.tip_table.OC_apex(r,2))) = 1;
                    dist = bwdist(dist,'Euclidean');
                    % apply mexican hat filter
                    mexhat = imfilter(im,pkernel, 'replicate','corr');
                    % find the peaks in the mexicanhat image
                    bw = imregionalmax(mexhat);
                    % reduce the peaks to a single pixel
                    bw = bwulterode(bw);
                    % get the co-ordinates of the pixels
                    [ridx,cidx] = find(bw);
                    % get the distance of each point from the apex using
                    % the distance transform image
                    d = dist(sub2ind(size(im),ridx,cidx));
                    % get the intensity value of each point
                    v = im(sub2ind(size(im),ridx,cidx));
                    %                     points = [d v ridx cidx];
                    %                     points = sortrows(points,1);
%                                         % pick the point that is closest to the apex
%                                         [~,idx] = min(d);
                    % in case there are multiple points nearby, find the
                    % brightest point within some distance
                    mx = max(v(d <= min(d)*2));
                    idx = find(v==mx, 1);
                    handles.tip_table.spk(r,1:2) = [ridx(idx), cidx(idx)];
                    if ~isempty(boundary)
                        hold on
                        plot(handles.tip_table.spk(r,2),handles.tip_table.spk(r,1), 'yo')
                        drawnow
                    end
                end
            end
        end
    case 'threshold'
        s = round(str2double(get(handles.txt_spk_size, 'String'))./handles.param.pixel_size(1));
        for iH = 1:size(handles.tip_results,1)
            for iT = 1:handles.nT
                im = double(squeeze(handles.images.subtracted(:,:,iC,iZ,iT)));
                im = (im-min(im(:)))/(max(im(:))-min(im(:)));
                if get(handles.chk_spk_threshold_auto, 'Value')
                    level = multithresh(im,2);
                    t = level(2);
                else
                    t = get(handles.sld_spk_threshold, 'Value');
                end
                [imth,boundary] = BOPlantBlobSegmentation2D(im,t,2);
                handles.tip_table{iH,iT}.xs1 = boundary(1);
                handles.tip_table{iH,iT}.ys1 = boundary(2);
                if ~isempty(boundary)
                    hold on
                    plot(handles.tip_table{iH,iT}.xs1,handles.tip_table{iH,iT}.ys1,'g*')
                end
                
            end
        end
end

function [imth,c] = BOPlantBlobSegmentation2D(im,t,s)
% Threshold
imth = im>t;
% Filter
se = strel('disk',s);
imthc = imopen(imth,se);
imth = imreconstruct(imthc,imth);
% Label
imlabel = bwlabel(imth);
if max(imlabel(:))>0
    r  = regionprops(imlabel,'area','centroid');
    c = cat(1,r.Centroid);
    a = cat(1,r.Area);
    [~,mi] = max(a);
    c = c(mi,:);
    imth = imlabel==mi;
else
    c = [];
end

% --------------------------------------------------------------------------
% TIP PLOT OPTIONS
% --------------------------------------------------------------------------

function chk_tip_plot_endpoint_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_endpoint',handles)
end

function chk_tip_plot_zone_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_zone',handles)
end

function chk_tip_plot_OCC_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_OC',handles)
    fnc_tip_plot_erase(handles.ax_image,'tip_OCC_apex',handles)
end

function chk_tip_plot_OCC_apex_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_OCC_apex',handles)
end

function chk_tip_plot_peak_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_peak',handles)
end

function chk_tip_plot_OCC_center_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_OCC_center',handles)
end

function chk_tip_plot_OCC_apex_vector_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_OCC_apex_vector',handles)
end

function chk_tip_plot_OCC_peak_vector_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_OCC_peak_vector',handles)
end

function chk_tip_plot_OCC_spk_vector_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_OCC_spk_vector',handles)
end

function chk_tip_plot_apex_apex_vector_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_apex_apex_vector',handles)
end

function chk_tip_plot_peak_peak_vector_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_peak_peak_vector',handles)
end

function chk_tip_plot_OCC_OCC_vector_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_OCC_OCC_vector',handles)
end

function chk_tip_plot_spk_spk_vector_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_spk_spk_vector',handles)
end

function chk_tip_plot_boundary_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_boundary',handles)
end

function chk_tip_plot_spk_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_spk',handles)
end

function chk_tip_plot_ID_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot(handles.ax_image,handles)
else
    fnc_tip_plot_erase(handles.ax_image,'tip_ID',handles)
end

function fnc_tip_plot_erase(ax,target,handles)
switch target
    case 'all'
        h = findobj(ax,'type','line','tag','tip_*');
        delete(h);
        h = findobj(ax,'type','text','tag','tip_*');
        delete(h);
        h = findobj(ax,'type','quiver','tag','tip_*');
        delete(h);
        h = findobj(ax,'type','scatter','tag','tip_*');
        delete(h);
    otherwise
        h = findobj(ax,'type','line','tag',target);
        delete(h);
        h = findobj(ax,'type','text','tag',target);
        delete(h);
        h = findobj(ax,'type','quiver','tag',target);
        delete(h);
        h = findobj(ax,'type','scatter','tag',target);
        delete(h);
end

function txt_plot_tip_marker_size_Callback(hObject, eventdata, handles)
function txt_plot_tip_vector_size_Callback(hObject, eventdata, handles)
function txt_plot_tip_OCC_vector_size_Callback(hObject, eventdata, handles)

function fnc_tip_plot(ax,handles)
% get the frame, section and tip trace channel
iT = round(get(handles.sld_T, 'value'));
iZ = round(get(handles.sld_Z, 'value'));
zoom = get(handles.sld_zoom, 'value');
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
% get the maximum number of hyphae
nH = max(handles.tip_table.ID);
% % set up a colormap for the each hypha
% cmap = jet(nH);
% get the parameter settings for the plots
OCC_vector_size = str2double(get(handles.txt_plot_tip_OCC_vector_size,'String'));
vector_size = str2double(get(handles.txt_plot_tip_vector_size,'String'));
marker_size = (str2double(get(handles.txt_plot_tip_marker_size,'String')).*zoom);
max_head_size = 0.04;
handles.ax_image.Units = 'pixels';
hold on
% get results for active hyphae from the current frame, section and channel
idx = find(handles.tip_table.T == iT & handles.tip_table.Z == iZ & handles.tip_table.C == iC & handles.tip_table.active == 1);
if iT < handles.nT
    idx2 = find(handles.tip_table.T == iT+1 & handles.tip_table.Z == iZ & handles.tip_table.C == iC & handles.tip_table.active == 1);
else
    idx2 = [];
end
% plot the tip ID
if get(handles.chk_tip_plot_ID, 'value')
    for k = 1:nH
        x = (double(handles.tip_table.boundary{k}(1,2) + double(handles.tip_table.boundary{k}(end,2)))./2);
        y = (double(handles.tip_table.boundary{k}(1,1) + double(handles.tip_table.boundary{k}(end,1)))./2);
        text(ax,x,y,num2str(handles.tip_table.ID(k)), ...
            'Color','r','HorizontalAlignment','center','VerticalAlignment','middle', ...
            'Tag','tip_ID');
    end
end
% plot the osculating circle
if get(handles.chk_tip_plot_OCC, 'value')
    for k = 1:length(idx)
        % calculate the osculating circle
        theta = linspace(0,2*pi,100);
        rho = ones(1,100)*handles.tip_table.OC_radius(idx(k));
        [xr,yr] = pol2cart(theta,rho);
        xr = xr + handles.tip_table.OC_center(idx(k),2);
        yr = yr + handles.tip_table.OC_center(idx(k),1);
        h = plot(ax,xr,yr,'k-','LineWidth',1);
        set(h, 'Tag','tip_OC')
        h = plot(ax,xr,yr,'w:','LineWidth',.75);
        set(h, 'Tag','tip_OC')
        h = plot(ax,handles.tip_table.OC_l(idx(k),2),handles.tip_table.OC_l(idx(k),1),'b+');
        set(h, 'Tag','tip_OC')
        h = plot(ax,handles.tip_table.OC_apex(idx(k),2),handles.tip_table.OC_apex(idx(k),1),'g+');
        set(h, 'Tag','tip_OCC_apex')
        h = plot(ax,handles.tip_table.OC_r(idx(k),2),handles.tip_table.OC_r(idx(k),1),'y+');
        set(h, 'Tag','tip_OC')
    end
end
% plot the hyphal boundary
if get(handles.chk_tip_plot_boundary, 'value')
    for k = 1:length(idx)
        h = plot(ax,handles.tip_table.boundary{idx(k)}(:,2), handles.tip_table.boundary{idx(k)}(:,1), 'c:', 'LineWidth', 0.75);
        set(h, 'Tag','tip_boundary')
    end
end
% plot the single landmarks:
if get(handles.chk_tip_plot_endpoint, 'Value') && any(ismember(handles.tip_table.Properties.VariableNames,'endpoint'))
    h = scatter(ax,handles.tip_table.endpoint(idx,2),handles.tip_table.endpoint(idx,1),marker_size,'y','filled','Marker','o','MarkerEdgeColor','k');
    set(h, 'Tag','tip_endpoint')
end
if get(handles.chk_tip_plot_zone, 'Value') && any(ismember(handles.tip_table.Properties.VariableNames,'zone'))
    h = scatter(ax,handles.tip_table.zone(idx,2),handles.tip_table.zone(idx,1),marker_size,'c','Marker','+');
    set(h, 'Tag','tip_zone')
end
if get(handles.chk_tip_plot_OCC_apex, 'value') && any(ismember(handles.tip_table.Properties.VariableNames,'OC_apex'))
    h = scatter(ax,handles.tip_table.OC_apex(idx,2),handles.tip_table.OC_apex(idx,1),marker_size,'g','filled','Marker','o','MarkerEdgeColor','k');
    set(h, 'Tag','tip_OCC_apex')
end
if get(handles.chk_tip_plot_OCC_center, 'value') && any(ismember(handles.tip_table.Properties.VariableNames,'OC_center'))
    h = scatter(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1),marker_size,'b','filled','Marker','o','MarkerEdgeColor','k');
    set(h, 'Tag','tip_OCC_center')
end
if get(handles.chk_tip_plot_peak, 'value') && any(ismember(handles.tip_table.Properties.VariableNames,'peak_coordinates'))
    data = cat(1,handles.tip_table.peak_coordinates{idx});
    h = scatter(ax,data(:,2),data(:,1),marker_size,'m','filled','Marker','o','MarkerEdgeColor','none');
    set(h, 'Tag','tip_peak')
end
if get(handles.chk_tip_plot_spk, 'value') && any(ismember(handles.tip_table.Properties.VariableNames,'spk'))
    h = scatter(ax,handles.tip_table.spk(idx,2),handles.tip_table.spk(idx,1),marker_size,'c','filled','Marker','o','MarkerEdgeColor','k');
    set(h, 'Tag','tip_spk')
end
% plot the delta T vectors
if get(handles.chk_tip_plot_apex_apex_vector, 'value') && ~isempty(idx2) && ~isempty(handles.tip_table.OC_apex(idx))
    Vx1 = handles.tip_table.OC_apex(idx2,2)-handles.tip_table.OC_apex(idx,2);
    Vy1 = handles.tip_table.OC_apex(idx2,1)-handles.tip_table.OC_apex(idx,1);
    h = quiver(ax,handles.tip_table.OC_apex(idx,2),handles.tip_table.OC_apex(idx,1), ...
        Vx1*vector_size,Vy1*vector_size,'g','AutoScale','off');
    set(h, 'MaxHeadSize',max_head_size)
    set(h, 'Tag','tip_apex_apex_vector');
    h = plot(ax,handles.tip_table.OC_apex(idx,2),handles.tip_table.OC_apex(idx,1), ...
        'LineStyle','none','Marker','o','MarkerSize',marker_size,'MarkerEdgeColor','k','MarkerFaceColor','g');
    set(h, 'Tag','tip_apex_apex_vector')
end
if get(handles.chk_tip_plot_OCC_OCC_vector, 'value') && ~isempty(idx2) && ~isempty(handles.tip_table.OC_center(idx))
    Vx1 = handles.tip_table.OC_center(idx2,2)-handles.tip_table.OC_center(idx,2);
    Vy1 = handles.tip_table.OC_center(idx2,1)-handles.tip_table.OC_center(idx,1);
    h = quiver(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1), ...
        Vx1*vector_size,Vy1*vector_size,'b','AutoScale','off');
    set(h, 'MaxHeadSize',max_head_size)
    set(h, 'Tag','tip_OCC_OCC_vector');
    h = plot(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1), ...
        'LineStyle','none','Marker','o','MarkerSize',marker_size,'MarkerEdgeColor','k','MarkerFaceColor','b');
    set(h, 'Tag','tip_OCC_OCC_vector')
end
if get(handles.chk_tip_plot_peak_peak_vector, 'value') && ~isempty(idx2) && ~isempty(handles.tip_table.peak_coordinates(idx))
    peak1 = cellfun(@(x,y) x(y,:), handles.tip_table.peak_coordinates(idx), handles.tip_table.peak_main(idx),'UniformOutput',false);
    peak1 = cat(1,peak1{:});
        peak2 = cellfun(@(x,y) x(y,:), handles.tip_table.peak_coordinates(idx2), handles.tip_table.peak_main(idx2),'UniformOutput',false);
    peak2 = cat(1,peak2{:});
    Vx1 = peak2(:,2)-peak1(:,2);
    Vy1 = peak2(:,1)-peak1(:,1);
    h = quiver(ax,peak1(:,2),peak1(:,1), ...
        Vx1*vector_size,Vy1*vector_size,'m','AutoScale','off');
    set(h, 'MaxHeadSize',max_head_size)
    set(h, 'Tag','tip_peak_peak_vector');
    h = plot(ax,peak1(:,2),peak1(:,1), ...
        'LineStyle','none','Marker','o','MarkerSize',marker_size,'MarkerEdgeColor','k','MarkerFaceColor','m');
    set(h, 'Tag','tip_peak_peak_vector')
end
if get(handles.chk_tip_plot_spk_spk_vector, 'value') && ~isempty(idx2) && ~isempty(handles.tip_table.spk(idx))
    Vx1 = handles.tip_table.spk(idx2,2)-handles.tip_table.spk(idx,2);
    Vy1 = handles.tip_table.spk(idx2,1)-handles.tip_table.spk(idx,1);
    h = quiver(ax,handles.tip_table.spk(idx,2),handles.tip_table.spk(idx,1), ...
        Vx1*vector_size,Vy1*vector_size,'c','AutoScale','off');
    set(h, 'MaxHeadSize',max_head_size)
    set(h, 'Tag','tip_spk_spk_vector');
    h = plot(ax,handles.tip_table.spk(idx,2),handles.tip_table.spk(idx,1), ...
        'LineStyle','none','Marker','o','MarkerSize',marker_size,'MarkerEdgeColor','k','MarkerFaceColor','c');
    set(h, 'Tag','tip_spk_spk_vector')
end

if get(handles.chk_tip_plot_OCC_apex_vector, 'value')
    Vx1 = handles.tip_table.OC_apex(idx,2)-handles.tip_table.OC_center(idx,2);
    Vy1 = handles.tip_table.OC_apex(idx,1)-handles.tip_table.OC_center(idx,1);
    h = quiver(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1), ...
        Vx1*OCC_vector_size,Vy1*OCC_vector_size,'g','AutoScale','off');
    set(h, 'MaxHeadSize',max_head_size)
    
    set(h, 'Tag','tip_OCC_apex_vector');
    h = plot(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1), ...
        'LineStyle','none','Marker','o','MarkerSize',marker_size,'MarkerEdgeColor','k','MarkerFaceColor','g');
    set(h, 'Tag','tip_OCC_apex_vector')
end
if get(handles.chk_tip_plot_OCC_peak_vector, 'value')
    peak = cellfun(@(x,y) x(y,:), handles.tip_table.peak_coordinates(idx), handles.tip_table.peak_main(idx),'UniformOutput',false);
    peak = cat(1,peak{:});
    Vx1 = peak(:,2)-handles.tip_table.OC_center(idx,2);
    Vy1 = peak(:,1)-handles.tip_table.OC_center(idx,1);
    h = quiver(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1), ...
        Vx1*OCC_vector_size,Vy1*OCC_vector_size,'m','AutoScale','off');
    set(h, 'MaxHeadSize',max_head_size)
    set(h, 'Tag','tip_OCC_peak_vector');
    h = plot(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1), ...
        'LineStyle','none','Marker','o','MarkerSize',marker_size,'MarkerEdgeColor','k','MarkerFaceColor','m');
    set(h, 'Tag','tip_OCC_peak_vector')
end

if get(handles.chk_tip_plot_OCC_spk_vector, 'value')
    Vx1 = handles.tip_table.spk(idx,2)-handles.tip_table.OC_center(idx,2);
    Vy1 = handles.tip_table.spk(idx,1)-handles.tip_table.OC_center(idx,1);
    h = quiver(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1), ...
        Vx1*OCC_vector_size,Vy1*OCC_vector_size,'c','AutoScale','off');
    set(h, 'MaxHeadSize',max_head_size)
    set(h, 'Tag','tip_OCC_spk_vector');
    h = plot(ax,handles.tip_table.OC_center(idx,2),handles.tip_table.OC_center(idx,1),'LineStyle','none','Marker','o','MarkerSize',marker_size,'MarkerEdgeColor','k','MarkerFaceColor','c');
    set(h, 'Tag','tip_OCC_spk_vector')
end
drawnow;

% --------------------------------------------------------------------------
% PROFILE PLOT OPTIONS
% --------------------------------------------------------------------------

function chk_tip_plot_profile_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot_profile(handles.ax_image,handles);
else
    fnc_tip_plot_erase(handles.ax_image,'tip_profile',handles)
end

function chk_tip_plot_profile_graph_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_plot_graph(handles)
else
    axes(handles.axes_profile_plot)
    cla
end

function chk_tip_profile_image_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    fnc_tip_profile_image(handles);
else
    axes(handles.axes_profile_image)
    h = findobj(handles.axes_profile_image,'type','scatter','Tag','tip_graph');
    delete(h);
end

function pop_tip_plot_Callback(hObject, eventdata, handles)
fnc_tip_profile_image(handles);
fnc_tip_plot_graph(handles);

function fnc_tip_plot_profile(ax,handles)
marker_size = str2double(get(handles.txt_plot_tip_marker_size,'String'));
P_length = str2double(get(handles.txt_tip_trace_distance, 'String'));
if get(handles.chk_tip_plot_profile, 'Value')
    nH = max(handles.tip_table.ID);
    iT = round(get(handles.sld_T, 'value'));
    for iH = 1:nH
        idx = handles.tip_table{:,'T'} == iT & handles.tip_table{:,'ID'} == iH;
        if handles.tip_table{idx,'active'} == 1
            % get values from the tip_table
            x = handles.tip_table.P{idx,1}(:,2);
            y = handles.tip_table.P{idx,1}(:,1);
            d = handles.tip_table.P_distance{idx,1};
            % select the profile length
            h = plot(ax,x(d<0),y(d<0),'y:');
            set(h, 'Tag','tip_profile');
            h = plot(ax,x(d==0),y(d==0),'r*');
            set(h, 'Tag','tip_profile');
            h = plot(ax,x(d>0),y(d>0),'b:');
            set(h, 'Tag','tip_profile');
            hold on
%             offset = round(((length(x)-(P_length*2)+1)/2)-1);
%             h = plot(ax,x(offset:P_length+offset),y(offset:P_length+offset),'y:');
%             set(h, 'Tag','tip_profile');
%             h = plot(ax,x(offset+P_length+1),y(offset+P_length+1),'r*');
%             set(h, 'Tag','tip_profile');
%             h = plot(ax,x(P_length+2:end-offset),y(P_length+2:end-offset),'b:');
%             set(h, 'Tag','tip_profile');
%             hold on
            %         xce = handles.tip_table{iH,iT}.xce;
            %         yce = handles.tip_table{iH,iT}.yce;
            %         crp = handles.tip_table{iH,iT}.crp;
            %         clp = handles.tip_table{iH,iT}.clp;
            %         [~,idx] = max(handles.tip_table{iH,iT}.ypfit);
            %         yp = handles.tip_table{iH,iT}.B_mean(idx,1);
            %         xp = handles.tip_table{iH,iT}.B_mean(idx,2);
            %         h = plot(ax,crp(:,2),crp(:,1),'y:');
            %         hold(ax, 'on')
            %         set(h, 'Tag','tip_profile')
            %         h = plot(ax,clp(:,2),clp(:,1),'b:');
            %         set(h, 'Tag','tip_profile')
            %         h = plot(ax,yce,xce,'go','MarkerSize',marker_size);
            %         set(h, 'Tag','tip_profile')
            %         h = plot(ax,[1 xp],[1 yp], 'mo','MarkerSize',marker_size);
            %         set(h, 'Tag','tip_profile')
            drawnow;
        end
    end
end

function fnc_tip_plot_graph(handles)
%fnc_tip_plot_erase(handles.axes_profile_plot,'tip_graph',handles)
% get channel and hypha to display
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
options = get(handles.pop_tip_plot,'String');
option_idx = get(handles.pop_tip_plot,'Value');
iH = str2double(options{option_idx});
iT = get(handles.sld_T, 'value');
iZ = get(handles.sld_Z, 'Value');
data = get(handles.uit_tip,'data');
first = cell2mat(data(iH,2));
last = cell2mat(data(iH,3));
if get(handles.chk_tip_plot_profile_graph, 'Value') == 1
    idx = handles.tip_table.T == iT & handles.tip_table.ID == iH;
    if handles.tip_table.active(idx) == 1
%         norm = max([handles.tip_table.P_mean{:}]);
        y = handles.tip_table.P_mean{idx};%./norm;
        y2 = smoothdata(y,'sgolay',15);
%         y2 = handles.tip_table.P_max{idx};%./norm;
        
        % get values from the results array
        x = handles.tip_table.P_distance{idx};
        axes(handles.axes_profile_plot);
        cla
        % set up the x-axes tick marks and labels
        nX = 11;
        mX = ceil(max(x));
        nXT = round(-mX:(2*mX)/(nX-1):mX);
        sXT = num2str((nXT.*handles.param.pixel_size(1))', 2);
        set(gca,'XTick',nXT,'XTickLabel',sXT,'FontUnits','pixels','FontSize',11);
        xlabel('profile position (µm)', 'FontSize',8);
        % fix the y limits and ticks
        set(gca, 'ylim',[0 1], 'yTick', [0:0.1:1]);
        ylabel('intensity', 'FontSize',8);
        % plot the profile and fit
        hold on
                        plot([0 0],[0 1], 'g:', 'linewidth',1,'Tag','tip_graph')
       plot(x,y,'bo','MarkerSize',3,'Tag','tip_graph');
        plot(x,y2,'b-','Tag','tip_graph');
        wxPk = handles.tip_table.peak_width_pos{idx};
        hm = handles.tip_table.peak_height{idx};
        n = length(hm);
        line(reshape([wxPk(:,1)'; wxPk(:,2)'; NaN(1,n)], 3*n, 1), ...
       reshape([(hm/2)'; (hm/2)'; NaN(1,n)], 3*n, 1), ...
       'Color','r','Tag','tip_graph');
        %plot(x,y2,'mo','MarkerSize',3,'Tag','tip_graph');
%         temp = handles.tip_table.peak_fit{idx};
%         temp.a1 = temp.a1/norm
%         if isfield(temp,'a2')
%         temp.a2 = temp.a2/norm
%         end
%         temp.d1 = temp.d1/norm
%         h = plot(handles.tip_table.peak_fit{idx});
       % h = plot(temp);
%        h.Tag = 'tip_graph';
%         % plot the position of the intensity
%         [~,idx2] = max(y);
%         plot([x(idx2) x(idx2)],[0 1], 'b-', 'linewidth',1,'Tag','tip_graph');
        %[~,idx2] = max(y2);
        %         plot([x(idx2) x(idx2)],[0 1], 'm-', 'linewidth',1,'Tag','tip_graph')
        plot([handles.tip_table.peak_displacement{idx}(:) handles.tip_table.peak_displacement{idx}(:)]',[zeros(handles.tip_table.peak_number(idx),1) hm]', 'r-', 'linewidth',1,'Tag','tip_graph')
        % plot the position of the apex

        %fnc_tip_table(handles)
        legend off
    else
        cla
    end
else
end

function fnc_tip_table(handles)
options = get(handles.pop_tip_plot,'String');
option_idx = get(handles.pop_tip_plot,'Value');
iH = str2double(options{option_idx});
temp = cell2mat(handles.tip_results);
time = handles.param.TimeStamps;
values = cat(1,temp(iH,:).fit_coefficients);
data = [time(1:size(values,1))', values];
set(handles.tab_data,'data',data, 'visible','on')

% --------------------------------------------------------------------------
% TIP PROFILE IMAGE
% --------------------------------------------------------------------------

function handles = fnc_tip_profile_image(handles)
% get channel and hypha to display
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
options = get(handles.pop_tip_plot,'String');
option_idx = get(handles.pop_tip_plot,'Value');
iH = str2double(options{option_idx});
iZ = get(handles.sld_Z, 'Value');
data = get(handles.uit_tip,'data');
first = cell2mat(data(iH,2));
last = cell2mat(data(iH,3));
idx = handles.tip_table.ID == iH;
% extract a consistant distance from the apex
Pidx = cellfun(@(x) x>=-30 & x<=30,handles.tip_table.P_distance,'UniformOutput',false);
P = cellfun(@(x,y) x(y)',handles.tip_table.P_mean(idx),Pidx(idx),'UniformOutput',false);
PT_mean = cat(1,P{:});
im_profile_interp = imresize(PT_mean,[151 301]);
% Display image, with zero time at the base
im_profile_interp = flip(im_profile_interp,1);
rgb_profile_interp = ind2rgb(uint8(im_profile_interp.*255/max(im_profile_interp(:))), jet(256));
axes(handles.axes_profile_image)
cla
hold off
imshow(rgb_profile_interp)
%imshow(im_profile_interp, [])
[m,n] = size(im_profile_interp);
hold on
% set up the x-axes tick marks and labels
nX = 11;
mX = size(im_profile_interp,2);
nXT = 1:(mX-1)/(nX-1):mX;
sXT = num2str(((-(n/2):n/(nX-1):n/2).*(size(PT_mean,2)./301).*handles.expt.micron_per_pixel(1))', '%2.0f');
set(gca,'XTick',nXT,'XTickLabel',sXT,'FontUnits','pixels','FontSize',11);
xlabel('profile position (µm)', 'FontSize',8)
% set up the y-axes tick marks and labels
%nY = handles.nT;
mY = size(im_profile_interp,1);
iY = round(mY./10);
%nYT = 1:(mY-1)/(nY-1):mY;
nYT = 1:iY:mY;
iY = round(handles.nT/10);
sYT = flipud(num2str((0:iY:handles.nT+1)'*handles.expt.time, 2));
set(gca,'YTick',nYT,'YTickLabel',sYT);
ylabel('time (min)', 'FontSize',8)
% plot the center line
plot([(mX+1)/2 (mX+1)/2],ylim,'k-')


function handles = fnc_tip_profile_image_old(handles)
% get channel and hypha to display
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
options = get(handles.pop_tip_plot,'String');
option_idx = get(handles.pop_tip_plot,'Value');
iH = str2double(options{option_idx});
iZ = get(handles.sld_Z, 'Value');
data = get(handles.uit_tip,'data');
first = cell2mat(data(iH,2));
last = cell2mat(data(iH,3));
idx = handles.tip_table.ID == iH;
PT_mean = cat(1,handles.tip_table.profile_mean{idx});
im_profile_interp = imresize(PT_mean,[151 301]);
% Display image, with zero time at the base
im_profile_interp = flip(im_profile_interp,1);
rgb_profile_interp = ind2rgb(uint8(im_profile_interp.*255/max(im_profile_interp(:))), jet(256));
axes(handles.axes_profile_image)
cla
hold off
imshow(rgb_profile_interp)
%imshow(im_profile_interp, [])
[m,n] = size(im_profile_interp);
hold on
% set up the x-axes tick marks and labels
nX = 11;
mX = size(im_profile_interp,2);
nXT = 1:(mX-1)/(nX-1):mX;
sXT = num2str(((-(n/2):n/(nX-1):n/2).*(size(PT_mean,2)./301).*handles.expt.micron_per_pixel(1))', '%2.0f');
set(gca,'XTick',nXT,'XTickLabel',sXT,'FontUnits','pixels','FontSize',11);
xlabel('profile position (µm)', 'FontSize',8)
% set up the y-axes tick marks and labels
%nY = handles.nT;
mY = size(im_profile_interp,1);
iY = round(mY./10);
%nYT = 1:(mY-1)/(nY-1):mY;
nYT = 1:iY:mY;
iY = round(handles.nT/10);
sYT = flipud(num2str((0:iY:handles.nT+1)'*handles.expt.time, 2));
set(gca,'YTick',nYT,'YTickLabel',sYT);
ylabel('time (min)', 'FontSize',8)
% plot the center line
plot([(mX+1)/2 (mX+1)/2],ylim,'k-')

% range = ~cellfun(@(x) isempty(x),handles.tip_table)
% if isfield(handles,'tip_table') && ~isempty(handles.tip_table)
%     assignin('base','results',handles.tip_table)
%
%     % extract the profile co-ordinates (length by x,y by time)
%     coords = cat(3,handles.tip_table);
%     % reshape to give time x length arrays
%     Bx1 = squeeze(coords(:,1,:))';
%     By1 = squeeze(coords(:,2,:))';
%     % get the image
%     ims = double(squeeze(handles.images.subtracted(:,:,iC,iZ,:)));
%     % get average image intensity to correct for overall fluctuations in image intensity
%     w = squeeze(mean(mean(ims)));
%     % allow sampling at non-integer pixel values
%     [x,y] = meshgrid(1:handles.nX,1:handles.nY);
%     im_profile = zeros(size(Bx1));
%     for iT = 1:handles.nT
%         xi = Bx1(iT,:);
%         yi = By1(iT,:);
%         im_profile(iT,:) = interp2(x,y,double(ims(:,:,iT)),yi,xi);
%         %normalise intensity to the average for the image
%         im_profile(iT,:) = im_profile(iT,:)./w(iT);
%         %im_profile(iT,:) = im_profile(iT,:)./mean(im_profile(iT,:));
%     end
%     % Interpolate by a factor of 5 in x and keep the aspect ratio to 1:2 with the same axes scaling
%     [m,n] = size(im_profile);
%     dx = 0.2;
%     dy = dx.*2.*m/n;
%     [x,y] = meshgrid(1:n,1:m);
%     [xi,yi] = meshgrid(1:dx:n,1:dy:m);
%     im_profile_interp = interp2(x,y,im_profile,xi,yi);
%     % Smooth
%     h = fspecial('gaussian',6*2,2);
%     im_profile_interp = imfilter(im_profile_interp,h);
%     % Display image, with zero time at the base
%     im_profile_interp = flip(im_profile_interp,1);
%     rgb_profile_interp = ind2rgb(uint8(im_profile_interp.*255/max(im_profile_interp(:))), jet(256));
%     axes(handles.axes_profile_image)
%     hold off
%     imshow(rgb_profile_interp)
%     %imshow(im_profile_interp, [])
%     hold on
%     % set up the x-axes tick marks and labels
%     nX = 11;
%     mX = size(im_profile_interp,2);
%     nXT = 1:(mX-1)/(nX-1):mX;
%     sXT = num2str(((-(n/2):n/(nX-1):n/2).*handles.param.pixel_size(1))', 2);
%     set(gca,'XTick',nXT,'XTickLabel',sXT,'FontUnits','pixels','FontSize',11);
%     xlabel('profile position (µm)', 'FontSize',8)
%     % set up the y-axes tick marks and labels
%     %nY = handles.nT;
%     mY = size(im_profile_interp,1);
%     iY = round(mY./10);
%     %nYT = 1:(mY-1)/(nY-1):mY;
%     nYT = 1:iY:mY;
%     iY = round(handles.nT/10);
%     sYT = flipud(num2str((0:iY:handles.nT+1)'*0.25, 2));
%     set(gca,'YTick',nYT,'YTickLabel',sYT);
%     ylabel('time (min)', 'FontSize',8)
%     % plot the center line
%     plot([(mX+1)/2 (mX+1)/2],ylim,'k-')
% end


% -------------------------------------------------------------------------
% GRAPH PLOT
% -------------------------------------------------------------------------

function pop_plot_array_Callback(hObject, eventdata, handles)
handles = fnc_plot_target(handles);
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function pop_plot_target_Callback(hObject, eventdata, handles)
handles = fnc_plot_target(handles);
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function pop_plot_type_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function chk_plot_hold_Callback(hObject, eventdata, handles)

function pop_plot_units_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function chk_plot_y_log_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function chk_plot_x_log_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function chk_plot_y_diff_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot,handles);
guidata(hObject, handles);

function chk_plot_x_diff_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot,handles);
guidata(hObject, handles);

function pop_plot_y_channel_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function pop_plot_y_axis_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function pop_plot_x_channel_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function pop_plot_x_axis_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function pop_plot_y_T_offset_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot,handles);
guidata(hObject, handles);

function pop_plot_x_T_offset_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot,handles);
guidata(hObject, handles);

function pop_plot_colormap_Callback(hObject, eventdata, handles)
handles = fnc_plot_results(handles.axes_profile_plot, handles);
guidata(hObject, handles);

function btn_plot_clear_Callback(hObject, eventdata, handles)
axes(handles.axes_profile_plot)
h = findobj(gca,'-not','type', 'axes','-not','type','image');
delete(h)

function handles = fnc_plot_target(handles)
% Sets the dropdown menu options for plotting a graph
% cords and nodes - gives options for edges and nodes
% polygons - gives options for inter-cord regions
% features - gives options for features
% HLD - plots the hierarchical decomposition tree
% the selection also updates the x and y axis titles
options = get(handles.pop_plot_target, 'string');
options_idx = get(handles.pop_plot_target, 'value');
target = options{options_idx};
% get the edge metric for display
lookup = handles.reference_table;
names = [{' '}];
switch target
    case 'tips'
        idx = ismember(lookup.object,'tips');
        names = lookup.parameter(idx);       
end
set(handles.pop_plot_x_axis, 'String',names,'Value',1);
set(handles.pop_plot_y_axis, 'String',names, 'Value',1);


function handles = fnc_plot_results(ax,handles)
% clear the axes
axes(ax);
axis normal
if get(handles.chk_plot_hold, 'Value')
    hold on
else
    cla
    hold off
end
% get the frame and section
iT = round(get(handles.sld_T, 'value'));
iZ = round(get(handles.sld_Z, 'value'));
% get the control settings
options = get(handles.pop_plot_array, 'string');
options_idx = get(handles.pop_plot_array, 'value');
array = options{options_idx};
options = get(handles.pop_plot_y_channel, 'string');
options_idx = get(handles.pop_plot_y_channel, 'value');
yC = str2double(options{options_idx});
options = get(handles.pop_plot_x_channel, 'string');
options_idx = get(handles.pop_plot_x_channel, 'value');
xC = str2double(options{options_idx});
options = get(handles.pop_plot_y_T_offset, 'string');
options_idx = get(handles.pop_plot_y_T_offset, 'value');
yT_offset = str2double(options{options_idx});
options = get(handles.pop_plot_x_T_offset, 'string');
options_idx = get(handles.pop_plot_x_T_offset, 'value');
xT_offset = str2double(options{options_idx});
options = get(handles.pop_plot_units, 'string');
options_idx = get(handles.pop_plot_units, 'value');
units = options{options_idx};
options = get(handles.pop_plot_target, 'string');
options_idx = get(handles.pop_plot_target, 'value');
target = options{options_idx};
options = get(handles.pop_plot_x_axis, 'string');
options_idx = get(handles.pop_plot_x_axis, 'value');
x_var = options{options_idx};
options = get(handles.pop_plot_y_axis, 'string');
options_idx = get(handles.pop_plot_y_axis, 'value');
y_var = options{options_idx};
options = get(handles.pop_plot_type, 'string');
options_idx = get(handles.pop_plot_type, 'value');
plot_type = options{options_idx};
% options = get(handles.pop_plot_colormap, 'string');
% options_idx = get(handles.pop_plot_colormap, 'value');
% cmap = options{options_idx};
% colormap(handles.axes_profile_plot,cmap)
% get the appropriate variables
[nY,nX,nC,nZ,nT] = size(handles.images.subtracted);
X = [];
Y = [];
switch target
    case 'profile'
        fnc_profile_plot(handles)
    otherwise
        lookup = handles.reference_table;
        switch plot_type
            case 'time'
                nV = 1;
                x_label = 'time  (s)';
                X = handles.tip_table.T.*handles.expt.time;
            case {'1D hist';'1D hist all'}
                nV = 1;
            case {'scatter';'scatter all';'2D hist';'2D hist all'}
                nV = 2;
        end 
        for variable = 1:nV
            if variable == 1
                metric = y_var;
                idx = ismember(lookup.parameter,metric);
                iC = yC;
            else
                metric = x_var;
                idx = ismember(lookup.parameter,metric);
                iC = xC;
            end
            % get the edge metric for the axis labels
            label = lookup.label{idx};
            % get the units for labelling
            switch units
                case 'pixels'
                    label_units = lookup.pixels{idx};
                    scaling = 1;
                case 'microns'
                    label_units = lookup.microns{idx};
                    scaling = (handles.expt.micron_per_pixel).^lookup.scaling_coefficient(idx);
                case 'mm'
                    label_units = lookup.mm{idx};
                    scaling = (handles.expt.micron_per_pixel./1000).^lookup.scaling_coefficient(idx);
            end
            if variable == 1
                if get(handles.chk_plot_y_log, 'Value')
                    if get(handles.chk_plot_y_diff, 'Value')
                        y_label = ['log_{10} \Delta' label ' ' label_units];
                    else
                        y_label = ['log_{10} ' label ' ' label_units];
                    end
                else
                    if get(handles.chk_plot_y_diff, 'Value')
                        y_label = ['\Delta' label ' ' label_units];
                    else
                        y_label = [label ' ' label_units];
                    end
                end
            else
                if get(handles.chk_plot_x_log, 'Value')
                    if get(handles.chk_plot_x_diff, 'Value')
                        x_label = ['log_{10} \Delta' label ' ' label_units];
                    else
                        x_label = ['log_{10} ' label ' ' label_units];
                    end
                else
                    if get(handles.chk_plot_x_diff, 'Value')
                        x_label = ['\Delta' label ' ' label_units];
                    else
                        x_label = [label ' ' label_units];
                    end
                end
            end            
            % now get the data
            switch array
                case 'tip_table'
                    T = handles.tip_table;
            end
            switch target
                case 'tips'
                    switch plot_type
                        case 'time'
                            nH = max(T.ID);
                            val = zeros(nT,nH);
                            X = zeros(nT,nH);
                            for iH = 1:nH
                                val(:,iH) = T.(metric)(T.ID==iH);
                                X(:,iH) = T.T(T.ID==iH);
                            end
                            Y = val.*scaling;
                        case {'1D hist all';'scatter all';'2D hist all'}
                            Hall = T{:,metric}.*scaling;
                            if variable == 1
                                Y = Hall;
                            else
                                X = Hall;
                            end
                        otherwise
                            H_idx = handles.tip_table.ID == 1;
                            if variable == 1
                                sT = iT+yT_offset;
                                if get(handles.chk_plot_y_diff, 'Value')
                                    Y = (T{H_idx,metric}-T{H_idx,metric}).*scaling;
                                else
                                    Y = T{H_idx,metric}.*scaling;
                                end
                            else
                                sT = iT+xT_offset;
                                if get(handles.chk_plot_x_diff, 'Value')
                                    X = (T{H_idx,metric}-T{H_idx,metric}).*scaling;
                                else
                                    X = T{H_idx,metric}.*scaling;
                                end
                            end
                            
                    end
            end
        end
            if ~isempty(Y)
                switch plot_type
                    case {'scatter';'time';'scatter all'}
                        if get(handles.chk_plot_y_log, 'Value')
                            Y = log10(Y);
                        end
                        if get(handles.chk_plot_x_log, 'Value')
                            X = log10(X);
                        end
                        switch plot_type
                            case 'time'
                                plot(X,Y,'-')
                            otherwise
                                scatter(X,Y,'.')
                        end
                        ylabel(y_label, 'interpreter','tex')
                        xlabel(x_label, 'interpreter','tex')
                    case {'1D hist';'1D hist all'}
                        if get(handles.chk_plot_y_log, 'Value')
                            histogram(log10(Y), 20,'FaceAlpha',1,'EdgeColor','k')
                        else
                            histogram(Y, 20,'FaceAlpha',1,'EdgeColor','k')
                        end
                        xlabel(y_label, 'interpreter','tex')
                        ylabel 'frequency'
                    case '2D hist'
                        if get(handles.chk_plot_y_log, 'Value')
                            Y = log10(Y);
                        end
                        if get(handles.chk_plot_x_log, 'Value')
                            X = log10(X);
                        end
                        histogram2(X,Y)
                        xlabel(x_label, 'interpreter','tex')
                        ylabel(y_label, 'interpreter','tex')
                    case 'cum. prod'
                        Y = sort(Y,'ascend');
                        Ycs = cumsum(Y);
                        if get(handles.chk_plot_y_log, 'Value')
                            Y1 = log10((max(Ycs)-Ycs)./max(Ycs));
                        else
                            Y1 = (max(Ycs)-Ycs)./max(Ycs);
                        end
                        if get(handles.chk_plot_x_log, 'Value')
                            X = log10(Y);
                        else
                            X = Y;
                        end
                        scatter(X,Y1,'k.')
                        xlabel(y_label, 'interpreter','tex')
                        ylabel(['cum. dist.' y_label], 'interpreter','tex')
                end
                set(gca,'FontName','Helvetica','FontUnits','pixels','FontSize',11, 'Box','on');
            end
            handles.X = X;
            handles.Y = Y;
end

function btn_test_Callback(hObject, eventdata, handles)
%handles = fnc_controls_options(handles);
%handles = fnc_optical_flow_run(handles);
handles = fnc_boundary_profile(handles);
assignin('base','images',handles.images)
assignin('base','tip_table',handles.tip_table)
guidata(gcbo, handles);

function handles = fnc_optical_flow_run(handles)
handles.param.optical_flow_method = 'Farneback';
handles = fnc_optical_flow_parameters(handles);
[handles.images.optical_flow_magnitude, ...
    handles.images.optical_flow_orientation, ...
    handles.images.optical_flow_Vx, ...
    handles.images.optical_flow_Vy, ...
    handles.images.optical_flow_rgb, ...
    handles.images.optical_flow_dir_rgb, ...
    handles.images.optical_flow_curlz, ...
    handles.images.optical_flow_curlz_rgb, ...
    handles.images.optical_flow_cav, ...
    handles.images.optical_flow_cav_rgb, ...
    handles.images.optical_flow_div, ...
    handles.images.optical_flow_div_rgb] = ...
    fnc_optical_flow(handles.images.subtracted,handles.images.mask,handles.expt, handles.param);
handles.images.test = handles.images.optical_flow_rgb;
guidata(gcbo, handles);
assignin('base','images',handles.images)

function handles = fnc_optical_flow_parameters(handles)
handles.param.optical_flow_Farneback_NumPyramidLevels = 4;
handles.param.optical_flow_Farneback_PyramidScale = 0.5;
handles.param.optical_flow_Farneback_NumIterations = 3;
handles.param.optical_flow_Farneback_NeighborhoodSize = 3;
handles.param.optical_flow_Farneback_FilterSize = 5;
handles.param.optical_flow_min = 0;
handles.param.optical_flow_max = 15;
handles.param.optical_flow_white = 1;
% switch handles.param.optical_flow_method
%     case {'Farneback'; 'LKPR'}
%         handles.param.optical_flow_Farneback_NumPyramidLevels = str2double(get(handles.txt_optical_flow_pyramid_levels, 'String'));
%         handles.param.optical_flow_Farneback_PyramidScale = str2double(get(handles.txt_optical_flow_pyramid_scale, 'String'));
%         handles.param.optical_flow_Farneback_NumIterations = str2double(get(handles.txt_optical_flow_iterations, 'String'));
%         handles.param.optical_flow_Farneback_NeighborhoodSize = str2double(get(handles.txt_optical_flow_nhood, 'String'));
%         handles.param.optical_flow_Farneback_FilterSize = str2double(get(handles.txt_optical_flow_filter_size, 'String'));
%     case 'Horn-Schunck'
%         handles.param.optical_flow_HS_Smoothness = str2double(get(handles.txt_optical_flow_pyramid_levels, 'String'));
%         handles.param.optical_flow_HS_MaxIteration = str2double(get(handles.txt_optical_flow_pyramid_scale, 'String'));
%         handles.param.optical_flow_HS_VelocityDifference = str2double(get(handles.txt_optical_flow_iterations, 'String'));
%     case 'Lucas-Kanade'
%         handles.param.optical_flow_LK_NoiseThreshold = str2double(get(handles.txt_optical_flow_pyramid_levels, 'String'));
%     case 'Lucas-Kanade-DoG'
%         handles.param.optical_flow_LKDoG_NumFrames = str2double(get(handles.txt_optical_flow_pyramid_levels, 'String'));
%         handles.param.optical_flow_LKDoG_ImageFilterSigma = str2double(get(handles.txt_optical_flow_pyramid_scale, 'String'));
%         handles.param.optical_flow_LKDoG_GradientFilterSigma = str2double(get(handles.txt_optical_flow_iterations, 'String'));
%         handles.param.optical_flow_LKDoG_NoiseThreshold = str2double(get(handles.txt_optical_flow_nhood, 'String'));
% end



function [magnitude, orientation, Vx, Vy, ...
    optical_flow_rgb, optical_flow_dir_rgb, ...
    curlz, curlz_rgb, ...
    cav, cav_rgb, ...
    div, div_rgb] = fnc_optical_flow(im_in,mask_in,expt,param)

[nY,nX,nC,nZ,nT] = size(im_in);
[~,~,mC,mZ,mT] = size(mask_in);
% normalise the input image
im_in = mat2gray(im_in);
im_in = im_in.*mask_in;
% set up blank arrays with two extra frames at the end. The last one will remain blank.
Vx = zeros([nY,nX,nC,nZ,nT+1],'single');
Vy = zeros([nY,nX,nC,nZ,nT+1],'single');
magnitude = zeros([nY,nX,nC,nZ,nT+1],'single');
orientation = zeros([nY,nX,nC,nZ,nT+1],'single');
curlz = nan([nY,nX,nC,nZ,nT],'single');
cav = nan([nY,nX,nC,nZ,nT],'single');
div = nan([nY,nX,nC,nZ,nT],'single');
optical_flow_rgb = zeros([nY,nX,3,nC,nZ,nT],'uint8');
optical_flow_dir_rgb = zeros([nY,nX,3,nC,nZ,nT],'uint8');
curlz_rgb = zeros([nY,nX,3,nC,nZ,nT],'uint8');
cav_rgb = zeros([nY,nX,3,nC,nZ,nT],'uint8');
div_rgb = zeros([nY,nX,3,nC,nZ,nT],'uint8');
% get the parameters for the chosen method
switch param.optical_flow_method
    case 'Farneback'
        % Farneback defaults:
        % 'NumPyramidLevels',3
        % 'PyramidScale',0.5
        % 'NumIterations',3'
        % 'NeighborhoodSize',5
        % 'FilterSize',15
        opticFlow = opticalFlowFarneback( ...
            'NumPyramidLevels',param.optical_flow_Farneback_NumPyramidLevels, ...
            'PyramidScale',param.optical_flow_Farneback_PyramidScale, ...
            'NumIterations',param.optical_flow_Farneback_NumIterations, ...
            'NeighborhoodSize',param.optical_flow_Farneback_NeighborhoodSize, ...
            'FilterSize',param.optical_flow_Farneback_FilterSize);
    case 'Horn-Schunck'
        % default parameters for Horn-Schunck
        % 'Smoothness', 1,
        % 'MaxIteration',10,
        % 'VelocityDifference', 0
        opticFlow = opticalFlowHS( ...
            'Smoothness',param.optical_flow_HS_Smoothness, ...
            'MaxIteration',param.optical_flow_HS_MaxIteration, ...
            'VelocityDifference',param.optical_flow_HS_VelocityDifference);
    case 'Lucas-Kanade'
        % defaults for Lucas-Kanade
        % 'NoiseThreshold', 0.0039
        opticFlow = opticalFlowLK( ...
            'NoiseThreshold',param.optical_flow_LK_NoiseThreshold);
    case 'Lucas-Kanade-DoG'
        % defaults for Lucas-Kanade-DoG
        % 'NumFrames,3,
        % 'ImageFilterSigma', 1.5,
        % 'GradientFilterSigma', 1,
        % 'NoiseThreshold', 0.0039
        opticFlow = opticalFlowLKDoG( ...
            'NumFrames',param.optical_flow_LKDoG_NumFrames, ...
            'ImageFilterSigma', param.optical_flow_LKDoG_ImageFilterSigma, ...
            'GradientFilterSigma', param.optical_flow_LKDoG_GradientFilterSigma, ...
            'NoiseThreshold',param.optical_flow_LKDoG_NoiseThreshold);
end
% load a dummy frame at the start. This sets the internal reference for the
% optical flow to the first frame rather than zeros. Add a dummy frame of
% nans at the end so that the whole array can be time shifted to show the
% results for deltaT in the first frame.
im_in = cat(5,im_in,im_in(:,:,:,:,end));
hwb2 = waitbar(0,'Calculating optical flow. Please wait...','Name','Optical flow','WindowStyle','modal');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);
pos = get(hwb2,'OuterPosition');
set(hwb2,'OuterPosition',[pos(1) pos(2)-pos(4) pos(3) pos(4)]);
for iT = 1:nT+1
    for iZ = 1:nZ
        for iC= 1:nC
            % calculate the optical flow and correct the timebase to units
            % of experimental time
            waitbar(iT/nT,hwb2,['Calculating optical flow. Please wait...'])
            switch param.optical_flow_method
                case 'LKPR'
                    NumPyramidLevels = param.optical_flow_Farneback_NumPyramidLevels;
                    NumIterations = param.optical_flow_Farneback_NumIterations;
                    NeighborhoodSize = param.optical_flow_Farneback_NeighborhoodSize;
                    alpha = 0.001;
                    if iT >1
                        [Vx(:,:,iC,iZ,iT), Vy(:,:,iC,iZ,iT)] = LKPR_MDF(im_in(:,:,iC,iZ,iT-1),im_in(:,:,iC,iZ,iT),NumPyramidLevels,NumIterations,NeighborhoodSize,alpha);
                        % calibrate in microns
                        Vx = Vx.*param.resample.*expt.micron_per_pixel;
                        Vy = Vy.*param.resample.*expt.micron_per_pixel;
                        magnitude(:,:,iC,iZ,iT) = hypot(Vx(:,:,iC,iZ,iT),Vy(:,:,iC,iZ,iT));
                        orientation(:,:,iC,iZ,iT) = atan2(Vy(:,:,iC,iZ,iT),Vx(:,:,iC,iZ,iT));
                    end
                otherwise
                    flow = estimateFlow(opticFlow,im_in(:,:,iC,iZ,iT));
                    % calibrate measurements in microns
                    Vx(:,:,iC,iZ,iT) = flow.Vx;%.*expt.micron_per_pixel/expt.time;
                    Vy(:,:,iC,iZ,iT) = flow.Vy;%.*expt.micron_per_pixel/expt.time;
                    magnitude(:,:,iC,iZ,iT) = flow.Magnitude;%.*expt.micron_per_pixel./expt.time;
                    orientation(:,:,iC,iZ,iT) = flow.Orientation;
            end
        end
    end
end
delete(hwb2)
% delete the first frame (the initial zero velocity frame) leaving a blank
% frame at the end
magnitude(:,:,:,:,1) = [];
orientation(:,:,:,:,1) = [];
Vx(:,:,:,:,1) = [];
Vy(:,:,:,:,1) = [];
magnitude(:,:,:,:,end) = nan;
orientation(:,:,:,:,end) = nan;
Vx(:,:,:,:,end) = nan;
Vy(:,:,:,:,end) = nan;

if param.optical_flow_max == 0
    % find the min and max for normalisation
    y = quantile(magnitude(:),[0.005 0.995]);
    mn = y(1);
    mx = y(2);
else
    mn = param.optical_flow_min;
    mx = param.optical_flow_max;
end
% construct a colour-coded optical flow image
hwb2 = waitbar(0,'Calculating colour-coded optical flow image. Please wait...','Name','Optical flow','WindowStyle','modal');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);
pos = get(hwb2,'OuterPosition');
set(hwb2,'OuterPosition',[pos(1) pos(2)-pos(4) pos(3) pos(4)]);

for iT = 1:nT-1
    for iZ = 1:nZ
        for iC = 1:nC
            waitbar(iT/nT,hwb2,['Calculating colour-coded optical flow image. Please wait...'])
            % calculate the curl and divergence
            [curlz1,cav1] = curl(Vx(:,:,iC,iZ,iT),Vy(:,:,iC,iZ,iT));
            curlz(:,:,iC,iZ,iT) = single(curlz1.*mask_in(:,:,min(mC,iC),min(mZ,iZ),min(mT,iT)));
            cav(:,:,iC,iZ,iT) = single(cav1.*mask_in(:,:,min(mC,iC),min(mZ,iZ),min(mT,iT)));
            div1 = divergence(Vx(:,:,iC,iZ,iT),Vy(:,:,iC,iZ,iT));
            div(:,:,iC,iZ,iT) = single(div1.*mask_in(:,:,min(mC,iC),min(mZ,iZ),min(mT,iT)));
            % normalise the magnitude
            M = squeeze(single(mat2gray(magnitude(:,:,iC,iZ,iT), double([mn mx]))));
            M = 0.7 - M*0.7;
            % normalise the orientation
            O = squeeze(single(mat2gray(orientation(:,:,iC,iZ,iT), [-pi pi])));
            % construct an HSV image
            V = single(mat2gray(max(im_in(:,:,iC,iZ,iT),im_in(:,:,iC,iZ,iT+1)))).*mask_in(:,:,min(mC,iC),min(mZ,iZ),min(mT,iT));
            V = imadjust(V);
            % normalise curl and divergence
            C = squeeze(single(mat2gray(curlz(:,:,iC,iZ,iT), [-pi/8 pi/8])));
            AV = squeeze(single(mat2gray(cav(:,:,iC,iZ,iT), [-pi/8 pi/8])));
            D = squeeze(single(mat2gray(div(:,:,iC,iZ,iT), [-pi/8 pi/8])));
            % convert to RGB using a lookup table, then convert to HSV
            cmap = colorcet('D7');
            C_hsv = rgb2hsv(ind2rgb(uint8(C.*255),cmap));
            AV_hsv = rgb2hsv(ind2rgb(uint8(AV.*255),cmap));
            cmap = colorcet('D13');
            D_hsv = rgb2hsv(ind2rgb(uint8(D.*255),cmap));
            % set up a full image
            W = ones(size(M));
            if param.optical_flow_white == 0
                optical_flow_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,M,W,V)));
                optical_flow_dir_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,O,W,V)));
                curlz_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,C_hsv(:,:,1:2),V)));
                cav_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,AV_hsv(:,:,1:2),V)));
                div_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,D_hsv(:,:,1:2),V)));
            else
                optical_flow_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,M,V,W)));
                optical_flow_dir_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,O,V,W)));
                curlz_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,C_hsv(:,:,1:2),(V.*0.625+W.*0.375))));
                cav_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,AV_hsv(:,:,1:2),(V.*0.625+W.*0.375))));
                div_rgb(:,:,1:3,iC,iZ,iT) = uint8(255.*hsv2rgb(cat(3,D_hsv(:,:,1:2),(V.*0.625+W.*0.375))));
            end
        end
    end
end
% mask out regions using the mask values from both frames, except for the
% last one
mask_in(:,:,:,:,1:end-1) = mask_in(:,:,:,:,1:end-1) & mask_in(:,:,:,:,2:end);
Vx = Vx.*mask_in;
Vy = Vy.*mask_in;
magnitude = magnitude.*mask_in;
orientation = orientation.*mask_in;
delete(hwb2)


% -------------------------------------------------------------------------
% TIP DATA OUTPUT
% -------------------------------------------------------------------------

function btn_save_profile_image_Callback(hObject, eventdata, handles)
set(handles.stt_status,'String','Saving current profile image. Please wait...')
cd(handles.dir_out_images)
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
fnc_tip_profile_image(handles);
export_fig(['profile_image_C' num2str(iC)],'-png','-pdf',handles.uip_profile_image)
cd(handles.dir_in)
set(handles.stt_status,'String','Current profile image saved')

function btn_save_profile_plot_Callback(hObject, eventdata, handles)
set(handles.stt_status,'String','Saving current profile plot. Please wait...')
cd(handles.dir_out_images)
options = get(handles.pop_tip_trace_channel, 'string');
options_idx = get(handles.pop_tip_trace_channel, 'value');
iC = str2double(options{options_idx});
iT = get(handles.sld_T,'Value');
fnc_tip_plot_graph(handles);
export_fig(['profile_plot_C' num2str(iC) '_T' num2str(iT)],'-png','-pdf',handles.uip_profile_plot)
cd(handles.dir_in)
set(handles.stt_status,'String','Current profile plot saved')

% -------------------------------------------------------------------------
% DISPLAY IMAGE
% -------------------------------------------------------------------------
function pop_display_image_channel_Callback(hObject, eventdata, handles)
% handles = fnc_thumbnail_display('all',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function pop_display_image_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function pop_display_merge_channel_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function pop_display_merge_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function pop_display_merge_method_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function chk_display_R_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);

function chk_display_G_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);

function chk_display_B_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);

function btn_display_switch_Callback(hObject, eventdata, handles)
% get current channel values
T1_options = get(handles.pop_display_image_channel, 'String');
T1_option_index = get(handles.pop_display_image_channel, 'Value');
T1 = T1_options{T1_option_index};
T2_options = get(handles.pop_display_merge_channel, 'String');
T2_option_index = get(handles.pop_display_merge_channel, 'Value');
T2 = T2_options{T2_option_index};
% switch channels
set(handles.pop_display_image_channel, 'Value',find(strcmpi(T1_options,T2)));
set(handles.pop_display_merge_channel, 'Value',find(strcmpi(T2_options,T1)));
% get current target values
T1_options = get(handles.pop_display_image, 'String');
T1_option_index = get(handles.pop_display_image, 'Value');
T1 = T1_options{T1_option_index};
T2_options = get(handles.pop_display_merge, 'String');
T2_option_index = get(handles.pop_display_merge, 'Value');
T2 = T2_options{T2_option_index};
% switch over
switch T2
    case 'none'
        % don't switch as there is no image to display
    otherwise
        set(handles.pop_display_image, 'Value',find(strcmpi(T1_options,T2)));
        set(handles.pop_display_merge, 'Value',find(strcmpi(T2_options,T1)));
end
% update the displays
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function chk_display_merge_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);

function pop_image_colormap_Callback(hObject, eventdata, handles)
options = get(handles.pop_image_colormap, 'String');
option_index = get(handles.pop_image_colormap, 'Value');
cmaps = options{option_index};
switch cmaps
    case {'L1';'L3';'L7';'L8';'L9';'D2';'D3';'D7';'R2'}
        cmap = colorcet(cmaps);
    otherwise
        cmap = colormap(cmaps);
end
cmap(1,:) = 0;
if ~isgraphics(handles.h_colorbar)
    % recreate the colorbar
    handles.h_colorbar = colorbar(handles.ax_colorbar,'location','east','TickDirection','out','TickLength',0.02,'FontSize',8);
end
colormap(handles.ax_colorbar,cmap)
fnc_display_image(handles);

function chk_T_max_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);

function chk_Z_max_Callback(hObject, eventdata, handles)
handles = fnc_display_image(handles);

function handles = fnc_display_image(handles)
options = get(handles.pop_display_image_channel, 'String');
option_index = get(handles.pop_display_image_channel, 'Value');
iC = str2double(options{option_index});
options = get(handles.pop_display_merge_channel, 'String');
option_index = get(handles.pop_display_merge_channel, 'Value');
mC = str2double(options{option_index});
% get the image array
options = get(handles.pop_display_image, 'String');
option_index = get(handles.pop_display_image, 'Value');
target = options{option_index};
% get the merge array
options = get(handles.pop_display_merge, 'String');
option_index = get(handles.pop_display_merge, 'Value');
merge = options{option_index};
% get the channel merge
options = get(handles.pop_display_merge_channel, 'String');
option_index = get(handles.pop_display_merge_channel, 'Value');
ch_merge = options{option_index};
if get(handles.chk_display_merge, 'value') == 0
    % the merge flag overrides the merge selection
    merge = 'none';
end
% get the merge method
options = get(handles.pop_display_merge_method, 'String');
option_index = get(handles.pop_display_merge_method, 'Value');
method = options{option_index};
% get the colormap
options = get(handles.pop_image_colormap, 'String');
option_index = get(handles.pop_image_colormap, 'Value');
cmaps = options{option_index};
% get the frame and section
iT = round(get(handles.sld_T, 'value'));
iZ = round(get(handles.sld_Z, 'value'));
% the merge flag overrides the merge selection
if get(handles.chk_display_merge, 'value') == 0
    merge = 'none';
end
% set the text to display
% if strcmp(merge,'none')
%     set(handles.stt_status, 'String', ['Displaying ' target ' image from channel ' num2str(iC)]);drawnow;
% else
%     set(handles.stt_status, 'String', ['Displaying merge between ' target ' image and ' merge ' image']);drawnow;
% end
% get the colormap
switch cmaps
    case {'L1';'L3';'L7';'L9';'D2';'D3';'D7';'R2'}
        cmap = colorcet(cmaps);
    otherwise
        cmap = colormap([cmaps '(256)']);
end
% check which channels to display
rgb_channels = [get(handles.chk_display_R, 'Value') get(handles.chk_display_G, 'Value') get(handles.chk_display_B, 'Value')];
% get the main image
switch target
    case {'raw';'initial';'filtered';'subtracted';'rotated'}
        sz = size(handles.images.(target));
        if length(sz) > 2
            if sz(3) == 1
                im_out = zeros(sz(1),sz(2),1,'like',handles.images.(target));
            else
                im_out = zeros(sz(1),sz(2),3,'like',handles.images.(target));
            end
            for sC = 1:min(3,sz(3))
                % only display a maximum of the first 3 channels
                switch target
                    case 'raw'
                        Cidx = [handles.param.ch1 handles.param.ch2 handles.param.ch3 handles.param.ch4 handles.param.ch5];
                        if get(handles.chk_T_max,'Value')
                            im_out(:,:,sC) = squeeze(max(handles.images.(target)(:,:,Cidx(sC),iZ,1:handles.T_inc:sz(5)),[],5).*rgb_channels(sC));
                        else
                            im_out(:,:,sC) = squeeze(handles.images.(target)(:,:,Cidx(sC),iZ,iT).*rgb_channels(sC));
                        end
                    otherwise
                        if get(handles.chk_T_max,'Value')
                            im_out(:,:,sC) = squeeze(max(handles.images.(target)(:,:,sC,iZ,1:handles.T_inc:sz(5)),[],5).*rgb_channels(sC));
                        else
                            im_out(:,:,sC) = squeeze(handles.images.(target)(:,:,sC,iZ,iT).*rgb_channels(sC));
                        end
                end
            end
        else
            im_out = zeros(sz(1),sz(2),1,'like',handles.images.(target));
            im_out(:,:,1) = squeeze(handles.images.(target)(:,:,iC,iZ,iT).*rgb_channels(iC));
        end
        if ~ismatrix(im_out)
        switch ch_merge
            % now swap the channel order to match the channel colour selection
            case 'green-magenta'
                im_out = imfuse(im_out(:,:,1),im_out(:,:,2),'ColorChannels',[2 1 2]);
            case 'yellow-blue'
                im_out = imfuse(im_out(:,:,1),im_out(:,:,2),'ColorChannels',[1 1 2]);
            case 'red-cyan'
                im_out = imfuse(im_out(:,:,1),im_out(:,:,2),'ColorChannels',[1 2 2]);
            case 'red-green'
                im_out = imfuse(im_out(:,:,1),im_out(:,:,2),'ColorChannels',[1 2 0]);
            case 'green-red'
                im_out = imfuse(im_out(:,:,1),im_out(:,:,2),'ColorChannels',[2 1 0]);
            case 'grey'
                im_out = im_out(:,:,1);
            case 'RGB'
                % do nothing
            case 'GRB'
                im_out = im_out(:,:,[2 1 3],:,:);
        end
        end
    case 'selected'
        mx = max(handles.images.(target)(:));
        cmap(1,:) = 0;
        % normalise to the maximum and convert to RGB
        im_out(:,:,:,1) = ind2rgb(uint8(255.*handles.images.(target)./mx),cmap);
    case {'tip';'boundary';'midline';'boundary_Din';'boundary_Dout';'boundary_FMin';'boundary_FMout';'axial';'radial'}
        temp = handles.images.(target)(:,:,iC,iZ,iT);
        idx = ~isinf(temp(:));
        mx = max(temp(idx));
        cmap(1,:) = 0;
        % normalise to the maximum and convert to RGB
        im_out(:,:,:,1) = ind2rgb(uint8(255.*handles.images.(target)(:,:,iC,iZ,iT)./mx),cmap);
    case 'white'
        im_out = ones(size(handles.images.filtered,1),size(handles.images.filtered,2),'like',handles.images.filtered);
    case 'black'
        im_out = zeros(size(handles.images.filtered,1),size(handles.images.filtered,2),'like',handles.images.filtered);
    case 'test'
        im_out = uint8(255.*handles.images.('test')(:,:,1,1,iT));
    otherwise
        sz = size(handles.images.(target));
        if get(handles.chk_T_max, 'value') == 1
            if ndims(handles.images.(target)) == 5
                im_out = max(handles.images.(target)(:,:,min(sz(3),iC),min(sz(4),iZ),1:handles.T_inc:sz(5)), [],5);
            else
                im_out = handles.images.(target);
            end
        else
            if ndims(handles.images.(target)) == 5
                im_out = handles.images.(target)(:,:,min(sz(3),iC),min(sz(4),iZ),min(sz(5),iT));
            else
                im_out = handles.images.(target);
            end
        end
        if get(handles.chk_Z_max, 'value') == 1
        end
        
end
% convert logical images to uint8
if islogical(im_out)
    im_out = uint8(im_out*255);
end
switch merge
    case 'none'
    case {'raw';'initial';'filtered';'subtracted'}
        sz = size(handles.images.(merge));
        if length(sz) > 2
            if sz(3) == 1
                merge_out = zeros(sz(1),sz(2),1,'like',handles.images.(merge));
            else
                merge_out = zeros(sz(1),sz(2),3,'like',handles.images.(merge));
            end
            for sC = 1:min(3,sz(3))
                % only display a maximum of the first 3 channels
                switch merge
                    case 'raw'
                        Cidx = [handles.param.ch1 handles.param.ch2 handles.param.ch3 handles.param.ch4 handles.param.ch5];
                        if get(handles.chk_T_max,'Value')
                            merge_out(:,:,sC) = squeeze(max(handles.images.(merge)(:,:,Cidx(sC),iZ,1:handles.T_inc:sz(5)),[],5).*rgb_channels(sC));
                        else
                            merge_out(:,:,sC) = squeeze(handles.images.(merge)(:,:,Cidx(sC),iZ,iT).*rgb_channels(sC));
                        end
                    otherwise
                        if get(handles.chk_T_max,'Value')
                            merge_out(:,:,sC) = squeeze(max(handles.images.(merge)(:,:,sC,iZ,1:handles.T_inc:sz(5)),[],5).*rgb_channels(sC));
                        else
                            merge_out(:,:,sC) = squeeze(handles.images.(merge)(:,:,sC,iZ,iT).*rgb_channels(sC));
                        end
                end
            end
        else
            merge_out = zeros(sz(1),sz(2),1,'like',handles.images.(merge));
            merge_out(:,:,1) = squeeze(handles.images.(merge)(:,:,min(tC,mC),min(tZ,iZ),min(tT,iT)).*rgb_channels(mC));
        end
    case 'selected'
        mx = max(handles.images.(merge)(:));
        cmap(1,:) = 0;
        % normalise to the maximum and convert to RGB
        merge_out(:,:,:,1) = ind2rgb(uint8(255.*handles.images.(merge)./mx),cmap);
    case {'tip';'boundary';'boundary_Din';'boundary_Dout';'boundary_FMin';'boundary_FMout';'axial';'radial'}
        temp = handles.images.(merge)(:,:,iC,iZ,iT);
        idx = ~isinf(temp(:));
        mx = max(temp(idx));
        cmap = jet(256);
        cmap(1,:) = 0;
        % normalise to the maximum and convert to RGB
        merge_out(:,:,:,1) = ind2rgb(uint8(255.*handles.images.(merge)(:,:,iC,iZ,iT)./mx),cmap);
    case 'white'
        merge_out = ones(size(handles.images.filtered,1),size(handles.images.filtered,2),'like',handles.images.filtered);
    case 'black'
        merge_out = zeros(size(handles.images.filtered,1),size(handles.images.filtered,2),'like',handles.images.filtered);
    otherwise
        sz = size(handles.images.(merge));
        if get(handles.chk_T_max, 'value') == 1
            if ndims(handles.images.(merge)) == 5
                merge_out = max(handles.images.(merge)(:,:,min(sz(3),iC),min(sz(4),iZ),1:handles.T_inc:sz(5)), [],5);
            else
                merge_out = handles.images.(merge);
            end
        else
            if ndims(handles.images.(merge)) == 5
                merge_out = handles.images.(merge)(:,:,min(sz(3),iC),min(sz(4),iZ),min(sz(5),iT));
            else
                merge_out = handles.images.(merge);
            end
        end
        if get(handles.chk_Z_max, 'value') == 1
        end
end
switch merge
    case 'none'
    otherwise
        % convert logical images to uint8
        if islogical(merge_out)
            merge_out = uint8(merge_out*255);
        end
end
%
% get the contrast settings
low = round(get(handles.sld_black_level, 'Value'))./255;
high = round(get(handles.sld_white_level, 'Value'))./255;
Imin = [low low low];
Imax = [high high high];
Omin = [0 0 0];
Omax = [1 1 1];
nC = size(im_out,3);
im_out = imadjust(im_out,[Imin(1:nC); Imax(1:nC)],[Omin(1:nC); Omax(1:nC)]);
% set the colorbar limits
if ~isgraphics(handles.h_colorbar)
    % recreate the colorbar
    handles.h_colorbar = colorbar(handles.ax_colorbar,'location','east','TickDirection','out','TickLength',0.02,'FontSize',8);
end

if handles.save_full_size_flag == 1
    % create a new figure for display and return the handle to allow it to
    % be saved
    figure(handles.hfig)
    imshow(im_out)
end
% display the image
api = iptgetapi(handles.hSp1);
if isempty(handles.images.raw)
    api.replaceImage(handles.blank, 'PreserveView',true,'DisplayRange', [],'colormap',cmap)
    fnc_image_fit(handles)
else
    switch merge
        case 'none'
            if nC == 1
                api.replaceImage(im_out, 'PreserveView',true,'colormap',gray)
            else
                api.replaceImage(im_out, 'PreserveView',true)
            end
        otherwise
            mC = size(merge_out,3);
            merge_out = imadjust(merge_out,[Imin(1:mC); Imax(1:mC)],[Omin(1:mC); Omax(1:mC)]);
            api.replaceImage(imfuse(im_out,merge_out,'method',method), 'PreserveView',true)
    end
end
% % add a colorbar to rgb images
% switch target
%     case {'width';'coded';'optical_flow';'perimeter';'polygons'}
%         cmap = jet(256);
%         cmap(1,:) = 1;
%         switch target
%             case {'width';'coded'}
%                 Cmin = min(handles.images.width_microns(:))*1000;
%                 Cmax = max(handles.images.width_microns(:))*1000;
%                 str = 'width (nm)';
%             case 'perimeter'
%                 Cmin = min(handles.images.perimeter_microns(:))*1000;
%                 Cmax = max(handles.images.perimeter_microns(:))*1000;
%                 str = 'width (nm)';
%             case 'optical_flow'
%                 Cmin = min(handles.images.optical_flow_magnitude(:));
%                 Cmax = max(handles.images.optical_flow_magnitude(:));
%                 str = 'optical flow (\mum s^{-1})';
%             case 'polygons'
%                 cmap = cool(256);
%                 cmap(1,:) = 1;
%                 Cmin = log10(min([handles.polygon_stats{iC,iZ,iT}.Area]*((handles.expt.micron_per_pixel*handles.param.resample)^2),[],'omitnan'));
%                 Cmax = log10(max([handles.polygon_stats{iC,iZ,iT}.Area]*((handles.expt.micron_per_pixel*handles.param.resample)^2),[],'omitnan'));
%                 str = 'log10  area (µm^2)';
%         end
%         if ~isgraphics(handles.h_colorbar)
%             % recreate the colorbar
%             handles.h_colorbar = colorbar(handles.ax_colorbar,'location','east','TickDirection','out','TickLength',0.02,'FontSize',8);
%         end
%         colormap(handles.ax_colorbar,cmap)
%         set(handles.ax_colorbar,'clim',([Cmin Cmax]))
%         handles.h_colorbar.Label.String = str;
%         handles.h_colorbar.Label.Interpreter = 'Tex';
% end
% drawnow

% -------------------------------------------------------------------------
% SAVE OPTIONS
% ------------------------------------------------------------------------

function btn_save_data_Callback(hObject, eventdata, handles)

function btn_save_frame_Callback(hObject, eventdata, handles)
cd(handles.dir_out_images)
[fileout,~] = uiputfile('*.png','Save current image');
[~,fout,~] = fileparts(fileout);
iT = get(handles.sld_T,'Value');
h = findobj(gcf,'type','colorbar');
delete(h);
export_fig([fout '_' num2str(iT)],'-png','-pdf','-native',handles.uip_Im1)
if ~isgraphics(handles.h_colorbar)
    % recreate the colorbar
    handles.h_colorbar = colorbar(handles.ax_colorbar,'location','east','TickDirection','out','TickLength',0.02,'FontSize',8);
end
cd(handles.dir_in)

function btn_save_image_Callback(hObject, eventdata, handles)
cd(handles.dir_out_images)
[fileout,~] = uiputfile('*.png','Save current image');
[~,fout,~] = fileparts(fileout);
handles = fnc_save_image(fout,handles);
cd(handles.dir_in)

function handles = fnc_save_image(name,handles)
set(handles.stt_status,'String','Saving full resolution image. Please wait...');drawnow;
iT = get(handles.sld_T,'Value');
options = get(handles.pop_display_image_channel, 'String');
option_index = get(handles.pop_display_image_channel, 'Value');
iC = str2double(options{option_index});
hfig = figure;
pos = get(hfig, 'Position');
set(hfig,'Color','w','Position',[pos(1),pos(2),handles.nY,handles.nX])
hax = axes;
axis image
axis ij
axis off
hold on
imshow(squeeze(handles.images.subtracted(:,:,iC,:,iT)),[],'InitialMagnification',100)
fnc_tip_plot(hax,handles)
export_fig([name '_' num2str(iT)],'-png','-pdf','-native',hax)
delete(hfig)
set(handles.stt_status,'String',['Image saved']);drawnow;
% if ~isgraphics(handles.h_colorbar)
%     % recreate the colorbar
%     handles.h_colorbar = colorbar(handles.ax_colorbar,'location','east','TickDirection','out','TickLength',0.02,'FontSize',8);
%     handles.h_colorbar.Label.Interpreter = 'none';
%     handles.h_colorbar.Label.String = str;
%     handles.h_colorbar.Limits = lim;
% end
% guidata(gcbo, handles);
% dpi = 150;
% full_name = get(handles.chk_figures_full_name, 'Value');
% cd(handles.dir_out_images)
% [~,fout,~] = fileparts(handles.fname);
% set(handles.stt_status,'String',['Saving ' name ' image. Please wait...']);drawnow;
% % if the full size check box is ticked, create a new window and display the
% % image with overlays in it. Save the image and then delete the window
% if get(handles.chk_figures_full_size, 'Value')
%     handles.save_full_size_flag = 1;
%     handles.hfig = figure;
%     handles = fnc_display_update(handles);
%     if full_name == 1
%         export_fig(handles.hfig,[fout '_' name '.png'],'-png','-pdf','-native')
%     else
%         export_fig(handles.hfig,[name '.png'],'-png','-pdf','-native')
%     end
%     delete(handles.hfig)
%     handles.save_full_size_flag = 0;
% else % display the image and overlays
%     handles = fnc_display_update(handles);
% end
% % save a copy of the colorbar
% if get(handles.chk_display_graph, 'Value')
%     if full_name == 1
%         export_fig([fout '_' name '_colorbar.png'],'-pdf','-png',handles.ax_colorbar);
%     else
%         export_fig([name '_colorbar.png'],'-pdf','-png',handles.ax_colorbar);
%     end
% end
% % the colorbar is the last panel to be set, so is the first in the
% % panel list. It will be saved correctly, but has to be deleted to
% % prevent interference with some of the other panels. So delete at
% % this point and recreate at the end
% if isgraphics(handles.h_colorbar)
%     str = handles.h_colorbar.Label.String;
%     lim = handles.h_colorbar.Limits;
%     handles.h_colorbar.Label.Interpreter = 'Tex';
%     colorbar(handles.h_colorbar,'off')
% end
% if get(handles.chk_figures_full_size, 'Value') == 0
%     if full_name == 1
%         export_fig([fout '_' name '.png'],['-r' num2str(dpi)],'-pdf','-png',handles.ax_image);
%     else
%         export_fig([name '.png'],['-r' num2str(dpi)],'-pdf','-png',handles.ax_image);
%     end
% end
% if isgraphics(handles.h_colorbar)
%     % recreate the colorbar
%     handles.h_colorbar = colorbar(handles.ax_colorbar,'location','east','TickDirection','out','TickLength',0.02,'FontSize',8);
%     handles.h_colorbar.Label.Interpreter = 'none';
%     handles.h_colorbar.Label.String = str;
%     handles.h_colorbar.Limits = lim;
% end
% guidata(gcbo, handles);
% set(handles.stt_status,'String',['Image saved']);drawnow;
% cd(handles.dir_in)

function btn_save_all_images_Callback(hObject, eventdata, handles)
cd(handles.dir_out_images)
[fileout,~] = uiputfile('*.png','Save current image');
[~,fout,~] = fileparts(fileout);
fnc_save_all_images(fout,handles);
cd(handles.dir_in)

function fnc_save_all_images(name,handles)
set(handles.stt_status,'String','Saving full resolution images. Please wait...');drawnow;
iT = get(handles.sld_T,'Value');
options = get(handles.pop_display_image_channel, 'String');
option_index = get(handles.pop_display_image_channel, 'Value');
iC = str2double(options{option_index});
hfig = figure;
pos = get(hfig, 'Position');
set(hfig,'Color','w','Position',[pos(1),pos(2),handles.nY,handles.nX])
hax = axes;
axis image
axis ij
axis off
hold on
for iT = 1:handles.nT-1
    set(handles.sld_T,'Value',iT)
    imshow(squeeze(handles.images.subtracted(:,:,iC,:,iT)),[],'InitialMagnification',100)
    fnc_tip_plot(hax,handles)
    export_fig([name '_' num2str(iT)],'-png','-pdf','-native',hax)
end
delete(hfig)
set(handles.stt_status,'String',['Image saved']);drawnow;

% -------------------------------------------------------------------------
% SAVE PANELS
% ------------------------------------------------------------------------
function btn_save_panels_Callback(hObject, eventdata, handles)
dpi = 150;
% make sure all the labels are in a compatible font
h = findobj(gcf,'Type','UIControl');
set(h,'FontName','Helvetica','FontUnits','pixels','FontSize',11);
h = findobj(gcf,'Type','UIPanel');
set(h,'FontName','Helvetica','FontUnits','pixels','FontSize',11);
[fout,pathname] = uiputfile('*.png','Panel output');
[pathstr, name, ext] = fileparts(fout);
fileout = [name '_all'];
cd(pathname)
export_fig(fileout,'-r300', '-png',handles.Tip_Tracker)

% % save every panel as a png
% AllChildren = get(gcf,'children');
% n = 0;
% for iP = 1:numel(AllChildren)
%     EachChild = get(AllChildren(iP));
%     if isfield(EachChild,'Type')
%         if strcmpi(EachChild.Type,'uipanel')
%             n = n+1;
%             PanelTags{n,1} = EachChild.Tag;
%         end
%     end
% end
% 
% for iP = 1:numel(PanelTags)
%     fileout = [name '_' PanelTags{iP,1}];
%     if iP == 1
%         % the colorbar is the last panel to be set, so is the first in the
%         % panel list. It will be saved correctly, but has to be deleted to
%         % prevent interference with some of the other panels. So delete at
%         % this point and recreate at the end
%         colorbar(handles.h_colorbar,'off')
%     end
%     % pdf output works from the panel handle
%     export_fig(fileout,['-r' num2str(dpi)],'-pdf','-png',handles.(PanelTags{iP,1}));
% end
% % recreate the colorbar
% handles.h_colorbar = colorbar(handles.ax_colorbar,'location','east','TickDirection','out','TickLength',0.02,'FontSize',8);
% handles.h_colorbar.Label.String = 'intensity';
% handles.h_colorbar.Label.Interpreter = 'none';
guidata(hObject, handles);
cd(handles.dir_in)
set(handles.stt_status,'String','Panels saved');drawnow;



% -------------------------------------------------------------------------
% VIEWER OPTIONS
% ------------------------------------------------------------------------
function btn_viewer_Callback(hObject, eventdata, handles)
handles = fnc_movie(handles);
guidata(gcbo, handles);
RRA_advanced_viewer(handles.images.movie)

function handles = fnc_movie(handles)
handles.play = 0;
set(handles.btn_display_movie_stop,'Value',0);
guidata(gcbo, handles);
% options = get(handles.pop_display_image, 'String');
% option_index = get(handles.pop_display_image, 'Value');
% target = options{option_index};
[~, ~, ~, ~, mT] = size(handles.images.subtracted);
set(handles.sld_T, 'Value',1,'Max',mT)
% get the size of the output
% if get(handles.chk_figures_full_size, 'Value')
%     handles.save_full_size_flag = 1;
%     handles.hfig = figure;
%     handles = fnc_display_update(handles);
%     f = export_fig('temp.png','-png','-native',handles.hfig);
%     handles.images.movie = zeros([size(f,1),size(f,2),size(f,3),mT],'uint8');
% %     delete(handles.hfig)
% %     handles.save_full_size_flag = 0;
% else % display the image and overlays
handles = fnc_display_update(handles);
f = getframe(handles.ax_image);
handles.images.movie = zeros([size(f.cdata,1),size(f.cdata,2),size(f.cdata,3),mT],'uint8');
% end

for mT = 1:mT
    set(handles.sld_T, 'Value',mT)
    set(handles.txt_T, 'String',mT)
    %fnc_clear_overlays(handles);
    handles = fnc_display_update(handles);
    drawnow
    %     if get(handles.chk_figures_full_size, 'Value')
    %         f = export_fig('temp.png','-png','-native',handles.hfig);
    %         handles.images.movie(:,:,:,mT) = f;
    %     else
    f = getframe(handles.ax_image);
    handles.images.movie(:,:,:,mT) = f.cdata;
    %     end
end
% if get(handles.chk_figures_full_size, 'Value')
%     handles.save_full_size_flag = 0;
%     delete(handles.hfig)
% end
set(handles.sld_T, 'Value',1,'Max',mT)
set(handles.txt_T, 'String',1)


% -------------------------------------------------------------------------
% DISPLAY UPDATE
% -------------------------------------------------------------------------
function handles = fnc_display_update(handles)
handles = fnc_display_image(handles);
if handles.save_full_size_flag == 1
    % create a new figure for display and return the handle to allow it to
    % be saved
    figure(handles.hfig)
    ax = gca;
else
    ax = handles.ax_image;
end
if isfield(handles,'tip_table') && ~isempty(handles.tip_table)
    fnc_tip_plot(ax,handles)
    fnc_tip_plot_profile(ax,handles)
    if isfield(handles, 'tip_table') && ~isempty(handles.tip_table.P_mean)
        fnc_tip_profile_image(handles);
        fnc_tip_plot_graph(handles);
    end
end

% -------------------------------------------------------------------------
% DISPLAY ROUTINES
% -------------------------------------------------------------------------

function btn_Im_fit_Callback(hObject, eventdata, handles)
fnc_image_fit(handles)

function fnc_image_fit(handles)
% set the image magnifcation to fit fully on screen
api1 = iptgetapi(handles.hSp1);
mag = api1.findFitMag();
api1.setMagnification(mag);
set(handles.sld_zoom, 'value', mag)
set(handles.txt_zoom, 'string',  num2str(mag, '%4.2f'))
fnc_adjust_scatter_size(handles)

function btn_Im_100_Callback(hObject, eventdata, handles)
% set the image magnifcation to 100%
api1 = iptgetapi(handles.hSp1);
api1.setMagnification(1);
fnc_adjust_scatter_size(handles)
set(handles.sld_zoom, 'value', 1)
set(handles.txt_zoom, 'string', num2str(1, '%4.2f'))

function sld_zoom_Callback(hObject, eventdata, handles)
NewVal = fnc_update_textbox(get(hObject,'Tag'),'floating',handles);
fnc_zoom(handles,NewVal)

function txt_zoom_Callback(hObject, eventdata, handles)
NewVal = fnc_check_slider_limits(get(hObject,'Tag'),'floating',handles);
fnc_zoom(handles,NewVal)

function fnc_zoom(handles,val)
api = iptgetapi(handles.hSp1);
api.setMagnification(val);
fnc_adjust_scatter_size(handles)

function fnc_adjust_scatter_size(handles)
zoom = get(handles.sld_zoom,'Value');
h = findobj(handles.ax_image,'Type','scatter');
sz = (str2double(get(handles.txt_plot_tip_marker_size,'String')).*zoom).^2;
if ~isempty(h)
    for iS = 1:length(h)
        h(iS).SizeData = sz;
    end
end

function sld_black_level_Callback(hObject, eventdata, handles)
low = round(get(hObject, 'Value'));
set(handles.txt_black_level, 'String', low);
handles = fnc_display_image(handles);
guidata(hObject, handles);

function txt_black_level_Callback(hObject, eventdata, handles)
fnc_update_txt(handles.sld_black_level, handles.txt_black_level, handles)
handles = fnc_display_image(handles);
guidata(hObject, handles);

function sld_white_level_Callback(hObject, eventdata, handles)
high = round(get(hObject, 'Value'));
set(handles.txt_white_level, 'String', high);
handles = fnc_display_image(handles);
guidata(hObject, handles);

function txt_white_level_Callback(hObject, eventdata, handles)
fnc_update_txt(handles.sld_white_level, handles.txt_white_level, handles);
handles = fnc_display_image(handles);
guidata(hObject, handles);

function sld_T_Callback(hObject, eventdata, handles)
handles.frame = round(get(handles.sld_T, 'Value'));
set(handles.txt_T, 'String', handles.frame);
guidata(hObject, handles);
fnc_display_update(handles);

function txt_T_Callback(hObject, eventdata, handles)
handles.frame = round(str2double(get(handles.txt_T, 'String')));
guidata(hObject, handles);
fnc_update_txt(handles.sld_T, handles.txt_T, handles)
guidata(hObject, handles);
fnc_display_update(handles);

function txt_T_inc_Callback(hObject, eventdata, handles)
handles.T_inc = round(str2double(get(hObject, 'String')));
guidata(hObject, handles);

function sld_Z_Callback(hObject, eventdata, handles)
handles.section = round(get(handles.sld_Z, 'Value'));
set(handles.txt_Z, 'String', handles.section);
guidata(hObject, handles);
fnc_display_update(handles);

function txt_Z_Callback(hObject, eventdata, handles)
handles.section = round(str2double(get(handles.txt_Z, 'String')));
guidata(hObject, handles);
fnc_update_txt(handles.sld_Z, handles.txt_Z, handles)
guidata(hObject, handles);
fnc_display_update(handles);

function txt_Z_inc_Callback(hObject, eventdata, handles)
handles.Z_inc = round(str2double(get(hObject, 'String')));
guidata(hObject, handles);

function btn_clear_Callback(hObject, eventdata, handles)
fnc_clear_overlays(handles)

function fnc_clear_overlays(handles)
set(handles.stt_status,'String',['Clearing displays. Please wait...']);drawnow;
h = findobj(handles.ax_image,'-not','type', 'axes','-not','type','image');
delete(h)
set(handles.stt_status,'String',['Displays cleared']);drawnow;

% -------------------------------------------------------------------------
% MOVIE CONTROLS
% -------------------------------------------------------------------------

function btn_display_movie_start_Callback(hObject, eventdata, handles)
set(handles.btn_display_movie_stop,'Value',0);
guidata(gcbo, handles);
options = get(handles.pop_display_image, 'String');
option_index = get(handles.pop_display_image, 'Value');
target = options{option_index};
switch target
    case 'movie'
        [~, ~, ~, ~, mT] = size(handles.images.movie{1,1,1});
        set(handles.sld_T, 'Max',mT)
    otherwise
        %         [~, ~, ~, ~, mT] = size(handles.images.raw);
        %         set(handles.sld_T, 'Max',mT)
        set(handles.sld_T,'Max',handles.nT)
        mT = handles.nT;
end
handles.play = 1;
guidata(gcbo, handles);
T_inc = str2double(get(handles.txt_T_inc, 'String'));
while (handles.play ~= 0)
    for iT = 1:T_inc:mT
        set(handles.sld_T, 'Value',iT)
        set(handles.txt_T, 'String',iT)
        handles = fnc_display_update(handles);
        handles = guidata(gcf);
        if handles.play == 0
            break
        end
    end
end

function btn_display_movie_stop_Callback(hObject, eventdata, handles)
handles.play = 0;
set([handles.btn_display_movie_stop; handles.btn_display_movie_start],'Value',0);
% % reset the maximum slider
% [~, ~, ~, ~, mT] = size(handles.images.raw);
% set(handles.sld_T, 'Max',mT, 'Value',1)
% set(handles.txt_T, 'String',1)
guidata(gcbo, handles);

% -------------------------------------------------------------------------
% MOVIE BUTTON ICONS
% -------------------------------------------------------------------------
function btn_display_movie_start_CreateFcn(hObject, eventdata, handles)
% create image of an arrow
im = nan(21,21);
for loop = 1:12
    im(4+round(loop/2):17-round(loop/2), loop+4) = 0.5;
end
set(hObject,'CData',cat(3,im,im,im));

function btn_display_movie_stop_CreateFcn(hObject, eventdata, handles)
im = nan(21,21);
x = [5 5 17 17 5];
y = [5 17 17 5 5];
bw = poly2mask(x,y,21,21);
im(bw) = 0.5;
set(hObject,'CData',cat(3,im,im,im));


function btn_start_Callback(hObject, eventdata, handles)
set(gcf,'renderer','painters')
handles.play = 1;
off = [handles.btn_display_movie_stop];% handles.btn_OK];
fnc_mutual_exclude(off);
guidata(gcbo, handles);
fnc_movie(handles)

% MOVIE STOP
function btn_stop_Callback(hObject, eventdata, handles)
handles.play = 0;
off = [handles.btn_display_movie_start handles.btn_display_movie_stop];
fnc_mutual_exclude(off);
guidata(gcbo, handles);

% -------------------------------------------------------------------------
% DISPLAY THUMBNAIL BUTTONS
% -------------------------------------------------------------------------

function btn_thumbnail_initial_Callback(hObject, eventdata, handles)
% if ~isempty(handles.images.resampled)
%     set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'resampled')));
%     handles = fnc_thumbnail_update_state('resampled',handles);
% elseif ~isempty(handles.images.crop)
%     set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'crop')));
%     handles = fnc_thumbnail_update_state('crop',handles);
% else
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'raw')));
handles = fnc_thumbnail_update_state('raw',handles);
% end

handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_filtered_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'filtered')));
handles = fnc_thumbnail_update_state('filtered',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_subtracted_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'subtracted')));
handles = fnc_thumbnail_update_state('subtracted',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_segmented_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'segmented')));
handles = fnc_thumbnail_update_state('segmented',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_selected_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'selected')));
handles = fnc_thumbnail_update_state('selected',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_raw_Callback(hObject, eventdata, handles)
find(strcmpi(get(handles.pop_display_image, 'String'), 'raw'))
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'raw')));
handles = fnc_thumbnail_update_state('raw',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_midline_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'midline')));
handles = fnc_thumbnail_update_state('midline',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_tip_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'tip')));
handles = fnc_thumbnail_update_state('tip',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_blank9_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'filtered')));
handles = fnc_thumbnail_update_state('filtered',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_blank10_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'filtered')));
handles = fnc_thumbnail_update_state('filtered',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function btn_thumbnail_blank11_Callback(hObject, eventdata, handles)
set(handles.pop_display_image, 'Value', find(strcmpi(get(handles.pop_display_image, 'String'), 'filtered')));
handles = fnc_thumbnail_update_state('filtered',handles);
handles = fnc_display_image(handles);
guidata(gcbo,handles)

function handles = fnc_thumbnail_update_state(target,handles)
h = [handles.btn_thumbnail_raw; ...
    handles.btn_thumbnail_initial; ...
    handles.btn_thumbnail_filtered; ...
    handles.btn_thumbnail_subtracted; ...
    handles.btn_thumbnail_segmented; ...
    handles.btn_thumbnail_selected; ...
    handles.btn_thumbnail_midline; ...
    handles.btn_thumbnail_tip; ...
    handles.btn_thumbnail_blank9; ...
    handles.btn_thumbnail_blank10; ...
    handles.btn_thumbnail_blank11];
set(h, 'Value',0)
switch target
    case {'raw';'resampled'}
    otherwise
        set(eval(['handles.btn_thumbnail_' target]),'value',1);
end

function handles = fnc_thumbnail_display(target,handles)
idx = false(11,1);
if strcmpi(target,'clear')
    idx(1:11,1) = 1;
elseif strcmpi(target,'setup')
    idx(3:11,1) = 1;
    idx(10,1) = 0;
elseif strcmpi(target,'analysis')
    idx(6:11,1) = 1;
    idx(10,1) = 0;
end
switch target
    case {'all'}
        for iT = 1:11
            if any(any(any(handles.thumbnails.(handles.options.thumbnail_names{iT}))))
                set(handles.(['btn_thumbnail_' handles.options.thumbnail_names{iT}]), ...
                    'Cdata', handles.thumbnails.(handles.options.thumbnail_names{iT}))
            else
                set(handles.(['btn_thumbnail_' handles.options.thumbnail_names{iT}]), ...
                    'Cdata', [])
            end
        end
    case {'clear';'setup'}
        for iT = 1:11
            if idx(iT) == 1
                set(handles.(['btn_thumbnail_' handles.options.thumbnail_names{iT}]),'Cdata', [])
            end
        end
    otherwise
        set(handles.(['btn_thumbnail_' target]), 'Cdata', handles.thumbnails.(target))
end

function thumb = fnc_thumbnail_make(im, target, handles)
% midr = round(size(im,1)./2);
% midc = round(size(im,2)./2);
% switch target
%     case {'raw';'initial'}
%         if midr > 128*handles.param.resample && midc > 128*handles.param.resample
%             sz = 128;
%         else
%             sz = floor(min(midr,midc)*handles.param.resample/2);
%         end
%     otherwise
%         if midr > 128 && midc > 128
%             sz = 128;
%         else
%             sz = floor(min(midr,midc)/2);
%         end
% end
% switch target
%     case {'raw';'initial'}
%         if isfield(handles.param,'resample')
%             sz = round(sz*handles.param.resample);
%         else
%             sz = sz*3;
%         end
%     case 'movie'
%         midt = round(handles.param.movie_nframes./2);
%         im = squeeze(im(:,:,:,midt));
% end
% switch target
%     case {'speed';'mask';'cisterna'}
%         thumb = single(imresize(im, [64 64],'nearest'));
%     case 'width'
%         temp = single(im(midr-sz:midr+sz-1,midc-sz:midc+sz-1,:));
%         temp = imdilate(temp,ones(2));
%         thumb = imresize(temp, [64 64],'bilinear');
%     otherwise
%temp = single(im(midr-sz:midr+sz-1,midc-sz:midc+sz-1,:));
if islogical(im)
    thumb = imresize(im, [64 64],'nearest');
else
    thumb = imresize(im, [64 64],'bilinear');
end
% end
% if handles.param.process_invert == 1
%     switch target
%         case {'resampled';'subtracted';'filtered'}
%             thumb = 1-thumb;
%     end
% end
if size(thumb,3) == 1
    thumb = cat(3,thumb,thumb,thumb);
elseif size(thumb,3) == 2
    thumb = cat(3,thumb,zeros(64,64,'like',thumb));
end
if islogical(thumb)
    thumb = im2uint8(255.*single(thumb));
else
    thumb = imadjust(im2uint8(thumb),stretchlim(thumb));
end

% -------------------------------------------------------------------------
% GENERAL SUBROUTINES
% -------------------------------------------------------------------------

function fnc_mutual_exclude(off)
set(off,'Value',0);

function fnc_set_slider_limits(slider, sldmin, sldmax, sldvalue, sldtext)
handles = guidata(gcbo);
if sldmax > 1
    set(slider, 'min', sldmin, 'max', sldmax, 'sliderstep', [1/(sldmax-sldmin) 1/(sldmax-sldmin)], 'Value', sldvalue);
    set(sldtext, 'String', sldvalue);
else
    set(slider, 'min', 1, 'max', 10, 'sliderstep', [1/9 1/9], 'Value', 1,'enable','off');
    set(sldtext, 'String', 1,'enable','off');
end
guidata(gcbo, handles);

function NewVal = fnc_check_slider_limits(target,integer,handles)
textbox = eval(['handles.' target]);
slider = eval(['handles.' strrep(target,'txt','sld')]);
Max = get(slider, 'Max');
Min = get(slider, 'Min');
NewVal = str2double(get(textbox, 'String'));
if strcmpi(integer,'integer')
    NewVal = round(NewVal);
end
if NewVal > Max
    NewVal = Max;
    set(handles.stt_status, 'String','Value is too large, reverting to maximum')
elseif NewVal < Min
    NewVal = Min;
    set(handles.stt_status, 'String','Value is too small, reverting to minimum')
end
set(slider, 'Value', NewVal)
if strcmpi(integer,'integer')
    set(textbox, 'String', num2str(NewVal, '%4.0f'))
else
    set(textbox, 'String', num2str(NewVal, '%4.2f'))
end

function NewVal = fnc_update_textbox(target,integer,handles)
slider = eval(['handles.' target]);
textbox = eval(['handles.' strrep(target,'sld','txt')]);
NewVal = get(slider, 'Value');
if strcmpi(integer,'integer')
    NewVal = round(NewVal);
end
set(slider, 'Value', NewVal)
if strcmpi(integer,'integer')
    set(textbox, 'String', num2str(NewVal, '%4.0f'))
else
    set(textbox, 'String', num2str(NewVal, '%4.2f'))
end

function fnc_update_txt(sld_name, txt_name, handles)
Max = get(sld_name, 'Max');
Min = get(sld_name, 'Min');
if (Max > 1)
    NewVal = round(str2double(get(txt_name, 'String')));
else
    NewVal = str2double(get(txt_name, 'String'));
end
if isempty(NewVal)
    OldVal = round(get(sld_name, 'Value'));
    set(txt_name, 'String', OldVal);
else
    set(sld_name, 'Value', NewVal);
    set(txt_name, 'String', NewVal);
end

% Executes during object creation, after setting all properties.

function fnc_slider_background(hObject, usewhitebg)
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function fnc_textbox_background(hObject)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% -------------------------------------------------------------------------
% CREATE FUNCTIONS
% -------------------------------------------------------------------------

% channel selection controls
function pop_ch1_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_ch2_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_ch3_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_ch4_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function pop_ch_colour_merge_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% T and Z selection controls
function txt_T_first_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_T_last_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function txt_Z_first_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_Z_last_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% rotation controls
function txt_rotation_angle_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function txt_xy_sz_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_z_sz_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% filter controls
function sld_xy_ave_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_xy_ave_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function sld_z_ave_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_z_ave_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function sld_t_ave_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_t_ave_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_filter_method_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% --- background
function pop_back_method_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function txt_ch1_back_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_ch2_back_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_ch3_back_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_ch4_back_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_ch5_back_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function txt_ch1_std_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_ch2_std_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_ch3_std_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_ch4_std_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_ch5_std_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% function txt_ch1_offset_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);
% function txt_ch2_offset_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);
% function txt_ch3_offset_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);
% function txt_ch4_offset_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);
% function txt_ch5_offset_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);

function txt_auto_corr_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_auto_corr_channel_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_auto_corr_target_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% profile controls
function txt_profile_FWHM_R_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_profile_FWHM_G_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_profile_FWHM_B_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_profile_FWHM_peak_R_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_profile_FWHM_peak_G_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_profile_FWHM_peak_B_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_profile_units_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_micron_per_pix_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function txt_profile_FWHM_min1_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_profile_FWHM_max1_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function txt_profile_FWHM_min2_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_profile_FWHM_max2_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function txt_time_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% Display contrast controls
function sld_white_level_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_white_level_CreateFcn(hObject, ~, handles)
fnc_textbox_background(hObject);
function sld_black_level_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_black_level_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% Display section and frame
function sld_T_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_T_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_T_inc_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function sld_Z_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_Z_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_Z_inc_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% Display channel and merge
function pop_display_image_channel_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_display_image_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_display_merge_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_display_merge_method_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_display_merge_channel_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_image_colormap_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% Position controls
function txt_zoom_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function sld_zoom_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);

% tip channels
function pop_tip_trace_channel_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_tip_spk_channel_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
% function txt_time_interval_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);

% tip threshold controls
function pop_segment_method_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_segment_local_radius_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_segment_local_offset_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_tip_threshold_p3_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function sld_segment_threshold_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_segment_threshold_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% tip filter controls
function txt_tip_filter_noise_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_tip_filter_median_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% tip trace controls
function txt_tip_trace_distance_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% tip profile controls
% function pop_tip_profile_method_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);
function txt_tip_profile_average_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
% function txt_tip_profile_sigma_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);
% function txt_tip_profile_length_CreateFcn(hObject, eventdata, handles)
% fnc_textbox_background(hObject);

% spk detect controls
function pop_spk_method_CreateFcn(hObject, eventdata, handles)
function sld_spk_threshold_CreateFcn(hObject, eventdata, handles)
fnc_slider_background(hObject, 1);
function txt_spk_threshold_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_spk_size_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function pop_tip_plot_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_plot_tip_vector_size_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_plot_tip_OCC_vector_size_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_plot_tip_marker_size_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

% Plot controls
function pop_plot_array_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_plot_target_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_plot_type_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function pop_plot_y_channel_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_plot_y_axis_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_plot_x_channel_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_plot_x_axis_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_plot_y_T_offset_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_plot_x_T_offset_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);

function pop_plot_units_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_plot_gradient_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function txt_plot_intercept_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
function pop_plot_colormap_CreateFcn(hObject, eventdata, handles)
fnc_textbox_background(hObject);
