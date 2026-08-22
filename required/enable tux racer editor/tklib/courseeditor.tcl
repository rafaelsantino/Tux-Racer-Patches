
namespace eval TRCourseEditor {
    
    proc Create {f} {
	global tux_data_dir
	upvar #0 _state$f state
	toplevel $f

	wm title $f "Course Editor"
	wm overrideredirect $f yes
	wm positionfrom $f user
	wm geometry $f +100+100
	set state(xpos) 100
	set state(ypos) 100
	set state(xmousepos) 100
	set state(ymousepos) 100

	set balloon [tixBalloon $f.tooltip]

	set wf [frame $f.wf -borderwidth 2 -relief raised]

	#
	# Title Bar
	#
	set titleFrame [frame $wf.titleFrame -background #0A246A \
		-borderwidth 2]
	set image [image create photo \
		-file $tux_data_dir/tklib/close.gif]
	set closebutton [button $titleFrame.close -image $image \
		-command [list destroy $f]]
	pack $closebutton -side right
	pack $titleFrame -side top -fill x -expand yes

	bind $titleFrame <Button-1> [code ClickWindow $f %X %Y]
	bind $titleFrame <B1-Motion> [code MoveWindow $f %X %Y]

	#
	# Draw Mode Buttons
	#
	set drawFrame [frame $wf.drawFrame -borderwidth 3]

	set state(drawMode) [objget :modes:editor draw_style]
	set image [image create photo \
		-file $tux_data_dir/tklib/normal_terrain.gif]
	set normalDrawBtn [radiobutton $drawFrame.normal -image $image \
		-width 16 -height 16 -variable _state$f\(drawMode\) \
		-value Polygons -indicatoron no \
		-command [code UpdateDrawMode $f]]
	$balloon bind $normalDrawBtn -msg "Standard Draw Style"

	set image [image create photo \
		-file $tux_data_dir/tklib/wireframe.gif]
	set wireframeDrawBtn [radiobutton $drawFrame.wireframe -image $image \
		-width 16 -height 16 -variable _state$f\(drawMode\) \
		-value Wireframe -indicatoron no \
		-command [code UpdateDrawMode $f]]
	$balloon bind $wireframeDrawBtn -msg "Wireframe Draw Style"

	set image [image create photo \
		-file $tux_data_dir/tklib/normal_and_wireframe.gif]
	set bothDrawBtn [radiobutton $drawFrame.both -image $image \
		-width 16 -height 16 -variable _state$f\(drawMode\) \
		-value Both -indicatoron no \
		-command [code UpdateDrawMode $f]]
	$balloon bind $bothDrawBtn -msg "Standard+Wireframe Draw Style"

	set image [image create photo \
		-file $tux_data_dir/tklib/contour.gif]
	set contourDrawBtn [radiobutton $drawFrame.contour -image $image \
		-width 16 -height 16 -variable _state$f\(drawMode\) \
		-value Contour -indicatoron no \
		-command [code UpdateDrawMode $f]]
	$balloon bind $contourDrawBtn -msg "Contour Draw Style"

	grid $normalDrawBtn $wireframeDrawBtn
	grid $bothDrawBtn $contourDrawBtn

	pack $drawFrame

	#
	# Edit Mode Buttons
	#
	set editFrame [frame $wf.edit -borderwidth 3]

	set state(editMode) [objget :modes:editor edit_mode]
	set image [image create photo \
		-file $tux_data_dir/tklib/object_edit.gif]
	set objectBtn [radiobutton $editFrame.object -image $image \
		-width 16 -height 16 \
		-variable _state$f\(editMode\) -value Object \
		-indicatoron no \
		-command [code UpdateEditMode $f]]
	$balloon bind $objectBtn -msg "Edit Objects (right-click to place)"

	set image [image create photo \
		-file $tux_data_dir/tklib/vertex_edit.gif]
	set vertexBtn [radiobutton $editFrame.vertex -image $image \
		-width 16 -height 16 \
		-variable _state$f\(editMode\) -value Vertex \
		-indicatoron no \
		-command [code UpdateEditMode $f]]
	$balloon bind $vertexBtn -msg "Edit Vertices"

	set image [image create photo \
		-file $tux_data_dir/tklib/paint_height_edit.gif]
	set paintHeightBtn [radiobutton $editFrame.paintHeight -image $image \
		-width 16 -height 16 \
		-variable _state$f\(editMode\) -value {Paint Height} \
		-indicatoron no \
		-command [code UpdateEditMode $f]]
	$balloon bind $paintHeightBtn -msg "Paint Height"

	set image [image create photo \
		-file $tux_data_dir/tklib/smooth_edit.gif]
	set smoothBtn [radiobutton $editFrame.smooth -image $image \
		-width 16 -height 16 \
		-variable _state$f\(editMode\) -value {Smooth Height} \
		-indicatoron no \
		-command [code UpdateEditMode $f]]
	$balloon bind $smoothBtn -msg "Smooth Height"

	set image [image create photo \
		-file $tux_data_dir/tklib/paint_texture_edit.gif]
	set textureBtn [radiobutton $editFrame.texture -image $image \
		-width 16 -height 16 \
		-variable _state$f\(editMode\) -value {Paint Texture} \
		-indicatoron no \
		-command [code UpdateEditMode $f]]
	$balloon bind $textureBtn -msg "Paint Terrain (right-click to select terrain)"

	set image [image create photo \
		-file $tux_data_dir/tklib/make_nice.gif]
	set makeNiceBtn [radiobutton $editFrame.makeNice -image $image \
		-width 16 -height 16 \
		-variable _state$f\(editMode\) -value {Make Nice} \
		-indicatoron no \
		-command [code UpdateEditMode $f]]
	$balloon bind $makeNiceBtn -msg "Make Nice"

	grid $objectBtn $vertexBtn
	grid $paintHeightBtn $smoothBtn
	grid $textureBtn $makeNiceBtn

	pack $editFrame

	#
	# Toggles
	#
	set togglesFrame [frame $wf.toggles -borderwidth 3]

	set image [image create photo \
		-file $tux_data_dir/tklib/follow_terrain.gif]
	set state(followTerrain) [objget :modes:editor follow_terrain]
	set followTerrain [checkbutton $togglesFrame.followTerrain \
		-indicatoron no -image $image \
		-variable _state$f\(followTerrain\) \
		-command [code UpdateFollowTerrain $f]]
	$balloon bind $followTerrain -msg "Follow Terrain"

	set image [image create photo \
		-file $tux_data_dir/tklib/flat_space.gif]
	set state(flatSpace) [objget :modes:editor flat_modification_space]
	set flatSpace [checkbutton $togglesFrame.flatSpace \
		-indicatoron no -image $image \
		-variable _state$f\(flatSpace\) \
		-command [code UpdateFlatSpace $f]]
	$balloon bind $flatSpace -msg "Flat Modification Space"

	set image [image create photo \
		-file $tux_data_dir/tklib/bounding_volumes.gif]
	set state(bvs) [objget :modes:editor draw_bounding_volumes]
	set bvs [checkbutton $togglesFrame.bvs \
		-indicatoron no -image $image \
		-variable _state$f\(bvs\) \
		-command [code UpdateBVs $f]]
	$balloon bind $bvs -msg "Draw Bounding Volumes"

	set image [image create photo \
		-file $tux_data_dir/tklib/draw_collidables.gif]
	set state(colls) [objget :modes:editor draw_collidables]
	set colls [checkbutton $togglesFrame.colls \
		-indicatoron no -image $image \
		-variable _state$f\(colls\) \
		-command [code UpdateColls $f]]
	$balloon bind $colls -msg "Draw Collidables"

	set image [image create photo \
		-file $tux_data_dir/tklib/help.gif]
	set state(help) [objget :modes:editor help_display]
	set help [checkbutton $togglesFrame.help \
		-indicatoron no -image $image \
		-variable _state$f\(help\) \
		-command [code UpdateHelp $f]]
	$balloon bind $help -msg "Show Help"

	set image [image create photo \
		-file $tux_data_dir/tklib/vertex_area.gif]
	set state(vertexDisplay) [objget :modes:editor vertex_display]
	set vertexDisplay [checkbutton $togglesFrame.vertexDisplay \
		-indicatoron no -image $image \
		-variable _state$f\(vertexDisplay\) \
		-command [code UpdateVertexDisplay $f]]
	$balloon bind $vertexDisplay -msg "Show Vertices"

	set image [image create photo \
		-file $tux_data_dir/tklib/auto_adjust_heights.gif]
	set state(autoAdjustHeights) [objget :modes:editor auto_adjust_item_heights]
	set autoAdjustHeights [checkbutton $togglesFrame.autoAdjustHeights \
		-indicatoron no -image $image \
		-variable _state$f\(autoAdjustHeights\) \
		-command [code UpdateAutoAdjustHeights $f]]
	$balloon bind $autoAdjustHeights -msg "Auto Adjust Item Heights"

	set image [image create photo \
		-file $tux_data_dir/tklib/auto_recalc_error.gif]
	set state(autoRecomputeError) [objget :modes:editor auto_recompute_error]
	set autoRecomputeError [checkbutton $togglesFrame.autoRecomputeError \
		-indicatoron no -image $image \
		-variable _state$f\(autoRecomputeError\) \
		-command [code UpdateAutoRecomputeError $f]]
	$balloon bind $autoRecomputeError -msg "Automatically recompute quadtree error after each painting operation"

	grid $followTerrain $flatSpace
	grid $bvs $colls
	grid $vertexDisplay $autoAdjustHeights
	grid $autoRecomputeError $help

	pack $togglesFrame


	#
	# Save/Load controls
	#
	set saveloadFrame [frame $wf.saveload -borderwidth 3]

	set image [image create photo \
		-file $tux_data_dir/tklib/save_elevation.gif]
	set saveElevBtn [button $saveloadFrame.saveElev \
		-width 16 -height 16 -image $image \
		-command {objcall :modes:editor write_elevation_data}] 
	$balloon bind $saveElevBtn -msg "Save Elevation Data"

	set image [image create photo \
		-file $tux_data_dir/tklib/save_terrain.gif]
	set saveTerrainBtn [button $saveloadFrame.saveTerrain \
		-width 16 -height 16 -image $image \
		-command {objcall :modes:editor write_terrain_data}] 
	$balloon bind $saveTerrainBtn -msg "Save Terrain Data"

	set image [image create photo \
		-file $tux_data_dir/tklib/save_items.gif]
	set saveItemsBtn [button $saveloadFrame.saveItems \
		-width 16 -height 16 -image $image \
		-command [code SaveObjectFile]] 
	$balloon bind $saveItemsBtn -msg "Save Items"

	set image [image create photo \
		-file $tux_data_dir/tklib/save_ai_targets.gif]
	set saveTargets [button $saveloadFrame.saveTargets \
		-width 16 -height 16 -image $image \
		-command [code SaveTargets]] 
	$balloon bind $saveTargets -msg "Save AI Targets" 

	set image [image create photo \
		-file $tux_data_dir/tklib/reload_course.gif]
	set reloadBtn [button $saveloadFrame.reload \
		-width 16 -height 16 -image $image \
		-command {objcall :modes:editor reload_course}] 
	$balloon bind $reloadBtn -msg "Reload Course"

	set image [image create photo \
		-file $tux_data_dir/tklib/play.gif]
	set playBtn [button $saveloadFrame.play \
		-width 16 -height 16 -image $image \
		-command {objcall :modes:editor play}] 
	$balloon bind $playBtn -msg "Start Racing"

	grid $saveElevBtn $saveTerrainBtn
	grid $saveItemsBtn $saveTargets 
	grid $reloadBtn $playBtn

	pack $saveloadFrame


	#
	# Controls
	#
	set controlsFrame [frame $wf.controls -borderwidth 3]

	set image [image create photo \
		-file $tux_data_dir/tklib/speed.gif]
	set state(speed) [expr log([objget :modes:editor velocity_multiplier]) / log(2) + 1]
	set speedCtrl [tixControl $controlsFrame.speed -integer yes \
		-allowempty no -min 1 -max 5 \
		-options [list \
		          entry.width 2 \
		          label.image $image \
			  label.borderWidth 2] \
		-command [code UpdateSpeed $f]  \
		-variable _state$f\(speed\)]
	$balloon bind $speedCtrl -msg "Velocity Multiplier"

	pack $speedCtrl -side top -anchor e

	set image [image create photo \
		-file $tux_data_dir/tklib/mod_area.gif]
	set state(modArea) [objget :modes:editor vertex_edit_area]
	set modAreaCtrl [tixControl $controlsFrame.modArea -integer yes \
		-allowempty no -min 1 -max 20 \
		-options [list \
		          entry.width 2 \
			  label.image $image \
			  label.borderWidth 2] \
		-command [code UpdateModArea $f] -label M: \
		-variable _state$f\(modArea\)]
	$balloon bind $modAreaCtrl -msg "Modification Area"

	pack $modAreaCtrl -side top -anchor e

	set image [image create photo \
		-file $tux_data_dir/tklib/smooth_edit.gif]
	set state(blur) [objget :modes:editor blur_filter_size]
	set blurCtrl [tixControl $controlsFrame.blur -integer yes \
		-allowempty no -min 1 -max 20 \
		-options [list \
		          entry.width 2 \
			  label.image $image \
			  label.borderWidth 2] \
		-command [code UpdateBlurFilter $f] -label B: \
		-variable _state$f\(blur\)]
	$balloon bind $blurCtrl -msg "Blur Filter Radius"

	pack $blurCtrl -side top -anchor e

	set image [image create photo \
		-file $tux_data_dir/tklib/vertex_area.gif]
	set state(vertex) [objget :modes:editor vertex_display_area]
	set vertexCtrl [tixControl $controlsFrame.vertex -integer yes \
		-allowempty no -min 1 -step 2  \
		-options [list \
		          entry.width 2 \
			  label.image $image \
			  label.borderWidth 2] \
		-command [code UpdateVertex $f] -label V: \
		-variable _state$f\(vertex\)]
	$balloon bind $vertexCtrl -msg "Vertex Display Area"

	pack $vertexCtrl -side top -anchor e

	pack $controlsFrame

	#
	# Pop-up Menus
	#
	set state(objectMenuSubmenus) 0
	set objectMenu [menu $f.objects -title {Place Object} \
		-postcommand [code CreateObjectMenu $f]]
	set state(objectMenu) $objectMenu
	bind $objectBtn <Button-3> [list tk_popup $objectMenu %X %Y]

	set terrainMenu [menu $f.terrains -title {Select Terrain} \
		-postcommand [code CreateTerrainMenu $f]]
	set state(terrainMenu) $terrainMenu
	bind $textureBtn <Button-3> [list tk_popup $terrainMenu %X %Y]


	pack $wf

	bind $f <Destroy> [list if {"%W" == "."} [list unset _state$f]]

	after 1000 [code UpdateSettings $f]

	return $f
    }

