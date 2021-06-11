package App::arraydata;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use List::Util qw(shuffle);

our %SPEC;

our %argspecopt_module = (
    module => {
        schema => 'perl::arraydata::modname_with_optional_args*',
        cmdline_aliases => {m=>{}},
        pos => 0,
    },
);

#our %argspecopt_modules = (
#    modules => {
#        schema => 'perl::arraydata::modnames_with_optional_args*',
#    },
#);

sub _list_installed {
    require Module::List::More;
    my $mods = Module::List::More::list_modules(
        "ArrayData::",
        {
            list_modules  => 1,
            list_pod      => 0,
            recurse       => 1,
            return_path   => 1,
        });
    my @res;
    for my $mod0 (sort keys %$mods) {
        (my $mod = $mod0) =~ s/\AArrayData:://;

        push @res, {
            name => $mod,
            path => $mods->{$mod0}{module_path},
        };
     }
    \@res;
}

$SPEC{arraydata} = {
    v => 1.1,
    summary => 'Show content of ArrayData modules (plus a few other things)',
    args => {
        %argspecopt_module,
        action => {
            schema  => ['str*', in=>[
                'list_installed',
                #'list_cpan',
                'dump',
                'pick',
                #'stat',
            ]],
            default => 'dump',
            cmdline_aliases => {
                L => {
                    summary=>'List installed ArrayData::*',
                    is_flag => 1,
                    code => sub { my $args=shift; $args->{action} = 'list_installed' },
                },
                #C => {
                #    summary=>'List ArrayData::* on CPAN',
                #    is_flag => 1,
                #    code => sub { my $args=shift; $args->{action} = 'list_cpan' },
                #},
                R => {
                    summary=>'Pick random elements from an ArrayData module',
                    is_flag => 1,
                    code => sub { my $args=shift; $args->{action} = 'pick' },
                },
                #S => {
                #    summary=>'Show statistics contained in the ArrayData module',
                #    is_flag => 1,
                #    code => sub { my $args=shift; $args->{action} = 'stat' },
                #},
            },
        },
        detail => {
            schema => 'bool*',
            cmdline_aliases => {l=>{}},
        },
        num => {
            summary => 'Number of elements to pick (for -R)',
            schema => 'posint*',
            default => 1,
            cmdline_aliases => {n=>{}},
        },
        #lcpan => {
        #    schema => 'bool',
        #    summary => 'Use local CPAN mirror first when available (for -C)',
        #},
    },
    examples => [
    ],
    'cmdline.default_format' => 'text-simple',
};
sub arraydata {
    my %args = @_;
    my $action = $args{action} // 'dump';

    if ($action eq 'list_installed') {
        my @rows;
        for my $row (@{ _list_installed() }) {
            push @rows, $args{detail} ? $row : $row->{name};
        }
        return [200, "OK", \@rows];
    }

    return [400, "Please specify module"] unless defined $args{module};

    require Module::Load::Util;
    my $obj = Module::Load::Util::instantiate_class_with_optional_args(
        {ns_prefix=>"ArrayData"}, $args{module});

    if ($action eq 'pick') {
        return [200, "OK", [$obj->pick_items(n=>$args{num})]];
    }

    # dump
    my @items;
    while ($obj->has_next_item) { push @items, $obj->get_next_item }
    [200, "OK", \@items];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

See the included script L<arraydata>.


=head1 ENVIRONMENT


=head1 SEE ALSO

L<ArrayData> and C<ArrayData::*> modules.
