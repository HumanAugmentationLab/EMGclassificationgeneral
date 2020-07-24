function MAVS = MAVSfunc(mydata, windowsize)
    %[mydata] is a 2D matrix of the data, with each trial as a column
    
    %[windowsize] is a integer of the window size in number of data points
    [dim1, dim2] = size(mydata);
    
    if dim1 > dim2
        dataPoints = dim1;
        trialNum = dim2;
    else
        dataPoints = dim2;
        trialNum = dim1;
    end

    w.totaltimewindow = [1 dataPoints];
    w.timewindowoverlap = 0; %no overlap needed for DFA
    %Potential to clean up this function in the future by removing any
    %instance of timewindowoverlap
    
    %Also should change any occurance of 'times' to 'points' for clarity,
    %as this function works using data points, not time
    
        
        %Calculating the start and end points of each bin, based on the window size
        w.starttimes = w.totaltimewindow(1):(windowsize(bin)-w.timewindowoverlap):w.totaltimewindow(2);
        w.endtimes = (w.totaltimewindow(1)-1+windowsize(bin)):(windowsize(bin)-w.timewindowoverlap):w.totaltimewindow(2);
        
        if w.totaltimewindow(2) - w.starttimes(end) <= w.timewindowoverlap %if increment is smaller than the overlap window
            w.starttimes(end) = []; %then remove the last one (avoids indexing problem, plus you've already used this data)
        end
        if length(w.starttimes) > length(w.endtimes)
            w.endtimes = [w.endtimes w.totaltimewindow(2)];
            %warning('The timewindowbinsize does not split evenly into the totaltimewindow, last window will be smaller')
            w.endtimes - w.starttimes;
        end
        w.alltimewindowsforfeatures = [w.starttimes; w.endtimes];%(:,1) for first pair
        
        
        for trial = 1:trialNum
            
            %Stops the function from trying to call a data point that doesn't exist
            if w.endtimes(end)>dataPoints
               w.endtimes(end) = [];
               w.starttimes(end) = [];
            end
            
                for L = 1:(floor(w.totaltimewindow(2)/windowsize)) %loops through each data bin
                     databin = mydata((w.starttimes(L):w.endtimes(L)), trialNum);%takes data for a specific bin from the current trial
                     mavTemp = mean(abs(mydata));
                     if L == 1%Concatenates all the data bins into one 2D matrix per trial
                        trialMAVbins = mavTemp;
                     else
                        trialMAVbins = cat(1, trialMAVbins, mavTemp); 
                     end
                    trialMAVS = diff(trialMAVbins)
                end
                
            if trial == 1 %Concatenate all the trials' data bins matrices into a 3D matrix
                MAVS = trialMAVS;
            else
                MAVS = cat(2, MAVS, trialMAVS); 
            end
            
        end
        
        
end

