
R version 4.6.1 (2026-06-24 ucrt) -- "Happy Hop"
Copyright (C) 2026 The R Foundation for Statistical Computing
Platform: x86_64-w64-mingw32/x64

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

> x=NA
> is.na(x)
[1] TRUE
> x=c(11,NA,13,NA)
> is.na(x)
[1] FALSE  TRUE FALSE  TRUE
> mean(x)
[1] NA
> mean(x,na.rm=TRUE)
[1] 12
> which(is.na(x))
[1] 2 4
> sum(is.na(x))
[1] 2
> complete.cases(x)
[1]  TRUE FALSE  TRUE FALSE
> y=na.omit(x)
> y
[1] 11 13
attr(,"na.action")
[1] 2 4
attr(,"class")
[1] "omit"
> mean(x)
[1] NA
> mean(y)
[1] 12
> x=5
> if(x>4) x*3
[1] 15
> x=3
> if(x>4) x*3
> x=6
> if(x>3){
+ print("The value is more than 3")
+ }
[1] "The value is more than 3"
> x=5
> if(x==3){
+ x=x-1} else {x=2*X}
Error: object 'X' not found
> if(x==3) { x=x-1} else { x=2*x}
> x
[1] 10
> x=3
> if(x==3){
+ x=x-1
+ } else if(x<3){
+ x=x+5
+ }else {x=2*x}
> x
[1] 2
> x=c(7,9,8,4)
> ifelse(x%%2==0,"even number","odd number")
[1] "odd number"  "odd number"  "even number" "even number"
> switch(4,"apple","banana","orange")
> switch("size","color"="blue","gender"="male","vol"=50)
> x=c(10,15,8,14,6,12)
> x
[1] 10 15  8 14  6 12
> which(x==14)
[1] 4
> x=matrix(nrow=3,ncol=3,data=1:9)
> x
     [,1] [,2] [,3]
[1,]    1    4    7
[2,]    2    5    8
[3,]    3    6    9
> which.min(x)
[1] 1
> which.max(x)
[1] 9
> which(x%%2==1)
[1] 1 3 5 7 9
> which(x%%2==1, arr.ind=TRUE)
     row col
[1,]   1   1
[2,]   3   1
[3,]   2   2
[4,]   1   3
[5,]   3   3
> 
