# -*-tcl-*-
# Squid object browser

namespace eval TRBrowser {

    proc Create { f } {
	upvar #0 _state$f state

	tixPanedWindow $f -orientation horizontal -height 300 
	$f add treePane
	$f add dataPane -size 450

	# Set up the tree pane
	set tp [$f subwidget treePane]

	set folder [tix getimage folder] 
	set t $tp.tree

	TRObjTree::Create $t

	# Set up the data pane
	set dp [$f subwidget dataPane]

	set notebook $dp.notebook
	tixNoteBook $notebook

	set hlist [$t subwidget hlist]

	set state(frame) $f
	set state(tree) $t
	set state(hlist) $hlist
	set state(notebook) $notebook

	pack $t -fill both -expand yes -side top
	pack $notebook -fill both -expand yes -side top
	pack $f -fill both -expand yes

	bind $hlist <Button-2> \
		[namespace code [list SelectForView $f %x %y] ]
	bind $hlist <Button-3> \
		[code SelectAndPopup $f %x %y %X %Y]

	# Create pop-up menu
	set popup [menu $f.popup -title {Object Menu}]
	$popup add command -label "View" \
		-command [code ViewSelection $f]
	$popup add command -label "New Child" \
		-command [code NewChild $f]
	$popup add command -label "Copy" \
		-command [code CopyObject $f]
	$popup add command -label "Move" \
		-command [code MoveObject $f]
	$popup add command -label "Reset" \
		-command [code ResetObject $f]
	$popup add command -label "Delete" \
		-command [code DeleteObject $f]
	$popup add command -label "Flush Children" \
		-command [code Flush $f]
	$popup add command -label "Serialize" \
		-command [code Serialize $f]
	$popup add command -label "Select In Editor" \
		-command [code SelectInEditor $f]

	set state(popup) $popup

	bind $f <Destroy> "unset _state$f"

	return $f
    }

    proc NewChild {f} {
	upvar #0 _state$f state

	set parent [lindex [$state(hlist) info selection] 0]

	if { ![objcall $parent is_a s_container] } {
	    tk_messageBox -type ok -message "$parent is not an s_container" \
		    -parent $f
	    return {}
	}

	TRNewObject::Create $f.newChildDialog$parent $parent
    }

    proc CopyObject {f} {
	upvar #0 _state$f state

	set obj [lindex [$state(hlist) info selection] 0]

	TRCopyObject::Create $f.copyChildDialog$obj $obj
    }

    proc MoveObject {f} {
	upvar #0 _state$f state

	set obj [lindex [$state(hlist) info selection] 0]

	if { ![objget $obj moveable] } {
	    tk_messageBox -type ok -message "$obj is not moveable" -parent $f
	} else {
	    TRMoveObject::Create $f.moveChildDialog$obj $obj
	}
    }

    proc ResetObject {f} {
	upvar #0 _state$f state

	set obj [lindex [$state(hlist) info selection] 0]

	set answer [tk_messageBox -message "Reset $obj?" -type yesno \
		-parent $f ]
	
	if { $answer == "no" } {
	    return
	}

	objreset $obj
    }

    proc DeleteObject {f} {
	upvar #0 _state$f state

	set obj [lindex [$state(hlist) info selection] 0]

	set answer [tk_messageBox -message "Delete $obj?" -type yesno \
		-parent $f ]
	
	if { $answer == "no" } {
	    return
	}

	if { ![objcall $obj can_delete] } {
	    tk_messageBox -type ok -message "$obj is in use" -parent $f
	} else {
	    objdel $obj
	}
    }

    proc Flush {f} {
	upvar #0 _state$f state

	set obj [lindex [$state(hlist) info selection] 0]

	set answer [tk_messageBox -message "Flush children of $obj?" \
		-type yesno -parent $f ]
	
	if { $answer == "no" } {
	    return 
	}

	if { ![objcall $obj is_a s_container] } {
	    tk_messageBox -type ok -message "$obj is not an s_container" \
		    -parent $f
	    return
	}

	objcall $obj flush
    }

