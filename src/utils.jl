function centroid!{T <: Real}(o::Vector{T},
	                          a::Vector{T},
	                          b::Vector{T})
	for i in 1:length(o)
		o[i] = (a[i] + b[i]) / 2
	end
	return
end
