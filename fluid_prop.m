function varargout = fluid_prop(varargin)
% FLUID_PROP MATLAB code for fluid_prop.fig
%      FLUID_PROP, by itself, creates a new FLUID_PROP or raises the existing
%      singleton*.
%
%      This is a Marika function.
%
%      H = FLUID_PROP returns the handle to a new FLUID_PROP or the handle to
%      the existing singleton*.
%
%      FLUID_PROP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLUID_PROP.M with the given input arguments.
%
%      FLUID_PROP('Property','Value',...) creates a new FLUID_PROP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fluid_prop_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fluid_prop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fluid_prop

% Last Modified by GUIDE v2.5 18-Mar-2016 14:38:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fluid_prop_OpeningFcn, ...
                   'gui_OutputFcn',  @fluid_prop_OutputFcn, ...
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


% --- Executes just before fluid_prop is made visible.
function fluid_prop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fluid_prop (see VARARGIN)

% Choose default command line output for fluid_prop
handles.output = hObject;
load('fluid_properties.mat',...
    'mue','mui','rhoe','rhoi','Q0','pump_type');
    set(handles.mue,  'String',  num2str(mue) );
    set(handles.mui,  'String',  num2str(mui) );
    set(handles.rhoe, 'String', num2str(rhoe) );
    set(handles.rhoi, 'String', num2str(rhoi) );
    set(handles.Q0,   'String', num2str(Q0)   );
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fluid_prop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fluid_prop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function mue_Callback(hObject, eventdata, handles)
% hObject    handle to mue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mue as text
%        str2double(get(hObject,'String')) returns contents of mue as a double


% --- Executes during object creation, after setting all properties.
function mue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rhoe_Callback(hObject, eventdata, handles)
% hObject    handle to rhoe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rhoe as text
%        str2double(get(hObject,'String')) returns contents of rhoe as a double


% --- Executes during object creation, after setting all properties.
function rhoe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rhoe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mui_Callback(hObject, eventdata, handles)
% hObject    handle to mui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mui as text
%        str2double(get(hObject,'String')) returns contents of mui as a double


% --- Executes during object creation, after setting all properties.
function mui_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rhoi_Callback(hObject, eventdata, handles)
% hObject    handle to rhoi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rhoi as text
%        str2double(get(hObject,'String')) returns contents of rhoi as a double


% --- Executes during object creation, after setting all properties.
function rhoi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rhoi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Q0_Callback(hObject, eventdata, handles)
% hObject    handle to Q0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Q0 as text
%        str2double(get(hObject,'String')) returns contents of Q0 as a double


% --- Executes during object creation, after setting all properties.
function Q0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fluid_prop_done.
function fluid_prop_done_Callback(hObject, eventdata, handles)
% Retrieves variables as entered by user, saves them to a file called
% 'fluid_properties.mat' and then closes the window.
% hObject    handle to fluid_prop_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Values are NaN if they are not entered
mue  = str2double(get(handles.mue,'String'));
mui  = str2double(get(handles.mui,'String'));
rhoe = str2double(get(handles.rhoe,'String'));
rhoi = str2double(get(handles.rhoi,'String'));
Q0   = str2double(get(handles.Q0,'String'));
choice = get(handles.highflowopts,'Value');
if choice == 1
    pump_type = 'h';
else
    pump_type = 'l';
end

save('fluid_properties.mat',...
    'mue','mui','rhoe','rhoi','Q0','pump_type');
closereq


% --- Executes on selection change in highflowopts.
function highflowopts_Callback(hObject, eventdata, handles)
% hObject    handle to highflowopts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns highflowopts contents as cell array
%        contents{get(hObject,'Value')} returns selected item from highflowopts


% --- Executes during object creation, after setting all properties.
function highflowopts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highflowopts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
