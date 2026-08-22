#-*-tcl-*-
# Utility functions for dealing with properties and arguments

namespace eval TREditUtil {

    proc CreateLabel { f name } {
	label $f -text "$name: " -justify left

	return $f
    }

    proc CreateIndexLabel { f idx } {
	label $f -text " $idx:" -font {helvetica 10 normal}
	return $f
    }

    proc CreateTooltipText { desc type length } {
	set tooltext "$desc ([CreateTooltipTypeText $type $length])"

	return $tooltext
    }

    proc CreateTooltipTypeText { type length } {
	set tooltext "$type";

	if [string match *list $type] {
	    if { $length < 0 } {
		set tooltext "$tooltext\[\]"
	    } else {
		set tooltext "$tooltext\[$length\]"
	    }
	}

	return $tooltext
    }

    proc CreateReadOnlyText { f varname } {
	entry $f -textvariable $varname -state disabled -relief sunken \
		-borderwidth 1
	$f configure -background [ [winfo parent $f] cget -background]
	return $f
    }

}
