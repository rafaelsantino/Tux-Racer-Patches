
namespace eval TRSceneEditor {
    
    proc Create {f} {
	global tux_data_dir
	upvar #0 _state$f state

	frame $f


	# Create New Node Frame
	frame $f.new_node -border 4 -relief sunken

	# Create Header
	set header $f.new_node.header
	label $header -text "Create a new node" \
		-background black -foreground white
	pack $header -fill x -expand no

	# Parent Name
	set parentobjprop :classes:s_action_anim:properties:root_object
	set pf [frame $f.new_node.parentobj]
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

	# Node type select
	set state(nodetype) Unset
	set tf [frame $f.new_node.nodetype]
	set widgets(nodetypebox)  [tixComboBox $tf.node_type -label "" \
		-variable _state$f\(nodetype\) ]
	foreach nodetype {
	    "Transformation"
	    "Animation"
	    "OBJ Instance"
	    "Billboard Instance"
	} {
	    $widgets(nodetypebox) subwidget listbox insert end $nodetype
	}
	$widgets(nodetypebox) pick 0
	set label [TREditUtil::CreateLabel $tf.node_type_label node_type]
	grid $label $widgets(nodetypebox)
	grid $label -sticky news
	grid $widgets(nodetypebox) -sticky ew
	grid columnconfigure $tf 1 -weight 1
	pack $tf -fill x -expand true -side top

	# Object3D Select
	set state(obj3d) Unset
	set of [frame $f.new_node.obj3d]
	set widgets(obj3dbox)  [tixComboBox $of.obj3d -label "" \
		-variable _state$f\(obj3d\) ]
	set obj3dlist [TRCourseEditor::GetObjects3d :objects]
	set obj3dlist [lsort -command \
		[code TRCourseEditor::SortObjectsByBasename] $obj3dlist]
	foreach obj3d $obj3dlist {
	    $widgets(obj3dbox) subwidget listbox insert end $obj3d
	}
	$widgets(obj3dbox) pick 0
	set label [TREditUtil::CreateLabel $of.obj3d_label Object3D]
	grid $label $widgets(obj3dbox)
	grid $label -sticky news
	grid $widgets(obj3dbox) -sticky ew
	grid columnconfigure $tf 1 -weight 1
	pack $of -fill x -expand true -side top

	# Child Name
	set state(childname) ""
	set childf [frame $f.new_node.childname]
	set nameLabel [label $childf.nameLabel -text "child name: " \
		-justify left]
	set nameEntry [entry $childf.nameEntry \
		-textvariable _state$f\(childname\)]
	set createNodeBtn [button $childf.createNode -text "Create Node" \
		-command [code CreateNode $f]] 
	grid $nameLabel $nameEntry $createNodeBtn
	grid $nameLabel -sticky ew
	grid $nameEntry -sticky ew
	grid $createNodeBtn -sticky ew
	grid columnconfigure $childf 1 -weight 1
	pack $childf -fill x -expand true -side top

	pack $f.new_node -fill x -expand true -side top

	# Edit Node Frame
	frame $f.edit_node -border 4 -relief sunken

	# Create Header
	set header $f.edit_node.header
	label $header -text "Edit the node" \
		-background black -foreground white
	pack $header -fill x -expand no

	# Node Name
	set nodeobjprop :classes:s_action_anim:properties:root_object
	set nf [frame $f.edit_node.nodeobj]
	set proptype [objget $nodeobjprop type]
	set proplen  [objget $nodeobjprop length]
	set widgets(node_name) \
		[TRPropEdit::Create $nf.node_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $nf.node_name_label node_name]
	grid $label $widgets(node_name)
	grid $label -sticky news
	grid $widgets(node_name) -sticky ew
	grid columnconfigure $nf 1 -weight 1
	pack $nf -fill both -expand true

	# Select Node Button
	set selectNodeBtn [button $f.edit_node.select -text "Select Node" \
		-command [code SelectInEditor $f]] 
	pack $selectNodeBtn -fill both -expand true

	pack $f.edit_node -fill x -expand true -side top

	pack $f -fill both -expand true
	set state(widgets) [array get widgets]
	return $f
    }

    proc SelectInEditor {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)
	set obj [TRPropEdit::GetValue $widgets(node_name)]

	if { ![objcall $obj is_a s_sgnode] } {
	    tk_messageBox -type ok -message "$obj is not an s_sgnode" \
		    -parent $f
	    return
	}

	objset :modes:editor -picked_object $obj
    }

    proc CreateNode {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	set type [$widgets(nodetypebox) cget -value]
	set parent [TRPropEdit::GetValue $widgets(parent_name)]
	set name $state(childname)

	switch $type {
	    "Transformation" {
		set result [objnew s_sgnode $parent $name]
		TRPropEdit::SetValue $widgets(node_name) $result
	    }
	    "Animation" {
		set result [objnew s_sganim $parent $name]
		TRPropEdit::SetValue $widgets(node_name) $result
	    }
	    "OBJ Instance" {
		set obj3d $state(obj3d)
		set result [objnew s_object3dinst $parent $name]
		objset $result -object3d $obj3d
		TRPropEdit::SetValue $widgets(node_name) $result
	    }
	    "Billboard Instance" {
		set result [objnew s_billboard_inst $parent $name]
		objset $result -object3d $obj3d
		TRPropEdit::SetValue $widgets(node_name) $result
	    }
	}
    }

}
