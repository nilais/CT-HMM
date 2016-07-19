function CTMC = IonChannelCTMC(V)
%=========
% Compute CTMC for the Vandenberg & Bezanilla (1991) model, which depends
% on the volage V of the patch clamp.
% However, because of the type of optimization we want to do, we omit links
% to the open state (5) from the C3 (3) and I (4) closed states, storing
% those rates instead in an .BackToOpen part of the CTMC. We we return is a
% structure containing: 
% .T = transition probabilities
% .L = dwell time parameters
% .BackToOpen = instantaneous rates from states 3 and 4 to state 5.

% Compute voltage-dependent transition rates, based on Vandenberg &
% Bezanilla (1991)
% States are 1 = C1, 2 = C2, 3 = C3, 4 = I, 5 = O, where numbers are for
% us, and the letter/number combones are the V & B designations
a = 2969 * exp(0.13*V/24);
b = 704 * exp(-0.7*V/24);
c = 28932 * exp(1.25*V/24);
d = 725 * exp(-0.6*V/24);
f = 705 * exp(0.49*V/24);
g = 1117 * exp(0.66*V/24);
i = 25/(1+g/f);
j = i*g/f;
% Dwell times
CTMC.L = [a a+b+g b+c i+j d+f];
% Transition probs
CTMC.T = [0 1 0 0 0
    b/(a+b+g) 0 a/(a+b+g) g/(a+b+g) 0
    0 b/(b+c) 0 0 0 %c/(b+c)
    0 i/(i+j) 0 0 0 %j/(i+j)
    0 0 d/(d+f) f/(d+f) 0];
% Initial probs
CTMC.BackToOpen = [0 0 c j 0];
