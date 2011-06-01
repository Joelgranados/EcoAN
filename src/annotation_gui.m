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
% GNU General Public License for more details.
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

    % Offset of current selected label
    handles.label_selected_label = -1;

    % Offset of current selected file
    handles.list_selected_file = -1;

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

    % The configuration stuff.  FIXME: we should have a function that reads
    % everything into the variable.
    handles.config = annotation_conf('annotation.conf', 0, 'r');
    if isempty(handles.config.cache_dir)
        handles.config.cache_dir = 'cache';
    end

    % Initialize the figure1 callback definitions.
    set(handles.figure1, 'KeyPressFcn', @on_key_press_callback);

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes annotation_gui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


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

    % We save before doing anything
    if handles.list_selected_file ~= -1
        annotation_save(handles, handles.curr_ann);
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
    % We save before doing anything.  This will allow the lock to be
    % released in the server.
    if handles.list_selected_file ~= -1
        annotation_save(handles, handles.curr_ann);
    end

    close(handles.figure1);

% --- Executes on selection change in labels.
function labels_Callback(hObject, eventdata, handles)
    handles.label_selected_label = get(hObject, 'Value');

    if handles.correction.active == 1 && handles.correction.offset ~= -1
        % handles.label_selected_label is just the offset.
        l_strings = get(handles.labels, 'String');
        l_offset = handles.label_selected_label;

        bbl = handles.correction.box;
        set(bbl.t, 'String', l_strings(l_offset));

        selected_offset = handles.correction.offset;
        set(handles.curr_ann.regions(selected_offset).bboxline.t, ...
            'String', l_strings(l_offset));
        handles.curr_ann.regions(selected_offset).label = ...
            l_strings(l_offset);
    end

    % Remember to save the changes.
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function labels_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'),...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    set (hObject, 'String', 'Default');

function labels = labels_addLabels(handles, pathname)
    labels = get (handles.labels, 'String');
    try
        dirlabels = textread( strcat(pathname, 'labels.txt'), '%s\n' );
    catch
        dirlabels = '';
    end
     labels = cat (1, dirlabels, labels);

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

    % Add the labels specified in the pathname
    set(handles.labels, 'String', labels_addLabels(handles, pathname));

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
% hObject    handle to clear_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Set the label list back to its default.
    labels_CreateFcn(handles.labels, '', handles);
    handles.paths = [];
    set(handles.file_list, 'String', '', 'Value', 0);
    cla(handles.image_axis, 'reset');
    guidata(hObject, handles);


