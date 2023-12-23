% Script to generate bar graph of different number of learning trials.
% Author: Angela Rose

% Graph for learning trials by RT (and for Congruent and Incongruent)
figure;
y_label = {'Simulated Mean Response Time'};
numSim = size(damageTypeArr, 2);   %number columns in array = number types of simulation runs/damages
y = [];
stderr = [];
bar_label = {};
for simCnt = 1:numSim
    switch taskType
        case 1
            y = [y; mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,9),'omitnan'), mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,10),'omitnan')];
            stderr=[stderr; std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,9),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,9))), std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,10),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,10)))];
        case 2
            % No C or I for number comparison, but data is stored in C
            % column
            y = [y; mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,9),'omitnan')];
            stderr=[stderr; std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,9),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,9)))];     
    end
        
    if (labelNumLearningTrials)
        %label x-axis with number learning trials, which is the number of
        %the simulation/damageType eg damageTypeArr = [17000 18000]
        % note: could not get xtickformat to work, so use function
        bar_label(1,simCnt) = formatNumAddComma(damageTypeArr(simCnt));
    end
end
 
b = bar(y, 'FaceColor','flat');
        
set(gca, 'box', 'off');
ax = gca;
ax.TitleHorizontalAlignment = 'left'; 
%title_text = {'A) The Effect of Changing the Number of', 'Learning Trials on the Response Time'};
title_text = {'A'};
title(title_text);
    
switch taskType
    case 1
        b(1).FaceColor = [1 1 1]; 
        b(2).FaceColor = [0.3 0.3 0.3];
    case 2
        b(1).FaceColor = [0.3 0.3 0.3]; 
end
    
if (taskType == 1)
    lgd = legend('Congruent', 'Incongruent', 'FontSize', 12, 'Orientation','horizontal');
    lgd.ItemTokenSize = [10,10];  
    legend('boxoff');
end
    
hold on

switch taskType
    case 1
        xtipsall = (get(b(1),'XData') + cell2mat(get(b,'XOffset'))).';  
    case 2
        xtipsall = b(1).XEndPoints; 
end

errorbar(xtipsall(:), y(:), stderr(:), 'k', 'LineStyle','none', 'HandleVisibility','off');

set(gca, 'Ticklength', [0 0]);

xticklabels(bar_label);
xtickangle(90);
xlabel('Number of Learning Trials'); 

if (taskType == 1)
    % This is for the RTs
    % The legend doesn't fit properly so have extended y-axis by setting
    % ylim, yticks, yticklabels to give room for it to display at top
    ylim([0 18]);   %Alternative to using BaseValue as starting value on y-axis. Sets y-axis range.
    yticks([0 2 4 6 8 10 12 14 16]);
    yticklabels({'0' '2' '4' '6' '8' '10' '12' '14' '16'});
end
   
%set(gca,'FontName','Calibri');
set(gca,'FontName','Arial');
set(gca,'FontSize',12);
set(gcf, 'Color', 'w');

ylabel(y_label);

savefig('LearnTrials_RT.fig');
f = gcf;
exportgraphics(f, 'LearnTrials_RT.tif', 'Resolution', 600);

hold off;
   
% Bar graph of number of learning trials by RT for SCE for numerical Stroop
if (taskType == 1)
    figure;
    y_label = {'Size Congruity Response Time'};
    numSim = size(damageTypeArr, 2);   %number columns in array = number types of simulation runs/damages
    y = [];
    stderr = [];
    bar_label = {};
    for simCnt = 1:numSim
        y = [y; mean(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,11),'omitnan')];
        stderr=[stderr; std(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,11),'omitnan')/sqrt(length(resultsANNMatrix(numTestANN*(simCnt-1)+1:numTestANN *simCnt,11)))];
              
        if (labelNumLearningTrials)
            bar_label(1,simCnt) = formatNumAddComma(damageTypeArr(simCnt));
        end
    end
 
    b = bar(y, 'FaceColor','flat');
       
    set(gca, 'box', 'off');
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
    title_text = {'A'}; 
    title(title_text);
   
    b(1).FaceColor = [0.3 0.3 0.3]; 
    
    hold on

    xtipsall = b(1).XEndPoints;
    errorbar(xtipsall(:), y(:), stderr(:), 'k', 'LineStyle','none', 'HandleVisibility','off');

    set(gca, 'Ticklength', [0 0]);
    xticklabels(bar_label);
    xtickangle(90);
    xlabel('Number of Learning Trials');
    
    %set(gca,'FontName','Calibri');
    set(gca,'FontName','Arial');
    set(gca,'FontSize',12);
    set(gcf, 'Color', 'w');

    ylabel(y_label);  
    
    savefig('LearnTrials_SCE_RT.fig');
    f = gcf;
    exportgraphics(f, 'LearnTrials_SCE_RT.tif', 'Resolution', 600);

    hold off;
   
end

% Bar graph of number of learning trials by accuracy
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
        
    if (labelNumLearningTrials)
        bar_label(1,simCnt) = formatNumAddComma(damageTypeArr(simCnt));
    end
end

% convert/display as %
y=y.*100;
stderr=stderr.*100;
b = bar(y, 'FaceColor','flat');
        
set(gca, 'box', 'off');
ax = gca;
ax.TitleHorizontalAlignment = 'left';
%title_text = {'B) The Effect of Changing the Number of', 'Learning Trials on Accuracy'};
title_text = {'B'};
title(title_text);
b(1).FaceColor = [0.3 0.3 0.3]; 
   
hold on

xtipsall = b(1).XEndPoints;
% cell2mat etc does not work here. Works elsewhere though.
errorbar(xtipsall(:), y(:), stderr(:), 'k', 'LineStyle','none', 'HandleVisibility','off');

set(gca, 'Ticklength', [0 0]);
% can change these values depending on what need
if ~labelNumLearningTrials
    bar_label = {'LMA','HMA'};
end
xticklabels(bar_label);
if labelNumLearningTrials
    xtickangle(90);
    xlabel('Number of Learning Trials');
else
    xtickangle(0);
    xlabel('Xxtra X Label');
end

%set(gca,'FontName','Calibri');
set(gca,'FontName','Arial');
set(gca,'FontSize',12);
set(gcf, 'Color', 'w');

ylabel(y_label);

savefig('LearnTrials_errors.fig');
f = gcf;
exportgraphics(f, 'LearnTrials_errors.tif', 'Resolution', 600);

hold off;
    