#-*-tcl-*-
# Dialog box for selecting objects

namespace eval TRObjSelectDialog {

    proc Create { f varname } {
	upvar #0 _state$f state
	upvar #0 $varname val

	toplevel $f

	set t [TRObjTree::Create $f.tree]

	TRObjTree::SetSelection $t $val

	set hlist [$t subwidget hlist]

	set bb [frame $f.buttonBar]

	set okBtn $bb.okBtn
	button $okBtn -text OK \
		-command [code okClick $f]

	set cancelBtn $bb.cancelBtn
	button $cancelBtn -text Cancel \
		-command [code cancelClick $f]

	pack $cancelBtn $okBtn -side right
	pack $t -side top -fill both -expand yes
	pack $bb -side bottom -fill x -expand no

	set state(frame) $f
	set state(tree) $t
	set state(hlist) $hlist
	set state(varname) $varname

	bind $f <Destroy> [list if [list \"%W\" == \"$f\"] [list unset _state$f]]

	return $f
    }

    proc okClick { f } {
	upvar #0 _state$f state
	upvar #0 $state(varname) val

	set hlist $state(hlist)
	set selection [$hlist info selection]

	if { [llength $selection] == 0 } {
	    set val null
	} else {
	    set val [lindex $selection 0]
	}

	destroy $f
    }

    proc cancelClick { f } {
	destroy $f
    }

} ;# Namespace TRObjSelectDialog
