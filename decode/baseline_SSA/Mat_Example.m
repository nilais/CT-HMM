%==========
% Mat_Example : A simple example chain, used for demonstrating State
% Sequence Analysis
%==========

% Make the chain
% if 1
%     States = {'1' '2' '3'};
%     Dwells = 1./[1 2 3];
%     Probs = [0 0.5 0.5
%         0 0 1
%         0.7 0.3 0];
% end

Q_mat = [-1 1; 0.5 -0.5];

if 1
    States = {'1' '2'};
    Dwells = [1 0.5];
    Probs = [0 1; 1 0];
end

%==========
% STATE SEQUENCE ANALYSIS 
%==========

% Make the optimization problem
if 1
    SSAProb.L = Dwells;
    SSAProb.T = Probs;
    SSAProb.Starts = 1;
    SSAProb.Time = 9;
    SSAProb.MaxDom = 0;
end

% Solve the optimization problem
if 1
    tic
    SSARes = StateSequenceAnalyze(SSAProb);
    SSATime = toc % Took 4.645360831000000 when I tried it
    
    
    StartStatesOrWeights = 1;
    EndStatesOrWeights = 2;
    TimesToDo = 9;
    MMostProbable = 1;
    
    [MaxSeqsByTime,SeqList] = ExtractMaxSeqs(SSARes,TimesToDo,StartStatesOrWeights,EndStatesOrWeights,MMostProbable);
       
    best_seq_idx = SeqList(1,3);
    best_seq = SSARes.Seqs{1,2}{best_seq_idx}.seq;
    best_prob = SSARes.Seqs{1,2}{best_seq_idx}.p(end);

    h = 1;
end

% Showing the non-dominated state sequences
if 1
    C = [0 0 1
        0 1 0
        1 0 0
        0 1 1
        1 0.5 0
        1 0 1
        0 0 0.5
        0 0.5 0
        0.5 0 0
        0 0.5 0.5
        0.5 0.25 0
        0.5 0 0.5];
    C = [C; rand(1000,3)];
    clf;
    %subplot(3,1,1:2);
    hold on;
    Leg = {};
    h = [];
    % Loop through all end states
    for End=1:length(States)
        for Seq=1:length(SSARes.Seqs{1,End})
            
            % Plot probablity of sequence
            h(end+1) = plot(SSARes.TimeGrid,SSARes.Seqs{1,End}{Seq}.p,'-');
            
            % Make sequence into string
            Str = '';
            for j=1:length(SSARes.Seqs{1,End}{Seq}.seq)
                Str = [Str,States{SSARes.Seqs{1,End}{Seq}.seq(j)}];
            end
            
            %Str = [Str,'(',num2str(SSARes.Seqs{1,End}{Seq}.ndom),')'];
            
            Leg{end+1} = Str;
                        
            %set(h(end),'color',rand(1,3));
            set(h(end),'color',C(length(h),:));
        end
    end
    
    set(h,'linewidth',5);
    set(gca,'fontsize',24);
    xlabel('time, t');
    ylabel('Sequence probability');
    
    l = legend(Leg);
    set(l,'fontsize',24);
    set(gca,'box','on');
    set(gca,'linewidth',3);
    set(gca,'ylim',[0 0.4]);
    hold off;
end
