% This script generates an array of boundary data for use with mGat
% pump
function[time, rate] = boundaryDataDSW(mui,mue,rhoi,rhoe,Q0,hl)
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

hl = 'l';

if strcmp(hl,'l')
    pumpFactor = 1/1.008; % nondimensional factor, Qactual*pumpFactor=Qpump 
elseif strcmp(hl,'h')
    pumpFactor = 1/0.9558;
end

Q0 = Q0/pumpFactor; % Base pump rate (ml/min)
alpha = alpha_thy;%2*sqrt(A0/pi)/Q0^0.25;
alphaMeasured = alpha_thy;
A0 = pi*(0.5*(alpha*Q0^0.25))^2; % Base conduit area (cm^2)
epsilon = mui/mue;               % mui/mue;
L0 = sqrt(A0/(8*pi*epsilon));    % Vertical length scale (cm)
U0 = Q0/(60*A0); % (cm/s)
T0 = L0/U0;

% Now generate DSW
% Ramp to discontinuity at z = z0
z2 = 20/L0;
A1 = 2.5;  % Backflow:  > 8/3, implosion:  > 32/5
fun = @(s) z2./(z2-2*s); % BC at z = 0 (nozzle)
tmin = 0;
tmax = z2*(A1-1)/(2*A1);

disp('DSW:');
disp(['z2 = ',num2str(z2)]);
disp(['A2 = ',num2str(A1)]);
disp(['Breaking should occur at t = ',num2str(T0*z2/2),...
    ' s = ',num2str(T0*z2/120),' min']);

% Minimum delta t is 0.l s
dt = 0.3/T0;
t = [tmin:dt:tmax];

% Compute Q and adjust for values too small
A = fun(t);% - 1; % Subtract off background assumed to be provided by pump #2
D = 2*sqrt(A*A0/pi); % Dimensional conduit diameter
Q = (D/alpha).^4; % Dimensional flux (ml/min)
Qnew = Q(1);
ctr = 1;
tnew = t(1);
for ii=1:length(Q)
    if abs(Q(ii)-Qnew(ctr)) >= 0.02
        ctr = ctr + 1;
        Qnew(ctr) = Q(ii);
        tnew(ctr) = t(ii);
    end
end

% Compensate for pump calibration
Q = Q*pumpFactor;

disp(['tmin = ',num2str(tmin*T0),' min']);
disp(['tmax = ',num2str(tmax*T0*60),' s = ',num2str(tmax*T0),' min']);
disp(['dt = ',num2str(dt*T0*60),' s']);
disp(['Q final = ',num2str(Q(end)),' mL/min']);

if strcmp(hl,'h')
	if max(Q)>=30
        disp('Warning! Exceeds pump capacity.');
        Q(Q>=30) = 30;
    end
else
    if max(Q)>=10
        disp('Warning! Exceeds pump capacity.');
        Q(Q>=10)=10;
    end
end
% Plot Q and A
figure(1)
clf()
subplot(2,1,1);
plot(t,A);
xlabel('t');
ylabel('A');
title(['length(t) = ',num2str(length(t))]);

subplot(2,1,2);
plot(t*T0/60,Q,'b-');
xlabel('t (min)');
ylabel('Q (ml/min)');

% Save data
time = tnew*T0/60;
rate = Qnew;
save('demo_1DSW.mat','rate','time');