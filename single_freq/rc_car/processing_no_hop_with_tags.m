dirpath0 = '2_10_Q_data/';
fname = 'test_AA_3'; % Input raw data file name rccartwosdrs
x = read_complex_binary ([dirpath0 fname '.dat'],100e9); % Reads the complex-binary data

%% Define Constants
f0= 5.860e9;%5.89e9;
lambda = physconst('LightSpeed')/f0;
Fs = 10e6; % Samples/Sec, sampling rate
Fsc = 0e3; %variable


% Select Doppler Profile Resolution
highres=0;
if highres
    FTDP_adv = 5e-3;%5e-3; % s, sliding window advancement duration
    winddur = 1;%1; % s, fft window duration
else
    FTDP_adv = 5e-2;%5e-3; % s, sliding window advancement duration
    winddur = .1;%1; % s, fft window duration
end

% Pre-Determine the frequency axis for the Doppler Profile (based on the window duration)
fsc_view = Fsc; % Hz, Center Frequency for Frequency-Time Doppler Profile (FTDP)
dfwin = 2000; % Hz, Doppler Window (gets converted to samples later)
wind = floor(winddur.*Fs); % samples, (or nfft size) this should be the desired window
FTDP_adv_samps = floor(FTDP_adv.*Fs); % samples, sliding window advance amount

f_FTDP = []; t_FTDP = 0;
f = ((0:wind-1)*(Fs/wind))';
f = f(f<Fs/2);
f = ((-wind/2:wind/2 -1)*Fs/wind)'; % both sides of FFT
f_FTDP = f; % Get FTDP frequency range

pp=wind/2;
mm = 100;
f_FTDP = f_FTDP(pp-mm:pp+mm-1);

% Doppler Processing
FTDP_Window = []; % Basic SPectrogram output
FTDP_Window_ind = 1; % Value for Window Index
nend = 1000000; % Controls how many windows are processed. Set to large number (1000000) as infinity
myfs = []; %Container for peak locations in f
myfsvals = []; % c
debugplots = 0;
pauseafterdebugplot = 0;
%
L = length(x);
for currSlideLoc = 0:FTDP_adv_samps:L-wind
    
    if  FTDP_Window_ind > nend
        break;
    end
    
    % Get window location and update t_FTDP (time vector)
    currTime = 0;
    if currSlideLoc == 0
       % For first segment (window) of signal
       windLoc = 1:wind;
    else
       % For all other segments of signal
       windLoc = currSlideLoc:currSlideLoc+wind-1;
       t_FTDP = [t_FTDP; t_FTDP(end)+FTDP_adv];
       currTime = t_FTDP(end)+FTDP_adv;
    end

    % Take large FFT over 1st window in this segment
    segment = x(windLoc);
    Fx = fftshift(fft(blackman(length(segment)).*segment));
    MFxPos = abs(Fx);
    
    % Take subsegment of FFT over carrier center
    obswindow = MFxPos(pp-mm:pp+mm-1);
    
    if debugplots
        close all
        plot(obswindow);
        drawnow
    end

    %Remove burst of energy
    % changing this one to test it
    [pks locs]=findpeaks(obswindow./max(obswindow),'MINPEAKHEIGHT',.29,'MINPEAKDISTANCE',10); %leave these settings
    
    if debugplots
        hold on
        plot(locs,obswindow(locs),'ro')
        drawnow
        if pauseafterdebugplot
            pause
        end
    end
    
    % Only one large spike should be found
    if length(locs) > 2 % if there are more, then this is burst of energy that needs to be removed
       FTDP_Window(FTDP_Window_ind,:) = zeros(1,length(obswindow));
       myfs = [myfs 0];
       myfsvals = [myfsvals 0];
    else 
        obswindow(length(obswindow)/2-5:length(obswindow)/2+4) = 0; % remove carrier
        [pks locs]=findpeaks(obswindow./max(obswindow),'MINPEAKHEIGHT',20,'MINPEAKDISTANCE',10); %leave these settings
        if length(locs) > 2
            obswindow = obswindow.*0;
        end
        [val,pos]=max(pks);
        myfsvals = [myfsvals obswindow(locs(pos))];
        myfs = [myfs f_FTDP(locs(pos))];
%         close all
%         plot(obswindow);
%         drawnow
%         hold on
%         plot(locs,obswindow(locs),'ro')
%         drawnow
        
        obswindow(1:length(obswindow)/2) = 0; % We only care about + doppler shifts
        FTDP_Window(FTDP_Window_ind,:) = obswindow.'; % ||^2
    end
    
    % Advance output, report progress
    FTDP_Window_ind = FTDP_Window_ind + 1;
    clc
    fprintf('Working %s: %.2f%% Complete\r',fname,100*(currSlideLoc/(L-wind)))
end

%% Show Spectrogram
specfig=figure;
set(gcf, 'Position',  [100, 100, 1100, 850])
[rr cc ll] = size(FTDP_Window);
typ = FTDP_Window(:,cc/2+10:end);
ampmin=max(max(abs(typ.')))/8;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ;
imagesc(t_FTDP(1:rr),f_FTDP(cc/2+10:end),10*log10(max(abs(typ.'),ampmin)/ampmin));%20*log10(max(abs(typ.'),ampmin)/ampmin));
labelsize = 18;
title(['Spectrogram: ' fname],'Interpreter','none', 'FontSize', labelsize, 'FontWeight', 'bold')
ylabel('Doppler Frequency (Hz)', 'FontSize', labelsize, 'FontWeight', 'bold')
xlabel('Time (s)','FontSize', labelsize, 'FontWeight', 'bold')
NumTicks = 4;
L = get(gca,'XLim');
set(gca,'XTick',round(linspace(t_FTDP(1),t_FTDP(end),NumTicks)))
axis('xy')

% Set x and y font sizes.
ax = gca
ax.XAxis.FontSize = 20;
ax.YAxis.FontSize = 20;
ax.FontWeight = 'bold';
axis tight
saveas(specfig,'ccsv_1_18/figs/DopplerProfileSpectrum.png');
%%
doppfreqfig=figure;
set(gcf, 'Position',  [100, 100, 1100, 850])
labelsize = 18;
t_myfs=myfs;
t_myfsvals=myfsvals;
normamplitudevals = t_myfsvals/max(t_myfsvals);
indicis=find(normamplitudevals<.25)
t_myfs(indicis) = 0;
t_myfs(t_myfs<0) = 0;

plot(t_FTDP,t_myfs,'bo','MarkerSize',12, 'LineWidth', 2)
title(['Doppler Profile'],'Interpreter','none', 'FontSize', labelsize, 'FontWeight', 'bold')
ylabel('Doppler Frequency (Hz)', 'FontSize', labelsize, 'FontWeight', 'bold')
xlabel('Time (s)','FontSize', labelsize, 'FontWeight', 'bold')
% Set x and y font sizes.
ax = gca
ax.XAxis.FontSize = 20;
ax.YAxis.FontSize = 20;
ax.FontWeight = 'bold';
grid on
saveas(doppfreqfig,'ccsv_1_18/figs/DopplerFrequencyPlot.png');