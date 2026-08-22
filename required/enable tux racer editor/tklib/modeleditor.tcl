
namespace eval TRModelEditor {

    proc Create {f} {
	global tux_data_dir
	upvar #0 _state$f state

	frame $f

	# Create Node Frame
	frame $f.create_node -border 4 -relief sunken

	# Create Header
	set header $f.create_node.header
	label $header -text "Create a new node" \
		-background black -foreground white
	pack $header -fill x -expand no


	# Parent Name
	set parentobjprop :classes:s_action_anim:properties:root_object
	set pf [frame $f.create_node.parentobj]
	set proptype [objget $parentobjprop type]
	set proplen  [objget $parentobjprop length]
	set widgets(parent_name) \
		[TRPropEdit::Create $pf.parent_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $pf.parent_name_label parent_name]
	grid $label $widgets(parent_name)
	grid $label -sticky news
	grid $widgets(parent_name) -sticky ew
	grid columnconfigure $pf 1 -weight 1

	# Node type select
	set state(nodetype) Unset
	set state(widgets) [array get widgets]
	set tf [frame $f.create_node.nodetype]
	set widgets(nodetypebox)  [tixComboBox $tf.node_type -label "" \
		-variable _state$f\(nodetype\) \
		-command [code SetNodeType $f] ]
	foreach nodetype {
	    "Container"
	    "OBJ Model"
	    "Texture"
	    "Object 3D"
	} {
	    $widgets(nodetypebox) subwidget listbox insert end $nodetype
	}
	$widgets(nodetypebox) pick 1
	set label [TREditUtil::CreateLabel $tf.node_type_label node_type]
	grid $label $widgets(nodetypebox)
	grid $label -sticky news
	grid $widgets(nodetypebox) -sticky ew
	grid columnconfigure $tf 1 -weight 1
	pack $tf -fill x -expand true -side top
	pack $pf -fill both -expand true


	# Child Name
	set state(childname) ""
	set childf [frame $f.create_node.childname]
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

	pack $f.create_node -fill x -expand true -side top

	# Load Model Frame
	frame $f.load_model -border 4 -relief sunken

	# Create Header
	set header $f.load_model.header
	label $header -text "Load Model OBJ" \
		-background black -foreground white
	pack $header -fill x -expand no

	# Model Name
	set modelobjprop :classes:s_action_anim:properties:root_object
	set nf [frame $f.load_model.modelobj]
	set proptype [objget $modelobjprop type]
	set proplen  [objget $modelobjprop length]
	set widgets(model_name) \
		[TRPropEdit::Create $nf.model_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $nf.model_name_label model_name]
	grid $label $widgets(model_name)
	grid $label -sticky news
	grid $widgets(model_name) -sticky ew
	grid columnconfigure $nf 1 -weight 1
	pack $nf -fill both -expand true

	# Load Model 
	set filenameprop :classes:s_model_obj:properties:filename
	set nf [frame $f.load_model.filename]
	set proptype [objget $filenameprop type]
	set proplen  [objget $filenameprop length]
	set widgets(filename) \
		[TRPropEdit::Create $nf.filename $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $nf.filename_label filename]
	set loadModelBtn [button $nf.load -text "Load Model" \
		-command [code LoadModel $f]] 
	grid $label $widgets(filename) $loadModelBtn
	pack $nf -fill both -expand true

	pack $f.load_model -fill x -expand true -side top


	# Load Texture Frame
	frame $f.load_texture -border 4 -relief sunken

	# Create Header
	set header $f.load_texture.header
	label $header -text "Load Texture PNG" \
		-background black -foreground white
	pack $header -fill x -expand no

	# Texture Name
	set textureobjprop :classes:s_action_anim:properties:root_object
	set nf [frame $f.load_texture.textureobj]
	set proptype [objget $textureobjprop type]
	set proplen  [objget $textureobjprop length]
	set widgets(texture_name) \
		[TRPropEdit::Create $nf.texture_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $nf.texture_name_label texture_name]
	grid $label $widgets(texture_name)
	grid $label -sticky news
	grid $widgets(texture_name) -sticky ew
	grid columnconfigure $nf 1 -weight 1
	pack $nf -fill both -expand true

	# Load Texture 
	set filenameprop :classes:s_texture:properties:filename
	set nf [frame $f.load_texture.filename]
	set proptype [objget $filenameprop type]
	set proplen  [objget $filenameprop length]
	set widgets(texfilename) \
		[TRPropEdit::Create $nf.filename $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $nf.filename_label filename]
	set loadTextureBtn [button $nf.load -text "Load Texture" \
		-command [code LoadTexture $f]] 
	grid $label $widgets(texfilename) $loadTextureBtn
	pack $nf -fill both -expand true

	pack $f.load_texture -fill x -expand true -side top


	# Set Obj3D Frame
	frame $f.set_obj3d -border 4 -relief sunken

	# Create Header
	set header $f.set_obj3d.header
	label $header -text "Set Obj3D Texture and Model" \
		-background black -foreground white
	pack $header -fill x -expand no

	# Obj3D Name
	set obj3dobjprop :classes:s_action_anim:properties:root_object
	set nf [frame $f.set_obj3d.obj3dobj]
	set proptype [objget $obj3dobjprop type]
	set proplen  [objget $obj3dobjprop length]
	set widgets(obj3d_name) \
		[TRPropEdit::Create $nf.obj3d_name $proptype "" $proplen rw]
	set label [TREditUtil::CreateLabel $nf.obj3d_name_label obj3d_name]
	grid $label $widgets(obj3d_name)
	grid $label -sticky news
	grid $widgets(obj3d_name) -sticky ew
	grid columnconfigure $nf 1 -weight 1
	pack $nf -fill both -expand true

	set setObj3dBtn [button $f.set_obj3d.btn -text "Set Obj3D" \
		-command [code SetObj3d $f]] 
	pack $setObj3dBtn -fill both -expand true

	pack $f.set_obj3d -fill x -expand true -side top

	pack $f -fill both -expand true
	set state(widgets) [array get widgets]
	return $f
    }

