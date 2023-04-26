# Load packages
library(tidyverse)
library(NHANES)

# Looking at data
glimpse(NHANES)

# Selecting columns
# Single column
select(NHANES, Age)
# Multiple columns
select(NHANES, Age, Weight, BMI)

# Excluding a column by using minus (-)
# Excluding head circumference
select(NHANES, -HeadCirc)

# Select helpers can help select columns based on common patterns in the variables
# This comes from the tidyselect package in tidyverse. Some examples:
# starts_with(): Select columns that begin with a pattern.
# ends_with(): Select columns that end with a pattern.
# contains(): Select columns that contain a pattern.

# Select all columns starting with letters "BP" (blood pressure). Quotes are added
# when we want to search for something
select(NHANES, starts_with("BP"))
# NHANES$XX <-- this is the base way to select columns.

# Select all columns ending in letters "Day"
select(NHANES, ends_with("Day"))

# Select all columns containing letters "Age"
select(NHANES, contains("Age"))


# Selecting data doesn't change the dataset and only prints thing to the
# console but disappear. If we want to save the information in a new data
# set, we create an object (<-). In this case, we'll create a data frame with
# specific columns we choose with select()
nhanes_small <- select(
  NHANES, Age, Gender, BMI, Diabetes, PhysActive,
  BPSysAve, BPDiaAve, Education
)
# View the new data frame
nhanes_small


# Renaming columns
# In the interests of keeping data tidy and matching the style guide, we
# should change the column names to be all lower case with _ for spaces
# between words. There’s a package that can do that for us called snakecase.
# To change all the column names to snakecase, we’ll use the function
# rename_with(). This function takes the data as the first argument but the
# second argument needs to be a function, which in our case is called
# snakecase::to_snake_case(), but exclude the () at the end. This function
# will rename all columns.
# Rename all columns to snake case
nhanes_small <- rename_with(nhanes_small, snakecase::to_snake_case)
# If you want to give a function to another function without a specific argument,
# e.g. want to rename everything, you should not have a () after to_snake_case

# Have a look at the data frame
nhanes_small


# Renaming specific columns
# rename() takes the dataset as the first argument and then takes as many
# renaming arguments as you want (because the second argument position is ...).
# When renaming, it takes the form of newname = oldname.
# The “gender” variable in the dataset actually describes “sex”, so let’s rename
# it to accurately reflect the data itself.
nhanes_small <- rename(nhanes_small, sex = gender)
nhanes_small


# Using the pipe operator from Magrittr
colnames(nhanes_small) # can be written more tidy as:
nhanes_small %>% colnames()

# Using the pipe with the select() and rename() functions from before.
# Remember, both select() and rename() take a dataset as the first argument,
# which makes them pipe-able.
nhanes_small %>%
  select(phys_active) %>%
  rename(physically_active = phys_active)



# Chapter 7.8 exercise
# 1. Replace the ___ in the select() function, with the columns bp_sys_ave,
# and education.
nhanes_small %>% select(bp_sys_ave, education)

# 2. Rename the bp_ variables so they don’t end in _ave, so they look like
# bp_sys and bp_dia. Tip: Recall that renaming is in the form new = old.

nhanes_small %>% rename(bp_sys = bp_sys_ave, bp_dia = bp_dia_ave)

# 3. Re-write this piece of code: select(nhanes_small, bmi, contains("age"))
# using the “pipe” operator:
nhanes_small %>% select(bmi, contains("age"))

# 4. Read through (in your head) the code below. How intuitive is it to read?
blood_pressure <- select(nhanes_small, starts_with("bp_"))
# This creates an object dataset named blood_pressure containing all columns
# that starts with "bp_"
rename(blood_pressure, bp_systolic = bp_sys_ave) # this renames bp_sys_ave to
# bp_systolic withing the blood_pressure data frame I just created.
# Now, re-write this code so that you don’t need to create the temporary
# blood_pressure object by using the pipe, then re-read the revised version.
nhanes_bp <- nhanes_small %>%
  select(starts_with("bp_")) %>%
  rename(bp_systolic = bp_sys_ave)
# Which do you feel is easier to “read”?
# The tidy code is shorter and contains fewer steps.

