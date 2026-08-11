#Basics of Calculations

#A) MATRIX OPERATIONS
#1) row, column and other operations
#Renaming the row and column names
x = matrix( nrow=4, ncol=3, data=c(1:12)) #1:12 means numbers from 1 to 12
x

rownames(x) = c("r1", "r2", "r3", "r4")
colnames(x) = c("c1", "c2", "c3")
x

#Assigning a specified number to all matrix elements
y = matrix( nrow=4, ncol=2, data=2)
y

#Diagonal matrix 
d = diag(5, nrow=3, ncol=3)
d

#Transpose of matrix x
xt= t(x)
xt

#row and column sums
rowSums(x)
colSums(x)

#row and column means
rowMeans(x)
colMeans(x)

#2)Access and Mathematical Operations
a = matrix(nrow=3, ncol=2, data=1:6)
a
a[3,]
a[,2]
a[2:3, 1:2]
a+2
a-10
a*0
a/10

#addition and subtraction of matrices
b = matrix(nrow=4, ncol=2, data=(1:8))
b
c = matrix(nrow=4, ncol=2, data=(4:11))
c
b+c
b-c
b*c
b/c
4*b+c
4*c-c
t(b)
t(b) %*% c
crossprod(c)

#Concatenating Matrices
rbind(b,c)

#inverse of a matrix
solve(a) #error comes because it requires a square matrix
d = matrix(nrow=2, ncol=2, data=1:4)
solve(d)

#eigen values and eigen vectors 
eigen(d)

#B) LOGICAL OPERATORS
#consists of greater than, less than, equal, not equal, negation, and, or, xor,etc.

x=8
(x>10) || (x>2) 
(x<10) | (x>2) 
(x>10) && (x>2)
(x>10) & (x>2)

y= 1:6
(y>2) & (y<5)
y[(y>2)&(y<5)]
(y>2) && (y<5) #error length = 6

#standard logical operations
x = TRUE
y = FALSE
x&y
x|y
!y
y=4
Logical1 = (2*y>10)
Logical1

#logical operations on vectors
a= c(1,2,3)
b = c(4,5,6)
a>b
a<b
a!=b
a==b