    proc Serialize {f} {
	upvar #0 _state$f state

	set obj [lindex [$state(hlist) info selection] 0]

	TRMainWin::ActivateConsole
	set console [TRMainWin::GetConsole]

	set serializestring "\n# ----- Begin output of \[objserialize $obj\]\n[objserialize $obj]\n# ----- End output of \[objserialize $obj\]"

	TRConsole::Eval $console [list puts $serializestring]
    }

    proc SelectInEditor {f} {
	upvar #0 _state$f state

	set obj [lindex [$state(hlist) info selection] 0]

	if { ![objcall $obj is_a s_sgnode] } {
	    tk_messageBox -type ok -message "$obj is not an s_sgnode" \
		    -parent $f
	    return
	}

	objset :modes:editor -picked_object $obj
    }

    proc Select {f x y} {
	upvar #0 _state$f state

	set h $state(hlist)
	set t $state(tree)

	set node [$h nearest $y]

	if { ![objexists $node] } {
	    # Tree is out of date
	    error "Tree is out of sync!"
	    return
	}

	# Emulate behaviour of left-clicking
	$h selection clear
	$h selection set $node
	$h anchor set $node
    }

    proc SelectAndPopup {f x y X Y} {
	upvar #0 _state$f state

	Select $f $x $y
	tk_popup $state(popup) $X $Y
    }

    proc ViewSelection {f} {
	upvar #0 _state$f state

	set h $state(hlist)
	set t $state(tree)

	# Get the selection
	set node [lindex [$h info selection] 0]

	# Update notebook
	set notebook $state(notebook)

	if { [lsearch -exact [$notebook pages] $node] < 0 } {
	    # Need to create page
	    CreateNotebookPage $f $node
	}
	$notebook raise $node
    }

    proc SelectForView {f x y} {
	upvar #0 _state$f state

	set h $state(hlist)
	set t $state(tree)

	# Emulate behaviour of left-clicking
	Select $f $x $y

	ViewSelection $f
    }

    proc CreateNotebookPage { f obj } {
	upvar #0 _state$f state

	set notebook $state(notebook)

	$notebook add $obj -label [objget $obj basename]

	set page [$notebook subwidget $obj]

	set subnotebook [tixNoteBook $page.subnotebook]
	$subnotebook add properties -label Properties
	$subnotebook add methods -label Methods

	#
	# Properties page
	#
	set propframe [$subnotebook subwidget properties]

	set propedit [TRObjEditor::Create $propframe.editor $obj]
	pack $propedit -fill both -expand yes


	#
	# Methods page
	#
	set methodframe [$subnotebook subwidget methods]

	set methodpanel [TRMethodPanel::Create $methodframe.panel $obj]
	pack $methodpanel -fill both -expand yes


	# 
	# Button Bar
	#
	set bb [frame $page.buttonBar]

	set refreshBtn $bb.refreshBtn
	button $refreshBtn -text Refresh \
		-command [code TRObjEditor::Refresh $propedit]

	set applyBtn $bb.applyBtn
	button $applyBtn -text Apply \
		-command [code TRObjEditor::Apply $propedit]

	set okBtn $bb.okBtn
	button $okBtn -text OK \
		-command [code ApplyAndCloseEditor $f $propedit $obj]

	set cancelBtn $bb.cancelBtn
	button $cancelBtn -text Cancel \
		-command [code $notebook delete $obj]

	pack $cancelBtn $okBtn $applyBtn $refreshBtn -side right

	grid $subnotebook -sticky news
	grid $bb -sticky ew

	grid rowconfigure $page 0 -weight 1
	grid columnconfigure $page 0 -weight 1
    }

    proc ApplyAndCloseEditor {f editor obj} {
	upvar #0 _state$f state
	set notebook $state(notebook)

	if [TRObjEditor::Apply $editor] {
	    $notebook delete $obj
	}
    }

    proc GetObjTree {f} {
	upvar #0 _state$f state
	return $state(tree)
    }

} ;# namespace TRBrowser
