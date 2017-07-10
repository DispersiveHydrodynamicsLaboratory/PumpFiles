% This script generates an array of boundary data for use with mGAT pump
function[time, rate] = boundaryDataDSWThenSoliton(mui,mue,rhoi,rhoe,Q0,hl)
load('fluid_properties.mat');
% Q0 = dsw_Q0;
mui = 80; mue = 2000;

maxphases = 339;% max is 340;
% Scale viscosities according to viscometer calibration
mu_calibration_measured = [79.8,103.5,5556,10581]; % in cP
mu_calibration_actual = [82.53,109.2,5479,10902]; % in cP
mui = vis_calib(mui)/100; % P = g/(cm*s)
mue = vis_calib(mue)/100; % P = g/(cm*s)
mui = mui*60; % g/(cm*min)
mue = mue*60; % g/(cm*min)
g = 9.796; % m/s^2 in Denver
g = g*3600*100; % cm/min^2
alpha_thy = (2^7*mui/(pi*g*(rhoe-rhoi)))^0.25; % (cm*min)^(1/4), (D = alpha Q^1/4
pumpFactor = 1/1.008; % nondimensional factor, Qactual*pumpFactor=Qpump 
Q0 = Q0/pumpFactor; % Base pump rate (ml/min)
alpha = alpha_thy;%2*sqrt(A0/pi)/Q0^0.25;
alphaMeasured = alpha_thy;
A0 = pi*(0.5*(alpha*Q0^0.25))^2; % Base conduit area (cm^2)
epsilon = mui/mue;               % mui/mue;
L0 = sqrt(A0/(8*pi*epsilon));    % Vertical length scale (cm)
U0 = Q0/(60*A0); % (cm/s)
T0 = L0/U0;

% Function definition
% DSW
A1 = 2.4; % Jump from 1 to A1
z0 = 30/L0; % Distance from nozzle to break
funDSW = @(s) z0./(z0-2*s); % DSW BC at z = 0 (nozzle), ramps from 1 to A1
tmin = 0;
tDSW = z0*(A1-1)/(2*A1);
dt = 0.2/T0; % Min dt is 0.1 s
t1 = [tmin:dt:tDSW];

% Soliton on background A1
z1 = -15/L0;  % Distance over which to generate soliton
A2 = 6; % Total soliton height
csoliton = A1*(2*(A2/A1)^2*log(A2/A1)-(A2/A1)^2+1)/ ...
    ((A2/A1)^2-2*(A2/A1)+1);
zsoliton = 40/L0; % Distance separating DSW ramp end and initiation of soliton (cm)
tsoliton = tDSW + zsoliton/csoliton;
t2 = [tDSW+dt,tsoliton-dt];
tmax = tsoliton-2*z1/csoliton;
t3 = [tsoliton:dt:tmax];
disp(['Soliton speed = ',num2str(csoliton*U0),' cm/s']);

% Get DSW ramp and constant
A = zeros(1,length(t1)+length(t2)+length(t3));
A(1:length(t1)) = funDSW(t1);
A(length(t1)+1:length(t1)+length(t2)) = A1*ones(1,length(t2));

% Get Soliton
xi = (-csoliton*(t3-tsoliton)-z1)/sqrt(A1);
% Compute from zero forward and use even reflection
[foo,ind] = min(abs(xi));
if xi(ind) < 0
    ind = ind - 1;
end
A(length(t1)+length(t2)+1:length(t1)+length(t2)+ind) = ...
    A1*fliplr(get_soli(xi(ind:-1:1),A2/A1,2,1e-4));
A(length(t1)+length(t2)+ind+1:end) = ...
    A1*get_soli(-xi(ind+1:end),A2/A1,2,1e-4);

% A = A-1;

% Get flux
D = 2*sqrt(A*A0/pi); % Dimensional conduit diameter
Q = (D/alphaMeasured).^4; % Dimensional flux (ml/min)
Qnew = 0;%Q(1);
ctr = 1;
t = [t1,t2,t3];
tnew = t(1);
for ii=1:length(Q)
    if abs(Q(ii)-Qnew(ctr)) >= 0.05
        ctr = ctr + 1;
        Qnew(ctr) = Q(ii);
        tnew(ctr) = t(ii);
    end
end



% if (tmax-tmin)/dt > maxphases/2
%     dt = (tmax-tmin)/(maxphases/2-1);
%     % Round up to the nearest tenth of second
%     dt = ceil(dt*T0*10)/(T0*10);
% end
% disp(['dt = ',num2str(dt*T0),' s']);
disp(['tmin = ',num2str(tmin*T0),' s']);
disp(['tmax = ',num2str(tmax*T0),' s = ',num2str(tmax*T0/60),' min']);

% Plot Q and A
figure(1)
clf()
subplot(2,1,1);
plot(t,A);
xlabel('t');
ylabel('A');

if strcmp(hl,'h')
	if max(Qnew)>=30
        disp('Warning! Exceeds pump capacity.');
        Qnew(Qnew>=30) = 30;
    end
else
    if max(Qnew)>=10
        disp('Warning! Exceeds pump capacity.');
        Qnew(Qnew>=10)=10;
    end
end

subplot(2,1,2);
plot(t*T0/60,Q,'r--',...
     tnew*T0/60,Qnew,'b-');
xlabel('t (min)');
ylabel('Q (ml/min)');

% Save data
time = tnew*T0/60;
rate = Qnew;
save('demo_DSW_then_soli.mat','rate','time');

disp(['Number of phases = ',int2str(length(time))]);
