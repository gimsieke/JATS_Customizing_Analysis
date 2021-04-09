declare variable $collection external := 'comm-use';
declare variable $from external := 1;
declare variable $to external := 1000000;

for $doc in db:open($collection) [position() = ($from to $to)]
let $path := db:path($doc),
    $journal := ($path => tokenize('/'))[1]
group by $journal
where count($doc) gt 40
return (
  let $newdb := 'PMC__' || $journal
  return ( 
    if (db:exists($newdb)) 
    then for $d in $doc 
         return db:replace($newdb, db:path($d), $d)
    else db:create($newdb)    
  )
)

