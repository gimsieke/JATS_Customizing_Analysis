module namespace jats = 'http://jats.nlm.nih.gov';
declare namespace html = 'http://www.w3.org/1999/xhtml';

declare function jats:db-html-list(
  $collection as xs:string,
  $cutoff as xs:decimal,
  $class as xs:string
) as element(html:html) {
let $anames := index:attribute-names($collection),
    $enames := index:element-names($collection),
    $doccount as xs:integer := xs:integer(db:info($collection)/databaseproperties/documents),
    $threshold as xs:decimal := $doccount * $cutoff,
    $filtered-elements := $enames[number(@count) gt $threshold],
    $filtered-attributes := $anames[number(@count) gt $threshold]
return 
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>analysis of filtered collection {$collection} (cutoff {$cutoff})</title>
    <meta charset="utf-8" />
    <meta name="customization-name" content="{$collection}{$cutoff}" />
    <meta name="cached" content="true"/>
  </head>
  <body class="{$class}" data-threshold="{$threshold}" data-doccount="{$doccount}">
    <ul id="elements"
        data-orig-count="{count($enames)}" data-filtered-count="{count($filtered-elements)}"> {
      for $e in $filtered-elements 
      order by $e
      return 
      <li>{string($e)}</li>
    }</ul>
    <ul id="attributes"
        data-orig-count="{count($anames)}" data-filtered-count="{count($filtered-attributes)}"> {
      for $a in $filtered-attributes 
      order by $a
      return 
      <li>{'@' || string($a)}</li>
    }</ul>
  </body>
</html>
};

declare function jats:normalize-pmc-path (
  $path as xs:string
) as xs:string {
  let $a := $path
  return string-join(
    for $r in analyze-string($path, '&amp;#x([0-9a-f]+);')/(*:non-match | *:match/*:group )
    return if ($r/self::*:group) then codepoints-to-string(convert:integer-from-base($r, 16))
           else string($r)
  ) ! replace(., '[\p{P}\p{Zs}]+', '_')
    ! codepoints-to-string(string-to-codepoints(normalize-unicode(., 'NFD'))[. lt 128])
    ! replace(., '[\W-[_]]', '')
};