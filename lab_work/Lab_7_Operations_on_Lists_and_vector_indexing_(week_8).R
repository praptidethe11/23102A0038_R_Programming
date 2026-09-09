#Week 8: Operations on Lists and Vector Indexing

#OPERATIONS ON LISTS

list1 = list(1,2,3)
list2 = list("water", "juice", "lemonade")
list1
list2

#merging lists using c()
list12 = c(list1, list2)
list12

#converting list to vector using unlist()
unlist(list1)
unlist(list2)
mode(list1)
mode(unlist(list1))

#appending an element to a list
append(list1, 100)
append(list2, "coffee")

#appending an element after a specific position
append(list1, 100, after = 2)
append(list2, "coffee", after = 2)

#removing an element from a list at a position
list1[-2]
list2[-1]

#extracting a range of elements from a list
list1 = list(1,2,3,4,5,6)
list1
list1[2:4]
list1[c(1,3,5)]

list2 = list("water", "juice", "lemonade", "tea", "coffee", "milk")
list2
list2[2:4]
list2[c(1,3,5)]

#VECTOR INDEXING

#vector and its values, logical indexing
x = 1:10
x
x[(x > 5)]
x[(x%%2==0)] #%% indicates x mod y, values for which x mod 2 is 0
x[(x%%2==1)] #values for which x mod 2 is 1

#vector with missing observations
x[5] = NA
x
y = x[!is.na(x)] #! means negation, removes missing value
y
mean(x)
mean(y)

#vector of negative integers
x = 1:10
x
x[-(1:5)]
#has the same outcome as
x[(6:10)]

#string vector: named list elements
z = list(a1 = 1, a2 = "c", a3 = 1:3)
z
names(z)

#changing the name of a specific element
names(z)[3] = "c2"
z

#named vector elements
x = c(water=1, juice=2, lemonade=3)
names(x)
x["juice"]

#empty index returns the whole vector
x = 1:10
x
x[]

#mixed mode: heterogeneous list given dimensions to form a matrix-like structure
ab = list(1, 2, 3, "X", "Y", "Z")
dim(ab) = c(2,3)
print(ab)
mode(print(ab))

#FACTORS

#basic factor from a numeric-coded example (colours)
colour_codes = c(1, 3, 3, 2, 1)  #Red=1, Blue=2, Green=3
colour_codes

#rolling a die seven times
y = c(1, 4, 3, 5, 4, 2, 4)
y

#possible values of upper face of die
possible.dieface = c(1, 2, 3, 4, 5, 6)
possible.dieface

#labels for the dice faces
labels.dieface = c("one", "two", "three", "four", "five", "six")
labels.dieface

#constructing the factor variable using levels and labels
facy = factor(y, levels = possible.dieface, labels = labels.dieface)
facy

#compare with the original numeric vector
y

#turning a numeric vector into a factor using as.factor()
x = c(3, 4, 5, 6, 1, 2, 3, 3, 4, 4, 5, 6)
x
yfac = as.factor(x)
yfac
#levels are ordered numerically here

#factor from character strings: levels ordered alphabetically by default
drinks = factor(c("lemonade", "lemonade", "juice", "lemonade", "water"))
drinks

#CLASS FUNCTION

class(9)
class("9")
class(print)
mat = matrix(nrow = 2, ncol = 2, data = 1:4)
class(mat)

#UNCLASS FUNCTION

brands = c("A", "A", "B", "B", "B", "B", "C")
brands
brands_fac = factor(brands)
brands_fac

#unclass converts the factor to its underlying integer codes
unclass(brands_fac)

#using the codes to map to another vector (colours)
colours = c("grey", "pink", "red")
colours
colours[unclass(brands_fac)]

#unclass on the drinks factor
unclass(drinks)

#FACTORS WITH CUSTOM LEVEL ORDER

drinks2 = factor(c("lemonade", "lemonade", "juice", "lemonade", "water"),
                 levels = c("water", "juice", "lemonade"))
drinks2
unclass(drinks2)
levels(drinks2)

#ORDERED FACTORS

income = ordered(c("high", "high", "low", "medium", "medium"),
                 levels = c("low", "medium", "high"))
income
unclass(income)

#FORMATTING AND DISPLAY OF STRINGS

#print function: numbers
print(sqrt(2))
print(sqrt(2), digits = 5)
print(pi, digits = 20)

#print function: characters
print("apple")
print(c("apple", "banana"))
print(c("apple", "banana", 6, 10))

#format function: controlling decimal places
print(format(0.5, digits = 10, nsmall = 15))

#format function: width and justify = "centre"
format(c("A", "BB", "CCC", "DDDD"), width = 7, justify = "centre")
format(c("A", "BB", "CCC", "DDDD"), width = 14, justify = "centre")

#format function: comparing justify options
format(c("A", "BB", "CCC", "DDDD"), width = 7, justify = "centre")
format(c("A", "BB", "CCC", "DDDD"), width = 7, justify = "left")
format(c("A", "BB", "CCC", "DDDD"), width = 7, justify = "right")
format(c("A", "BB", "CCC", "DDDD"), width = 7, justify = "none")

#printing a matrix
m = matrix(nrow = 3, ncol = 2, data = 1:6, byrow = TRUE)
print(m)

#FORMATTING AND DISPLAY OF LARGE QUANTITIES

#big.mark with comma separator
format(1234567, big.mark = ",")
format(12345678, big.mark = ",")
format(123456789, big.mark = ",")

#big.mark with space separator
format(123456789, big.mark = " ")