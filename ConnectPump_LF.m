function varargout = ConnectPump_LF(varargin)
%% ConnectPump_LF MATLAB code for ConnectPump_LF.fig
%      ConnectPump_LF is an interface for a MicroLynx-controlled pump
%      connected to a Sensirion Liquid Flow Sensor
%         
%      Check to see if it's working by pressing Connect, Run Demo and Disconnect
%      Capabilities of specific functions are described more fully in the
%      experimental protocol
%
%      ConnectPump_LF was designed by Michelle Maiden using MATLAB's GUIDE
%      
%      ConnectPump_LF must be in the same folder as the following files:
%           ConnectPump_LF.fig, ShdlcDriver.dll, SensorCableDriver.dll, 
%           Test.exe, demo.mat
%
%      ConnectPump_LF, by itself, creates a new ConnectPump_LF or raises the existing
%      singleton*.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES %%

% Last Modified by GUIDE v2.5 08-Feb-2016 10:32:39

%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConnectPump_LF_OpeningFcn, ...
                   'gui_OutputFcn',  @ConnectPump_LF_OutputFcn, ...
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



% --- Executes just before ConnectPump_LF is made visible.
function ConnectPump_LF_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConnectPump_LF (see VARARGIN)

% Choose default command line output for ConnectPump_LF
handles.output = hObject;
% Update handles structure 
handles.VM = 50;
handles.ACCL = 1000;
handles.DECL = 1000;
handles.MOVR=0;
handles.volRate = 50;
handles.backgroundRate = mL2uL(0.25);
set(handles.backgroundrate,'String',num2str(0.25));
handles.filename='Filename';
handles.progname='progname';
% Sets default file name
handles.s =  'Output.txt';
x=clock;
handles.t =  ['Output_',num2str(x(2)),'_',num2str(x(3)),'_',num2str(x(1)),'.txt'];
handles.print_on = 0; % 0 sends output to pump, 1 sends output to fid
set(handles.pumpon,'Value',1,'Enable','On');
set(handles.pumpoff,'Value',0,'Enable','Off');
guidata(hObject,handles)

% UIWAIT makes ConnectPump_LF wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ConnectPump_LF_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
    
%% PANEL 1: Pump Controls

% --- Executes on button press in pumpon.
function pumpon_Callback(hObject, eventdata, handles)
% Connects the MicroLynx pump to the computer
% hObject    handle to pumpon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear handles.s  
     if strcmp('PCWIN',computer) %If this is a windows machine
            disp('Windows Computer. Yay Windows.');
     end
     if strcmp('MACI64',computer) % If this is a mac
            disp('Mac Computer. Yay Mac.');
     end
    
        if strcmp('PCWIN', computer) %If this is a windows machine
            handles.s=instrfind('Type', 'serial', 'Port', 'COM5', 'Tag', '');
            handles.s = serial('COM5'); % Sets the handle to the port
        end
        if strcmp('MACI64', computer) % If this is a mac
            handles.s=instrfind('Type', 'serial', 'Port', '/dev/tty.usbserial', 'Tag', '');
            handles.s = serial('/dev/tty.usbserial');
        end
        fclose(handles.s); % Closes the connection with the pump. This is
        % required because parts of the handles.s structure still need to 
        % be set
        handles.s = handles.s(1); % Removes repetative information
    % Opens dialog box that allows user to input
    % densities, viscosities, background rate
    fluid_prop
    handles.f = load(['fluid_properties.mat'],...
                      'mue','mui','rhoe','rhoi','Q0','pump_type');

    % Sets standard values for the pump
    % See user manual pg 31 for acceptable values of each
    set(handles.s,'BaudRate',9600);
    set(handles.s,'DataBits',8);
    set(handles.s,'StopBits',1);
    set(handles.s,'Parity','none');
    set(handles.s,'FlowControl','none');
    % Re-opens connection with the pump then displays current settings
    fopen(handles.s);
    disp(handles.s)
    pause(0.25);
    % Communication test: should pring the command sent followed by the
    % pump's response
    uLynx(handles.s,handles.t,'hello',1,handles.print_on,handles)
    uLynx(handles.s,handles.t,'print ver',1,handles.print_on,handles)
    if handles.f.Q0 == 0
        uLynx(handles.s,handles.t,'sstp',1,handles.print_on,handles);
    else
        handles.backgroundRate = mL2uL(handles.f.Q0);
        set(handles.backgroundrate,'String',num2str(handles.f.Q0));
        uLynx(handles.s,handles.t,['slew ',num2str(handles.backgroundRate)],1,handles.print_on,handles);
    end
    fscanf(handles.s); % This line may not do anything
    set(handles.pumpon,'Value',0,'Enable','Off');
    set(handles.pumpoff,'Value',1,'Enable','On');
    disp(['Output from session will be saved to ',handles.t,'.']);
    guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function pumpon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumpon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in pumpoff.
