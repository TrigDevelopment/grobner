#include <iostream>
#include <math.h>
#include <assert.h>
#include <vector>
#include <algorithm>

struct Monomial 
{
  std::vector<int> degrees;
  int coefficient;
};

bool monomialEqual(Monomial const & a, Monomial const & b)
{
  return a.degrees == b.degrees && a.coefficient == b.coefficient;
}

struct Polynomial 
{
  std::vector<Monomial> monomials;
};

Monomial getMajorMonomial(Polynomial const & polynomial)
{
  return polynomial.monomials[0];
}

/*
  Возвращает наименьшее общее частное monomial1 и monomial2.
  monomial1 и monomial2 должны быть нормализованы,
  то есть коэффициент при них должен быть равен 1.
*/
Monomial normalisedMonomialLeastCommonMultiple(
  Monomial const & monomial1, Monomial const & monomial2)
{
  assert(monomial1.coefficient == 1);
  assert(monomial2.coefficient == 1);
  Monomial lcm = monomial1;
  for (size_t i = 0; i < monomial1.degrees.size(); ++i) {
    lcm.degrees[i] = std::max(monomial1.degrees[i], monomial2.degrees[i]);
  }
  return lcm;
}

/*
  Возвращает результат деления divisible на divisor. 
  divisible и divisor должны быть нормализованы,
  то есть коэффициент при них должен быть равен 1.
*/
Monomial normalisedMonomialDivide(Monomial const & divisible, Monomial const & divisor)
{
  assert(divisible.coefficient == 1);
  assert(divisor.coefficient == 1);
  auto res = divisible;
  for (size_t i = 0; i < divisible.degrees.size(); ++i) {
    res.degrees[i] -= divisor.degrees[i];
  }
  return res;
}

void testNormalisedMonomialDivide()
{
  auto divisible1 = Monomial{ std::vector<int>{2, 3}, 1 };
  auto divisor1 = Monomial{ std::vector<int>{0, 0}, 1 };
  auto expected1 = Monomial{ std::vector<int>{2, 3}, 1 };
  auto result1 = normalisedMonomialDivide(divisible1, divisor1);
  assert(monomialEqual(result1, expected1));
  auto divisor2 = Monomial{ std::vector<int>{2, 3}, 1 };
  auto expected2 = Monomial{ std::vector<int>{0, 0}, 1 };
  auto result2 = normalisedMonomialDivide(divisible1, divisor2);
  assert(monomialEqual(result2, expected2));
  auto divisor3 = Monomial{ std::vector<int>{1, 1}, 1 };
  auto expected3 = Monomial{ std::vector<int>{1, 2}, 1 };
  auto result3 = normalisedMonomialDivide(divisible1, divisor3);
  assert(monomialEqual(result3, expected3));
}

void testAll() 
{
  testNormalisedMonomialDivide();
}

int main(void)
{
  testAll();

  return 0;
}