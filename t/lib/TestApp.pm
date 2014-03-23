package t::lib::TestApp;
use Dancer;
set session => 'simple';

use Dancer::Plugin::Paginate;

our $VERSION = '0.1';

get '/' => paginate sub {
    return 'Index ok';
};

get '/page' => paginate sub {
    my $range = var 'range';
    my $unit = var 'range_unit';
    content_type 'application/json';
    return to_json({start => ${$range}[0], end => ${$range}[1], unit => $unit });
};

get '/total' => paginate sub {
    var total => '100';
    content_type 'application/json';
    return to_json({total => '100'});
};

get '/range' => paginate sub {
    var return_range => [0,100];
    content_type 'application/json';
    return to_json({start => 0, end => 100});
};

true;
