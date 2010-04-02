function varargout = annotation_gui(varargin)
% ANNOTATION_GUI M-file for annotation_gui.fig
%      ANNOTATION_GUI, by itself, creates a new ANNOTATION_GUI or raises the existing
%      singleton*.
%
%      H = ANNOTATION_GUI returns the handle to a new ANNOTATION_GUI or the handle to
%      the existing singleton*.
%
%      ANNOTATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATION_GUI.M with the given input arguments.
%
%      ANNOTATION_GUI('Property','Value',...) creates a new ANNOTATION_GUI or raises the
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

% Last Modified by GUIDE v2.5 31-Mar-2010 18:00:12

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
handles.curr_ann.regions(1) = annotation_init;

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

% Update the var that holds the current status of the list.
handles.list_selected_file = get(hObject,'Value');

% Every time the user selects an image in the file list we change the image
% in the axis.
selected_file = handles.list_file_paths(handles.list_selected_file);
axis_handler = handles.image_axis;
put_image_in_axis (selected_file, axis_handler, handles);

% Modify handles.ann_curr to reflect the change
handles.curr_ann = read_annotation(selected_file);
put_annotations_in_axis (handles.curr_ann);

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
if ~iscellstr(filename) && ~iscellstr(pathname) && ~iscellstr(filterindex)
    return
end

handles.image_files(ifo).image_files = filename;
handles.image_files(ifo).directory = pathname;
handles.image_files(ifo).full_paths = strcat(pathname,filename);
handles.image_files_current_dir = pathname;

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

% Remember to save the changes.
guidata(hObject, handles);

% --- Called when an image needs to be uploaded to an axis.
function put_image_in_axis (input_image, axis_handler, handles)
% input_image   is the string that references the image
% axis_handler  the handler use as parent of the image
if exist (char(input_image)) > 0
    img = imread(char(input_image));
    imagesc(img, 'Parent', axis_handler, 'ButtonDownFcn',...
        @button_pressed_on_image);
    set(gca,'Units','pixels');
else
    msgboxText{1} =  strcat('File not foun: ', input_image);
    msgbox(msgboxText,'File Not Found', 'error');
end

% --- Called when the a button is pressed on the figure/image
function button_pressed_on_image(hObject, eventdata)
% hObject       is the handle to the related object.
% eventdata     I have no idea what Matlab puts here.

% We help the user create a square.
p1=get(gca,'CurrentPoint');
rbbox; % the rubber box thingy :)
p2=get(gca,'CurrentPoint');
p=round([p1;p2]);

% We define the coordinates.
xmin=min(p(:,1));
xmax=max(p(:,1));
ymin=min(p(:,2));
ymax=max(p(:,2));

% Here we expect curr_ann to be in a special state.  We assume that that
% var has a certain number of region elements (N).  The Nth element will not
% contain any info and we can use it.  We will leave curr_ann in the same
% state by adding an empty element when we are done.

%initialize handles.
handles = guidata(hObject);
% Create a new region
reg_offset = size(handles.curr_ann.regions, 2);
handles.curr_ann.regions(reg_offset).bbox = [xmin ymin xmax ymax];

% We will use the label that is currently selected.
l_offset = get(handles.labels, 'Value');
l_strings = get(handles.labels, 'String');
handles.curr_ann.regions(reg_offset).label = l_strings(l_offset);

% We create an empty region...
handles.curr_ann.regions(reg_offset + 1) = annotation_init;

% Draw the box in red.
pts = handles.curr_ann.regions(reg_offset).bbox;
drawbox(pts);

% Remember to save the changes.
guidata(hObject, handles);

function on_key_press_callback(hObject, eventdata)

if strcmp(eventdata.Character, 'n') == 1 ||...
        strcmp(eventdata.Character, 'N') == 1
  %initialize handles
  handles = guidata(hObject);

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
  if handles.list_selected_file >= size(handles.list_file_paths,2) ||...
          handles.list_selected_file < 1;
      handles.list_selected_file = 1;
  else
      handles.list_selected_file = handles.list_selected_file + 1;
  end

  % We get the selected file name.
  selected_file = handles.list_file_paths(handles.list_selected_file);

  % We select the corresponding file in the list of files.
  set(handles.file_list, 'Value', handles.list_selected_file);

  % We put the image in the axis.
  put_image_in_axis (selected_file, axis_handler, handles);

  % Modify handles.ann_curr to reflect the change
  handles.curr_ann = read_annotation(selected_file);
  put_annotations_in_axis (handles.curr_ann);

  % Remember to save the changes.
  guidata(hObject, handles);
end
    
