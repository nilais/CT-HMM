%========
% Script for analyzing the ion channel example.
%========

% Loop over different voltages
if 1
    SSAResAllV = {};
    VRange = -100:0.25:0; % Warning: This takes a while! If you want a faster picture, try -100:10:0;
    tic;
    for V = VRange
        disp(['Voltage: ',num2str(V)]);
        
        % Create the chain
        CTMC = IonChannelCTMC(V);
        
        % Create OSS problem structure
        SSAProb.L = CTMC.L;
        SSAProb.T = CTMC.T;
        SSAProb.Starts = [3 4];
        SSAProb.Time = 0:(0.005/1000):0.005; % Units of seconds
        
        % Solve it!
        SSARes = StateSequenceAnalyze(SSAProb);

        % Add weighting by prior and posterior transition probabilities,
        % for start and end states of interest
        StartProbs = CTMC.T(5,:);
        StopProbs = CTMC.BackToOpen;
        for Start=3:4
            for Stop=3:4
                for s=1:length(SSARes.Seqs{Start,Stop})
                    SSARes.Seqs{Start,Stop}{s}.p = ...
                        SSARes.Seqs{Start,Stop}{s}.p ... 
                        * StartProbs(Start) * StopProbs(Stop);
                end
            end
        end
                    
        % Store the result
        SSAResAllV{end+1} = SSARes;
    end
    SSATime = toc; % Takes about 14.095428160399999 per voltage level
    
    % If you want to save the results of the computation for later:
    %save Mat_Ion_Results.mat VRange SSAResAllV SSATime
end

% Analyzing the results -- some of this could have been done using
% ExtractMaxSeqs, but it wouldn't be much more elegant in the end.
if 1
    % If you saved the results:
    %load Mat_Ion_Results;
    
    TStep = 1; % How many time steps to skip over
    OptSeqs = {}; % A cell array of optimal sequences.
    NTSteps = (length(SSAResAllV{1}.TimeGrid)-1)/TStep;
    NVSteps = length(VRange);
    OptSeqIndex = zeros(NTSteps,NVSteps);
    % Loop over V steps
    for vi=1:NVSteps
        % Get optimization results for that voltage
        TempSSARes = SSAResAllV{vi};
        % Collect the non-dominated sequences to the end state
        TempSeqs = {};
        for Start = 3:4
            for Stop = 3:4
                for i=1:length(TempSSARes.Seqs{Start,Stop})
                    TempSeqs{end+1} = TempSSARes.Seqs{Start,Stop}{i};
                end
            end
        end
        % Loop over time steps, figuring best state sequence at each
        for ti=1:NTSteps
            % Find best-scoring one
            MaxProb = TempSeqs{1}.p(1+ti*TStep);
            BestSeq = TempSeqs{1};
            for j=2:length(TempSeqs)
                if TempSeqs{j}.p(1+ti*TStep)>MaxProb
                    MaxProb = TempSeqs{j}.p(1+ti*TStep);
                    BestSeq = TempSeqs{j};
                end
            end
            % Now, figure out which one it is, in terms of the overall
            % OptSeqs list
            ItIs = NaN;
            for j=1:length(OptSeqs)
                if length(OptSeqs{j})==length(BestSeq.seq)
                    if all(OptSeqs{j}==BestSeq.seq)
                        ItIs = j;
                    end
                end
            end
            if ~isnan(ItIs)
                OptSeqIndex(ti,vi) = ItIs;
            else
                OptSeqs{end+1} = BestSeq.seq;
                OptSeqIndex(ti,vi) = length(OptSeqs);
            end
        end
    end
    
    % Show it
    Mult = floor(64/max(max(OptSeqIndex)));
    image(VRange,1000*SSAResAllV{1}.TimeGrid,Mult*OptSeqIndex);
    set(gca,'ydir','normal');
    xlabel('Clamp voltage (mV)');
    ylabel('Closed duration (ms)');
end



