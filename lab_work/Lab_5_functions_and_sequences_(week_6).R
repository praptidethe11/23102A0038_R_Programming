#Week 6: Control Structures in R
##LOOPS

#for loop 
#syntax: for(name in vector){commands to be executed}

for(i in 1:5){print(i**2)}
for(i in c(1,2,3,4)){print(i+2)}

#nested looping with for loop
child = c("c1", "c2", "c3")
sweet = c("s1", "s2", "s3")
for(x in child){
  for(y in sweet){
    print(paste(x,y))
  }
}

#break command
drink = c("coke", "fanta", "milk")
for(x in drink){
  if(x=="milk") break
  print(x)
}
for(x in drink){
  if(x=="coke") next
  print(x)
}

#while loop
#syntax: while(condition){commands to be executed as long as condition is true}

i=1
while(i<10){
  print(i^2)
  i=i+2
}

sumfun = function(){
  sum=0
  n= as.integer(readline(prompt="Please select number less than 25: "))
  while(n<=25){
    sum = sum+n
    n=n+1
  }
  print(paste("the sum of numbers recieved from the while loop: ", sum))
}

sumfun()

#repeat command: repeat{commands to be execute}
i=1
repeat{
  print(i**2)
  i=i+2
  if(i>10)
    break
}

i=1
repeat{
  i=i+1
  if(i<10) next
  print(i**2)
  if(i>=13) break
}

#FUNCTIONS
#SOME BUILT IN FUNCTIONS- sum(), prod(), mean(), max(), sum(x)
#syntax: Name = function(arg1, arg2){
                  #expression()
              #}

abc = function(x){
  x=x**2
  print(x)
}

abc(3)
abc(11)
abc(89)

abc= function(x){
  x= sin(x)^2+cos(x)**2+x
  print(x)
}

abc(45)
abc(30)
abc(-1)
abc(70)

#callin function without an argument
abc = function(){
  for(i in 1:3){
    print(i**3)
  }
}
abc()

#SEQUENCES: set of related objects that follow a particular order
#syntax: seq(condition)

help("seq")
seq(from=20, to=10, by= -2) #decrement
seq(to=10, length=10) #predefined length
seq(from=10, length=10, by=0.1) #default increment
seq(from=20, length=10, by=-2) #decrement in predefined length
