function [ output_args ] = plot_delay( fname )
%PLOT_DELAY Summary of this function goes here
%   Detailed explanation goes here

d =load(fname);

figure
set(0, 'DefaultAxesFontSize', 24)
plot(d, 'k-')

end

