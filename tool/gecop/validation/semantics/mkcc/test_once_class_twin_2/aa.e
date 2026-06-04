class AA

create

	make

feature

	make
		local
			b: BB
		do
			create b.f
			inspect b
			when {BB}.f then
				print ("b = {BB}.f: True%N")
			else
				print ("b = {BB}.f: False%N")
			end
			inspect b.twin
			when {BB}.f then
				print ("b.twin = {BB}.f: True%N")
			else
				print ("b.twin = {BB}.f: False%N")
			end
		end
		
end
