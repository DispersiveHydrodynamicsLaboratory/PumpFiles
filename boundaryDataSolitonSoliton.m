%add two solitons together
Q0 = handles.f.Q0;
load('demo_soli_small.mat')
small_t = time;
    n = length(rate);
    ncut = floor(1*n);
    rate = [rate(1:ncut) Q0*ones(1,n-ncut)];
small_r = rate;
load('demo_soli_large.mat')
large_t = time;
     n = length(rate);
     ncut = floor(1*n);
    rate = [rate(1:ncut) Q0*ones(1,n-ncut)];
large_r = rate;
time;
dt = 0.05; % minutes 0.16 for big conduit, 0.05 for small
time = [small_t, small_t(end)+dt, large_t+(small_t(end)+2*dt)];
rate = [small_r, Q0, Q0, large_r(2:end)];
figure; plot(time,rate)
save('demo_2soli.mat','time','rate');