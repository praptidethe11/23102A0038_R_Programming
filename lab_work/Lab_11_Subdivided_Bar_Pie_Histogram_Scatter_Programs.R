#Week 12: Subdivided Bar Plots, Pie Diagrams, Combining Graphics, Histograms, Bivariate and 3D Plots, Writing Programs

#SUBDIVIDED OR COMPONENT BAR DIAGRAM

#a subdivided (component) bar diagram divides the total magnitude of a variable into parts
#each bar is split into sections, the sections show the values in cumulative form
#Usage: barplot(variable in matrix format)
#each column of the matrix becomes one bar, the rows become the sections inside the bar

#number of customers visiting 3 shops during 10-11 AM on 4 consecutive days
#rows are days (Day 1 to Day 4), columns are shops (Shop 1 to Shop 3)
cust = matrix(nrow = 4, ncol = 3,
              data = c(2, 20, 30, 26, 53, 40, 42, 15, 25, 30, 75, 100),
              byrow = TRUE)
cust

#3 bars, one per shop, each bar is stacked over the 4 days
barplot(cust)
#height of the Shop 1 bar is 2+26+42+30 = 100, Shop 2 is 20+53+15+75 = 163, Shop 3 is 30+40+25+100 = 195

#adding labels and colours, one colour per section (day)
barplot(cust, names.arg = c("Shop 1", "Shop 2", "Shop 3"),
        col = c("red", "green", "orange", "brown"))

#naming the rows lets us put a legend for the days
rownames(cust) = c("Day 1", "Day 2", "Day 3", "Day 4")
colnames(cust) = c("Shop 1", "Shop 2", "Shop 3")
cust
barplot(cust, col = c("red", "green", "orange", "brown"),
        legend.text = rownames(cust),
        xlab = "Shops", ylab = "No. of customers",
        main = "Customers visiting the shops")

#PIE DIAGRAM

#pie charts show the absolute and relative frequencies of the categories
#the pie is a circle divided into segments, one segment per category
#the angle of each segment depends on the relative frequency, angle = relative frequency * 360 degrees
#Usage: pie(x, labels = names(x), ...)

#10 persons coded as 1 for male (M) and 2 for female (F)
#M, F, M, F, M, M, M, F, M, M
gender = c(1, 2, 1, 2, 1, 1, 1, 2, 1, 1)
gender

#pie on the raw data draws one segment per observation, usually not what we want
pie(gender)

#pie on the table draws one segment per category
pie(table(gender))

#pizza home delivery, 3 branches: East = 1, West = 2, Central = 3
direction = c(1,1,2,1,2,3,2,2,3,3,3,1,2,3,2,2,3,1,1,1,3,3,3,2,2,2,2,1,2,2,1,1,1,3,2,2,1,2,2,3,3,2,1,2,2,3,1,1,2,1,2,3,2,3,2,2,3,1,2,1,1,1,2,1,1,2,1,2,3,3,1,2,3,3,2,1,2,2,2,2,2,3,2,2)
table(direction)
pie(table(direction))

#adding colours with col and a title with main
pie(table(direction), col = c("red", "green", "blue"),
    main = "Directions of food delivery")

#COMBINING GRAPHICS

#par() sets the graphical parameters, mfrow puts multiple graphs in a single plot
#Usage: par(mfrow = c(p, q)) divides the plotting area into a p*q array (p rows, q columns)

#plotting area as a 1*2 array, bar plot and pie chart side by side
par(mfrow = c(1, 2))
barplot(table(direction))
pie(table(direction))

#plotting area as a 2*1 array, one below the other
par(mfrow = c(2, 1))
barplot(table(direction))
pie(table(direction))

#go back to one plot per window
par(mfrow = c(1, 1))

#HISTOGRAM

#a histogram categorizes continuous data into groups and draws a bar for each group
#area of the bar (height * width) is proportional to the frequency or relative frequency
#so the widths of the bars need not be the same
#Usage: hist(x) shows absolute frequencies
#Usage: hist(x, freq = F) shows relative frequencies (density)
#Usage: hist(x, main, col, xlab, xlim, ylim)

#x is a numeric vector, main is the title, col is the colour of the bars
#xlab is the label of the x axis, xlim and ylim are the ranges of the x and y axes
#help("hist") lists all the arguments

