This README.txt file describes a Matlab code package implementing State Sequence Analysis of continuous-time Markov chains.  

It was written by Theodore J. Perkins on August 8, 2012.

This package was created in support of a journal paper describing State Sequence Analysis, currently in submission, titled "What Do Molecules Do When We're Not Looking? State Sequence Analysis for Stochastic Chemical Systems", authored by Pavel Levin, Jeremie Lefebvre, and Theodore J. Perkins.


WHAT IS INCLUDED

The distribution comes with seven files (including the README.txt file):

(1) README.txt: Distribution details and usage instructions.

(2) StateSequenceAnalyze.m: Implementation of State Sequence Analysis approach, more specifically, the key step of computing non-dominated state sequences.

(3) ExtractMaxSeqs.m: A utility for extracting, from the output of StateSequenceAnalyze, those state sequences that are maximally probable at some point in time.
(4) Mat_Example.m: A script analyzing the "demonstration" example near the beginning of the paper.
(5) Mat_HIV.m: A script analyzing the HIV example, which concerns mutations conferring resistance to Efavirenz combination therapy.
(6) Mat_Ion.m: A script analyzing the ion channel example, which concerns sequences of closed states underlying closed intervals of time, as might be seen on a single-channel patch clamp recording of a sodium ion channel.

(7) IonChannelCTMC.m: A function that instantiates the continuous-time Markov chain model of ion channel dynamics, depending on the voltage of the patch clamp.


INSTALLATION

To use the package, the files can simply all be placed in the current working directory of Matlab.  Or they may be put in any other directory, and the "addpath" command used to add that directory to "matlabpath", which is a list of directories that Matlab automatically searches when looking for a .m file to execute.


NOTES

This distribution should be considered research-quality code. It has been tested on variable examples and checked for correctness.  However, it does not include much (if any) error checking.  Nor has it been optimized for speed.  Rather, it represents about as straightforward an implementation as was possible of the ideas described in the paper.

The two general-use functions, StateSequenceAnalyze and ExtractMaxSeqs, have usage instructions at the start, which can be viewed directly in an editor or accessed as "help 
StateSequenceAnalyze" or "help ExtractMaxSeqs". These describe the inputs and outputs of the functions, including the data structure conventions employed.