    proc UpdateDrawMode {f} {
	upvar #0 _state$f state
	objset :modes:editor -draw_style $state(drawMode)
    }

    proc UpdateEditMode {f} {
	upvar #0 _state$f state
	objset :modes:editor -edit_mode $state(editMode)
    }

    proc UpdateSpeed {f newval} {
	objset :modes:editor -velocity_multiplier [expr 1 << ($newval - 1)]
    }

    proc UpdateModArea {f newval} {
	objset :modes:editor -vertex_edit_area $newval
    }

    proc UpdateBlurFilter {f newval} {
	objset :modes:editor -blur_filter_size $newval
    }

    proc UpdateVertex {f newval} {
	objset :modes:editor -vertex_display_area $newval
    }

    proc UpdateFollowTerrain {f} {
	upvar #0 _state$f state
	objset :modes:editor -follow_terrain $state(followTerrain)
    }

    proc UpdateFlatSpace {f} {
	upvar #0 _state$f state
	objset :modes:editor -flat_modification_space $state(flatSpace)
    }

    proc UpdateBVs {f} {
	upvar #0 _state$f state
	objset :modes:editor -draw_bounding_volumes $state(bvs)
    }

    proc UpdateColls {f} {
	upvar #0 _state$f state
	objset :modes:editor -draw_collidables $state(colls)
    }

