%% Define Constants
f0= 5.860e9;%5.89e9;
lambda = physconst('LightSpeed')/f0;
Fs = 1e6; % Samples/Sec, sampling rate
Fsc = 0; %variable

%% Select Doppler Profile Resolution
highres=0;
if highres
    FTDP_adv = 5e-3;%5e-3; % s, sliding window advancement duration
    winddur = 1;%1; % s, fft window duration
else
    FTDP_adv = 5e-2;%5e-3; % s, sliding window advancement duration
    winddur = .1;%1; % s, fft window duration
end

%% Pre-Determine the frequency axis for the Doppler Profile (based on the window duration)
fsc_view = Fsc; % Hz, Center Frequency for Frequency-Time Doppler Profile (FTDP)
dfwin = 2000; % Hz, Doppler Window (gets converted to samples later)
wind = floor(winddur.*Fs); % samples, (or nfft size) this should be the desired window
FTDP_adv_samps = floor(FTDP_adv.*Fs); % samples, sliding window advance amount

f_FTDP = []; t_FTDP = 0;
f = ((0:wind-1)*(Fs/wind))';
f = f(f<Fs/2);
f = ((-wind/2:wind/2 -1)*Fs/wind)'; % both sides of FFT
f_FTDP = f; % Get FTDP frequency range

%% Doppler Processing
Fcfo = []; % Holder for CFO Measurement
FTDP_Window_Doppler_Unaligned = []; % Holder for FTDP Unaligned Doppler
FTDP_Window_Doppler = []; % Holder for FTDP Aligned Doppler
FTDP_Window = []; % Basic SPectrogram output
Direct_Window = []; % cheat, no rotate
FTDP_Window_ind = 1; % Value for Window Index
FTDP_Window_indcount=1; % Value for Window Count
nend = 1000000; % Controls how many windows are processed. Set to large number (1000000) as infinity
myfs = []; %Container for peak locations in f
% Control variable in case the FFT does not reveal a strong peak
noPeaksPreviously = 0;
mypow=[];
% Will display the Aligned Doppler Spectrum for all processed windows in real-time
displayDopplerProfile_in_RealTime = 0;

% Will display the aligned Doppler Spectra (different from Doppler Profile)
% in real-time.
displayDopplerSpectra_in_RealTime = 0;

% Will compute and display the Unaligned Doppler Profile
showUnalignedDopplerProfile = 0;

