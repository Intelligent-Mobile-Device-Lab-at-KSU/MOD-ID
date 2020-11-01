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

%% Show Spectrogram
fname='beside_dumpster_dome';
load(fname);
[rr cc ll] = size(Direct_Window);
typ = Direct_Window(1:rr,:);
if mean(f_FTDP) < 0
    %typ = fliplr(FTDP_Window(1:rr,:));
end
ampmin=max(max(abs(typ.')))/200;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ;
imagesc(t_FTDP(1:rr),[-100:99],20*log10(max(abs(typ.'),ampmin)/ampmin));
title(['Spectrogram: ' fname],'Interpreter','none')
ylabel('Frequency (Hz)')
xlabel('Time (s)')
NumTicks = 4;
L = get(gca,'XLim');
set(gca,'XTick',round(linspace(t_FTDP(1),t_FTDP(end),NumTicks)))
axis('xy')
colorbar