function pumpoff_Callback(hObject, eventdata, handles)
% Disconnects the pump from the computer
% hObject    handle to pumpoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fclose(handles.s);
disp(handles.s);
delete(handles.s);
    set(handles.pumpoff,'Value',0,'Enable','Off');
    set(handles.pumpon,'Value',0,'Enable','On');
    
% --- Executes on button press in pumpstart.
function pumpstart_Callback(hObject, eventdata, handles)
% Tells the pump to run at a specified rate
% If no rate is selected, will run at 3 mL/min
% hObject    handle to pumpstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    uLynx(handles.s,handles.t,['slew ', num2str(handles.VM)],1,handles.print_on,handles);

% --- Executes on button press in pumpstop.
function pumpstop_Callback(hObject, eventdata, handles)
% Stops the pump. Does not work if a program is running.
% hObject    handle to pumpstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uLynx(handles.s,handles.t,'sstp',1,handles.print_on,handles);

function commline_Callback(hObject, eventdata, handles)
% Allows user to input commands directly into pump
% For a list of commands, see pump manual, Appx B
% hObject    handle to commline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of commline as text
%        str2double(get(hObject,'String')) returns contents of commline as a double

    foo=get(hObject,'String');
    uLynx(handles.s,handles.t,foo,1,handles.print_on,handles)

% --- Executes during object creation, after setting all properties.
function commline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to commline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in readahead.
function readahead_Callback(hObject, eventdata, handles)
% Read output from pump (if not already displayed)
% hObject    handle to readahead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp(fgets(handles.s));

% --- Executes on button press in read10.
function read10_Callback(hObject, eventdata, handles)
% Read 10 lines of output from pump
% Not recommended to press unless pgm is being downloaded to pump
% If request can not be processed, user will be unable to access the
% program until the requests are returned.
% hObject    handle to read10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for ii=1:10
    disp(fgets(handles.s));
end

% --- Executes on button press in emergencystop.
function emergencystop_Callback(hObject, eventdata, handles)
% Stops all pump operations, even if a pgm is running
% hObject    handle to emergencystop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   fprintf(handles.s,char(27)); % 27 is ASCII for escape

   % --- Executes on button press in openfile.
function openfile_Callback(hObject, eventdata, handles)
% Allows ConnectPump_LF to run even if pump is not connected
% Sends all output to specified txt file
% hObject    handle to openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    fluid_prop
    handles.f = load('fluid_properties.mat',...
                              'mue','mui','rhoe','rhoi','Q0');
	handles.s =  'Output.txt';
    handles.fid = fopen(handles.s,'a');
    fprintf(handles.fid,['Below data is from: ',num2str(fix(clock)),'\n']);
    disp(['No connection to the pump. Output from session will be saved to ',handles.s,'.']);
    set(handles.openfile,'Value',1,'Enable','Off')
    set(handles.closefile,'Value',0,'Enable','On')
    handles.print_on = 1;
guidata(hObject,handles);

