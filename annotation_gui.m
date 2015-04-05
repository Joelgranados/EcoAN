% Annotation.  An annotation creation tool for images.
% Copyright (C) 2010 Joel Granados <joel.granados@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.C
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


function varargout = annotation_gui(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @annotation_gui_OpeningFcn, ...
                       'gui_OutputFcn',  @annotation_gui_OutputFcn, ...
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


% --- Executes just before annotation_gui is made visible.
function annotation_gui_OpeningFcn(hObject, eventdata, handles, varargin)

    % Choose default command line output for annotation_gui
    handles.output = hObject;

    % This is where we will initialize the gui specific data structures.
    handles.paths = [];
    handles.current_dir = pwd;

    % Offset of current selected file
    handles.list_selected_file = -1;

    % There will only be one annotation per timestream.
    handles.annotation = annotation_init;

    handles.isModifying = 0;

    % Initialize the figure1 callback definitions.
    addlistener(handles.figure1, 'WindowKeyPress', @on_key_press_callback);

    % Update handles structure
    guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = annotation_gui_OutputFcn(hObject, eventdata, handles)
    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on selection change in file_list.
function file_list_Callback(hObject, eventdata, handles)
    % We ingore the users interaction if there is nothing in the list.
    if size (handles.paths,2) == 0
        return;
    end

    % We can't do anything if the user is modifying.
    if handles.isModifying == 1,
        msgboxText{1} =  strcat('Interaction error.:',...
            'You must finish the annotation formating.');
        msgbox(msgboxText,'');
        return;
    end

    % see what the user has chossen
    offset = get(hObject,'Value');

    % do the selection.
    [success, handles] = select_offset_from_list(offset, handles, hObject);

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function file_list_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'),...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
    close(handles.figure1);
    exit;

% --- Executes on button press in add_files.
function add_files_Callback(hObject, eventdata, handles)
    % This is where I find the files that we are to annotate.
    % We change dir so the user sees the previous place he searched.
    imagetypes = '*.gif;*.jpg;*.png;*.jpeg,*.GIF;*.JPG;*.PNG;*.JPEG';
    [filename, pathname, filterindex] =...
        uigetfile(imagetypes, 'Pick an image file', 'MultiSelect', 'on',...
        handles.current_dir);

    % Handle the cancel option
    if ~iscellstr(filename) && ~ischar(filename) ...
            && ~iscellstr(pathname) && ~ischar(filename)
        % just return, user pushed cancel.
        return
    end

    if ischar(filename) && ischar(pathname)
        % User only chose one file.  change to cellstr
        filename = cellstr(filename);
        pathname = cellstr(pathname);
    end

    handles.paths = unique([handles.paths, strcat(pathname,filename)]);

    % Set the values in the file path list.
    set(handles.file_list,'String',handles.paths,'Value',1);

    % Keep track of the path that the user is on.
    handles.current_dir = char(pathname);

    % For the users convinience select the first file in the list.
    % if unsuccessfull it wont make much of a difference as we have a well
    % constructed handles by now.
    [success, handles] = select_offset_from_list(1, handles, hObject);

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes on button press in clear_files.
function clear_files_Callback(hObject, eventdata, handles)
    % Set the label list back to its default.
    handles.paths = [];
    set(handles.file_list, 'String', '', 'Value', 0);
    cla(handles.image_axis, 'reset');
    handles.annotation = annotation_init;
    guidata(hObject, handles);


% --- Called when an image needs to be uploaded to an axis.
% input_image   is the string that references the image
% axis_handler  the handler use as parent of the image
function [retimg, ret_handles]  = put_image_in_axis (input_image, ...
            axis_handler, handles)
    if exist (char(input_image)) <= 0,
        msgboxText{1} =  strcat('File not found: ', input_image);
        msgbox(msgboxText,'File Not Found', 'error');
        retimg = 0;
        return;
    end

    img = imread(char(input_image));

    image(img, 'Parent', axis_handler,...
        'ButtonDownFcn', @button_pressed_on_image);
    set(gca,'Units','pixels');
    axis equal;

    if ~isnan(handles.annotation.vertices),
        hroi_vertices = handles.annotation.vertices;
        handles.annotation.line_handle = ...
            line( [hroi_vertices(:,1);hroi_vertices(1,1)],...
                [hroi_vertices(:,2);hroi_vertices(1,2)],...
                'Color',[1 0 0],'LineWidth',1);
    end

    retimg = img;
    ret_handles = handles;

% --- Called when the a button is pressed on the figure/image
function button_pressed_on_image(hObject, eventdata)
    %initialize handles.
    handles = guidata(hObject);

    % What button did the user click?
    % normal -> left click
    % alt -> right click
    % extended -> middle button. (might be different for mice
    % that dont have a middle button).
    mouseid = get(gcf,'SelectionType');

    if ((strcmp(mouseid, 'normal') ~= 1 && strcmp(mouseid, 'alt') ~= 1)) ||...
            handles.isModifying ~= 0
        return;
    end
    handles.isModifying = 1;guidata(hObject, handles);

    if ~isnan(handles.annotation.line_handle),
        set(handles.annotation.line_handle, 'Visible', 'off');
    end
    handles.annotation = annotation_init;

    hroi = impoly(handles.image_axis);
    handles.isModifying = 0;guidata(hObject, handles);

    % handle when user presses ESC
    if (size(hroi,1) == 0), return; end
    hroi_vertices = round(getPosition(hroi));
    delete(hroi);

    % Create a new region in the next offset
    handles.annotation.vertices = round(hroi_vertices);
    handles.annotation.line_handle = ...
        line( [hroi_vertices(:,1);hroi_vertices(1,1)],...
            [hroi_vertices(:,2);hroi_vertices(1,2)],...
            'Color',[1 0 0],'LineWidth',1);

    xmin = min(handles.annotation.vertices(:,1));
    ymin = min(handles.annotation.vertices(:,2));
    xmax = max(handles.annotation.vertices(:,1));
    ymax = max(handles.annotation.vertices(:,2));
    handles.annotation.rect = [xmin, ymin, xmax-xmin, ymax-ymin];

    % Remember to save the changes.
    guidata(hObject, handles);

function on_key_press_callback(hObject, eventdata)
    %initialize handles
    handles = guidata(hObject);

    key = get(eventdata.Source, 'CurrentCharacter');
    if strcmp(key, 'z') == 1 || strcmp(key, 'Z') == 1
        bstate = get(handles.zoom_toggle, 'Value');
        if bstate == get(handles.zoom_toggle, 'Min') %it is not pressed.
            set(handles.zoom_toggle, 'Value',...
                get(handles.zoom_toggle, 'Max'));
        else
            set(handles.zoom_toggle, 'Value',...
                get(handles.zoom_toggle, 'Min'));
        end

        % call the zoom callback..
        zoom_toggle_Callback(handles.zoom_toggle, [], handles);
    elseif strcmp(key, 'p') == 1 || strcmp(key, 'P') == 1 ...
            || strcmp(key, 't')
        bstate = get(handles.grab_toggle, 'Value');
        if bstate == get(handles.grab_toggle, 'Min')
            set(handles.grab_toggle, 'Value', ...
                get(handles.grab_toggle, 'Max'));
        else
            set(handles.grab_toggle, 'Value', ...
                get(handles.grab_toggle, 'Min'));
        end
        grab_toggle_Callback(handles.grab_toggle, [], handles);
    end

    % Remember to save the changes.
    guidata(hObject, handles);


% --- helper function.  It selects the offset in the file list.
% it was code that was being repeated.  If the return value  is not successfull one
% can always reuse the previous handles var.
function [success, ret_handles] = select_offset_from_list(offset, handles, hObject)
    % FIXME : HACK!!!
    %For some reason Matlab does not keep the handles with the guidata call
    % this is a workaround.
    ret_handles = handles;

    % We dafault to a successfull return :(
    success = 1;

    % We ignore if there is nothing in the list.
    if size (ret_handles.paths,2) == 0
        return;
    end

    % We search for the next image in the list.  If we have gotten to the end
    % of the list, we go to element 1.
    % Update the var that holds the current status of the list.
    axis_handler = ret_handles.image_axis;

    % we use > and < to make sure we put the counter back to the first image
    % if we encounter some inconsistent values.
    if offset >= size(ret_handles.paths,2) + 1 || offset < 1;
        offset = 1;
    end

    % We get the selected file name.
    selected_file = ret_handles.paths(offset);

    % We 'officialize' the selection
    ret_handles.list_selected_file = offset;

    % We select the corresponding file in the list of files.
    set(ret_handles.file_list, 'Value', ret_handles.list_selected_file);

    % We put the image in the axis.
    [img, ret_handles] = put_image_in_axis (char(selected_file), ...
            axis_handler, ret_handles);

    % Remember to save the changes.
    guidata(hObject, ret_handles);

% --- Executes on button press in zoom_toggle.
function zoom_toggle_Callback(hObject, eventdata, handles)
    zoom_toggle_state = get(hObject, 'Value');
    zh = zoom(handles.figure1);
    ph = pan(handles.figure1);

    if zoom_toggle_state == 0
        set(zh, 'Enable', 'off');
    elseif zoom_toggle_state == 1

        % make sure we disable the grab first
        set(ph, 'Enable', 'off');
        set(handles.grab_toggle, 'Value', 0);

        set(zh, 'Enable', 'on', 'ActionPostCallback',@zoomCallback);
    else
        % this should not be reached.
    end

function zoomCallback(x, y)
    axis equal;

% --- Executes on button press in grab_toggle.
function grab_toggle_Callback(hObject, eventdata, handles)
    state = get(hObject, 'Value');
    ph = pan(handles.figure1);
    zh = zoom(handles.figure1);

    if state == 0
        set(ph, 'Enable', 'off');
    elseif state == 1

        % make sure we disable the zoom first
        set(zh, 'Enable', 'off');
        set(handles.zoom_toggle, 'Value', 0);

        set(ph, 'Enable', 'on');
    else
        % this should not be reached.
    end

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % get new resized position
    globalPos = get(handles.figure1, 'Position');

    cporp = get(handles.rightpanel, 'Position'); % right panel.
    cpolp = get(handles.image_axis, 'Position'); % image axis.

    sfrp = cporp(3) + cpolp(1) + 2;%space for right panel.
    cporp(1) = globalPos(3) - sfrp;% calc the x.

    %get current pos of image_axis.

    cpolp(3) = abs(globalPos(3) - sfrp - cpolp(1) - 5);
    cpolp(4) = cpolp(3); %its a square.

    %make the changes.
    set(handles.image_axis, 'Position', cpolp);
    set(handles.rightpanel, 'Position', cporp);

    % Remember to save the changes.
    guidata(hObject, handles);

function object = annotation_init()
  object.roi = NaN; % a imroi
  object.rect = NaN; % surrounding rectangle.
  object.vertices = NaN; % vertices array.
  object.line_handle = NaN; % handle to the drawn line.
  object.filename = 'Signal.txt';
  object.signal = [];

% --- Executes on button press in createSignal.
function createSignal_Callback(hObject, eventdata, handles)
% hObject    handle to createSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if isnan(handles.annotation.line_handle),
        msgboxText{1} =  strcat('Interaction Error:',...
            'You must create a polygon first..');
        msgbox(msgboxText,'');
        return;
    end

    [filename, pathname, filterindex] =...
        uiputfile({'*.txt'}, 'Save as', 'Signal.txt');
    % Handle the cancel option
    if ~ischar(filename) && ~ischar(pathname)
        return;
    end
    sfn = fullfile(pathname,filename);

    if size(sfn, 2) < 1,
        msgboxText{1} = strcat('Interaction Error:',...
            'You must have a filename');
        msgbox(msgboxText, '');
    end

    prevColor = get(handles.rightpanel, 'BackgroundColor');
    set(handles.rightpanel, 'BackgroundColor', 'red');
    pause(2); %So we notice the color
    if size(handles.annotation.signal,2) == 0,
        signalAccum = {};
        for i=1:size(handles.paths,2),
            [gcc, r_m, g_m, b_m] = calcSignal(handles.paths(i), ...
                        handles.annotation.vertices);
            signalAccum(i, 1) = cellstr(num2str(gcc));
            signalAccum(i, 2) = cellstr(num2str(r_m));
            signalAccum(i, 3) = cellstr(num2str(g_m));
            signalAccum(i, 4) = cellstr(num2str(b_m));

            warning off;
            info = imfinfo(char(handles.paths(i)));
            warning on;
            signalAccum(i, 5) = ...
                cellstr(strrep(info.DigitalCamera.DateTimeDigitized, ...
                                ' ', '_'));
                    %datenum(info.DateTime, 'yyyy:mm:dd HH:MM:SS');
        end;
        signalAccum = expandDates(signalAccum);
        handles.annotation.signal = signalAccum;
    end;

    annotation_save(handles.annotation, sfn);
    set(handles.rightpanel, 'BackgroundColor', prevColor);

function expDates = expandDates ( signalAccum )
    dTemp = datevec(signalAccum(:,5), 'yyyy:mm:dd_HH:MM:SS');
    dTemp(:,4:5) = 0;
    dTemp = datenum(dTemp);

    % Number of days between start and finish
    minD = min(dTemp);
    maxD = max(dTemp);

    % +1 to count the last day.
    numDays = round(abs(maxD - minD)) + 1;

    % Day offset from minD
    dayOffset = (0:1:numDays)+1;

    expDates = {};
    for i=dayOffset,
        expDates(i,5) = cellstr(datestr(minD + i-1, 'yyyy-mm-dd'));
        [val, ind] = min(abs(dTemp - (minD+i-1)));
        expDates(i,1) = signalAccum(ind,1);
        expDates(i,2) = signalAccum(ind,2);
        expDates(i,3) = signalAccum(ind,3);
        expDates(i,4) = signalAccum(ind,4);
    end

function [gcc, m_r, m_g, m_b] = calcSignal(imgpath, vertices)
    img = imread(char(imgpath));
    mask = roipoly(img, vertices(:,1), vertices(:,2));
    [c r] = find(mask);
    Ind = sub2ind(size(img), c, r);
    roiPixels = [];

    imgt = img(:,:,1);
    R = imgt(Ind);
    imgt = img(:,:,2);
    G = imgt(Ind);
    imgt = img(:,:,3);
    B = imgt(Ind);
    T = R + G + B;
    R = double(R)./(double(T)+0.0000001);
    G = double(G)./(double(T)+0.0000001);
    B = double(B)./(double(T)+0.0000001);

    gcc = 2*G - B - R;
    gcc = mean(gcc);
    m_r = mean(R);
    m_g = mean(G);
    m_b = mean(B);

function annotation_save(annotation, outputFile)
    [fd,syserrmsg]=fopen(outputFile,'w+');

    if (fd==-1),
        msgboxText{1} =  strcat('Error saving to file');
        msgbox(msgboxText,'Please try to save again.');
        return;
    end;

    fprintf(fd, '#Xmin,Ymin,Width,Height,');
    fprintf(fd, 'col1,row1,col2,row2...,colN,rowN\n');

    fprintf(fd, 'Polygon,');
    fprintf(fd, '%d,%d,%d,%d', annotation.rect);
    vertices = annotation.vertices;
    for j=1:size(vertices,1),
        fprintf(fd, ',%d,%d', vertices(j,1), vertices(j,2));
    end;
    fprintf(fd, '\n');

    fprintf(fd, '#filename,signalValue,RedMean,GreenMean,BlueMean\n');
    for i=1:size(annotation.signal,1),
        fprintf(fd, '%s,%s,%s,%s,%s\n', char(annotation.signal(i,5)), ...
                char(annotation.signal(i,1)), ...
                char(annotation.signal(i,2)), ...
                char(annotation.signal(i,3)), ...
                char(annotation.signal(i,4)));
    end;
    fprintf(fd, '\n');
    fclose(fd);

function annotation = annotation_read(file_name)
    % No file case.
    if exist (file_name) == 0,
        msgboxText{1} =  strcat('Error getting file');
        msgbox(msgboxText,'Please try again.');
        return;
    end

    annotation = annotation_init();

    % We try to read the file.
    [fd,syserrmsg]=fopen(file_name,'rt');
    if (fd==-1),
        return
    end;

    lines = textscan(fd,'%s%d%d%d%d%[0123456789,]',...
        'Delimiter', ',', 'CommentStyle', '#');
    fclose(fd);
    if (isempty(lines{1})),return;end;

    vertices = [];
    for i=1:size(lines{1},1),
        if (~strcmp(lines{1}(1),'Polygon')),
            continue;
        end;

        annotation.rect =...
            [double(lines{2}(i)), double(lines{3}(i)),...
             double(lines{4}(i)), double(lines{5}(i))];

        %Create the vertieces
        remain = lines{6}(i);
        while strcmp(remain,'') ~= 1,
            [X,remain] = strtok(remain, ',');
            [Y,remain] = strtok(remain, ',');
            X = round(str2double(X)); Y = round(str2double(Y));
            vertices = [vertices; [X Y]];
        end
        annotation.vertices = vertices;

        break;
    end

    if (length(vertices) > 0),
        xmin = min(annotation.vertices(:,1));
        ymin = min(annotation.vertices(:,2));
        xmax = max(annotation.vertices(:,1));
        ymax = max(annotation.vertices(:,2));
        annotation.rect = [xmin, ymin, xmax-xmin, ymax-ymin];
    else
        annotation = annotation_init();
        return;
    end

% --- Executes on button press in loadSignal.
function loadSignal_Callback(hObject, eventdata, handles)
    [filename, pathname, filterindex] =...
        uigetfile({'*.txt'}, 'Pick a signal file', 'MultiSelect', 'off',...
            handles.current_dir);

    % Handle the cancel option
    if ~ischar(filename) && ~ischar(pathname),
        return;
    end

    file_name = fullfile(pathname, filename);
    annotation = annotation_read(file_name);
    if (isnan(annotation.rect)),
        msgboxText{1} =  strcat('Error reading file: ', file_name);
        msgbox(msgboxText,'Please try to load again.');
        return;
    end

    % Create a new region in the next offset
    handles.annotation = annotation;
    handles.annotation.vertices = round(annotation.vertices);
    handles.annotation.line_handle = ...
        line( [annotation.vertices(:,1);annotation.vertices(1,1)],...
            [annotation.vertices(:,2);annotation.vertices(1,2)],...
            'Color',[1 0 0],'LineWidth',1);

    % Remember to save the changes.
    guidata(hObject, handles);


