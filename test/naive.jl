module TestNaive
	using Base.Test
    using Distance
	using NearestNeighbors

    X = readcsv(Pkg.dir("NearestNeighbors", "test", "iris.csv"))

	t = NaiveNeighborTree(X)

	v = X[:, 21]

	inds, dists = nearest(t, v, 1)
	inds, dists = nearest(t, v, 2)
	inds, dists = nearest(t, v, 3)

	inds, dists = nearest(t, v, 1, 21)
	inds, dists = nearest(t, v, 2, 21)
	inds, dists = nearest(t, v, 3, 21)

	inds, dists = inball(t, v, 0.5)
	inds, dists = inball(t, v, 0.5, 21)
end
