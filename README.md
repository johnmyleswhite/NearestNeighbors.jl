NearestNeighbors.jl
===================

Data structures for exact and approximate nearest neighbor search. We have:

* A naive search "tree", which uses brute force to find nearest neighbors and caches nothing
* Ball-trees

The main API for each search structure is:

* Tree construction:
	* `t = NaiveNeighborTree(X)`
	* `t = BallTree(X)`
* k nearest-neighbors:
	* `k_nearest(v, t, k)`
	* `k_nearest(v, t, k, exclude)`
* Neighbors in a ball of radius `r`:
	* `inball(v, t, r)`
	* `inball(v, t, r, exclude)`

# Coming Soon

* KD-trees
* Cover-trees
* Approximate nearest neighbor search
