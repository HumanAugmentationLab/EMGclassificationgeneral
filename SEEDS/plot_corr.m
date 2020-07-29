function [] = plot_corr(corrmat,ticks, graphTitle, label, varargin)
if length(varargin) == 1
    subj = [' For Subj ' num2str(varargin{1})];
else
    subj = ' For All Subjects';
end
load('./colormapjetwhite.mat','cmapwj');
colormap(cmapwj); % set colormap
imagesc(corrmat) %visual of mean correlation matrix 
title([graphTitle subj] );
xlabel(label);
ylabel(label);
c = colorbar;
caxis([-1 1]); %limits for colorbar
c.Label.String = 'Correlation Coefficient';

numticks = size(corrmat,1);
if numticks > 100 % If there are too many ticks, reduce this to half for readability
    numticks = ceil(size(corrmat,1)./2);
    ticks = ticks(1:2:end);
    set(gca, 'XTick', 1:2:size(corrmat,1));
    set(gca, 'YTick', 1:2:size(corrmat,1));
else
    set(gca, 'XTick', 1:numticks); % center x-axis ticks
    set(gca, 'YTick', 1:numticks); % center y-axis ticks
end
xticklabels(ticks);% Label x axis
yticklabels(ticks);% Label y axis
xtickangle(90); %rotate x axis ticks to avoid collision
end