module main

import gx
import ghostnear.vstorm

fn app_init(mut app vstorm.AppContext) {
	// App background container
	mut bkg := create_background()
	app.root.add_child(mut bkg, 'background')

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
				bkg.add_child(mut create_calculator_button(ButtonConfig{
					yindex: i
					xindex: j
					text: y
					normal_color: gx.Color{
						r: 0x22
						g: 0x22
						b: 0x22
					}
					over_color: gx.Color{
						r: 0x33
						g: 0x33
						b: 0x33
					}
					size: vstorm.NodeV2D{
						x: 1
						y: 1
					}
				}), 'calc_button_${i}_$j')
			}
			j++
		}
		i++
	}

	// Special buttons ofc
	bkg.add_child(mut create_calculator_button(ButtonConfig{
		xindex: 4
		yindex: 4
		text: '='
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
	}), 'calc_button_equals')
	bkg.add_child(mut create_calculator_button(ButtonConfig{
		xindex: 4
		yindex: 0
		text: '←'
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
		size: vstorm.NodeV2D{
			x: 1
			y: 1
		}
	}), 'calc_button_remove')
	bkg.add_child(mut create_calculator_button(ButtonConfig{
		xindex: 4
		yindex: 1
		text: '!'
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
		size: vstorm.NodeV2D{
			x: 1
			y: 1
		}
	}), 'calc_button_special')
	bkg.add_child(mut create_calculator_button(ButtonConfig{
		xindex: 1
		yindex: 5
		text: '0'
		normal_color: gx.Color{
			r: 0x22
			g: 0x22
			b: 0x22
		}
		over_color: gx.Color{
			r: 0x33
			g: 0x33
			b: 0x33
		}
		size: vstorm.NodeV2D{
			x: 2
			y: 1
		}
	}), 'calc_button_0_wide')
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
			init_fn: app_init
		}
	}

	// App runner
	mut app := vstorm.new_storm_context(app_config)
	app.run()
}