#heights of 50 persons in cm
height = c(166,125,130,142,147,159,159,147,165,156,149,164,137,166,135,142,133,136,127,143,165,121,142,148,158,146,154,157,124,125,158,159,164,143,154,152,141,164,131,152,152,161,143,143,139,131,125,145,140,163)
length(height)

hist(height)

#relative frequencies
hist(height, freq = F)

#adding colour, title and axis labels
hist(height, main = "Heights of persons", col = "green",
     xlab = "Heights", ylab = "Number of Persons")

#density is the number of shading lines per inch, non-positive values stop the shading lines
hist(height, main = "Heights of persons", col = "red",
     xlab = "Heights", ylab = "Number of Persons", density = 2)

#increasing the density
hist(height, main = "Heights of persons", col = "red",
     xlab = "Heights", ylab = "Number of Persons", density = 8)

#angle is the slope of the shading lines in degrees (counter-clockwise)
hist(height, main = "Heights of persons", col = "red",
     xlab = "Heights", ylab = "Number of Persons", density = 8, angle = 100)

#BIVARIATE PLOTS: ASSOCIATION OF TWO VARIABLES

#examples of association: hours of study and marks, temperature and power consumption, height and weight of children
#graphical procedures: two dimensional plots, three dimensional plots
#quantitative procedures: correlation coefficients, contingency tables, chi-square statistic, regression

#a scatter plot plots the paired observations (x1,y1), (x2,y2), ..., (xn,yn) in a single graph
#it shows the nature (linear or nonlinear), direction (positive or negative) and strength of the relationship

#SCATTER PLOT WITH plot(x, y)

#Usage: plot(x, y)
#Usage: plot(x, y, type)
#x and y are two data vectors of the same length
#type "p" points, "l" lines, "b" both points and lines, "c" the lines part alone of "b"
#type "o" both overplotted, "s" stair steps, "h" histogram like (high-density) vertical lines
#other options: main (title), sub (subtitle), xlab, ylab, asp (the y/x aspect ratio)
#help("plot") has more details

#marks obtained by 20 students out of 500 and the number of hours studied per week
marks = c(337,316,327,340,374,330,352,353,370,380,384,398,413,428,430,438,439,479,460,450)
hours = c(23,25,26,27,30,26,29,32,33,34,35,38,39,42,43,44,45,46,44,41)
length(marks)
length(hours)

#marks tend to increase as the number of hours increases
plot(hours, marks)

#different types of plot
plot(hours, marks, "l")  #lines
plot(hours, marks, "b")  #both points and lines
plot(hours, marks, "o")  #both, overplotted
plot(hours, marks, "h")  #histogram like vertical lines
plot(hours, marks, "s")  #stair steps

#adding a title and axis labels
plot(hours, marks, xlab = "Number of weekly hours", ylab = "Marks obtained",
     main = "Marks obtained versus Number of hours per week")

#MATRIX SCATTER PLOT

#pairs() creates a matrix of scatter plots, one for each pair of variables
pairs(cbind(hours, marks))

#adding labels and colour
pairs(cbind(hours, marks), labels = c("Study hours", "Marks obtained"), col = "red")

#SCATTER PLOT WITH A SMOOTH CURVE

#scatter.smooth draws the scatter plot and adds a smooth curve showing the trend of the relationship
#it is based on LOESS, a locally weighted scatterplot smoothing method
#LOESS fits local polynomial regression, a polynomial surface is determined by one or more numerical predictors using local fitting
#Usage: scatter.smooth(x, y = NULL, span = 2/3, degree = 1, family = c("symmetric", "gaussian"), xlab = NULL, ylab = NULL, ylim = ...)

#span is the smoothness parameter for LOESS, degree is the degree of the local polynomial
#family "symmetric" uses a re-descending M estimator, "gaussian" uses least squares fitting
#help("scatter.smooth") has more details
scatter.smooth(hours, marks)

#more options for the curve through lpars
scatter.smooth(hours, marks, lpars = list(col = "red", lwd = 3, lty = 3))

#THREE DIMENSIONAL SCATTER PLOT

#scatterplot3d plots a three dimensional point cloud of the data in x, y and z
#needs the package scatterplot3d, install once, then load with library each session
#install.packages("scatterplot3d")
library(scatterplot3d)

#Usage: scatterplot3d(x, y, z)

#height (cm), weight (kg) and age (years) of 5 persons
height3 = c(100, 125, 145, 160, 170)
weight3 = c(30, 35, 50, 65, 70)
age3 = c(10, 15, 20, 30, 35)

