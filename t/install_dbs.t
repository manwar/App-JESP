#! perl -w

use Test::Most;

BEGIN{
    eval "use Test::mysqld";
    plan skip_all => "Test::mysqld is required for this test" if $@;
}

use App::JESP;
use File::Spec;

# use Log::Any::Adapter qw/Stderr/;

# First something with SQLite.
my @connection_params = ({ dsn => 'dbi::SQLite:dbname=:memory:',
                           username => undef,
                           password => undef
                       });

# Then something with MySQL
my $mysql = Test::mysqld->new( my_cnf => {
    'skip-networking' => '1',
    socket => File::Spec->catfile( File::Spec->tmpdir() , 'socket-'.$$.'-testmysqld')
});

push @connection_params, { dsn => $mysql->dsn(),
                           password => '',
                           username => ''
                       };

foreach my $connect_params ( @connection_params ){
    diag("Testing ".$connect_params->{dsn} );

    ok( my $jesp = App::JESP->new({ dsn => 'dbi:SQLite:dbname=:memory:', username => undef, password => undef }) );
    ok( $jesp->install(), "Ok can install JESP in the given Database");
    my @installed_patches  = $jesp->dbix_simple()->select( $jesp->patches_table_name() )->hashes();

    is( scalar( @installed_patches ) , 1 );
    is( $installed_patches[0]->{id} , $jesp->prefix().'meta_zero' , "Good zero name" );
    ok( exists( $installed_patches[0]->{applied_datetime} ) , "There is an applied time" );
}
done_testing();