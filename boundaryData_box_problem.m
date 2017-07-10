A1 = 3;    %Jump Height (nd)
zb = 20;   %break height (cm)
Q0 = 0.25; %background flow rate (mL/min)

% load('/Volumes/Data Storage/Experiments/Photos/2016_07_26/fluid_prop.mat');

mue = 1152;
mui = 92.2;
rhoe = 1.261;
rhoi = 1.21;
mui = vis_calib(mui); %interior viscosity (cP)
mui = mui*60/100; % cP -> g/(cm*min)
mue = vis_calib(mue); %exterior viscosity (cP)
mue = mue*60/100; % cP -> g/(cm*min)
rhoi = mean(rhoi); %interior density (g/cm^3)
rhoe = mean(rhoe); %exterior density (g/cm^3)
g = 9.796; % m/s^2 in Denver
g = g*3600*100; % cm/min^2

delta = rhoe-rhoi;
eps   = mui/mue;
alpha = (2^7*mui/pi/g/delta)^(1/4); %(cm*min)^(1/4)

R0 = alpha/2*Q0^(1/4); %cm
U = (g*R0^2*delta)/(8*mui); %cm/min
gamma = U/zb;

%% Cut ramp at predicted breaking time
Ufac = (g*delta*Q0/8/pi/mui).^(1/2); % cm/min
ramp_max = (A1-1)/(2*A1)/gamma;
tb   = zb./(2.*Ufac);

%% Define time function to be size of box + one second
time = 0:1/60:tb+1/60;
if length(time)>300
    time = [0:1/60:ramp_max ramp_max+1/60:1/2:tb+1/60]; %min
end
if time(end)~=tb+1/60
    time = [time tb+1/60];
end
 
%% Box Function
ratefun = @(t) Q0*(1                   .*(t<=0) +...
                   1./(1-2*gamma.*t).^2.*(t>0 & gamma.*t<=(A1-1)/(2*A1))+...
                   (A1)^2              .*(gamma.*t>(A1-1)/(2*A1) & t<=tb)+...
                   1                   .*(t>tb));
rate = ratefun(time);
 
if rate>=30
    disp('Warning! Pump rate exceeds capacity')
    rate(rate>=30) = 30;
end



%% Plot Ramp 
figure(1); clf;
plot(time,rate);
xlabel('time (min)'); ylabel('rate (mL/min)');


%% Save Rate-Time Profile & Display Relevant Parameters
currentDirectory = pwd;
[upperPath, deepestFolder, ~] = fileparts(currentDirectory);
disp(deepestFolder);
disp(['Q0:   ',num2str(Q0)]);
disp(['A1:   ',num2str(A1)]);
disp(['Qmax: ',num2str((A1)^2*Q0)]);
disp(['zb:   ',num2str(zb)]);
disp(['Box is finished in: ',num2str(floor(tb)),' min, ',...
                             num2str((tb-floor(tb))*60),' s.']);

Qf = (A1)^2*Q0;
save('boundaryData.mat','rate','time','Q0','A1','zb','tb');
