module Verhoeff

using Test

export verhoeff_gencheck, verhoeff_verify

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

warnabs(x)    =
begin
    if x < 0
        @warn "Input $x is negative. Taking absolute value."
        UInt(abs(x))
    else
        UInt(    x)
    end
end

# verhoeff_onestep computes the multiplication and permutation step of the Verhoeff algorithm.
# verhoeff_onestep is exclusively left-associative
verhoeff_onestep(t::Integer, (p, x)) = verhoeff_mult[begin+t][begin+verhoeff_perm[begin+(p-1)%8][begin+x]]
@test verhoeff_onestep(0, (1, 0)) ==  0
@test verhoeff_onestep(0, (2, 6)) ==  3
@test verhoeff_onestep(3, (3, 3)) ==  1
@test verhoeff_onestep(1, (4, 2)) ==  2

# verhoeff_alg implements the recursive steps that are central to the Verhoeff algorithm.
verhoeff_alg(xs::Array)        = foldl(verhoeff_onestep, collect(enumerate(xs)), init=0)
verhoeff_alg(x::Unsigned)      = verhoeff_alg(digits(x))
verhoeff_alg(x::Signed)        = verhoeff_alg(warnabs(x))

# verhoeff_verify verifies a number with a Verhoeff algorithm check digit
verhoeff_verify(x)             = verhoeff_alg(x) == 0
@test verhoeff_verify(2363)
@test verhoeff_verify([3,6,3,2])
@test !verhoeff_verify(2364)

# verhoeff_check returns a raw number's Verhoeff algorithm check digit
verhoeff_check(xs::Array)      = verhoeff_inv[begin+verhoeff_alg([[0]; xs])]
verhoeff_check(x::Unsigned)    = verhoeff_check(digits(x))
verhoeff_check(x::Signed)      = verhoeff_check(warnabs(x))
@test verhoeff_check(236)     == 3
@test verhoeff_check([6,3,2]) == 3

# verhoeff_gencheck takes a raw number and returns that number with its check
# digit appended to it.
verhoeff_gencheck(x::Array)    = [[verhoeff_check(x)]; x]
verhoeff_gencheck(x::Unsigned) = invdigits(verhoeff_gencheck(digits(x)))
verhoeff_gencheck(x::Signed)   = verhoeff_gencheck(warnabs(x))
@test verhoeff_gencheck([6,3,2]) == [3,6,3,2]
@test verhoeff_gencheck(236)     == 2363

end
