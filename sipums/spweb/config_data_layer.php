<?
/*
 * $Id: config_data_layer.php,v 1.5 2004/08/17 19:33:56 kenglish Exp $
 */

		$config->data_container_type="sql";		//Type of data container 'sql' or 'ldap'

		////////////////////////////////////////////////////////////////
		//            configure database

		/* these are the defaults with which SER installs; if you changed
		   the SER account for SQL database, you need to update here 
		*/

		$config->data_sql=new stdClass();
		
		$config->data_sql->db_type="mysql";			//type of db host, enter "mysql" for MySQL or "pgsql" for PostgreSQL
		$config->data_sql->db_host="localhost";		//database host
		$config->data_sql->db_port="";				//database port - leave empty for default
		$config->data_sql->db_name="ser";			//database name
		$config->data_sql->db_name_conference="conference";			//database name
		$config->data_sql->db_user="ser";			//database conection user
		$config->data_sql->db_pass="olseh";			//database conection password


		/* Unless you used brute-force to change SER table names */
		$config->data_sql->table_subscriber="subscriber";
		$config->data_sql->table_pending="pending";
		$config->data_sql->table_grp="grp";
		$config->data_sql->table_aliases="aliases";
		$config->data_sql->table_location="location";
		$config->data_sql->table_missed_calls="missed_calls";
		$config->data_sql->table_accounting="misc_acc";
		$config->data_sql->table_phonebook="phonebook";
		$config->data_sql->table_event="event";
		$config->data_sql->table_netgeo_cache="netgeo_cache";
		$config->data_sql->table_ser_mon="server_monitoring";
		$config->data_sql->table_ser_mon_agg="server_monitoring_agg";
		$config->data_sql->table_message_silo="silo";
		$config->data_sql->table_voice_silo="voice_silo";
		$config->data_sql->table_user_preferences="usr_preferences";
		$config->data_sql->table_user_preferences_types="usr_preferences_types";
		$config->data_sql->table_providers="providers";
		$config->data_sql->table_admin_privileges="admin_privileges";
		$config->data_sql->table_speed_dial="speed_dial";
		$config->data_sql->table_calls_forwarding="calls_forwarding";
 
?>