% --- Called when an image needs to be uploaded to an axis.
% input_image   is the string that references the image
% axis_handler  the handler use as parent of the image
function retimg = put_image_in_axis (input_image, axis_handler, handles)
    if exist (char(input_image)) > 0
        img = imread(char(input_image));
        if get(handles.hsv, 'Value') == 1
            img = rgb2hsv(img);
        elseif get(handles.ycbcr, 'Value') == 1
            img = rgb2ycbcr(img);
        elseif get(handles.gray, 'Value') == 1
            img = rgb2gray(img);
            colormap(axis_handler, gray(256));
        end
        image(img, 'Parent', axis_handler,...
            'ButtonDownFcn', @button_pressed_on_image);
        set(gca,'Units','pixels');
        retimg = img;
    else
        msgboxText{1} =  strcat('File not found: ', input_image);
        msgbox(msgboxText,'File Not Found', 'error');
        retimg = 0;
    end

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
            % modify the previous region.

            bbt = handles.curr_ann.regions(reg_offset).bbox;
            % Remember bbox_figure[ x y width height] in cartesian coor.
            % Remember bbt(1)=xmin bbt(2)=ymin bbt(3)=xmax bbt(4)=ymax
            bbox_figure = handles.curr_ann.regions(reg_offset).bbox_figure;

            % We find out which part of the last region will be stretched by
            % analysing the relation between the last annotation's center
            % and the current possition.
            [fixed_figure, fixed_axis] =...
                annotation_util_calcsquares(bbt,bbox_figure,p1);

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

        % Check for negative and overflow values
        if (xmin < 0) xmin = 0; end
        if (ymin < 0) ymin = 0; end
        if (xmax > handles.curr_ann.image(2))
            xmax = handles.curr_ann.image(2);
        end
        if (ymax > handles.curr_ann.image(1))
            ymax = handles.curr_ann.image(1);
        end

        % Don't create size 0 boxes.
        if xmin == xmax || ymin == ymax
            guidata(hObject, handles);
            return;
        end

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
    % extended -> middle button. (might be different for mice
    % that dont have a middle button).
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
            if  (( (abs(x-xmin)<m_d || abs(x-xmax)<m_d)...
                   && (y>=ymin && y<=ymax) ) ...
                 || ( (abs(y-ymin)<m_d || abs(y-ymax)<m_d)...
                      && (x>=xmin && x<=xmax) ))...
                && handles.curr_ann.regions(i).active ~= 0
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
        [success, handles] = ...
            select_offset_from_list(offset, handles, hObject);

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
           handles.correction.active == 1 && handles.correction.offset >= 0
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
% it was code that was being repeated.  If the return value  is not successfull one
% can always reuse the previous handles var.
function [success, ret_handles] = select_offset_from_list(offset, handles, hObject)
    % We dafault to a successfull return :(
    success = 1;

    % We ignore if there is nothing in the list.
    if size (handles.paths,2) == 0
        return;
    end

    % We search for the next image in the list.  If we have gotten to the end
    % of the list, we go to element 1.
    % Update the var that holds the current status of the list.
    axis_handler = handles.image_axis;

    % we use > and < to make sure we put the counter back to the first image
    % if we encounter some inconsistent values.
    if offset >= size(handles.paths,2) + 1 || offset < 1;
        offset = 1;
    end

    % We get the selected file name.
    selected_file = handles.paths(offset);

    % We make sure that the file is in the local filesystem
    [local_file, success, handles] =...
        annotation_getfile(handles, selected_file);
    if ~success
        ret_handles = handles;
        return;
    end% we have already shown an error.

    % We 'officialize' the selection
    handles.list_selected_file = offset;

    % We select the corresponding file in the list of files.
    set(handles.file_list, 'Value', handles.list_selected_file);

    % We put the image in the axis.
    img = put_image_in_axis (local_file, axis_handler, handles);

    % Modify handles.ann_curr to reflect the change
    handles.curr_ann = annotation_read(local_file);
    handles.curr_ann = annotation_put_in_axis (handles.curr_ann,...
        @button_press_on_line);
    handles.curr_ann.image = size(img);

    % modify the review items.
    handles = update_review_items(handles);

    % make sure we reinitialize the relevant correction vars.
    % Offset of region to correct.  This is only valid when correcting.  It
    % should be -1 otherwise.
    handles.correction.offset = -1;
    handles.correction.box.l = -1;
    handles.correction.box.t = -1;

    % FIXME : HACK!!!
    %For some reason Matlab does not keep the handles with the guidata call
    % this is a workaround.
    ret_handles = handles;

    % Remember to save the changes.
    guidata(hObject, handles);


% --- Executes on button press in zoom_toggle.
function zoom_toggle_Callback(hObject, eventdata, handles)
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


% --- Executes on button press in review_checkbox.
function review_checkbox_Callback(hObject, eventdata, handles)
    state = get(handles.review_checkbox, 'Value');
    if state == 1
        % This means the user wants to review.  let him modify the reviewer
        % text and put todays date in the date text.
        rev_date = datestr(now, 'dd-mm-yyyy');
        rev_rev = 'Default_Reviewer';
        set(handles.date_text, 'String', rev_date);
        set(handles.reviewer_text, 'Enable', 'on');
        set(handles.reviewer_text, 'String', rev_rev);
        handles.curr_ann.review.date = rev_date;
        handles.curr_ann.review.reviewer = rev_rev;
    elseif state == 0
        % turn off reviewes.
        % FIXME: there could be an issue with the text left in date and
        % reviewer text boxes.
        set(handles.reviewer_text, 'Enable', 'off');
    end

    % Remember to save the changes.
    guidata(hObject, handles);

function date_text_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function date_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function reviewer_text_Callback(hObject, eventdata, handles)
    handles.curr_ann.review.reviewer =...
        get(handles.reviewer_text, 'String');
    % Remember to save the changes.
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function reviewer_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ret_handles = update_review_items(handles)
    review_checkbox_state = get(handles.review_checkbox, 'Value');
    if review_checkbox_state == 1
        % They are reviewing, dont change the contents.
        handles.curr_ann.review.date = get(handles.date_text, 'String');
        handles.curr_ann.review.reviewer = get(handles.reviewer_text, 'String');
    elseif review_checkbox_state == 0
        % They are not reviewing and we should show the file info.  We
        % don't change curr_ann because it already has the file info.
        set(handles.reviewer_text, 'String', handles.curr_ann.review.reviewer);
        set(handles.date_text, 'String', handles.curr_ann.review.date);
    end
    ret_handles = handles;

% --- Executes when selected object is changed in vispanel.
function vispanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in vispanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
    [success, handles] = ...
            select_offset_from_list(handles.list_selected_file,...
                handles, hObject);

    % Remember to save the changes.
    guidata(hObject, handles);
