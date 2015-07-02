#!/usr/bin/env perl

#########################################################
# A simple recursive example for converting R dendrograms
# into Perl Tree::DAG_Node objects.
# Might be helpfull to process results of hierarchical 
# clustering with perl.
# I could also have used a list of lists representation
# but Tree::DAG_Node has so many nice features.
########################################################
use strict;
use warnings;
use R;
use RReferences;
use Tree::DAG_Node;

#####
# Check, if this is a dendrogram
####
sub matchDendrogram {
    my $obj = shift;
    my $ok = R::call("inherits", $obj, "dendrogram");
    my $type = R::call("typeof", $obj);
    # print "Typeof r object ", $type, "\n";
    return($ok);
}

#####
# The actual converter.
# This function converts a given dendrogram recursively
# into Tree::DAG_Node objects.
#####

sub convertDendrogram {
    my $obj = shift;
    my $type = R::call("typeof", $obj);
# a new node to represent the dendrogram node
    my $node = Tree::DAG_Node->new();
 
# get dendrogram node attributes and add them to the perl node  
    my $height = R::call('attr',$obj,'height');
    my $leaf = R::call('attr', $obj, 'leaf');
    my $label = R::call('attr', $obj, 'label');
    my $members = R::call('attr', $obj, 'members');
    $node->name(($label || '*')); # one could think of something better than '*'*
    $node->attributes({height=>$height, members=>$members, label=>$label, leaf=>$leaf});
	
#### check if this node is a leaf
#### then just return the leaf node
    if ($leaf) {
	return $node;
    } else {
#### otherwise: get the left and right sub-branches
#### and add them to the actual node
#### convertDendrogram will be called recursively as each sub-node is
#### also a dendrogram
 	my $new_daughter_left = R::call('getLeftNode', $obj);
	my $new_daughter_right = R::call('getRightNode', $obj);
	$node->add_daughters($new_daughter_left, $new_daughter_right);
	return $node;
    }

}

R::setConverter(\&matchDendrogram, \&convertDendrogram, "A simple Perl routine for converting an R dendrogram into a Tree::DAG_Node object", 1);
R::setDebug(0);
R::initR("--slave");
R::library("RSPerl");

#### These R functions provide access to the sub-branches of the
#### dendrogram. I think i have to do it this way, as one cannot call
#### '[[]]' (list indexing) as a function via R::call.  
R::eval("getLeftNode <<- function(dend) { return(dend[[1]]) }");
R::eval("getRightNode <<- function(dend) { return(dend[[2]]) }");

#### provide some sample dendro. Print dendro via str to compare with 
#### ascii output of Tree::DAG_Node
R::eval('makeDend <<- function(){ mat <- matrix(rnorm(3*10),ncol=3); rownames(mat)<- paste("ROW",1:10,sep="_"); hc <- hclust(dist(mat), "ave"); (dend1 <- as.dendrogram(hc)); print(str(dend1)); return(dend1)}');

sub foo {
    my $tree = R::call('makeDend');
    my $lines = $tree->draw_ascii_tree(); # real nice feature for small trees
    print map("$_\n", @$lines);
}

foo();

__END__
