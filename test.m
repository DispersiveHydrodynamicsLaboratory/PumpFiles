% Test Script
% Literally just here to mess with code. That's it.

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
    
    set(handles.s,'BaudRate',9600);
    set(handles.s,'DataBits',8);
    set(handles.s,'StopBits',1);
    set(handles.s,'Parity','none');
    set(handles.s,'FlowControl','none');
    fopen(handles.s)
    disp('Its alive!!!')
    fclose(handles.s)
       