#include <iostream>
#include <math.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include <time.h>

struct Monomial
{
    std::vector<int> degrees;
    int coefficient;
};

bool monomialEqual(Monomial const& a, Monomial const& b)
{
    return a.degrees == b.degrees && a.coefficient == b.coefficient;
}

struct Polynomial
{
    std::vector<Monomial> monomials;
};

struct PolynomialBasis
{
  std::vector<Polynomial> polynomials;
};

void mod(int& number, int prime) {
    number %= prime;
    if (number < 0) {
        number += prime;
    }
}

/* Алгоритм Евклида*/
int gcdex(int a, int b, int& x, int& y) {
    if (b == 0) {
        x = 1;
        y = 0;
        return a;
    }
    int x1, y1;
    int d1 = gcdex(b, a % b, x1, y1);
    x = y1;
    y = x1 - (a / b) * y1;
    return d1;
}

int getInversedElement(int a, int N) {
    int x, y;
    gcdex(a, N, x, y);
    return x;
}

/*
  Определяет, равны ли полиномы a и b.
*/
bool polynomialEqual(Polynomial const& a, Polynomial const& b)
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

bool isMonomialGreater(Monomial const& a, Monomial const& b)
{
    assert(a.degrees.size() == b.degrees.size());
    for (size_t i = 0; i < a.degrees.size(); ++i) {
        if (a.degrees[i] > b.degrees[i]) {
            return true;
        }
        else if (a.degrees[i] < b.degrees[i]) {
            return false;
        }
    }
    return false;
}

/*
  Определяет, отсортированы ли одночлены polynomial по убыванию.
  Для этого необходимо, чтобы одночлены должны быть приведены.
*/
bool isSorted(Polynomial const& polynomial)
{
    for (size_t i = 0; i + 1 < polynomial.monomials.size(); ++i) {
        if (!isMonomialGreater(polynomial.monomials[i], polynomial.monomials[i + 1])) {
            return false;
        }
    }
    return true;
}

/*
  Возвращает старший одночлен. Так как все многочлены отсортированы по убыванию,
  то старшим одночлленом всегда будет первый одночлен.
*/
Monomial getMajorMonomial(Polynomial const& polynomial)
{
  assert(polynomial.monomials.size() > 0);
  return polynomial.monomials[0];
}

bool isPolynomialGreater(Polynomial const& a, Polynomial const& b)
{
    auto majorA = getMajorMonomial(a);
    auto majorB = getMajorMonomial(b);
    return isMonomialGreater(majorA, majorB);
}

bool isSorted(PolynomialBasis const& basis)
{
    for (size_t i = 0; i + 1 < basis.polynomials.size(); ++i) {
        if (!isPolynomialGreater(basis.polynomials[i], basis.polynomials[i + 1])) {
            return false;
        }
    }
    return true;
}

/*
  Возвращает наименьшее общее частное monomial1 и monomial2.
  monomial1 и monomial2 должны быть нормализованы,
  то есть коэффициент при них должен быть равен 1.
*/
Monomial normalisedMonomialLeastCommonMultiple(
    Monomial const& monomial1, Monomial const& monomial2)
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
  divisor должен быть нормализован,
  то есть коэффициент при этом одночлене должен быть равен 1.
*/
Monomial dividedByNormalisedMonomial(Monomial const& divisible, Monomial const& divisor)
{
    assert(divisor.coefficient == 1);
    auto res = divisible;
    for (size_t i = 0; i < divisible.degrees.size(); ++i) {
        res.degrees[i] -= divisor.degrees[i];
    }
    return res;
}

Polynomial multiplyByNormalisedMonomial(Polynomial const& polynomial, Monomial const& monomial)
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

void sortPolynomial(Polynomial& polynomial) 
{
    std::sort(polynomial.monomials.begin(), polynomial.monomials.end(), isMonomialGreater);
}

void sortPolynomialBasis(PolynomialBasis& basis) 
{
    std::sort(basis.polynomials.begin(), basis.polynomials.end(), isPolynomialGreater);
}

