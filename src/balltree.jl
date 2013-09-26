# TODO: Try to make as many types as possible immutable
# TODO: Generalize to arbitrary metric space

abstract AbstractBallTreeNode

type EmptyBallTreeNode <: AbstractBallTreeNode
end

type BallTreeNode <: AbstractBallTreeNode
	ball::AbstractBall
	index::Int # Index of ball's center point in source data
	parent::AbstractBallTreeNode
	left::AbstractBallTreeNode
	right::AbstractBallTreeNode
end

function BallTreeNode()
	BallTreeNode(EmptyBall(),
		         -1,
	             EmptyBallTreeNode(),
	             EmptyBallTreeNode(),
	             EmptyBallTreeNode())
end

immutable BallTree
	root::AbstractBallTreeNode
	n::Int # Number of leaves
	# Other metadata
end

function isleaf(n::AbstractBallTreeNode)
	return isa(n.left, EmptyBallTreeNode) &&
	       isa(n.right, EmptyBallTreeNode)
end

function Base.show(io::IO, n::EmptyBallTreeNode)
	print(io, EmptyBallTreeNode)
end

function Base.show(io::IO, n::BallTreeNode)
	print(io, n.ball)
end

function walk(t::BallTree)
	println("BallTree")
	walk(t.root)
end

function walk(n::BallTreeNode, depth::Integer = 0)
	for i in 1:depth
		print(' ')
	end
	println(n.ball)
	walk(n.left, depth + 1)
	walk(n.right, depth + 1)
	return
end

function walk(n::EmptyBallTreeNode, depth::Integer = 0)
	return
end

check(t::BallTree) = check(t.root)

function check(n::BallTreeNode)
	if n.ball.r == 0.0
		return true
	else
		return contains(n.ball, n.left.ball) &&
		       contains(n.ball, n.right.ball) &&
			   check(n.left) &&
			   check(n.right)
	end
end

check(n::EmptyBallTreeNode) = true

function BallTree{T <: Real}(X::Matrix{T})
	p, n = size(X)
	balls = Array(AbstractBallTreeNode, n)
	for i in 1:n
		balls[i] = BallTreeNode(Ball(X[:, i], 0.0),
			                    i,
			                    EmptyBallTreeNode(),
			                    EmptyBallTreeNode(),
			                    EmptyBallTreeNode())
	end
	return BallTree(wrap(balls, 1, n), n)
end

function coordselect!(balls::Vector{AbstractBallTreeNode},
	                  c::Integer,
	                  k::Integer,
	                  l::Integer,
	                  u::Integer)
	# Semi-sort balls[l:u] around k-th element on the c-th dimension
	#  * Items below have >=
	#  * Items above have <=
	while l < u
		r = rand(l:u)
		balls[r], balls[l] = balls[l], balls[r]
		m = l
		i = l + 1
		while i <= u
			if balls[i].ball.center[c] < balls[l].ball.center[c]
				m += 1
				balls[m], balls[i] = balls[i], balls[m]
			end
			i += 1
		end
		balls[l], balls[m] = balls[m], balls[l]
		if m <= k
			l = m + 1
		end
		if m >= k
			u = m - 1
		end
	end
	return
end

function findmax_spreadcoord(balls::Vector{AbstractBallTreeNode},
	                         l::Integer,
	                         u::Integer)
	max_spread = -Inf
	max_coord = -1
	p = length(balls[1].ball.center)
	n = length(balls)
	for c in 1:p
		min_c, max_c = Inf, -Inf
		for i in 1:n
			if balls[i].ball.center[c] < min_c
				min_c = balls[i].ball.center[c]
			end
			if balls[i].ball.center[c] > max_c
				max_c = balls[i].ball.center[c]
			end
		end
		spread = max_c - min_c
		if spread > max_spread
			max_spread, max_coord = spread, c
		end
	end
	return max_coord
end

# Construct a BallTreeNode that wraps the l-th through u-th elements of balls
function wrap(balls::Vector{AbstractBallTreeNode},
	          l::Integer,
	          u::Integer)
	if u == l
		return balls[u]
	else
		# Split left and right
		c = findmax_spreadcoord(balls, l, u)
		m = fld(l + u, 2) # May be off-by-1
		coordselect!(balls, c, m, l, u)

		res = BallTreeNode()

		res.left = wrap(balls, l, m)
		res.left.parent = res

		res.right = wrap(balls, m + 1, u)
		res.right.parent = res

		ball = Ball(Array(Float64, length(balls[1].ball.center)),
			        NaN)
		centroid!(ball.center,
			      res.left.ball.center,
			      res.right.ball.center)
		ball.r = max(euclidean(ball.center,
			                   res.left.ball.center) + res.left.ball.r,
			         euclidean(ball.center,
			         	       res.right.ball.center) + res.right.ball.r)
		res.ball = ball

		return res
	end
end

function k_nearest{T <: Real}(v::Vector{T},
	                          t::BallTree,
	                          k::Integer = 1,
	                          exclude::Integer = -1)
	if k > t.n
		error("k must be smaller than the size of the full data set")
	end

	# Should PriorityQueue's allow duplicate keys?
	pq = PriorityQueue{Int, Float64}(Base.Order.Reverse)
	for i in 1:k
		enqueue!(pq, -i, Inf)
	end

	# Don't search inside a sub-tree whose ball doesn't intersect search_ball
	search_ball = Ball(v, euclidean(v, t.root.ball.center) + t.root.ball.r)

	k_nearest_search!(v, t.root, pq, search_ball, exclude)

	return collect(keys(pq)), collect(values(pq))
end

function k_nearest_search!{T <: Real}(v::Vector{T},
                                      n::AbstractBallTreeNode,
                                      pq::PriorityQueue,
                                      search_ball::Ball,
                                      exclude::Integer)
	if isleaf(n)
		if n.index == exclude
			return
		end
		d = euclidean(search_ball.center, n.ball.center)
		if d < search_ball.r
			dequeue!(pq)
			enqueue!(pq, n.index, d)
			i_max, d_max = peek(pq)
			search_ball.r = d_max
		end
	else
		# Closest point in ball to center of search_ball
		ld = euclidean(n.left.ball.center,
			           search_ball.center) - n.left.ball.r
		rd = euclidean(n.right.ball.center,
			           search_ball.center) - n.right.ball.r
		if ld <= search_ball.r || rd <= search_ball.r
			if ld <= rd
				k_nearest_search!(v, n.left, pq, search_ball, exclude)
				if rd < search_ball.r
					k_nearest_search!(v, n.right, pq, search_ball, exclude)
				end
			else
				k_nearest_search!(v, n.right, pq, search_ball, exclude)
				if ld < search_ball.r
					k_nearest_search!(v, n.left, pq, search_ball, exclude)
				end
			end
		end
	end
	return
end

function inball{T <: Real}(v::Vector{T},
	                       t::BallTree,
	                       r::Real,
	                       exclude::Integer = -1)
	error("Not yet implemented")
end
