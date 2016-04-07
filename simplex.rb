#!/usr/bin/ruby
require 'matrix'


class Simplex
	def initialize(a, bb, ct)
		@A = a
		@b = bb
		@CT = ct

		@size = @b.to_a.size

		@N = create_of_columns @A, 0, @size
		@B = create_of_columns @A, @size, @size
		@I = @B.inv

		@CTN = create_of_columns @CT, 0, @size
		@CTB = create_of_columns @CT, @size, @size
	end

	def create_of_columns(m, start, length)
		columns = []
		length.times do |i|
			pos = i + start
			columns.push m.column(pos)
		end

		Matrix.columns columns
	end

	def concat_matrixes_by_columns(m1, m2)
		result = []
		
		m1::column_size.times do |i|
			result.push m1.column(i)
		end

		m2::column_size.times do |i|
			result.push m2.column(i)
		end

		Matrix.columns(result)
	end

	def Q(x)
		result = 0
		@CTN.to_a[0].each_with_index do |val, i|
			result += val * x[i, 0]
		end

		result
	end

	def xnb()
		@I * @b
	end

	def xn(xnb)
		Matrix[[0], [0], [xnb[0,0]], [xnb[1,0]]]
	end

	def pm()
		@CTN - (@CTB * @I * @N)
	end

	def get_min_index_of(arr)
		arr.each_with_index.min.last
	end

	def calc_p_column(pm)
		get_min_index_of pm.to_a[0]
	end

	def dm(p)
		@I * @A.column(p)
	end

	def calc_d_column(xnb, dm)
		# tu sie zastanowić
		# bo raczej to nie jest dobrze
		# przeanalizować algorytm raz jeszcze
		tmp = xnb.to_a.flatten.each_with_index.map do |e, i|
			e / dm[i] > 0 ? e / dm[i] : 99999999 # hehe, nie...
		end
		
		min_index = get_min_index_of(tmp);
		min_index#[min_index, tmp[min_index]]
	end

	def switch_values(p_column, d_column)
		cols_N = []
		cols_B = []

		@size.times do |i|
			cols_N.push @N.column(i)
			cols_B.push @B.column(i)
		end

		tmp = cols_N[p_column]
		cols_N[p_column] = cols_B[d_column]
		cols_B[d_column] = tmp

		@N = Matrix.columns(cols_N)
		@B = Matrix.columns(cols_B)
		@I = @B.inv
		@A = concat_matrixes_by_columns @N, @B
	end

	def switch_x(xn, p_column, d_column)
		d_column += @N.to_a.size
		xn = xn.to_a
		xn[d_column], xn[p_column] = xn[p_column], xn[d_column]
		Matrix.rows(xn)
	end

	def calc
		#iter 1 (prep?)
		x0b = xnb()

		x0 = xn(x0b)

		qx0 = Q(x0)

		#iter 1
		p1 = pm()
		p_column = calc_p_column(p1)
		
		d1 = dm(p_column)
		d_column = calc_d_column(x0b, d1)

		switch_values(p_column, d_column)

		xb1 = @I * @b

		x1 = xn(xb1)

		x1 = switch_x(x1, p_column, d_column)		

		qx1 = Q(x0)

		@CT = switch_x(@CT.transpose, p_column, d_column).transpose #opakować gdzieś
		@CTN = create_of_columns @CT, 0, @size
		@CTB = create_of_columns @CT, @size, @size

		#iter 2
		p2 = pm();
		p_column = calc_p_column(p2)
		
		d2 = dm(p_column)
		d_column = calc_d_column(xb1, d2)

		switch_values(p_column, d_column)

		xb2 = @I * @b

		x2 = xn(xb2)

		x2 = switch_x(x2, p_column, d_column)		

		qx2 = Q(x2)

		@CT = switch_x(@CT.transpose, p_column, d_column).transpose #opakować gdzieś
		@CTN = create_of_columns @CT, 0, @size
		@CTB = create_of_columns @CT, @size, @size

		p xb2, x2, qx2, @CT # cos nie tak w x2 :(

		#iter 3
		p3 = pm();

		p p3

	end
end

a = Matrix[[2,-1,1,0],[-1,4,0,1]]

b = Matrix[[2],[6]]

c = Matrix[[-1, -2, 0, 0]]



simplex = Simplex.new a, b, c
simplex.calc

=begin
@TODO

iteracyjnny calc
step-by-step
naprawic
uporzadkowac
zrefaktoryzować
=end