    proc UpdateHelp {f} {
	upvar #0 _state$f state
	objset :modes:editor -help_display $state(help)
    }

    proc UpdateVertexDisplay {f} {
	upvar #0 _state$f state
	objset :modes:editor -vertex_display $state(vertexDisplay)
    }
    
    proc UpdateAutoAdjustHeights {f} {
	upvar #0 _state$f state
	objset :modes:editor -auto_adjust_item_heights $state(autoAdjustHeights)
    }
    proc UpdateAutoRecomputeError {f} {
	upvar #0 _state$f state
	objset :modes:editor -auto_recompute_error $state(autoRecomputeError)
    }

    proc ClickWindow {f x y} {
	upvar #0 _state$f state
	set state(xmousepos) $x
	set state(ymousepos) $y
    }
    
    proc MoveWindow {f x y} {
	upvar #0 _state$f state
	
	set xdelta [expr $x - $state(xmousepos)]
	set ydelta [expr $y - $state(ymousepos)]

	set geom [wm geometry $f]

	if [regexp {\+([0-9]*)\+([0-9]*)} $geom match xpos ypos] {
	    wm geometry $f +[expr $xpos+$xdelta]+[expr $ypos+$ydelta]
	}

	set state(xmousepos) $x
	set state(ymousepos) $y
    }