    proc CreateNode {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	set type [$widgets(nodetypebox) cget -value]
	set parent [TRPropEdit::GetValue $widgets(parent_name)]
	set name $state(childname)

	switch $type {
	    "Container" {
		set result [objnew s_container $parent $name]
		TRPropEdit::SetValue $widgets(parent_name) $result
	    }
	    "OBJ Model" {
		set result [objnew s_model_obj $parent $name]
		TRPropEdit::SetValue $widgets(model_name) $result
	    }
	    "Texture" {
		set result [objnew s_texture $parent $name]
		TRPropEdit::SetValue $widgets(texture_name) $result
	    }
	    "Object 3D" {
		set result [objnew s_object3d $parent $name]
		TRPropEdit::SetValue $widgets(obj3d_name) $result
	    }
	}

    }

    proc SetNodeType {f type} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	switch $type {
	    "Container" {
	    }
	    "OBJ Model" {
		TRPropEdit::SetValue $widgets(parent_name) :models
	    }
	    "Texture" {
		TRPropEdit::SetValue $widgets(parent_name) :textures
	    }
	    "Object 3D" {
		TRPropEdit::SetValue $widgets(parent_name) :objects
	    }
	}
    }

    proc LoadModel {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	set name [TRPropEdit::GetValue $widgets(model_name)]
	set filename  [TRPropEdit::GetValue $widgets(filename)]
	objset $name -filename $filename

    }

    proc LoadTexture {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	set name [TRPropEdit::GetValue $widgets(texture_name)]
	set filename  [TRPropEdit::GetValue $widgets(texfilename)]
	objset $name -filename $filename

    }

    proc SetObj3d {f} {
	upvar #0 _state$f state

	array set widgets $state(widgets)

	set name [TRPropEdit::GetValue $widgets(obj3d_name)]
	set texname [TRPropEdit::GetValue $widgets(texture_name)]
	set modelname [TRPropEdit::GetValue $widgets(model_name)]
	objset $name -drawable_model $modelname
	objset $name -texture $texname
    }

}
