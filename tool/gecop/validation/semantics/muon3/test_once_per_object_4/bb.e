class BB

feature

	g
		do
			print ("First call to f%N")
			f (False)
			if attached other_thread as l_other_thread then
				l_other_thread.join
			end
		end
		
	f (a_recursive_call: BOOLEAN)
		local
			l_other_thread: CC
		once ("OBJECT")
			print ("Calling f%N")
			if not a_recursive_call then
				create l_other_thread.make (Current)
				other_thread := l_other_thread
				l_other_thread.launch
				if not l_other_thread.join_with_timeout (1000) then
					print ("Second call was block by first call%N")
				end
			end
			print ("End of first call to f%N")
		end

	other_thread: detachable CC
	
end
