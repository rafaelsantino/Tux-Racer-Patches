# -*-tcl-*-
# Profiler display.

namespace eval TRProfiler {
    variable profilerData ""
    variable oldProfilerData ""

    proc Create { f } {
	variable profilerData

	tixScrolledText $f -scrollbar auto -options { 
	    text.width 120 
	    text.height 15 
	    text.font {courier 10 normal} 
	}

	pack $f -fill both -expand true
	set t [$f subwidget text]

	# Make state an alias for object state
	upvar #0 _state$t state

	focus $t
	set state(text) $t

	trace variable profilerData w [code Update $t]

	Update $t profilerData {} w

	bind $t <Destroy> "unset _state$t"

	return $t
    }

    proc Update {t var dummy op} {
	variable profilerData
	variable oldProfilerData

	if { $profilerData == $oldProfilerData } {
	    return;
	}

	if { ![winfo exists $t] } {
	    trace vdelete profilerData w [code Update $t]
	    return
	}

	$t delete 1.0 end

	$t insert 1.0 $profilerData

	set oldProfilerData $profilerData
    }

} ;# namespace TRProfiler
