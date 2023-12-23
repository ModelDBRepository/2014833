Readme for A Neural Network Model of Mathematics Anxiety: The Role of Attention.

Adapted from supplemental materials of Huber S., Nuerk H-C., Willmes K., Moeller K. (2016). A general model framework for multisymbol number comparison. *Psychological Review*, 123, 667-695. [https://doi.org/10.1037/rev0000040](https://doi.org/10.1037/rev0000040). Reproduced with permission from American Psychological Association. No further reproduction or distribution is permitted. Permission has also been granted by the authors (K. Moeller).

Matlab code adapted (in Matlab R2021a on Ubuntu) by Angela Rose (a.rose@westernsydney.edu.au), Western Sydney University, Australia.

To run the Matlab code for the artificial neural network model of the numerical Stroop and single-digit comparison tasks, run the Matlab script `testNSCCNetwork.m`.

To reproduce the simulations for the different impairments (as described in the paper), uncomment the appropriate Matlab script at the beginning of `testNSCCNetwork.m` which initialises the appropriate variables.

Directory contains:

- Matlab .m files containing the code
- the input data files with file name format of `"inputdata_*.txt"`
- the ANN connection weights used in various simulations, file names have format `"savedWeights*.csv"`
- the Results directory contains the output/data (as .csv files) and graphs (Matlab .fig files) for the various simulations
