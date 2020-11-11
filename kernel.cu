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

bool isMonomialLess(Monomial const& a, Monomial const& b)
{
    for (size_t i = 0; i < a.degrees.size(); ++i) {
        if (a.degrees[i] < b.degrees[i]) {
            return false;
        }
        else if (a.degrees[i] > b.degrees[i]) {
            return true;
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
    for (size_t i = 0; i < polynomial.monomials.size() - 1; ++i) {
        if (!isMonomialLess(polynomial.monomials[i], polynomial.monomials[i+1])) {
            return false;
        }
    }
    return true;
}

/*
  Возвращает старший одночлен. Так как все многочлены отсортированы,
  то старшим одночлленом всегда будет первый одночлен.
*/
Monomial getMajorMonomial(Polynomial const& polynomial)
{
    return polynomial.monomials[0];
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
  divisible и divisor должны быть нормализованы,
  то есть коэффициент при них должен быть равен 1.
*/
Monomial normalisedMonomialDivide(Monomial const& divisible, Monomial const& divisor)
{
    assert(divisible.coefficient == 1);
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

void sortPolynomial(Polynomial& polynomial) {
    std::sort(polynomial.monomials.begin(), polynomial.monomials.end(), isMonomialLess);
}

void addMonomial(Polynomial& polynomial, Monomial const& monomial) {
    for (auto& m : polynomial.monomials) {
        if (m.degrees == monomial.degrees) {
            m.coefficient += monomial.coefficient;
            return;
        }
    }
    polynomial.monomials.push_back(monomial);
}

Polynomial addPolynomials(Polynomial const& polynomial1, Polynomial const& polynomial2) {
    Polynomial result{ polynomial1.monomials };
    for (const auto& monomial : polynomial2.monomials) {
        addMonomial(result, monomial);
    }
    sortPolynomial(result);
    return result;
}

Polynomial generateRandomSortedPolynomial(size_t nVariables, size_t maxVariableDegree,
    size_t prime, size_t maxNMonomials)
{
    size_t nMonomials = rand() % maxNMonomials + 1;
    Polynomial result{ {} };
    for (size_t i = 0; i < nMonomials; ++i) {
        std::vector<int> degrees;
        for (size_t var = 0; var < nVariables; ++var) {
            int degree = rand() % (maxVariableDegree + 1);
            degrees.push_back(degree);
        }
        int coefficient = 1 + rand() % (prime-1);
        Monomial monomial{ degrees, coefficient };
        addMonomial(result, monomial);
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

void testIsMonomialLess()
{
    auto monomial1 = Monomial{ std::vector<int>{2, 3}, 1 };
    auto monomial2 = Monomial{ std::vector<int>{2, 2}, 1 };
    assert(isMonomialLess(monomial1, monomial2));
    assert(!isMonomialLess(monomial2, monomial1));
    auto monomial3 = Monomial{ std::vector<int>{2, 3}, 1 };
    auto monomial4 = Monomial{ std::vector<int>{1, 5}, 1 };
    assert(isMonomialLess(monomial3, monomial4));
    assert(!isMonomialLess(monomial4, monomial3));
}

void testIsSorted()
{
    auto polynomial1 = Polynomial{ { Monomial{{1, 5}, 1}, Monomial{{2, 4}, 1} } };
    assert(!isSorted(polynomial1));
    auto polynomial2 = Polynomial{ { Monomial{{3, 2}, 1}, Monomial{{2, 4}, 1} } };
    assert(isSorted(polynomial2));
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
    srand(time(nullptr));
    testAll();
    return 0;
}