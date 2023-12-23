% Script to generate bar graph of Congruent (LMA, HMA) and Incongruent (LMA, HMA)
% response times.
% Author: Angela Rose
    
if (taskType == 1)
    figure;
    bar_label = {'Congruent', 'Incongruent'};
    y_label = {'Simulated Mean Response Time'};
    y = [mean(resultsANNMatrix(1:numTestANN,9),'omitnan'), mean(resultsANNMatrix(numTestANN+1:numTestANN*2,9),'omitnan'); mean(resultsANNMatrix(1:numTestANN,10),'omitnan'), mean(resultsANNMatrix(numTestANN+1:numTestANN*2,10),'omitnan')];
    stderr=[std(resultsANNMatrix(1:numTestANN,9),'omitnan')/sqrt(length(resultsANNMatrix(1:numTestANN,9))), std(resultsANNMatrix(numTestANN+1:numTestANN*2,9),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN+1:numTestANN*2,9))); std(resultsANNMatrix(1:numTestANN,10),'omitnan')/sqrt(length(resultsANNMatrix(1:numTestANN,10))), std(resultsANNMatrix(numTestANN+1:numTestANN*2,10),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN+1:numTestANN*2,10)))];
    b = bar(y, 'FaceColor','flat', 'BaseValue', 6);
    
    switch damageTypeArr(2)
        case 7
            switch setDCWeights
                case 3 
                    title_text = {'B) Model: Impair', 'Numerical Size Attention'};
                    fileBarCongruityGroups = "RT_C_I_LMAHMA_7.fig";
                    fileBarCongruityGroupsTif = "RT_C_I_LMAHMA_7.tif";
                case 4
                    title_text = {'F) Model: Anxiety and', 'Less Trained Connections'};
                    fileBarCongruityGroups = "RT_C_I_LMAHMA_53_7.fig";
            end
        case 8
            title_text = {'C) Model: Impair', 'Physical Size Attention'};
            fileBarCongruityGroups = "RT_C_I_LMAHMA_8.fig";
            fileBarCongruityGroupsTif = "RT_C_I_LMAHMA_8.tif";
        case 9
            title_text = {'D) Model: Impair Numerical', 'and Physical Size Attention'};
            fileBarCongruityGroups = "RT_C_I_LMAHMA_9.fig";
            fileBarCongruityGroupsTif = "RT_C_I_LMAHMA_9.tif";
        case 53
            title_text = {'E) Model:', 'Less Trained Connections'};
            fileBarCongruityGroups = "RT_C_I_LMAHMA_53.fig";
        otherwise
            title_text = {''};
            fileBarCongruityGroups = "RT_C_I_LMAHMA.fig";
            fileBarCongruityGroupsTif = "RT_C_I_LMAHMA.tif";
    % For experimental results graph run barGraphNumStroopExper.m
    end
    
    set(gca, 'box', 'off');  %remove top and right axes
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';  %left justify title
    %ax.TitleFontSizeMultiplier = 1.5;      % change font size of just the title (it is scaled compared to axes)
    title(title_text);
    axis square;  % makes the x-axis shorter ie less space between bars
    
    title(title_text);
    %set colour [r g b] of bars
    b(1).FaceColor = [1 1 1]; %for first group of bars
    b(2).FaceColor = [0.3 0.3 0.3]; % for second group of bars

    % legend
    % If use LMA abbreviation then set legend font 10 and ItemTokenSize
    % [-8, -8] as looks best.
    % Note font for labels are defaulting to 11. Default for legend is
    % 9.
    % If don't use LMA abbreviation then set legend font 11 and ItemTokenSize
    % [10, 10] as looks best. But can play with font 10 or 11.
    lgd = legend('Low Math-Anxious', 'High Math-Anxious', 'FontSize', 12);
    lgd.ItemTokenSize = [10,10];   % minimum size of legend symbol and text (but auto adjusts, can be negative)
    %legend('Location','best');  
    legend('Location','northwest');   %using 'best' is not working for C, I but is when graphing C, I, SCE.
    legend('boxoff'); %removes box from around legend
    
    hold on
    % Add errorbars
    % Get x centers so can position errorbars; XOffset is undocumented
    xtipsall = (get(b(1),'XData') + cell2mat(get(b,'XOffset'))).';   % this line is old Matlab version but works. 
    % The 'k' is the code for the color black and makes the errorbars black
    % The handle visibility off stops the errorbar from being displayed in the
    % legend
    errorbar(xtipsall(:), y(:), stderr(:), 'k', 'LineStyle','none', 'HandleVisibility','off');

    set(gca, 'Ticklength', [0 0]);   % removes the ticks on the x-axis between the groups by setting their length to zero, for [firsttick secondtick]
    xticklabels(bar_label);
    xtickangle(0);  %labels horizontal
    
    %ylim([6 14]);   % just for reducing attention to physical size only

    %get(gca,'FontName'); %displays the font for the gca current axis object
    %get(gca,'FontSize');
    % sets font for all ie axes, labels, title, legend
    %set(gca,'FontName','Calibri'); % used for thesis
    set(gca,'FontName','Arial'); %for PLOS
    set(gca,'FontSize',12);
    set(gcf, 'Color', 'w'); %background colour to white

    ylabel(y_label);  %no option to set x-axis label to bold so just leave y-axis normal

    savefig(fileBarCongruityGroups); %save as .fig
    
    f = gcf;
    exportgraphics(f, fileBarCongruityGroupsTif, 'Resolution', 600); %export to .tif at high res
    
    hold off;
    
end %taskType == 1