% --- Executes on button press in closefile.
function closefile_Callback(hObject, eventdata, handles)
% Closes file created in openfile
% hObject    handle to closefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fclose(handles.fid);
set(handles.closefile,'Value',1,'Enable','Off')
set(handles.openfile,'Value',0,'Enable','On')
guidata(hObject,handles);

function savefile_Callback(hObject, eventdata, handles)
% User inputs name of output file
% If not file is selected, saved to Output_'date'.txt
% hObject    handle to savefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of savefile as text
%        str2double(get(hObject,'String')) returns contents of savefile as a double

savefile  = get(hObject, 'String'); 
handles.s = [savefile,'.txt'];
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function savefile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% PANEL 2: Control by Rate Flow 
function backgroundrate_Callback(hObject, eventdata, handles)
% Sets background rate from text box
% hObject    handle to backgroundrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of backgroundrate as text
%        str2double(get(hObject,'String')) returns contents of backgroundrate as a double

backgroundRate=get(hObject,'String');
    if abs(str2num(backgroundRate))>30
        return; % Stops pump from going over max rate
    end
    handles.backgroundRate = num2str(mL2uL(str2num(backgroundRate)));
    if get(handles.pumpon,'Value')==0
         uLynx(handles.s,handles.t,'DECL = 1000',1,handles.print_on,handles)
         uLynx(handles.s,handles.t,'ACCL = 1000',1,handles.print_on,handles)
    uLynx(handles.s,handles.t,['slew ',handles.backgroundRate],1,handles.print_on,handles)
    end
    
    set(hObject,'String',backgroundRate);
    guidata(hObject,handles);
    

% --- Executes during object creation, after setting all properties.
function backgroundrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backgroundrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function rateslider_Callback(hObject, eventdata, handles)
% Controls pump flow rate from slider
% hObject    handle to rateslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

   VM=get(hObject,'Value');
   handles.VM = mL2uL(VM);  
   disp(VM);
   uLynx(handles.s,handles.t,['slew ',sprintf('%f',handles.VM)],1,handles.print_on,handles);
   guidata(hObject,handles);
   % Sets text value based on slider position
   hTxt = findobj(gcf,'Tag','rateoutput');
   set(hTxt,'String',num2str(VM));
   guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function rateslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rateslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function rateoutput_Callback(hObject, eventdata, handles)
% Controls pump flow rate from text box
% hObject    handle to rateoutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of rateoutput as text
%        str2double(get(hObject,'String')) returns contents of rateoutput as a double

VM=get(hObject,'String');
    handles.VM = num2str(mL2uL(str2num(VM)));
    uLynx(handles.s,handles.t,['slew ',handles.VM],1,handles.print_on,handles)
    % Sets the slider to the position inputed in the text box
    hTxt = findobj(gcf,'Tag','rateslider');
    set(hTxt,'Value',str2num(VM));
    guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function rateoutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rateoutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function accelerationslider_Callback(hObject, eventdata, handles)
% Controls pump acceleration (deceleration) from one rate to another with
% slider
% hObject    handle to accelerationslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

acc=get(hObject,'Value');
    if acc>0
        handles.ACCL=mL2uL(acc)./60; % Converts to a per second basis
        uLynx(handles.s,handles.t,['ACCL=',num2str(handles.ACCL)],1,handles.print_on,handles)
    else
        handles.DECL=abs(acc);
        uLynx(handles.s,handles.t,['DECL=',num2str(handles.DECL)],1,handles.print_on,handles)
    end
    % Sets the slider to teh position indicated by the text box
    hTxt = findobj(gcf,'Tag','accelerationoutput');
    set(hTxt,'String',num2str(acc));
    guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function accelerationslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accelerationslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function accelerationoutput_Callback(hObject, eventdata, handles)