void addMonomial(Polynomial& polynomial, Monomial const& monomial, int prime) {
    for (size_t i = 0; i < polynomial.monomials.size(); ++i) {
        if (polynomial.monomials[i].degrees == monomial.degrees) {
            polynomial.monomials[i].coefficient += monomial.coefficient;
            mod(polynomial.monomials[i].coefficient, prime);
            if (!polynomial.monomials[i].coefficient) {
                polynomial.monomials.erase(polynomial.monomials.begin() + i);
            }
            return;
        }
    }
    polynomial.monomials.push_back(monomial);
}

/*
  Возвращает результат умножения polynomial на -1.
*/
Polynomial negate(Polynomial const& polynomial, int prime)
{
    auto current = polynomial;
    for (auto& monomial : current.monomials) {
        monomial.coefficient = prime - monomial.coefficient;
    }
    return current;
}

Polynomial addPolynomials(Polynomial const& polynomial1, Polynomial const& polynomial2, int prime) {
    Polynomial result{ polynomial1.monomials };
    for (const auto& monomial : polynomial2.monomials) {
        addMonomial(result, monomial, prime);
    }
    sortPolynomial(result);
    return result;
}

Polynomial generateRandomSortedPolynomial(size_t nVariables, size_t maxVariableDegree,
    size_t prime, size_t maxNMonomials)
{
    size_t nMonomials = rand() % (maxNMonomials + 1);
    Polynomial result{ {} };
    for (size_t i = 0; i < nMonomials; ++i) {
        std::vector<int> degrees;
        for (size_t var = 0; var < nVariables; ++var) {
            int degree = rand() % (maxVariableDegree + 1);
            degrees.push_back(degree);
        }
        int coefficient = 1 + rand() % (prime - 1);
        Monomial monomial{ degrees, coefficient };
        addMonomial(result, monomial, prime);
    }
    sortPolynomial(result);
    return result;
}

void outputMonomial(Monomial const& monomial) {
    char letter = 'a';
    if (monomial.coefficient != 1) {
        std::cout << monomial.coefficient;
    }
    for (size_t i = 0; i < monomial.degrees.size(); ++i) {
        if (monomial.degrees[i]) {
            std::cout << letter;
            if (monomial.degrees[i] > 1) {
                std::cout << "^" << monomial.degrees[i];
            }
            if (i != monomial.degrees.size() - 1) {
                std::cout << " ";
            }
        }
        ++letter;
    }
}

void outputPolynomial(Polynomial const& polynomial)
{
    for (size_t i = 0; i < polynomial.monomials.size(); ++i) {
        outputMonomial(polynomial.monomials[i]);
        if (i != polynomial.monomials.size() - 1) {
            std::cout << " + ";
        }
    }
    std::cout << std::endl;
}

void subtract(Polynomial& polynomial1, Polynomial const& polynomial2, int prime)
{
    polynomial1 = addPolynomials(polynomial1, negate(polynomial2, prime), prime);
}

Polynomial multipliedByMonomial(Polynomial const& polynomial, Monomial const& monomial, int prime)
{
    auto res = polynomial;
    for (size_t monomialI = 0; monomialI < polynomial.monomials.size(); ++monomialI) {
        for (size_t i = 0; i < monomial.degrees.size(); ++i) {
            res.monomials[monomialI].degrees[i] += monomial.degrees[i];
        }
        res.monomials[monomialI].coefficient *= monomial.coefficient;
        mod(res.monomials[monomialI].coefficient, prime);
        if (!res.monomials[monomialI].coefficient) {
            res.monomials.erase(res.monomials.begin() + monomialI);
        }
    }
    return res;
}

bool isMonomialDivide(Monomial const& monomial1, Monomial const& monomial2)
{
    assert(monomial1.degrees.size() == monomial2.degrees.size());
    for (size_t i = 0; i < monomial1.degrees.size(); ++i) {
        if (monomial1.degrees[i] > monomial2.degrees[i]) {
            return false;
        }
    }
    return true;
}

