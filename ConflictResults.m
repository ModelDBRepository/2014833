% Class to generate a line plot of the amount of conflict (energy) in the response
% layer at each timestep.
% Author: Angela Rose

classdef ConflictResults< handle
    
    properties (Constant)
 
    end
    
    properties (Access = public)
        plotConflict = false;
        arrResultsIdx;
        arrResults = NaN(5000,8);        %damageType, ANN, N1, N2, P1, P2, timestep, conflict/energy in response layer
    end
    
    %constructor
    methods (Access = public)
        
        function CR = ConflictResults()
            CR.arrResultsIdx = 0;
            CR.plotConflict = false;
        end
        
        function plotTimestepConflict(CR, damageTypeArr, stroopN1, stroopN2, stroopP1, stroopP2)
            figure;
            hold on;
            y_label = {'Energy'};
            numSim = 0;
            x = [];
            y = [];
            xstderr = [];
            ystderr = [];
            stderr = [];
            for sim=damageTypeArr
                numSim = numSim + 1;
                maxTimestep = max(CR.arrResults(CR.arrResults(:,1)==sim & CR.arrResults(:,3)== stroopN1 & CR.arrResults(:,4)== stroopN2 ...
                    & CR.arrResults(:,5)== stroopP1 & CR.arrResults(:,6)== stroopP2, 7));
                for timestep = 1:maxTimestep     
                    x = [x; timestep];
                    y = [y; mean(CR.arrResults(CR.arrResults(:,1)==sim & CR.arrResults(:,3)== stroopN1 & CR.arrResults(:,4)== stroopN2 ...
                        & CR.arrResults(:,5)== stroopP1 & CR.arrResults(:,6)== stroopP2 & CR.arrResults(:,7)== timestep, 8),'omitnan')];
                    stderr = [stderr; std(CR.arrResults(CR.arrResults(:,1)==sim & CR.arrResults(:,3)== stroopN1 & CR.arrResults(:,4)== stroopN2 ...
                        & CR.arrResults(:,5)== stroopP1 & CR.arrResults(:,6)== stroopP2 & CR.arrResults(:,7)== timestep, 8),'omitnan')/sqrt(length(CR.arrResults(CR.arrResults(:,1)==sim & CR.arrResults(:,3)== stroopN1 & CR.arrResults(:,4)== stroopN2 ...
                        & CR.arrResults(:,5)== stroopP1 & CR.arrResults(:,6)== stroopP2 & CR.arrResults(:,7)== timestep)))];
                end
   
                switch numSim
                    case 1
                        lineStyle = '-';
                    case 2
                        lineStyle = ':';
                end
                
                % hardcode reduce amount of error bars on graph
                xstderr = x;
                ystderr = y;
                if (stroopN1 == 1 & stroopN2 == 2 & stroopP1 == 8 & stroopP2 == 2)
                    %incongruent
                    for idx=18:-2:1
                        if idx == 18
                            [nrows,~]=size(x);
                            if (nrows < 18)
                                continue
                            end
                        end
                        xstderr(idx) = [];
                        ystderr(idx) = [];
                        stderr(idx) = [];
                    end
                end
                
                errorbar(xstderr,ystderr,stderr(:), 'k', 'LineStyle', 'none', 'HandleVisibility','off');
                plot(x, y, 'k', 'LineStyle', lineStyle); 
                x = [];
                y = [];
                xstderr = [];
                ystderr = [];
                stderr = [];
            end    
            
            set(gca, 'box', 'off');
            ax = gca;
            ax.TitleHorizontalAlignment = 'left';  %left justify title
      
            if (stroopP1 == 0 && stroopP2 ==0)  %placeholder for number comparison
                title_text = {''};
            else
                %numerical Stroop
                if ((stroopN1 < stroopN2 && stroopP1 < stroopP2) || ...
                    (stroopN1 > stroopN2 && stroopP1 > stroopP2))
                    % Congruent trial              
                    title_text = {'A) Congruent Stimulus'};
                    xlim([0,8]);
                    xticks([0 2 4 6 8]);
                    xticklabels({'0' '2' '4' '6' '8'});
                    ylim([0,0.15]);
                    file_name = 'Conflict_Cong_LMAHMA.fig';
                    file_name_tif = 'Conflict_Cong_LMAHMA.tif';
                else
                    % Incongruent trial
                    title_text = {'B) Incongruent Stimulus'};
                    xlim([0,19]);
                    ylim([0,0.5]);
                    yticks([0 0.1 0.2 0.3 0.4 0.5]);
                    yticklabels({'0' '0.1' '0.2' '0.3' '0.4' '0.5'});
                    file_name = 'Conflict_Incong_LMAHMA.fig';
                    file_name_tif = 'Conflict_Incong_LMAHMA.tif';
                end
            end
            title(title_text);
                
            xtickangle(0);
            xlabel('Simulated Time Step');
   
            set(gca,'FontName','Arial');
            set(gca,'FontSize',12);
            set(gcf, 'Color', 'w');
                      
            ylabel(y_label);

            % display label after both plots done
            legend_label = {'Low Math-Anxious', 'High Math-Anxious'};
            lgd = legend(legend_label, 'FontSize', 12);
            lgd.ItemTokenSize = [10,10];   
            legend('Location','northwest');
            legend('boxoff');
            savefig(file_name);
            f = gcf;
            exportgraphics(f, file_name_tif, 'Resolution', 600);
            hold off;
        end
        
    end
    
end