# 5. Run styler on the R/learning.R file with Ctrl-Shift-P, then type “style file”.
# Complete. Console output: styler::style_active_file()
# 6. Lastly, add and commit these changes to the Git history with the '
# RStudio Git interface (Ctrl-Shift-P, then type “commit”).


# Filtering. Filter or subset data based on the data contained inside rows
# To do so, we need to understand logic. Meaning that we need to understand how
# a computer looks at logic; is it TRUE or FALSE?
# Table 7.1 contains information on logical operators in R

# Examples
# Participants who are not physically active (has answered "no")
nhanes_small %>%
    filter(phys_active == "No")
# Participants who have BMI equal to 25
nhanes_small %>%
    filter(bmi == 25)
# Participants who have BMI equal to or more than 25
nhanes_small %>%
    filter(bmi >= 25) #always size before =


# Combining logical operators
# We use the | (“or”) and & (“and”) when we want to combine conditions across
# columns. Be careful with these operators and when combining logic conditions,
# as they can sometimes work differently than our human brains interpret them
# (speaking from experience).
# When BMI is 25 or above AND phys_active is No
nhanes_small %>%
    filter(bmi >= 25 & phys_active == "No")
#For &, both sides must be TRUE in order for the combination to be TRUE.
# For |, only one side needs to be TRUE in order for the combination to be TRUE.
nhanes_small %>%
    filter(bmi>=25 | phys_active=="No")


# Arranging data
    # arrange ascending by age
nhanes_small %>%
    arrange(age)
    # arrange descending by age
nhanes_small %>%
    arrange(desc(age))
    #multiple columns
nhanes_small %>%
    arrange(education, age)
# Arranging is only visually, not saved in data


# Transforming data
    #Add column using mutate
nhanes_small %>%
    mutate(age= age*12) #this will overwrite age with age*12 (age in months)
    #Multiple mutations
nhanes_small %>%
    mutate(age=age*12,
           log_bmi=log(bmi))

# We can also add a logical condition inside mutate
nhanes_small %>%
    mutate(old=if_else(age>=30, "Yes", "No")) #if_else is the logical condition
styler::style_active_file()



# Exercise 7.12
#   Copy and paste the code below into the learning.R script file.
# 1. BMI between 20 and 40 with diabetes
nhanes_small %>% # Format should follow: variable >= number or character
    filter(bmi>=20& bmi<= 40 & diabetes == "Yes")

# Pipe the data into mutate function and:
nhanes_modified <- nhanes_small %>% # Specifying dataset
    mutate(mean_arterial_pressure=((2*bp_dia_ave)+bp_sys_ave)/3,
           young_child=if_else(age<=6, "Yes", "No")
    )
nhanes_modified


# Finally, add and commit these changes to the Git history with the RStudio
# Git Interface. Push to GitHub to synchronize with your GitHub repository.


# Calculating summary statistics
nhanes_small %>%
    summarise(max_bmi = max(bmi)) #max() is a function in R
# We get back a result of NA, which means “missing”. In R, NA values
# “propagate”, meaning that if there is one value missing, then the max or
# mean will also be missing. So, we need to tell max() to exclude any NA
# values from the calculation using the argument na.rm = TRUE.

nhanes_small %>%
    summarise(max_bmi = max(bmi, na.rm = TRUE),
              min_bmi = min(bmi, na.rm = TRUE)) #na.rm = TRUE <-- remove all
# missing values before running the command

# Split apply combine
nhanes_small %>%
    group_by(diabetes) %>%
    summarise(mean_age=mean(age, na.rm=TRUE),
              mean_bmi=mean(bmi, na.rm=TRUE))
#this gives a NA in the outcome, but we can filter the NA out by adding a filter
#to the code:
nhanes_small %>%
    filter(!is.na(diabetes)) %>% #shows all results where diabetes is not NA
    group_by(diabetes) %>%
    summarise(mean_age=mean(age, na.rm=TRUE),
              mean_bmi=mean(bmi, na.rm=TRUE)) %>% #This has grouped the data,
    ungroup() # it is good custom to combine data again


# Saving data
readr::write_csv(nhanes_small, here::here("data/nhanes_small.csv"))
    #Saves nhanes_small as csv in data folder

