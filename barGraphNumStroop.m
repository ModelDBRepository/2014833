% Script to generate graphs for validation of the numerical Stroop
% simulations.
% Author: Angela Rose

if (taskType == 1)
    % graph all 8 conditions
    figure;
    bar_label = {'Congruent NumFar PhysFar', 'Congruent NumFar PhysClose', 'Congruent NumClose PhysFar', 'Congruent NumClose PhysClose', 'Incongruent NumFar PhysFar', 'Incongruent NumFar PhysClose', 'Incongruent NumClose PhysFar', 'Incongruent NumClose PhysClose'};
    bar([meanCongNumFarPhysFar, meanCongNumFarPhysClose, meanCongNumClosePhysFar, meanCongNumClosePhysClose, meanIncongNumFarPhysFar, meanIncongNumFarPhysClose, meanIncongNumClosePhysFar, meanIncongNumClosePhysClose]);
    title('Congruity & Numerical Distance & Physical Distance');
    xticklabels(bar_label);   
    xtickangle(90);   
    ylabel('Mean RT');
    savefig('Cong_All.fig');

    % congruity and numerical distance
    figure;
    bar_label = {'Congruent NumFar', 'Congruent NumClose', 'Incongruent NumFar', 'Incongruent NumClose'};
    bar([meanCongNumDistLarge, meanCongNumDistSmall, meanIncongNumDistLarge, meanIncongNumDistSmall]);
    title('Congruity & Numerical Distance');
    xticklabels(bar_label);
    xtickangle(90);
    ylabel('Mean RT');
    savefig('CongNum.fig');

    % congruity and physical distance
    figure;
    bar_label = {'Congruent PhysFar', 'Congruent PhysClose', 'Incongruent PhysFar', 'Incongruent PhysClose'};
    bar([meanCongPhysDistLarge, meanCongPhysDistSmall, meanIncongPhysDistLarge, meanIncongPhysDistSmall]);
    title('Congruity & Physical Distance');
    xticklabels(bar_label);
    xtickangle(90);
    ylabel('Mean RT');
    savefig('CongPhys.fig');

    % Congruity and phys distance
    figure;
    bar_label = {'Far', 'Far'; 'Close', 'Close'};
    y_label = {'Simulated Mean Response Time'};
    y = [mean(resultsANNMatrix(1:numTestANN,22),'omitnan'), mean(resultsANNMatrix(1:numTestANN,23),'omitnan'); mean(resultsANNMatrix(1:numTestANN,24),'omitnan'), mean(resultsANNMatrix(1:numTestANN,25),'omitnan') ];
    stderr=[std(resultsANNMatrix(1:numTestANN,22),'omitnan')/sqrt(length(resultsANNMatrix(1:numTestANN,22))), std(resultsANNMatrix(1:numTestANN,23),'omitnan')/sqrt(length(resultsANNMatrix(1:numTestANN,23))); std(resultsANNMatrix(1:numTestANN,24),'omitnan')/sqrt(length(resultsANNMatrix(1:numTestANN,24))), std(resultsANNMatrix(1:numTestANN,25),'omitnan')/sqrt(length(resultsANNMatrix(1:numTestANN,25)))];
    b = bar(y, 'FaceColor','flat', 'BaseValue', 6);
    
    set(gca, 'box', 'off');
    ax = gca;
    ax.TitleHorizontalAlignment = 'left';
    %title_text = {'Congruity & Physical Distance'};
    title_text = {'B'}; % for phys Stroop simulations
    title(title_text);
    axis square;
    
    b(1).FaceColor = [1 1 1]; 
    b(2).FaceColor = [0.3 0.3 0.3];

    lgd = legend('Congruent', 'Incongruent', 'FontSize', 12);
    lgd.ItemTokenSize = [10,10];
    legend('Location','northeast'); 
    legend('boxoff');
    hold on
    
    xtipsall = (get(b(1),'XData') + cell2mat(get(b,'XOffset'))).'; 
    errorbar(xtipsall(:), y(:), stderr(:), 'k', 'LineStyle','none', 'HandleVisibility','off');

    set(gca, 'Ticklength', [0 0]);  
    xticklabels(bar_label);
    xtickangle(0);
    
    %set(gca,'FontName','Calibri');
    set(gca,'FontName','Arial');
    set(gca,'FontSize',12);
    set(gcf, 'Color', 'w');

    ylabel(y_label);
    xlabel('Physical Distance');
    %%xlabel('Numerical Distance'); % for phys Stroop simulations with num/phys reversed

    savefig('RT_CongPhysDist.fig');
    f = gcf;
    exportgraphics(f, 'RT_CongPhysDist.tif', 'Resolution', 600);

    hold off;
     
    % numerical distance
    figure;
    bar_label = {'NumFar', 'NumClose'};
    bar([meanNumDistLarge, meanNumDistSmall]);
    title('Numerical Distance');
    xticklabels(bar_label);
    xtickangle(90);
    ylabel('Mean RT');
    savefig('Num.fig');

    % physical distance
    figure;
    bar_label = {'PhysFar', 'PhysClose'};
    bar([meanPhysDistLarge, meanPhysDistSmall]);
    title('Physical Distance');
    xticklabels(bar_label);
    xtickangle(90);
    ylabel('Mean RT');
    savefig('Phys.fig');

    % SCE by numerical distance
    figure;
    bar_label = {'NumFar', 'NumClose'};
    bar([meanSCENumDistLarge, meanSCENumDistSmall]);
    title('SCE Modulated by Numerical Distance');
    xticklabels(bar_label);
    xtickangle(90);
    ylabel('Mean RT');
    savefig('SCENum.fig');

    % SCE by physical distance
    figure;
    bar_label = {'PhysFar', 'PhysClose'};
    bar([meanSCEPhysDistLarge, meanSCEPhysDistSmall]);
    title('SCE Modulated by Physical Distance');
    xticklabels(bar_label);
    xtickangle(90);
    ylabel('Mean RT');
    savefig('SCEPhys.fig');

    % congruity
    figure;
    bar_label = {'Congruent', 'Incongruent'};
    bar([meanCong, meanIncong]);
    title('Congruity');
    xticklabels(bar_label);
    ylabel('Mean RT');
    savefig('Cong.fig');

end % taskType ==1 
    