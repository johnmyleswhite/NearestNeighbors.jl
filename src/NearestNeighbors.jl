module NearestNeighbors
	using Base.Collections
	using Distance

	export NaiveNeighborTree
	# export KDTree, BallTree, CoverTree
	export nearest, inball

	# export AbstractBall, Ball, EmptyBall
	# export AbstractBallTreeNode, BallTreeNode, EmptyBallTreeNode

	# export intersects

	include("utils.jl")
	include("naive.jl")
	# include("kdtree.jl")
	# include("ball.jl")
	# include("balltree.jl")
	# TODO: Implement cover-trees
	# include("covertree.jl")
end
