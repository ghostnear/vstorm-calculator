module main

import gx
import math
import vstorm

// Background factory
pub fn create_background() &vstorm.Node{
	mut node := &vstorm.Node{}
	node.add_component(
		&gx.Color{
			r: 0x11
			g: 0x11
			b: 0x11
		},
		'color'
	)
	node.add_function(
		fn(mut node &vstorm.Node) {
			mut ggc := node.context.win.gg
			w_size := node.context.win.get_size()
			ggc.draw_rect_filled(
				0, 0,
				w_size.x, w_size.y,
				&gx.Color(node.get_component('color'))
			)
		},
		'draw'
	)
	return node
}

// Config for the button texts
struct ButtonTextConfig {
	text string
	textcfg gx.TextCfg
}

// Factory for BUTTON texts
pub fn create_text(text string) &vstorm.Node {
	mut node := &vstorm.Node{}
	node.add_component(
		&ButtonTextConfig {
			text: text
			textcfg: gx.TextCfg{
				color: gx.rgb(0xAA, 0xAA, 0xAA)
				size: 40
				italic: true
				align:          gx.HorizontalAlign.center
				vertical_align: gx.VerticalAlign.middle
			}
		},
		'text'
	)
	node.add_function(
		fn(mut node &vstorm.Node) {
			mut win := node.context.win
			mut ggc := win.gg
			w_size := win.get_size()

			// Parent is guaranteed to be a button so get the properties so we know where to draw the text
			pos := (&vstorm.NodeV2D(node.parent.get_component('position'))).get_relative_to(w_size)
			siz := (&vstorm.NodeV2D(node.parent.get_component('size'))).get_relative_to(w_size)

			// Get text config and size
			t := &ButtonTextConfig(node.get_component('text'))
			ggc.set_cfg(t.textcfg)

			ggc.draw_text(
				int(pos.x + siz.x / 2),
				int(pos.y + siz.y / 2),
				t.text,
				t.textcfg
			)
		},
		'draw'
	)
	return node
}

// Config for the factory
struct ButtonConfig {
	xindex int
	yindex int
	text string
	size vstorm.NodeV2D
	normal_color gx.Color
	over_color gx.Color
}

struct ButtonAnimState {
mut:
	mouse_over bool
	normal_color gx.Color
	over_color gx.Color
}

// Button factory
pub fn create_calculator_button(cfg ButtonConfig) &vstorm.Node {
	mut butt := &vstorm.Node{}
	mut size_x := f32(135.0 / 540)
	mut size_y := f32(135.0 / 960)
	butt.add_component(
		&vstorm.NodeV2D {
			x: 0	   			+ size_x * cfg.xindex
			y: (285.0 / 960)  	+ size_y * cfg.yindex
			r: true
		},
		'position'
	)
	butt.add_component(
		&vstorm.NodeV2D {
			x: size_x * cfg.size.x
			y: size_y * cfg.size.y
			r: true
		},
		'size'		
	)
	butt.add_component(
		&vstorm.NodeV2D {
			x: 2.0
			y: 2.0
			r: false
		},
		'padding'
	)
	butt.add_component(
		&ButtonAnimState{
			normal_color: cfg.normal_color
			over_color: cfg.over_color
		},
		'animation_state'
	)
	butt.add_function(
		fn(mut node &vstorm.Node) {
			mut ggc := node.context.win.gg
			w_size := node.context.win.get_size()

			// Convert the properties to be relative to the window
			pos := (&vstorm.NodeV2D(node.get_component('position'))).get_relative_to(w_size)
			siz := (&vstorm.NodeV2D(node.get_component('size'))).get_relative_to(w_size)
			pad := (&vstorm.NodeV2D(node.get_component('padding'))).get_relative_to(w_size)

			anim_state := &ButtonAnimState(node.get_component('animation_state'))
			mut color := anim_state.normal_color
			if anim_state.mouse_over {
				color = anim_state.over_color
			}
			ggc.draw_rounded_rect_filled(
				pos.x + pad.x, pos.y + pad.y,
				siz.x - 2 * pad.x, siz.y - 2 * pad.y,
				0.1 * math.min(siz.x, siz.y),
				color
			)
		},
		'draw'
	)
	butt.add_function(
		fn(mut node &vstorm.Node) {
			// Get window pointer
			mut window := node.context.win

			// Only on mouse moved
			match window.latest_event.typ {
				.mouse_move {
					// Get mouse position
					mut mouse_pos := window.get_mouse_pos()

					// Convert the properties to be relative to the window
					w_size := window.get_size()
					pos := (&vstorm.NodeV2D(node.get_component('position'))).get_relative_to(w_size)
					siz := (&vstorm.NodeV2D(node.get_component('size'))).get_relative_to(w_size)
					pad := (&vstorm.NodeV2D(node.get_component('padding'))).get_relative_to(w_size)
					
					// If inside change the state
					mut anim_state := &ButtonAnimState(node.get_component('animation_state'))
					if mouse_pos.x >= pos.x + pad.x && mouse_pos.y >= pos.y + pad.y &&
					   mouse_pos.x <= pos.x + siz.x - pad.x && mouse_pos.y <= pos.y + siz.y - pad.y {
						anim_state.mouse_over = true
					}
					else {
						anim_state.mouse_over = false
					}
				}
				else {}
			}
		},
		'event'
	)
	// If we have a text, add the node here
	if cfg.text != '' {
		butt.add_child(mut create_text(cfg.text), 'button_text')
	}
	return butt
}