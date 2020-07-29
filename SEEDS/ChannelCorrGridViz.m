% View channel correlations with spatial layout of actual EMG arm grid

% Load meanSubjMat by first running rawDataCorrelation

load('./colormapjetwhite.mat','cmapwj');

armgrid = zeros(9,14);
labelcols = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N'};
labelrows = 1:9;

figure
for ch = 1:length(meanSubjMat)
    armgrid = reshape(meanSubjMat(1:126,ch),9,14);
    imagesc(armgrid);
    colormap(cmapwj); % set colormap
    caxis([-1 1]); %limits for colorbar
    colorbar;
    xticks(1:14)
    xticklabels(labelcols)
    yticklabels(labelrows)
    title(EEG.chanlocs.labels(ch,:))
    pause(1)
end
