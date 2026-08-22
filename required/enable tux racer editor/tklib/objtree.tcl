#-*-tcl-*-
# Creates a tree widget for browsing Squid object hierarchy

namespace eval TRObjTree {
    # The program writes to this variable if an object is created or deletd
    variable treeModified ""
    variable newObjects [list]
    variable deletedObjects [list]

    proc Create { t } {
	upvar #0 _state$t state
	variable treeModified

	set folder [tix getimage folder] 
	tixTree $t -width 250 -height 300 \
		-opencmd [code OpenNode $t] \
		-options { \
		hlist.separator : \
		hlist.itemType imagetext \
		hlist.drawBranch true \
		hlist.indent 18 \
		hlist.selectmode single }

	set hlist [$t subwidget hlist]

	set state(tree) $t
	set state(hlist) $hlist

	InsertObject $t : 0

	$t open :

	trace variable treeModified w [code TraceUpdate $t]

	bind $t <Destroy> "unset _state$t"

	return $t
    }

    proc OpenNode {t node} {
	upvar #0 _state$t state

	set hlist $state(hlist)

	# Add children of node if necessary
	set i 0
	set children [objget $node children]
	foreach child $children {
	    if { ![$hlist info exists $child] } {
		InsertObject $t $child $i
	    }
	    incr i
	}
	
	# Now do default open action
	set opencmd [$t cget -opencmd]
	$t configure -opencmd {}
	$t open $node
	$t configure -opencmd $opencmd
    }

    proc InsertObject {t obj pos} {
	upvar #0 _state$t state

	if [objcall $obj is_a s_container] {
	    $state(hlist) add $obj -at $pos -image [tix getimage folder] \
		    -text [objget $obj basename]
	    $t setmode $obj close
	    $t close $obj
	} else {
	    # Not an s_container
	    $state(hlist) add $obj -image [tix getimage file] \
		    -text [objget $obj basename]
	}
    }

    proc UpdateAux {t obj pos} {
	upvar #0 _state$t state
	upvar 1 mode mode

	InsertObject $t $obj $pos

	if [objcall $obj is_a s_container] {
	    set children [objget $obj children]

	    set i 0
	    foreach child $children {
		UpdateAux $t $child $i
		incr i
	    }

	    if [info exists mode($obj)] {
		if { $mode($obj) == "close" } {
		    $t setmode $obj open
		    $t open $obj
		} elseif { $mode($obj) == "open" } {
		    $t setmode $obj close
		    $t close $obj
		}
	    } else {
		$t setmode $obj close
		$t close $obj
	    }
	} 
    }

    # Re-scans the whole object hierarchy
    proc Update {t} {
	upvar #0 _state$t state

	set h $state(hlist)
	set t $state(tree)

	# Save modes of existing nodes
	set curobj [$h info children]
	while (1) {
	    if { $curobj == "" } break
	    set mode($curobj) [$t getmode $curobj]
	    set curobj [$h info next $curobj]
	}

	# Save selection
	set selection [$h info selection]

	# Save anchor
	set anchor [$h info anchor]

	$state(hlist) delete all

	UpdateAux $t : 0

	# Re-do selection
	foreach node $selection {
	    if [$h info exists $node] {
		$h selection set $node
	    }
	}

	# Re-do anchor
	if [$h info exists $anchor] {
	    $h anchor set $anchor
	}
    }

    proc TraceUpdate { t var dummy op } {
	upvar #0 _state$t state
	variable treeModified
	variable newObjects
	variable deletedObjects

	if { ![winfo exists $t] } {
	    # Widget gone, end trace
	    trace vdelete treeModified w [code TraceUpdate $t]
	    return
	}

	# Remove deleted objects
	foreach obj $deletedObjects {
	    if [$state(hlist) info exists $obj] {
		$state(hlist) delete entry $obj
	    }
	}
	
	# Add new objects
	foreach obj $newObjects {
	    set parent [objget $obj parent]
	    if { ![$state(hlist) info exists $obj] && \
		  [$state(hlist) info exists $parent ] && \
	          [$t getmode $parent] == "close" } {

		InsertObject $t $obj \
			[lsearch -exact [objget $parent children] $obj]

		# Now need to walk up to root, resetting state
		set curobj [objget $obj parent]
		while { $curobj != "null" } {
		    set curmode [$t getmode $curobj]

		    if { $curmode == "close" } {
			$t setmode $curobj open
			$t open $curobj
		    } elseif { $curmode == "open" } {
			$t setmode $curobj close
			$t close $curobj
		    }
		    set curobj [objget $curobj parent]
		}
	    }
	}
    }

    proc SetSelection { t node } {
	upvar #0 _state$t state

	set h $state(hlist)

	if { ![objexists $node] } {
	    set node null
	}

	if { $node != "null" } {
	    $h selection clear

	    # Create list of all ancestor nodes
	    set ancestors [list]
	    set curobj [objget $node parent]
	    while { $curobj != "null" } {
		lappend ancestors $curobj
		set curobj [objget $curobj parent]
	    }
	    
	    # Open all ancestors
	    for {set i [expr [llength $ancestors] - 1]} {$i>=0} {incr i -1} {
		$t open [lindex $ancestors $i]
	    }

	    # and select it
	    $h selection set $node
	    $h anchor set $node
	    $h see $node
	}
    }

} ;# Namespace TRObjTree
