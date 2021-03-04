%% create doppler profile plots
    % create directory path and location
    % append save_path for the two outputs
    
    save_path = strcat(pwd,'\single_freq\data\');
    fname = 'cw_2car_chengAA_trevorCC';
    load(fname);
    
    
   
    profile_path = [save_path, fname,'_frequency_plot.png'];
    
    doppfreqfig=figure;
    set(gcf, 'Position',  [100, 100, 1100, 850])
    labelsize = 18;
    t_myfs=myfs;
    t_myfsvals=myfsvals;
    normamplitudevals = t_myfsvals/max(t_myfsvals);
    indicis=find(normamplitudevals<.25)
    t_myfs(indicis) = 0;
    t_myfs(t_myfs<0) = 0;
    
    disp(length(t_FTDP));
    disp(length(t_myfs));
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
    saveas(doppfreqfig, frequency_path);