% Script to generate bar graph of the size effect (LMA, HMA) for response times
% for number pairs of 1 & 2, 2 & 1, and 8 & 9, 9 & 8. Size effect is
% for number comparison task, not numerical Stroop.
% Author: Angela Rose
  
%if (taskType == 2)
figure;
bar_label = {'Small', 'Large'};
y_label = {'Simulated Mean Response Time'};
y = [mean(resultsANNMatrix(1:numTestANN,44),'omitnan'), mean(resultsANNMatrix(numTestANN+1:numTestANN*2,44),'omitnan'); mean(resultsANNMatrix(1:numTestANN,45),'omitnan'), mean(resultsANNMatrix(numTestANN+1:numTestANN*2,45),'omitnan')];
%stderr=[std(resultsANNMatrix(1:numTestANN,44),'omitnan')/sqrt(length(resultsANNMatrix(1:numTestANN,44))), std(resultsANNMatrix(numTestANN+1:numTestANN*2,44),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN+1:numTestANN*2,44))); std(resultsANNMatrix(1:numTestANN,45),'omitnan')/sqrt(length(resultsANNMatrix(1:numTestANN,45))), std(resultsANNMatrix(numTestANN+1:numTestANN*2,45),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN+1:numTestANN*2,45)))];
% Have changed the denominator calculation here as it has NaN elements in it
% this is the only SEM calculation that has NaN elements in it, 
% and is due to using a smaller data set. This could be updated for the rest of
% the SEM calculations if needed.
stderr=[std(resultsANNMatrix(1:numTestANN,44),'omitnan')/sqrt(sum(~isnan(resultsANNMatrix(1:numTestANN,44)))), std(resultsANNMatrix(numTestANN+1:numTestANN*2,44),'omitnan')/sqrt(sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,44)))); std(resultsANNMatrix(1:numTestANN,45),'omitnan')/sqrt(sum(~isnan(resultsANNMatrix(1:numTestANN,45)))), std(resultsANNMatrix(numTestANN+1:numTestANN*2,45),'omitnan')/sqrt(sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,45))))];
b = bar(y, 'FaceColor','flat', 'BaseValue', 6);
    
title_text = {'The Size Effect'};
set(gca, 'box', 'off');  
ax = gca;
title(title_text);
axis square;
    
b(1).FaceColor = [1 1 1]; 
b(2).FaceColor = [0.3 0.3 0.3]; 

lgd = legend('Low Math-Anxious', 'High Math-Anxious', 'FontSize', 12);
lgd.ItemTokenSize = [10,10]; 
legend('Location','northwest');  
legend('boxoff'); 
hold on

xtipsall = (get(b(1),'XData') + cell2mat(get(b,'XOffset'))).';   
errorbar(xtipsall(:), y(:), stderr(:), 'k', 'LineStyle','none', 'HandleVisibility','off');

set(gca, 'Ticklength', [0 0])  
xticklabels(bar_label);
xtickangle(0);

set(gca,'FontName','Arial');
set(gca,'FontSize',12);
set(gcf, 'Color', 'w'); %background colour to white

ylabel(y_label); 
xlabel('Numerical Size');

savefig('RT_Size_LMAHMA.fig');
f = gcf;
exportgraphics(f, 'RT_Size_LMAHMA.tif', 'Resolution', 600);
    
hold off;
 