void normalise(Polynomial& polynomial, int prime)
{
    assert(isSorted(polynomial));
    if (polynomial.monomials.size() > 0) {
        auto const major = getMajorMonomial(polynomial);
        int coefficient = getInversedElement(major.coefficient, prime);
        for (auto& monomial : polynomial.monomials) {
            monomial.coefficient *= coefficient;
            mod(monomial.coefficient, prime);
        }
    }
}

Polynomial getReducedPolynomial(Polynomial const& polynomial,
    PolynomialBasis const& basis, int prime)
{
    assert(isSorted(basis));
    auto current = polynomial;
    for (size_t basisPolynomialI = 0;
        basisPolynomialI < basis.polynomials.size();
        ++basisPolynomialI) {
        auto basisPolynomial = basis.polynomials[basisPolynomialI];
        auto major = getMajorMonomial(basisPolynomial);
        for (size_t monomialI = 0; monomialI < current.monomials.size(); ++monomialI) {
            auto monomial = current.monomials[monomialI];
            if (isMonomialDivide(major, monomial)) {
                auto multiplier = dividedByNormalisedMonomial(monomial, major);
                auto multipliedBasisPolynomial =
                    multipliedByMonomial(basisPolynomial, multiplier, prime);
                subtract(current, multipliedBasisPolynomial, prime);
                monomialI = 0;
            }
        }
    }
    normalise(current, prime);
    return current;
}

void testNegate()
{
    auto poly1 = Polynomial{ {} };
    assert(polynomialEqual(negate(poly1, 7), poly1));
    auto poly2 = Polynomial{ { {{2, 3}, 1}, {{2, 2}, 4} } };
    auto poly3 = Polynomial{ { {{2, 3}, 6}, {{2, 2}, 3} } };
    assert(polynomialEqual(negate(poly2, 7), poly3));
}

void testIsMonomialLess()
{
    auto monomial1 = Monomial{ {2, 3}, 1 };
    auto monomial2 = Monomial{ {2, 2}, 1 };
    assert(isMonomialGreater(monomial1, monomial2));
    assert(!isMonomialGreater(monomial2, monomial1));
    auto monomial3 = Monomial{ {2, 3}, 1 };
    auto monomial4 = Monomial{ {1, 5}, 1 };
    assert(isMonomialGreater(monomial3, monomial4));
    assert(!isMonomialGreater(monomial4, monomial3));
}

void testIsSorted()
{
    auto polynomial1 = Polynomial{ { Monomial{{1, 5}, 1}, Monomial{{2, 4}, 2} } };
    assert(!isSorted(polynomial1));
    auto polynomial2 = Polynomial{ { Monomial{{3, 2}, 2}, Monomial{{2, 4}, 1} } };
    assert(isSorted(polynomial2));
}

void testNormalisedMonomialDivide()
{
    auto divisible1 = Monomial{ {2, 3}, 2 };
    auto divisor1 = Monomial{ {0, 0}, 1 };
    auto expected1 = Monomial{ {2, 3}, 2 };
    auto result1 = dividedByNormalisedMonomial(divisible1, divisor1);

    assert(monomialEqual(result1, expected1));
    auto divisor2 = Monomial{ {2, 3}, 1 };
    auto expected2 = Monomial{ {0, 0}, 2 };
    auto result2 = dividedByNormalisedMonomial(divisible1, divisor2);
    assert(monomialEqual(result2, expected2));

    auto divisor3 = Monomial{ {1, 1}, 1 };
    auto expected3 = Monomial{ {1, 2}, 2 };
    auto result3 = dividedByNormalisedMonomial(divisible1, divisor3);
    assert(monomialEqual(result3, expected3));
}

