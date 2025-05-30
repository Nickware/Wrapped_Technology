# Install required Python packages for the R script
# Save the summary to a text file

library(reticulate)
py_install("pandas")
py_install("statsmodels")
py_install("matplotlib")