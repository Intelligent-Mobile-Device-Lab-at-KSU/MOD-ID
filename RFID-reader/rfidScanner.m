close all
clear
clc
dirpath0 = '2_10_Q_data/';
fname = 'CC_test'; % Input raw data file name rccartwosdrs
x = read_complex_binary ([dirpath0 fname '.dat'],100e9); % Reads the complex-binary data

%% Define Constants
f0= 5.860e9;%5.89e9;
Fs = 10e6; % Samples/Sec, sampling rate
Fsc = 0e3; %variable

% Set Tag Scanning Resolution
scan_adv = 5e-2;%5e-3; % s, sliding window advancement duration
winddur = .1;%1; % s, fft window duration
scan_adv_samps = floor(scan_adv.*Fs); % samples, sliding window advance amount

% Pre-Determine the frequency axis for the Doppler Profile (based on the window duration)
wind = floor(winddur.*Fs); % samples, (or nfft size) this should be the desired window
pp=wind/2;
mm = 100;
t_FTDP = 0;

% Scanner Processing
scan_Window_ind = 1; % Value for Window Index
nend = 1000000; % Controls how many windows are processed. Set to large number (1000000) as infinity
myTag_AA = [];
myTag_CC = [];
L = length(x);

for currSlideLoc = 0:scan_adv_samps:L-wind
    
    if  scan_Window_ind > nend
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
       t_FTDP = [t_FTDP; t_FTDP(end)+scan_adv];
       currTime = t_FTDP(end)+scan_adv;
    end

    % Take large FFT over 1st window in this segment
    segment = x(windLoc);
    Fx = fftshift(fft(blackman(length(segment)).*segment));
    MFxPos = abs(Fx);
    
    % Take subsegment of FFT over carrier center
    obswindow = MFxPos(pp-mm:pp+mm-1);
    
    %Remove burst of energy
    [pks locs]=findpeaks(obswindow./max(obswindow),'MINPEAKHEIGHT',.32,'MINPEAKDISTANCE',15); %leave these settings
    
    num = "-1"; % debugging
    
    % Only one large spike should be found
%     if length(locs) > 2 % if there are more, then this is burst of energy that needs to be removed
%        num = "0";
%        myTag_AA = [myTag_AA 0];
%        myTag_CC = [myTag_CC 0];
%     else 
        num="1";
        %Special Section looking for tag
        tag_pp=wind/2;
        tag_mm = 2*50000;

        t_obswindow = segment(tag_pp-tag_mm:tag_pp+tag_mm-1);
        N=10;
        xcc=[ones(1,N).*exp(1i*0) ones(1,N).*exp(1i*0) ones(1,N).*exp(1i*pi)  ones(1,N).*exp(1i*pi) ones(1,N).*exp(1i*0) ones(1,N).*exp(1i*0)  ones(1,N).*exp(1i*pi)  ones(1,N).*exp(1i*pi)].';
        xaa=[ones(1,N).*exp(1i*0)  ones(1,N).*exp(1i*pi) ones(1,N).*exp(1i*0)  ones(1,N).*exp(1i*pi) ones(1,N).*exp(1i*0)  ones(1,N).*exp(1i*pi) ones(1,N).*exp(1i*0)  ones(1,N).*exp(1i*pi) ones(1,N).*exp(1i*0)  ones(1,N).*exp(1i*pi)].';
        
        mf_xcc = conj(xcc(end:-1:1));
        mf_xaa = conj(xaa(end:-1:1));

        y_xcc = filter(mf_xcc,1,t_obswindow);
        y_xaa = filter(mf_xaa,1,t_obswindow);

        myTag_CC = [myTag_CC max(abs(y_xcc).^2)];
        myTag_AA = [myTag_AA max(abs(y_xaa).^2)];
%         end

        % Advance output, report progress
        scan_Window_ind = scan_Window_ind + 1;
        clc
        fprintf('Working %s: %.2f%% Complete, used statement %s with length %.2f\r',fname,100*(currSlideLoc/(L-wind)), num, length(locs))
end

figure
%%
plot(myTag_AA,'ro')
hold on
plot(myTag_CC,'bo')