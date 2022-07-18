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
struct TextConfig {
	// I'd use the actual gx config if it would be mutable, oh well
	// TODO: In the future find an alternative
pub mut:
	color gx.Color
	size int
	italic bool
	align gx.HorizontalAlign
	vertical_align gx.VerticalAlign
}

struct ButtonTextConfig {
	text string
	textcfg TextConfig
}

// Factory for BUTTON texts
pub fn create_text(text string) &vstorm.Node {
	mut node := &vstorm.Node{}
	node.add_component(
		&ButtonTextConfig {
			text: text
			textcfg: TextConfig{
				color: gx.rgb(0xAA, 0xAA, 0xAA)
				size: 20
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
			scale := win.get_app_scale()

			// Parent is guaranteed to be a button so get the properties so we know where to draw the text
			mut rect := (&vstorm.NodeR2D(node.parent.get_component('rect'))).get_relative_to(w_size)
			pad := (&vstorm.NodeV2D(node.parent.get_component('padding'))).get_relative_to(w_size)
			rect.pos += pad
			rect.siz -= pad + pad
			mid := (rect.pos + rect.siz.divide_by(2)).multiply_by_float(scale)

			// Get text config and size
			t := &ButtonTextConfig(node.get_component('text'))
			
			// ggc.draw_text() is broken on android for no reason
			// Took this from the app implementation
			// TODO: make something about this
			ggc.set_cfg(
				gx.TextCfg {
					color: t.textcfg.color
					size: int(t.textcfg.size * scale)
					italic: t.textcfg.italic
					align:          t.textcfg.align
					vertical_align: t.textcfg.vertical_align
				}
			)
			ggc.ft.fons.draw_text(mid.x, mid.y, t.text)
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
	mut b_size := &vstorm.NodeV2D{
		x: 54.0 / 270
		y: 54.0 / 480
	}
	butt.add_component(
		&vstorm.NodeR2D {
			pos: vstorm.NodeV2D {
				x: 0	   			+ b_size.x * cfg.xindex
				y: (250.0 / 960)  	+ b_size.y * cfg.yindex
				r: true
			}
			siz: vstorm.NodeV2D {
				x: b_size.x * cfg.size.x
				y: b_size.y * cfg.size.y
				r: true
			}
		},
		'rect'
	)
	butt.add_component(
		&vstorm.NodeV2D {
			x: 2.0
			y: 2.0
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
			mut window := node.context.win
			mut ggc := window.gg
			w_size := window.get_size()

			// Convert the properties to be relative to the window
			mut rect := (&vstorm.NodeR2D(node.get_component('rect'))).get_relative_to(w_size)
			pad := (&vstorm.NodeV2D(node.get_component('padding'))).get_relative_to(w_size)
			rect.pos += pad
			rect.siz -= pad.multiply_by(2)
			
			anim_state := &ButtonAnimState(node.get_component('animation_state'))
			mut color := anim_state.normal_color
			if anim_state.mouse_over {
				color = anim_state.over_color
			}
			ggc.draw_rounded_rect_filled(
				rect.pos.x, rect.pos.y,
				rect.siz.x, rect.siz.y,
				0.1 * math.min(rect.siz.x, rect.siz.y),
				color
			)
		},
		'draw'
	)
	butt.add_function(
		fn(mut node &vstorm.Node) {
			// Get window pointer
			mut window := node.context.win
			mut e := window.latest_event

			// Event handling
			match e.typ {
				.touches_began,
				.touches_moved,
				.touches_ended,
				.mouse_enter,
				.mouse_leave,
				.mouse_move,
				.mouse_down,
				.mouse_up {
					// Get mouse position
					mut mouse_pos := window.get_mouse_pos()

					// Convert the properties to be relative to the window
					w_size := window.get_size()
					scale := window.get_app_scale()
					mut rect := (&vstorm.NodeR2D(node.get_component('rect'))).get_relative_to(w_size)
					pad := (&vstorm.NodeV2D(node.get_component('padding'))).get_relative_to(w_size)
					rect.pos += pad
					rect.siz -= pad.multiply_by(2)
					
					// If inside change the state
					mut anim_state := &ButtonAnimState(node.get_component('animation_state'))
					mut touch_pos := vstorm.NodeV2D{}
					anim_state.mouse_over = rect.check_inside(mouse_pos)

					for i := 0; i < e.num_touches; i++ {
						touch_pos.x = e.touches[i].pos_x / scale
						touch_pos.y = e.touches[i].pos_y / scale
						anim_state.mouse_over = (anim_state.mouse_over || rect.check_inside(touch_pos))
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