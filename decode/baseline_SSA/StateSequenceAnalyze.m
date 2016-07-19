function SSARes = StateSequenceAnalyze(SSAProb)

% function SSARes = StateSequenceAnalyze(SSAProb)
%
% StateSequenceAnalyze finds all non-dominated state sequences for a given
% continuous-time Markov chain, a given start state or set of start states,
% and a given final time. Optionally, it can, more generally, find the set
% of state sequences dominated by no more than MaxDom other sequences. (By 
% default, MaxDom=0, so that only the non-dominated state sequences are 
% returned.)
%
% INPUTS:
%
% Input SSAProb should be a structure containing:
% .L = vector of lambda values, one for each state of the chain
% .T = matrix of transition probabilities
% .Starts = Vector of possible start states that will be analyzed
% .Time = vector of time points at which to numerically evaluate the
%   probabilities or likelihoods -- or, if only a single time > 0 is given,
%   that is interpreted as the final time, with 1e+4 steps between 0 and
%   .Time taken to be the numerical grid. If a full vector of grid points
%   is specific, the first element (i.e. first time) must be zero.
% .MaxDom = optionally, largest number of state sequences that can dominate
%   a sequence before it is discarded. Defaults to 0, hence only
%   non-dominated sequences would be returned.
%
% OUTPUTS:
%
% Returns a data structure SSARes, which includes:
% .SSAProb = the SSA problem being solved
% .TimeGrid = the numerical grid for evaluation of state sequence
%   probabilities and likelihoods
% .Seqs = an NxN cell array where N is the number of states of the chain,
%   in which .Seqs{i,j} is the set of non-dominated state sequences from
%   state i to state j. Each sequence is represented by a structure which
%   itself contains two fields: .seq is the state sequence, and .p is its
%   probability as a function of time.

% How many states in the system?
NStates = length(SSAProb.L);

% Determine the temporal grid for numerical solution of probability and
% likelihood functions
if length(SSAProb.Time)>1
    TimeGrid = SSAProb.Time;
else
    TimeGrid = 0:(SSAProb.Time*1e-4):SSAProb.Time;
end

% Do we have an M parameter?
if isfield(SSAProb,'MaxDom')
    MaxDom = SSAProb.MaxDom;
else
    MaxDom = 0;
end

% Initialize the Seqs cell array
Seqs = cell(NStates);

% Initialize info for possible start states, and enqueue their possible
% extensions
Q = {};
for i=1:length(SSAProb.Starts)
    Start = SSAProb.Starts(i);
    TempSeq = [];
    TempSeq.seq = Start; % The sequence
    TempSeq.p = exp(-SSAProb.L(Start)*TimeGrid'); % The probability of the sequence
    TempSeq.ndom = 0; % How many sequences dominate it
    Seqs{Start,Start}{end+1} = TempSeq;
    for j=1:NStates
        if SSAProb.T(Start,j)>0
            Q{end+1} = [Start j];
        end
    end
end

% Keep processing sequences, as long as the queue is not empty!
while length(Q)>0
    % Get the next sequence, and process it, unless it's parent is gone,
    % which means it should be gone too.
    Seq = Q{1};
    Q = Q(2:end);
    Parent = FindParent(Seqs,Seq);
    if isstruct(Parent)
        % Compute the sequence's probability curve and create a structure 
        % for it.
        TempSeq = [];
        TempSeq.seq = Seq;
        TempSeq.p = ComputeP(SSAProb,Seq,Parent,TimeGrid);
        TempSeq.ndom = 0;
        
        % Update the Seqs data structure based on the new sequence
        [Seqs,ItsAKeeper] = UpdateSeqs(Seqs,TempSeq,MaxDom);
        
        % If it wasn't dominated (or not too much), add the possible
        % single-step extensions to the queue.
        if ItsAKeeper
            for i=1:NStates
                if SSAProb.T(Seq(end),i)>0
                    Q{end+1} = [Seq i];
                end
            end
        end
    end
end

SSARes.SSAProb = SSAProb;
SSARes.Seqs = Seqs;
SSARes.TimeGrid = TimeGrid;

end

%============
% UPDATESEQS -- Updates the Seqs data structure to account for a new
% sequence. If the new sequence is dominated by any others, it is not added
% to Seqs, otherwise, it is.  If the new sequence dominates any others,
% they are removed from Seqs.  Returns the updated Seqs structure, as
% NonDom=1 if the new sequence is not dominated (i.e., was added) or
% NonDom=0 if the new sequence was dominated.
%============

function [OutSeqs,ItsAKeeper] = UpdateSeqs(InSeqs,NewSeq,MaxDom)
% Start and end states
Start = NewSeq.seq(1);
End = NewSeq.seq(end);

% Establish dominance relationships
DomOthers = []; % Whether NewSeq dominates already-found sequences
for i=1:length(InSeqs{Start,End});
    TempDiff = InSeqs{Start,End}{i}.p(2:end) - NewSeq.p(2:end);
    % If NewSeq is dominated...
    if all(TempDiff>0)
        NewSeq.ndom = NewSeq.ndom+1;
    end
    % It NewSeq dominates
    if all(TempDiff<0)
        DomOthers(end+1) = i;
    end
end

% If NewSeq dominated, or dominated by too many other sequences, we discard
% it, and we're done.
if NewSeq.ndom>MaxDom
    ItsAKeeper = 0;
    OutSeqs = InSeqs;
else
    ItsAKeeper = 1;
    OutSeqs = InSeqs;
    
    % We need to see if any old sequences should be deleted.
    ToKill = [];
    for i=DomOthers
        OutSeqs{Start,End}{i}.ndom = OutSeqs{Start,End}{i}.ndom+1;
        if OutSeqs{Start,End}{i}.ndom > MaxDom
            ToKill(end+1) = i;
        end
    end
    if ~isempty(ToKill)
        ToKeep = setdiff(1:length(OutSeqs{Start,End}),ToKill);
        OutSeqs{Start,End} = OutSeqs{Start,End}(ToKeep);
    end
    
    % Then we add the new sequence
    OutSeqs{Start,End}{end+1} = NewSeq;
end
end

%============
% FINDPARENT -- find the sequence of which Seq is an extension, if we can;
% The parent may have been deleted because of being dominated by another
% sequence, in which case Seq should be ignored as well. The parent is
% located in the returned variable Parent.
%============
function Parent = FindParent(Seqs,Seq)
Parent = NaN;
if length(Seq)>=2
    PSeq = Seq(1:(end-1));
    PStart = PSeq(1);
    PEnd = PSeq(end);
    for i=1:length(Seqs{PStart,PEnd})
        TempSeq = Seqs{PStart,PEnd}{i};
        if length(TempSeq.seq)==length(PSeq)
            if all(TempSeq.seq==PSeq)
                Parent = TempSeq;
                return;
            end
        end
    end
end
end


%==========
% COMPUTEP -- compute the time-dependent probability of a state sequence
%==========
function P = ComputeP(SSAProb,Seq,Parent,TimeGrid)

if ~isstruct(Parent)
    P = NaN;
    return;
end

NextToLastState = Parent.seq(end);
pfunc = @(t)interp1(TimeGrid,Parent.p,t);

A=-SSAProb.L(Seq(end));
B=SSAProb.L(Parent.seq(end))*SSAProb.T(NextToLastState,Seq(end));
RHS = @(t,y)(A*y +B*pfunc(t));

options=odeset('NonNegative',1,'AbsTol',1e-10,'RelTol',1e-10);
[Dummy,P]=ode45(RHS,TimeGrid,0,options);

end







