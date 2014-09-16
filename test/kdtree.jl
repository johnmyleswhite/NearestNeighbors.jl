module TestKDTree
	using Base.Test
	using Distance
	using NearestNeighbors

	# Empty tree
	t = KDTree()
	@test typeof(t.root) == NearestNeighbors.EmptyKDTree

	t = KDTree(Euclidean())
	@test typeof(t.root) <: NearestNeighbors.EmptyKDTree
	@test typeof(t.metric) == Euclidean

	# With one element
	x = [1, 2, 3]
	t = KDTree(x, 1, Euclidean())
	@test typeof(t.root) <: NearestNeighbors.KDTreeNode
	@test t.root.k == x
	@test t.root.i == 1

	# With multiple points
	X = [1 60 29 7 86 44 23 54 12]
	t = KDTree(X)
	@test typeof(t.root) <: NearestNeighbors.KDTreeNode

	# Search
	#Distance.evaluate(m::Metric, a::Int, b::Float64) = evaluate(m, float(a) ,b)
	ind, dist = nearest(t, [3], 2)
	@test length(ind) == 2
	@test length(dist) ==  2
	@test 4 in ind && 1 in ind
	@test_approx_eq(4.0, dist[1])
	@test_approx_eq(2.0, dist[2])


	X = readdlm(Pkg.dir("NearestNeighbors", "test", "iris.csv"), ',')
	kdt = KDTree(X)
	nnt = NaiveNeighborTree(X)
	v = X[:, 84]

	@test sort(nearest(kdt, v, 1)[1])[1] == 84
	@test sort(nearest(kdt, v, 2)[1])[1] == 84
	@test sort(nearest(kdt, v, 3)[1])[1] == 84
	@test sort(nearest(kdt, v, 3)[1]) == sort(nearest(nnt, v, 3)[1])
	@test sort(nearest(kdt, v, 3, 84)[1]) == sort(nearest(nnt, v, 3, 84)[1])
	@test sort(inball(kdt, v, .5)[1]) == sort(inball(nnt, v, .5)[1])
	@test sort(inball(kdt, v, .5, 84)[1]) == sort(inball(nnt, v, .5, 84)[1])
end