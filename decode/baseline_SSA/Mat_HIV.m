%========
% Script for analyzing the HIV example
%========

%=====
% The basic data defining the CTMC for the HIV example
%=====
if 1
    % State definitions
    States = {'wild type','G190S','G190E','G190A','Y188L','Y188L,G190E','K103N','K103N, P225H','K103N,G190A','K103N,Y188H','K103N,V108I','K103N,V106M','K101E','K101E,G190S','K101Q','K101Q,G190S','K101Q,K103N','L100I,K103N','L100I,K103N,P225H'};
    
    % Dwell time parameters
    L = [   6.1475e-03   8.2645e-03            0   1.8182e-02            0   3.4483e-02   3.8809e-03   1.5767e-03            0            0   1.0050e-03            0   1.4286e-02            0   1.4085e-02            0   8.8417e-04   2.7422e-03            0];
    
    % Transition probabilities
    T = [            0   4.4444e-02   2.2222e-02   1.1111e-02   4.4444e-02            0   8.7778e-01            0            0            0            0            0            0            0            0            0            0            0            0
        4.0000e-01            0            0            0            0            0            0            0            0            0            0            0            0   4.0000e-01            0   2.0000e-01            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        1.0000e+00            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0   1.0000e+00            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        1.3043e-01            0            0            0            0            0            0   3.9130e-01   2.1739e-02   2.1739e-02   2.3913e-01   2.1739e-02            0            0            0            0   8.6957e-02   8.6957e-02            0
        0            0            0            0            0            0   1.0000e+00            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0   1.0000e+00            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        1.0000e+00            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0   1.0000e+00            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0   1.0000e+00            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0   6.6667e-01            0            0            0            0            0            0            0            0            0            0            0   3.3333e-01
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0];
    
    % Rate matrix
    Q = [  -6.1475e-03   2.7322e-04   1.3661e-04   6.8306e-05   2.7322e-04            0   5.3962e-03            0            0            0            0            0            0            0            0            0            0            0            0
        3.3058e-03  -8.2645e-03            0            0            0            0            0            0            0            0            0            0            0   3.3058e-03            0   1.6529e-03            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        1.8182e-02            0            0  -1.8182e-02            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0   3.4483e-02  -3.4483e-02            0            0            0            0            0            0            0            0            0            0            0            0            0
        5.0620e-04            0            0            0            0            0  -3.8809e-03   1.5186e-03   8.4367e-05   8.4367e-05   9.2804e-04   8.4367e-05            0            0            0            0   3.3747e-04   3.3747e-04            0
        0            0            0            0            0            0   1.5767e-03  -1.5767e-03            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0   1.0050e-03            0            0            0  -1.0050e-03            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        1.4286e-02            0            0            0            0            0            0            0            0            0            0            0  -1.4286e-02            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0  -1.4085e-02            0   1.4085e-02            0            0
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0
        0            0            0            0            0            0   8.8417e-04            0            0            0            0            0            0            0            0            0  -8.8417e-04            0            0
        0            0            0            0            0            0   1.8282e-03            0            0            0            0            0            0            0            0            0            0  -2.7422e-03   9.1408e-04
        0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0            0];
end

%======
% Make an OSS-problem data structure
%======

if 1
    SSAProb.L = L;
    SSAProb.T = T;
    SSAProb.Starts = 1;
    SSAProb.Time = 10*365.25; % Unit of days
    SSAProb.MaxDom = 0;
end

%=====
% Get the non-dominated optimal sequence(s)
%=====

if 1
    tic
    SSARes = StateSequenceAnalyze(SSAProb);
    SSATime = toc % Took 49.739576841000002 when I tried it
end

%======
% Plot the results
%======

if 1
    [MaxByTime,SeqList]= ExtractMaxSeqs(SSARes,SSARes.TimeGrid,1,ones(1,19),1);
end
if 1
    figure(2);
    clf;
    Colors = 'bgrcmyk';
    SeqList = SeqList([1 3 4 5 2],:);
    hold on;
    Leg = {};
    for i=1:length(SeqList)
        % Plot sequence probability
        h = plot(SSARes.TimeGrid/365.25,SSARes.Seqs{SeqList(i,1),SeqList(i,2)}{SeqList(i,3)}.p);
        set(h,'linewidth',3);
        set(h,'color',Colors(i));
        % Sequence name for legend
        Seq = SSARes.Seqs{SeqList(i,1),SeqList(i,2)}{SeqList(i,3)}.seq;
        Name = States{Seq(1)};
        for i=2:length(Seq);
            Name = [Name,' -> ',States{Seq(i)}];
        end
        Leg{end+1} = Name;
    end
    set(gca,'fontsize',18);
    xlabel('time (yrs)');
    ylabel('probability');
    legend(Leg,1);
    hold off;
end
