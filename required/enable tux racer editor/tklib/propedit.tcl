# -*-tcl-*-
# Squid property editor

namespace eval TRPropEdit {

    proc Create { f type value length access } {
	upvar #0 _state$f state

	frame $f

	set state(type) $type
	set state(value) $value
	set state(length) $length
	set state(varlength) [expr $length < 0]
	set state(access) $access
	set state(widgetType) [GetWidgetType $type]
	set state(updateWidgets) [list] ;# Widgets that need to be updated

	if [string match "*list" $state(type)] {
	    set state(islist) 1
	} else {
	    set state(islist) 0
	}

	set widgetType $state(widgetType)

	if { $widgetType == "" } {
	    error "unknown widget type"
	    unset state
	    return $f
	}

	# The write state determines if the value should be set in the
	# object; it is always true for readable properties 
	# (since writing back the same value is OK).  It is 0 by default
	# for write-only properties (we don't know the current value, so
	# it's not a good idea to always clobber the current value with
	# zeroes).
	if { $access == "w" } {
	    set state(write) 0
	} else {
	    set state(write) 1
	}

	if { $access == "r" } {
	    # Read-only

	    if { $state(length) < 0 } {
		# Save actual length
		set state(length) [llength $value]
	    }

	    CreateWidgets $f CreateReadOnlyWidget

	} else {
	    # Writeable
	    if { $length >= 0 } {
		# Fixed-length

		CreateWidgets $f CreateWritableWidget

	    } else {
		# Ugh, variable length
		# For now we use a single textbox and rely on user 
		# to know Tcl list syntax
		set entry $f.entry
		entry $entry -textvariable _state$f\(value\)
		pack $entry -side left -fill x -expand yes
	    }

	    if { $access == "w" } {
		# Add a checkbox; if checked it means that we want to
		# write the value
		set cb [checkbutton $f.write -text write \
			-variable _state$f\(write\)]
		pack $cb -side left
	    }
	}

	bind $f <Destroy> "unset _state$f"

	return $f
    }

    proc WriteRequested { f } {
	upvar #0 _state$f state

	return $state(write)
    }

    proc SetValue { f value } {
	upvar #0 _state$f state

	set state(value) $value

	if { $state(varlength) } {
	    set state(length) [llength $value]

	    if { $state(access) == "r" } {
		# Read-only variable length. We need to re-create the 
		# widgets. 
		# Destroy all of $f's children
		foreach child [winfo children $f] {
		    destroy $child
		}
		CreateWidgets $f CreateReadOnlyWidget
	    } else {
		# Writable variable length; we've already set state(value) 
		# so we're good
	    }
	} elseif $state(islist) {
	    # Fixed-length
	    for {set i 0} {$i<$state(length)} {incr i} {
		set state(val$i) [lindex $value $i]
	    }
	} else {
	    # Not a list, don't need to do anything
	}
    }

    proc GetValue { f } {
	upvar #0 _state$f state

	# Update widgets that need it
	foreach widget $state(updateWidgets) {
	    $widget update
	}

	if { $state(varlength) && $state(access) != "r" } {

	    # Variable length, writable; value is in state(value)
	    return $state(value)

	} elseif { !$state(islist) } {

	    return $state(value)

	} else {
	    # Fixed-length list
	    set val [list]

	    for {set i 0} {$i<$state(length)} {incr i} {
		lappend val $state(val$i)
	    }

	    return $val
	} 

	error "shouldn't get here!"
    }

    proc GetWidgetType { type } {
	set name ""
	switch -glob -- $type {
	    integer* { 
		set name TRIntEdit
	    }
	    string* {
		set name TRStringEdit
	    }
	    scalar* {
		set name TRDoubleEdit
	    }
	    boolean* {
		set name TRBoolEdit
	    }
	    object* {
		set name TRObjectEdit
	    }
	    filename* {
		set name TRFilenameEdit
	    }
	}
    }

    proc CreateWidgets { f method } {
	upvar #0 _state$f state

	set widgetType $state(widgetType)
	set value $state(value)
	set type $state(type)
	set length $state(length)

	if { $state(length) == 0 } {
	    set label [label $f.label -text "(empty list)" \
		    -font {helivetica 12 italic}]
	    pack $label -side left

	} elseif { !$state(islist) } {

	    set widget [eval [list ${widgetType}::${method} \
		    $f $f.widget $type _state$f\(value\) ] ]
	    
	    pack $widget -side left -fill x -expand yes

	} else {
	    
	    set scwin [tixScrolledWindow $f.scwin -scrollbar {auto -x}]
	    set scf [$scwin subwidget window]
	    
	    set widgetHeight 0
	    
	    for {set i 0} {$i<$length} {incr i} {
		set wf [frame $scf.wf$i]
		set state(val$i) [lindex $value $i]
		
		# Create index label
		set idxlbl [TREditUtil::CreateIndexLabel \
			$wf.idxlbl$i $i]
		pack $idxlbl -side left
		
		set widget [eval [list \
			${widgetType}::${method} \
			$f $wf.widget $type _state$f\(val$i\) ] ]

		pack $widget -side left -fill x -expand yes
		pack $wf -side top -fill x -expand yes

		update

		set widgetHeight [expr $widgetHeight + \
			[winfo height $widget]]
	    }

	    $scwin configure -height [expr \
		    ( ceil($widgetHeight/$length) ) \
		    * [min 4 $length] + 4 ]
	    pack $scwin -side left -fill x -expand yes
	}
    }

} ;# namespace TRPropEdit

