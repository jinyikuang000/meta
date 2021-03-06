## ------------------------------------------------------------------------

## Specify the file containing your data
filename <- "dataOR.csv"

### Specify the columns containing the Study ID and count of events, non-events, and n for control and intervention within the file

col.int.event     <- "Intervention.Event"
col.int.nonevent  <- "Intervention.NonEvent"
col.int.n         <- "Intervention.N"
col.cont.event    <- "Control.Event"
col.cont.nonevent <- "Control.NonEvent"
col.cont.n        <- "Control.N"
col.study.id      <- "Study.ID"


### Specify the effect size measure

## Options in this template are OR (Odds Ratio), RD (Risk Difference), RR (log
## Relative Risk), AS (Arsine Square-root transformed risk difference), and PETO
## (log odds ratio using Peto's Method).

measure <- "OR"

## Metafor can support more diverse catagorical outcome data see help(escalc)
## for detail

### Specify the model type. 
## In most cases REML should be the default

## Options in this template are 

# method <- "FE" # Fixed effect meta-analysis
# method <- "REML" # Default random effects meta-analysis
# method <- "DL" #  DerSimonian-Laird estimator
# method <- "HE" # Hedges estimator
# method <- "HS" # Hunter-Schmidt estimator
# method <- "SJ" # Sidik-Jonkman estimator
# method <- "ML" # maximum-likelihood estimator
# method <- "REML" # restricted maximum-likelihood estimator
# method <- "EB" # empirical Bayes estimator
# method <- "PM" # Paule-Mandel estimator
# method <- "GENQ" # generalized Q-statistic estimator

method <- "REML"


## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(metafor)
library(DT)
library(knitr)
library(RCurl)
library(dplyr)
library(rmarkdown)

## These lines of code download and run the metafor_tidiers functions that implement broom type tidy data functions for rma objects
source("metafor_tidiers.R")

# Set so that long lines in R will be wrapped:
opts_chunk$set(tidy.opts = list(width.cutoff = 80), tidy = TRUE)


## ----read_data-----------------------------------------------------------
dat <- read.csv(filename, stringsAsFactors = FALSE)

## ----calculate_ES--------------------------------------------------------
  dat_ES <-
    escalc(
    measure = measure,
    ai  = get(col.int.event),
    bi  = get(col.int.nonevent),  
    n1i = get(col.int.n),  
    ci  = get(col.cont.event),
    di  = get(col.cont.nonevent),  
    n2i = get(col.cont.n),  
    data = dat
    )

## ----dat_es_html, echo = FALSE, warning = FALSE--------------------------
datatable(dat_ES %>% 
            select(-one_of(c("X", "Timestamp"))), rownames = FALSE)  %>% 
                formatRound('yi', 3) %>% 
                  formatRound('vi', 3)

## ----run_MA--------------------------------------------------------------
dat_MA <- rma(yi, vi, data = dat_ES, slab = get(col.study.id), method=method)
dat_MA

## ----convenience, echo=FALSE---------------------------------------------
##These are some convenience functions that help put things into tables for easier interpretation.

model <- tidy.rma(dat_MA)

het.small <- glance.rma(dat_MA) %>% 
  select(one_of(c("k", "tau2", "se.tau2", "QE", "QEp", "I2")))


## ----summary_table, echo=FALSE-------------------------------------------
kable(model, col.names=c("*OR*", "se", "z", "*p*", "95% CI LB", "95% CI UB"), row.names=FALSE, digits = 3, caption="Effect Size")

## ----het_table, eval=dat_MA$method!="FE", echo=FALSE---------------------
kable(het.small, col.names=c("k", "$\\tau$^2^", "se", "Q", "*p*", "I^2^"), digits = 3, caption="Heterogeneity")

## ----forest, warning = FALSE, fig.height = (het.small$k*0.5)-------------
forest(dat_MA)

## ----funnel--------------------------------------------------------------
funnel(dat_MA, back="white")

## ----include=FALSE-------------------------------------------------------
citPkgs <- names(sessionInfo()$otherPkgs)
write_bib(citPkgs, file="R-Pckgs.bib")

