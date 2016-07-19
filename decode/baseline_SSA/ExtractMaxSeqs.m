function [MaxSeqsByTime,SeqList] = ExtractMaxSeqs(SSARes,TimesToDo,StartStatesOrWeights,EndStatesOrWeights,MMostProbable)

% ExtractMaxSeqs is inteded to extract sequences that are maximally
% probable somewhere, or more generally, are among the MMostProbable
% sequences. It takes as input:
%
% SSARes: The structure output by the StateSequenceAnalyze function.
% TimesToDo: One or more timepoints for which the sequences are desired.
% StartStates: Vector of starts states allowed for the sequences.
% EndStates: Vector of end states allwed for the sequences.
% MMostProbable: Defaults to 1 -- return sequences that are among the M
% most probable.
%
% It returns:
%
% Seqs: A cell array of vectors, each giving a state sequence
% MaxLists: A cell array of up to three dimensions, corresponding to choice
% of TimesToDo, StartStates

% Initialization
MaxSeqsByTime = {};

% How many states in chain?
NStates = length(SSARes.SSAProb.L);

% Set up start state list and weights
if length(StartStatesOrWeights)==NStates
    StartStates = find(StartStatesOrWeights>0);
    StartWeights = StartStatesOrWeights;
else
    StartStates = StartStatesOrWeights;
    StartWeights = ones(1,NStates);
end

% Set up end state list and weights
if length(EndStatesOrWeights)==NStates
    EndStates = find(EndStatesOrWeights>0);
    EndWeights = EndStatesOrWeights;
else
    EndStates = EndStatesOrWeights;
    EndWeights = ones(1,NStates);
end

% How far down the probability list do we go? Just seek the maximum, but
% default.
if nargin<5
    MMostProbable = 1;
end

% First, we loop through all TimesToDo, probs at that time point, then find
% all sequences with probability in the top M.
for t=TimesToDo
    i = find(SSARes.TimeGrid==t);
    if isempty(i)
        disp(['Warning: ExtractMaxSeqs did not find time ',num2str(t),' among TimeGrid. Skipping.']);
    end
    
    % Find cutoff probability
    CurrProbs = [];
    for Starts = StartStates
        for Ends = EndStates
            for S = 1:length(SSARes.Seqs{Starts,Ends})
                CurrProbs(end+1) = SSARes.Seqs{Starts,Ends}{S}.p(i)*StartWeights(Starts)*EndWeights(Ends);
            end
        end
    end
    CutoffProb = nan;
    if length(CurrProbs)>0
        CurrProbs = fliplr(sort(CurrProbs));
        CutoffProb = CurrProbs(MMostProbable);
    end
    
    % Collect sequences at or above threshold
    TempSeqs = [];
    if ~isnan(CutoffProb)
        for Starts = StartStates
            for Ends = EndStates
                for S = 1:length(SSARes.Seqs{Starts,Ends})
                    if SSARes.Seqs{Starts,Ends}{S}.p(i)*StartWeights(Starts)*EndWeights(Ends)>=CutoffProb
                        TempSeqs = [TempSeqs; Starts Ends S];
                    end
                end
            end
        end
    end
    
    % MaxSeqsByTime
    MaxSeqsByTime{i} = TempSeqs;
end

% If two output arguments are assigned, we collect a list of all sequences
% and revised MaxSeqsByTime to refer to indeces into that list.
SeqList = [];
for i=1:length(MaxSeqsByTime)
    SeqList = [SeqList; MaxSeqsByTime{i}];
end
SeqList = unique(SeqList,'rows');
for i=1:length(MaxSeqsByTime)
    [N,Dummy] = size(MaxSeqsByTime{i});
    TempList = [];
    for j=1:N
        TempList(end+1) = find(MaxSeqsByTime{i}(j,1)==SeqList(:,1) & ...
            MaxSeqsByTime{i}(j,2)==SeqList(:,2) & ...
            MaxSeqsByTime{i}(j,3)==SeqList(:,3));
    end
    MaxSeqsByTime{i} = TempList;
end






        