namespace eval TRIntEdit {
    proc CreateReadOnlyWidget { w f type varname } {
	upvar #0 $varname val
	if { $val == "" } { set val 0 }
	set label [TREditUtil::CreateReadOnlyText $f $varname]
	return $label
    }

    proc CreateWritableWidget { w f type varname } {
	upvar #0 _state$w state
	upvar #0 $varname val
	if { $val == "" } { set val 0 }
	set ctrl [tixControl $f -variable $varname -integer yes]

	set state(updateWidgets) [concat $state(updateWidgets) $ctrl]

	return $ctrl
    }
}

namespace eval TRStringEdit {
    proc CreateReadOnlyWidget { w f type varname } {
	set label [TREditUtil::CreateReadOnlyText $f $varname]
	return $label
    }

    proc CreateWritableWidget { w f type varname } {
	set entry [entry $f -textvariable $varname]
	return $entry
    }
}

namespace eval TRDoubleEdit {
    proc CreateReadOnlyWidget { w f type varname } {
	upvar #0 $varname val
	if { $val == "" } { set val 0 }
	set label [TREditUtil::CreateReadOnlyText $f $varname]
	return $label
    }

    proc CreateWritableWidget { w f type varname } {
	upvar #0 _state$w state
	upvar #0 $varname val
	if { $val == "" } { set val 0 }
	set ctrl [tixControl $f -variable $varname]

	set state(updateWidgets) [concat $state(updateWidgets) $ctrl]

	return $ctrl
    }
}

namespace eval TRBoolEdit {
    proc CreateReadOnlyWidget { w f type varname } {
	upvar #0 $varname val
	if { $val == "" } { set val 0 }
	set check [checkbutton $f -state disabled -variable $varname \
		-anchor w]
	return $check
    }

    proc CreateWritableWidget { w f type varname } {
	upvar #0 $varname val
	if { $val == "" } { set val 0 }
	set check [checkbutton $f -variable $varname -anchor w]
	return $check
    }
}

namespace eval TRObjectEdit {
    proc CreateReadOnlyWidget { w f type varname } {
	upvar #0 $varname val
	if { $val == "" } { set val null }

	frame $f
	set label [TREditUtil::CreateReadOnlyText $f.label $varname]
	pack $label -side left -fill x -expand yes

	set goto $f.goto
	button $goto -text View -command [code GotoObject $w $varname]
	pack $goto -side left -expand no

	pack $f -side top -fill x -expand yes
	return $f
    }

    proc CreateWritableWidget { w f type varname } {
	upvar #0 $varname val
	if { $val == "" } { set val null }

	frame $f

	set entry $f.entry
	entry $entry -textvariable $varname
	pack $entry -side left -fill x -expand yes

	set browse $f.browse
	button $browse -text ... \
		-command [code DisplayDialog $f.browsedialog $varname]
	pack $browse -side left -expand no

	set goto $f.goto
	button $goto -text View -command [code GotoObject $w $varname]
	pack $goto -side left -expand no

	pack $f -side top -fill x -expand yes
	return $f
    }

    proc DisplayDialog { f varname } {
	upvar #0 _state$f state

	if [winfo exists $f] {
	    wm deiconify $f
	    raise $f
	    focus $f
	} else {
	    TRObjSelectDialog::Create $f $varname
	    wm title $f "Select Object"
	}
    }

    proc GotoObject {f varname} {
	upvar #0 $varname val
	if [objexists $val] {
	    TRMainWin::ViewObjectInBrowser $val
	} else {
	    tk_messageBox -type ok -message "$val does not exist" \
		    -parent $f
	}
    }
}

namespace eval TRFilenameEdit {
    proc CreateReadOnlyWidget { w f type varname } {
	upvar #0 $varname val
	set label [TREditUtil::CreateReadOnlyText $f $varname]
	return $label
    }

    proc CreateWritableWidget { w f type varname } {
	upvar #0 $varname val

	frame $f

	set entry $f.entry
	entry $entry -textvariable $varname
	pack $entry -side left -fill x -expand yes

	set browse $f.browse
	button $browse -text ... \
		-command [code DisplayDialog $f $varname]
	pack $browse -side left -expand no

	pack $f -side top -fill x -expand yes
	return $f
    }

    proc DisplayDialog { f varname } {
	upvar #0 _state$f state
	upvar #0 $varname value
	global tux_data_dir

	set result [tk_getOpenFile -initialdir $tux_data_dir \
		-title "Select File" -parent $f]

	if { $result != "" } {
	    set value $result
	}
    }
}
