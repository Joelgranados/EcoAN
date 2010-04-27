function varargout = annotation_gui(varargin)
    % ANNOTATION_GUI M-file for annotation_gui.fig
    %      ANNOTATION_GUI, by itself, creates a new ANNOTATION_GUI or raises
    %      the existing singleton*.
    %
    %      H = ANNOTATION_GUI returns the handle to a new ANNOTATION_GUI or
    %      the handle to the existing singleton*.
    %
    %      ANNOTATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the
    %      local function named CALLBACK in ANNOTATION_GUI.M with the given
    %      input arguments.
    %
    %      ANNOTATION_GUI('Property','Value',...) creates a new ANNOTATION_GUI
    %      or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before annotation_gui_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to annotation_gui_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help annotation_gui

    % Last Modified by GUIDE v2.5 26-Apr-2010 14:32:02

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
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to annotation_gui (see VARARGIN)

    % Choose default command line output for annotation_gui
    handles.output = hObject;

    % This is where we will initialize the gui specific data structures.
    % image_files is a list of image data structs.
    % image_files(n).image_files = [file1, file1...]
    % image_files(n).directory = dir
    handles.image_files(1).image_files = [];
    handles.image_files(1).directory = '';
    handles.image_files(1).full_paths = [];
    handles.image_files_offset = 1;
    handles.image_files_regex_string =...
        '*.gif;*.jpg;*.png;*.jpeg,*.GIF;*.JPG;*.PNG;*.JPEG';
    handles.image_files_current_dir = pwd;

    % Current selected label in label pop up.  This is an offset.  Not a
    % string.
    handles.label_selected_label = -1;

    % Current selected file in file list.  Notice that this is an offset.
    % Not a string.
    handles.list_selected_file = -1;
    handles.list_file_paths = [];

    % The variable that will temporarily hold the annotation activity per
    % image. curr_ann(current annotation)
    handles.curr_ann.file_name = '';
    handles.curr_ann.image = -1;
    handles.curr_ann.reg_offset = 0;
    handles.curr_ann.regions(1) = annotation_init;

    % Offset of region to correct.  This is only valid when correcting.  It
    % should be -1 otherwise.
    handles.correction.offset = -1;
    % Will have the line information.
    handles.correction.box.l = -1;
    handles.correction.box.t = -1;
    handles.correction.active = 0;

    % The ftp stuff.
    handles.ftp_struct = -1;

    % The configuration stuff.  FIXME: we should have a function that reads
    % everything into the variable.
    handles.config.cache_dir = '/home/joel/src/fcount/annotation/cache/';

    % Initialize handle responsible for zoom
    % handles.zoom_handle = zoom;

    % Initialize the figure1 callback definitions.
    set(handles.figure1, 'KeyPressFcn', @on_key_press_callback);

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes annotation_gui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = annotation_gui_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on selection change in file_list.
function file_list_Callback(hObject, eventdata, handles)
    % hObject    handle to file_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns file_list
    %        contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from file_list

    % We ingore the users interaction if there is nothing in the list.
    if size (handles.list_file_paths,2) == 0
        return;
    end

    % see what the user has chossen
    offset = get(hObject,'Value');

    % do the selection.
    handles = select_offset_from_list(offset, handles, hObject);

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function file_list_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to file_list (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'),...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in save_annotation.
function save_annotation_Callback(hObject, eventdata, handles)
    % hObject    handle to save_annotation (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    save_annotation(handles.curr_ann);


% --- Executes on button press in clear_annotation.
function clear_annotation_Callback(hObject, eventdata, handles)
    % hObject    handle to clear_annotation (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % We need to reset the reg_offset and make sure that regions(1) is -1.
    for i = 1:handles.curr_ann.reg_offset
        handles.curr_ann.regions(i).active = 0;
        bbl = handles.curr_ann.regions(i).bboxline;
        set(bbl.l, 'Visible', 'off');
        set(bbl.t, 'Visible', 'off');
    end

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
    % hObject    handle to exit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    close(handles.figure1);

% --- Executes on selection change in labels.
function labels_Callback(hObject, eventdata, handles)
    % hObject    handle to labels (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns labels contents
    %        as cell array
    %        contents{get(hObject,'Value')} returns selected item from labels
    handles.label_selected_label = get(hObject, 'Value');

    % Remember to save the changes.
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function labels_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to labels (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'),...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    try
        labels = textread('labels.txt', '%s\n');
        set(hObject, 'String', labels);
    catch
        % The file is not where we expect.... error out with a message.
        msgboxText{1} =  strcat('I cant find the file where the labels',...
            ' are stored.  Please create this file, name it labels.txt',...
            ' and put it in:', pwd);
        msgbox(msgboxText,'File Not Found', 'error');
    end

% --- Executes on button press in add_files.
function add_files_Callback(hObject, eventdata, handles)
    % hObject    handle to add_files (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % This is where I find the files that we are to annotate.
    % We change dir so the user sees the previous place he searched.
    ifo = handles.image_files_offset;
    [filename, pathname, filterindex] =...
        uigetfile(handles.image_files_regex_string,...
        'Pick an image file', 'MultiSelect', 'on',...
        handles.image_files_current_dir);

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

    handles.image_files(ifo).image_files = filename;
    handles.image_files(ifo).directory = pathname;
    handles.image_files(ifo).full_paths = strcat(pathname,filename);
    handles.image_files_current_dir = char(pathname);

    % Now I have to add those files to the list in file_list
    % create a temp var with all the names we have up until now
    file_names_temp = [];
    for i = 1:ifo
        file_names_temp = cat(2,file_names_temp,...
            cellstr(handles.image_files(i).full_paths));
    end
    % I don't want repeated values in the list.
    file_names_temp = unique(file_names_temp);

    % Set the values in the file path list.
    set(handles.file_list,'String',file_names_temp,'Value',1);

    % Keep track of the new list so we don't have to calculate it twice
    handles.list_file_paths = file_names_temp;

    % Keep track of the image_file_offset.
    handles.image_files_offset = handles.image_files_offset + 1;

    % For the users convinience select the first file in the list.
    handles = select_offset_from_list(1, handles, hObject);

    % Remember to save the changes.
    guidata(hObject, handles);

% --- Called when an image needs to be uploaded to an axis.
function retimg = put_image_in_axis (input_image, axis_handler, handles)
    % input_image   is the string that references the image
    % axis_handler  the handler use as parent of the image
    if exist (char(input_image)) > 0
        img = imread(char(input_image));
        imagesc(img, 'Parent', axis_handler, 'ButtonDownFcn',...
            @button_pressed_on_image);
        set(gca,'Units','pixels');
        retimg = img;

    else
        msgboxText{1} =  strcat('File not found: ', input_image);
        msgbox(msgboxText,'File Not Found', 'error');
        retimg = 0;
    end

% --- Called when the a button is pressed on the figure/image
function button_pressed_on_image(hObject, eventdata)
    % hObject       is the handle to the related object.
    % eventdata     I have no idea what Matlab puts here.

    %initialize handles.
    handles = guidata(hObject);

    % What button did the user click?
    % normal -> left click
    % alt -> right click
    % extended -> middle button. (might be different for mice with more
    % that dont have a middle button.
    mouseid = get(gcf,'SelectionType');

    if ((strcmp(mouseid, 'normal') == 1 || strcmp(mouseid, 'alt') == 1)) &&...
            handles.correction.active == 0
        % We get the first possition of the square.
        p1=get(gca,'CurrentPoint');

        % What region was the last one to be created?
        reg_offset = handles.curr_ann.reg_offset;

        % When user left clicks.
        % When there is no regions at all.
        % When user right clicks but there is no previous info in the
        %      bbox_figure
        if strcmp(mouseid, 'normal') == 1 || reg_offset <= 0 || ...
                (strcmp(mouseid, 'alt') == 1 &&...
                 isempty(handles.curr_ann.regions(reg_offset).bbox_figure))
            bbox_figure = rbbox; % the rubber box thingy :)

        elseif strcmp(mouseid, 'alt') == 1 &&...
                ~isempty(handles.curr_ann.regions(reg_offset).bbox_figure)
            % this means modify the previous region.
            % We find out which part of the last region will be stretched by
            % analysing the relation between the last annotation's center
            % and the current possition.
            bbt = handles.curr_ann.regions(reg_offset).bbox;
            % xdiff is center_x - current_x
            xdiff = (bbt(1)+(abs(bbt(3)-bbt(1))/2)) - (p1(1,1));
            % ydiff is center_y - current_y
            ydiff = (bbt(2)+(abs(bbt(4)-bbt(2)))/2) - (p1(1,2));

            % Remember that bbox_figure[ x y width height] in cartesian coor.
            % Remember bbt(1)=xmin bbt(2)=ymin bbt(3)=xmax bbt(4)=ymax
            bbox_figure = handles.curr_ann.regions(reg_offset).bbox_figure;
            if xdiff < 0 && ydiff > 0
                %fixed in lower left
                fixed_figure = [ bbox_figure(1), bbox_figure(2) ];
                fixed_axis = [ bbt(1), bbt(4) ];
            elseif xdiff >= 0 && ydiff >= 0
                %fixed in lower right
                fixed_figure = [ bbox_figure(1)+bbox_figure(3),...
                    bbox_figure(2) ];
                fixed_axis = [ bbt(3), bbt(4) ];
            elseif xdiff > 0 && ydiff < 0
                %fixed in upper right
                fixed_figure = [ bbox_figure(1)+bbox_figure(3),...
                    bbox_figure(2)+bbox_figure(4) ];
                fixed_axis = [bbt(3), bbt(2) ];
            elseif xdiff <= 0 && ydiff <= 0
                %fixed in upper left
                fixed_figure = [ bbox_figure(1),...
                    bbox_figure(2)+bbox_figure(4) ];
                fixed_axis = [ bbt(1), bbt(2) ];
            end

            % The end possition is p2 (whereever the user lets go of the mouse,
            % but p1 is not where the user first clicked, its where fixed is.
            p1 = [fixed_axis(1), fixed_axis(2), 1;...
                  fixed_axis(1), fixed_axis(2), 0];

            % The code that comes after will create a new region in the
            % region list using the reg_offset.  Lets make it think that
            % nothing has happened
            handles.curr_ann.reg_offset = handles.curr_ann.reg_offset - 1;

            % erase the previous one from the axis and from the internal
            % structure.
            bbl = handles.curr_ann.regions(reg_offset).bboxline;
            set(bbl.l, 'Visible', 'off');
            set(bbl.t, 'Visible', 'off');

            bbox_figure = rbbox( bbox_figure,...
                [fixed_figure(1) fixed_figure(2)]);
        end

        p2=get(gca,'CurrentPoint');
        p=round([p1;p2]);

        % We define the coordinates.
        xmin=min(p(:,1));
        xmax=max(p(:,1));
        ymin=min(p(:,2));
        ymax=max(p(:,2));

        % Incremeant the offset.
        reg_offset = handles.curr_ann.reg_offset + 1;
        handles.curr_ann.reg_offset = reg_offset;

        % Create a new region in the next offset
        handles.curr_ann.regions(reg_offset) = annotation_init;
        handles.curr_ann.regions(reg_offset).bbox = [xmin ymin xmax ymax];

        % We will use the label that is currently selected.
        l_offset = get(handles.labels, 'Value');
        l_strings = get(handles.labels, 'String');
        handles.curr_ann.regions(reg_offset).label = l_strings(l_offset);

        % Draw the box in red and save in regions.
        pts = handles.curr_ann.regions(reg_offset).bbox;
        lbl = handles.curr_ann.regions(reg_offset).label;
        [l, t] = annotation_drawbox(pts, lbl, [1 0 0], @button_press_on_line);
        handles.curr_ann.regions(reg_offset).bboxline.l = l;
        handles.curr_ann.regions(reg_offset).bboxline.t = t;
        handles.curr_ann.regions(reg_offset).bbox_figure = bbox_figure;
        handles.curr_ann.regions(reg_offset).active = 1;
    end

    % Remember to save the changes.
    guidata(hObject, handles);

function button_press_on_line(hObject, eventdata)
    %initialize handles.
    handles = guidata(hObject);

    % What button did the user click?
    % normal -> left click
    % alt -> right click
    % extended -> middle button. (might be different for mice with more
    % that dont have a middle button.
    mouseid = get(gcf,'SelectionType');

    if strcmp(mouseid, 'normal') == 1 && handles.correction.active == 1
        % Get the current position of the click.
        p1=get(gca,'CurrentPoint');
        p = [p1(1,1), p1(1,2)];
        m_d = 10; % consider clicks withing m_d pixels as good

        % do a search in the current regions (the active ones) for the one
        % that contains p in it's perimeter.
        x = p(1);
        y = p(2);
        selected_offset = -1;
        for i = 1:handles.curr_ann.reg_offset
            bboxt = handles.curr_ann.regions(i).bbox;
            xmin = bboxt(1);
            ymin = bboxt(2);
            xmax = bboxt(3);
            ymax = bboxt(4);
            if  ( (abs(x-xmin)<m_d || abs(x-xmax)<m_d)...
                  && (y>=ymin && y<=ymax) ) ...
                || ( (abs(y-ymin)<m_d || abs(y-ymax)<m_d)...
                     && (x>=xmin && x<=xmax) )
                % We have a winner.  The user clicked on a border pixel.
                selected_offset = i;
                break;
            end
        end

        % If we did not find any regions, just continue
        if selected_offset ~= -1
            % If we find a box:
            % Unpaint the previous green box if there is one.
            % Update the global handles.correction var
            % paint the new box.
            if handles.correction.offset ~= -1
                % We must undraw the green box
                bbl = handles.correction.box;
                set(bbl.l, 'Visible', 'off');
                set(bbl.t, 'Visible', 'off');
            end

            handles.correction.offset = selected_offset;
            pts = handles.curr_ann.regions(selected_offset).bbox;
            lbl = handles.curr_ann.regions(selected_offset).label;
            [l, t] = annotation_drawbox(pts, lbl, [0 1 0], ...
                @button_press_on_line);
            handles.correction.box.l = l;
            handles.correction.box.t = t;
        end
    end

    % Remember to save the changes.
    guidata(hObject, handles);

function on_key_press_callback(hObject, eventdata)
    %initialize handles
    handles = guidata(hObject);

    if strcmp(eventdata.Character, 'n') == 1 ||...
            strcmp(eventdata.Character, 'N') == 1
        % This function takes care of strange values in offset, so we will feel
        % save putting the next offset that we see.
        offset = handles.list_selected_file + 1;
        handles = select_offset_from_list(offset, handles, hObject);

    elseif strcmp(eventdata.Character, 'z') == 1 ||...
            strcmp(eventdata.Character, 'Z') == 1
        % will ONLY turn on zoom.  Matlab has a cute feature that it redefines
        % the KeyPressFcn when zoom is active.  This means that you cannot
        % deactivate zoom with a key press.   Thankyou Matlab.  I guess this is
        % bad for this particular situation but good in others.
        bstate = get(handles.zoom_toggle, 'Value');
        if bstate == get(handles.zoom_toggle, 'Min') %it is not pressed.
            set(handles.zoom_toggle, 'Value',...
                get(handles.zoom_toggle, 'Max'))
        end
        % call the zoom callback..
        zoom_toggle_Callback(handles.zoom_toggle, '', handles)

    elseif (strcmp(eventdata.Character, 'd') == 1 ||...
            strcmp(eventdata.Character, 'D') == 1) &&...
            handles.correction.active == 1
        % we need to deactivate the region that is marked by
        % handles.correction.offset. remove the green and red squares.
        % fist deactivate the region
        handles.curr_ann.regions(handles.correction.offset).active = 0;

        % remove the green box
        bbl = handles.correction.box;
        set(bbl.l, 'Visible', 'off');
        set(bbl.t, 'Visible', 'off');

        % remove the red box
        bbl = handles.curr_ann.regions(handles.correction.offset).bboxline;
        set(bbl.l, 'Visible', 'off');
        set(bbl.t, 'Visible', 'off');

        handles.correction.offset = -1;
        handles.correction.box.l = -1;
        handles.correction.box.t = -1;
    end

    % Remember to save the changes.
    guidata(hObject, handles);


% --- helper function.  It selects the offset in the file list.
% it was code that was being repeated.
function ret_handles = select_offset_from_list(offset, handles, hObject)
    % We ignore if there is nothing in the list.
    if size (handles.list_file_paths,2) == 0
        return;
    end

    % We search for the next image in the list.  If we have gotten to the end
    % of the list, we go to element 1.
    % Update the var that holds the current status of the list.
    axis_handler = handles.image_axis;

    % we use > and < to make sure we put the counter back to the first image
    % if we encounter some inconsistent values.
    if offset >= size(handles.list_file_paths,2) + 1 || offset < 1;
        handles.list_selected_file = 1;
    else
        handles.list_selected_file = offset;
    end

    % We get the selected file name.
    selected_file = handles.list_file_paths(handles.list_selected_file);

    % We select the corresponding file in the list of files.
    set(handles.file_list, 'Value', handles.list_selected_file);

    % We put the image in the axis.
    img = put_image_in_axis (selected_file, axis_handler, handles);

    % Modify handles.ann_curr to reflect the change
    handles.curr_ann = read_annotation(selected_file);
    handles.curr_ann = put_annotations_in_axis (handles.curr_ann,...
        @button_press_on_line);
    handles.curr_ann.image = size(img);

    % FIXME : HACK!!!
    %For some reason Matlab does not keep the handles with the guidata call
    % this is a workaround.
    ret_handles = handles;

    % Remember to save the changes.
    guidata(hObject, handles);


% --- Executes on button press in zoom_toggle.
function zoom_toggle_Callback(hObject, eventdata, handles)
    % hObject    handle to zoom_toggle (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of zoom_toggle
    zoom_toggle_state = get(hObject, 'Value');
    h = zoom;

    if zoom_toggle_state == 0
        set(h, 'Enable', 'off');
    elseif zoom_toggle_state == 1

        % make sure we disable the grab first
        set(pan, 'Enable', 'off');
        set(handles.grab_toggle, 'Value', 0);

        set(h, 'Enable', 'on');
    else
        % this should not be reached.
    end


% --- Executes on button press in grab_toggle.
function grab_toggle_Callback(hObject, eventdata, handles)
    % hObject    handle to grab_toggle (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of grab_toggle
    state = get(hObject, 'Value');
    h = pan;

    if state == 0
        set(h, 'Enable', 'off');
    elseif state == 1

        % make sure we disable the zoom first
        set(zoom, 'Enable', 'off');
        set(handles.zoom_toggle, 'Value', 0);

        set(h, 'Enable', 'on');
    else
        % this should not be reached.
    end


% --- Executes on button press in correct_toggle.
% this function basically changes the onclick callback function.
function correct_toggle_Callback(hObject, eventdata, handles)
    % hObject    handle to correct_toggle (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of correct_toggle
    state = get(hObject, 'Value');

    if state == 0
        % change to the button_pressed_on_image callback,  I should change
        % the name... :)
        handles.correction.active = 0;

    elseif state == 1
        % change to the special call back function for the correction
        % purposes.
        handles.correction.active = 1;
    end

    % Remember to save the changes.
    guidata(hObject, handles);


% --- Executes on button press in add_ftp.
function add_ftp_Callback(hObject, eventdata, handles)
% hObject    handle to add_ftp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [filename, pathname, handles.ftp_struct] = ...
        ftp_getlist(handles.ftp_struct);

    ifo = handles.image_files_offset;

    handles.image_files(ifo).image_files = filename;
    handles.image_files(ifo).directory = pathname;
    handles.image_files(ifo).full_paths = strcat(pathname,filename);
    handles.image_files_current_dir = char(pathname);

    % Now I have to add those files to the list in file_list
    % create a temp var with all the names we have up until now
    file_names_temp = [];
    for i = 1:ifo
        file_names_temp = cat(2,file_names_temp,...
            cellstr(handles.image_files(i).full_paths));
    end
    % I don't want repeated values in the list.
    file_names_temp = unique(file_names_temp);

    % Set the values in the file path list in the gui.
    set(handles.file_list,'String',file_names_temp,'Value',1);

    % Keep track of the new list so we don't have to calculate it twice
    handles.list_file_paths = file_names_temp;

    % Keep track of the image_file_offset.
    handles.image_files_offset = handles.image_files_offset + 1;

    % Don't do this for the ftp version.
    % For the users convinience select the first file in the list.
    % handles = select_offset_from_list(1, handles, hObject);

    % Remember to save the changes.
    guidata(hObject, handles);
