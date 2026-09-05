#Basics of Calculations with Data vectors
#Addition, Subtraction, Multiplication & Division

#Addition with data vectors
c(2,3,4,5) + c(6,7,8,9)

#Power Operator (^ or **)
2^3 
2**3 
4^0.5
4^-0.5

#Power Operator on a vector
c(2,3,4,5)**2

#Power Operator on a vector with a vector
c(2,3,4,5)**c(2,3)  #alternate powers are used
c(2,2,4,9)**c(0,1,2,3)
c(1,2,3,4,5,6)**c(0,1,2,3) #warning msg- "longer object length is not a multiple of shorter object length"

#Integer Division with scalar (%/%)
2%/%2
5/2 #includes the decimal part aswell
5%/%2 #doesn't include the decimal part
c(0,2,4,8,10)%/%2
c(1,2,3,4,5)/2

#Integer divison with data vector
c(1,2,3,4,5)%/%c(2,3)
c(1,2,3,4,5)/c(2,3) 

#Modulo Division (x mod y) with scalars (%%)
#returns remainder
2%%2
3%%2
c(2,3,4,5)%%2
c(6,7,8,9)%%c(2,3)

#Maximum operator (max)
max(1,4,-5, 100.0, 67)

#Minimum operator (min)
min(0,-2,-4,-100.0, 1000)

#Arithmetic Mean (mean)
mean(1,2,3) #gives wrong result because c is not used
mean(c(1,2,3))

#Absolute Value
abs(-100.67)

#Square root
sqrt(0.64)

#Rounding, up and down (round, floor, ceiling)
round(1.5)
floor(2.6) #rounds off to lower limit
ceiling(2.6) #rounds off to higher limit

#logarithimic function (log)
log(10)
log(exp(1))
log(c(10,100,1000))

#Assignment
x1 = c(1,2,3,4)
x2 = c(x1^2)
print(x2)

#Matrix (matrix, nrow, ncol)
x = matrix ( nrow=4, ncol=2, data=c(1,2,3,4,5,6,7,8))
x
x[3,2]
y = matrix( nrow=4, ncol=2, data=c(1,2,3,4,5,6,7,8), byrow=FALSE)
y

#Properties of matrix
dim(x) #dimension of matrix
nrow(y) #number of rows
ncol(y) #number of cols
mode(y)
attributes(x)
help("matrix")



