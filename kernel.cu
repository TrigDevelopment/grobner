#include <iostream>
#include <math.h>
#include <assert.h>
#include <vector>
#include <algorithm>
#include <time.h>
#include <string>

bool isPositiveInteger(const std::string& s)
{
    return !s.empty() &&
        (std::count_if(s.begin(), s.end(), std::isdigit) == s.size());
}

std::vector<std::string> split(const std::string& input, const std::string& delimiter) {
    std::vector<std::string> tokens;
    size_t prev = 0, pos = 0;
    do {
        pos = input.find(delimiter, prev);
        if (pos == std::string::npos) {
            pos = input.length();
        }
        std::string token = input.substr(prev, pos - prev);
        if (!token.empty()) {
            tokens.push_back(token);
        }
        prev = pos + delimiter.length();
    } while (pos < input.length() && prev < input.length());
    return tokens;
}

struct Monomial
{
    std::vector<int> degrees;
    int coefficient;

    Monomial() : coefficient(0) {}

    Monomial(std::vector<int> degrees, int coefficient) : degrees(degrees), coefficient(coefficient) {}

    Monomial(const std::string& input, size_t nVariables) {
        auto variables = split(input, "*");
        if (isPositiveInteger(variables.at(0))) {
            coefficient = atoi(variables.at(0).c_str());
            variables.erase(variables.begin());
        }
        else {
            coefficient = 1;
        }
        char current_letter = 'a';
        for (const auto& variable : variables) {
            auto tokens = split(variable, "^");
            while (tokens.at(0)[0] != current_letter) {
                degrees.push_back(0);
                ++current_letter;
            }
            degrees.push_back(atoi(tokens.at(1).c_str()));
            ++current_letter;
        }
        while (degrees.size() < nVariables) {
            degrees.push_back(0);
        }
    }
};

bool operator==(const Monomial& a, const Monomial& b)
{
    return a.degrees == b.degrees && a.coefficient == b.coefficient;
}

struct Polynomial
{
    std::vector<Monomial> monomials;

    Polynomial() {}
    Polynomial(std::vector<Monomial> monomials) : monomials(monomials) {}
    Polynomial(const std::string& input, size_t nVariables) {
        auto monomialTokens = split(input, " + ");
        for (const auto& token : monomialTokens) {
            monomials.push_back(Monomial(token, nVariables));
        }
    }
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

int getInverseElement(int a, int N) {
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
        if (!(a.monomials[i] == b.monomials[i])) {
            return false;
        }
    }
    return true;
}

