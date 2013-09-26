immutable NaiveNeighborTree{T <: Real}
	X::Matrix{T}
	n::Int
end

function NaiveNeighborTree{T <: Real}(X::Matrix{T})
	NaiveNeighborTree(X, size(X, 2))
end

function k_nearest{T <: Real}(v::Vector{T},
	                          t::NaiveNeighborTree,
	                          k::Integer = 1,
	                          exclude::Integer = -1)
	if k > t.n
		error("k must be smaller than the size of the full data set")
	end

	pq = PriorityQueue{Int, Float64}(Base.Order.Reverse)
	items = 0

	for i in 1:t.n
		if i == exclude
			continue
		end
		d = euclidean(v, t.X[:, i])
		if items < k
			items += 1
			enqueue!(pq, i, d)
		else
			i_max, d_max = peek(pq)
			if d < d_max
				dequeue!(pq)
				enqueue!(pq, i, d)
			end
		end
	end

	return collect(keys(pq)), collect(values(pq))
end


function inball{T <: Real}(v::Vector{T},
	                       t::NaiveNeighborTree,
	                       r::Real,
	                       exclude::Integer = -1)
	is, ds = Int[], Float64[]

	for i in 1:t.n
		if i == exclude
			continue
		end
		d = euclidean(v, t.X[:, i])
		if d < r
			push!(is, i)
			push!(ds, d)
		end
	end

	return is, ds
end