% Controls pump acceleration (deceleration) from one rate to another
% hObject    handle to accelerationoutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of accelerationoutput as text
%        str2double(get(hObject,'String')) returns contents of accelerationoutput as a double

   acc=get(hObject,'String');
   acc=str2double(acc);
    if acc>0
        handles.ACCL=mL2uL(acc)./60;
        uLynx(handles.s,handles.t,['ACCL=',num2str(handles.ACCL)],1,handles.print_on,handles)
    else
        handles.DECL=abs(acc);
        uLynx(handles.s,handles.t,['DECL=',num2str(handles.DECL)],1,handles.print_on,handles)
    end
    hTxt = findobj(gcf,'Tag','accelerationslider');
    set(hTxt,'Value',acc);
    guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function accelerationoutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accelerationoutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in maxaccl.
function maxaccl_Callback(hObject, eventdata, handles)
% Maximum acceleration and deceleration values chosen
% Closest pump has to a "jump" between rates
% hObject    handle to maxaccl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of maxaccl

p = get(hObject,'Value');
if p
        uLynx(handles.s,handles.t,['ACCL=1000'],1,handles.print_on,handles)
        uLynx(handles.s,handles.t,['DECL=1000'],1,handles.print_on,handles)
        set(handles.accelerationslider,'Value',0,'Enable','Off');
        set(handles.accelerationoutput,'Value',0,'Enable','Off');
        set(handles.maxaccl,'String','Choose Acceleration');
else
        uLynx(handles.s,handles.t,['ACCL=',num2str(handles.ACCL)],1,handles.print_on,handles)
        uLynx(handles.s,handles.t,['DECL=',num2str(handles.DECL)],1,handles.print_on,handles)
        set(handles.accelerationslider,'Value',1,'Enable','On');
        set(handles.accelerationoutput,'Value',1,'Enable','On');
        set(handles.maxaccl,'String','Max Acceleration');
end


%% PANEL 3: Control by Volume Dispension 

function volrateedit_Callback(hObject, eventdata, handles)
% User inputs rate at which volume will be dispensed
% hObject    handle to volrateedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of volrateedit as text
%        str2double(get(hObject,'String')) returns contents of volrateedit as a double

   volRate=get(hObject,'String');
   handles.volRate = num2str(mL2uL(str2num(volRate)));
    guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function volrateedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volrateedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function volamtedit_Callback(hObject, eventdata, handles)
% User inputs volume of fluid to be dispensed
% hObject    handle to volamtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   MOVR=get(hObject,'String');
   handles.MOVR = num2str(str2num(MOVR)*10^3); %Converts mL to uL
    guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of volamtedit as text
%        str2double(get(hObject,'String')) returns contents of volamtedit as a double


