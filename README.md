NearestNeighbors.jl
===================

Data structures for exact and approximate nearest neighbor search. We have:

* A naive search "tree", which uses brute force to find nearest neighbors and caches nothing

The main API for each search structure is:

* Tree construction:
	* `t = NaiveNeighborTree(X, Euclidean())`
* k nearest-neighbors:
	* `nearest(t, v, k)`
	* `nearest(t, v, k, exclude)`
* Neighbors in a ball of radius `r`:
	* `inball(t, v, r)`
	* `inball(t, v, r, exclude)`

# Usage Example

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

# Coming Soon

* Ball-trees
* KD-trees
* Cover-trees
* Approximate nearest neighbor search
