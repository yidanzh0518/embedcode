#include "binom.hpp"

int main () {
  Binom b(10, 0.5);
  std::cout << "Q1:Factorials" << std::endl;
  for (int i = 1; i <= 10; i++) {
    std::cout << b.factorial(i) << std::endl;
  }
  
  std::cout << "Q2:Choose" << std::endl;
  for (int i = 1; i <= 10; i++) {
    std::cout << b.choose(10, i) << std::endl;
    
  }
  
}