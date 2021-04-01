declare variable $collection external := 'comm-use';

for $doc in db:open($collection) (:[position() = (1 to 200)]:)
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

