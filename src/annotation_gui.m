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

    handles.remove_active = 0;

    % Initialize the figure1 callback definitions.
    set(handles.figure1, 'KeyPressFcn', @on_key_press_callback);

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
    % Remember to save the changes.
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function labels_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'),...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    set (hObject, 'String', {'---','Default'});

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
        elseif get(handles.canny, 'Value') == 1
            img = edge(rgb2gray(img), 'canny');
            colormap(axis_handler, gray(2));
        end

        image(img, 'Parent', axis_handler,...
            'ButtonDownFcn', @button_pressed_on_image);
        set(gca,'Units','pixels');

        if get(handles.gradient, 'Value') == 1
            step = 10;
            [U, V] = gradient(double(rgb2gray(img)));
            [X,Y] = meshgrid(1:size(img,2),1:size(img,1));
            U = U(1:step:size(U,1), 1:step:size(U,2));
            V = V(1:step:size(V,1), 1:step:size(V,2));
            X = X(1:step:size(X,1), 1:step:size(X,2));
            Y = Y(1:step:size(Y,1), 1:step:size(Y,2));
            hold on;quiver(axis_handler, X, Y, U, V);hold off;
        end

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

    if ((strcmp(mouseid, 'normal') ~= 1 && strcmp(mouseid, 'alt') ~= 1)) ||...
            handles.remove_active ~= 0
        return;
    end

    hrect = imrect(handles.image_axis);

    % increment offset for new box.
    handles.curr_ann.reg_offset = handles.curr_ann.reg_offset + 1;
    reg_offset = handles.curr_ann.reg_offset;

    % Create a new region in the next offset
    handles.curr_ann.regions(reg_offset) = annotation_init;
    handles.curr_ann.regions(reg_offset).roi = hrect;
    handles.curr_ann.regions(reg_offset).bbox =...
        round(getPosition(hrect));

    % We will use the label that is currently selected.
    l_offset = get(handles.labels, 'Value');
    l_strings = get(handles.labels, 'String');
    hrect_pos = round(getPosition(hrect));
    handles.curr_ann.regions(reg_offset).label =...
        create_text_label(l_strings(l_offset),...
                          hrect_pos(1), hrect_pos(2));

    addNewPositionCallback(hrect,...
        @(pos)on_move_imrect(pos,...
                             hrect,...
                             handles.curr_ann.regions(reg_offset).label));

    % new annotation is active
    handles.curr_ann.regions(reg_offset).active = 1;

    % Remember to save the changes.
    guidata(hObject, handles);

function text_handle = create_text_label(str, X, Y)
    text_handle = text(X, Y, str,...
        'Color', [1 0 0], 'FontSize', 16,...
        'Clipping', 'on',...
        'ButtonDownFcn',...
        @(text_handle,~)button_pressed_on_text_label(text_handle));

function button_pressed_on_text_label(text_handle)
    handles = guidata(gco);
    l_offset = get(handles.labels, 'Value');
    l_strings = get(handles.labels, 'String');
    set(text_handle, 'String', l_strings(l_offset));

function on_move_imrect(pos, hrect, text_handle)
    %called whenever a rect is moved.
    % FIXME (HACK) we could receive a move from a deleted object.
    if (size(gco,1) == 0) return; end;

    handles = guidata(gco);
    if handles.remove_active == 0
        set(text_handle, 'Position', [pos(1), pos(2)]);
    elseif handles.remove_active == 1
        % delete the imrect_handle, make the text invisible and active=0.
        for i = 1:size(handles.curr_ann.regions,2)
            if handles.curr_ann.regions(i).active == 1 &&...
                    handles.curr_ann.regions(i).roi == hrect
                delete(handles.curr_ann.regions(i).roi);
                handles.curr_ann.regions(i).roi = NaN;
                set(handles.curr_ann.regions(i).label, 'Visible', 'off');
                delete(handles.curr_ann.regions(i).label);
                handles.curr_ann.regions(i).label = NaN;
                handles.curr_ann.regions(i).active = 0;
            end
        end
    end

    % Remember to save the changes.
    guidata(gcf, handles);

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

    % We make sure that the file is in the local filesystem
    [local_file, success, ret_handles] =...
        annotation_getfile(ret_handles, selected_file);
    if ~success
        return;
    end% we have already shown an error.

    % We 'officialize' the selection
    ret_handles.list_selected_file = offset;

    % We select the corresponding file in the list of files.
    set(ret_handles.file_list, 'Value', ret_handles.list_selected_file);

    % We put the image in the axis.
    img = put_image_in_axis (local_file, axis_handler, ret_handles);

    % Modify ret_handles.ann_curr to reflect the change
    ret_handles.curr_ann = annotation_read(local_file);

    % Paint annotations. Remember that the last region is empty.
    for i = 1:size(ret_handles.curr_ann.regions, 2)
        % we paint only the active ones.
        if ret_handles.curr_ann.regions(i).active == 1
            imrect_pos = [ ret_handles.curr_ann.regions(i).bbox(1),...
                           ret_handles.curr_ann.regions(i).bbox(2),...
                           ret_handles.curr_ann.regions(i).bbox(3),...
                           ret_handles.curr_ann.regions(i).bbox(4) ];
            ret_handles.curr_ann.regions(i).roi = imrect(ret_handles.image_axis,...
                                                     imrect_pos);
            % Work with text ret_handles not strings.
            ret_handles.curr_ann.regions(i).label =...
                create_text_label(char(ret_handles.curr_ann.regions(i).label),...
                                  imrect_pos(1), imrect_pos(2));

            % func handle that will pass pos and the related text.
            addNewPositionCallback(...
                ret_handles.curr_ann.regions(i).roi,...
            	@(pos)on_move_imrect(pos,...
                                     ret_handles.curr_ann.regions(i).roi,...
                                     ret_handles.curr_ann.regions(i).label) );

        end
    end
    iptPointerManager(gcf);
    ret_handles.curr_ann.image = size(img);

    % modify the review items.
    ret_handles = update_review_items(ret_handles);

    % Remember to save the changes.
    guidata(hObject, ret_handles);


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


% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    state = get(hObject, 'Value');

    if state == 0
        % change to the button_pressed_on_image callback,  I should change
        % the name... :)
        handles.remove_active = 0;

    elseif state == 1
        % change to the special call back function for the correction
        % purposes.
        handles.remove_active = 1;
    end

    % Remember to save the changes.
    guidata(hObject, handles);