void testMultiplyByNormalisedMonomial()
{
    auto polynomial1 = Polynomial{ { Monomial{{1, 4}, 1} } };
    auto monomial1 = Monomial{ {1, 1}, 1 };
    auto expected1 = Polynomial{ { Monomial{{2, 5}, 1} } };
    auto result1 = multiplyByNormalisedMonomial(polynomial1, monomial1);
    assert(polynomialEqual(result1, expected1));
    auto polynomial2 = Polynomial{ { Monomial{{3, 4}, 1}, Monomial{{1, 2}, 1} } };
    auto expected2 = Polynomial{ { Monomial{{4, 5}, 1}, Monomial{{2, 3}, 1} } };
    auto result2 = multiplyByNormalisedMonomial(polynomial2, monomial1);
    assert(polynomialEqual(result2, expected2));
    auto polynomial3 = Polynomial{ { Monomial{{0, 0}, 1} } };
    auto monomial3 = Monomial{ {0, 0}, 1 };
    auto expected3 = Polynomial{ { Monomial{{0, 0}, 1} } };
    auto result3 = multiplyByNormalisedMonomial(polynomial3, monomial3);
    assert(polynomialEqual(result3, expected3));
    auto polynomial4 = Polynomial{ {} };
    auto monomial4 = Monomial{ {5}, 1 };
    auto expected4 = Polynomial{ {} };
    auto result4 = multiplyByNormalisedMonomial(polynomial4, monomial4);
    assert(polynomialEqual(result4, expected4));
}

void testGenerateRandomSortedPolynomial()
{
    for (size_t i = 0; i < 20; ++i)
    {
        auto poly = generateRandomSortedPolynomial(3, 5, 19, 5);
        outputPolynomial(poly);
    }
    for (size_t i = 0; i < 100; ++i)
    {
        auto poly = generateRandomSortedPolynomial(32, 50, 19, 50);
        assert(isSorted(poly));
    }
}

void testSubtract()
{
    auto poly1 = Polynomial{{}};
    subtract(poly1, {{}}, 7);
    assert(polynomialEqual(poly1, {{}}));

    auto poly2 = Polynomial{{}};
    subtract(poly2, {{ {{2, 3}, 5} }}, 7);
    assert(polynomialEqual(poly2, {{ {{2, 3}, 2} }}));

    auto poly3 = Polynomial{{ {{2, 3}, 5} }};
    subtract(poly3, {{}}, 7);
    assert(polynomialEqual(poly3, {{ {{2, 3}, 5} }}));

    auto poly4 = Polynomial{{ {{2, 3}, 5} }};
    subtract(poly4, {{ {{2, 3}, 2} }}, 7);
    assert(polynomialEqual(poly4, {{ {{2, 3}, 3} }}));

    auto poly5 = Polynomial{{ {{2, 3}, 5} }};
    subtract(poly5, {{ {{2, 3}, 5} }}, 7);
    assert(polynomialEqual(poly5, {{}}));

    auto poly6 = Polynomial{{ {{2, 3}, 2} }};
    subtract(poly6, {{ {{2, 3}, 3} }}, 7);
    assert(polynomialEqual(poly6, {{ {{2, 3}, 6} }}));

    auto poly7 = Polynomial{{ {{3, 3}, 1} }};
    subtract(poly7, {{ {{2, 2}, 1} }}, 5);
    assert(polynomialEqual(poly7, {{ {{3, 3}, 1}, {{2, 2}, 4} }}));

    auto poly8 = Polynomial{{ {{2, 2}, 1} }};
    subtract(poly8, {{ {{3, 3}, 1} }}, 5);
    assert(polynomialEqual(poly8, {{ {{3, 3}, 4}, {{2, 2}, 1} }}));

    auto poly9 = Polynomial{{ {{4, 4}, 2}, {{2, 2}, 3} }};
    subtract(poly9, {{ {{3, 3}, 4}, {{1, 1}, 3} }}, 5);
    assert(polynomialEqual(poly9, {{ {{4, 4}, 2}, {{3, 3}, 1}, {{2, 2}, 3}, {{1, 1}, 2} }}));

    auto poly10 = Polynomial{{ {{1, 2}, 1} }};
    subtract(poly10, {{ {{2, 1}, 1} }}, 5);
    assert(polynomialEqual(poly10, {{ {{2, 1}, 4}, {{1, 2}, 1} }}));
}

