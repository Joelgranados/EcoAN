function varargout = ftp_conf_gui(varargin)
% FTP_CONF_GUI M-file for ftp_conf_gui.fig
%      FTP_CONF_GUI, by itself, creates a new FTP_CONF_GUI or raises the existing
%      singleton*.
%
%      H = FTP_CONF_GUI returns the handle to a new FTP_CONF_GUI or the handle to
%      the existing singleton*.
%
%      FTP_CONF_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FTP_CONF_GUI.M with the given input arguments.
%
%      FTP_CONF_GUI('Property','Value',...) creates a new FTP_CONF_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ftp_conf_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ftp_conf_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ftp_conf_gui

% Last Modified by GUIDE v2.5 22-Apr-2010 17:16:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ftp_conf_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ftp_conf_gui_OutputFcn, ...
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


% --- Executes just before ftp_conf_gui is made visible.
function ftp_conf_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ftp_conf_gui (see VARARGIN)

% Choose default command line output for ftp_conf_gui
% handles.output = hObject;

% set everything up...
set(handles.server_edit, 'String', char(varargin(1)));
set(handles.user_edit, 'String', char(varargin(2)))
set(handles.dir_edit, 'String', char(varargin(3)));

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes ftp_conf_gui wait for user response (see UIRESUME)
% uiwait(handles.ftp_figure);


% --- Outputs from this function are returned to the command line.
function varargout = ftp_conf_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Wait until we close the ftp_figure
uiwait();

% Get default command line output from handles structure
s.server = get(handles.server_edit, 'String');
s.username = get(handles.user_edit, 'String');
s.directory = get(handles.dir_edit, 'String');
s.passwd = get(handles.passwd_edit, 'String');
varargout{1} = s;
close(handles.ftp_figure);

function server_edit_Callback(hObject, eventdata, handles)
% hObject    handle to server_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of server_edit as text
%        str2double(get(hObject,'String')) returns contents of server_edit as a double


% --- Executes during object creation, after setting all properties.
function server_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to server_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function user_edit_Callback(hObject, eventdata, handles)
% hObject    handle to user_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of user_edit as text
%        str2double(get(hObject,'String')) returns contents of user_edit as a double


% --- Executes during object creation, after setting all properties.
function user_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to user_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dir_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dir_edit as text
%        str2double(get(hObject,'String')) returns contents of dir_edit as a double


% --- Executes during object creation, after setting all properties.
function dir_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We check if we have text in all the text areas.
server = get(handles.server_edit, 'String');
username = get(handles.user_edit, 'String');
directory = get(handles.dir_edit, 'String');
passwd = get(handles.passwd_edit, 'String');

if ~isempty(server) && ~isempty(username) &&...
        ~isempty(directory)
    uiresume();
else
    % There is one text area that needs to be filled in..
    msgboxText{1} =  strcat('Make sure you fill in all the text areas.');
    msgbox(msgboxText,'File Not Found', 'error');
end

guidata(hObject, handles);


% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.server_edit, 'String', '');
set(handles.user_edit, 'String', '');
set(handles.dir_edit, 'String', '');
set(handles.passwd_edit, 'String', '');
uiresume();

guidata(hObject, handles);

function passwd_edit_Callback(hObject, eventdata, handles)
% hObject    handle to passwd_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of passwd_edit as text
%        str2double(get(hObject,'String')) returns contents of passwd_edit as a double


% --- Executes during object creation, after setting all properties.
function passwd_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to passwd_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
