
namespace eval TRAnimEditor {
    
    proc Create {f} {
	global tux_data_dir
	upvar #0 _state$f state

	frame $f

	# Create Anim Frame
	frame $f.anim -border 4 -relief sunken

	# Create Header
	set header $f.anim.header
	label $header -text "Create an animation" \
		-background black -foreground white
	pack $header -fill x -expand no

	# Parent Name
	set parentobjprop :classes:s_action_anim:properties:root_anim
	set pf [frame $f.anim.parentobj]
	set proptype [objget $parentobjprop type]
	set proplen  [objget $parentobjprop length]
	set widgets(parent_name) \
		[TRPropEdit::Create $pf.parent_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $pf.parent_name_label parent_name]
	grid $label $widgets(parent_name)
	grid $label -sticky news
	grid $widgets(parent_name) -sticky ew
	grid columnconfigure $pf 1 -weight 1
	pack $pf -fill both -expand true

	# Anim type select
	set state(animtype) Unset
	set tf [frame $f.anim.animtype]
	set widgets(animtypebox)  [tixComboBox $tf.anim_type -label "" \
		-variable _state$f\(animtype\) ]
	foreach animtype {
	    "Container"
	    "Interpolation"
	    "Curve"
	    "Alias"
	} {
	    $widgets(animtypebox) subwidget listbox insert end $animtype
	}
	$widgets(animtypebox) pick 0
	set label [TREditUtil::CreateLabel $tf.anim_type_label anim_type]
	grid $label $widgets(animtypebox)
	grid $label -sticky news
	grid $widgets(animtypebox) -sticky ew
	grid columnconfigure $tf 1 -weight 1
	pack $tf -fill x -expand true -side top

	# Child Name
	set state(childname) ""
	set childf [frame $f.anim.childname]
	set nameLabel [label $childf.nameLabel -text "child name: " \
		-justify left]
	set nameEntry [entry $childf.nameEntry \
		-textvariable _state$f\(childname\)]
	set createAnimBtn [button $childf.createAnim -text "Create Anim" \
		-command [code CreateAnim $f]] 
	grid $nameLabel $nameEntry $createAnimBtn
	grid $nameLabel -sticky ew
	grid $nameEntry -sticky ew
	grid $createAnimBtn -sticky ew
	grid columnconfigure $childf 1 -weight 1
	pack $childf -fill x -expand true -side top

	pack $f.anim -fill x -expand true -side top



	# Joint frame 
	frame $f.joint -border 4 -relief sunken

	# Create Header
	set header $f.joint.header
	label $header -text "Link animation to joint" \
		-background black -foreground white
	pack $header -fill x -expand no

	#Full Curve Name
	set animobjprop :classes:s_action_anim:properties:root_anim
	set af [frame $f.joint.animobj]
	set proptype [objget $animobjprop type]
	set proplen  [objget $animobjprop length]
	set widgets(curve_name) \
		[TRPropEdit::Create $af.curve_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $af.curve_name_label curve_name]
	grid $label $widgets(curve_name) 
	grid $label -sticky news
	grid $widgets(curve_name) -sticky ew
	grid columnconfigure $af 1 -weight 1
	pack $af -fill both -expand true


	# Joint Name
	set jointobjprop :classes:s_action_anim:properties:root_object
	set jf [frame $f.joint.jointobj]
	set proptype [objget $jointobjprop type]
	set proplen  [objget $jointobjprop length]
	set widgets(joint_name) \
		[TRPropEdit::Create $af.joint_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $af.joint_name_label joint_name]
	grid $label $widgets(joint_name)
	grid $label -sticky news
	grid $widgets(joint_name) -sticky ew
	grid columnconfigure $jf 1 -weight 1
	pack $jf -fill both -expand true

	# Clock select
	set state(clocktype) Unset
	set ctf [frame $f.joint.clocktype]
	set widgets(clocktypebox)  [tixComboBox $ctf.clock_type -label "" \
		-variable _state$f\(clocktype\) ]
	foreach clocktype {
	    "Real-time"
	    "Assigned time"
	} {
	    $widgets(clocktypebox) subwidget listbox insert end $clocktype
	}
	$widgets(clocktypebox) pick 0
	set label [TREditUtil::CreateLabel $ctf.clock_type_label clock_type]
	grid $label $widgets(clocktypebox)
	grid $label -sticky news
	grid $widgets(clocktypebox) -sticky ew
	grid columnconfigure $ctf 1 -weight 1
	pack $ctf -fill x -expand true -side top

	# Anim channel select
	set state(animchannel) Unset
	set cf [frame $f.joint.animchannel]
	set widgets(animchannelbox)  [tixComboBox $cf.anim_channel -label "" \
		-variable _state$f\(animchannel\) ]
	foreach animchannel {
	    "x_rotation"
	    "y_rotation"
	    "z_rotation"
	    "x_translation"
	    "y_translation"
	    "z_translation"
	    "x_scale"
	    "y_scale"
	    "z_scale"
	    "x_terrain"
	    "z_terrain"
	    "x_radians"
	    "y_radians"
	    "z_radians"
	} {
	    $widgets(animchannelbox) subwidget listbox insert end $animchannel
	}
	$widgets(animchannelbox) pick 0
	set label [TREditUtil::CreateLabel $cf.anim_channel_label anim_channel]
	set linkAnimBtn [button $cf.linkAnim -text "Link Anim" \
		-command [code LinkAnim $f]] 
	grid $label $widgets(animchannelbox) $linkAnimBtn
	grid $label -sticky news
	grid $widgets(animchannelbox) -sticky ew
	grid $linkAnimBtn -sticky ew
	grid columnconfigure $cf 1 -weight 1
	pack $cf -fill x -expand true -side top

	pack $f.joint -fill x -expand true -side top

	# Create Action frame 
	frame $f.action -border 4 -relief sunken

	# Create Header
	set header $f.action.header
	label $header -text "Create action" \
		-background black -foreground white
	pack $header -fill x -expand no

	# Anim Root Name
	set animobjprop :classes:s_action_anim:properties:root_anim
	set arf [frame $f.action.animobj]
	set proptype [objget $animobjprop type]
	set proplen  [objget $animobjprop length]
	set widgets(anim_root_name) \
		[TRPropEdit::Create $arf.anim_root_name $proptype \
		"" $proplen rw]
	set label [TREditUtil::CreateLabel $arf.anim_root_name_label \
		anim_root_name]
	grid $label $widgets(anim_root_name) 
	grid $label -sticky news
	grid $widgets(anim_root_name) -sticky ew
	grid columnconfigure $arf 1 -weight 1
	pack $arf -fill both -expand true

	# Object Root Name
	set objrootprop :classes:s_action_anim:properties:root_object
	set orf [frame $f.action.jointobj]
	set proptype [objget $objrootprop type]
	set proplen  [objget $objrootprop length]
	set widgets(objroot_name) \
		[TRPropEdit::Create $orf.objroot_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $orf.objroot_name_label \
		obj_root_name]
	grid $label $widgets(objroot_name)
	grid $label -sticky news
	grid $widgets(objroot_name) -sticky ew
	grid columnconfigure $orf 1 -weight 1
	pack $orf -fill both -expand true

	# Action Parent Name
	set parentobjprop :classes:s_action_anim:properties:root_anim
	set apf [frame $f.action.parentobj]
	set proptype [objget $parentobjprop type]
	set proplen  [objget $parentobjprop length]
	set widgets(action_parent_name) \
		[TRPropEdit::Create $apf.parent_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $apf.parent_name_label \
		action_parent_name]
	grid $label $widgets(action_parent_name)
	grid $label -sticky news
	grid $widgets(action_parent_name) -sticky ew
	grid columnconfigure $pf 1 -weight 1
	pack $apf -fill both -expand true

	# Action Child Name
	set state(actionchildname) ""
	set acf [frame $f.action.childname]
	set nameLabel [label $acf.nameLabel -text "child name: " \
		-justify left]
	set nameEntry [entry $acf.nameEntry \
		-textvariable _state$f\(actionchildname\)]
	set createActionBtn [button $acf.createAction -text "Create Action" \
		-command [code CreateAction $f]] 
	grid $nameLabel $nameEntry $createActionBtn
	grid $nameLabel -sticky ew
	grid $nameEntry -sticky ew
	grid $createActionBtn -sticky ew
	grid columnconfigure $acf 1 -weight 1
	pack $acf -fill x -expand true -side top

	pack $f.action -fill x -expand true -side top




	# Use Action frame 
	frame $f.useaction -border 4 -relief sunken

	# Create Header
	set header $f.useaction.header
	label $header -text "Use action" -background black -foreground white
	pack $header -fill x -expand no

	# Action Name
	set actionprop :classes:s_action_anim:properties:root_anim
	set anf [frame $f.useaction.name]
	set proptype [objget $actionprop type]
	set proplen  [objget $actionprop length]
	set widgets(action_name) \
		[TRPropEdit::Create $anf.action_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $anf.action_name_label \
		action_name]
	grid $label $widgets(action_name)
	grid $label -sticky news
	grid $widgets(action_name) -sticky ew
	grid columnconfigure $anf 1 -weight 1
	pack $anf -fill both -expand true

	# Action Buttons
	set bf [frame $f.useaction.buttons]
	set startActionBtn [button $bf.createAction -text "Start Action" \
		-command [code StartAction $f]] 
	set endActionBtn [button $bf.endAction -text "End Action" \
		-command [code EndAction $f]] 
	grid $startActionBtn $endActionBtn
	grid $startActionBtn -sticky news
	grid $endActionBtn -sticky ew
	pack $bf -fill both -expand true

	pack $f.useaction -fill x -expand true -side top


	pack $f -fill both -expand true
	set state(widgets) [array get widgets]
	return $f
    }

