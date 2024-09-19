#ifndef BINOM_HPP
#define BINOM_HPP

#include <iostream> // Needed for cout / printf
#include <cmath>    // Needed for pow

class Binom {
private:
  int n;
  double p;
  
public:
  Binom(int n, double p) : n(n), p(p) {};
  int factorial(int n) const;
  double choose(int a, int b) const;
  double dbinom(int k) const;
  void print(int k) const;
};

inline int Binom::factorial(int n) const {
  if (n==0)
    return 1;
  return this -> factorial(n-1) * n;
};

inline double Binom::choose(int a, int b) const {
  
  return static_cast<double>(this->factorial(a))/(
      static_cast<double>(factorial(a-b))*
      static_cast<double>(factorial(b)));
  
};

inline double Binom::dbinom(int k) const {
  return choose(n,k) * 
    std::pow(p, k) * std::pow(1-p,n-k);
};

inline void Binom::print(int k) const {
  std::printf(
    "P(Y=%-2d; n=%d, p=%.2f) = %.4f\n",
    k, n, p, dbinom(k)); 
}
#endif