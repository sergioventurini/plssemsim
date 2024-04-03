{smcl}
{* *! version 0.5.0  05Apr2024}{...}
{vieweralsosee "plssem" "help plssem"}{...}
{viewerjumpto "Syntax" "plssemsim##syntax"}{...}
{viewerjumpto "Description" "plssemsim##description"}{...}
{viewerjumpto "Options" "plssemsim##options"}{...}
{viewerjumpto "Examples" "plssemsim##examples"}{...}
{viewerjumpto "Authors" "plssemsim##authors"}{...}
{viewerjumpto "Stored results" "plssemsim##results"}{...}
{viewerjumpto "References" "plssemsim##references"}{...}
{title:Title}

{p 4 17 2}
{hi:plssemsim} {hline 2} Partial least squares structural equation modelling (PLS-SEM) - Data simulation


{marker syntax}{...}
{title:Syntax}

{pstd}
Simulation of data in accordance with a given partial least squares structural equation model

{p 8 10 2}
{cmd:plssemsimsim} (LV1 > indblock1) (LV2 > indblock2) (...)
[{cmd:,} structural(LV1 = structeq1, LV2 = structeq2, ...) {it:{help plssemsim##plssemsimopts:options}}]


{synoptset 25 tabbed}{...}
{marker plssemsimopts}{...}
{synopthdr}
{synoptline}
{synopt:{opt n(#)}}number of data to simulate; default is {cmd:200}{p_end}
{synopt:{opth err:or_cor(syntax##description_of_namelist:namelist)}}error correlation matrix{p_end}
{synopt:{opth ind:icator_cor(syntax##description_of_namelist:namelist)}}indicator correlation matrix{p_end}
{synopt:{opt phi(#)}}phi parameter; default is {cmd:1}{p_end}
{synopt:{opt emp:irical}}indicates whether mu and Sigma of the normal distribution specify
the empirical or the population mean and covariance matrix; to use with {cmd:method(vm)}{p_end}
{synopt:{opth sk:ewness(syntax##description_of_namelist:namelist)}}skewness values; to use with {cmd:method(vm)}{p_end}
{synopt:{opth ku:rtosis(syntax##description_of_namelist:namelist)}}kurtosis values; to use with {cmd:method(vm)}{p_end}
{synopt:{opth vars_2nd:(syntax##optional_string:string)}}2nd order constructs; experimental feature{p_end}
{synopt:{opth vars_attached_to_2nd:(syntax##optional_string:string)}}constructs attached 2nd order constructs; experimental feature{p_end}
{synopt:{opth vars_not_attached_to_2nd:(syntax##optional_string:string)}}constructs notattached 2nd order constructs; experimental feature{p_end}
{synopt:{cmdab:co:pula(independent)}}independent copula; to use with {cmd:method(copula)}{p_end}
{synopt:{cmdab:co:pula(normal)}}normal copula; to use with {cmd:method(copula)}{p_end}
{synopt:{cmdab:co:pula(t)}}t copula; to use with {cmd:method(copula)}{p_end}
{synopt:{cmdab:co:pula(Clayton)}}Clayton copula; to use with {cmd:method(copula)}{p_end}
{synopt:{cmdab:co:pula(Frank)}}Frank copula; to use with {cmd:method(copula)}{p_end}
{synopt:{cmdab:co:pula(Gumbel)}}Gumbel copula; to use with {cmd:method(copula)}{p_end}
{synopt:{opth copm:argins(syntax##description_of_namelist:namelist)}}string specifying the margin distributions to use with the copula; to use with {cmd:method(copula)}{p_end}
{synopt:{opth copmargp:arams(syntax##description_of_namelist:namelist)}}matrix providing the parameters to use with the margin distributions; each column of the matrix corresponds to a margin distribution; to use with {cmd:method(vm)}{p_end}
{synopt:{opth copp:arams(syntax##description_of_namelist:namelist)}}matrix providing the parameters to use with the copula distribution; to use with {cmd:method(vm)}{p_end}
{synopt:{cmdab:disp:str(ex)}}exchangeable copula dispersion structure; to use with {cmd:method(vm)}{p_end}
{synopt:{cmdab:disp:str(un)}}unstructured copula dispersion structure; to use with {cmd:method(vm)}{p_end}
{synopt:{cmdab:disp:str(ar1)}}first-order autoregressive copula dispersion structure; to use with {cmd:method(vm)}{p_end}
{synopt:{cmdab:disp:str(toep)}}Toeplitz copula dispersion structure; to use with {cmd:method(vm)}{p_end}
{synopt:{opt nw(#)}}number of data to simulate for warm-up; to use with {cmd:method(vm)}; default is {cmd:1e6}{p_end}
{synopt:{cmd:hnd(stop)}}stop when encounters negative definite variance-covariance matrices}{p_end}
{synopt:{cmd:hnd(drop)}}drop a negative definite variance-covariance matrices}{p_end}
{synopt:{cmd:hnd(missing)}}returns a missing when encounters negative definite variance-covariance matrices}{p_end}
{synopt:{cmdab:met:ods(normal)}}simulate the data assuming normality{p_end}
{synopt:{cmdab:met:ods(vm)}}simulate the data using the Vale-Maurelli approach (see {help plssemsim##ValeMaurelli1983:Vale and Maurelli, 1983}){p_end}
{synopt:{cmdab:met:ods(copula)}}simulate the data using the copula approach (see {help plssemsim##Mairetal2012:Mair et al. 2012}){p_end}
{synopt:{opt dig:its(#)}}number of digits to display; default is {cmd:3}{p_end}
{synopt:{cmd:no}{cmdab:head:er}}suppress display of output header{p_end}
{synopt:{cmd:no}{cmdab:meas:table}}suppress display of measurement model estimates table{p_end}
{synopt:{cmd:no}{cmdab:struct:table}}suppress display of structural model estimates table{p_end}
{synopt:{cmd:no}{cmdab:corr}}suppress display of correlation matrices{p_end}
{synoptline}

{p 4 4 2}
{cmd:by} is not allowed with {cmd:plssemsim}. Similarly, the standard {cmd:if} and {cmd:in} qualifers are
not allowed.

{pstd}The syntax of {cmd:plssemsim} reflects the measurement and structural part of a PLS-SEM model,
and accordingly requires the user to specify both of these parts simultaneously. Since a
full PLS-SEM model would include a structural model, i.e., the relationship between latent
variables (LV), one needs to have at least two latent variables specified in the measurement
part. Each latent variable will be defined by a block of indicators (say, {cmd:indblock}). For
example, if we have two latent variables in our PLS-SEM model, the {cmd:plssemsim} syntax requires to
specify the measurement part by typing {cmd:(LV1 > l11:y11 + l12:y12) (LV2 > l21:y21 + l22:y22)} following
the command name, where the loadings, in the example {cmd: l11}, {cmd: l12}, {cmd: l21} and {cmd: l22},
must be specified as real numbers. Note that we can specify up to eight LVs in the model.

{pstd}Incidentally, when specifying reflective measures, one needs to use the greater-than sign between 
a latent variable and its associated indicators (e.g., {cmd:LV1 > indblock1}) and the less-than sign 
for formative measures (e.g., {cmd:LV1 < indblock1}).

{pstd}To specify the structural part, one simply needs to type in the endogenous/dependent LV first
and then the exogenous latent variable/s, e.g., {cmd:structural(LV1 = structeq1)}. One can specify more
than one structural relationship following the same approach. Say that we have two further latent variables
in the model, {cmd:LV2} and {cmd:LV3}; then, in the structural part of the syntax we would type in
{cmd:structural(LV2 = b21:LV1, LV3 = b31:LV1 + b32:LV2)} indicating that {cmd:LV3} is another endogenous
LV predicted by {cmd:LV1} and {cmd:LV1}. All the path coefficients, in the example {cmd: b21}, {cmd: b31}
and {cmd: b32}, must be specified as real numbers. 


{marker description}{...}
{title:Description}

{pstd} {bf:plssemsim} simulate data in accordance with a given partial least squares structural equation
model (PLS-SEM) including up to eight constructs. {bf:plssemsim} is developed in line with the cSEM.DGP
R package ({browse "https://m-e-rademaker.github.io/cSEM.DGP/"}), while it adds the simulation of
data using copulas (see {help plssemsim##Mairetal2012:Mair et al. 2012}).


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. matrix ic = J(9, 9, 0)}{p_end}
{phang2}{cmd:. matrix ic[1.3, 1.3] = (0, .2, .3 \ .2, 0, .5 \ .3, .5, 0)}{p_end}

{pstd}Data simulation (method = "normal"){p_end}
{phang2}{cmd:. plssemsim (eta1 < 0.7:y11 + 0.9:y12 + 0.8:y13) ///}{p_end}
{phang3}{cmd: (eta2 > 0.7:y21 + 0.7:y22 + 0.9:y23) ///}{p_end}
{phang3}{cmd: (eta3 > 0.9:y31 + 0.8:y32 + 0.7:y33), ///}{p_end}
{phang3}{cmd: structural(eta3 = 0.4:eta1 + 0.35:eta2, eta2 = 0.2:eta1) ///}{p_end}
{phang3}{cmd: indicator_cor(ic) n(1e4) method(normal)}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. matrix ic = J(9, 9, 0)}{p_end}
{phang2}{cmd:. matrix ic[1.3, 1.3] = (0, .2, .3 \ .2, 0, .5 \ .3, .5, 0)}{p_end}
{phang2}{cmd:. matrix skew = J(9, 1, 5)}{p_end}
{phang2}{cmd:. matrix kurt = J(9, 1, 0)}{p_end}

{pstd}Data simulation (method = "vm"){p_end}
{phang2}{cmd:. plssemsim (eta1 < 0.7:y11 + 0.9:y12 + 0.8:y13) ///}{p_end}
{phang3}{cmd: (eta2 > 0.7:y21 + 0.7:y22 + 0.9:y23) ///}{p_end}
{phang3}{cmd: (eta3 > 0.9:y31 + 0.8:y32 + 0.7:y33), ///}{p_end}
{phang3}{cmd: structural(eta3 = 0.4:eta1 + 0.35:eta2, eta2 = 0.2:eta1) ///}{p_end}
{phang3}{cmd: indicator_cor(ic) n(1e4) method(vm) empirical ///}{p_end}
{phang3}{cmd: skewness(skew) kurtosis(kurt)}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. matrix ic = J(9, 9, 0)}{p_end}
{phang2}{cmd:. matrix ic[1.3, 1.3] = (0, .2, .3 \ .2, 0, .5 \ .3, .5, 0)}{p_end}
{phang2}{cmd:. local margins = "norm norm norm norm norm norm norm norm norm"}{p_end}
{phang2}{cmd:. matrix mean = J(1, 9, 0)}{p_end}
{phang2}{cmd:. matrix sd = (1, 3, 10, 1, 3, 10, 1, 3, 10)}{p_end}
{phang2}{cmd:. matrix prmMarg = (mean \ sd)}{p_end}
{phang2}{cmd:. matrix param = (.9 \ 2)}{p_end}

{pstd}Data simulation (method = "copula"){p_end}
{phang2}{cmd:. plssemsim (eta1 < 0.7:y11 + 0.9:y12 + 0.8:y13) ///}{p_end}
{phang3}{cmd: (eta2 > 0.7:y21 + 0.7:y22 + 0.9:y23) ///}{p_end}
{phang3}{cmd: (eta3 > 0.9:y31 + 0.8:y32 + 0.7:y33), ///}{p_end}
{phang3}{cmd: structural(eta3 = 0.4:eta1 + 0.35:eta2, eta2 = 0.2:eta1) ///}{p_end}
{phang3}{cmd: indicator_cor(ic) n(1e4) method(copula) ///}{p_end}
{phang3}{cmd: copula(t) copmargins(`margins') copmargparams(prmMarg) ///}{p_end}
{phang3}{cmd: copparams(param) nw(1e4) dispstr(ex)}{p_end}

    {hline}


{marker authors}{...}
{title:Authors}

{pstd} Sergio Venturini{break}
Department of Economics and Social Sciences{break}
Università Cattolica del Sacro Cuore, Italy{break}
{browse "mailto:sergio.venturini@unicatt.it":sergio.venturini@unicatt.it}{break}
{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:plssemsim} stores the following in {cmd:e()}:

{synoptset 24 tabbed}{...}
{p2col 5 24 28 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations simulated in the final sample{p_end}
{synopt:{cmd:e(phi)}}specified phi value{p_end}
{synopt:{cmd:e(Nw)}}number of observations simulated for warm-up in the "copula" method{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 24 28 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:plssemsim}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(mvs)}}list of manifest variables (indicators) used{p_end}
{synopt:{cmd:e(lvs)}}list of latent variables used{p_end}
{synopt:{cmd:e(reflective)}}list of latent variables measured in a reflective way{p_end}
{synopt:{cmd:e(formative)}}list of latent variables measured in a formative way{p_end}
{synopt:{cmd:e(method)}}method used for simulating the data{p_end}
{synopt:{cmd:e(coptype)}}copula distribution selected{p_end}
{synopt:{cmd:e(copmargins)}}copula margin distributions selected{p_end}
{synopt:{cmd:e(dispstr)}}copula dispersion structure selected{p_end}
{synopt:{cmd:e(empirical)}}whether mu and Sigma of the normal distribution specify
the empirical or the population mean and covariance matrix{p_end}
{synopt:{cmd:e(eqs_meas)}}equations defining the measurement model{p_end}
{synopt:{cmd:e(eqs_struct)}}equations defining the structural model{p_end}
{synopt:{cmd:e(properties)}}properties of the estimation command{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 24 28 2: Matrices}{p_end}
{synopt:{cmd:e(Sigma)}}model implied variance-covariance matrix of the indicators{p_end}
{synopt:{cmd:e(pathcoef)}}path coefficients matrix{p_end}
{synopt:{cmd:e(adj_struct)}}adjacency matrix for the structural (inner) model{p_end}
{synopt:{cmd:e(loadings)}}outer loadings matrix{p_end}
{synopt:{cmd:e(adj_meas)}}adjacency matrix for the measurement (outer) model{p_end}
{synopt:{cmd:e(indicator_cor)}}specified correlation matrix for the indicators{p_end}
{synopt:{cmd:e(error_cor)}}specified correlation matrix for the errors{p_end}
{synopt:{cmd:e(copparams)}}specified copula parameters{p_end}
{synopt:{cmd:e(copmargparams)}}specified copula margin parameters{p_end}
{synopt:{cmd:e(skewness)}}specified skewness values{p_end}
{synopt:{cmd:e(kurtosis)}}specified kurtosis values{p_end}


{marker references}{...}
{title:References} 

{marker Hairetal2022}{...}
{phang}
Hair, J. F., Hult, G. T. M., Ringle, C. M., and Sarstedt, M. 2022. {it:A Primer on Partial Least Squares Structural Equation Modeling (PLS-SEM)}. Third edition. Sage.

{marker Lohmoller1989}{...}
{phang}
Lohmöller, J. B. 1989. {it:Latent Variable Path Modeling with Partial Least Squares}. Heidelberg: Physica.

{marker Mairetal2012}{...}
{phang}
Mair, P., Satorra, A., and Bentler, P. M. 2012. Generating Nonnormal Multivariate Data Using Copulas: Applications to SEM. {it:Multivariate Behavioral Research}, 47, 547–565.

{marker MehmetogluVenturini2021}{...}
{phang}
Mehmetoglu, M., and Venturini, S. 2021. {it:Structural Equation Modelling with Partial Least Squares Using Stata and R}. CRC Press.

{marker ValeMaurelli1983}{...}
{phang}
Vale, C. D., and Maurelli, V. A. 1983. Simulating Multivariate Nonnormal Distributions. {it:Psychometrika}, 48, 3, 465-471.

{marker Wold1975}{...}
{phang}
Wold, H. O. A. 1975. Path Models with Latent Variables: The NIPALS Approach.
In Blalock, H. M., Aganbegian, A., Borodkin, F. M., Boudon, R., and Cappecchi, V. (ed.), {it:Quantitative Sociology} (pp. 307-359). New York: Academic Press.
{p_end}
