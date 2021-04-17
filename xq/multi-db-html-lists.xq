import module namespace jats = 'http://jats.nlm.nih.gov' at "jats-analysis.xqm";

declare variable $collection external := 'comm-use';
declare variable $cutoff as xs:decimal external := 0.01;
declare variable $class as xs:string external := 'STEM';
declare variable $dir as xs:anyURI := resolve-uri("../multi-db-html-lists/", static-base-uri());

(file:create-dir($dir),
 for $dbname in db:list()[starts-with(., 'PMC__')]
 let $list := jats:db-html-list($dbname, $cutoff, $class)
 return file:write($dir || $dbname || '.xhtml', $list, map{'omit-xml-declaration': false()})
)