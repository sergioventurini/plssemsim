*!plssemsim version 0.1.1
*!Written 10Apr2024
*!Written by Sergio Venturini
*!The following code is distributed under GNU General Public License version 3 (GPL-3)

program plssemsim
  version 15.1
  syntax [anything] [, * ]
  
  if replay() {
    if ("`e(cmd)'" != "plssemsim") {
      error 301
    }
   
    // Extract all the options from 'cmdline'
    local cmdline = `"`e(cmdline)'"'
    local cmdlen = strlen(`"`cmdline'"')
    local cmdcomma = strpos(`"`cmdline'"', ",")
    local old_options = substr(`"`cmdline'"', `cmdcomma' + 1, `cmdlen' - `cmdcomma')
    local old_options : list clean old_options
    local hasstruct = strpos(`"`old_options'"', "str")
    if (!`hasstruct') {
      local nostructural "nostructural"
    }
   
    if (`"`options'"' != "") {
      Display, `options' `nostructural'
    }
    else {
      Display, `old_options' `nostructural'
    }
    exit
  }
 
  if (_caller() < 8) {
    local version : display "version " string(_caller()) ", missing :"
  }
  else {
    local version : display "version " string(_caller()) " :"
  }
 
  `version' Simulate `0'  // version is not necessary
end