    proc SortObjectsByBasename {a b} {
	return [string compare -nocase \
		[objget $a basename] [objget $b basename]]
    }

    proc CreateObjectMenu {f} {
	upvar #0 _state$f state

	set menu $state(objectMenu)
	set i 0
	while {$i < $state(objectMenuSubmenus)} {
	    # $menu.sub$i delete 0 end
	    destroy $menu.sub$i
	    incr i
	}
	$menu delete 0 end

	set obj3dlist [GetObjects3d :objects]

	set obj3dlist [lsort -command [code SortObjectsByBasename] $obj3dlist]

	set objcount 20
	set submenu 0
	set numsubmenus 0
	foreach obj3d $obj3dlist {
	    if { $objcount == 20 } {
		$menu add cascade -label [objget $obj3d basename] \
			-menu $menu.sub$numsubmenus
		set submenu [menu $menu.sub$numsubmenus]
		set objcount 0
		incr numsubmenus
	    }
	    $submenu add command -label [objget $obj3d basename] \
		    -command [code CreateObjectInstance $obj3d]
	    incr objcount 
	}

	set state(objectMenuSubmenus) $numsubmenus
    }

    proc GetObjects3d {obj} {
	if [objcall $obj is_a s_object3d] {
	    return $obj
	} elseif [objcall $obj is_a s_container] {
	    set obj3dlist {}
	    foreach child [objget $obj children] {
		set obj3dlist [concat $obj3dlist [GetObjects3d $child]]
	    }
	    return $obj3dlist
	}
	return {}
    }

