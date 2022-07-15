module main

import vstorm

fn app_init(mut app &vstorm.StormContext) {
	// App background container
	mut bkg := create_background()
	app.root.add_child(mut bkg, 'background')

	// Test a button
	mut b_test := create_calculator_button()
	bkg.add_child(mut b_test, 'test_button')
}

fn main() {
	// App data goes here
	app_config := vstorm.StormConfig{
		// Window specific configuration
		winconfig: vstorm.StormWindowConfig{
			title: 'Calculator'
			width: 270
			height: 480
			init_fn: app_init
		}
	}

	// App runner
	mut app := vstorm.new_storm_context(app_config)
	app.run()
}