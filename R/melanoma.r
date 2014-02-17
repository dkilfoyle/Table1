suppressMessages(library(boot))

data(melanoma, package="boot")

# Set time to years instead of days
melanoma$time_years <- 
  melanoma$time / 365.25

# Factor the basic variables that 
# we're interested in
melanoma$status <- 
  factor(melanoma$status, 
         levels=c(2,1,3),
         labels=c("Alive", # Reference
                  "Melanoma death", 
                  "Non-melanoma death"))
melanoma$sex <- 
  factor(melanoma$sex,
         labels=c("Male", 
                  "Female"))

melanoma$ulcer <- 
  factor(melanoma$ulcer,
         labels=c("Present", 
                  "Absent"))