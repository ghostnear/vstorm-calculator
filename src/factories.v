module main

import gx
import math
import ghostnear.vstorm

// Background factory
fn create_background() &vstorm.Node {
	mut node := &vstorm.Node{}
	node.add_component(&gx.Color{
		r: 0x11
		g: 0x11
		b: 0x11
	}, 'color')
	node.add_function(fn (mut node vstorm.Node) {
		mut window := node.context.win
		mut ggc := window.gg
		w_size := window.get_size()
		ggc.draw_rect_filled(0, 0, w_size.x, w_size.y, &gx.Color(node.get_component('color')))
	}, 'draw')
	return node
}

// Config for the factory
struct ButtonConfig {
	xindex       int
	yindex       int
	textcfg      vstorm.TextConfig
	size         vstorm.NodeV2D
	command      Command
	normal_color gx.Color
	over_color   gx.Color
}

struct ButtonAnimState {
mut:
	mouse_over   bool
	normal_color gx.Color
	over_color   gx.Color
}

// Button factory
fn create_calculator_button(cfg ButtonConfig, text string) &vstorm.Node {
	mut butt := &vstorm.Node{}
	mut b_size := &vstorm.NodeV2D{
		x: 54.0 / 270
		y: 54.0 / 480
	}
	butt.add_component(&vstorm.NodeR2D{
		pos: vstorm.NodeV2D{
			x: 0 + b_size.x * cfg.xindex
			y: (250.0 / 960) + b_size.y * cfg.yindex
			r: true
		}
		siz: vstorm.NodeV2D{
			x: b_size.x * cfg.size.x
			y: b_size.y * cfg.size.y
			r: true
		}
	}, 'rect')
	butt.add_component(&vstorm.NodeV2D{
		x: 2.0
		y: 2.0
	}, 'padding')
	butt.add_component(&Command{
		name: cfg.command.name
		args: cfg.command.args
	}, 'command')
	butt.add_component(&ButtonAnimState{
		normal_color: cfg.normal_color
		over_color: cfg.over_color
	}, 'animation_state')
	butt.add_function(fn (mut node vstorm.Node) {
		mut window := node.context.win
		mut ggc := window.gg
		w_size := window.get_size()

		// Convert the properties to be relative to the window
		mut rect := (&vstorm.NodeR2D(node.get_component('rect'))).get_relative_to(w_size)
		pad := (&vstorm.NodeV2D(node.get_component('padding'))).get_relative_to(w_size)
		rect.pos += pad
		rect.siz -= pad.multiply_by(2)

		// Update text
		if node.has_child('text') {
			mut text := node.get_child('text')
			mut text_pos := &vstorm.NodeV2D(text.get_component('position'))
			result := rect.pos + rect.siz.divide_by(2)
			text_pos.x = result.x
			text_pos.y = result.y
			text_pos.r = false
		}

		// Update color depending on the mouse over state
		anim_state := &ButtonAnimState(node.get_component('animation_state'))
		mut color := anim_state.normal_color
		if anim_state.mouse_over {
			color = anim_state.over_color
		}
		ggc.draw_rounded_rect_filled(rect.pos.x, rect.pos.y, rect.siz.x, rect.siz.y, 0.1 * math.min(rect.siz.x,
			rect.siz.y), color)
	}, 'draw')
	butt.add_function(fn (mut node vstorm.Node) {
		// Get window pointer
		mut window := node.context.win
		mut e := window.latest_event
		mut anim_state := &ButtonAnimState(node.get_component('animation_state'))

		get_rect := fn (node &vstorm.Node) vstorm.NodeR2D {
			w_size := node.context.win.get_size()
			mut rect := (&vstorm.NodeR2D(node.get_component('rect'))).get_relative_to(w_size)
			pad := (&vstorm.NodeV2D(node.get_component('padding'))).get_relative_to(w_size)
			rect.pos += pad
			rect.siz -= pad.multiply_by(2)
			return rect
		}
		rect := get_rect(node)

		// Event handling
		match e.typ {
			// On mouse press
			.mouse_down {
				// Get event data
				mut mouse_pos := window.get_mouse_pos()

				// Deactivate to make the button 'click'
				anim_state.mouse_over = false

				// If inside, fire up the on click event
				if rect.check_inside(mouse_pos) {
					node.execute('on_click')
				}
			}
			// Reset the animation because we are out of the app
			.mouse_enter, .mouse_leave {
				anim_state.mouse_over = false
			}
			// Mobile only click
			.touches_ended {
				// Care about this only if the button is being held down
				if anim_state.mouse_over {
					// Get event data
					touches := window.get_touches()

					// Check for overlaps in any of the touches
					anim_state.mouse_over = false
					for i := 0; i < touches.count; i++ {
						anim_state.mouse_over = (anim_state.mouse_over
							|| rect.check_inside(touches.list[i]))
					}

					// Finger was released
					if anim_state.mouse_over == false {
						node.execute('on_click')
					}
				}
			}
			// Mobile only highlight
			.touches_began, .touches_moved {
				// Get event data
				touches := window.get_touches()

				// Check for overlaps in any of the touches
				anim_state.mouse_over = false
				for i := 0; i < touches.count; i++ {
					anim_state.mouse_over = (anim_state.mouse_over
						|| rect.check_inside(touches.list[i]))
				}
			}
			// On mouse highlight
			.mouse_up, .mouse_move {
				// Get event data
				mut mouse_pos := window.get_mouse_pos()

				// Change animation state if required
				anim_state.mouse_over = rect.check_inside(mouse_pos)
			}
			else {}
		}
	}, 'event')
	butt.add_function(fn (mut node vstorm.Node) {
		// Get background
		mut bkg := node.context.root.get_child('background')

		// Get display
		if bkg.has_child('calc_display') {
			mut display := bkg.get_child('calc_display')
			comm := &Command(node.get_component('command'))
			mut latest := &Command(display.get_component('lastestcommand'))
			latest.name = comm.name
			latest.args = comm.args
			display.execute('exec')
		}
	}, 'on_click')
	butt.add_child(mut vstorm.new_text_node(cfg.textcfg, text), 'text')
	return butt
}

