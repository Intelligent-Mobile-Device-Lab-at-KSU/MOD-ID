%% create doppler profile plots
% create directory path and location
% append save_path for the two outputs

save_path = strcat(pwd,'\single_freq\data\');
fname = 'cw_car badwithtagCC';
load(fname);

%% create doppler profile plots
% create directory path and location
% append save_path for the two outputs
% profile_path = [save_path, fname,'_profile.png'];
% specfig=figure;
set(gcf, 'Position',  [100, 100, 1100, 850])
[rr cc ll] = size(FTDP_Window);
typ = FTDP_Window(:,cc/2+10:end);
ampmin=max(max(abs(typ.')))/6;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ;
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

% saveas(specfig, profile_path);

%% overlay trend line
hold on

disp(FTDP_Window);

limited_DP = t_FTDP(myfs>200 & myfs < 600);% & t_FTDP < 7);
limited_fs = myfs(myfs>200 & myfs < 600);% & t_FTDP < 7);

limited_DP = limited_DP(limited_DP > 3 & limited_DP < 7);
limited_fs = limited_fs(limited_DP > 3 & limited_DP < 7);

coeffs=polyfit(limited_DP,limited_fs,5);
newxxs=linspace(t_FTDP(50),t_FTDP(end),1000);
newyys=polyval(coeffs,newxxs);
% figure
plot(limited_DP,limited_fs,'bo')
hold on
plot(newxxs,newyys,'r')