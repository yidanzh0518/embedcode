#include <Rcpp.h>
#include <limits.h>
using namespace Rcpp;

// [[Rcpp::export]]
List distanceRcpp(NumericVector x) {
  const int n = static_cast<int>(x.size());
  NumericMatrix dist(n, n);  // Create an empty distance matrix
  
  for (int i = 0; i < n; i++) {
    for (int j = i + 1; j < n; j++) {
      dist(i, j) = fabs(x[i] - x[j]);  
      dist(j, i) = dist(i, j);  // Symmetric matrix 
    }
  }
  
  // Set diagonal to a large value to avoid self-matching
  for (int i = 0; i < n; i++) {
    dist(i, i) = std::numeric_limits<double>::max(); 
  }
  
  // Find the smallest value (one by one) in each row
  IntegerVector indices(n);  // Store the index of the smallest value
  NumericVector matched_x(n);  // Store the corresponding values of nearest neighbors
  
  for (int i = 0; i < n; i++) {
    double min_dist = dist(i, 0);  // Start with the first element as the minimum (it will be updated)
    int min_index = 0;
    
    // Find the index of the smallest value in the row (excluding diagonal)
    for (int j = 1; j < n; j++) {
      if (dist(i, j) < min_dist) {
        min_dist = dist(i, j);  // Update the minimum distance
        min_index = j;  // Update the index of the minimum distance
      }
    }
    
    indices[i] = min_index+1;  // +1 to adjust for R's 1-based indexing
    matched_x[i] = x[min_index];  // Get the value from x corresponding to the nearest neighbor
  }
  
  // Return a list with the indices and the matched values
 return List::create(
   Named("matched_x") = matched_x,
   Named("indices") = indices);
}


/***R
distanceRcpp(x)
*/