procedure bigcorr (zero_file, zero_list, flat_list, sci_list, fix_file)

string	zero_file	{"zeroc01", prompt="Name of mean zero img.?"}
string	zero_list	{"listc01-bias", prompt="List of zero frames?"}
string	flat_list	{"listc01-flat", prompt="List of flat frames?"}
string	sci_list	{"listc01-sci", prompt="List of sci frames?"}
string	fix_file	{"badcolsc.list", prompt=" Name of fixfile?"}
struct	*list

begin
	struct	s1

	print 'First biascorrection and removal of badpix of object-frames '
	list = sci_list
	while (fscan (list, s1) != EOF) {
		ccdproc (s1, ccdtype="object", fixfile = fix_file, fixpix = yes, zerocor= yes, flatcor= no, overscan= no, trim = no)
		}

	print 'Then biascorrection and removal of badpix of flats '
	list = flat_list
	while (fscan (list, s1) != EOF) {
		ccdproc (s1, ccdtype="flat", fixfile = fix_file, fixpix = yes, zerocor= yes, flatcor= no, overscan= no, trim = no)
		}

	print 'Then biascorrection and removal of badpix of the zeros - '
	print 'just to check the quality of correction...'
	list = zero_list
	while (fscan (list, s1) != EOF) {
		ccdproc (s1, ccdtype="zero", fixfile = fix_file, fixpix = yes, zerocor= yes, flatcor= no, overscan= no, trim = no)
	}

	print 'Now for double overscan correction of the objects'
	list = sci_list
	while (fscan (list, s1) != EOF) {
		imcopy (s1, "testcopy1")
#		imcopy (s1, "testcopy2")
		imarith (s1, "*", "0.908260", "testcopy2")
		ccdproc ("testcopy1", overscan = yes, biassec = "[683:707,1:1410]", trimsec = "[3:341,1:1410]", ccdtype="object", interactive = no, function = "chebyshev", order = "1", trim = yes , fixpix= no, zerocor= no, flatcor= no)
		ccdproc ("testcopy2", overscan = yes, biassec = "[708:732,1:1410]", trimsec = "[342:679,1:1410]", ccdtype="object", interactive = no, function = "chebyshev", order = "1", trim = yes , fixpix= no, zerocor= no, flatcor= no)
		imcopy ("testcopy1" // "[1:339,1:1410]", s1 // "[3:341,1:1410]" )
		imcopy ("testcopy2" // "[1:338,1:1410]", s1 // "[342:679,1:1410]" )
		ccdproc((s1), trimsec = "[3:679,1:1410]", overscan= no, ccdtype="object", trim = yes , fixpix= no, zerocor= no, flatcor= no)
		imdele ("testc*")
	}
 
	print 'Now for double overscan correction of the flats'
	list = flat_list
	while (fscan (list, s1) != EOF) {
		imcopy (s1, "testcopy1")
#		imcopy (s1, "testcopy2")
		imarith (s1, "*", "0.908260", "testcopy2")
		ccdproc ("testcopy1", overscan= yes, biassec = "[683:707,1:1410]", trimsec = "[3:341,1:1410]", ccdtype="flat", interactive = no, function = "chebyshev", order = "1", trim = yes , fixpix= no, zerocor= no, flatcor= no)
		ccdproc ("testcopy2", overscan = yes, biassec = "[708:732,1:1410]", trimsec = "[342:679,1:1410]", ccdtype="flat", interactive = no, function = "chebyshev", order = "1", trim = yes , fixpix= no, zerocor= no, flatcor= no)
		imcopy ("testcopy1" // "[1:339,1:1410]", s1 // "[3:341,1:1410]" )
		imcopy ("testcopy2" // "[1:338,1:1410]", s1 // "[342:679,1:1410]" )
		ccdproc((s1), trimsec = "[3:679,1:1410]", overscan= no, ccdtype="flat", trim = yes , fixpix= no, zerocor= no, flatcor= no)
		imdele ("testc*")
	}
 
end
