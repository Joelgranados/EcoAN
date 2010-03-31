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
handles.image_files_regex_string = '*.gif;*.jpg;*.png;*.jpeg,*.GIF;*.JPG;*.PNG;*.JPEG';
handles.image_files_current_dir = pwd;

% Current selected label in label pop up
handles.label_selected_label = -1;

% Current selected file in file list.
handles.list_selected_file = -1;

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

% Hints: contents = cellstr(get(hObject,'String')) returns file_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from file_list
handles.list_selected_file = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function file_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_annotation.
function save_annotation_Callback(hObject, eventdata, handles)
% hObject    handle to save_annotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

% Hints: contents = cellstr(get(hObject,'String')) returns labels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from labels
handles.label_selected_label = get(hObject, 'Value');


% --- Executes during object creation, after setting all properties.
function labels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

try
    labels = textread('labels.txt', '%s\n');
    set(hObject, 'String', labels);
catch
    % The file is not where we expect.... error out with a message.
    msgboxText{1} =  strcat('I cant find the file where the labels are stored.  Please create this file, name it labels.txt and put it in:', pwd);
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
[filename, pathname, filterindex] = uigetfile(handles.image_files_regex_string,'Pick an image file', 'MultiSelect', 'on', handles.image_files_current_dir);
handles.image_files(ifo).image_files = filename;
handles.image_files(ifo).directory = pathname;
handles.image_files(ifo).full_paths = strcat(pathname,filename);
handles.image_files_current_dir = pathname;

% Now I have to add those files to the list in file_list
% create a temp var with all the names we have up until now
file_names_temp = [];
for i = 1:ifo
    file_names_temp = cat(2,file_names_temp, cellstr(handles.image_files(i).full_paths));
end
% I don't want repeated values in the list.
file_names_temp = unique(file_names_temp);
set(handles.file_list,'String',file_names_temp,'Value',1);

% Keep track of the image_file_offset.
handles.image_files_offset = handles.image_files_offset + 1;

% Remember to save the changes.
guidata(hObject, handles);
