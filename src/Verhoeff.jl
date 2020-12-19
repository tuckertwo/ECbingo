module Verhoeff

using Test

# Lookup tables for permutation and group multiplication
const verhoeff_mult =
[
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
]

const verhoeff_perm =
[
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
]

const verhoeff_inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9]

# x=invdigits(xs) is the inverse of xs=digits(x, base=10)
invdigits(xs) = foldr((x, t) -> t*10+x, xs)
@test invdigits(digits(848584)) == 848584
@test invdigits(digits(0))      == 0

verhoeff_onestep((p, x), t::Int) = verhoeff_mult[begin+t][begin+verhoeff_perm[begin+(p-1)%8][begin+x]]
verhoeff_onestep(t::Int, (p, x)) = verhoeff_onestep((p, x), t)
@test verhoeff_onestep((1, 0), 0) ==  0
@test verhoeff_onestep((2, 6), 0) ==  3
@test verhoeff_onestep((3, 3), 3) ==  1
@test verhoeff_onestep((4, 2), 1) ==  2

verhoeff_alg(xs::Array) = foldl(verhoeff_onestep, collect(enumerate(xs)), init=0)
verhoeff_alg(x::Int)     = verhoeff_alg(digits(x))

# verhoeff_verify verifies a number with a Verhoeff algorithm check digit
verhoeff_verify(x)          = verhoeff_alg(x) == 0
@test verhoeff_verify(2363)
@test verhoeff_verify([3,6,3,2])
@test !verhoeff_verify(2364)

# verhoeff_check returns a raw number's Verhoeff algorithm check digit
verhoeff_check(xs::Array)   = verhoeff_inv[begin+verhoeff_alg(xs)]
verhoeff_check(x::Int)      = verhoeff_check(digits(x))
@test verhoeff_check(236)     == 3
@test verhoeff_check([6,3,2]) == 3

# verhoeff_gencheck takes a raw number and returns that number with its check
# digit appended to it.
verhoeff_gencheck(x::Array) = [[verhoeff_check(x)] x]
verhoeff_gencheck(x::Int)   = invdigits(verhoeff_gencheck(digits(x)))
@test verhoeff_gencheck([6,3,2]) == [3,6,3,2]
@test verhoeff_gencheck(236)     == 2363

end
