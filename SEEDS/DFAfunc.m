function DFA = DFAfunc(mydata, windowvector)
    %[mydata] is a 2D matrix of the data, with each trial as a column
    
    %[windowvector] is a vector of the window sizes, in number of data
    %points, being looped through. Minimum window size is 3 as second
    %degree polyfit does not work with less than 3 data points


    yk = (cumsum((mydata)-mean(mydata))); %cumulative sum of the difference between each data point
                   
    [dataPoints, trialNum] = size(yk);
    
                                    
    w.totaltimewindow = [1 dataPoints];
    w.timewindowoverlap = 0; %no overlap needed for DFA
    %Potential to clean up this function in the future by removing any
    %instance of timewindowoverlap
    
    %Also should change any occurance of 'times' to 'points' for clarity,
    %as this function works using data points, not time
    
    for bin = 1:(size(windowvector,2)) %loops through each window size
        
        %Calculating the start and end points of each bin, based on the window size
        w.starttimes = w.totaltimewindow(1):(windowvector(bin)-w.timewindowoverlap):w.totaltimewindow(2);
        w.endtimes = (w.totaltimewindow(1)-1+windowvector(bin)):(windowvector(bin)-w.timewindowoverlap):w.totaltimewindow(2);
        
        if w.totaltimewindow(2) - w.starttimes(end) <= w.timewindowoverlap %if increment is smaller than the overlap window
            w.starttimes(end) = []; %then remove the last one (avoids indexing problem, plus you've already used this data)
        end
        if length(w.starttimes) > length(w.endtimes)
            w.endtimes = [w.endtimes w.totaltimewindow(2)];
            %warning('The timewindowbinsize does not split evenly into the totaltimewindow, last window will be smaller')
            w.endtimes - w.starttimes;
        end
        w.alltimewindowsforfeatures = [w.starttimes; w.endtimes];%(:,1) for first pair
        
        %Needed to give the polyfit function an xvalue to work with
        xval = [1:windowvector(bin)];
        
        for trial = 1:trialNum
            
            %Stops the function from trying to call a data point that doesn't exist
            if w.endtimes(end)>dataPoints
               w.endtimes(end) = [];
               w.starttimes(end) = [];
            end
            
                for L = 1:(floor(w.totaltimewindow(2)/windowvector(bin))) %loops through each data bin
                     databin = yk((w.starttimes(L):w.endtimes(L)), trialNum);%takes data for a specific bin from the current trial
                     if L == 1%Concatenates all the data bins into one 2D matrix per trial
                        epochData = databin;
                     else
                        epochData = cat(2, epochData, databin); 
                     end
                    
                    epochData = [epochData databin];
                end
                
            if trial == 1 %Concatenate all the trials' data bins matrices into a 3D matrix
                epochTrial = epochData;
            else
                epochTrial = cat(3, epochTrial, epochData); 
            end
            
            for loop = 1:(floor(w.totaltimewindow(2)/windowvector(bin)))
                %Calculates a second-order least squares fit of the data in each bin
                coeff(loop,:,trial) = polyfit(xval',epochTrial(1:(windowvector(bin)),loop,trial), 1);
                
                %Takes the estimate of each data point based on its least-squares polyfit
                singleYn = polyval(coeff(loop,:,trial), xval);
                
                %Concatenating all the estimations per trial into a 2D matrix
                if loop == 1
                    binYn = singleYn;
                else
                    binYn = cat(2, binYn, singleYn); 
                end
            end
            
            %Concatenating all the trial estimations into a 3D matrix
            if trial == 1
                    yn = binYn;
                else
                    yn = cat(3, yn, binYn); 
            end
        end
        
        ykResized = yk(1:(size(yn,2)),:); % When testing, yk ended up one row smaller than yn, so this makes yk and yn the same dimensions
        
        singleFn  = sqrt((sum((ykResized - squeeze(yn)).^2)/(size(ykResized,1)))); %calculate the Fn value for all trials in the current bin
        if bin == 1 %concatenate all the Fn values from different bins
                    fn = singleFn;
                else
                    fn = cat(3, fn, singleFn); 
        end
    end
    %DFA is the estimated slope of Fn values against bin size on a log10 graph, so Fn and bin size a logged
    flucProfiles = squeeze(fn);
    logFn = log10(flucProfiles);
    logBinSize = log10(windowvector);
    
    
    for trialLoop = 1:trialNum
        DFAtemp = polyfit((logBinSize),(logFn(trialLoop,:)),1); %Linear polyfit finds the slope from the logValues
        if trialLoop == 1 %Concatenating all DFA values to get one value per trial
            DFA = DFAtemp(1);
        else
            DFA = cat(2, DFA, DFAtemp(1)); 
        end

    end
    DFA = DFA'; %transpose the matrix so the dims work with the feature extraction code
    
end