program Simulate, eclass
  version 15.1
  syntax anything(id="Measurement model" name=blocks), ///
    [ STRuctural(string) ERRor_cor(name) INDicator_cor(name) phi(real 1) ///
    EMPirical SKewness(name) KUrtosis(name) vars_2nd(string) ///
    vars_attached_to_2nd(string) vars_not_attached_to_2nd(string) ///
    COpula(string) COPMargins(namelist) COPMARGParams(name) ///
    COPParams(name) DISPstr(string) nw(numlist integer >1 min=1 max=1) ///
    hnd(string) n(numlist integer >1 min=1 max=1) METhod(string) ///
    noHEADer noMEAStable noSTRUCTtable noCORR DIGits(integer 3) noCLeanup ]
 
  /* Options:
     --------
     structural(string)               --> structural model specification
     error_cor(name)                  --> measurement error correlation matrix
     indicator_cor(name)              --> indicator correlation matrix
     phi(integer 3)                   --> [[SV ???]]
     empirical                        --> if 1 mu and Sigma of the normal
                                          distribution specify the empirical
                                          not the population mean and
                                          covariance matrix
     skewness                         --> skewness of the indicators
     kurtosis                         --> kurtosis of the indicators
     vars_2nd                         --> 2nd order constructs
     vars_attached_to_2nd             --> constructs attached to 2nd order
                                          constructs
     vars_not_attached_to_2nd         --> constructs not attached to 2nd
                                          order constructs
     copula                           --> copula distribution to use
     copmargins                       --> marginal distributions
     copmargparams                    --> marginal distributions parameters
     copparams                        --> copula parameters
     dispstr                          --> normal/t copula dispersion structure;
                                          one of "ex", "un", "ar1", or "toep"
     nw                               --> size of the warm-up sample
     hnd(string)                      --> how to handle negative definite
                                          indicator correlation matrices;
                                          one of "stop", "drop" or "missing"
                                          in which case a missing is produced;
                                          defaults to "stop"
     n(numlist integer>1 min=1 max=1) --> number of data to simulate
     method(string)                   --> method to use for simulating the
                                          data; one of "normal", "vm" or
                                          "copula"
     noheader                         --> do not show the header
     nomeastable                      --> do not show the measurement table
     nostructtable                    --> do not show the structural table
     nocorr                           --> do not show any correlation matrix
     digits(integer 3)                --> number of digits to display
                                          (default 3)
     nocleanup                        --> Mata temporary objects are not
                                          removed (undocumented)
   */
 
  /* Macros:
   *  LV`i'             - latent variable name
   *  i`i'              - indicators for latent, by latent index
   *  istd`i'           - indicators for latent, by latent index (standardized)
   *  i`LV`i''          - indicators for latent, by latent name
   *  istd`LV`i''       - indicators for latent, by latent name (standardized)
   *  allindicators     - all indicators
   *  allstdindicators  - all standardized indicators
   *  alllatents        - all latents
   */

  local cmdline : list clean 0
  local tempnamelist

  /* Parse outer relationships */
  local blocks : list clean blocks
  tokenize `"`blocks'"', parse(" ()<>")

  tempname inblock startblock
  scalar `inblock' = 0
  scalar `startblock' = 0

  local j = 0
  local i = 0
  local tok_i = 1

  tempname loadings im jm
  local tempnamelist "`tempnamelist' `loadings' `im' `jm'"
  while ("``tok_i''" != "") {
    if ("``tok_i''" == "(") {
      if (`inblock') {
        display as error "unexpected ("
        error 197
      }
      scalar `inblock' = 1
      scalar `startblock' = 1
      local ++j
      if (`j' == 1) {
        mata: `loadings' = J(0, 1, 0)
      }
      else {
        mata: `loadings' = (`loadings', J(rows(`loadings'), 1, 0))
      }
    }
    else if (`inblock') {
      if ("``tok_i''" == ")") {
        if ("LV`j'" == "" | "i`j'" == "") {
          display as error "incomplete measurement model specification"
          error 197
        }
        else {
          scalar `inblock' = 0
          local i`LV`j'' `i`j''
          local allindicators "`allindicators' `i`j''"
          local alllatents "`alllatents' `LV`j''"
        }
      }
      else if ("``tok_i''" == "<" | "``tok_i''" == ">") {
        scalar `startblock' = 0
        if ("``tok_i''" == ">") {
          local modeA "`modeA' `LV`j''"
        }
        else if ("``tok_i''" == "<") {
          local modeB "`modeB' `LV`j''"
        }
      }
      else if (`startblock') {
        if ("`LV`j''" != "") {
          display as error "missing ="
          error 197
        }
        local LV`j' ``tok_i''
      }
      else {
        if ("``tok_i''" != "+") {
          if (strpos("``tok_i''", ":")) {
            while ("``tok_i''" != "") {
              gettoken tok_i_tmp `tok_i' : `tok_i', parse(":")
              if (real("`tok_i_tmp'") != .) {
                mata: `loadings' = (`loadings' \ J(1, cols(`loadings'), 0))
                local ++i
                mata: `im' = strtoreal(st_local("i"))
                mata: `jm' = strtoreal(st_local("j"))
                mata: `loadings'[`im', `jm'] = strtoreal(st_local("tok_i_tmp"))
              }
              else if ("`tok_i_tmp'" != ":") {
                local i`j' "`i`j'' `tok_i_tmp'"
              }
            }
          }
          else {
            local i`j' "`i`j'' ``tok_i''"
          }
        }
      }
    }
    else {
      error 197
    }
    local ++tok_i
  }
  local modeA : list clean modeA
  local modeB : list clean modeB
  local modeA : list uniq modeA
  local modeB : list uniq modeB
  forvalues idx = 1(1)`j' {
    local i`idx' : list clean i`idx'
  }
 
  if (`inblock') {
    display as error "missing )"
    error 197
  }
 
  local allindicators : list clean allindicators
  local alllatents : list clean alllatents
  local allindicators : list uniq allindicators
  local alllatents : list uniq alllatents
  /* End of parsing outer relationships */
 
//   /* Save original data set */
//   if (_N > 0) {
//     tempname original_data
//     local tempnamelist "`tempnamelist' `original_data'"
//     mata: `original_data' = st_data(., .)
//   }
//   /* End saving original data set */
 
  /* Check that digits is nonnegative */
  if (`digits' < 0) {
    display as error "number of digits to display must be a nonnegative integer"
    exit
  }
  /* End of checking that digits is nonnegative */
 
  /* Check the error correlation matrix */
  local num_ind: word count `allindicators'
  tempname ec err_corr
  local tempnamelist "`tempnamelist' `ec' `err_corr'"
  if ("`error_cor'" == "") {
    matrix `ec' = J(`num_ind', `num_ind', 0)
  }
  else {
    matrix `ec' = `error_cor'
  }
  matrix rownames `ec' = `allindicators'
  matrix colnames `ec' = `allindicators'
  mata: `err_corr' = st_matrix("`ec'")

  if (rowsof(`ec') != `num_ind') {
    display as error "size of error_cor does not match number of constructs"
    exit
  }
  /* End of checking the error correlation matrix */
 
  /* Check the indicator correlation matrix */
  tempname ic ind_corr
  local tempnamelist "`tempnamelist' `ic' `ind_corr'"
  if ("`indicator_cor'" == "") {
    matrix `ic' = J(`num_ind', `num_ind', 0)
  }
  else {
    matrix `ic' = `indicator_cor'
  }
  matrix rownames `ic' = `allindicators'
  matrix colnames `ic' = `allindicators'
  mata: `ind_corr' = st_matrix("`ic'")

  if (rowsof(`ic') != `num_ind') {
    display as error "size of indicator_cor does not match number of indicators"
    exit
  }
  /* End of checking the indicator correlation matrix */
 
  /* Check the sample size */
  if ("`n'" == "") {
    local n 200
  }
  else {
    if (`n' <= 1) {
      display as error "sample size must be larger than 1"
      exit
    }
  }
  /* End of checking the sample size */
 
  /* Check the handling of negative definite matrices */
  if ("`hnd'" == "") {
    local hnd "stop"
  }
	if !("`hnd'" == "stop" | "`hnd'" == "drop" | "`hnd'" == "missing") {
		display as error "hnd can be either 'stop', 'drop', or 'missing'"
		exit
	}
  /* End of checking the handling of negative definite matrices */
 
  /* Check the method */
  if ("`method'" == "") {
    local method "normal"
  }
	if !("`method'" == "normal" | "`method'" == "vm" | "`method'" == "copula") {
		display as error "method can be either 'normal', 'vm', or 'copula'"
		exit
	}
  /* End of checking the method */
 
  /* Check the empirical option */
  if ("`empirical'" == "") {
    local emp 0
  }
  else {
    local emp 1
  }
  /* End of checking the empirical option */

  /* Parse inner relationships */
  local num_lv: word count `alllatents'
  local num_ind: word count `allindicators'
  tempname isproduct pathcoef
  local tempnamelist "`tempnamelist' `isproduct' `pathcoef'"
  mata: `isproduct' = J(`num_ind', 1, 0)
  mata: `pathcoef' = J(cols(`loadings'), cols(`loadings'), 0)
 
  if ("`structural'" != "") {
    tokenize `"`structural'"', parse(" ,")
   
    local tok_i = 1
    while ("``tok_i''" != "") {
      if ("``tok_i''" != "+" & "``tok_i''" != "=") {
        if (strpos("``tok_i''", ":")) {
          while ("``tok_i''" != "") {
            gettoken tok_i_tmp `tok_i' : `tok_i', parse(":")
            if (real("`tok_i_tmp'") != .) {
              local pc_tmp = real("`tok_i_tmp'")
            }
            else if ("`tok_i_tmp'" != ":") {
              local i : list posof "`tok_i_tmp'" in alllatents
            }
          }
          mata: `im' = strtoreal(st_local("i"))
          mata: `jm' = strtoreal(st_local("j"))
          mata: `pathcoef'[`im', `jm'] = strtoreal(st_local("pc_tmp"))
        }
        else {
          local j : list posof "``tok_i''" in alllatents
        }
      }
      local ++tok_i
    }
  }
  /* End of parsing the inner relationships */

  /* Build the construct orders */
  tempname constr_order
  matrix `constr_order' = J(`num_lv', 1, 1)
  if ("`vars_2nd'" != "") {
    local i = 1
    foreach var in `vars_2nd' {
      if (`: list var in alllatents') {
        matrix `constr_order'[`i', 1] = 2
      }
      local ++i
    }
  }
  /* End of building the construct orders */

  /* Check skewness */
  tempname skew
  if ("`skewness'" == "") {
    matrix `skew' = J(`num_ind', 1, 0)
  }
  else {
    matrix `skew' = `skewness'
  }
  if (rowsof(`skew') != `num_ind') {
    display as error "skewness vector size differs from number of indicators"
    error 198
  }
  matrix rownames `skew' = `allindicators'
  /* End of checking skewness */

  /* Check kurtosis */
  tempname kurt
  if ("`kurtosis'" == "") {
    matrix `kurt' = J(`num_ind', 1, 0)
  }
  else {
    matrix `kurt' = `kurtosis'
  }
  if (rowsof(`kurt') != `num_ind') {
    display as error "kurtosis vector size differs from number of indicators"
    error 198
  }
  matrix rownames `kurt' = `allindicators'
  /* End of checking skewness */

  /* Check copula options */
  tempname copmargprms copprms
  if ("`method'" == "copula") {
    if ("`copula'" == "") {
      display as error "copula type must be provided"
      error 198
    }
    if ("`copula'" != "normal" & "`copula'" != "t" & "`copula'" != "Clayton" & ///
        "`copula'" != "Frank" & "`copula'" != "Gumbel" & "`copula'" != "independent") {
      display as error "copula option must be one of 'Clayton', 'Frank', 'Gumbel', " _continue
      display as error "'independent', 'normal', or 't'"
      error 198
    }

    if ("`copmargins'" == "") {
      display as error "copula margin distributions must be provided"
      error 198
    }
    else {
      if (`: word count `copmargins'' != `num_ind') {
        display as error "copula margin distributions differ from number of indicators"
        error 198
      }
    }

    if ("`copmargparams'" == "") {
      display as error "copula margin parameters must be provided"
      error 198
    }
    else {
      matrix `copmargprms' = `copmargparams'
      if (colsof(`copmargprms') != `num_ind') {
        display as error "copula margin parameters size differs from number of indicators"
        error 198
      }
    }

    if ("`copparams'" == "") {
      display as error "copula parameters must be provided"
      error 198
    }
    else {
      matrix `copprms' = `copparams'
    }

    if ("`copula'" == "normal" | "`copula'" == "t") {
      if ("`dispstr'" == "") {
        display as error "normal/t copula dispersion structure must be provided"
        error 198
      }
      if ("`dispstr'" != "ex" & "`dispstr'" != "un" & "`dispstr'" != "ar1" & "`dispstr'" != "toep") {
        display as error "normal/t copula dispersion structure must be one of 'ex', 'un', 'ar1', or 'toep'"
        error 198
      }
    }

    if ("`nw'" == "") {
      local nw 1e5
    }
  }
  else {
    matrix `copmargprms' = J(1, 1, .)
    matrix `copprms' = J(1, 1, .)

  }
  /* End of checking copula options */

  /* Create other macros and scalars */
  tempname struct_sc
  if ("`structural'" == "") {
    scalar `struct_sc' = 0
  }
  else {
    scalar `struct_sc' = 1
  }
  /* End of creating other macros */

  /* Create the adjacency matrices */
  tempname modes adj_meas adj_struct
  local num_ind : word count `allindicators'

  matrix `modes' = J(`num_lv', 1, 1)
  local i = 1
  foreach var in `alllatents' {
    if (`: list var in modeA') {
      matrix `modes'[`i', 1] = 0
    }
    local ++i
  }
 
  matrix `adj_meas' = J(`num_ind', `num_lv', 0) 
  local i = 1
  local j = 1
  foreach var in `alllatents' {
    foreach var2 in `i`var'' {
      matrix `adj_meas'[`i', `j'] = 1
      local ++i
    }
    if (`: list var in modeA') {
      local loadcolnames `loadcolnames' "Reflective:`var'"
    }
    else {
      local loadcolnames `loadcolnames' "Formative:`var'"
    }
    local loadrownames `loadrownames' `i`var''
    local ++j
  }
  matrix rownames `adj_meas' = `loadrownames'
  matrix colnames `adj_meas' = `loadcolnames'
  local adj_sum = 0
  local adj_nrows = rowsof(`adj_meas')
  local adj_ncols = colsof(`adj_meas')
  forvalues adj_i = 1(1)`adj_nrows' {
    forvalues adj_j = 1(1)`adj_ncols' {
      local adj_el = `adj_meas'[`adj_i', `adj_j']
      local adj_sum = `adj_sum' + `adj_el'
    }
  }
  if (`adj_sum' == 0) {
    display as error "the adjacency matrix of the measurement model is empty"
    exit
  }

  mata: st_matrix("`adj_struct'", `pathcoef' :!= 0)
  matrix rownames `adj_struct' = `alllatents'
  matrix colnames `adj_struct' = `alllatents'
  /* End of creating the adjacency matrices */

  tempname data latents reflective indicators Sigma
  local tempnamelist "`tempnamelist' `data' `latents' `reflective'"
  local tempnamelist "`tempnamelist' `indicators' `Sigma'"
  mata: `latents' = st_local("alllatents")
  mata: `reflective' = st_local("modeA")
  mata: `indicators' = st_local("allindicators")

  capture noisily {
    mata: `Sigma' = plssemsim_generateSigma( ///
      st_matrix("`adj_meas'")', ///      // warning: tranposed!
      st_matrix("`adj_struct'")', ///    // warning: tranposed!
      plssemsim_constrtype(`latents', `reflective'), ///
      st_matrix("`constr_order'"), ///
      `indicators', ///
      `latents', ///
      `loadings'', ///   // warning: tranposed!
      `pathcoef'', ///   // warning: tranposed!
      `err_corr', ///
      `ind_corr', ///
      strtoreal(st_local("phi")), ///
      strtoreal(st_local("n")), ///
      st_local("hnd"), ///
      st_local("vars_2nd"), ///
      st_local("vars_attached_to_2nd"), ///
      st_local("vars_not_attached_to_2nd"))

    mata: `data' = plssemsim_generateData( ///
      st_matrix("`adj_meas'")', ///      // warning: tranposed!
      st_matrix("`adj_struct'")', ///    // warning: tranposed!
      plssemsim_constrtype(`latents', `reflective'), ///
      st_matrix("`constr_order'"), ///
      `indicators', ///
      `latents', ///
      `loadings'', ///   // warning: tranposed!
      `pathcoef'', ///   // warning: tranposed!
      `err_corr', ///
      `ind_corr', ///
      strtoreal(st_local("phi")), ///
      strtoreal(st_local("n")), ///
      st_local("hnd"), ///
      strtoreal(st_local("emp")), ///
      st_matrix("`skew'"), ///
      st_matrix("`kurt'"), ///
      st_local("vars_2nd"), ///
      st_local("vars_attached_to_2nd"), ///
      st_local("vars_not_attached_to_2nd"), ///
      st_local("copula"), ///
      tokens(st_local("copmargins")), ///
      st_matrix("`copmargprms'"), ///
      length(tokens(`indicators')), ///
      st_matrix("`copprms'"), ///
      strtoreal(st_local("nw")), ///
      st_local("dispstr"), ///
      st_local("method"))

    if ("`clear'" != "") {
      quietly clear
    }

    if (_N > 0) {
      display as error "some data already present; " _continue
      display as error "close the active data set before simulating new data"
      error 197
    }
    else {
      mata: st_addobs(`n')
      quietly mata: st_addvar("double", tokens(`indicators'), 1)
      mata: st_store(., ., `data')
    }

    /* Label the indicators */
    local now "`c(current_date)', `c(current_time)'"
    local now : list clean now
    foreach var of varlist `allindicators' {
      label variable `var' "Simulated values of `var' [`now']"
    }
    /* End of labeling the indicators */

  } // end of -capture-
  local rc = _rc
  if (`rc' == 1) {
    display
    display as error "you pressed the Break key; " _continue
    display as error "calculation interrupted"
  }
  if (`rc' >= 1) {
    /* Clean up */
    foreach var in `allindicators' {
      capture quietly drop `var'
    }
    if ("`cleanup'" == "") {
      capture mata: plssemsim_cleanup(st_local("tempnamelist"))
    }
    /* End of cleaning up */
   
    error `rc'
  }

  /* Return values */
  local props ""
  if ("`structural'" != "") {
    local props "`props' structural"
  }
  local props "`props'"
  ereturn post, obs(`n') properties(`props')  // this must be the first because it
                                              // clears all existing e-class results

  tokenize `"`blocks'"', parse("()")
  local tok_i = 2
  local measurement "``tok_i''"
  local ++tok_i
  while ("``tok_i''" != "") {
    if ("``tok_i''" != ")" & "``tok_i''" != "(") {
      local measurement "`measurement', ``tok_i''"
    }
    local ++tok_i
  }
  local structural : list clean structural
  local measurement : list clean measurement
  ereturn local eqs_struct "`structural'"
  ereturn local eqs_meas `"`measurement'"'
  if ("`method'" == "copula") {
    if ("`copula'" == "normal" | "`copula'" == "t") {
      ereturn local dispstr "`dispstr'"
    }
    ereturn local copmargins "`copmargins'"
    ereturn local coptype "`copula'"
  }
  else if ("`method'" == "vm") {
    if ("`empirical'" == "") {
      ereturn local empirical "population"
    }
    else {
      ereturn local empirical "empirical"
    }
  }
  ereturn local vars_2nd `"`vars_2nd'"'
  ereturn local vars_attached_to_2nd `"`vars_attached_to_2nd'"'
  ereturn local vars_not_attached_to_2nd `"`vars_not_attached_to_2nd'"'
  ereturn local method `"`method'"'
  ereturn local formative `"`modeB'"'
  ereturn local reflective `"`modeA'"'
  ereturn local lvs `"`alllatents'"'
  ereturn local mvs `"`allindicators'"'
  ereturn local title "Partial least squares structural equation modeling - Simulated data"
  ereturn local cmdline "plssemsim `cmdline'"
  ereturn local cmd "plssemsim"

  local lv_nm : colnames `adj_meas'
  local mv_nm : rownames `adj_meas'
  tempname loadings_ret pathcoef_ret Sigma_ret
  mata: st_matrix("`loadings_ret'", `loadings')
  mata: st_matrix("`pathcoef_ret'", `pathcoef')
  mata: st_matrix("`Sigma_ret'", `Sigma')
  matrix rownames `loadings_ret' = `mv_nm'
  matrix colnames `loadings_ret' = `lv_nm'
  matrix rownames `pathcoef_ret' = `lv_nm'
  matrix colnames `pathcoef_ret' = `lv_nm'
  matrix rownames `Sigma_ret' = `mv_nm'
  matrix colnames `Sigma_ret' = `mv_nm'

  if ("`method'" == "vm") {
    matrix colnames `skew' = "skewness"
    ereturn matrix skewness = `skew'
    matrix colnames `kurt' = "kurtosis"
    ereturn matrix kurtosis = `kurt'
  }
  else if ("`method'" == "copula") {
    ereturn matrix copmargparams = `copmargprms'
    ereturn matrix copparams = `copprms'
  }
  ereturn matrix error_cor = `ec'
  ereturn matrix indicator_cor = `ic'
  ereturn matrix adj_meas = `adj_meas'
  ereturn matrix loadings = `loadings_ret'
  ereturn matrix adj_struct = `adj_struct'
  ereturn matrix pathcoef = `pathcoef_ret'
  ereturn matrix Sigma = `Sigma_ret'

  ereturn scalar phi = `phi'
  if ("`method'" == "copula") {
    ereturn scalar Nw = `nw'
  }
  /* End of returning values */

  /* Display results */
  if ("`structural'" == "") {
    local nostructural "nostructural"
  }
  local num_lv_A: word count `modeA'
  if (`num_lv_A' == 0) {
    local nodiscrim "nodiscrimtable"
  }
  else {
    local nodiscrim `discrimtable'
  }
  Display, `nostructural' digits(`digits') `header' `meastable' ///
    `structtable' `corr'
  /* End of displaying results */
 
  /* Clean up */
  if ("`cleanup'" == "") {
    capture mata: plssemsim_cleanup(st_local("tempnamelist"))
  }
  /* End of cleaning up */
end

program Display
  version 15.1
  syntax [, noSTRuctural DIGits(integer 3) noHEADer noMEAStable ///
    noSTRUCTtable noCORR * ]
 
  if (`digits' < 0) {
    display as error "number of digits to display must be a nonnegative integer"
    exit
  }
 
  local props = e(properties)
  local method = e(method)
   
  if ("`header'" == "") {
    local header "Partial least squares SEM - Simulated data"
    display
    display as text "`header'"
    display
    display as text "Sample size = " _continue
    display as result e(N)
    display
    display as text "Indicators = " _continue
    display as result e(mvs)
    if ("`e(lvs)'" != "") {
      display as text "Constructs = " _continue
      display as result e(lvs)
    }
    if ("`e(reflective)'" != "") {
      display as text "Mode A constructs = " _continue
      display as result e(reflective)
    }
    if ("`e(formative)'" != "") {
      display as text "Mode B constructs = " _continue
      display as result e(formative)
    }
    if ("`e(vars_2nd)'" != "") {
      display as text "2nd order constructs = " _continue
      display as result e(vars_2nd)
    }
    if ("`e(vars_attached_to_2nd)'" != "") {
      display as text "Constructs attached to 2nd order constructs = " _continue
      display as result e(vars_attached_to_2nd)
    }
    if ("`e(vars_not_attached_to_2nd)'" != "") {
      display as text "Constructs not attached to 2nd order constructs = " _continue
      display as result e(vars_not_attached_to_2nd)
    }
    tokenize `"`e(eqs_meas)'"', parse(",")
    local tok_i = 1
    display as text "Measurement model equations:"
    while ("``tok_i''" != "") {
      if ("``tok_i''" != ",") {
        display as result "  - ``tok_i''"
      }
      local ++tok_i
    }
    tokenize `"`e(eqs_struct)'"', parse(",")
    local tok_i = 1
    display as text "Structural model equations:"
    while ("``tok_i''" != "") {
      if ("``tok_i''" != ",") {
        display as result "  - ``tok_i''"
      }
      local ++tok_i
    }
//    display as text "Phi = " _continue
//    display as result e(phi)
    display
    display as text "Method = " _continue
    display as result "`method'"
    if ("`method'" == "copula") {
      display as text "Sample size for warm-up = " _continue
      display as result e(Nw)
      display as text "Copula distribution = " _continue
      display as result e(coptype)
      display as text "Copula parameters = " _continue
      display as result "[execute 'matlist e(copparams)']"
      display as text "Copula margin distributions = " _continue
      display as result e(copmargins)
      display as text "Copula margin parameters = " _continue
      display as result "[execute 'matlist e(copmargparams)']"
      if ("`e(coptype)'" == "normal" | "`e(coptype)'" == "t") {
        display as text "Copula dispersion structure = " _continue
        if ("`e(dispstr)'" == "un") {
          display as result "unstructured"
        }
        else if ("`e(dispstr)'" == "ex") {
          display as result "exchangeable"
        }
        else if ("`e(dispstr)'" == "ar1") {
          display as result "AR(1)"
        }
        else if ("`e(dispstr)'" == "toep") {
          display as result "Toeplitz"
        }
      }
    }
    else if ("`method'" == "vm") {
      display as text "Mean and covariance matrix used = " _continue
      if ("`e(empirical)'" == "population") {
        display as result "population"
      }
      else {
        display as result "empirical"
      }
      display as text "Skewness parameters = " _continue
      display as result "[execute 'matlist e(skewness)']"
      display as text "Kurtosis parameters = " _continue
      display as result "[execute 'matlist e(kurtosis)']"
    }
  }

  if ("`meastable'" == "") {
    tempname loadings
    matrix `loadings' = e(loadings)
    local num_lv = colsof(`loadings')
    local allformative = e(formative)
    local num_lv_B : word count `allformative'
    local num_lv_A = `num_lv' - `num_lv_B'
    local num_ind = rowsof(`loadings')
    local title_meas "Measurement model - Standardized loadings"
    mktable, matrix(`loadings') digits(`digits') firstcolname("") ///
      title(`title_meas') firstcolwidth(14) colwidth(14) ///
      hlines(`num_ind') novlines
  }

  if ("`structural'" != "nostructural") {
    if ("`structtable'" == "") {
      tempname pathcoef
      matrix `pathcoef' = e(pathcoef)
      local hline_path = rowsof(`pathcoef')
      local title_st "Structural model - Standardized path coefficients"
      mktable, matrix(`pathcoef') digits(`digits') firstcolname("Variable") ///
        title(`title_st') firstcolwidth(14) colwidth(14) ///
        hlines(`hline_path') novlines path
    }
  }

  if ("`corr'" == "") {
    tempname Sigma
    matrix `Sigma' = e(Sigma)
    mktable_corr, matrix(`Sigma') title("Model implied correlation of indicators")

    tempname loadings
    matrix `loadings' = e(loadings)
    local num_ind = rowsof(`loadings')
    quietly correlate `e(mvs)'
    tempname C
    matrix `C' = r(C)
    forvalues i = 1/`num_ind' {
      local ip1 = `i' + 1
      forvalues j = `ip1'/`num_ind' {
        matrix `C'[`i', `j'] = .
      }
    }
    mktable_corr, matrix(`C') title("Empirical correlation of indicators")

    tempname Resid
    matrix `Resid' = `C' - `Sigma'
    mktable_corr, matrix(`Resid') title("Residual correlations")

    tempname Error_Corr
    matrix `Error_Corr' = e(error_cor)
    mktable_corr, matrix(`Error_Corr') title("Error correlation matrix")
  }
end
