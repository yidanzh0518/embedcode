#include "binom.hpp"

int main () {
  Binom b(10, 0.5);
  for (int i = 0; i < 10; i++) {
    std::cout << b.factorial(i) << std::endl;
  }
}