module main

import gx
import ghostnear.vstorm

fn app_init(mut app vstorm.AppContext) {
	// App background container
	mut bkg := create_background()
	app.root.add_child(mut bkg, 'background')

	// Default values
	default_txt_cfg := vstorm.TextConfig{
		size: 18
		color: gx.rgb(0xAA, 0xAA, 0xAA)
		align: gx.HorizontalAlign.center
		relative: true
		vertical_align: gx.VerticalAlign.middle
	}

	default_normal_color := gx.Color{
		r: 0x22
		g: 0x22
		b: 0x22
	}

	default_over_color := gx.Color{
		r: 0x33
		g: 0x33
		b: 0x33
	}

	default_button_size := vstorm.NodeV2D{
		x: 1
		y: 1
	}

	// Create the calculator buttons
	text := [
		['sin', 'cos', 'tan', 'π'],
		['+', '-', '*', '/'],
		['7', '8', '9', '(', ')'],
		['4', '5', '6', 'ln', 'e'],
		['1', '2', '3', '^'],
		['.', '', '', '√'],
	]
	mut i := 0
	for x in text {
		mut j := 0
		for y in x {
			if y != '' {
				mut command := Command{}
				if y[0] <= 57 && y[0] >= 48 {
					command.name = 'add_digit'
					command.args = y
				} else {
					match y {
						'sin', 'cos', 'tan' {
							command.name = 'add_trig'
						}
						'π', 'e' {
							command.name = 'add_constant'
						}
						'+', '-' {
							command.name = 'add_sign'
						}
						'/', '*', '^' {
							command.name = 'add_operation'
						}
						'.' {
							command.name = 'add_dot'
						}
						'ln' {
							command.name = 'add_log'
						}
						'√' {
							command.name = 'add_sqrt'
						}
						'(', ')' {
							command.name = 'add_paranthesis'
						}
						else {}
					}
					command.args = y
				}
				bkg.add_child(mut create_calculator_button(ButtonConfig{
					yindex: i
					xindex: j
					textcfg: default_txt_cfg
					normal_color: default_normal_color
					over_color: default_over_color
					command: command
					size: default_button_size
				}, y), 'calc_button_${i}_$j')
			}
			j++
		}
		i++
	}

	// Special buttons
	bkg.add_child(mut create_calculator_button(ButtonConfig{
		xindex: 4
		yindex: 4
		textcfg: default_txt_cfg
		normal_color: gx.Color{
			r: 0x22
			g: 0x44
			b: 0x44
		}
		over_color: gx.Color{
			r: 0x33
			g: 0x66
			b: 0x66
		}
		size: vstorm.NodeV2D{
			x: 1
			y: 2
		}
		command: Command{
			name: 'equals'
		}
	}, '='), 'calc_button_equals')
	bkg.add_child(mut create_calculator_button(ButtonConfig{
		xindex: 4
		yindex: 0
		textcfg: default_txt_cfg
		normal_color: gx.Color{
			r: 0x44
			g: 0x22
			b: 0x22
		}
		over_color: gx.Color{
			r: 0x66
			g: 0x33
			b: 0x33
		}
		size: default_button_size
		command: Command{
			name: 'remove'
		}
	}, '←'), 'calc_button_remove')
	bkg.add_child(mut create_calculator_button(ButtonConfig{
		xindex: 4
		yindex: 1
		textcfg: default_txt_cfg
		normal_color: gx.Color{
			r: 0x22
			g: 0x22
			b: 0x44
		}
		over_color: gx.Color{
			r: 0x33
			g: 0x33
			b: 0x66
		}
		size: default_button_size
		command: Command{
			name: 'special'
		}
	}, '!'), 'calc_button_special')
	bkg.add_child(mut create_calculator_button(ButtonConfig{
		xindex: 1
		yindex: 5
		textcfg: default_txt_cfg
		command: Command{
			name: 'add_digit'
			args: '0'
		}
		normal_color: default_normal_color
		over_color: default_over_color
		size: vstorm.NodeV2D{
			x: 2
			y: 1
		}
	}, '0'), 'calc_button_0_wide')
	bkg.add_child(mut create_calculator_display(), 'calc_display')
}

fn main() {
	// App data goes here
	mut app_config := vstorm.AppConfig{
		// Window specific configuration
		winconfig: vstorm.WindowConfig{
			title: 'Calculator'
			size: vstorm.NodeV2D{
				x: 270
				y: 480
			}
			ui_mode: true
			init_fn: app_init
		}
	}

	// App runner
	mut app := vstorm.new_storm_context(app_config)
	app.run()
}
