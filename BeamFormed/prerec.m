function [ output_args ] = prerec( fname128, fname256, fname512, fname1024, fnamecomb )
%PLOTRES Summary of this function goes here
%   Detailed explanation goes here
   
f128 = load(fname128);
f256 = load(fname256);
f512 = load(fname512);
f1024 = load(fname1024);
comb = load(fnamecomb);


figure
subplot(2,1,1)
set(0, 'DefaultAxesFontSize', 24)
plot(f128(:,1), f128(:,3), 'ko-', 'LineWidth', 2)
hold on
plot(f256(:,1), f256(:,3), 'gs-', 'LineWidth', 2)
hold on
plot(f512(:,1), f512(:,3), 'bs-', 'LineWidth', 2)
hold on
plot(f1024(:,1), f1024(:,3), 'ms-', 'LineWidth', 2)
hold on
plot(comb(:,1), comb(:,3), 'r-', 'LineWidth', 2)
set(gca,'Xtick',0.4:0.05:1)
grid on
legend('Beam128', 'Beam256', 'Beam512', 'Beam1024', 'Combined', 'Location', 'southeast')
xlabel('Sensitivity')
ylabel('Recall')
%set(gcf,'units','points','position',[10,10,850,600])

subplot(2,1,2)
set(0, 'DefaultAxesFontSize', 24)
plot(f128(:,1), f128(:,4), 'ko-', 'LineWidth', 2)
hold on
plot(f256(:,1), f256(:,4), 'gs-', 'LineWidth', 2)
hold on
plot(f512(:,1), f512(:,4), 'bs-', 'LineWidth', 2)
hold on
plot(f1024(:,1), f1024(:,4), 'ms-', 'LineWidth', 2)
hold on
plot(comb(:,1), comb(:,4), 'r-', 'LineWidth', 2)
set(gca,'Xtick',0.4:0.05:1)
grid on
legend('Beam128', 'Beam256', 'Beam512', 'Beam1024', 'Combined', 'Location', 'southeast')
xlabel('Sensitivity')
ylabel('F-Score')
set(gcf,'units','points','position',[10,10,1000,1200])


