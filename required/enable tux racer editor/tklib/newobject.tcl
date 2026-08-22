# -*-tcl-*-
# Dialog box for creating a new object

namespace eval TRNewObject {

    proc Create { f parent } {
	upvar #0 _state$f state

	set state(parent) $parent

	toplevel $f
	wm title $f "Create New Child"

	set entryFrame [frame $f.entry -borderwidth 5]


	# Class selection
	set state(classes) [objls :classes]
	set state(class) s_container
	set classLabel [label $entryFrame.classLabel -text "class: " \
		-justify left]
	set classSelect [tixComboBox $entryFrame.classListbox -editable yes]

	$classSelect subwidget slistbox configure -scrollbar y
	$classSelect subwidget listbox configure -selectmode single \
		-listvar _state$f\(classes\) -height 4
	$classSelect subwidget entry configure \
		-textvariable _state$f\(class\)

	grid $classLabel $classSelect
	grid $classLabel -sticky ew
	grid $classSelect -sticky news


	# Name entry
	set state(childname) ""
	set nameLabel [label $entryFrame.nameLabel -text "child name: " \
		-justify left]
	set nameEntry [entry $entryFrame.nameEntry \
		-textvariable _state$f\(childname\)]

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

	set parent $state(parent)
	set name $state(childname)
	set class $state(class)

	if { [catch {objnew $class $parent $name} msg] } {
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

} ;# namespace TRNewObject
