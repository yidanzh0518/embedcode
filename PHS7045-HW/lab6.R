x<- runif(n=10)
#Example solution
ps_matchR <- function(x) {
  
  match_expected <- as.matrix(dist(x))
  diag(match_expected) <- .Machine$integer.max
  indices <- apply(match_expected, 1, which.min)
  
  list(
    match_id = as.integer(unname(indices)),
    match_x  = x[indices]
  )
  
}


ps_matchR(x)

#My solution with the for loop
distance <- function(x){
  n <- length(x)
  dist <- matrix(,n,n)
  for (i in 1:n-1) {
    for (j in (i+1):n) {  
      dist[i, j] <- abs(x[i] - x[j])  #Eculidean distance for two points on the real line
      dist[j, i] <- dist[i, j]  #The distance is symmetric 
    }
  }
  diag(dist) <- .Machine$integer.max
  list(indice <- apply(dist,1,which.min),
       x <- x[indice])
}


distance(x)
