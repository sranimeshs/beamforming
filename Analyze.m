function [ output_args ] = Analyze( hotword_fold, sample_fold )
%ANALYZE Summary of this function goes here
%   Detailed explanation goes here

mkdir 'left'
mkdir 'right'
mkdir 'combined_shifted'
mkdir 'combined'

% Extract left and right and generate combined audio with no shift
hotwords = dir(sprintf('%s/hotw*.wav', hotword_fold));
for i=1:1:length(hotwords)
    audio_file = sprintf('%s/%s', hotword_fold, hotwords(i).name);
    fprintf('Extracting channels from %s\n', audio_file)
    [data, fs] = audioread(audio_file);
    
    left_fname = sprintf('left/left%d.wav', i); 
    right_fname = sprintf('right/right%d.wav', i);
    comb_fname = sprintf('combined/comb%d.wav', i);
    
    audiowrite(left_fname, data(:,1), fs);
    audiowrite(right_fname, data(:,2), fs);
    
    combined_data = (data(:,1) + data(:,2))/2;
    audiowrite(comb_fname, combined_data, fs); 
end

% Compute delays and generate shifted combined audio
samples = dir(sprintf('%s/sample*.wav', sample_fold));
delay_info = [];
for i=1:1:length(samples)
    audio_file = sprintf('%s/sample%d.wav', sample_fold, i);
    left_fname = sprintf('left/left%d.wav', i);
    right_fname = sprintf('right/right%d.wav', i);
    comb_fname = sprintf('combined_shifted/comb%d.wav', i);
    
    fprintf('Computing delay from %s\n', audio_file)
    [data, fs] = audioread(audio_file);
    [xc, lags] = xcorr(data(:,1), data(:,2));
    [~,I] = max(abs(xc));
    lagDiff = lags(I);
    
    if length(delay_info) == 0
        delay_info = lagDiff;
    else
        delay_info = [delay_info; lagDiff];
    end
    fprintf('Delay found (sample data point): %s\n', num2str(lagDiff))
    
    [left, ~] = audioread(left_fname);
    [right, ~] = audioread(right_fname);
    
    if lagDiff < 0
        right(1:end + lagDiff) = right(1 - lagDiff: end);
        right(end + lagDiff + 1: end) = 0;
    elseif lagDiff > 0
        right(1 + lagDiff: end) = right(1: end - lagDiff);
        right(1: lagDiff) = 0;
    end
    
    comb_data = (left + right)/2;
    audiowrite(comb_fname, comb_data, fs);
end

fprintf('Delay info written to delay.csv.\n')
csvwrite('delay.csv', delay_info);

fprintf('Generating merged false audios.\n')
false_files = dir(sprintf('false_samples/false*.wav'));
for i=1:1:length(false_files)
    audio_file = sprintf('false_samples/%s', false_files(i).name);
    [data,fs] = audioread(audio_file);
    comb_data = (data(:,1) + data(:,2))/2;
    
    comb_fname = sprintf('false_combined/%s', false_files(i).name);
    audiowrite(comb_fname, comb_data, fs);
end

end

