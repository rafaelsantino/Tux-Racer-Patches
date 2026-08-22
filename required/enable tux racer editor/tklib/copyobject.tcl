# -*-tcl-*-
# Dialog box for copying an object

namespace eval TRCopyObject {

    proc Create { f obj } {
	upvar #0 _state$f state

	set state(obj) $obj

	toplevel $f
	wm title $f "Copy Object"

	set entryFrame [frame $f.entry -borderwidth 5]


	# Parent selection
	set parentLabel [label $entryFrame.classLabel -text "new parent: " \
		-justify left]

	set parentSelect [TRObjTree::Create $entryFrame.tree]
	set state(parentSelect) $parentSelect
	TRObjTree::SetSelection $parentSelect $obj
	TRObjTree::SetSelection $parentSelect [objget $obj parent]

	grid $parentLabel $parentSelect
	grid $parentLabel -sticky ew
	grid $parentSelect -sticky news


	# Name entry
	set state(newname) [objget $obj basename]
	set nameLabel [label $entryFrame.nameLabel -text "new name: " \
		-justify left]
	set nameEntry [entry $entryFrame.nameEntry \
		-textvariable _state$f\(newname\)]

	grid $nameLabel $nameEntry
	grid $nameLabel -sticky ew
	grid $nameEntry -sticky ew

	grid columnconfigure $entryFrame 1 -weight 1

	pack $entryFrame -fill both -expand yes

	set bb [frame $f.buttonbar -borderwidth 5]

	set okButton [button $bb.okButton -text OK \
		-command [code OKClick $f]]

	set cancelButton [button $bb.cancelButton -text Cancel \
		-command [code CancelClick $f]]

	pack $cancelButton $okButton -side right 

	pack $bb -fill x -expand yes

	bind $nameEntry <Return> [code OKClick $f]

	bind $f <Destroy> [list if [list \"%W\" == \"$f\"] [list unset _state$f]]

	return $f
    }

    proc OKClick {f} {
	upvar #0 _state$f state

	set obj $state(obj)
	set tree $state(parentSelect)
	set newname $state(newname)

	set hlist [$tree subwidget hlist]
	set selection [$hlist info selection]

	if { [llength $selection] == 0 } {
	    set parent null
	} else {
	    set parent [lindex $selection 0]
	}

	if { [catch {objcp $obj $parent $newname} msg] } {
	    # Something bad happened...
	    tk_messageBox -type ok -message "$msg" -parent $f
	} else {
	    # Succeeded, we're done
	    destroy $f
	}
    }

    proc CancelClick {f} {
	destroy $f
    }

} ;# namespace TRCopyObject
