declare variable $html-list-uri external := 'file:/C:/cygwin/home/gerrit/XML/JATS/2020_Praktikum/JATS_Customizing_Analysis_Data/all/PMC__Transfusion.xhtml';
declare variable $db-name external := 'comm-use';
declare variable $green-oasis-uri external := 'file:/C:/cygwin/home/gerrit/XML/JATS/2020_Praktikum/JATS_Customizing_Analysis/cache/schema/JATS/1.3d2/Green/rng/JATS-archive-oasis-article1-3d2-mathml3.xhtml';


let $html-list := doc($html-list-uri),
    $green-oasis-list := doc($green-oasis-uri),
    $list-elts as xs:string+ := $html-list//*:ul[@id = 'elements']/*:li/string(.),
    $list-atts as xs:string+ := $html-list//*:ul[@id = 'attributes']/*:li ! substring(., 2),
    $mml-elts as xs:string+ := $green-oasis-list//*:ul[@id = 'elements']/*:li[@class = 'mathml']/string(.),
    $mml-atts as xs:string+ := $green-oasis-list//*:ul[@id = 'attributes']/*:li[@class = 'mathml'] ! substring(., 2),
    $add-elts := ('tex-math', 'alternatives', 'colgroup', 'disp-quote', 'principal-award-recipient', 'uri',
                  'object-id', 'phone', 'conf-date', 'chem-struct', 'conf-loc', 'date-in-citation', 'conf-name',
                  'ali:license_ref', 'conference', 'supplement', 'prefix', 'volume-series', 'isbn', 'related-article',
                  'attrib', 'size', 'statement'),
    $maybe-add-elts := ('season'),
    $maybe-add-atts := ('season'),
    $add-atts := ('notes-type')
return 
<result>
  <elements> {
    for $e in index:element-names($db-name)[not(. = ($list-elts, $mml-elts))]
    order by number($e/@count) descending
    return element {$e/name()} {
      $e/@count, if ($e = $add-elts) then attribute {'action'} {'add'} else (), 
      if ($e = $maybe-add-elts) then attribute {'action'} {'maybe-add'} else (), string($e)
    }
  }</elements>
  <attributes> {
    for $a in index:attribute-names('comm-use')[not(. = ($list-atts, $mml-atts))]
    order by number($a/@count) descending
    return element {$a/name()} {
      $a/@count, if ($a = $add-atts) then attribute {'action'} {'add'} else (), 
      if ($a = $maybe-add-atts) then attribute {'action'} {'maybe-add'} else (), string($a)
    }
  }</attributes>
</result>
