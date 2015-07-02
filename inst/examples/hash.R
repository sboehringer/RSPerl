.PerlFile("")
tbl = .Perl("hash_and_count_words", 0, "this and that", "and others", convert=FALSE, array=FALSE)
.Perl("hash_and_count_words", tbl, "and more")
