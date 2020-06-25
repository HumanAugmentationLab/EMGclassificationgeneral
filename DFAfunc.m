function DFA = DFAfunc(mydata, windowvector)
    [dataPoints, trialNum] = size(mydata);
    yk = zeros(dataPoints, trialNum);
    trialMean = mean(mydata)
    yk = (cumsum((mydata)-mean(mydata)));
    
    w.totaltimewindow = [1 dataPoints];
    w.timewindowoverlap = 0;
    
    for bin = 1:(size(windowvector,2))
    
        w.starttimes = w.totaltimewindow(1):(windowvector(bin)-w.timewindowoverlap):w.totaltimewindow(2);
        w.endtimes = (w.totaltimewindow(1)-1+windowvector(bin)):(windowvector(bin)-w.timewindowoverlap):w.totaltimewindow(2);
        if w.totaltimewindow(2) - w.starttimes(end) <= w.timewindowoverlap %if increment is smaller than the overlap window
            w.starttimes(end) = []; %then remove the last one (avoids indexing problem, plus you've already used this data)
        end
        if length(w.starttimes) > length(w.endtimes)
            w.endtimes = [w.endtimes w.totaltimewindow(2)];
            warning('The timewindowbinsize does not split evenly into the totaltimewindow, last window will be smaller')
            w.endtimes - w.starttimes
        end
        w.alltimewindowsforfeatures = [w.starttimes; w.endtimes];%(:,1) for first pair
        
        xval = [1:windowvector(bin)];
        
        for trial = 1:trialNum
            
                for L = 1:(w.totaltimewindow(2)/windowvector(bin))
                     databin = yk((w.starttimes(L):w.endtimes(L)), trialNum);
                     if L == 1
                        epochData = databin;
                     else
                        epochData = cat(2, epochData, databin); 
                     end
                    
                    epochData = [epochData databin];
                end
                
            if trial == 1
                epochTrial = epochData;
            else
                epochTrial = cat(3, epochTrial, epochData); 
            end
            
            for loop = 1:(w.totaltimewindow(2)/windowvector(bin))
                coeff(loop,:,trial) = polyfit(xval,epochTrial(1:(windowvector(bin)),loop,trial), 2);
                
                singleYn = polyval(coeff(loop,:,trial), xval);
                if loop == 1
                    binYn = singleYn;
                else
                    binYn = cat(2, binYn, singleYn); 
                end
            end
            
            if trial == 1
                    yn = binYn;
                else
                    yn = cat(3, yn, binYn); 
            end
        end
        
        squeeze(yn)
        yk = yk(1:(size(yn,2)),:) % When testing, yk ended up one row smaller than yn, so this makes yk and yn the same dimensions
        singleFn  = sqrt((sum((yk - squeeze(yn)).^2)/(size(yk,1))));
        if bin == 1
                    fn = singleFn;
                else
                    fn = cat(3, fn, singleFn); 
        end
    end

    flucProfiles = squeeze(fn)
    logFn = log10(flucProfiles)
    logBinSize = log10(windowvector)
    DFA = (mean((logFn./logBinSize)'))'
end

