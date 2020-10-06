#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use XML::CompareML::HTML    ();
use XML::CompareML::DocBook ();
use IO::Scalar              ();
use Test::Differences qw/ eq_or_diff /;

{
    my $buffer    = "";
    my $file      = IO::Scalar->new( \$buffer );
    my $converter = XML::CompareML::HTML->new(
        'input_filename' => "t/files/scm-comparison.xml",
        'output_handle'  => $file,
        'data_dir'       => "./extradata",
    );

    $converter->process();

    # TEST
    ok( length($buffer) > 0, "\$buffer was filled in" );
}

{
    my $buffer    = "";
    my $file      = IO::Scalar->new( \$buffer );
    my $converter = XML::CompareML::DocBook->new(
        'input_filename' => "t/files/scm-comparison.xml",
        'output_handle'  => $file,
        'data_dir'       => "./extradata",
    );

    $converter->process();

    # TEST
    ok( length($buffer) > 0, "\$buffer was filled in" );
}

sub normalize_space
{
    my $text_ref = shift;

    ${$text_ref} =~ s{^[ \t]*}{}gms;

    return;
}

# Check for actual content.
{
    my $buffer    = "";
    my $file      = IO::Scalar->new( \$buffer );
    my $converter = XML::CompareML::HTML->new(
        'input_filename' => "examples/scm-comparison.xml",
        'output_handle'  => $file,
        'data_dir'       => "./extradata",
    );

    $converter->process();

    # Make it "if (1)" if you want to generate a good version.
    if (0)
    {
        open my $o, ">:encoding(UTF-8)", "examples/scm-comparison.output.html";
        print {$o} $buffer;
        close($o);
    }

    open my $good_html_fh, "<:encoding(UTF-8)",
        "examples/scm-comparison.output.html";
    my $good_content;
    {
        local $/;
        $good_content = <$good_html_fh>;
    }
    close($good_html_fh);

    normalize_space( \$buffer );
    normalize_space( \$good_content );

    # TEST
    eq_or_diff( $buffer, $good_content, "XSLT Works" );
}
