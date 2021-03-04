%% create doppler profile plots
    % create directory path and location
    % append save_path for the two outputs
    
    save_path = strcat(pwd,'\frequency_jumping_rfid\single_freq\data\');
    fname = 'drive_by_2';
    load(fname);
    
    
   
    profile_path = [save_path, fname,'_profile.png'];
    
    specfig=figure;
    set(gcf, 'Position',  [100, 100, 1100, 850])
    [rr cc ll] = size(FTDP_Window);
    typ = FTDP_Window(:,cc/2+10:end);
    ampmin=max(max(abs(typ.')))/50;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ;
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
    
    saveas(specfig, profile_path);