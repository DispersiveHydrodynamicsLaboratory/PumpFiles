% This function generates a small soliton that can be sent to the uLynx
% Called in ConnectPump
function[time, rate] = boundaryDataSoliton(mui,mue,rhoi,rhoe,Q0,soli_type,hl)
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

hl = 'l';

% A1 = soli_type;
% Generate soliton
if strcmp(soli_type, 'small')
    A1 = 2;
    dt = 0.1/T0;
elseif strcmp(soli_type, 'large')
    A1 = 3;
    dt = 0.1/T0;
elseif strcmp(soli_type, 'close_small')
    A1 = 1.5;
    dt = 0.2/T0;
elseif strcmp(soli_type, 'smallest')
    A1 = 2.5;
    dt = 0.2/T0;
else % initialize to a pure soliton
    A1 = 3;
    dt = 0.2/T0;
end

z1 = -10;
c1 = (2*A1.^2.*log(A1)-A1^2+1)./(A1.^2-2.*A1+1);
fun = @(s) z1./(z1-2*s); % BC at z = 0 (nozzle)
tmin = 0;
tmax = -2*z1/c1;
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
data = zeros(length(Qnew1)*2-1,1);
data(1:2:end) = Qnew1;
data(2:2:end) = Qnew1(2:end);

dtnew1 = tnew1(2:end) - tnew1(1:end-1);
mins1 = floor(dtnew1*T0/60);
secs1 = floor(dtnew1*T0-60*mins1);
tenths1 = floor(10*(dtnew1*T0-secs1-60*mins1));
hrssecs1 = zeros(length(data),1);
minstenths1 = zeros(length(data),1);
hrssecs1(2:2:end) = secs1;
minstenths1(1:2:end-1) = mins1;
minstenths1(2:2:end) = tenths1;
% Remove last entry because we are not holding constant the rate now
data = data(1:end-1);
hrssecs1 = hrssecs1(1:end-1);
minstenths1 = minstenths1(1:end-1);

% Plot data
Q = Q1;
A = Asol1;
t = t1;
tnew = tnew1;
Qnew = Qnew1;

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
% Remove first entry because it is zero
time(1) = [];
rate(1) = [];

disp(['Number of phases = ',int2str(length(data))]);

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

if strcmp(soli_type, 'small')
    save('demo_soli_small.mat','rate','time');
elseif strcmp(soli_type, 'large')
    save('demo_soli_large.mat','rate','time');
elseif strcmp(soli_type, 'small_close')
    save('demo_soli_small_close.mat','rate','time');
elseif strcmp(soli_type, 'smallest')
    save('demo_soli_smallest.mat','rate','time');
end

