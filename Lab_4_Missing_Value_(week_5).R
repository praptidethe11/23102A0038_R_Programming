#Week 5 NPTEL
#Basic Calculations: Missing Data Handling

#Missing Data
#is.na() detects missing values

x = NA
is.na(x)

x= c(11, 12, NA, 13, NA)
is.na(x)
mean(x, na.rm= TRUE)

#NA vs NULL
#they are not the same 
#NA: placeholder ; NULL: stands for nothing

#to identify location of NAs, which() is used
x= c(11, 12, NA, 13, NA)
x
which(is.na(x))

#to count number of NAs, sum() is used
sum(is.na(x))

#complete.cases() returns the complete cases as true in the logical vector
complete.cases(x)

#na.omit() deletes NAs and returns the new vector
y = na.omit(x)
y

#Conditional Executions: if and if-else
## Control Structures in R

#Condition execution: if()
a= 5
if(a>4){
  b= a*3
  print("the value is 3 times more")
  b
}

#condition execution: if else()
a=100
if(a==100){
  a=a-1
} else a = 2*a
a

#condition execution: nested if else()
a=5
if(a==2){
  a=a-1
}else if(a>2){
  a=a+5
}else a=2*a
a

#condition execution: ifelse()
##syntax- ifelse(test, yes, no)
x= 1:10
x
ifelse(x<6, x**2, x-1)

#Conditional Executions: switch and which commands
##switch is a substitute for long if statements, its a branch statement
#syntax- switch(expr, case1, case2)

switch(2, "pink", "yellow", "orange")
switch(1, "pink", "yellow", "orange")
switch("gender", "color"="blue", "age"=40, "gender"="female")


##which() function returns the position of the elements in a logical vector

x= 10:22
x
which(x==14)
which(x!=19)

## in case of matrices
x= matrix(nrow=5, ncol=2, data=1:20)
x
which.min(x)
which.max(x)
which(x%%2==1)