% --- Executes during object creation, after setting all properties.
function volamtedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volamtedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in voldispense.
function voldispense_Callback(hObject, eventdata, handles)
% Executes volume dispense commands
% hObject    handle to voldispense (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% uLynx(handles.s,handles.t,'CP=1',1,handles.print_on,handles);
    uLynx(handles.s,handles.t,'pgm 1',1,handles.print_on,handles);
    uLynx(handles.s,handles.t,['lbl dispense'],1,handles.print_on,handles);
    uLynx(handles.s,handles.t,['ACCL=1000'],1,handles.print_on,handles);
    uLynx(handles.s,handles.t,['DECL=1000'],1,handles.print_on,handles);
    uLynx(handles.s,handles.t,['VM=',num2str(handles.volRate)],1,handles.print_on,handles)
    uLynx(handles.s,handles.t,['MOVR ',num2str(handles.MOVR)],1,handles.print_on,handles)
    uLynx(handles.s,handles.t,'HOLD 2',0,handles.print_on,handles);
    uLynx(handles.s,handles.t,'sstp',1,handles.print_on,handles)
    uLynx(handles.s,handles.t,['ACCL=',num2str(handles.ACCL)],1,handles.print_on,handles)
    uLynx(handles.s,handles.t,['DECL=',num2str(handles.DECL)],1,handles.print_on,handles)
    uLynx(handles.s,handles.t,'end',0,handles.print_on,handles);
    uLynx(handles.s,handles.t,'pgm',0,handles.print_on,handles);

uLynx(handles.s,handles.t,'dispense',1,handles.print_on,handles);


%% PANEL 4: Generate Program from Rate/Time Data 

% --- Executes on button press in cmd_getDir.
function cmd_getDir_Callback(hObject, eventdata, handles)
% User chooses file from which to upload rate/time data
% hObject    handle to cmd_getDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uigetfile('*.mat');
if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
    else
       disp(['User selected ', fullfile(pathname, filename)])
end
    set(handles.filedir,'String',filename);
    load(filename,'time','rate');
    handles.filename = strrep(filename,'.mat','');
    handles.time=time.*60;      %Converts time to s
    handles.rate=mL2uL(rate);   %Converts rate to uL/s
handles.h1 = plot(handles.proginput,time,rate);%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
hold on;
hold off;
guidata(hObject,handles);

% --- Executes on button press in makeprog.
function makeprog_Callback(hObject, eventdata, handles)
% Creates uLynx program from user-selected data and downloads to pump
% hObject    handle to makeprog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice = get(handles.final_rate_choice,'Value');
if choice == 1
    finalRate = handles.rate(end);
else
    finalRate = handles.backgroundRate;
end
h = waitbar(1/length(handles.time),'Program Loading...');
% uLynx(handles.s,handles.t,'CP=1',0,handles.print_on,handles);
uLynx(handles.s,handles.t,'pgm 1',0,handles.print_on,handles);
uLynx(handles.s,handles.t,['lbl ',handles.progname],0,handles.print_on,handles);
h = PGMuLynx(handles.s,handles.t,handles.rate,handles.time,handles.backgroundRate,finalRate,handles.print_on,h,handles);
uLynx(handles.s,handles.t,'end',0,handles.print_on,handles);
uLynx(handles.s,handles.t,'pgm',0,handles.print_on,handles);
waitbar(1,h,'Program has been downloaded to uLynx.');
pause(0.75);
delete(h);

% --- Executes on button press in runprog.
function runprog_Callback(hObject, eventdata, handles)
% Runs user-generated program
% hObject    handle to runprog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uLynx(handles.s,handles.t,handles.progname,1,handles.print_on,handles);

%Begin Marika's code (altered by Michelle Maiden for robustness)
n  = 100;
t  = linspace(handles.time(1)/60, handles.time(end)/60, n); % need more space in between points to counteract
                                                              % resolution of pause function, time needed
                                                              % for plotting
dt = t(2) - t(1);
while dt < 1/60 % Prevents line movement from being too fast
    n = floor(n/2);
    if n > 2
        t = linspace(handles.time(1)/60, handles.time(end)/60, n);
        dt = t(2) - t(1);
    else
        t = linspace(handles.time(1)/60, handles.time(end)/60, 2);    
        break;
    end
end

while dt > 5/60 % Prevents line movement from being too slow
    n = n*2;
    t = linspace(handles.time(1)/60, handles.time(end)/60, n);
    dt = t(2) - t(1);
end
dt = dt*60*0.97; % Converts from min to s; Corrects for plotting time
%dt = dt*60; % converts from min to s
for ind = 1:length(t)-1
    v = t(ind)*ones(100);
    ybounds = get(handles.proginput,'YLim');
    w = linspace(ybounds(1),ybounds(2));
    hold off
    plot(handles.proginput,handles.time/60,uL2mL(handles.rate),'-',v,w)
    pause(dt);
end
plot(handles.proginput,handles.time/60,uL2mL(handles.rate))
% set(handles.proginput,'userData',plot(handles.time*60,uL2mL(handles.rate)));
% End Marika's code
    
guidata(hObject,handles);

% --- Executes on selection change in final_rate_choice.
function final_rate_choice_Callback(hObject, eventdata, handles)
% hObject    handle to final_rate_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns final_rate_choice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from final_rate_choice


% --- Executes during object creation, after setting all properties.
function final_rate_choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to final_rate_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%% BEGIN PANEL 5: Results from Rate/Time Data 
% --- Executes on button press in demo_soli_small.

function demo_soli_small_Callback(hObject, eventdata, handles)
% hObject    handle to demo_soli_small (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[time, rate] = boundaryDataSoliton(handles.f.mui,handles.f.mue,...
                          handles.f.rhoi,handles.f.rhoe,handles.f.Q0,'small',handles.f.pumptype);
handles.progname = 'demo';
    handles.time=time.*60;      %Converts time to s
    handles.rate = rate;
        n = length(handles.rate);
        ncut = floor(1*n);
        handles.rate = [handles.rate(1:ncut) handles.f.Q0*ones(1,n-ncut)];
    handles.rate=mL2uL(handles.rate);   %Converts rate to uL/s
    guidata(hObject,handles);
plot(handles.proginput,handles.time/60,uL2mL(handles.rate));%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
handles.ax=axis;
ConnectPump_LF('makeprog_Callback',hObject,eventdata,handles);
ConnectPump_LF('runprog_Callback',hObject,eventdata,handles);


% --- Executes on button press in demo_soli_large.
function demo_soli_large_Callback(hObject, eventdata, handles)
% hObject    handle to demo_soli_large (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[time, rate] = boundaryDataSoliton(handles.f.mui,handles.f.mue,...
                          handles.f.rhoi,handles.f.rhoe,handles.f.Q0,'large');
handles.progname = 'demo';
    handles.time=time.*60;      %Converts time to s
    handles.rate = rate;
        n = length(handles.rate);
        ncut = floor(1*n);
        handles.rate = [handles.rate(1:ncut) handles.f.Q0*ones(1,n-ncut)];
    handles.rate=mL2uL(handles.rate);   %Converts rate to uL/s
    guidata(hObject,handles);
plot(handles.proginput,handles.time/60,uL2mL(handles.rate));%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
handles.ax=axis;
ConnectPump_LF('makeprog_Callback',hObject,eventdata,handles);
ConnectPump_LF('runprog_Callback',hObject,eventdata,handles);

% --- Executes on button press in demo_twoSoliSim.
function demo_twoSoliSim_Callback(hObject, eventdata, handles)
% hObject    handle to demo_twoSoliSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[time, rate] = boundaryDataSolitonSoliton_same(handles.f.mui,handles.f.mue,...
                          handles.f.rhoi,handles.f.rhoe,handles.f.Q0);
handles.filename = 'demo_2soli_sim.mat'; 
handles.progname = 'demo';
    load(handles.filename,'time','rate');
    handles.time=time.*60;      %Converts time to s
    handles.rate=mL2uL(rate);   %Converts rate to uL/s
    guidata(hObject,handles);
plot(handles.proginput,handles.time/60,uL2mL(handles.rate));%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
handles.ax=axis;
ConnectPump_LF('makeprog_Callback',hObject,eventdata,handles);
ConnectPump_LF('runprog_Callback',hObject,eventdata,handles);

% --- Executes on button press in demo_2soli_diff.
function demo_2soli_diff_Callback(hObject, eventdata, handles)
% hObject    handle to demo_2soli_diff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
boundaryDataSolitonSoliton;
handles.filename = 'demo_2soli.mat'; 
handles.progname = 'demo';
    load(handles.filename,'time','rate');
    handles.time=time.*60;      %Converts time to s
    handles.rate=mL2uL(rate);   %Converts rate to uL/s
    guidata(hObject,handles);
plot(handles.proginput,handles.time/60,uL2mL(handles.rate));%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
handles.ax=axis;
ConnectPump_LF('makeprog_Callback',hObject,eventdata,handles);
ConnectPump_LF('runprog_Callback',hObject,eventdata,handles);

% --- Executes on button press in demo_1DSW.
function demo_1DSW_Callback(hObject, eventdata, handles)
% hObject    handle to demo_1DSW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[time, rate] = boundaryDataDSW(handles.f.mui,handles.f.mue,...
                          handles.f.rhoi,handles.f.rhoe,handles.f.Q0,'l');
handles.progname = 'demo';
    handles.time=time.*60;      %Converts time to s
    handles.rate=mL2uL(rate);   %Converts rate to uL/s
    guidata(hObject,handles);
plot(handles.proginput,handles.time/60,uL2mL(handles.rate));%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
handles.ax=axis;
ConnectPump_LF('makeprog_Callback',hObject,eventdata,handles);
ConnectPump_LF('runprog_Callback',hObject,eventdata,handles);

% --- Executes on button press in demo_backflow.
function demo_backflow_Callback(hObject, eventdata, handles)
% hObject    handle to demo_backflow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[time, rate] = boundaryDataDSW_backflow(handles.f.mui,handles.f.mue,...
                          handles.f.rhoi,handles.f.rhoe,handles.f.Q0);
handles.progname = 'demo';
    handles.time=time.*60;      %Converts time to s
    handles.rate=mL2uL(rate);   %Converts rate to uL/s
    guidata(hObject,handles);
plot(handles.proginput,handles.time/60,uL2mL(handles.rate));%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
handles.ax=axis;
ConnectPump_LF('makeprog_Callback',hObject,eventdata,handles);
ConnectPump_LF('runprog_Callback',hObject,eventdata,handles);

% --- Executes on button press in demo_soli_then_DSW.
function demo_soli_then_DSW_Callback(hObject, eventdata, handles)
% hObject    handle to demo_soli_then_DSW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[time, rate] = boundaryDataSolitonThenDSW(handles.f.mui,handles.f.mue,...
                          handles.f.rhoi,handles.f.rhoe,handles.f.Q0);
handles.progname = 'demo';
    handles.time=time.*60;      %Converts time to s
    handles.rate=mL2uL(rate);   %Converts rate to uL/s
    guidata(hObject,handles);
plot(handles.proginput,handles.time/60,uL2mL(handles.rate));%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
handles.ax=axis;
ConnectPump_LF('makeprog_Callback',hObject,eventdata,handles);
ConnectPump_LF('runprog_Callback',hObject,eventdata,handles);

% --- Executes on button press in demo_dsw_then_soli.
function demo_dsw_then_soli_Callback(hObject, eventdata, handles)
% hObject    handle to demo_dsw_then_soli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[time, rate] = boundaryDataDSWThenSoliton(handles.f.mui,handles.f.mue,...
                          handles.f.rhoi,handles.f.rhoe,handles.f.Q0);
handles.progname = 'demo';
    handles.time=time.*60;      %Converts time to s
    handles.rate=mL2uL(rate);   %Converts rate to uL/s
    guidata(hObject,handles);
plot(handles.proginput,handles.time/60,uL2mL(handles.rate));%uL2mL(handles.time),uL2mL(handles.rate),'-*');
xlabel(handles.proginput,'Time (min)');
ylabel(handles.proginput,'Rate (mL/min)');
handles.ax=axis;
ConnectPump_LF('makeprog_Callback',hObject,eventdata,handles);
ConnectPump_LF('runprog_Callback',hObject,eventdata,handles);



%% END PANEL 5 


%%% PGM Function
function[h] = PGMuLynx(serialport,outputfile,rate,time,backgroundRate,finalRate,print_on,h,handles)
%Generates program from rate-time data
waitbar(1/length(time),h,'Program Loading...');
formSpec1='slew %f';
% formSpec2='delay %5f\r\n';
formSpec3='accl=%f';
formSpec4='decl=%f';
% rate = (1.1514*1000/60).*rate - (0.0407*1000/60);
initrate=rate(1:end-1);
endrate =rate(2:end);

dtime=time(2:end)-time(1:end-1);
accl=(endrate-initrate)./dtime;

% accl_0= rate(1)./dtime(1);
uLynx(serialport,outputfile,sprintf(formSpec3,1000),0,print_on,handles);
steps = length(accl);
for jj=1:steps-1
    if accl(jj)~=0
    if abs(initrate(jj)) < abs(endrate(jj))
        uLynx(serialport,outputfile,sprintf(formSpec3,abs(accl(jj))),0,print_on,handles);
    else
        uLynx(serialport,outputfile,sprintf(formSpec4,abs(accl(jj))),0,print_on,handles);
    end
    uLynx(serialport,outputfile,sprintf(formSpec1,endrate(jj)),0,print_on,handles);
    uLynx(serialport,outputfile,'HOLD 1',0,print_on,handles);
    else
        uLynx(serialport,outputfile,sprintf(formSpec1,initrate(jj)),0,print_on,handles);
        uLynx(serialport,outputfile,'HOLD 1',0,print_on,handles);
        uLynx(serialport,outputfile,['DELAY ',num2str(dtime(jj)*1000)],0,print_on,handles);
    end
    waitbar(jj/steps,h)
end
     if accl(end)~=0
    if abs(initrate(end)) < abs(endrate(end))
        uLynx(serialport,outputfile,sprintf(formSpec3,abs(accl(end))),0,print_on,handles);
    else
        uLynx(serialport,outputfile,sprintf(formSpec4,abs(accl(end))),0,print_on,handles);
    end
    uLynx(serialport,outputfile,sprintf(formSpec1,endrate(end)),0,print_on,handles);
    uLynx(serialport,outputfile,'HOLD 1',0,print_on,handles);
    else
        uLynx(serialport,outputfile,sprintf(formSpec1,initrate(end)),0,print_on,handles);
        uLynx(serialport,outputfile,'HOLD 1',0,print_on,handles);
        uLynx(serialport,outputfile,['DELAY ',num2str(dtime(end)*1000)],0,print_on,handles);
    end
    uLynx(serialport,outputfile,sprintf(formSpec1,endrate(end)),0,print_on,handles);
    uLynx(serialport,outputfile,['slew ',num2str(finalRate)],0,print_on,handles);
    waitbar(steps/(steps+1),h,sprintf('Finalizing Program...'));


%% SEND TO PUMP FUNCTION
function[] = uLynx(serialport,outputfile,command,disp_on,print_on,handles)
% This program generates a uLynx command, sends it to a pump, then
% prints command in an output file
% Inputs: serialport: uLynx serialport
%         outputfile: file command is written to
%         command: text sent to pump
%         disp_on: 1 shows command in MATLAB command prompt
%         print_on: if serialport is a .txt file instead of a COM port, sends command to said file
    fid=fopen(outputfile,'a');
    q = fprintf(fid,[command,'\n']);
%    old = cellstr(get(handles.command_history,'String')); % Retrieves current listbox contents
%    bottom = size(old,1)+1; % Finds the bottom of the list
%    set(handles.command_history,'String',{old{:},command}); % Adds the new item to the list 
%    set(handles.command_history,'Value', bottom); % Scrolls down to most recent item
    fclose(fid);
if print_on==0
    q=query(serialport,command,'%s\r\n');
    pause(0.05);
end
   if disp_on
    disp(command);
    disp(q);
   end

%% CONVERSION FUNCTIONS
    function[uL] = mL2uL(mL)
    %Changes mL/min to uL/s
    %necessary for pump
    uL = mL./60.*1000;

    function[mL] = uL2mL(uL)
    %Changes uL/s to mL/min
    %Keeps GUI consistent
    mL = uL.*60./1000;
    %% 


% --- Executes on selection change in command_history.
function command_history_Callback(hObject, eventdata, handles)
% hObject    handle to command_history (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns command_history contents as cell array
%        contents{get(hObject,'Value')} returns selected item from command_history
handles.command_history = cellstr(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function command_history_CreateFcn(hObject, eventdata, handles)
% hObject    handle to command_history (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
