

Ao = 6; %Jump Height (nd)
Zb = 10; %break height (cm)
Qo = 0.25; %background flow rate (mL/min)


mui = vis_calib(60); %interior viscosity (cP)
mui = mui*60/100; % cP -> g/(cm*min)
mue = vis_calib(3000); %exterior viscosity (cP)
mue = mue*60/100; % cP -> g/(cm*min)
rhoi = 1.2; %interior density (g/cm^3)
rhoe = 1.4; %exterior density (g/cm^3)
g = 9.796; % m/s^2 in Denver
g = g*3600*100; % cm/min^2

delta = rhoe-rhoi;
alpha = (2^7*mui/pi/g/delta)^(1/4); %(cm*min)^(1/4)
Ro = alpha/2*Qo^(1/4); %cm
L = Ro/sqrt(8); %cm
T = sqrt(8)*mui/(g*Ro^2*delta); %min
U = L/T; %cm/min
gamma = U/Zb;


time = 0:3/60:5; %min

ratefun = @(t) Qo*(1.*(t<=0) +...
               1./(1-2*gamma.*t).^2.*(t>0 & gamma.*t<(Ao-1)/(2*Ao))+...
               Ao^2.*(gamma.*t>=(Ao-1)/(2*Ao)));
rate = ratefun(time);

if rate>=10
    disp('Warning! Pump rate exceeds capacity')
    rate(rate>=10) = 10;
end

figure(1); clf;
plot(time,rate)
xlabel('time (min)'); ylabel('rate (mL/min)');

save('boundaryData.mat','rate','time');


