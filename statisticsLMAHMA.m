% Script to calculate statistics for LMA vs HMA
% Author: Angela Rose

% in resultsANNMatrix, LMA (damage=0) is first then HMA is next (as per the order of damageTypeArr). 
% i.e. LMA = resultsANNMatrix(1:numTestANN,9);  HMA=resultsANNMatrix(numTestANN+1:numTestANN*2,9);
% col 8 = % Hits SCE, col 9 = Congruent RT, col 10 = Incongruent RT, col
% 11 = SCE RT
fprintf('\nSTATISTICS SUMMARY LMA vs HMA: \n');
fprintf('if h=0 Do not reject the null hypothesis; if h=1 Reject: \n\n');
if (taskType == 2)
    fprintf('Number comparison task: data is in congruent column/field \n\n');
end

[h3_L_meanANNCong, p3_L_meanANNCong] = kstest(resultsANNMatrix(1:numTestANN,9));
[h3_H_meanANNCong, p3_H_meanANNCong] = kstest(resultsANNMatrix(numTestANN+1:numTestANN*2,9));
fprintf('ks normality test for Congruent RT LMA: h=%d, p=%f \n', h3_L_meanANNCong, p3_L_meanANNCong);
fprintf('ks normality test for Congruent RT HMA: h=%d, p=%f \n', h3_H_meanANNCong, p3_H_meanANNCong);

