# Split HMDB All Metabolites XML
#### Mr. George L. Malone
#### 24<sup>th</sup> of March, 2021


### Overview

This repository documents the scripts and requirements for splitting and
storing the [HMDB _All Metabolites_][1] XML.  The operations are completed
using the Ruby programming language.  The operations rely on certain harcoded
data, such as the initial XML declaration and the document opening and closing
tags, including namespace declaration.  Due to the size of the XML document
containing all metabolite data, Ruby was used to take advantage of the ease of
use of the `File.foreach` method, in order to maximise speed and minimise RAM
usage.  The file was too large for Nokogiri to handle -- approx. 4.1GB.


### Operations

After initial setup and variable declarations, the file is opened and the rows
are iterated over.  If the row is the doctype declaration or the `hmdb` opening
or closing tag, it is skipped.  The row text is then pushed to the output
object.  If the ID of the current metabolite is `nil`, the current row text is
checked for the ID inside the primary `accession` tag, and assigned if
found<sup>[n1]</sup>.  If the row is the `metabolite` closing tag, the current
data are written out using the current ID.  If the current ID count is `nil`,
the `nil`-ID count is used with the `IDNA_` prefix, and the `nil`-ID count is
incremented.  The output data hash is then reset, which makes me a bit
concerned about scoping, but it appears to be working properly.


[n1]\:  I realise it's not generally a good idea to parse XML using regex, but
this is a line-by-line/within-text operation, rather than a global
parse/search.


[1]: https://hmdb.ca/downloads
