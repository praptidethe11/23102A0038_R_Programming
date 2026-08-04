# variables

x <- 10       # Numeric variable
y = "Hello"   # Character variable
z <- TRUE     # Logical variable

print(x) # Output: 10
print(y) # Output: "Hello"
print(z) # Output: TRUE

var1 <- 5       # Valid
var.name <- 10  # Valid (using dot)
# _var <- 20    # Invalid (starts with underscore)
# 2var <- 30    # Invalid (starts with a number)

Var <- 100
var <- 200
print(Var) # Output: 100
print(var) # Output: 200

a <- 15              # Using <-
b = 20               # Using =
10 -> a              # Using ->
assign("c", 25)      # Using assign() function

print(a) # 15
print(b) # 20
print(c) # 25

x <- 10               # x is numeric
x <- "R Programming"  # Now x is character
print(x) # Output: "R Programming"

# comments

# This is a single-line comment

# Multi-line comments can be written as:
# Line 1
# Line 2
# Line 3

x = 10
if (FALSE) {
  # This is a multi-line comment.
  # It won't be executed.
  x <- 5 + 10
}
print(x)

x <- 10       # Assigning 10 to x
y <- x * 2    # Doubling x and storing in y
print(y)      # Output: 20

# keywords

x <- 10
if (x > 5) {
  print("x is greater than 5")
} else {
  print("x is less than or equal to 5")
}
# Output: "x is greater than 5"

for (i in 1:5) {
  print(i)
}
# Output: 1 2 3 4 5

count <- 1
while (count <= 3) {
  print(paste("Count is", count))
  count <- count + 1
}
# Output: "Count is 1", "Count is 2", "Count is 3"

square <- function(x) {
  return(x * x)
}
print(square(4)) # Output: 16

for (i in 1:10) {
  if (i == 6) {
    break
  }
  print(i)
}
# Output: 1 2 3 4 5

for (i in 1:5) {
  if (i == 3) {
    next
  }
  print(i)
}
# Output: 1 2 4 5

# if <- 10           # Error: unexpected assignment in "if <-"
# TRUE <- 5          # Error: invalid assignment to 'TRUE'
# function <- "test" # Error: invalid assignment to 'function'

# arithmetic operators

a <- 10
b <- 3
print(a + b)   # 13
print(a - b)   # 7
print(a * b)   # 30
print(a / b)   # 3.333 (floating point division)
print(a ^ b)   # 1000
print(a %% b)  # 1 (remainder of integer division)
print(a %/% b) # 3 (quotient of integer division)

# relational operators

x <- 10
y <- 5
print(x == y)  # FALSE
print(x != y)  # TRUE
print(x > y)   # TRUE
print(x < y)   # FALSE
print(x >= y)  # TRUE
print(x <= y)  # FALSE

# logical operators

a <- TRUE
b <- FALSE
print(a & b)   # FALSE
print(a | b)   # TRUE
print(!a)      # FALSE
print(a && b)  # FALSE (stops if first condition is FALSE)
print(a || b)  # TRUE (stops if first condition is TRUE)

# assignment operators

x <- 10  # Standard assignment
20 -> y  # Right assignment
z = 30   # Alternative assignment
print(x) # 10
print(y) # 20
print(z) # 30

# miscellaneous operators

seq <- 1:5
print(seq) # 1 2 3 4 5

print(3 %in% c(1, 2, 3)) # TRUE

mat1 <- matrix(1:4, nrow = 2)
mat2 <- matrix(5:8, nrow = 2)
print(mat1 %*% mat2)
#      [,1] [,2]
# [1,]   19   22
# [2,]   43   50

# basic data types

num <- 10.5    # Numeric
int <- 5L      # Integer
char <- "Hello" # Character
bool <- TRUE   # Logical
comp <- 3 + 2i # Complex

print(class(num))  # "numeric"
print(class(int))  # "integer"
print(class(char)) # "character"
print(class(bool)) # "logical"
print(class(comp)) # "complex"

# special data types

x <- NULL # NULL
y <- NA   # Missing value
z <- Inf  # Infinity
w <- NaN  # Not a Number

print(x) # NULL
print(y) # NA
print(z) # Inf
print(w) # NaN

# composite data types

vec <- c(1, 2, 3)
print(vec) # 1 2 3

lst <- list(1, "a", TRUE)
print(lst) # [[1]] 1, [[2]] "a", [[3]] TRUE

mat <- matrix(1:4, nrow = 2)
print(mat)
# [,1] [,2]
# [1,]    1    3
# [2,]    2    4

df <- data.frame(name = c("Alice", "Bob"), age = c(25, 30))
print(df)
#    name age
# 1 Alice  25
# 2   Bob  30

fac <- factor(c("A", "B", "A"))
print(fac) # Levels: A B

# creating factors

gender <- factor(c("Male", "Female", "Male", "Female"))
print(gender)
# Output: Male Female Male Female
# Levels: Female Male

grades <- factor(c("A", "B", "A", "C", "B", "A", "B", "C"), levels = c("A", "B", "C", "D"))
print(grades)
# Output: A B A C B A B C
# Levels: A B C D

# specifying levels: survey data example

responses <- c("iPhone", "Samsung", "iPhone", "Xiaomi", "Samsung")
all_brands <- c("iPhone", "Samsung", "Google", "Xiaomi", "OnePlus")

phone_factor <- factor(responses, levels = all_brands)
print(phone_factor)
# Output: iPhone Samsung iPhone Xiaomi Samsung
# Levels: iPhone Samsung Google Xiaomi OnePlus

table(phone_factor)
# Output:
#  iPhone Samsung  Google  Xiaomi OnePlus
#       2       2       0       1       0

# ordered factors

temperature <- factor(
  c("Low", "High", "Medium", "Low"),
  levels = c("Low", "Medium", "High"),
  ordered = TRUE
)
print(temperature)
# Output: Low High Medium Low
# Levels: Low < Medium < High

# factor operations

colors <- factor(c("Red", "Blue", "Green"))
print(levels(colors)) # "Blue" "Green" "Red"

levels(colors) <- c("R", "B", "G")
print(colors) # R B G

f <- factor(c("Apple", "Banana", "Apple"))
print(as.character(f)) # "Apple" "Banana" "Apple"
print(as.numeric(f))   # 1 2 1 (internal codes)

f <- factor(c("A", "B", "A", "C"), levels = c("A", "B", "C", "D"))
f_new <- factor(f, levels = c("A", "B")) # Drops "C" and "D"
print(f_new) # A B A <NA>

f_clean <- droplevels(f)
print(f_clean) # Levels: A B C

# statistical modeling with factors

data <- data.frame(
  yield = c(10, 15, 12, 20),
  fertilizer = factor(c("A", "B", "A", "B"))
)
model <- lm(yield ~ fertilizer, data = data)
summary(model) # Compares A (baseline) vs. B

# reordering levels

data$fertilizer <- reorder(data$fertilizer, data$yield, FUN = mean)
print(levels(data$fertilizer)) # Sorted by mean yield

# common pitfalls: converting factors to numbers

f <- factor(c(10, 20, 10))
as.numeric(f) # Returns 1 2 1 (not 10, 20, 10)

as.numeric(as.character(f)) # Correct: 10 20 10

# common pitfalls: missing levels

factor(c("A", "A"), levels = c("A", "B", "C"))

# common pitfalls: unintended alphabetical order

factor(c("Low", "High"), levels = c("Low", "Medium", "High"))