dirpath0 = 'raw/';
fname = 'test1013'; % Input raw data file name rccartwosdrs
x = read_complex_binary ([dirpath0 fname '.dat'],100e9); % Reads the complex-binary data

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
    N = 10000;
    M = 10000;
    segment = x(windLoc);
        if 0
            mypow(FTDP_Window_ind,:)=mean(abs(segment).^2);
    end
     if(currTime>=5)
    %     [cfs,frq] = cwt(segment,Fs);
   % pause
    
     end
    %Fx = fft(blackman(length(segment)).*segment);
    %MFxPos = abs(Fx);%abs(Fx(wind/2+1:end));%abs(Fx(1:wind/2));
    
    %MFxPos(1:M) = 0;
    %MFxPos(end-N:end) = 0;
    %plot(MFxPos);
    %drawnow
    %continue
    Fx = fftshift(fft(blackman(length(segment)).*segment));
    %Fx = fftshift(fft(segment));
    MFxPos = abs(Fx);%abs(Fx(wind/2+1:end));%abs(Fx(1:wind/2));
    MFxPos(length(Fx)/2-1000:length(Fx)/2+1000) = 0;
    %MFxPos(1:M) = 0;
    %MFxPos(end-N:end) = 0;
    FTDP_Window(FTDP_Window_ind,:) = MFxPos;
    if 0
    plot(MFxPos);
    drawnow
    continue
    end
    
    locs = findLocs(MFxPos);
    if isempty(locs)
       display('Flag1: Empty locs')
       noPeaksPreviously = 1;
       FTDP_Window_ind = FTDP_Window_ind + 1;
       if FTDP_Window_ind ~= 1
        %FTDP_Window_Doppler(FTDP_Window_ind,:) = FTDP_Window_Doppler(FTDP_Window_ind-1,:);
       end
       continue
    end

    locs = locs(end);
    if length(locs) ~= 1
       display('Flag2: locs length not one?')
       noPeaksPreviously = 1;
       FTDP_Window_ind = FTDP_Window_ind + 1;
       if FTDP_Window_ind ~= 1
        %FTDP_Window_Doppler(FTDP_Window_ind,:) = FTDP_Window_Doppler(FTDP_Window_ind-1,:);
       end
       continue
       %plot(f,MFxPos);
       %break;
    end
    if(currTime>=1)
        pp=locs(1);
        %if pp>100000-2000
        %    continue;
        %end
        
        %MFxPos(pp-5:pp+4)=0;
        
        %plot(MFxPos);
        %drawnow
        %continue
        Direct_Window(FTDP_Window_ind,:)= MFxPos(pp-100:pp+99);
         if 0
            mypow(FTDP_Window_ind,:)=mean(MFxPos(pp-100:pp+99));
    end
        if 0
        plot(MFxPos(pp-100:pp+99))
        drawnow
        end
        %plot(MFxPos(pp-500:pp+499))
        %drawnow
            end
    myfs = [myfs f(locs(1))];
    % Correct for CFO
    %if f(locs(1))>250000
        V = [-450000 -350000 -250000 -150000 -50000 50000 150000 250000 350000 450000];
        T = f(locs(1)) - V;
        [val,pos] = min(abs(T));
        
        CFOfine = f(locs(1))-0;%-V(pos);
    %elseif f(locs(1))<250000
     %   CFOfine = f(locs(1))+250000;
    %end
    Fcfo = [Fcfo abs(f(locs(1))-V(pos))];
    segment = segment.*exp(-1i.*2.*pi.*CFOfine.*[1:length(segment)]'.*(1/Fs));
    
    %CFOfine = V(pos) - 300000;
    %segment = segment.*exp(-1i.*2.*pi.*CFOfine.*[1:length(segment)]'.*(1/Fs));
    
     % Obtain corrected spectrum, which is the Doppler Profile for the
    % current window.
    Fx = fft(hann(wind).*segment);
    MFxPos = abs(Fx);%abs(Fx(wind/2+1:end));%abs(Fx(1:wind/2));
    MFxPos(1:2000) = 0;
    if noPeaksPreviously
        FTDP_Window_Doppler(FTDP_Window_ind,:) = MFxPos;
    else
        % Need to code: Estimate Doppler Profiles between noPeaks segement 
        % and current segment. For now just treat as normal.
        
        % <code to estimate missed segments>
        
        FTDP_Window_Doppler(FTDP_Window_ind,:) = MFxPos;
    end
    
    % Update the FTDP window index and report status
    FTDP_Window_ind = FTDP_Window_ind +1;
    clc
    fprintf('Working %s: %.2f%% Complete\r',fname,100*(currSlideLoc/(L-wind)))
end

%% Show Spectrogram
[rr cc ll] = size(Direct_Window);
typ = Direct_Window(1:rr,:);
if mean(f_FTDP) < 0
    %typ = fliplr(FTDP_Window(1:rr,:));
end
ampmin=max(max(abs(typ.')))/1000;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ;
imagesc(t_FTDP(1:rr),[-100:99],20*log10(max(abs(typ.'),ampmin)/ampmin));
title(['Spectrogram: ' fname],'Interpreter','none')
ylabel('Frequency (Hz)')
xlabel('Time (s)')
NumTicks = 4;
L = get(gca,'XLim');
set(gca,'XTick',round(linspace(t_FTDP(1),t_FTDP(end),NumTicks)))
axis('xy')
colorbar