bool basisEqual(PolynomialBasis const& a, PolynomialBasis const& b)
{
    if (a.polynomials.size() != b.polynomials.size()) {
        return false;
    }
    for (size_t i = 0; i < a.polynomials.size(); ++i) {
        if (!polynomialEqual(a.polynomials[i], b.polynomials[i])) {
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
    assert(isSorted(a));
    assert(isSorted(b));
    for (size_t i = 0; i < a.monomials.size(); ++i) {
        if (isMonomialGreater(a.monomials[i], b.monomials[i])) {
            return true;
        }
        else if (isMonomialGreater(b.monomials[i], a.monomials[i])) {
            return false;
        }
    }
    return false;
}

bool isSorted(PolynomialBasis const& basis)
{
    for (size_t i = 0; i + 1 < basis.polynomials.size(); ++i) {
        auto current = basis.polynomials[i];
        auto next = basis.polynomials[i + 1];
        if (!isPolynomialGreater(current, next) &&
            !polynomialEqual(current, next)) {
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

void normalise(Polynomial& polynomial, int prime)
{
    assert(isSorted(polynomial));
    if (polynomial.monomials.size() > 0) {
        auto const major = getMajorMonomial(polynomial);
        int coefficient = getInverseElement(major.coefficient, prime);
        for (auto& monomial : polynomial.monomials) {
            monomial.coefficient *= coefficient;
            mod(monomial.coefficient, prime);
        }
    }
}

Polynomial generateRandomSortedPolynomial(size_t nVariables, int maxVariableDegree,
    int prime, size_t maxNMonomials)
{
    size_t nMonomials = rand() % (maxNMonomials + 1);
    Polynomial result;
    for (size_t i = 0; i < nMonomials; ++i) {
        std::vector<int> degrees;
        for (size_t variableI = 0; variableI < nVariables; ++variableI) {
            int degree = rand() % (maxVariableDegree + 1);
            degrees.push_back(degree);
        }
        int coefficient = 1 + rand() % (prime - 1);
        Monomial monomial{ degrees, coefficient };
        addMonomial(result, monomial, prime);
    }
    sortPolynomial(result);
    normalise(result, prime);
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
                std::cout << "";
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

void outputPolynomialBasis(PolynomialBasis const& basis)
{
    for (auto const& polynomial : basis.polynomials) {
        outputPolynomial(polynomial);
    }
    std::cout << std::endl;
}

void subtract(Polynomial& polynomial1, Polynomial const& polynomial2, int prime)
{
    polynomial1 = addPolynomials(polynomial1, negate(polynomial2, prime), prime);
}

Polynomial multipliedByCoefficient(Polynomial const& polynomial, int coefficient, int prime)
{
    auto res = polynomial;
    for (size_t monomialI = 0; monomialI < polynomial.monomials.size(); ++monomialI) {
        res.monomials[monomialI].coefficient *= coefficient;
        mod(res.monomials[monomialI].coefficient, prime);
        if (res.monomials[monomialI].coefficient == 0) {
            res.monomials.erase(res.monomials.begin() + monomialI);
        }
    }
    return res;
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
        if (res.monomials[monomialI].coefficient == 0) {
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

Polynomial getPolynomialWithEliminatedMajorMonomials(
    Polynomial const& polynomial1, Polynomial const& polynomial2, int prime)
{
    auto major1 = getMajorMonomial(polynomial1);
    auto major2 = getMajorMonomial(polynomial2);
    auto lcm = normalisedMonomialLeastCommonMultiple(major1, major2);
    auto multiplier1 = dividedByNormalisedMonomial(lcm, major1);
    auto multiplier2 = dividedByNormalisedMonomial(lcm, major2);
    auto multipliedPolynomial1 = multipliedByMonomial(polynomial1, multiplier1, prime);
    auto multipliedPolynomial2 = multipliedByMonomial(polynomial2, multiplier2, prime);
    subtract(multipliedPolynomial1, multipliedPolynomial2, prime);
    return multipliedPolynomial1;
}

Polynomial getReducedSPolynomial(PolynomialBasis const& basis,
    Polynomial const& polynomial1, Polynomial const& polynomial2, int prime)
{
    auto eliminated = getPolynomialWithEliminatedMajorMonomials(
        polynomial1, polynomial2, prime);
    auto reduced = getReducedPolynomial(eliminated, basis, prime);
    return reduced;
}

bool isZero(Polynomial const& polynomial)
{
    return polynomial.monomials.size() == 0;
}

Polynomial getFirstNotZeroSPolynomial(PolynomialBasis const& basis, int prime)
{
    for (auto const& a : basis.polynomials) {
        for (auto const& b : basis.polynomials) {
            auto sPolynomial = getReducedSPolynomial(basis, a, b, prime);
            if (sPolynomial.monomials.size() != 0) {
                return sPolynomial;
            }
        }
    }
    return { {} };
}

PolynomialBasis getGrobnerBasis(PolynomialBasis const& initialBasis, int prime)
{
    auto currentBasis = initialBasis;
    sortPolynomialBasis(currentBasis);
    while (true) {
        outputPolynomialBasis(currentBasis);
        auto s = getFirstNotZeroSPolynomial(currentBasis, prime);
        if (isZero(s)) {
            break;
        }
        else {
            currentBasis.polynomials.push_back(s);
            sortPolynomialBasis(currentBasis);
        }
    }
    return currentBasis;
}

PolynomialBasis generateRandomPolynomialBasis(size_t nVariables, int maxVariableDegree,
    int prime, size_t maxNMonomials, size_t nPolynomials)
{
    PolynomialBasis currentBasis;
    while (currentBasis.polynomials.size() < nPolynomials) {
        auto newPolynomial = generateRandomSortedPolynomial(
            nVariables, maxVariableDegree, prime, maxNMonomials);
        if (!isZero(newPolynomial)) {
            currentBasis.polynomials.push_back(newPolynomial);
        }
    }
    return currentBasis;
}

/*
    Возвращает случайный ненулевой многочлен из идеала, создаваемого базисом basis.
*/
Polynomial generateRandomPolynomialFromIdeal(PolynomialBasis const& basis, int prime)
{
    Polynomial current;
    for (auto const& polynomial : basis.polynomials) {
        auto randomCoefficient = rand() % prime;
        auto multiplied = multipliedByCoefficient(polynomial, randomCoefficient, prime);
        subtract(current, multiplied, prime);
    }
    return isZero(current) ?
        generateRandomPolynomialFromIdeal(basis, prime) :
        current;
}

/*
    Определяет, выполняется ли свойство базиса Грёбнера для отдельного
    многочлена из идеала
*/
bool isGrobnerForPolynomial(PolynomialBasis const& grobnerBasis,
    Polynomial const& polynomialFromIdeal)
{
    for (auto const& grobnerBasisPolynomial : grobnerBasis.polynomials) {
        auto idealMajor = getMajorMonomial(polynomialFromIdeal);
        auto grobnerMajor = getMajorMonomial(grobnerBasisPolynomial);
        if (isMonomialDivide(grobnerMajor, idealMajor)) {
            return true;
        }
    }
    return false;
}

bool isGrobnerBasis(PolynomialBasis const& initialBasis,
    PolynomialBasis const& grobnerBasis, int prime)
{
    for (int i = 0; i < 100; ++i) {
        auto polynomialFromIdeal = generateRandomPolynomialFromIdeal(initialBasis, prime);
        if (!isGrobnerForPolynomial(grobnerBasis, polynomialFromIdeal)) {
            return false;
        }
    }
    return true;
}

void testNegate()
{
    auto poly1 = Polynomial{ {} };
    assert(polynomialEqual(negate(poly1, 7), poly1));
    auto poly2 = Polynomial("a^2*b^3 + 4*a^2*b^2", 2);
    auto poly3 = Polynomial("6*a^2*b^3 + 3*a^2*b^2", 2);
    assert(polynomialEqual(negate(poly2, 7), poly3));
}

void testIsMonomialLess()
{
    auto monomial1 = Monomial("a^2*b^3", 2);
    auto monomial2 = Monomial("a^2*b^2", 2);
    assert(isMonomialGreater(monomial1, monomial2));
    assert(!isMonomialGreater(monomial2, monomial1));
    auto monomial3 = Monomial("a^2*b^3", 2);
    auto monomial4 = Monomial("a^1*b^5", 2);
    assert(isMonomialGreater(monomial3, monomial4));
    assert(!isMonomialGreater(monomial4, monomial3));
}

void testIsSorted()
{
    auto polynomial1 = Polynomial("a^1*b^5 + 2*a^2*b^4", 2);
    assert(!isSorted(polynomial1));
    auto polynomial2 = Polynomial("a^3*b^2 + 2*a^2*b^4", 2);
    assert(isSorted(polynomial2));
}

void testNormalisedMonomialDivide()
{
    auto divisible1 = Monomial("2*a^2*b^3", 2);
    auto divisor1 = Monomial("1", 2);
    auto expected1 = Monomial("2*a^2*b^3", 2);
    auto result1 = dividedByNormalisedMonomial(divisible1, divisor1);

    assert(result1 == expected1);
    auto divisor2 = Monomial("a^2*b^3", 2);
    auto expected2 = Monomial("2", 2);
    auto result2 = dividedByNormalisedMonomial(divisible1, divisor2);
    assert(result2 == expected2);

    auto divisor3 = Monomial("a^1*b^1", 2);
    auto expected3 = Monomial("2*a^1*b^2", 2);
    auto result3 = dividedByNormalisedMonomial(divisible1, divisor3);
    assert(result3 == expected3);
}

void testMultiplyByNormalisedMonomial()
{
    auto polynomial1 = Polynomial("a^1*b^4", 2);
    auto monomial1 = Monomial("a^1*b^1", 2);
    auto expected1 = Polynomial("a^2*b^5", 2);
    auto result1 = multiplyByNormalisedMonomial(polynomial1, monomial1);
    assert(polynomialEqual(result1, expected1));
    auto polynomial2 = Polynomial("a^3*b^4 + a^1*b^2", 2);
    auto expected2 = Polynomial("a^4*b^5 + a^2*b^3", 2);
    auto result2 = multiplyByNormalisedMonomial(polynomial2, monomial1);
    assert(polynomialEqual(result2, expected2));
    auto polynomial3 = Polynomial("1", 2);
    auto monomial3 = Monomial("1", 2);
    auto expected3 = Polynomial("1", 2);
    auto result3 = multiplyByNormalisedMonomial(polynomial3, monomial3);
    assert(polynomialEqual(result3, expected3));
    auto polynomial4 = Polynomial{ {} };
    auto monomial4 = Monomial("a^5", 2);
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
    auto poly1 = Polynomial();
    subtract(poly1, { {} }, 7);
    assert(polynomialEqual(poly1, { {} }));

    auto poly2 = Polynomial();
    subtract(poly2, { "5*a^2*b^3", 2 }, 7);
    assert(polynomialEqual(poly2, { "2*a^2*b^3", 2 }));

    auto poly3 = Polynomial("5*a^2*b^3", 2);
    subtract(poly3, { {} }, 7);
    assert(polynomialEqual(poly3, { "5*a^2*b^3", 2 }));

    auto poly4 = Polynomial("5*a^2*b^3", 2);
    subtract(poly4, { "2*a^2*b^3", 2 }, 7);
    assert(polynomialEqual(poly4, { "3*a^2*b^3", 2 }));

    auto poly5 = Polynomial("5*a^2*b^3", 2);
    subtract(poly5, { "5*a^2*b^3", 2 }, 7);
    assert(polynomialEqual(poly5, { {} }));

    auto poly6 = Polynomial("2*a^2*b^3", 2);
    subtract(poly6, { "3*a^2*b^3", 2 }, 7);
    assert(polynomialEqual(poly6, { "6*a^2*b^3", 2 }));

    auto poly7 = Polynomial("a^3*b^3", 2);
    subtract(poly7, { "a^2*b^2", 2 }, 5);
    assert(polynomialEqual(poly7, { "a^3*b^3 + 4*a^2*b^2", 2 }));

    auto poly8 = Polynomial("a^2*b^2", 2);
    subtract(poly8, { "a^3*b^3", 2 }, 5);
    assert(polynomialEqual(poly8, { "4*a^3*b^3 + a^2*b^2", 2 }));

    auto poly9 = Polynomial("2*a^4*b^4 + 3*a^2*b^2", 2);
    subtract(poly9, { "4*a^3*b^3 + 3*a^1*b^1", 2 }, 5);
    assert(polynomialEqual(poly9, { "2*a^4*b^4 + a^3*b^3 + 3*a^2*b^2 + 2*a^1*b^1", 2 }));

    auto poly10 = Polynomial("a^1*b^2", 2);
    subtract(poly10, { "a^2*b^1", 2 }, 5);
    assert(polynomialEqual(poly10, { "4*a^2*b^1 + a^1*b^2", 2 }));
}

void testMultipliedByMonomial()
{
    auto poly0 = Polynomial("1", 2);
    auto monomial0 = Monomial("1", 2);
    auto expected0 = Polynomial("1", 2);
    auto result0 = multipliedByMonomial(poly0, monomial0, 5);
    assert(polynomialEqual(expected0, result0));

    auto poly1 = Polynomial("a^1*b^4", 2);
    auto monomial1 = Monomial("a^1*b^1", 2);
    auto expected1 = Polynomial("a^2*b^5", 2);
    auto result1 = multipliedByMonomial(poly1, monomial1, 5);
    assert(polynomialEqual(expected1, result1));

    auto poly2 = Polynomial("a^3*b^4 + a^1*b^2", 2);
    auto monomial2 = Monomial("a^1*b^1", 2);
    auto expected2 = Polynomial("a^4*b^5 + a^2*b^3", 2);
    auto result2 = multipliedByMonomial(poly2, monomial2, 5);
    assert(polynomialEqual(expected2, result2));

    auto poly3 = Polynomial("a^1*b^1", 2);
    auto monomial3 = Monomial("2", 2);
    auto expected3 = Polynomial("2*a^1*b^1", 2);
    auto result3 = multipliedByMonomial(poly3, monomial3, 5);
    assert(polynomialEqual(expected3, result3));
}

void testGetReducedPolynomial()
{
    auto poly0 = Polynomial();
    auto poly1 = Polynomial("1", 1);
    auto result1 = getReducedPolynomial(poly1, { { poly1 } }, 7);
    assert(polynomialEqual(result1, poly0));

    auto poly2 = Polynomial("a^1", 1);
    auto result2 = getReducedPolynomial(poly2, { { poly1 } }, 7);
    assert(polynomialEqual(result2, poly0));

    auto poly3 = Polynomial("a^2", 1);
    auto poly4 = Polynomial("a^5", 1);
    auto result3 = getReducedPolynomial(poly4, { { poly3 } }, 7);
    assert(polynomialEqual(result3, poly0));

    auto result4 = getReducedPolynomial(poly3, { { poly4 } }, 7);
    assert(polynomialEqual(result4, poly3));

    auto poly5 = Polynomial("a^1 + b^1", 2);
    auto poly6 = Polynomial("a^1", 2);
    auto poly7 = Polynomial("b^1", 2);
    auto result5 = getReducedPolynomial(poly6, { { poly5 } }, 7);
    assert(polynomialEqual(result5, poly7));

    auto poly8 = Polynomial("b^1 + c^1", 3);
    auto poly9 = Polynomial("a^1 + b^1", 3);
    auto poly10 = Polynomial("a^1", 3);
    auto poly11 = Polynomial("c^1", 3);
    auto basis0 = PolynomialBasis{ { poly8, poly9 } };
    sortPolynomialBasis(basis0);
    auto result6 = getReducedPolynomial(poly10, basis0, 7);
    assert(polynomialEqual(result6, poly11));

    auto result7 = getReducedPolynomial(poly8, basis0, 7);
    assert(polynomialEqual(result7, { {} }));

    auto poly12 = Polynomial("3*a^1", 2);
    auto poly13 = Polynomial("b^1", 2);
    auto result8 = getReducedPolynomial(poly12, { { poly5 } }, 7);
    assert(polynomialEqual(result8, poly13));
}

void testGetPolynomialWithEliminatedMajorMonomials()
{
    auto result1 = getPolynomialWithEliminatedMajorMonomials(
        { "1", 1 }, { "1", 1 }, 7);
    assert(polynomialEqual(result1, { {} }));

    auto result2 = getPolynomialWithEliminatedMajorMonomials(
        { "a^1", 2 }, { "b^1", 2 }, 7);
    assert(polynomialEqual(result2, { {} }));

    auto result3 = getPolynomialWithEliminatedMajorMonomials(
        { "a^1 + b^1", 2 }, { "a^1", 2 }, 7);
    assert(polynomialEqual(result3, { "b^1", 2 }));

    auto result4 = getPolynomialWithEliminatedMajorMonomials(
        { "a^1", 2 }, { "a^1 + b^1", 2 }, 7);
    assert(polynomialEqual(result4, { "6*b^1", 2 }));
}

void testGetGrobnerBasis(size_t nVariables, size_t nPolynomials, int maxVariableDegree,
    size_t maxNMonomials, int prime, int nIterations)
{
    for (int i = 0; i < nIterations; ++i) {
        auto basis = generateRandomPolynomialBasis(
            nVariables, maxVariableDegree, prime, maxNMonomials, nPolynomials);
        auto grobnerBasis = getGrobnerBasis(basis, prime);
        assert(isGrobnerBasis(basis, grobnerBasis, prime));
    }
}

void testSortPolynomialBasis()
{
    auto const poly1 = Polynomial("a^1 + 2*b^2", 2);
    auto const poly2 = Polynomial("a^1 + b^6", 2);
    auto basis = PolynomialBasis{ { poly1, poly2 } };
    sortPolynomialBasis(basis);
    auto expected = PolynomialBasis{ { poly2, poly1 } };
    assert(basisEqual(basis, expected));
}

void testGetFirstNotZeroSPolynomial_1()
{
    auto poly1 = Polynomial("a^2*b^2 + a^1", 2);
    auto poly2 = Polynomial("a^2*b^1 + b^1", 2);
    auto basis = PolynomialBasis{ { poly1, poly2 } };
    auto result = getFirstNotZeroSPolynomial(basis, 3);
    auto expected = Polynomial("a^1 + 2*b^2", 2);
    assert(polynomialEqual(result, expected));
}

void testGetGrobnerBasis()
{
    srand(0);
    //nVariables, nPolynomials, maxVariableDegree, maxNMonomials, prime, nIterations
    //testGetGrobnerBasis(1, 1, 1, 1, 2, 10);
    testGetGrobnerBasis(2, 2, 2, 2, 3, 100);
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
    testGetPolynomialWithEliminatedMajorMonomials();
    testSortPolynomialBasis();
    testGetFirstNotZeroSPolynomial_1();
    // testGetGrobnerBasis();
}

int main(void)
{
    testAll();
    return 0;
}