struct Command {
pub mut:
	name string
	args string
}

struct CommandList {
pub mut:
	list []Command
	text string
}

fn create_calculator_display() &vstorm.Node {
	mut node := &vstorm.Node{}
	node.add_component(&gx.Color{
		r: 0x22
		g: 0x22
		b: 0x22
	}, 'color')
	node.add_component(&vstorm.NodeV2D{
		x: (2.5 / 480)
		y: (5.0 / 960)
		r: true
	}, 'position')
	node.add_component(&vstorm.NodeV2D{
		x: (475.0 / 480)
		y: (240.0 / 960)
		r: true
	}, 'size')
	node.add_component(&CommandList{}, 'commands')
	node.add_component(&Command{}, 'lastestcommand')
	node.add_function(fn (mut node vstorm.Node) {
		mut window := node.context.win
		w_size := window.get_size()
		pos := (&vstorm.NodeV2D(node.get_component('position'))).get_relative_to(w_size)
		siz := (&vstorm.NodeV2D(node.get_component('size'))).get_relative_to(w_size)

		// Update the text position
		result_text := node.get_child('result_text')
		mut result_text_pos := &vstorm.NodeV2D(result_text.get_component('position'))
		result_text_pos.x = pos.x + siz.x - (5.0 / 480) * w_size.x
		result_text_pos.y = pos.y + siz.y
		result_text_pos.r = false
		last_text := node.get_child('last_text')
		mut last_text_pos := &vstorm.NodeV2D(last_text.get_component('position'))
		last_text_pos.x = pos.x + siz.x - (5.0 / 480) * w_size.x
		last_text_pos.y = (15.0 / 480) * w_size.y
		last_text_pos.r = false
	}, 'update')
	node.add_function(fn (mut node vstorm.Node) {
		mut window := node.context.win
		mut ggc := window.gg
		w_size := window.get_size()
		pos := (&vstorm.NodeV2D(node.get_component('position'))).get_relative_to(w_size)
		siz := (&vstorm.NodeV2D(node.get_component('size'))).get_relative_to(w_size)
		ggc.draw_rounded_rect_filled(
			pos.x, pos.y,
			siz.x, siz.y,
			0.1 * math.min(siz.x, siz.y),
			&gx.Color(node.get_component('color'))
		)
	}, 'draw')
	node.add_function(fn (mut node vstorm.Node) {
		mut latest := &Command(node.get_component('lastestcommand'))
		mut list := &CommandList(node.get_component('commands'))
		match latest.name {
			'add_digit' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'add_trig' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'add_constant' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'add_sign' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'add_operation' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'add_paranthesis' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'add_dot' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'add_log' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'add_sqrt' {
				// TODO: finish this
				list.text = list.text + latest.args
			}
			'equals' {
				// TODO: finish this
			}
			'remove' {
				// TODO: finish this
			}
			'special' {
				// TODO: finish this
			}
			else {
				return
			}
		}
	}, 'exec')
	// Texts from the textbox
	mut result_text := vstorm.new_text_node(vstorm.TextConfig{
		size: 80
		color: gx.rgb(0x33, 0x99, 0x99)
		align: gx.HorizontalAlign.right
		vertical_align: gx.VerticalAlign.bottom
		relative: true
	}, 'result')
	mut last_text := vstorm.new_text_node(vstorm.TextConfig{
		size: 50
		color: gx.rgb(0xAA, 0xAA, 0xAA)
		align: gx.HorizontalAlign.right
		vertical_align: gx.VerticalAlign.top
		relative: true
	}, 'before')
	node.add_child(mut result_text, 'result_text')
	node.add_child(mut last_text, 'last_text')
	return node
}
