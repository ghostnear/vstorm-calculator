module main

import gx
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
			mut ggc := &node.context.win.gg
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

// Button factory
pub fn create_calculator_button() &vstorm.Node {
	mut butt := &vstorm.Node{}
	butt.add_component(
		&vstorm.NodeV2D {
			x: 0
			y: 0.5
			r: true
		},
		'position'
	)
	butt.add_component(
		&vstorm.NodeV2D {
			x: 0.25
			y: 0.25
			r: true
		},
		'size'		
	)
	butt.add_function(
		fn(mut node &vstorm.Node) {
			mut ggc := &node.context.win.gg
			w_size := node.context.win.get_size()

			// Convert the position relative to the window
			poz := (&vstorm.NodeV2D(node.get_component('position'))).get_relative_to(w_size)

			// Convert the size relative to the window
			siz := (&vstorm.NodeV2D(node.get_component('size'))).get_relative_to(w_size)
			ggc.draw_rounded_rect_filled(
				poz.x, poz.y,
				siz.x, siz.y,
				0.1 * siz.y,
				gx.Color{
					r: 0x22
					g: 0x22
					b: 0x22
				}
			)
		},
		'draw'
	)
	return butt
}