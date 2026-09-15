#Week 9: Strings - Display and Formatting

#PRINT AND FORMAT WITH CONCATENATION

#print function has a limitation - prints only one object at a time
#trying to print multiple items gives an error
print("The zero occurs at", 2*pi, "radians.")  #Error: invalid 'quote' argument

#the only way to print multiple items with print() is one at a time
print("The zero occurs at"); print(2*pi); print("radians")

#cat function - alternative to print, combines multiple items into continuous output
#Usage: cat(..., file = "", sep = " ", fill = FALSE, labels = NULL, append = FALSE)
cat("The zero occurs at", 2*pi, "radians.", "\n")

#cat with date
d = date()
cat("Today's date is:", d, "\n")

#cat with sep argument
x = 1:10
x
cat(x, sep = " ++ ")
cat("\n")
cat(x, sep = " / ")

#cat combining text and computed values
x = 7
cat("The square of", x, "is", x^2, "!\n")

#cat with format() for controlled decimal places
cat("The square root of", x, "is approximately", format(sqrt(x), digits = 3), "\n")

#cat can print simple vectors
evenno = c(2,4,6,8,10)
evenno
cat("The first few even numbers are:", evenno, "...\n")

#cat with fill and labels
x = 1:10
cat(x, fill = 2, labels = paste("(", letters[1:10], ")"))

#PASTE FUNCTION

#paste concatenates several strings, result can be assigned to a variable
#Usage: paste(..., sep = " ", collapse = NULL)

#paste converts arguments to character strings via as.character
paste(1:12)
as.character(1:12)  #Alternative to paste

#paste with default and custom separators
paste("Everybody", "loves", "R Programming.")
paste("Everybody", "loves", "R Programming.", sep = "*")
paste("Everybody", "loves", "R Programming.", sep = "===")

#paste generates all combinations when arguments are vectors of strings
names = c("Prof. Singh", "Mr. Venkat", "Dr. Jha")
names
paste(names, "is", "a good", "person.")

#collapse parameter - joins combinations into one string
paste(names, "is", "a good", "person.", collapse = ", and ")

#OPERATIONS WITH STRINGS

#role of blank space inside double quotes
paste(1, " is first", 2, " is second", 3, " is third", sep = "#")
paste(1, " is first   ", 2, " is second   ", 3, " is third   ", sep = "#")

#paste with vectorized numbering
x = paste("Ex", 1:5, sep = "_")
x
x[1]
x[2]
x[3]
x[5]

#collapse creates a single string instead of a vector
x = paste("Ex", 1:5, sep = "_", collapse = "")
x

#difference between with and without collapse
x = paste("Ex", 1:5, sep = "_")
x
x = paste("Ex", 1:5, sep = "_", collapse = "")
x

#paste0 - equivalent to paste with sep = ""
#for a single vector, paste0 and paste behave the same as as.character
paste0(1:10)
paste(1:10)

#paste0 with multiple vectors - concatenates in a vectorized way
paste0(1:10, c("st", "nd", "rd", rep("th", 7)))

#observe the role of blank space with paste (adds a space)
paste(1:10, c("st", "nd", "rd", rep("th", 7)))

#STRING SPLITTING

#strsplit splits elements of a character vector into substrings
#Usage: strsplit(x, split, fixed = FALSE, ...)

x = "The&!syntax&!of&!paste&!is!&available! &inthe online-help"
x
strsplit(x, split = "!")

strsplit(x, split = "&!")

y = strsplit(x, split = "!&")
y

#accessing single components
y[[1]][1]
y[[1]][2]
y[[1]][3]

#example: convert to matrix
dates = c("2020-07-24", "2021-08-25", "2022-09-26", "2023-10-27")
datesplt = strsplit(dates, "-")
datesplt

datemat = matrix(unlist(datesplt), nrow = 4, ncol = 3, byrow = TRUE)
datemat

datematrix = matrix(as.numeric(unlist(datesplt)), nrow = 4, ncol = 3, byrow = TRUE)
datematrix

#splitting a string into individual characters
strsplit("Shalabh", split = "")

#MANIPULATIONS WITH STRINGS AND ALPHABET

#COUNTING CHARACTERS

#nchar - returns the number of characters in each element
#nzchar - fast check for non-empty strings
#Usage: nchar(x, type = "chars", allowNA = FALSE, keepNA = NA)
#Usage: nzchar(x, keepNA = FALSE)

x = "R course 24.07.2022"
y = "Number of participants: 25"
nchar(x)  #Count the number of characters
nchar(y)

nzchar(x)
nzchar(y)

#nzchar with a vector including an empty string
x = c("Apple", "Banana", "Cake")
x
nzchar(x)

y = c("Apple", "", "Cake")
y
nzchar(y)

#nchar on character and numeric vectors
x = c("Apple", "Banana", "Cake")
nchar(x)

y = c(2, 4, 6)
nchar(y)

z = c(11, 222, 3333)
nchar(z)

z1 = c(1.1, 2.22, 3.333)
nchar(z1)

#LOWER AND UPPER CASES

#tolower(x) and toupper(x) convert case; non-alphabetic characters unchanged
x = "R course will start from 24.07.2022"
toupper(x)

z = "INDIAN INSTITUTE OF TECHNOLOGY"
tolower(z)