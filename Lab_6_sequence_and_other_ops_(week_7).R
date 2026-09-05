#Week 7: Sequences, Repeats, Sorting, Ordering, Mode and Lists

#SEQUENCES
#syntax: seq(from=1, to=1, by=((to-from)/(length.out-1)), length.out=NULL, along.with=NULL)

#continuous sequences with constant unit increment
1:10
10:1
5:15
15:5
-1:-10
-10:-1

#decimal sequences with unit increment
1.23:10
1.23:10.54
10.54:2.23
-1.23:-10

#seq(10) same as seq(1:10)
seq(10)
seq(1:10)

#sequence with predefined variable and constant increment
x=2
seq(1, x, x/10)

x=50
seq(0, x, x/10)

#storing outcome of sequences
x = seq(1, 50, 1/2)
x
y = 2*x
y

#index vector
x = c(9,8,7,6)
ind = seq(along=x)
ind
x[ind[2]]

#generating current time and date
Sys.time()
Sys.Date()

#sequence of dates
seq(as.Date("2010-01-01"), as.Date("2017-01-01"), by = "years")
seq(as.Date("2017-01-01"), by = "days", length = 6)
seq(as.Date("2017-01-01"), by = "months", length = 6)
seq(as.Date("2017-01-01"), by = "years", length = 6)

#sequence with defined start and end date, decreasing
startdate = as.Date("2016-1-1")
enddate = as.Date("2017-1-1")
out = seq(enddate, startdate, by = "-1 month")
out

#sequence of alphabets
letters
letters[1:3]
letters[3:1]
letters[21:23]
letters[2]

LETTERS
LETTERS[1:3]
LETTERS[3:1]
LETTERS[21:23]
LETTERS[2]

#REPEATS
#syntax: rep(x, times=n), rep(x, each=n), rep(x, length.out=n)

rep(3.5, times=10)
rep(1:4, 2)

x = 1:4
rep(x, times = 3)
rep(x, each = 3)

#order of each and times matters
rep(1:4, each = 2)
rep(1:4, each = 2, times = 3)
rep(1:4, times = 3, each = 2)

#each element repeated a different number of times
rep(1:4, 2:5)
ans = seq(from=2, to=8, by=2)
ans
rep(1:4, ans)

#repeats on a matrix
x = matrix(nrow=2, ncol=2, data=1:4, byrow=T)
x
rep(x, 3)

#repetition of characters
rep(c("a", "b", "c"), 2)
rep(c("apple", "banana", "cake"), 2)

#repetition for pre-specified length
rep(2, length.out=5)
rep(2, length=5)
rep(c(2,3), length=5)
rep(c(2,3,4), length=5)
rep("apple", length=5)
rep(c("a", "b", "c"), length=2)
rep(c("a", "b", "c"), length=5)

#SORTING
#syntax: sort(x, decreasing=FALSE, na.last=NA)

y = c(8,5,7,6)
y
sort(y)
sort(y, decreasing = TRUE)

#ORDERING
#syntax: order(x, decreasing=FALSE, na.last=TRUE)

y = c(9,8,5,7,6)
y
order(y)
order(y, decreasing = TRUE)

#MODE
#mode() tells how an object is stored in memory

mode(2.432)
mode(c(3,4,5,6,7,8))
mode("India")
mode(c("India", "CANADA"))
mode(factor(c("UP", "MP")))
mode(list("India", "USA"))
mode(data.frame(x=1:2, y=c("India", "USA")))
mode(print)

#LISTS
#lists can hold elements of different modes, unlike vectors

x1 = matrix(nrow=2, ncol=2, data=1:4, byrow=T)
x2 = matrix(nrow=2, ncol=2, data=5:8, byrow=T)
x1
x2
x1+x2

#assigning a character into a numeric matrix coerces the whole matrix
x1[2,1] = "hello"
x1
#x1+x2 would now throw an error since x1 is no longer numeric

#lists containing matrices
x1 = matrix(nrow=2, ncol=2, data=1:4, byrow=T)
x2 = matrix(nrow=2, ncol=2, data=5:8, byrow=T)
matlist = list(x1, x2)
matlist
matlist[1]
matlist[2]

#lists with mixed object types
z1 = list(c("water", "juice", "lemonade"), rep(1:4, each=2), matrix(data=5:8, nrow=2, ncol=2, byrow=T))
z1

#accessing list elements: [[ ]] vs [ ]
z1[[1]]
z1[1][2]   #wrong way, returns NULL
z1[[1]][2] #correct way, returns "juice"