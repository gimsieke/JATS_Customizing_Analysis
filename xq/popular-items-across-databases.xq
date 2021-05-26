declare variable $db-names := ('PMC_comm_use_A-B', 'PMC_non_comm_use_O-Z', 'DeGruyter', 'PsychOpen', 'ScienceOpen');
declare variable $green-oasis-uri external := 'file:/C:/cygwin/home/gerrit/XML/JATS/2020_Praktikum/JATS_Customizing_Analysis/cache/schema/JATS/1.3d2/Green/rng/JATS-archive-oasis-article1-3d2-mathml3.xhtml';
declare variable $item-type external := 'elements';
declare option output:method 'text';

(:declare function local:add-sum-to-map(
  $map as map(xs:string, item()*)
) as map {
};:)

declare function local:fraction ($nom as xs:integer?, $denom as xs:integer?) as xs:string {
  if (exists($nom))
  then format-number(math:log10($nom div $denom), '#.#')
  else '-9'
};

let $green-oasis-list := doc($green-oasis-uri),
    $index-function as function(*) := if ($item-type = 'elements') 
                                      then index:element-names#1
                                      else index:attribute-names#1,
    $mml-items as xs:string+ := $green-oasis-list//*:ul[@id = $item-type]/*:li[@class = 'mathml']
                                                                              [not(.='mml:math')] 
                                ! replace(., '^@', ''),
    $counts as map(xs:string, xs:integer)
      := map:merge($db-names ! map:entry(., xs:integer(db:info(.)/databaseproperties/documents))),
    $total-count as xs:integer := xs:integer(sum(map:for-each($counts, function($k, $v){xs:integer($v)}))),
    $items as map(xs:string, element(entry)+) 
      := map:merge($db-names ! map:entry(., $index-function(.)[not(. = $mml-items)])),
    $distinct-items as xs:string+ := sort(distinct-values(map:for-each($items, function($k, $v){$v ! string(.)}))),
    $aggregate-counts as map(xs:string, xs:integer) :=
       map:merge(
         for $item-name in $distinct-items 
         return map:entry($item-name, sum(map:for-each($items, function($k, $v){$v[. = $item-name]/@count => xs:integer()})))
       ),
    $lines as xs:string+ := (
      'Item' || "&#x9;"  || 'Aggregate' || "&#x9;" || string-join($db-names, '&#x9;'),
      for $item-name in map:keys($aggregate-counts)
      order by map:get($aggregate-counts, $item-name) descending
      return string-join(
               (
                 (if ($item-type = 'attributes') then '@' else '') || $item-name,  
                 local:fraction(map:get($aggregate-counts, $item-name), $total-count),
                 $db-names ! local:fraction(map:get($items, .)[string(.) = $item-name]/@count, map:get($counts, .))
               ), '&#x9;'
             )
    )
return string-join($lines, '&#xa;')
