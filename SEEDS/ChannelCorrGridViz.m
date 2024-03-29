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


%% If plotting ICA components

figure
for ch = 1:size(OBJ.TransformWeights,2)
    armgrid = reshape(OBJ.TransformWeights(1:126,ch),9,14);
    imagesc(armgrid);
    colormap(cmapwj); % set colormap
    caxis([-.2 .2]); %limits for colorbar
    colorbar;
    xticks(1:14)
    xticklabels(labelcols)
    yticklabels(labelrows)
    title(['ICA Component ' num2str(ch)])
    pause(1)
end

%% If plotting PCA components
[PCAcomps,~,LATENT] = pca(dataReshape');
%%
figure
for ch = 1:29
    armgrid = reshape(PCAcomps(1:126,ch),9,14);
    imagesc(armgrid);
    colormap(cmapwj); % set colormap
    caxis([-1 1]); %limits for colorbar
    colorbar;
    xticks(1:14)
    xticklabels(labelcols)
    yticklabels(labelrows)
    title(['PCA Component ' num2str(ch)])
    pause(1)
end
