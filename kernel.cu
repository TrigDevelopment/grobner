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

/*
  Определяет, равны ли полиномы a и b.
*/
bool polynomialEqual(Polynomial const & a, Polynomial const & b)
{
  if (a.monomials.size() != b.monomials.size()) {
    return false;
  }
  for (size_t i = 0; i < a.monomials.size(); ++i) {
    if (!monomialEqual(a.monomials[i], b.monomials[i])) {
      return false;
    }
  }
  return true;
}

bool isMonomialLess(Monomial const & a, Monomial const & b)
{
  return false;
}

/*
  Определяет, отсортированы ли одночлены polynomial по убыванию.
  Для этого необходимо, чтобы одночлены должны быть приведены.
*/
bool isSorted(Polynomial const & polynomial)
{
  return false;
}

/*
  Возвращает старший одночлен. Так как все многочлены отсортированы,
  то старшим одночлленом всегда будет первый одночлен.
*/
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

Polynomial multiplyByNormalisedMonomial(Polynomial const & polynomial, Monomial const & monomial)
{
  assert(monomial.coefficient == 1);
  auto res = polynomial;
  for (size_t monomialI = 0; monomialI < polynomial.monomials.size(); ++monomialI) {
    for (size_t i = 0; i < monomial.degrees.size(); ++i) {
      res.monomials[monomialI].degrees[i] += monomial.degrees[i];
    }
  }
  return res;
}

Polynomial generateRandomSortedPolynomial(int nVariables, int maxVariableDegree,
  int maxPrime, int maxNMonomials) 
{
  return Polynomial{{}};
}

void outputPolynomial(Polynomial const & polynomial)
{

}

void testIsMonomialLess()
{
  
}

void testIsSorted()
{

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

void testMultiplyByNormalisedMonomial()
{
  auto polynomial1 = Polynomial{{ Monomial{{1, 4}, 1} }};
  auto monomial1 = Monomial{{1, 1}, 1};
  auto expected1 = Polynomial{{ Monomial{{2, 5}, 1} }};
  auto result1 = multiplyByNormalisedMonomial(polynomial1, monomial1);
  assert(polynomialEqual(result1, expected1));
  auto polynomial2 = Polynomial{{ Monomial{{3, 4}, 1}, Monomial{{1, 2}, 1} }};
  auto expected2 = Polynomial{{ Monomial{{4, 5}, 1}, Monomial{{2, 3}, 1} }};
  auto result2 = multiplyByNormalisedMonomial(polynomial2, monomial1);
  assert(polynomialEqual(result2, expected2));
  auto polynomial3 = Polynomial{{ Monomial{{0, 0}, 1} }};
  auto monomial3 = Monomial{{0, 0}, 1};
  auto expected3 = Polynomial{{ Monomial{{0, 0}, 1} }};
  auto result3 = multiplyByNormalisedMonomial(polynomial3, monomial3);
  assert(polynomialEqual(result3, expected3));
  auto polynomial4 = Polynomial{{}};
  auto monomial4 = Monomial{{5}, 1};
  auto expected4 = Polynomial{{}};
  auto result4 = multiplyByNormalisedMonomial(polynomial4, monomial4);
  assert(polynomialEqual(result4, expected4));
}

void testGenerateRandomSortedPolynomial()
{
  for (size_t i = 0; i < 10; ++i)
  {
    auto poly = generateRandomSortedPolynomial(3, 5, 20, 5);
    outputPolynomial(poly);
  }
  for (size_t i = 0; i < 100; ++i)
  {
    auto poly = generateRandomSortedPolynomial(32, 50, 20, 50);
    assert(isSorted(poly));
  }
}

void testAll() 
{
  testIsMonomialLess();
  testIsSorted();
  testNormalisedMonomialDivide();
  testMultiplyByNormalisedMonomial();
  testGenerateRandomSortedPolynomial();
}

int main(void)
{
  testAll();

  return 0;
}