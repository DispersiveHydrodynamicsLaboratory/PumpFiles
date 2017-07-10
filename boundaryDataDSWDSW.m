% This script generates an array of boundary data for use with mGAT pump
function[time, rate] = boundaryDataDSWDSW(mui,mue,rhoi,rhoe,Q0,hl)
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
% Ramp to discontinuity at z = z0
z0 = 60/L0;
ADSW1 = 2.25;  % Backflow:  > 8/3, implosion:  > 32/5
fun = @(s) z0./(z0-2*s); % BC at z = 0 (nozzle)
tmin = 0;
tmax = z0*(ADSW1-1)/(2*ADSW1);

disp(['z0 = ',num2str(z0)]);
disp(['A1 = ',num2str(ADSW1)]);
disp(['Breaking should occur at t = ',num2str(T0*z0/2),...
    ' s = ',num2str(T0*z0/120),' min']);

% Minimum delta t is 0.l s
dt = 0.3/T0;
t1 = [tmin:dt:tmax];

% Compute Q and adjust for values too small
A1 = fun(t1); % Subtract off background assumed to be provided by pump #2
D1 = 2*sqrt(A1*A0/pi); % Dimensional conduit diameter
Q1 = (D1/alpha).^4; % Dimensional flux (ml/min)

Qnew1 = Q1(1);
ctr = 1;
tnew1 = t1(1);
for ii=1:length(Q1)
    if abs(Q1(ii)-Qnew1(ctr)) >= 0.01
        ctr = ctr + 1;
        Qnew1(ctr) = Q1(ii);
        tnew1(ctr) = t1(ii);
    end
end

% Set delay between DSWs
t_delay = 60/T0;
t2 = linspace(tmax+dt,tmax+dt+t_delay,10);
A2 = A1(end)*ones(size(t2));
D2 = 2*sqrt(A2*A0/pi);
Q2 = (D2/alpha).^4;

Qnew2 = Q2;
tnew2 = t2;

% Second DSW
z0 = 30/L0;
ADSW2 = 4.5;  % Backflow:  > 8/3, implosion:  > 32/5
fun = @(s) z0./(z0/ADSW1-2*s); % BC at z = 0 (nozzle)
tmin = t2(end)+dt;
tmax = tmin+z0/2*(1/ADSW1-1/ADSW2);
t3 = [tmin:dt:tmax];
A3 = fun(t3-tmin);
D3 = 2*sqrt(A3*A0/pi);
Q3 = (D3/alpha).^4;

Qnew3 = Q3(1);
ctr = 1;
tnew3 = t3(1);
for ii=1:length(Q3)
    if abs(Q3(ii)-Qnew3(ctr)) >= 0.01
        ctr = ctr + 1;
        Qnew3(ctr) = Q3(ii);
        tnew3(ctr) = t3(ii);
    end
end

% Put em all together
Q = [Q1,Q2,Q3];
t = [t1,t2,t3];
A = [A1,A2,A3];
Qnew = [Qnew1,Qnew2,Qnew3];
tnew = [tnew1,tnew2,tnew3];

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

disp(['tmax = ',num2str(t(end)*T0),' s = ',num2str(t(end)*T0/60),' min']);

% Plot Q and A
figure(1)
clf()
subplot(2,1,1);
plot(t,A);
xlabel('t');
ylabel('A');

subplot(2,1,2);
plot(t*T0/60,Q,'r--',...
     tnew*T0/60,Qnew,'b-');
xlabel('t (min)');
ylabel('Q (ml/min)');

% Save data
data = zeros(length(Qnew)*2-1,1);
data(1:2:end) = Qnew;
data(2:2:end) = Qnew(2:end);

% Save data
time = tnew*T0/60;
rate = Qnew;
save('demo_2DSW.mat','rate','time');

disp(['Number of phases = ',int2str(length(data))]);