scatterplot3d(height3, weight3, age3)

#angle changes the direction of the figure
scatterplot3d(height3, weight3, age3, angle = 120)

#color changes the colour of the points
scatterplot3d(height3, weight3, age3, color = "red")

#MORE GRAPHICS FUNCTIONS

#contour() for contour lines
#dotchart() for dot charts (replacement for bar charts)
#image() for pictures with colours
#mosaicplot() for mosaic plots of categorical variables (contingency tables)
#persp() for perspective surfaces over the x-y plane (third dimension is z)

#PERSPECTIVE PLOT

#plot of the surface z = 10*sin(r)/r where r = sqrt(x^2 + y^2)
x = seq(-10, 10, length = 30)
y = x
f = function(x, y) {
  r = sqrt(x^2 + y^2)
  10 * sin(r)/r
}
z = outer(x, y, f)  #value of f for every combination of x and y
z[is.na(z)] = 1     #at x = y = 0 the value is 0/0 = NaN, replace it by 1
op = par(bg = "white")

#theta and phi are the viewing angles, expand is the expansion factor for the z axis
persp(x, y, z, theta = 30, phi = 30, expand = 0.5, col = "lightblue")

#ltheta is the direction of the light source, shade is the shading of the surface
#ticktype = "detailed" shows tick marks and values on the axes
persp(x, y, z, theta = 30, phi = 30, expand = 0.5, col = "lightblue",
      ltheta = 120, shade = 0.75, ticktype = "detailed",
      xlab = "X", ylab = "Y", zlab = "Sinc( r )")

#SOME EXAMPLES OF R PROGRAMMING

#STEPS TO WRITE A PROGRAM

#a program is a set of instructions or commands based on input variables
#they are given in a sequence of operations, the objective of the program is defined first
#R works like an interpreter between us and the computer
#we say something in R's language, R translates it to the computer, the computer does the task
#and R translates the result back to us

#1. identify the objective, i.e., what we want to obtain as an outcome
#2. identify the input and output variables
#3. identify the nature of the variables, i.e., numeric, string, factor, matrix etc.
#4. write the program in R as a function using function()

#input and output variables can be a single value, a vector, a matrix or even a function
#the input variables are the arguments of function()
#the output can be formatted as per the need, for example with cat()

#TIPS
#loops usually slow down the program, better to use vectors and matrices where possible
#use variable names which are easy to understand
#use the symbol # to write comments
#do not forget to initialize the variables

#EXAMPLE 1

#for two data vectors x = (x1, ..., xn) and y = (y1, ..., yn) compute
#g = sum(x^2)/sum(y^2)
#h = sum((x/y)^2)

#input variables: x, y (and n, the number of observations, found from length(x))
#output variables: g and h
#we need summation, so use the sum function

#remove all objects
rm(list = ls())

#++++++START OF FUNCTION++++++++
example1 = function(x, y) {
  #computation of the number of observations
  n = length(x)

  #initialize the vectors to store the squared values
  x1 = 0
  y1 = 0
  z1 = 0

  #start of loop
  for (i in 1:n) {
    x1[i] = x[i]^2
    y1[i] = y[i]^2
    z1[i] = (x[i]/y[i])^2
  }
  #end of loop

  #sums of the squared quantities
  sum_square_x = sum(x1)
  sum_square_y = sum(y1)
  sum_square_z = sum(z1)

  #computation of g and h
  g = sum_square_x/sum_square_y
  h = sum_square_z

  #format the output
  cat("The value of g and h are", g, "and", h, "respectively", "\n")
}
#++++++END OF FUNCTION++++++++

#run the function for different data
x = c(10, 20, 30)
y = c(1, 2, 3)
example1(x, y)  #g = 100 and h = 300

x = c(67, 87, 26, 85, 6, 45)
y = c(54, 64, 22, 94, 20, 88)
example1(x, y)  #g = 0.8996568 and h = 5.953203

#just by changing the values of x and y we get different outcomes

#the same thing without a loop, using vectors (faster)
example1_vec = function(x, y) {
  g = sum(x^2)/sum(y^2)
  h = sum((x/y)^2)
  cat("The value of g and h are", g, "and", h, "respectively", "\n")
}
example1_vec(c(10, 20, 30), c(1, 2, 3))
