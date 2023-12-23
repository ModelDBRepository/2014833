% Script to generate bar graph of speed-accuracy trade-off ie. different
% values of the threshold parameter.
% Author: Angela Rose

figure;
y_label = {'% Errors'};
numSim = size(damageTypeArr, 2);
y = [];
stderr = [];
bar_label = {};
for simCnt = 1:numSim
    % this calculates number of errors as col4/col3 = sum of errors / sum total trials.
    % Don't do % Hits as need to split C and I etc
    y = [y; mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,4),'omitnan')/mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,3),'omitnan')];
    stderr=[stderr; std( ...
        resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,4) ...
        ./resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,3),'omitnan') ...
        /sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,4)))];
    
end
% convert/display as %
y=y.*100;
stderr=stderr.*100;
b = bar(y, 'FaceColor','flat');
       
set(gca, 'box', 'off');
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%title_text = {'Accuracy When Changing Response Threshold'};
title_text = {''};
title(title_text);
b(1).FaceColor = [0.3 0.3 0.3];
  
hold on

xtipsall = b(1).XEndPoints;    
errorbar(xtipsall(:), y(:), stderr(:), 'k', 'LineStyle','none', 'HandleVisibility','off');

set(gca, 'Ticklength', [0 0]);
% can change these values depending on what need
bar_label = {'0.65', '0.70', '0.75', '0.80', '0.85'};
xticklabels(bar_label);
xtickangle(0);
xlabel('Response Threshold');
        
%set(gca,'FontName','Calibri');
set(gca,'FontName','Arial');
set(gca,'FontSize',12);
set(gcf, 'Color', 'w');

ylabel(y_label);

savefig('ChgThreshold.fig');
f = gcf;
exportgraphics(f, 'ChgThreshold.tif', 'Resolution', 600);

hold off;
    