    proc CreateObjectInstance {obj3d} {
	set basename [objget $obj3d basename]
	set name $basename
	set suffix ""
	set i 0
	if {[objget $obj3d reset_point]} {
	    while {1} {
		if { ![objexists ":reset_points:$name"] } {
		    break
		}
		incr i
		set name "$basename-$i"
	    }
	    objcall $obj3d create_instance_rel :reset_points $name
	    return :reset_points:$name
	} elseif {[objget $obj3d start_point]} {
	    while {1} {
		if { ![objexists ":start_points:$name"] } {
		    break
		}
		incr i
		set name "$basename-$i"
	    }
	    objcall $obj3d create_instance_rel :start_points $name
	    return :start_points:$name
	} else {
	    while {1} {
		if { ![objexists ":scene:$name"] } {
		    break
		}
		incr i
		set name "$basename-$i"
	    }
	    objcall $obj3d create_instance_rel :scene $name
	    return :scene:$name
	}

	return $name
    }

    proc CreateTerrainMenu {f} {
	upvar #0 _state$f state

	set menu $state(terrainMenu)
	$menu delete 0 end

	set terrainlist [GetTerrains :terrains]

	set terrainlist [lsort -command [code SortObjectsByBasename] \
		$terrainlist]

	foreach terrain $terrainlist {
	    $menu add command -label [objget $terrain basename] \
		    -command [list objset :modes:editor \
		    -terrain_paint $terrain]
	}
    }

    proc GetTerrains {obj} {
	if [objcall $obj is_a s_terrain] {
	    return $obj
	} elseif [objcall $obj is_a s_container] {
	    set terrainlist {}
	    foreach child [objget $obj children] {
		set terrainlist [concat $terrainlist [GetTerrains $child]]
	    }
	    return $terrainlist
	}
	return {}
    }

