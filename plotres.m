function [ output_args ] = plotres( left_fname, right_fname, comb_fname, combs_fname )
%PLOTRES Summary of this function goes here
%   Detailed explanation goes here
   
left = load(left_fname);
right = load(right_fname);
comb = load(comb_fname);
combs = load(combs_fname);

figure
subplot(2,1,1)
set(0, 'DefaultAxesFontSize', 24)
plot(left(:,1), left(:,3), 'ko-', 'LineWidth', 2)
hold on
plot(right(:,1), right(:,3), 'gs-', 'LineWidth', 2)
hold on
plot(combs(:,1), combs(:,3), 'r-', 'LineWidth', 2)
set(gca,'Xtick',0.4:0.05:1)
grid on
legend('Left', 'Right', 'Beamformed', 'Location', 'southeast')
xlabel('Sensitivity')
ylabel('Recall')
%set(gcf,'units','points','position',[10,10,850,600])

subplot(2,1,2)
set(0, 'DefaultAxesFontSize', 24)
plot(left(:,1), left(:,4), 'ko-', 'LineWidth', 2)
hold on
plot(right(:,1), right(:,4), 'gs-', 'LineWidth', 2)
hold on
plot(combs(:,1), combs(:,4), 'r-', 'LineWidth', 2)
set(gca,'Xtick',0.4:0.05:1)
grid on
legend('Left', 'Right', 'Beamformed', 'Location', 'southeast')
xlabel('Sensitivity')
ylabel('F-Score')
set(gcf,'units','points','position',[10,10,1000,1200])

figure
subplot(2,1,1)
set(0, 'DefaultAxesFontSize', 24)
plot(left(:,1), left(:,3), 'ko-', 'LineWidth', 2)
hold on
plot(right(:,1), right(:,3), 'gs-', 'LineWidth', 2)
hold on
plot(comb(:,1), comb(:,3), 'b-', 'LineWidth', 2)
set(gca,'Xtick',0.4:0.05:1)
grid on
legend('Left', 'Right', 'Combined', 'Location', 'southeast')
xlabel('Sensitivity')
ylabel('Recall')
%set(gcf,'units','points','position',[10,10,850,600])

subplot(2,1,2)
set(0, 'DefaultAxesFontSize', 24)
plot(left(:,1), left(:,4), 'ko-', 'LineWidth', 2)
hold on
plot(right(:,1), right(:,4), 'gs-', 'LineWidth', 2)
hold on
plot(comb(:,1), comb(:,4), 'b-', 'LineWidth', 2)
set(gca,'Xtick',0.4:0.05:1)
grid on
legend('Left', 'Right', 'Combined', 'Location', 'southeast')
xlabel('Sensitivity')
ylabel('F-Score')
set(gcf,'units','points','position',[10,10,1000,1200])

figure
subplot(2,1,1)
set(0, 'DefaultAxesFontSize', 24)
plot(comb(:,1), comb(:,3), 'b-', 'LineWidth', 2)
hold on
plot(combs(:,1), combs(:,3), 'r-', 'LineWidth', 2)
set(gca,'Xtick',0.4:0.05:1)
grid on
legend('Combined', 'Beamformed', 'Location', 'southeast')
xlabel('Sensitivity')
ylabel('Recall')
%set(gcf,'units','points','position',[10,10,850,600])

subplot(2,1,2)
set(0, 'DefaultAxesFontSize', 24)
plot(comb(:,1), comb(:,4), 'b-', 'LineWidth', 2)
hold on
plot(combs(:,1), combs(:,4), 'r-', 'LineWidth', 2)
set(gca,'Xtick',0.4:0.05:1)
grid on
legend('Combined', 'Beamformed', 'Location', 'southeast')
xlabel('Sensitivity')
ylabel('F-Score')
set(gcf,'units','points','position',[10,10,1000,1200])
end

