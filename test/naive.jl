module NearestNeighborsNaive
	using Base.Test
	using NearestNeighbors

	X = readcsv(joinpath("test", "iris.csv"))

	t = NaiveNeighborTree(X)

	v = X[:, 21]

	k_nearest(v, t, 1)
	k_nearest(v, t, 2)
	k_nearest(v, t, 3)

	k_nearest(v, t, 1, 21)
	k_nearest(v, t, 2, 21)
	k_nearest(v, t, 3, 21)

	inball(v, t, 0.5)
	inball(v, t, 0.5, 21)
end