    # Note: this procedure is also called from C code in s_editor.c.
    proc SaveObjectFile {} {
	global tux_data_dir

	TRMainWin::ConsoleEval {puts "Saving items.tcl file..."}
	update

	set course [objget :modes:editor current_course]
	if { "$course" == "" } {
	    tk_messageBox -type ok -message "Can't save: no course is loaded"
	    return
	}

	set fname "$tux_data_dir/courses/$course/items.tcl"

	if [catch {open $fname w} fileId] {
	    tk_messageBox -type ok -message "$fileId"
	} else {
	    fconfigure $fileId -buffering full

	    # Stop animations so that animation state doesn't get saved.
	    set activeanimlist [StopAnimationActions :actions]

	    set serializelist { \
		    :sounds:course \
		    :music:course \
		    :textures:course \
		    :models:course \
		    :collidables:course \
		    :collision_responses:course \
		    :objects:course \
		    :anim:course \
		    :scene \
		    :reset_points \
		    :start_points \
		    :actions:course \
		    :terrains:course } 

	    foreach obj $serializelist {
		if [objexists $obj] {
		    puts $fileId [objserialize $obj]
		}
	    }

	    close $fileId

	    TRMainWin::ConsoleEval {puts "... done."}

	    # Restart animations
	    foreach anim $activeanimlist {
		objcall $anim start
	    }
	}
    }

    proc SaveTargets {} {
	global tux_data_dir

	if { [objget :ai_targets num_children] == 0 } {
	    tk_messageBox -type ok -message "No targets to save"
	    return
	}

	set aitargets [objserialize :ai_targets]

	regsub -all {:ai_targets} $aitargets {ai_targets} aitargets

	set aitargetsdir "$tux_data_dir/courses/[objget :modes:editor current_course]/ai_targets"

	if { ![file exists $aitargetsdir] } {
	    file mkdir $aitargetsdir
	    file mkdir "$aitargetsdir/easy"
	    file mkdir "$aitargetsdir/normal"
	    file mkdir "$aitargetsdir/hard"
	}

	set fname [tk_getSaveFile -initialdir $aitargetsdir \
		-title "Select File"]

	if { $fname == "" } {
	    return;
	}

	if [catch {open $fname w} fileId] {
	    tk_messageBox -type ok -message "$fileId"
	} else {
	    fconfigure $fileId -buffering full

	    puts $fileId $aitargets

	    close $fileId
	}
    }

    proc StopAnimationActions {obj} {
	# Find all s_action_anim_inst objects under :actions and end them.

	if [objcall $obj is_a s_action_anim_inst] {
	    set anim [objget $obj action]
	    objcall $obj end
	    return $anim
	} elseif [objcall $obj is_a s_container] {
	    set animlist {}
	    foreach child [objget $obj children] {
		set animlist [concat $animlist [StopAnimationActions $child]]
	    }
	    return $animlist
	}
	return {}
    }

    proc UpdateSettings { f } {
	upvar #0 _state$f state
	if { ![winfo exists $f] } {
	    # window gone, stop
	    return
	}

	set editor :modes:editor

	set state(drawMode) [objget $editor draw_style]
	set state(editMode) [objget $editor edit_mode]
	set state(followTerrain) [objget $editor follow_terrain]
	set state(flatSpace) [objget $editor flat_modification_space]
	set state(bvs) [objget $editor draw_bounding_volumes]
	set state(colls) [objget $editor draw_collidables]
	set state(help) [objget $editor help_display]
	set state(vertexDisplay) [objget $editor vertex_display]
	set state(autoAdjustHeights) [objget :modes:editor auto_adjust_item_heights]
	set state(autoRecomputeError) [objget :modes:editor auto_recompute_error]
	set state(speed) [expr log([objget :modes:editor velocity_multiplier])/log(2) + 1]
	set state(modArea) [objget :modes:editor vertex_edit_area]
	set state(blur) [objget :modes:editor blur_filter_size]
	set state(vertex) [objget :modes:editor vertex_display_area]

	after 500 [code UpdateSettings $f]
    }
}
