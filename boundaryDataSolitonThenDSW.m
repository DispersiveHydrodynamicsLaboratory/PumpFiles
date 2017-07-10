% This script generates an array of boundary data for use with mGAT Pump
function[time, rate] = boundaryDataSolitonThenDSW(mui,mue,rhoi,rhoe,Q0,hl)
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

% Generate first soliton
A1 = 4;
c1 = (2*A1^2*log(A1)-A1^2+1)/(A1^2-2*A1+1);
z1 = -10;
fun = @(s) z1./(z1-2*s); % BC at z = 0 (nozzle)
tmin = 0;
tmax = -2*z1/c1;
dt = 0.2/T0;
t1 = [tmin:dt:tmax];

disp(['First soliton speed = ',num2str(c1*U0),' cm/s']);


% Minimum delta t is 0.l s

% Compute Q and adjust for values too small
xi1 = -c1*t1-z1;
% Compute from zero forward and use even reflection
[foo,ind] = min(abs(xi1));
if xi1(ind) < 0
    ind = ind - 1;
end
Asol1 = zeros(size(t1));
Asol1(1:ind) = fliplr(get_soli(xi1(ind:-1:1),A1,2,1e-4));
Asol1(ind+1:end) = get_soli(-xi1(ind+1:end),A1,2,1e-4);
D = 2*sqrt(Asol1*A0/pi); % Dimensional conduit diameter
Q1 = (D/alpha).^4; % Dimensional flux (ml/min)
Qnew1 = 0;%Q(1);
ctr = 1;
tnew1 = t1(1);
for ii=1:length(Q1)
    if abs(Q1(ii)-Qnew1(ctr)) >= 0.003
        ctr = ctr + 1;
        Qnew1(ctr) = Q1(ii);
        tnew1(ctr) = t1(ii);
    end
end

% Save data
data1 = zeros(length(Qnew1)*2-1,1);
data1(1:2:end) = Qnew1;
data1(2:2:end) = Qnew1(2:end);
    n = length(data1);
    ncut = floor(1*n);
    data1 = [data1(1:ncut) Q0*ones(1,n-ncut)];

dtnew1 = tnew1(2:end) - tnew1(1:end-1);
mins1 = floor(dtnew1*T0/60);
secs1 = floor(dtnew1*T0-60*mins1);
tenths1 = floor(10*(dtnew1*T0-secs1-60*mins1));
hrssecs1 = zeros(length(data1),1);
minstenths1 = zeros(length(data1),1);
hrssecs1(2:2:end) = secs1;
minstenths1(1:2:end-1) = mins1;
minstenths1(2:2:end) = tenths1;
% Remove last entry because we are not holding constant the rate now
data1 = data1(1:end-1);
hrssecs1 = hrssecs1(1:end-1);
minstenths1 = minstenths1(1:end-1);

% Now generate DSW
% Ramp to discontinuity at z = z0
z2 = 15/L0;
A2 = 4;  % Backflow:  > 8/3, implosion:  > 32/5
fun = @(s) z2./(z2-2*s); % BC at z = 0 (nozzle)
tmin = 0;
tmax = z2*(A2-1)/(2*A2);

disp('DSW:');
disp(['z2 = ',num2str(z2)]);
disp(['A2 = ',num2str(A2)]);
disp(['Breaking should occur at t = ',num2str(T0*z2/2),...
    ' s = ',num2str(T0*z2/120),' min']);

% Minimum delta t is 0.l s
dt = 0.3/T0;
t2 = [tmin:dt:tmax];

% Compute Q and adjust for values too small
Adsw = fun(t2);% - 1; % Subtract off background assumed to be provided by pump #2
D = 2*sqrt(Adsw*A0/pi); % Dimensional conduit diameter
Q2 = (D/alpha).^4; % Dimensional flux (ml/min)
Qnew2 = Q2(1);
ctr = 1;
tnew2 = t2(1);
for ii=1:length(Q2)
    if abs(Q2(ii)-Qnew2(ctr)) >= 0.02
        ctr = ctr + 1;
        Qnew2(ctr) = Q2(ii);
        tnew2(ctr) = t2(ii);
    end
end

% Plot data
Q = [Q1,Q2];
A = [Asol1,Adsw];
t = [t1,t2+t1(end)];
tnew = [tnew1,tnew2(2:end)+tnew1(end)];
Qnew = [Qnew1,Qnew2(2:end)];

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

time = tnew*T0/60;
rate = Qnew;
save('demo_soli_then_DSW.mat','rate','time');

disp(['Number of phases = ',int2str(length(time))]);

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
