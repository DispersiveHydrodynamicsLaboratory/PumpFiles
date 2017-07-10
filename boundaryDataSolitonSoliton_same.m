%add two solitons together
function [time, rate] = boundaryDataSolitonSoliton_same(mui,mue,rhoi,rhoe,Q0,hl);
[time, rate] = boundaryDataSoliton(mui,mue,rhoi,rhoe,Q0,'close_small',hl);
small_t = time;
    n = length(rate);
    ncut = floor(1*n);
    rate = [rate(1:ncut) Q0*ones(1,n-ncut)];
small_r = rate;
load('demo_soli_small.mat')
large_t = time;
    n = length(rate);
    ncut = floor(1*n);
    rate = [rate(1:ncut) Q0*ones(1,n-ncut)];
large_r = rate;
dt = 0.02; % minutes
time = [small_t, small_t(end)+dt, large_t+(small_t(end)+2*dt)];
rate = [small_r, small_r(end), small_r(end), large_r(2:end)];
figure; plot(time,rate)
save('demo_2soli_sim.mat','time','rate');