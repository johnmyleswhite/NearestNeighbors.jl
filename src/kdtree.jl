using Base.Order

abstract AbstractKDTree <: AbstractNearestNeighborTree

type EmptyKDTree <: AbstractKDTree
end

type KDTreeNode{T <: Real} <: AbstractKDTree
    k::     Vector{T}       # multidimensional point
    i::		Int             # index
    d::     Int             # split dimension
    s::     Float64         # split value
    leaf::  Bool            # is leaf?
    left::  AbstractKDTree  # left node
    right:: AbstractKDTree  # right node

    KDTreeNode(k::Vector{T}, i::Int) = new(k, i, 1, NaN, true, EmptyKDTree(), EmptyKDTree())
    KDTreeNode(k::Vector{T}, i::Int, d) = new(k, i, d, NaN, true, EmptyKDTree(), EmptyKDTree())
end

type KDTree <: NearestNeighborTree
	metric::Metric
	root:: AbstractKDTree

	KDTree() = new(Euclidean(), EmptyKDTree())
	KDTree(metric::Metric) = new(metric, EmptyKDTree())
	KDTree(k, i, metric::Metric) = new(metric, setindex!(EmptyKDTree(), i, k))

	function KDTree{T <: Real}(X::Matrix{T}, metric::Metric = Euclidean())
		n = size(X, 2)
		t = KDTree(X[:,1], 1, metric)
		for i = 2 : n
			setindex!(t.root, i, X[:,i])
		end
		new(t.metric, t.root)
	end
end

function Base.show(io::IO, t::KDTree)
	println(io, "KDTree: ", t.metric)
end

Base.setindex!{T <: Real}(t::EmptyKDTree, i::Int, k::Vector{T}) = KDTreeNode{T}(k, i)
Base.setindex!(t::KDTree, i::Int, k) = (t.root = setindex!(t.root, i, k); t)

function Base.setindex!{T <: Real}(n::KDTreeNode{T}, i::Int, k::Vector{T})
	if n.leaf
		left_k = k
		left_i = i
		right_k = n.k
		right_i = n.i
		if right_k[n.d] < left_k[n.d]
			left_k = n.k
			left_i = n.i
			right_k = k
			right_i = i
		end
		n.s = 0.5*(right_k[n.d] + left_k[n.d])
		next_sd = ((n.d) % length(k))+1

		n.left = KDTreeNode{T}(left_k, left_i, next_sd)
		n.right = KDTreeNode{T}(right_k, right_i, next_sd)
		n.leaf = false
	else
		setindex!(k[n.d] <= n.s ? n.left : n.right, i, k)
	end
	return n
end

disp(t::KDTree) = disp(t.root)
function disp(n::KDTreeNode, l::Int = 0)
	print(repeat("\t", l), "L: $(l), SD: $(n.d), SV: $(n.s)")

	if typeof(n.left) <: EmptyKDTree && typeof(n.right) <: EmptyKDTree
		println(" = K: $(n.k) ($(n.i))")
	else
		println("")
		disp(n.right, l+1)
		disp(n.left, l+1)
	end
end

function search_leaf{T <: Real}(n::KDTreeNode{T},
						x::Vector{T},
						h::Array{Float64,1},
						index::Array{Int},
						m::Metric)

	if n.leaf
		d = evaluate(m, x, n.k)
		if (d < h[1])
			h[end]=d
			index[end]=n.i
			percolate_down!(h, index, 1, d, n.i, Base.Order.Reverse)
		end
	else
		# Determine nearest and furtherest branch
		if (x[n.d] > n.s)
			near = n.right
			far = n.left
		else
			near = n.left
			far = n.right
		end

		# Search the nearest branch
		search_leaf(near, x, h, index, m)

		# Only search far tree if do not have enough neighbors
		d = evaluate(m, Float64(x[n.d]), n.s)
		if d <= h[1]
			search_leaf(far, x, h, index, m)
		end
	end
end

function nearest{T <: Real}(t::KDTree,
							x::Vector{T},
							k::Int)
	h = fill(Inf, k+1)
	index = fill(0, k+1)

	search_leaf(t.root, x, h, index, t.metric)

	return index[1:end-1], h[1:end-1]
end

function inball{T <: Real}(t::KDTree,
						   v::Vector{T},
	                       r::Real,
	                       exclude::Integer = -1)
	error("Not yet implemented")
end

# Binary heap indexing
heapleft(i::Integer) = 2i
heapright(i::Integer) = 2i + 1

# Binary min-heap percolate down.
function percolate_down!(xs::AbstractArray, xis::AbstractArray, i::Integer, x=xs[i], xi=xis[i], o::Ordering=Forward, len::Integer=length(xs))
    @inbounds while (l = heapleft(i)) <= len
        r = heapright(i)
        j = r > len || lt(o, xs[l], xs[r]) ? l : r
        if lt(o, xs[j], x)
            xs[i] = xs[j]
            xis[i] = xis[j]
            i = j
        else
            break
        end
    end
    xs[i] = x
    xis[i] = xi
end