void testMultipliedByMonomial()
{
    auto poly0 = Polynomial{ { {{0, 0}, 1} } };
    auto monomial0 = Monomial{ {0, 0}, 1 };
    auto expected0 = Polynomial{ { {{0, 0}, 1} } };
    auto result0 = multipliedByMonomial(poly0, monomial0, 5);
    assert(polynomialEqual(expected0, result0));

    auto poly1 = Polynomial{ { {{1, 4}, 1}} };
    auto monomial1 = Monomial{ {1, 1}, 1 };
    auto expected1 = Polynomial{ { {{2, 5}, 1} } };
    auto result1 = multipliedByMonomial(poly1, monomial1, 5);
    assert(polynomialEqual(expected1, result1));

    auto poly2 = Polynomial{ { {{3, 4}, 1}, {{1, 2}, 1} } };
    auto monomial2 = Monomial{ {1, 1}, 1 };
    auto expected2 = Polynomial{ { {{4, 5}, 1}, {{2, 3}, 1} } };
    auto result2 = multipliedByMonomial(poly2, monomial2, 5);
    assert(polynomialEqual(expected2, result2));

    auto poly3 = Polynomial{ { {{1, 1}, 1} } };
    auto monomial3 = Monomial{ {0, 0}, 2 };
    auto expected3 = Polynomial{ { {{1, 1}, 2} } };
    auto result3 = multipliedByMonomial(poly3, monomial3, 5);
    assert(polynomialEqual(expected3, result3));
}

void testGetReducedPolynomial()
{
    auto poly0 = Polynomial{{}};
    auto poly1 = Polynomial{{ {{0}, 1} }};
    auto result1 = getReducedPolynomial(poly1, { { poly1 } }, 7);
    assert(polynomialEqual(result1, poly0));

    auto poly2 = Polynomial{{ {{1}, 1} }};
    auto result2 = getReducedPolynomial(poly2, { { poly1 } }, 7);
    assert(polynomialEqual(result2, poly0));

    auto poly3 = Polynomial{{ {{2}, 1}}};
    auto poly4 = Polynomial{{ {{5}, 1} }};
    auto result3 = getReducedPolynomial(poly4, { { poly3 } }, 7);
    assert(polynomialEqual(result3, poly0));

    auto result4 = getReducedPolynomial(poly3, { { poly4 } }, 7);
    assert(polynomialEqual(result4, poly3));

    auto poly5 = Polynomial{ { {{1, 0}, 1}, {{0, 1}, 1} } };
    auto poly6 = Polynomial{ { {{1, 0}, 1} }};
    auto poly7 = Polynomial{{ {{0, 1}, 1} }};
    auto result5 = getReducedPolynomial(poly6, { { poly5 } }, 7);
    assert(polynomialEqual(result5, poly7));

    auto poly8 = Polynomial{ { {{0, 1, 0}, 1}, {{0, 0, 1}, 1} } };
    auto poly9 = Polynomial{ { {{1, 0, 0}, 1}, {{0, 1, 0}, 1} } };
    auto poly10 = Polynomial{ { {{1, 0, 0}, 1} } };
    auto poly11 = Polynomial{ { {{0, 0, 1}, 1} } };
    auto basis0 = PolynomialBasis{ { poly8, poly9 } };
    sortPolynomialBasis(basis0);
    auto result6 = getReducedPolynomial(poly10, basis0, 7);
    assert(polynomialEqual(result6, poly11));

    auto result7 = getReducedPolynomial(poly8, basis0, 7);
    assert(polynomialEqual(result7, {{}}));

    auto poly12 = Polynomial{ { {{1, 0}, 3} } };
    auto poly13 = Polynomial{ { {{0, 1}, 1} } };
    auto result8 = getReducedPolynomial(poly12, { { poly5 } }, 7);
    assert(polynomialEqual(result8, poly13));
}

void testAll()
{
    testNegate();
    testIsMonomialLess();
    testIsSorted();
    testNormalisedMonomialDivide();
    testMultiplyByNormalisedMonomial();
    testGenerateRandomSortedPolynomial();
    testSubtract();
    testMultipliedByMonomial();
    testGetReducedPolynomial();
}

int main(void)
{
    srand(time(nullptr));
    testAll();
    return 0;
}