indexkeep = []
includedspeeds
for n = 1:length(EEG.data)
    if EEG.speeds(n) == includedspeeds(1)
        indexkeep = [indexkeep n]
    end
end 

