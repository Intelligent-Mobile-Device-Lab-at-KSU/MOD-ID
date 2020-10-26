function locs = findLocs(MFxPos)
locs = 0;
m = .29;
while (length(locs) ~= 2) && (m <= 1)
    [pks locs]=findpeaks(MFxPos./max(MFxPos),'MINPEAKHEIGHT',m,'MINPEAKDISTANCE',10e3);
    m = m + .05;   
end