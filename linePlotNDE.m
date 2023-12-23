% Script to generate line plot of numerical distance effect (NDE) for
% response times.
% Author: Angela Rose

figure;
hold on;
y_label = {'Simulated Mean Response Time'};
legend_label = {''};
numSim = size(damageTypeArr, 2);   %number columns in array = number types of simulation runs/damages
x = [];
y = [];
stderr = [];
for simCnt = 1:numSim
    x = [1, 2, 3, 4, 5, 6, 7, 8];
    y = [mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,49),'omitnan'), ...
            mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,50),'omitnan'), ...
            mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,51),'omitnan'), ...
            mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,52),'omitnan'), ...
            mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,53),'omitnan'), ...
            mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,54),'omitnan'), ...
            mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,55),'omitnan'), ...
            mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,56),'omitnan')];
     stderr=[std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,49),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,49))), ...
         std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,50),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,50))), ...
         std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,51),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,51))), ...
         std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,52),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,52))), ...
         std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,53),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,53))), ...
         std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,54),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,54))), ...
         std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,55),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,55))), ...
         std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,56),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,56)))];
        
    %can do 4 lines with different styles
    switch numSim
        case 2
        %when 2 plot lines use these
            switch simCnt
                case 1
                    lineStyle = '-';
                case 2
                    lineStyle = ':';
            end
        case 3
            switch simCnt
                case 1
                    lineStyle = '-.';
                case 2
                    lineStyle = '-';
                case 3 
                   lineStyle = ':';
            end
        otherwise
            switch simCnt
                case 1
                    lineStyle = '-';
                case 2
                    lineStyle = '-.';
                case 3
                    lineStyle = ':';       
                case 4
                    lineStyle = '--';
            end
    end        
    
    %all lines black with different line styles eg dash etc
    errorbar(x,y,stderr(:), 'k', 'LineStyle', 'none', 'HandleVisibility','off');
    plot(x,y, 'k', 'LineStyle', lineStyle); % Need to plot after errorbar otherwise errorbar rewrites the lines without the line style  
        
    if (labelNumLearningTrials)
        legend_label(1,simCnt) = formatNumAddComma(damageTypeArr(simCnt));
    end
end
        
set(gca, 'box', 'off');
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%title_text = {'B) Model: The Numerical Distance Effect'};
%title_text = {'A'}; %for red learn without attn reduced.
%title_text = {'B'}; %for red learn with attn reduced.
title_text = {''};
title(title_text);

% if only two simulations then assume its LMA and HMA and use this for
% legend. (if legends etc don't work can update graph manually
% if want legend to display number of learning trials then change if
% statement to if labelNumLearningTrials and set flag to true
if (numSim == 2) %or labelNumLearningTrials
    legend_label = {'Low Math-Anxious', 'High Math-Anxious'};
end
if (numSim == 3) %or labelNumLearningTrials
    legend_label = {'Low Math-Anxious', 'High Math-Anxious (95%)', 'High Math-Anxious (90%)'};
end
if (numSim == 4) %or labelNumLearningTrials
    legend_label = {'17,000', '24,000', '30,000', '100,000'};
end
lgd = legend(legend_label, 'FontSize', 12);

if labelNumLearningTrials || (numSim == 4)
    title(lgd,{'Number of', 'Learning Trials'}); %Use this if need legend title across 2 lines
end
lgd.ItemTokenSize = [10,10];
legend('boxoff');
   
xlim([0 9]);
xtick_label = {''; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; ''};
xticklabels(xtick_label);
xtickangle(0);
xlabel('Numerical Distance');
   
%set(gca,'FontName','Calibri'); % used for thesis
set(gca,'FontName','Arial');  % for PLOS
set(gca,'FontSize',12);
set(gcf, 'Color', 'w');
 
% customised to display NDE for the different simulations
if max(y) < 18
    ylim([9 17]);
else
    ylim([12 22]);
end
if (numSim == 4) 
    ylim([9 22])
end
ylabel(y_label);

savefig('NDE_RT.fig');

f = gcf;
exportgraphics(f, 'NDE_RT.tif', 'Resolution', 600);

hold off;
