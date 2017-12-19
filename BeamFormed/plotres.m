[data, fs] = audioread('beamformed_128.wav');
tot_size = size(data) * 4;

process_time_128 = load('stats_128.txt');
process_time_256 = load('stats_256.txt');
process_time_512 = load('stats_512.txt');
process_time_1024 = load('stats_def.txt');

% figure
% bar_data = [sum(process_time_128);
%             sum(process_time_256);
%             sum(process_time_512);
%             sum(process_time_1024)];
%         
% set(0, 'DefaultAxesFontSize', 24)
% bar(bar_data)
% set(gca,'xticklabel',{'128', '256', '512', '1024'})
% xlabel('Buffer Size')
% ylabel('Total processing time (in sec)')

process_rate = [tot_size/sum(process_time_128);
                tot_size/sum(process_time_256);
                tot_size/sum(process_time_512);
                tot_size/sum(process_time_1024)];
figure
set(0, 'DefaultAxesFontSize', 24)
bar(process_rate)
set(gca,'xticklabel',{'128', '256', '512', '1024'})
xlabel('Buffer Size')
ylabel('Rate of processing (samples/sec)')