# About this directory

This directory contains data regarding experiments with Mankowska et al (2014) MIP model and dataset. Most content are logfiles and raw CSVs, as described below.

For a summary of results, please c.f. file [comparison-cplex-configs.ods](comparison-cplex-configs.ods).

## Description of the experiments

We tested in total 8 distinct experiment configurations while solving the MK dataset. All these experiments use CPLEX 20.1.0, and we set a time limit of two hours of processing. Additionally, all runs set the CPLEX parameter randomseed to 1.

- `cplex-lp`: Solves the linear relaxation of the Mankowska's MIP model
- `cplex-defaults`: Uses the default parameter setting of CPLEX
- `cplex-defaults-mem-emphasis`: Uses the default parameter setting of CPLEX, but enables the parameter for memory saving throug `set emphasis memory yes`
- `cplex-defaults-1thread`: Same as `cplex-defaults`, but limit the processeing to one thread

With these results, we combined a few configurations to design other experiments, but in those experiments we also consider additional components: `warmstart` reflects a configuration that includes a MIP warmstart from a feasible solution; `softcut` indicates a setting with all cut generation set to 1 "moderate", but with clique cut generation and probing procedures disabled; `CUT` indicates an experiment that includes additional redundant cuts into the model.

- `cplex-defaults-mem-emphasis-1thread`: combines `cplex-defaults-mem-emphasis` and `cplex-defaults-1thread`
- `cplex-defaults-mem-emphasis-1thread-warmstart`: combines `cplex-defaults-mem-emphasis-1thread` with `warmstart`
- `cplex-softcut-mem-emphasis-1thread-warmstart`: like `cplex-defaults-mem-emphasis-1thread-warmstart` but with `softcut`
- `logs-cplex-softcut-CUT-mem-emphasis-1thread-warmstart`: like `cplex-softcut-mem-emphasis-1thread-warmstart` but with `CUT`


## Raw CSV datasets

Directory [raw-csv](raw-csv) contains raw CSV files generated from the experiment logfiles.

## Raw logfiles

All these are stored in [logfiles](logfiles).

## Scripts for parsing logfiles

Directory [scripts](scripts) has a few python and shell scripts to parse the logfiles generated during the experiments.

