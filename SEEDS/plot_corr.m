function [] = plot_corr(corrmat,ticks, graphTitle, label, varargin)
if length(varargin) == 1
    subj = num2str(varargin{1});
else
    subj = 'all subjects or unknown';
end
load('./colormapjetwhite.mat','cmapwj');
colormap(cmapwj); % set colormap
imagesc(corrmat) %visual of mean correlation matrix 
title([graphTitle subj] );
xlabel(label);
set(gca, 'XTick', 1:size(corrmat)); % center x-axis ticks
set(gca, 'YTick', 1:size(corrmat)); % center y-axis ticks
ylabel(label');
c = colorbar;
caxis([-1 1]); %limits for colorbar
c.Label.String = 'Correlation Coefficient';
xticks(1:length(ticks));
xticklabels(ticks);% Label x axis
yticks(1:length(ticks));
yticklabels(ticks);% Label y axis
end