package XML::CompareML::HTML;

use strict;
use warnings;
use CGI ();

use base 'XML::CompareML::Base';

sub print_header
{
    my $self = shift;

    my $style = $self->get_head_css_style();

    my $o = $self->{o};
    print {*{$o}} <<"EOF";
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<title>Version Control Systems Comparison</title>
$style
</head>
<body>
EOF
}

sub get_head_css_style
{
    my $self = shift;
    
    my $stylesheet_url = undef;
    my $style;
    
    if ($stylesheet_url)
    {
        $style = "<link rel=\"stylesheet\" href=\"$stylesheet_url\" />";
    }
    else
    {
        $style = <<'EOF';
<style type="text/css">
<!--
h2 { background-color : #98FB98; /* PaleGreen */ }
h3 { background-color : #FFA500; /* Orange */ }
table.compare 
{ 
    margin-left : 1em; 
    margin-right : 1em; 
    width: 90%;
    max-width : 40em;
}
.compare td 
{ 
    border-color : black; border-style : solid ; border-width : thin;
    vertical-align : top;
    padding : 0.2em;
}
ul.toc
{
    list-style-type : none ; padding-left : 0em;
}
.toc ul
{
    list-style-type : none ; 
    padding-left : 0em; 
    margin-left : 2em;
}
.expl
{
    border-style : solid ; border-width : thin;
    background-color : #E6E6FA; /* Lavender */
    border-color : black;
    padding : 0.3em;
}
a:hover { background-color : yellow }
tt { color : #8A2BE2 /* The BlueViolet Color */ }
-->
</style>
EOF
    }
    return $style;
}

sub start_rendering
{
    my $self = shift;
    $self->{toc_text} .= "<ul class=\"toc\">\n";
}

sub finish_rendering
{
    my $self = shift;
    
    my $toc_text = $self->{toc_text};
    $toc_text .= "</ul>\n";

    $self->{document_text} =~ s!<<<TOC>>>!$toc_text!;
}

sub print_footer
{
    my $self = shift;
    print {*{$self->{o}}} "\n</body>\n</html>\n";
}

sub render_section_start
{
    my $self = shift;
    my %args = (@_);

    my $depth = $args{depth};
    my $id = $args{id};
    my $title_string = $args{title_string};
    my $expl = $args{expl};
    my $sub_sections = $args{sub_sections};

    my $d = $depth+1;
    $self->out("<h$d id=\"$id\">$title_string</h$d>\n");

    if ($expl)
    {
        $self->out("<p class=\"expl\">\n" . $self->xml_node_contents_to_string($expl) . "\n</p>\n");
    }

    if ($depth == 0)
    {
        if (defined($self->timestamp()))
        {
            $self->out("<p><b>Timestamp:</b> <tt>" . $self->timestamp() . "</tt></p>");
        }
        $self->out("<<<TOC>>>\n");
    }

    $self->toc_out("<li><a href=\"#$id\">$title_string</a>");

    if (@$sub_sections)
    {
        $self->toc_out("\n<ul>\n");
    }
}

sub render_sys_table_start
{
    my $self = shift;
    $self->out("<table class=\"compare\">\n");
}

sub render_s_elem
{
    my ($self, $s_elem) = @_;
    return $self->xml_node_contents_to_string($s_elem);
}

sub render_sys_table_row
{
    my ($self, %args) = @_;
    
    $self->out(
        "<tr>\n<td class=\"sys\">" . $args{name} . "</td>\n" .
        "<td class=\"desc\">\n" . $args{desc} . "\n</td>\n</tr>\n"
    );
}

sub render_sys_table_end
{
    my $self = shift;
    $self->out("</table>\n");
}

sub render_section_end
{
    my ($self, %args) = @_;

    my $sub_sections = $args{sub_sections};
    
    if (@$sub_sections)
    {
        $self->toc_out("\n</ul>\n");
    }
    $self->toc_out("</li>\n");
}

sub gen_systems_list
{
    my ($self, %args) = @_;

    my $fh = $args{output_handle};

    my @implementations = $self->findnodes("/comparison/meta/implementations/impl");

    foreach my $impl (@implementations)
    {
        my $name = $self->_impl_get_tag_text($impl, "name");
        my $url = $self->_impl_get_tag_text($impl, "url");
        my $fullname = $self->_impl_get_tag_text($impl, "fullname");
        if (!defined($url))
        {
            die "URL not specified for implementation " . $self->_impl_get_name($_);
        }
        print {$fh} qq{<li><a href="} . CGI::escapeHTML($url) . qq{">} . 
            CGI::escapeHTML(defined($fullname) ? $fullname : $name) . qq{</a></li>\n};
    }
}
1;