    proc CreateAnim {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	set type [$widgets(animtypebox) cget -value]
	set parent [TRPropEdit::GetValue $widgets(parent_name)]
	set name $state(childname)

	switch $type {
	    Container {
		set result [objnew s_container $parent $name]
		TRPropEdit::SetValue $widgets(parent_name) $result
	    }
	    Interpolation {
		set result [objnew s_anim_interp $parent $name]
		TRPropEdit::SetValue $widgets(curve_name) $result
	    }
	    Alias {
		objnew s_alias_container $parent $name
		TRPropEdit::SetValue $widgets(curve_name) $result
	    }
	    Curve {
		set result [objnew s_anim_curve $parent $name]
		TRPropEdit::SetValue $widgets(curve_name) $result
	    }
	}
	TRPropEdit::SetValue $widgets(anim_root_name) $parent
    }

    proc LinkAnim {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	set curve [TRPropEdit::GetValue $widgets(curve_name)]
	set joint [TRPropEdit::GetValue $widgets(joint_name)]
	set channel [$widgets(animchannelbox) cget -value]
	set clocktype [$widgets(clocktypebox) cget -value]

	switch $clocktype {
	    "Real-time" {
		set useclock 1
	    }
	    "Assigned time" {
		set useclock 0
	    }
	}


	set current_curves [objget $joint bound_animations]
	objset $joint {-bound_animations} "$current_curves \{\( $curve \, \
		$channel \, $useclock \) \} "

	TRPropEdit::SetValue $widgets(objroot_name) $joint

    }

    proc CreateAction {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	set curve [TRPropEdit::GetValue $widgets(anim_root_name)]
	set joint [TRPropEdit::GetValue $widgets(objroot_name)]
	set name $state(actionchildname)
	set parent [TRPropEdit::GetValue $widgets(action_parent_name)]

	set result [objnew s_action_anim $parent $name]
	objset $result {-root_anim} $curve
	objset $result {-root_object} $joint

	TRPropEdit::SetValue $widgets(action_name) $result

    }

    proc StartAction {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)
	set action [TRPropEdit::GetValue $widgets(action_name)]

	set result [objcall $action start]
	if {[lindex $result 0] == 1} {
	    set widgets(action_inst) [lindex $result 1]
	    set state(widgets) [array get widgets] 
	}

    }

    proc EndAction {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	objcall $widgets(action_inst) end
    }
}
