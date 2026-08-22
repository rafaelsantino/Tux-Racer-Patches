# -*-tcl-*-
# Squid object editor

namespace eval TRObjEditor {

    proc Create { w obj } {
	upvar #0 _state$w state

	frame $w

	set sw [tixScrolledWindow $w.sw -scrollbar auto]
	set statusBar [label $w.status -relief sunken -justify left \
		-borderwidth 2 -font { helvetica 10 normal }]

	set f [$sw subwidget window]

	# Get properties and organize them by class
	set objclass [objget $obj class]
	set curclass $objclass
	set classlist [objclasslist $obj]

	set properties [list]
	foreach class $classlist {
	    set classprops($class) [list]
	    foreach prop [objls $class:properties] {
		if { [lsearch -exact $properties $prop] < 0 } {
		    # New property
		    lappend properties $prop
		    lappend classprops($class) $prop
		}
	    }
	}

	# Create a header with object name
	set objheader $f.header
	label $objheader -text "Properties for [objget $obj name]" \
		-background black -foreground white
	pack $objheader -fill x -expand no

	set statusBalloon [tixBalloon $f.statusballoon -state status \
		-initwait 0 -statusbar $statusBar]
	set tooltipBalloon [tixBalloon $f.tooltipballoon -state balloon \
		-initwait 600]

	# Loop over classes in reverse order
	for {set i [expr [llength $classlist]-1]} {$i>=0} {incr i -1}  {
	    set class [lindex $classlist $i]

	    if [llength $classprops($class)] {
		set cf [frame $f.$class]
		set head [frame $cf.head]
		set body [frame $cf.body -borderwidth 5]

		label $head.label -text "[objget $class basename] properties" \
			-background white
		pack $head.label -fill x -expand yes
		pack $head -fill x -expand no

		# Loop over properties belonging to class
		foreach prop $classprops($class) {
		    set fqprop $class:properties:$prop
		    set proptype [objget $fqprop type]
		    set propname [objget $fqprop property_name]
		    set propdesc [objget $fqprop description]
		    set proplen  [objget $fqprop length]
		    set propacc  [objget $fqprop access]
		    
		    if { [string index $propacc 0] == "r" } {
			# Property is readable
			set propval  [objget $obj $prop]
		    } else {
			# Not readable, set value to empty list
			set propval [list]
		    }

		    set tooltip [TREditUtil::CreateTooltipText \
			    $propdesc $proptype $proplen]

		    set label [TREditUtil::CreateLabel \
			    $body.label$prop $propname]

		    $statusBalloon  bind $label -msg $tooltip
		    $tooltipBalloon bind $label -msg $tooltip
		    
		    set propwidgets($prop) \
			    [TRPropEdit::Create $body.$prop $proptype \
			    $propval $proplen $propacc]

		    $statusBalloon  bind $propwidgets($prop) -msg $tooltip
		    # Don't want pop-up tooltips over edit widgets

		    grid $label $propwidgets($prop)
		    grid $label -sticky news
		    grid $propwidgets($prop) -sticky ew
		    
		    grid columnconfigure $body 1 -weight 1
		}

		pack $body -fill x -expand no -anchor nw

		pack $cf -fill both -expand no
	    }
	}

	set state(scrollwin) $w
	set state(frame) $f
	set state(obj) $obj
	set state(class) $objclass
	set state(properties) $properties
	set state(propwidgets) [array get propwidgets]

	grid $sw -sticky news
	grid $statusBar -sticky news
	grid rowconfigure $w 0 -weight 1
	grid columnconfigure $w 0 -weight 1

	bind $w <Destroy> "unset _state$w"

	return $w
    }

    proc Refresh { w } {
	upvar #0 _state$w state

	array set propwidgets $state(propwidgets)
	set class $state(class)
	set obj $state(obj)

	if { ![objexists $obj] } {
	    tk_messageBox -type ok -message "Object $obj no longer exists" \
		    -parent $w
	    return
	}

	foreach prop $state(properties) {
	    if { [objget ${class}:properties:${prop} access] != "w" } {
		# Property is readable
		set value [objget $obj $prop]

		TRPropEdit::SetValue $propwidgets($prop) $value
	    }
	}
    }

    proc Apply { w } {
	upvar #0 _state$w state

	array set propwidgets $state(propwidgets)
	set class $state(class)
	set obj $state(obj)

	if { ![objexists $obj] } {
	    tk_messageBox -type ok -message "Object $obj no longer exists" \
		    -parent $w
	    return 0
	}

	foreach prop $state(properties) {
	    set fqprop $class:properties:$prop
	    set proptype [objget $fqprop type]
	    set propname [objget $fqprop property_name]
	    set propacc  [objget $fqprop access]

	    if { $propacc != "r" } {
		# Property is writable

		# Check if we want to set this value
		if { [TRPropEdit::WriteRequested $propwidgets($prop)] } {
		    
		    if { [catch {TRPropEdit::GetValue \
			    $propwidgets($prop)} val ] } {
			tk_messageBox -type ok -message "$val" -parent $w
			return 0
		    }
		    
		    if { [catch {objset $obj -$prop $val} result] } {
			tk_messageBox -type ok -message "$result" -parent $w
			return 0
		    }
		}
	    }
	}
	return 1
    }
   

} ;# namespace TRObjEditor
