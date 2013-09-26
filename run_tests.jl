#
# Correctness Tests
#

using Base.Test

my_tests = ["test/naive.jl",
            "test/balltree.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
