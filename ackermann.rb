#!/usr/bin/env ruby

require 'optparse'
require 'pstore'

module Ackermann
	extend self
	
	RESULTS = File.join(File.dirname(__FILE__), "ackermann_results.pstore")	

	def Ackermann(args)
		@option = {
			:recurse => nil,
			:optimize => true,
			:values => nil
		}		
	  @store = PStore.new(RESULTS)
		@results = {}
	  parse(args)
		init_results
		work
	end
		
	# Flow control	
	def work
		set_m_and_n
						
		if @option[:optimize]
	 		print(has_results?, false) unless !has_results?	
	 		print(optimize) unless !optimize
		end
		
		print(@option[:recurse] ? recursive(@m, @n) : nonrecursive)  			
	end
	
	# Sets the m and n values
	def set_m_and_n
		@m = @option[:values].split(',')[0].to_i
		@n = @option[:values].split(',')[1].to_i
		self
	end

	# Recursive implementation of Ackermann function.
	# WARNING: due to stack limitatiion the recursive method can
  #  handle up to m = 4 and m = 0. 
	def recursive(m,n)
		if m == 0
			return n+1
		elsif m > 0 && n == 0
			recursive(m-1, 1)
		elsif m > 0 && n > 0
			recursive(m-1, recursive(m, n-1))
		end
	end	
	
	# Non recursive implementation of Ackermann function
	# Consider each push onto the stach a recursive call to Ackermann
	def nonrecursive
		@stack = Array.new
		
		@stack.push(@m)
		until @stack.empty?
			@m = @stack.pop
			if @m == 0
				@n += 1
			elsif @m > 0 && @n == 0
				@stack.push(@m-1); @n+=1
			elsif @m > 0 && @n > 0
				@stack.push(@m-1, @m); @n-=1
			end
		end	
		return @n
	end
	
	# If m >= 5 it returns the optimal equation for the value m
	# See infinite table on https://en.wikipedia.org/wiki/Ackermann_function
	# for more details.
	def optimize
		case @m
		when 0
			return @n+1
		when 1
			return @n+2
		when 2
			return 2*@n+3
		when 3
			return (2**(@n+3)) - 3
		when 4
			return tetration(2,(@n+3)) - 3
		when 5
			return pentation(2,(@n+3)) - 3
		else
			return false
		end
	end
	
	# Programmatically execute the Knuth's up-arrow notation, tetration.
	# Utilized Pseudocode presented here http://googology.wikia.com/wiki/Tetration 
	def tetration(a,b)
		_r = 1
		for i in 0..b-1
			_r = a**_r 
		end
		return _r
	end
	
	# Programmatically execute the Knuth's up-arrow notation, pentation.
	# Utilized sudo code presented here http://googology.wikia.com/wiki/Pentation
	def pentation(a,b)
		_r = 1
		for i in 0..b-1
			_r = tetration(a, _r)
		end
		return _r 
	end 
	
	# User interface
	# @param args [Array]
	def parse(args)
		help = nil
		
		option = OptionParser.new do |opts|
			opts.banner = "Ackermann Function".center(80, '-')
			opts.separator ""
			opts.separator "DESCRIPTION:"
			opts.separator " "
			opts.separator "	 This is an implementation of the Ackermann function. The Ackerman function is defined as" 
			opts.separator "	 the following for nonnegative integers m and n."
			opts.separator " "
			opts.separator "	   A(m, n){"
			opts.separator "	     n + 1			if m == 0"
			opts.separator "	     A(m - 1, 1)		if m > 0 && n == 0"
			opts.separator "	     A(m - 1, A(m, n - 1))	if m > 0 && n > 0 "
			opts.separator "	   }"
			opts.separator " "
			opts.separator "	 In this module there  are two methods in place to compute the Ackermann function, one that"
			opts.separator "	 uses `recursion` and one that is `non-recursive`. Due to the stack limitations of my environment"
			opts.separator "	 I was not able to test the recursive method pass m = 4, and n = 1, but all other m and n"
			opts.separator "	 values compute correctly prior to. The non-recursive function computes for values pass "
			opts.separator "	 m = 4 and n = 1 but it does take some time to return."
			opts.separator "	 Included in this module as well is a method that optimizes low values of m as special cases and"
			opts.separator "	 returns an optimized equation for value m <= 5."
			opts.separator "	   * reference Table of values at https://en.wikipedia.org/wiki/Ackermann_function"
			opts.separator "	 Furthermore, once the value for m and n has been computed that value stored then recalled anytime"
			opts.separator "	 the user call the Ackermann function for the same m and n value."
			opts.separator " "
			opts.separator "USAGE:"
			opts.separator "	 A call is made to ackermann.rb either with two options (see options for more details)"
			opts.separator "	 the first option indicates which Ackermann method you will be using `-r` for recursive or `-n` non-recursive"
			opts.separator "	 the other option `-v` is followed by the m and n values you would like to compute. A third option can be"
			opts.separator "	 included  the `-d` option which disabled the use of the optimizer and the reference to the result store."
			opts.separator "	 The -d option provides a means for directly testing the Ackermann methods."
			opts.separator " "
			opts.separator "EXAMPLE:"
			opts.separator "	   ./ackermann.rb [METHOD] -v [VALUES]"
			opts.separator "	      e.g ./ackermann.rb -n -v 3,2"
			opts.separator "	      e.g ./ackermann.rb -r -v 3,4"
			opts.separator "	   ./ackermann.rb [NO_OPTIMIZE] [METHOD] -v [VALUES]"
			opts.separator "	      e.g ./ackermann.rb -d -r -v 3,4"
			opts.separator " "
			opts.separator "OPTIONS:"
			opts.on("-d", "--no_optimize", "Disable optimizer method and access result store")do |d| @option[:optimize] = false; end
			opts.on("-r", "--recurse", "Utilize the recursive method")do |r| @option[:recurse] = true; end
			opts.on("-n", "--nrecurse", "Utilize the nonrecursive method")do |n| @option[:recurse] = false; end
			opts.on("-v VALUES", "--values VALUES", String, "The values for m and n to be computed")do |v| @option[:values] = v; end
			opts.on("-?", "--help"){ puts option }
			help = opts.help
		end.parse!

		if @option[:recurse].nil? || (!@option[:recurse].nil? && @option[:values].nil?)
			puts help; exit 1
		end
	end
	
	# Initalizes the pstore instance variable to a empty hash 
	def init_results
		unless (File.size?(RESULTS).nil? || @store.transaction {@store[:results]}.nil?)
		  @results.replace(@store.transaction { @store[:results] }) 
		end
	end
	
	# If the computation for the m and n values exists, the computation is returned
	# if it does not false is returned.
	def has_results?
		return @results[@option[:values]] unless @results[@option[:values]].nil? 
		return false
	end
	
	# After the value for m and n is computed it stored for later access. 
	def store_results(solution)
		unless @results.value?(solution)
			@results = @results.merge({@option[:values] => solution})
		
			@store.transaction do
				@store[:results] = @results; @store.commit
			end
		end	
	end
 
	# Stores the given parameter for later use, and prints the parameter to the screen. 
	def print(solution, store=true)
		store_results(solution) unless !store

		puts solution
		
		exit
	end

	private :tetration, :pentation
end


Ackermann.Ackermann(ARGV)
