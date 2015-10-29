using Distances
using NearestNeighbors
using StatsBase

function benchmark{T <: NearestNeighborTree, V}(k, d, n, r, warmup, ::Type{V}, ::Type{T})
	E = eltype(V)
	X = rand(E, d, n)
	tree = T(X, Euclidean())

	skip = warmup
	times = Float64[]
	print("pass: ")
	for i = 1 : r
		numReps = 50
	    while true
	    	time = time_ns()
	    	for ii = 1 : numReps
	  			nearest(tree, rand(E, 3), k)
	  		end
	    	time = time_ns() - time;

	    	t = float(time)/1.0e+09

	    	if t < 1.0
	    		numReps *= 5
	    		continue
	    	else
	    		if skip > 0
	    			skip -= 1
	    			print("$(i)* ")
	    		else
	    			push!(times, numReps/t)
	    			print("$(i) ")
	    		end
	    		break
	    	end
		end
	end

	# Statistics
	println("\nImpl: ", T,
			", Key type: ", V,
			", nn = $(k), searches/sec = ",int(mean(times)), " ± ", int(1.96*sem(times)), " [CI:95%]")
	return times
end

d = 3
n = 1000
r = 51
w = 1

k = 1
times = benchmark(k, d, n, 3, w, Float32, NaiveNeighborTree)
times = benchmark(k, d, n, r, w, Float64, NaiveNeighborTree)
times = benchmark(k, d, n, r, w, Float32, KDTree)
times = benchmark(k, d, n, r, w, Float64, KDTree)

k = 5
times = benchmark(k, d, n, r, w, Float32, NaiveNeighborTree)
times = benchmark(k, d, n, r, w, Float64, NaiveNeighborTree)
times = benchmark(k, d, n, r, w, Float32, KDTree)
times = benchmark(k, d, n, r, w, Float64, KDTree)

# Results [CI:95%]
# java kd-tree, nn = 1, searches/sec = 242236 ± 10386
# NaiveNeighborTree, Float32, nn = 1, searches/sec = 3600 ± 14
# NaiveNeighborTree, Float64, nn = 1, searches/sec = 3451 ± 12
# KDTree, Float32, nn = 1, searches/sec = 291513 ± 1474
# KDTree, Float64, nn = 1, searches/sec = 301366 ± 778

# java kd-tree, nn = 5, searches/sec =  102855 ± 10829
# NaiveNeighborTree, Float32, nn = 5, searches/sec = 2818 ± 25
# NaiveNeighborTree, Float64, nn = 5, searches/sec = 2757 ± 26
# KDTree, Float32, nn = 5, searches/sec = 120687 ± 432
# KDTree, Float64, nn = 5, searches/sec = 126815 ± 312
