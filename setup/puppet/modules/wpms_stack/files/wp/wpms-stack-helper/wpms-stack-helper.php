<?php
/**
 * Plugin Name: WPMS Stack Helper
 * Plugin URI: https://github.com/Link7/wpms-stack
 * Description: This plugin interacts with the wpms-stack
 * Version: 0.1
 * Author: Link7
 * Author URI: https://github.com/Link7
 * License: GPL3
 */
 

/* Warning:
 * This file is managed by puppet, changes that are not made in the source file will be overwritten when puppet apply runs.
 * The source file can be found in /var/wpms-stack/setup/puppet/modules/wpms-wp/files/wpms-stack-helper/wpms-stack-helper.php
 * 
 */

add_action( 'network_admin_menu', 'plugin_menu_wpms_stack' );
 
function plugin_menu_wpms_stack() {
	add_menu_page( 'WPMS Stack Helper', 'WPMS Stack', 'manage_network', 'wpms-stack-helper', 'plugin_options_wpms_stack','dashicons-cloud' );
}
 

function update_setting_in_file($setting,$value) {
	$new_config_array = array();

	$instructions_file = ABSPATH.'../../internal/wpms-stack-plugin-instructions-for-puppet';
	$current_config_array = read_instructions_file_into_array($instructions_file);
	$new_config_array = $current_config_array;
	$new_config_array[$setting] = $value;
	write_array_into_instructions_file($instructions_file,$new_config_array);
}

function read_instructions_file_into_array($file='default') {
	if($file=='default') {
		$file = ABSPATH.'../../internal/wpms-stack-plugin-instructions-for-puppet';
	}
	$instructions_array = array();
	$instructions_file_lines = file($file);
	foreach($instructions_file_lines as $line) {
		if(strpos($line,': ') !== false) {		
			$keyvalue = explode(': ',$line);
			$instructions_array[trim($keyvalue[0])] = trim($keyvalue[1]);
		}
	}
	return $instructions_array;
}

function write_array_into_instructions_file($file,$array) {
	$file_contents = null;
	foreach($array as $key => $value) {
		$file_contents .= $key.': '.$value.PHP_EOL;
	}
	if (!file_put_contents($file,$file_contents)) {
		wp_die( __( 'file_put_contents failed.' ) );
	}
}


function plugin_options_wpms_stack() {
	if ( !current_user_can( 'manage_network' ) )  {
		wp_die( __( 'You do not have sufficient permissions to access this page.' ) );
	}

	$available_settings = array(
		'git-commit-now' => array(
			'name' => 'Commit to local git',
			'explanation' => 'A script on cron will execute <code>git add --all && git commit -m "wpms-stack cron autocommit"</code> within 1 minute and uncheck this box again. (This doesn\'t do anything on Vagrant)',
			'value' => 'No',
		),
		'example' => array(
			'name' => 'Example setting',
			'explanation' => 'This doesn\'t do anything, it\'s just an example.',
			'value' => 'Yes',
		),
	);
	
	$current_settings = read_instructions_file_into_array();
	
	#print_r($current_settings);

	foreach($available_settings as $key => $array) {
		if(isset($current_settings[$key])) {
			$available_settings[$key]['value'] = $current_settings[$key];
		}
	}

	#print_r($available_settings);

	echo '<div class="wrap">';

	echo '<h2>WPMS Stack Helper Plugin</h2>';
	
	if ( $_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['update']) ){
		
		#print_r($_POST);

		foreach($available_settings as $key => $array) {
			if(isset($_POST[$key])) {
				#echo "1 updating ".$available_settings[$key]['name']." to 'Yes'";
				$available_settings[$key]['value'] = 'Yes';
			} else {
				#echo "2 updating ".$available_settings[$key]['name']." to 'No'";
				$available_settings[$key]['value'] = 'No';
			}
		}

		#print_r($available_settings);

		foreach($available_settings as $key => $array) {
			update_setting_in_file($key,$array['value']);
		}
		echo '<div id="message" class="updated"><p>Settings updated</p></div>';
	}

	

?>
 <form name="options" method="POST" action="<?php echo $_SERVER['REQUEST_URI']; ?>">
	<table class="form-table">
		<tbody>
<?php foreach($available_settings as $key => $array) { ?>
			<tr>
				<th scope="row"><?php echo $array['name']; ?></th>
				<td>
					<label><input name="<?php echo $key; ?>" type="checkbox" id="<?php echo $key; ?>" value="<?php echo $array['value']; ?>"<?php if($array['value'] == 'Yes') { echo ' checked="checked"'; } ?>> <?php echo $array['explanation']; ?></label>
				</td>
			</tr>
<?php }

	
	?>
		</tbody>
	</table>

	<?php submit_button('Save Changes', 'primary', 'update'); ?>
 </form>

 <?php
echo '</div>'; //end wrap
}
