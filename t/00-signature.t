#   $Id: 00-signature.t 69 2008-06-29 15:00:08Z adam $

use Test::More;

BEGIN {

    if ( $ENV{SKIP_SIGNATURE_TEST} ) {
        plan( skip_all => 'Signature test skipped. Unset $ENV{SKIP_SIGNATURE_TEST} to activate test.' );
    }

    eval ' use Test::Signature; ';

    if ( $@ ) {
        plan( skip_all => 'Test::Signature not installed.' );
    }
    else {
        plan( tests => 1 );
    }
}
signature_ok();

