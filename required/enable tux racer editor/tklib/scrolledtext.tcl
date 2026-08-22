#-*-tcl-*-

# Based on example 27-1, p 346 in _Practical Programming in Tcl and
# Tk_, 2nd Ed. by Brent B. Welch.

# Creates a text widget with vertical and horizontal scrollbars
proc Scrolled_Text { f args } {
    frame $f
    eval { text $f.text -wrap none \
	    -xscrollcommand [list $f.xscroll set] \
	    -yscrollcommand [list $f.yscroll set]} $args
    scrollbar $f.xscroll -orient horizontal \
	    -command [list $f.text xview]
    scrollbar $f.yscroll -orient vertical \
	    -command [list $f.text yview]
    grid $f.text $f.yscroll -sticky news
    grid $f.xscroll -sticky news
    grid rowconfigure $f 0 -weight 1
    grid columnconfigure $f 0 -weight 1
    return $f.text
}
