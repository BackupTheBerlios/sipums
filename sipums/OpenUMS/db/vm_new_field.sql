ALTER TABLE sound_files ADD custom_sound_flag TINYINT( 1 ) DEFAULT '1' NOT NULL ;
update sound_files set custom_sound_flag = !(professional);
