use Module::Build;
my $build = new Module::Build
	(
		module_name	=> 'DateTime::Calendar::Mayan',
		dist_version_from => 'lib/DateTime/Calendar/Mayan.pm',
		author		=> 'Joshua Hoblitt <jhoblitt@cpan.org>',
		license		=> 'perl',
		requires	=> {
			DateTime		=> '0.08',
			Params::Validate	=> '0.52',
		},
	);
$build->create_build_script;
