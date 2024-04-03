# plssemsim
###### Current release: 0.1.0
###### Stata version required: at least 15.1
Stata package for simulating data in accordance with a given Partial Least Squares Structural Equation Model (PLS-SEM). The package has been developed in line with the `cSEM.DGP` `R` package (https://m-e-rademaker.github.io/cSEM.DGP), while it adds the simulation of data using copulas.

The companion package for estimating PLS-SEM models is available at the following GitHub repository: https://github.com/sergioventurini/plssem.

# Installation notes

To install `plssemsim` directly from GitHub you need to use the `github` Stata package. You can install the latest version of the `github` package by executing the following code in your Stata session:

    net install github, from("https://haghish.github.io/github/")

Then, you can install the `plssemsim` package using the following code in Stata:

    github install sergioventurini/plssemsim

# Authors
Sergio Venturini, Department of Economic and Social Sciences, Università Cattolica del Sacro Cuore, Cremona, Italy

E-mail: sergio.venturini@unicatt.it

# Bugs
In case you find any bug, please send us an e-mail or open an issue on GitHub.

# Citation
You can cite the `plssemsim` package as:

Mehmetoglu, M., Venturini, S. (2021). Structural Equation Modelling with Partial Least Squares Using Stata and R. CRC Press

Venturini, S., Mehmetoglu, M. (2019). plssemsim: A Stata Package for Structural Equation Modeling with Partial Least Squares. Journal of Statistical Software, 88(8)1-35

Paper webpage: https://www.jstatsoft.org/article/view/v088i08

GitHub repository: https://github.com/sergioventurini/plssemsim

# Copyright
This software is distributed under the GPL-3 license (see LICENSE file).
