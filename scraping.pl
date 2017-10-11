#!/usr/bin/perl
# Sina AHMADI
# Web scraper

use WWW::Mechanize;
use HTML::Parser;
use HTML::Tree;
use HTML::LinkExtractor;
use LWP::Simple;
use strict;
#use warnings;
 
sub println(@)
{
    print map{"$_\n"} @_;
}

# println("\t******* ASPIRATEUR DE WEB *****************");
# println("\tThis module is a part of Sina Ahmadi's internship in LIMSI-CNRS for Soyooz Inc.");
# println("\tAll rights reserved for the developper. ");
# println("\tSina Ahmadi - June 2016 - Paris. ");
# println("\tahmadi.sina\@outlook.com");
# println("\t*******************************************");
println("\t-------------------------------------------");

die "Error: Argument needed (1- key word$! $!\n" unless defined $ARGV[0];
die "Error: Argument needed (2- Number of pages $!\n" unless defined $ARGV[1];
die "Error: Argument needed (3- Category|question_number|response $!\n" unless defined $ARGV[2];

my @link_array = ();

my $base_path = "corpus/raw/links/$ARGV[2].txt";
if(-e $base_path){
	system("rm ".$base_path);
}
open(my $FH, '>>', $base_path);

my $bot = WWW::Mechanize->new();
$bot->agent_alias ('Linux Mozilla');
my $search_key = $ARGV[0]; 
my $search_url = "http://www.google.com/search?q=".$search_key;

$bot -> get($search_url);
my $page = 1;
do{
	my $tree = HTML::Tree->new();
	$tree->parse($bot->content);
	my @link = $tree->look_down('_tag','h3');
	if(!@link){
	    println("\tOppsss.. No result!");
	    exit 1;
	}
	print("\tLinks from Page $page:");
	for my $url(@link){
		my $lien = $url->as_HTML();
		my $LX = new HTML::LinkExtractor;
		$LX->parse(\$lien);
		for my $Link(@{$LX->links}){
			# print("$$Link{_TEXT} URL   "); 
			$$Link{href} =~ s/^\/url\?q=//;
			$$Link{href} =~ s/&sa=U.*$//;
	    	# println("\n\t$$Link{href}");
			push(@link_array, $$Link{href});
	    	print $FH $$Link{href}."\n";
    	}
	}
	$page++;
	$bot->follow_link(text=>$page);
	println("             Saved!");
	println("\t-------------------------------------------");
	print $FH "----------------------\n";
	sleep 10;
}while($page < ($ARGV[1]+1));
close($FH);
# # ------ Documentation 
# AGENT_ALIASES = {
#   'Windows IE 6' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
#   'Windows IE 7' => 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
#   'Windows Mozilla' => 'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.4b) Gecko/20030516 Mozilla Firebird/0.6',
#   'Mac Safari' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; de-at) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10',
#   'Mac FireFox' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6',
#   'Mac Mozilla' => 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.4a) Gecko/20030401',
#   'Linux Mozilla' => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
#   'Linux Firefox' => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.1) Gecko/20100122 firefox/3.6.1',
#   'Linux Konqueror' => 'Mozilla/5.0 (compatible; Konqueror/3; Linux)',
#   'iPhone' => 'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3',
#   'Mechanize' => "WWW-Mechanize/#{VERSION} (http://rubyforge.org/projects/mechanize/)"
# 
# ---------------------
# println("\t*******************************************");
# # print("\tWant to download the content of each link? (Y/N) ");
# println("\tDonwloading the links");
# my $to_continue = "Y";#<STDIN>;
# chomp $to_continue;
# chomp $ARGV[2];
# my $corpus_path = "corpus/raw/$ARGV[2].txt";

# if($to_continue eq "Y"){
# 	if(-e $corpus_path){
# 		system("rm ".$corpus_path);
# 	}
# 	open(my $FH_corpus, '>>', $corpus_path);
# 	foreach my $link(<@link_array>){
# 		# validity of the links
# 		my $html = get $link;
# 		if(length($html)!=0){
# 			#die "Couldn't get it!" unless defined $html;
# 			HTML::Parser->new(text_h => [\my @accum, "text"])->parse($html);
# 			my @content = (map $_->[0], @accum);
# 			print $FH_corpus "$_\n" for @content;
# 		}
# 	}
# }
# else{
# 	exit 1;
# }
# close($corpus_path);
# ---------------------
# Regex to eliminate multiple newlines (by one) and multiple spaces (by one).
# $_ =~ s/[\n]+/\n/;