[h_meanANNCong, p_meanANNCong, ci_meanANNCong, stats_meanANNCong] = ttest2(resultsANNMatrix(1:numTestANN,9),resultsANNMatrix(numTestANN+1:numTestANN*2,9), 'Tail','both');
[p2_meanANNCong, h2_meanANNCong, stats2_meanANNCong] = ranksum(resultsANNMatrix(1:numTestANN,9),resultsANNMatrix(numTestANN+1:numTestANN*2,9), 'Tail','both');
fprintf('independent (2-sample) t-test: Congruent RT Alt H: LMA <> HMA: h=%d, t(%d)=%f, p=%f \n', h_meanANNCong, stats_meanANNCong.df, stats_meanANNCong.tstat, p_meanANNCong);
fprintf('Mann-Whitney equivalent test: Congruent RT Alt H: LMA <> HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_meanANNCong, p2_meanANNCong, stats2_meanANNCong.zval, stats2_meanANNCong.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,9))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,9))));
[h_meanANNCong, p_meanANNCong, ci_meanANNCong, stats_meanANNCong] = ttest2(resultsANNMatrix(1:numTestANN,9),resultsANNMatrix(numTestANN+1:numTestANN*2,9), 'Tail','left');
[p2_meanANNCong, h2_meanANNCong, stats2_meanANNCong] = ranksum(resultsANNMatrix(1:numTestANN,9),resultsANNMatrix(numTestANN+1:numTestANN*2,9), 'Tail','left');
fprintf('independent (2-sample) t-test: Congruent RT Alt H: LMA < HMA: h=%d, t(%d)=%f, p=%f \n', h_meanANNCong, stats_meanANNCong.df, stats_meanANNCong.tstat, p_meanANNCong);
fprintf('Mann-Whitney equivalent test: Congruent RT Alt H: LMA < HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_meanANNCong, p2_meanANNCong, stats2_meanANNCong.zval, stats2_meanANNCong.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,9))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,9))));

% Hits Cong is column 6 - for single-digit number comparison task all
% trials are stored in Congruent field, and errors are 100- %Hits.
[h3_L_hitsANNPercentCong, p3_L_hitsANNPercentCong] = kstest(resultsANNMatrix(1:numTestANN,6));
[h3_H_hitsANNPercentCong, p3_H_hitsANNPercentCong] = kstest(resultsANNMatrix(numTestANN+1:numTestANN*2,6));
fprintf('ks normality test for %% Hits Cong LMA: h=%d, p=%f \n', h3_L_hitsANNPercentCong, p3_L_hitsANNPercentCong);
fprintf('ks normality test for %% Hits Cong HMA: h=%d, p=%f \n', h3_H_hitsANNPercentCong, p3_H_hitsANNPercentCong);

[h_hitsANNPercentCong, p_hitsANNPercentCong, ci_hitsANNPercentCong, stats_hitsANNPercentCong] = ttest2(resultsANNMatrix(1:numTestANN,6),resultsANNMatrix(numTestANN+1:numTestANN*2,6), 'Tail','both');
[p2_hitsANNPercentCong, h2_hitsANNPercentCong, stats2_hitsANNPercentCong] = ranksum(resultsANNMatrix(1:numTestANN,6),resultsANNMatrix(numTestANN+1:numTestANN*2,6), 'Tail','both');
fprintf('independent (2-sample) t-test: %% Hits Cong Alt H: LMA <> HMA: h=%d, t(%d)=%f, p=%f \n', h_hitsANNPercentCong, stats_hitsANNPercentCong.df, stats_hitsANNPercentCong.tstat, p_hitsANNPercentCong);
fprintf('Mann-Whitney equivalent test: %% Hits Cong Alt H: LMA <> HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_hitsANNPercentCong, p2_hitsANNPercentCong, stats2_hitsANNPercentCong.zval, stats2_hitsANNPercentCong.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,6))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,6))));

% size effect only valid for number comparison task 
if displaySizeEffect
    % Size effect checking (8,9)(9,8) - (1,2)(2,1) ie the SCE / interference effect.
    [h3_L_meanANNSizeSCE, p3_L_meanANNSizeSCE] = kstest(resultsANNMatrix(1:numTestANN,45) - resultsANNMatrix(1:numTestANN,44));
    [h3_H_meanANNSizeSCE, p3_H_meanANNSizeSCE] = kstest(resultsANNMatrix(numTestANN+1:numTestANN*2,45) - resultsANNMatrix(numTestANN+1:numTestANN*2,44));
    fprintf('ks normality test for Size Effect SCE RT (Large(8,9;9,8) - Small(1,2;2,1)) RT LMA: h=%d, p=%f \n', h3_L_meanANNSizeSCE, p3_L_meanANNSizeSCE);
    fprintf('ks normality test for Size Effect SCE RT HMA: h=%d, p=%f \n', h3_H_meanANNSizeSCE, p3_H_meanANNSizeSCE);

    [h_meanANNSizeSCE, p_meanANNSizeSCE, ci_meanANNSizeSCE, stats_meanANNSizeSCE] = ttest2(resultsANNMatrix(1:numTestANN,45) - resultsANNMatrix(1:numTestANN,44),resultsANNMatrix(numTestANN+1:numTestANN*2,45) - resultsANNMatrix(numTestANN+1:numTestANN*2,44), 'Tail','both');
    [p2_meanANNSizeSCE, h2_meanANNSizeSCE, stats2_meanANNSizeSCE] = ranksum(resultsANNMatrix(1:numTestANN,45) - resultsANNMatrix(1:numTestANN,44),resultsANNMatrix(numTestANN+1:numTestANN*2,45) - resultsANNMatrix(numTestANN+1:numTestANN*2,44), 'Tail','both');
    fprintf('independent (2-sample) t-test: Size Effect SCE RT Alt H: LMA <> HMA: h=%d, t(%d)=%f, p=%f \n', h_meanANNSizeSCE, stats_meanANNSizeSCE.df, stats_meanANNSizeSCE.tstat, p_meanANNSizeSCE);
    fprintf('Mann-Whitney equivalent test: Size Effect SCE RT Alt H: LMA <> HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_meanANNSizeSCE, p2_meanANNSizeSCE, stats2_meanANNSizeSCE.zval, stats2_meanANNSizeSCE.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,45) - resultsANNMatrix(1:numTestANN,44))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,45) - resultsANNMatrix(numTestANN+1:numTestANN*2,44))));
    [h_meanANNSizeSCE, p_meanANNSizeSCE, ci_meanANNSizeSCE, stats_meanANNSizeSCE] = ttest2(resultsANNMatrix(1:numTestANN,45) - resultsANNMatrix(1:numTestANN,44),resultsANNMatrix(numTestANN+1:numTestANN*2,45) - resultsANNMatrix(numTestANN+1:numTestANN*2,44), 'Tail','left');
    [p2_meanANNSizeSCE, h2_meanANNSizeSCE, stats2_meanANNSizeSCE] = ranksum(resultsANNMatrix(1:numTestANN,45) - resultsANNMatrix(1:numTestANN,44),resultsANNMatrix(numTestANN+1:numTestANN*2,45) - resultsANNMatrix(numTestANN+1:numTestANN*2,44), 'Tail','left');
    fprintf('independent (2-sample) t-test: Size Effect SCE RT Alt H: LMA < HMA: h=%d, t(%d)=%f, p=%f \n', h_meanANNSizeSCE, stats_meanANNSizeSCE.df, stats_meanANNSizeSCE.tstat, p_meanANNSizeSCE);
    fprintf('Mann-Whitney equivalent test: Size Effect SCE RT Alt H: LMA < HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_meanANNSizeSCE, p2_meanANNSizeSCE, stats2_meanANNSizeSCE.zval, stats2_meanANNSizeSCE.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,45) - resultsANNMatrix(1:numTestANN,44))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,45) - resultsANNMatrix(numTestANN+1:numTestANN*2,44))));
end

%Stroop tests
if (taskType == 1)
    %Incongruent RT
    [h3_L_meanANNIncong, p3_L_meanANNIncong] = kstest(resultsANNMatrix(1:numTestANN,10));
    [h3_H_meanANNIncong, p3_H_meanANNIncong] = kstest(resultsANNMatrix(numTestANN+1:numTestANN*2,10));
    fprintf('ks normality test for Incongruent RT LMA: h=%d, p=%f \n', h3_L_meanANNIncong, p3_L_meanANNIncong);
    fprintf('ks normality test for Incongruent RT HMA: h=%d, p=%f \n', h3_H_meanANNIncong, p3_H_meanANNIncong);
    [h_meanANNIncong, p_meanANNIncong, ci_meanANNIncong, stats_meanANNIncong] = ttest2(resultsANNMatrix(1:numTestANN,10),resultsANNMatrix(numTestANN+1:numTestANN*2,10), 'Tail','both');
    [p2_meanANNIncong, h2_meanANNIncong, stats2_meanANNIncong] = ranksum(resultsANNMatrix(1:numTestANN,10),resultsANNMatrix(numTestANN+1:numTestANN*2,10), 'Tail','both');
    fprintf('independent (2-sample) t-test: Incongruent RT Alt H: LMA <> HMA: h=%d, t(%d)=%f, p=%f \n', h_meanANNIncong, stats_meanANNIncong.df, stats_meanANNIncong.tstat, p_meanANNIncong);
    fprintf('Mann-Whitney equivalent test: Incongruent RT Alt H: LMA <> HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_meanANNIncong, p2_meanANNIncong, stats2_meanANNIncong.zval, stats2_meanANNIncong.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,10))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,10))));
    [h_meanANNIncong, p_meanANNIncong, ci_meanANNIncong, stats_meanANNIncong] = ttest2(resultsANNMatrix(1:numTestANN,10),resultsANNMatrix(numTestANN+1:numTestANN*2,10), 'Tail','left');
    [p2_meanANNIncong, h2_meanANNIncong, stats2_meanANNIncong] = ranksum(resultsANNMatrix(1:numTestANN,10),resultsANNMatrix(numTestANN+1:numTestANN*2,10), 'Tail','left');
    fprintf('independent (2-sample) t-test: Incongruent RT Alt H: LMA < HMA: h=%d, t(%d)=%f, p=%f \n', h_meanANNIncong, stats_meanANNIncong.df, stats_meanANNIncong.tstat, p_meanANNIncong);
    fprintf('Mann-Whitney equivalent test: Incongruent RT Alt H: LMA < HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_meanANNIncong, p2_meanANNIncong, stats2_meanANNIncong.zval, stats2_meanANNIncong.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,10))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,10))));
           
    %SCE RT
    [h3_L_meanANNSCE, p3_L_meanANNSCE] = kstest(resultsANNMatrix(1:numTestANN,11));
    [h3_H_meanANNSCE, p3_H_meanANNSCE] = kstest(resultsANNMatrix(numTestANN+1:numTestANN*2,11));
    fprintf('ks normality test for SCE RT LMA: h=%d, p=%f \n', h3_L_meanANNSCE, p3_L_meanANNSCE);
    fprintf('ks normality test for SCE RT HMA: h=%d, p=%f \n', h3_H_meanANNSCE, p3_H_meanANNSCE);
    [h_meanANNSCE, p_meanANNSCE, ci_meanANNSCE, stats_meanANNSCE] = ttest2(resultsANNMatrix(1:numTestANN,11),resultsANNMatrix(numTestANN+1:numTestANN*2,11), 'Tail','both');
    [p2_meanANNSCE, h2_meanANNSCE, stats2_meanANNSCE] = ranksum(resultsANNMatrix(1:numTestANN,11),resultsANNMatrix(numTestANN+1:numTestANN*2,11), 'Tail','both');
    fprintf('independent (2-sample) t-test: SCE RT Alt H: LMA <> HMA: h=%d, t(%d)=%f, p=%f \n', h_meanANNSCE, stats_meanANNSCE.df, stats_meanANNSCE.tstat, p_meanANNSCE);
    fprintf('Mann-Whitney equivalent test: SCE RT Alt H: LMA <> HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_meanANNSCE, p2_meanANNSCE, stats2_meanANNSCE.zval, stats2_meanANNSCE.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,11))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,11))));
    [h_meanANNSCE, p_meanANNSCE, ci_meanANNSCE, stats_meanANNSCE] = ttest2(resultsANNMatrix(1:numTestANN,11),resultsANNMatrix(numTestANN+1:numTestANN*2,11), 'Tail','left');
    [p2_meanANNSCE, h2_meanANNSCE, stats2_meanANNSCE] = ranksum(resultsANNMatrix(1:numTestANN,11),resultsANNMatrix(numTestANN+1:numTestANN*2,11), 'Tail','left');
    fprintf('independent (2-sample) t-test: SCE RT Alt H: LMA < HMA: h=%d, t(%d)=%f, p=%f \n', h_meanANNSCE, stats_meanANNSCE.df, stats_meanANNSCE.tstat, p_meanANNSCE);
    fprintf('Mann-Whitney equivalent test: SCE RT Alt H: LMA < HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_meanANNSCE, p2_meanANNSCE, stats2_meanANNSCE.zval, stats2_meanANNSCE.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,11))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,11))));

    %SCE %Hits
    [h3_L_hitsANNPercentSCE, p3_L_hitsANNPercentSCE] = kstest(resultsANNMatrix(1:numTestANN,8));
    [h3_H_hitsANNPercentSCE, p3_H_hitsANNPercentSCE] = kstest(resultsANNMatrix(numTestANN+1:numTestANN*2,8));
    fprintf('ks normality test for SCE %% Hits LMA: h=%d, p=%f \n', h3_L_hitsANNPercentSCE, p3_L_hitsANNPercentSCE);
    fprintf('ks normality test for SCE %% Hits HMA: h=%d, p=%f \n', h3_H_hitsANNPercentSCE, p3_H_hitsANNPercentSCE);
    [h_hitsANNPercentSCE, p_hitsANNPercentSCE, ci_hitsANNPercentSCE, stats_hitsANNPercentSCE] = ttest2(resultsANNMatrix(1:numTestANN,8),resultsANNMatrix(numTestANN+1:numTestANN*2,8), 'Tail','both');
    [p2_hitsANNPercentSCE, h2_hitsANNPercentSCE, stats2_hitsANNPercentSCE] = ranksum(resultsANNMatrix(1:numTestANN,8),resultsANNMatrix(numTestANN+1:numTestANN*2,8), 'Tail','both');
    fprintf('independent (2-sample) t-test: %% Hits SCE Alt H: LMA <> HMA: h=%d, t(%d)=%f, p=%f \n', h_hitsANNPercentSCE, stats_hitsANNPercentSCE.df, stats_hitsANNPercentSCE.tstat, p_hitsANNPercentSCE);
    fprintf('Mann-Whitney equivalent test: %% Hits SCE Alt H: LMA <> HMA: h=%d, p=%f, stats.zval=%f, stats.ranksum U=%f, n1=%d, n2=%d \n\n', h2_hitsANNPercentSCE, p2_hitsANNPercentSCE, stats2_hitsANNPercentSCE.zval, stats2_hitsANNPercentSCE.ranksum, sum(~isnan(resultsANNMatrix(1:numTestANN,8))), sum(~isnan(resultsANNMatrix(numTestANN+1:numTestANN*2,8))));  
end