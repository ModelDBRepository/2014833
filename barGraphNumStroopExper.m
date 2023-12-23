% Script generates bar graph of Suarez et al. (2014) experimental results.
% Author: Angela Rose

figure;
       
% RTs Congruent (LMA, HMA), Incongruent (LMA, HMA), Size Congruity Effect (LMA, HMA):
%{
bar_label = {'Congruent', 'Incongruent', 'Size Congruity Effect'}
y_label = {'Simulated Mean Response Time'};
y = [327, 346; 379, 418; 52.02, 72.5];
stderr = [8.32, 10.64; 10.76, 14.70; 5.30, 8.15];
b = bar(y, 'FaceColor','flat');
title_text = {'A) Experimental'};
%}
        
% mean of medians RT Congruent (LMA, HMA), Incongruent (LMA, HMA):
        
bar_label = {'Congruent', 'Incongruent'};
y_label = {'Response Time'};
y = [327, 346; 379, 418];
stderr = [8.32, 10.64; 10.76, 14.70];
b = bar(y, 'FaceColor','flat', 'BaseValue', 200);   %[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
title_text = {'A) Experimental:', 'Suárez-Pellicioni et al. (2014)'};
        
        
set(gca, 'box', 'off');
ax = gca;
ax.TitleHorizontalAlignment = 'left';  
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

set(gca, 'Ticklength', [0 0]);
xticklabels(bar_label);
xtickangle(0); 

set(gca,'FontName','Arial');
set(gca,'FontSize',12);
set(gcf, 'Color', 'w');

ylabel(y_label); 

savefig('RT_C_I_LMAHMA_Suarez.fig');
f = gcf;
exportgraphics(f, 'RT_C_I_LMAHMA_Suarez.tif', 'Resolution', 600);
    

hold off;