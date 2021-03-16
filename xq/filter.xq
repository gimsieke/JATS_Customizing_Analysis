declare variable $collection external := 'comm-use';
declare variable $cutoff as xs:decimal external := 0.01;
declare variable $class as xs:string external := '';

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
  <body class="{$class}">
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