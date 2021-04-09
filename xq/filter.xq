import module namespace jats = 'http://jats.nlm.nih.gov' at "jats-analysis.xqm";

declare variable $collection external := 'comm-use';
declare variable $cutoff as xs:decimal external := 0.01;
declare variable $class as xs:string external := '';

jats:db-html-list($collection, $cutoff, 'STEM')