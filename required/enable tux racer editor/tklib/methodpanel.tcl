# -*-tcl-*-
# Squid method panel

namespace eval TRMethodPanel {

    proc Create { w obj } {
	upvar #0 _state$w state

	frame $w

	set sw [tixScrolledWindow $w.sw -scrollbar auto]
	set statusBar [label $w.status -relief sunken -justify left \
		-borderwidth 2 -font { helvetica 10 normal } -height 2]

	set f [$sw subwidget window]

	# Get methods and organize them by class
	set objclass [objget $obj class]
	set curclass $objclass
	set classlist [objclasslist $obj]

	set methods [list]
	foreach class $classlist {
	    set classmethods($class) [list]
	    foreach method [objls $class:methods] {
		if { [lsearch -exact $methods $method] < 0 } {
		    # New method
		    lappend methods $method
		    lappend classmethods($class) $method
		}
	    }
	}

	# Create a header with object name
	set objheader $f.header
	label $objheader -text "Methods for [objget $obj name]" \
		-background black -foreground white
	pack $objheader -fill x -expand no

	set statusBalloon [tixBalloon $f.statusballoon -state status \
		-initwait 0 -statusbar $statusBar]
	set tooltipBalloon [tixBalloon $f.tooltipballoon -state balloon \
		-initwait 600]

	# Loop over classes in reverse order
	for {set i [expr [llength $classlist]-1]} {$i>=0} {incr i -1}  {
	    set class [lindex $classlist $i]

	    if [llength $classmethods($class)] {
		set cf [frame $f.$class]
		set head [frame $cf.head]
		set body [frame $cf.body -borderwidth 5]

		label $head.label -text "[objget $class basename] methods" \
			-background white
		pack $head.label -fill x -expand yes
		pack $head -fill x -expand no

		# Loop over methods belonging to class
		foreach method $classmethods($class) {
		    set fqmethod      $class:methods:$method
		    set methoddesc    [objget $fqmethod description]
		    set methodname    [objget $fqmethod method_name]
		    set methodreturns [objget $fqmethod returns]
		    set methodargs($method) [objget $fqmethod:args children]
		    
		    set tooltip ""
		    if { $methoddesc != "" } {
			set tooltip "$methoddesc";
		    }
		    if { $methodreturns != "" } {
			if { $tooltip != "" } { 
			    set tooltip "$tooltip\n" 
			}
			set tooltip "${tooltip}Returns: $methodreturns"
		    }

		    set labelFrame [tixLabelFrame $body.labelFrame$method \
			    -label $methodname]

		    if { $tooltip != "" } {
			$statusBalloon  bind [$labelFrame subwidget label] \
				-msg $tooltip
			$tooltipBalloon bind [$labelFrame subwidget label] \
				-msg $tooltip
		    }

		    set argFrame [$labelFrame subwidget frame]

		    # Loop over arguments in method
		    foreach arg $methodargs($method) {
			set argdesc [objget $arg description]
			set arglen  [objget $arg length]
			set argtype [objget $arg type]

			set tooltip [TREditUtil::CreateTooltipTypeText \
				$argtype $arglen]

			set label [TREditUtil::CreateLabel \
				$argFrame.label$arg $argdesc]

			$statusBalloon  bind $label -msg $tooltip
			$tooltipBalloon bind $label -msg $tooltip

			set argwidgets($arg) \
				[TRPropEdit::Create $argFrame.$arg $argtype \
				{} $arglen "rw"]

			$statusBalloon bind $argwidgets($arg) -msg $tooltip
			# Don't want pop-up tooltips over edit widgets
			
			grid $label $argwidgets($arg)
			grid $label -sticky news
			grid $argwidgets($arg) -sticky ew
			
		    }

		    set callButton [button $argFrame.callButton \
			    -text "Call Method" \
			    -command [code CallMethod $w $method]]

		    grid $callButton -
		    grid $callButton -sticky e

		    grid columnconfigure $argFrame 1 -weight 1

		    pack $labelFrame -fill x -expand no -anchor nw
		}

		pack $body -fill x -expand no -anchor nw

		pack $cf -fill both -expand no
	    }
	}

	set state(obj)        $obj
	set state(methodargs) [array get methodargs]
	set state(argwidgets) [array get argwidgets]

	grid $sw -sticky news
	grid $statusBar -sticky news
	grid rowconfigure $w 0 -weight 1
	grid columnconfigure $w 0 -weight 1

	bind $w <Destroy> "unset _state$w"

	return $w
    }

    proc CallMethod { w method } {
	upvar #0 _state$w state 

	array set methodargs $state(methodargs)
	array set argwidgets $state(argwidgets)

	set arglist [list]
	foreach arg $methodargs($method) {
	    if { [catch {TRPropEdit::GetValue \
		    $argwidgets($arg)} val ] } {
		tk_messageBox -type ok -message "$val" -parent $w
		return
	    }
	    lappend arglist $val
	}

	set callcmd [concat [list objcall $state(obj) $method] $arglist]

	# Bring up the console
	TRMainWin::ActivateConsole
	set console [TRMainWin::GetConsole]

	TRConsole::EvalEcho $console $callcmd
    }


} ;# namespace TRMethodPanel
